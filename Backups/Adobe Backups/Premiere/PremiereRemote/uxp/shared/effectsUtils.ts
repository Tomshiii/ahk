// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
import type {
    premierepro,
} from "@adobe/premierepro";
import { storage } from "uxp";
import * as common from "../common";
import { fileExists } from "./fileUtils";
import { prfpsetXmlToBuckets } from "./prfpset";

const lfs = storage.localFileSystem;

export interface PropertyEntry {
    displayName: string;
    isTimeVarying: boolean;
    value?: any;
    keyframes?: { time: string; value: any }[];
}

export interface EffectEntry {
    matchName: string;
    displayName?: string;
    properties: PropertyEntry[];
    anchorInPoint?: string | number;
    anchorOutPoint?: string | number;
    timeOrigin?: string;
    timeDomain?: "source" | "timeline";
}

/**
 * parses already-decoded text (plain JSON or plain prfpset XML) into buckets
 */
function parsePayloadText(text: string): { mediaType: string, effects: EffectEntry[] }[] | false {
    try {
        const trimmed = text.trim();
        if (trimmed.startsWith("<?xml") || trimmed.startsWith("<PremiereData")) {
            return prfpsetXmlToBuckets(text);
        }
        return JSON.parse(trimmed.replace(/\\"/g, '"'));
    } catch (e: any) {
        console.log("parsePayloadText error:", e);
        return false;
    }
}

/**
 * accepts either a real file path (.json or .prfpset) or a legacy base64-encoded
 * JSON string, and returns parsed buckets, or false on failure
 */
export async function readAndDecodeText(filePathOrData: string): Promise<{ mediaType: string, effects: EffectEntry[] }[] | false> {
    try {
        // Same clean-up fileExists does, so what we check is what we open
        const cleanedPath = String(filePathOrData ?? "").trim().replace(/^["']|["']$/g, "").replace(/^file:\/\/\/?/i, "");
        const exists = await fileExists(cleanedPath);

        if (exists) {
            const url = "file:///" + cleanedPath.replace(/\\/g, "/");
            console.log("resolved url:", url);

            const entry = await lfs.getEntryWithUrl(url);
            console.log("entry:", entry);

            const text = await entry.read({ format: storage.formats.utf8 });
            console.log("read length:", text?.length, "starts with:", text?.slice(0, 30));

            const parsed = parsePayloadText(text);
            console.log("parsed:", parsed);
            return parsed;
        }

        const trimmed = String(filePathOrData ?? "").trim();

        // Raw JSON or prfpset XML passed in directly
        if (/^[\[{<]/.test(trimmed)) {
            return parsePayloadText(trimmed);
        }

        // Looks like a file path, but fs couldn't find it -- say so rather than
        // falling through to a confusing base64 decode error
        if (/^[A-Za-z]:[\\/]/.test(trimmed) || /^\\\\/.test(trimmed) || trimmed.startsWith("/")) {
            console.log("readAndDecodeText: file not found at path:", trimmed);
            return false;
        }

        // Legacy: base64-encoded JSON
        const decoded = atob(trimmed);
        return parsePayloadText(decoded);
    } catch (e: any) {
        console.log("readAndDecodeText error:", e);
        return false;
    }
}

/**
 * How far to shift saved keyframe times so they land on `item`, in the same
 * domain (source/timeline) they were saved in. 0 for the clip they came from,
 * and 0 for older saves that don't carry origin info (previous behaviour).
 */
export async function computeKeyframeShift(item: any, fx: EffectEntry): Promise<bigint> {
    if (fx.timeOrigin === undefined || !fx.timeDomain) return 0n;
    const target = fx.timeDomain === "source" ? await item.getInPoint() : await item.getStartTime();
    return BigInt(target.ticks) - BigInt(fx.timeOrigin);
}

/**
 * adjust component parameters of the selected clips
 * @param {number} [componentIndex] unassigned masks is `0`, `Motion` is `1`
 * @param {number} [paramIndex]
 * @param {number | string | boolean} [value]
 * @returns {void}
 */
export async function setClipComponentParam(
    componentIndex: number,
    paramIndex: number,
    value: number | string | boolean
): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;
    const sequence = await common.getActiveSequence();
    if (!sequence) return;
    const items = await common.getSelectedTrackItems(sequence);
    if (!items || items.length === 0) return;

    // coerce value to correct type
    let coercedValue: any;
    if (typeof value === "string" && value.includes(",")) {
        const parts = value.split(",").map(Number);
        const settings = await sequence.getSettings();
        const frameRect = await settings.getVideoFrameRect();
        coercedValue = await ppro.PointF(Number(parts[0] / frameRect.width), Number(parts[1] / frameRect.height));
    } else if (value === "true" || value === "false") {
        coercedValue = value === "true";
    } else if (!isNaN(Number(value))) {
        coercedValue = Number(value);
    } else {
        coercedValue = value;
    }

    // Each item's chain is independent, so resolve them all at once.
    // Promise.all keeps results in the same order as `items`.
    const results = await Promise.all(items.map(async (item) => {
        const chain = await item.getComponentChain();
        if (!chain) return null;

        const component = await chain.getComponentAtIndex(componentIndex);
        if (!component) return null;

        const param = await component.getParam(paramIndex);
        if (!param) return null;

        const keyframe = await param.createKeyframe(coercedValue);
        return { param, keyframe };
    }));
    const paramData = results.filter((r): r is { param: any, keyframe: any } => r !== null);

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            for (const { param, keyframe } of paramData) {
                try {
                    compoundAction.addAction(param.createSetValueAction(keyframe, true));
                } catch (e) {
                    console.log("error:", e);
                }
            }
        }, "Set Component Param");
    });
}

/**
 * Saved point params (Position, Anchor Point...) come back from JSON as plain
 * [x, y] arrays, but createKeyframe wants a PointF (same wrapping setClipComponentParam
 * and anchorToPosition already do).
*/
export async function toParamValue(value: any): Promise<any> {
    if (Array.isArray(value) && value.length === 2 && value.every((n) => typeof n === "number")) {
        return await ppro.PointF(value[0], value[1]);
    }
    return value;
}

/** createKeyframe wrapper that logs (instead of silently dropping) failures. */
export async function createParamKeyframe(param: any, value: any, label: string): Promise<any | null> {
    try {
        const keyframe = await param.createKeyframe(await toParamValue(value));
        if (!keyframe) console.log(`[applyEffectSlotJSON] createKeyframe returned nothing for ${label}, value=`, value);
        return keyframe ?? null;
    } catch (e) {
        console.log(`[applyEffectSlotJSON] createKeyframe FAILED for ${label}, value=`, value, e);
        return null;
    }
}

export function dbToEncoded(db: number): number {
    return Math.min(Math.pow(10, (db - 15) / 20), 1.0);
}

export function encodedToDb(encoded: number): number {
    return 20 * Math.log(encoded) * Math.LOG10E + 15;
}
