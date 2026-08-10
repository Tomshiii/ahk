// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
import type {
    premierepro,
    TickTime,
} from "@adobe/premierepro";

type ParsedProperty = {
    displayName: string;
    isTimeVarying: boolean;
    value?: any;
    keyframes?: { time: number; value: any }[];
};
type ParsedEffect = { matchName: string; displayName: string; anchorInPoint: string; properties: ParsedProperty[] };
type ParsedBucket = { mediaType: "Video" | "Audio"; effects: ParsedEffect[] };

interface XmlRecord { tag: string; content: string; }

function buildXmlIndex(xml: string): Record<string, XmlRecord> {
    const index: Record<string, XmlRecord> = {};
    const re = /<([A-Za-z0-9_]+)(?:\s[^>]*)?\bObjectID="(\d+)"[^>]*>([\s\S]*?)<\/\1>/g;
    let m: RegExpExecArray | null;
    while ((m = re.exec(xml)) !== null) {
        index[m[2]] = { tag: m[1], content: m[3] };
    }
    return index;
}

function extractTag(content: string, tagName: string): string | null {
    const re = new RegExp(`<${tagName}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${tagName}>`);
    const m = content.match(re);
    return m ? m[1] : null;
}

function extractRef(content: string, tagName: string): string | null {
    const re = new RegExp(`<${tagName}\\s+ObjectRef="(\\d+)"\\s*\\/>`);
    const m = content.match(re);
    return m ? m[1] : null;
}

function extractAllRefs(content: string, containerTag: string, itemTag: string): string[] {
    const container = extractTag(content, containerTag);
    if (!container) return [];
    const re = new RegExp(`<${itemTag}\\s+Index="(\\d+)"\\s+ObjectRef="(\\d+)"\\s*\\/>`, "g");
    const results: { index: number; ref: string }[] = [];
    let m: RegExpExecArray | null;
    while ((m = re.exec(container)) !== null) {
        results.push({ index: Number(m[1]), ref: m[2] });
    }
    results.sort((a, b) => a.index - b.index);
    return results.map(r => r.ref);
}

function extractParamName(content: string): string {
    return extractTag(content, "Name") ?? extractTag(content, "n") ?? "";
}

function parseStartKeyframeValue(raw: string | null): any {
    if (!raw) return undefined;
    const rawValue = raw.split(",")[1];
    if (rawValue === "true") return true;
    if (rawValue === "false") return false;
    const num = Number(rawValue);
    return Number.isNaN(num) ? rawValue : num;
}

export function prfpsetXmlToBuckets(xmlText: string): ParsedBucket[] {
    const index = buildXmlIndex(xmlText);
    const buckets: Record<string, ParsedEffect[]> = {};

    for (const id in index) {
        const rec = index[id];
        if (rec.tag !== "FilterPresetItem") continue;

        for (const presetId of extractAllRefs(rec.content, "FilterPresets", "FilterPreset")) {
            const presetRec = index[presetId];
            if (!presetRec) continue;

            const matchName = extractTag(presetRec.content, "FilterMatchName") ?? "";
            const componentRef = extractRef(presetRec.content, "Component");
            const componentRec = componentRef ? index[componentRef] : null;
            if (!componentRec) continue;

            const mediaType = componentRec.tag === "VideoFilterComponent" ? "Video" : "Audio";
            const innerBlock = extractTag(componentRec.content, "Component") ?? componentRec.content;
            const displayName = extractTag(innerBlock, "DisplayName") ?? "";
            const anchorInPoint = extractTag(presetRec.content, "AnchorInPoint") ?? "0";
            const anchorOutPoint = extractTag(presetRec.content, "AnchorOutPoint") ?? anchorInPoint;

            const properties: ParsedProperty[] = [];
            for (const paramId of extractAllRefs(innerBlock, "Params", "Param")) {
                const paramRec = index[paramId];
                if (!paramRec) {
                    properties.push({ displayName: "", isTimeVarying: false, value: undefined });
                    continue;
                }
                const name = extractParamName(paramRec.content);
                const isTimeVarying = (extractTag(paramRec.content, "IsTimeVarying") ?? "false") === "true";

                if (isTimeVarying) {
                    const keyframesRaw = extractTag(paramRec.content, "Keyframes") ?? "";
                    const keyframes: { time: string; value: any }[] = [];

                    for (const entry of keyframesRaw.split(";").map(s => s.trim()).filter(Boolean)) {
                        const parts = entry.split(",");
                        const time = parts[0]; // keep as string -- these ticks can exceed Number safe-integer precision
                        const rawValue = parts[1];
                        let value: any;
                        if (rawValue === "true") value = true;
                        else if (rawValue === "false") value = false;
                        else {
                            const num = Number(rawValue);
                            value = Number.isNaN(num) ? rawValue : num;
                        }
                        keyframes.push({ time, value });
                    }
                    properties.push({ displayName: name, isTimeVarying: true, keyframes });
                } else {
                    const startKeyframeRaw = extractTag(paramRec.content, "StartKeyframe");
                    properties.push({ displayName: name, isTimeVarying: false, value: parseStartKeyframeValue(startKeyframeRaw) });
                }
            }

            if (!buckets[mediaType]) buckets[mediaType] = [];
            buckets[mediaType].push({ matchName, displayName, anchorInPoint, anchorOutPoint, properties });
        }
    }

    return Object.entries(buckets).map(([mediaType, effects]) => ({
        mediaType: mediaType as "Video" | "Audio",
        effects,
    }));
}

export function formatTimecode(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.floor(seconds % 60);
  const ms = Math.round((seconds - Math.floor(seconds)) * 1000);
  const pad = (n, len = 2) => String(n).padStart(len, "0");
  return `${pad(h)}:${pad(m)}:${pad(s)}.${pad(ms, 3)}`;
}

/**
 * determines the first available free track
 */
export async function findFirstFreeTrack(
    getTrack: (index: number) => Promise<any>,
    trackCount: number,
    rangeStart: TickTime,
    rangeEnd: TickTime,
    searchFrom: number = 0
): Promise<FreeTrackResult> {
    for (let t = searchFrom; t < trackCount; t++) {
        const track = await getTrack(t);
        const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);

        let free = true;
        for (const item of items) {
            const start = await item.getStartTime();
            const end = await item.getEndTime();
            if (start.ticksNumber < rangeEnd.ticksNumber && end.ticksNumber > rangeStart.ticksNumber) {
                free = false;
                break;
            }
        }

        if (free) {
            return { trackIndex: t, needsNewTrack: false };
        }
    }
    return { trackIndex: trackCount, needsNewTrack: true };
}