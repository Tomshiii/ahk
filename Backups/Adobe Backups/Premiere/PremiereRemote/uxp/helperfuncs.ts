// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
import type {
    premierepro,
    Project,
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
    searchFrom: number = 0,
    ignoreTracks: Set<number> = new Set()
): Promise<FreeTrackResult> {
    for (let t = searchFrom; t < trackCount; t++) {
        if (ignoreTracks.has(t)) continue;

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

/**
 * parse comma separate string
 */
export function parseTrackList(input: string): Set<number> {
    const result = new Set<number>();
    if (!input) return result;
    for (const part of input.split(",")) {
        const trimmed = part.trim();
        if (trimmed === "") continue;
        const n = parseInt(trimmed, 10);
        if (!isNaN(n)) {
            result.add(n - 1);
        }
    }
    return result;
}

/**
 * Places a [sliceIn, sliceOut) slice of clipProjItem at `startTime` on
 * `realTrackIndex` (of type `realMediaType`), and discards whatever lands
 * on the other media type's track (found via a fresh free-space scan
 * across the same time range).
 */
export async function placeMediaSlice(
    project: any,
    editor: any,
    sequence: any,
    nestedProjItem: any,
    clipProjItem: any,
    sliceIn: TickTime,
    sliceOut: TickTime,
    startTime: TickTime,
    realTrackIndex: number,
    realIsVideo: boolean,
    originalInPoint: TickTime,
    originalOutPoint: TickTime,
    hadOriginalInOut: boolean,
    ignoreVideoTracks: Set<number> = new Set(),
    ignoreAudioTracks: Set<number> = new Set()
): Promise<void> {
    const sliceDuration = sliceOut.subtract(sliceIn);
    const endTime = startTime.add(sliceDuration);
    const otherTrackCount = realIsVideo ? await sequence.getAudioTrackCount() : await sequence.getVideoTrackCount();
    const otherGetTrack = realIsVideo ? (i: number) => sequence.getAudioTrack(i) : (i: number) => sequence.getVideoTrack(i);
    const otherIgnoreSet = realIsVideo ? ignoreAudioTracks : ignoreVideoTracks;
    const scratch = await findFirstFreeTrack(otherGetTrack, otherTrackCount, startTime, endTime, 0, otherIgnoreSet);

    const videoTrackIndex = realIsVideo ? realTrackIndex : scratch.trackIndex;
    const audioTrackIndex = realIsVideo ? scratch.trackIndex : realTrackIndex;
    const needsNewTrack = scratch.needsNewTrack; // real track is always pre-existing (see below)

    // Trim to this pass's slice.
    project.lockedAccess(() => {
        project.executeTransaction((compoundAction: any) => {
            const setTempInOutAction = clipProjItem.createSetInOutPointsAction(sliceIn, sliceOut);
            compoundAction.addAction(setTempInOutAction);
        }, "Set temporary nested-item slice");
    });

    // Place. NOTE: placement actions take the raw ProjectItem, not the cast
    // ClipProjectItem -- passing the cast object here is what caused
    // "Invalid parameter." Only the in/out-point actions want the cast one.
    project.lockedAccess(() => {
        project.executeTransaction((compoundAction: any) => {
            const placeAction = needsNewTrack
                ? editor.createInsertProjectItemAction(nestedProjItem, startTime, videoTrackIndex, audioTrackIndex, false)
                : editor.createOverwriteItemAction(nestedProjItem, startTime, videoTrackIndex, audioTrackIndex);
            compoundAction.addAction(placeAction);
        }, "Place nested-item slice");
    });

    // Restore original in/out immediately -- each pass is self-contained.
    project.lockedAccess(() => {
        project.executeTransaction((compoundAction: any) => {
            const restoreAction = hadOriginalInOut
                ? clipProjItem.createSetInOutPointsAction(originalInPoint, originalOutPoint)
                : clipProjItem.createClearInOutPointsAction();
            compoundAction.addAction(restoreAction);
        }, "Restore nested item duration");
    });

    // Discard whatever landed on the scratch track.
    const scratchTrack = realIsVideo ? await sequence.getAudioTrack(scratch.trackIndex) : await sequence.getVideoTrack(scratch.trackIndex);
    const scratchItem = await findItemAtStart(scratchTrack, startTime);
    if (scratchItem) {
        await removeItems(
            project,
            editor,
            [scratchItem],
            realIsVideo ? ppro.Constants.MediaType.AUDIO : ppro.Constants.MediaType.VIDEO,
            "Remove scratch placement"
        );
    }
}

/** Finds the single clip on `track` whose start matches `startTime`. */
export async function findItemAtStart(track: any, startTime: TickTime): Promise<any | null> {
    const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);
    for (const item of items) {
        const start = await item.getStartTime();
        if (start.ticksNumber === startTime.ticksNumber) return item;
    }
    return null;
}

/** Re-scans the given tracks for clips still sitting at previously-recorded
 *  positions, and returns the matching live TrackItem objects. */
export async function findMatchingItems(
    getTrack: (index: number) => Promise<any>,
    entries: TrackItemEntry[]
): Promise<any[]> {
    const found: any[] = [];
    for (const entry of entries) {
        const track = await getTrack(entry.trackIndex);
        const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);
        for (const item of items) {
            const start = await item.getStartTime();
            const end = await item.getEndTime();
            if (start.ticksNumber === entry.start.ticksNumber && end.ticksNumber === entry.end.ticksNumber) {
                found.push(item);
                break;
            }
        }
    }
    return found;
}

/**
 *
 */
export async function removeItems(
    project: any,
    editor: any,
    items: any[],
    mediaType: any,
    undoString: string
): Promise<void> {
    if (items.length === 0) return;
    project.lockedAccess(() => {
        project.executeTransaction((compoundAction: any) => {
            ppro.TrackItemSelection.createEmptySelection((selection: any) => {
                for (const item of items) {
                    selection.addItem(item);
                }
                const removeAction = editor.createRemoveItemsAction(selection, false /* ripple */, mediaType);
                compoundAction.addAction(removeAction);
            });
        }, undoString);
    });
}

/**
 *
 */
export async function gatherSelectedEntries(
    getTrack: (index: number) => Promise<any>,
    trackCount: number
): Promise<TrackItemEntry[]> {
    const entries: TrackItemEntry[] = [];
    for (let t = 0; t < trackCount; t++) {
        const track = await getTrack(t);
        const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);
        for (const item of items) {
            if (await item.getIsSelected()) {
                const start = await item.getStartTime();
                const end = await item.getEndTime();
                entries.push({ trackIndex: t, start, end });
            }
        }
    }
    return entries;
}

/**
 * import specific sequences from unopened prproj files
 * @param {Project} [activeProject] the opened project you wish to copy into
 * @param {string} [sourceProjectPath] path to project file you wish to import from
 * @param {string} [sequenceNames] name of sequence you wish to import
 * @returns {boolean}
 */
export async function importSequencesFromProject(activeProject: Project, sourceProjectPath: string, sequenceNames: string): Promise<boolean> {
    const sourceProject = await ppro.Project.open(sourceProjectPath);
    const sequences = await sourceProject.getSequences();
    const targetSequences = sequences.filter(seq => sequenceNames.includes(seq.name));
    const guids = targetSequences.map(seq => seq.guid);
    await sourceProject.close();
    const success = await activeProject.importSequences(sourceProjectPath, guids);

    return success;
}