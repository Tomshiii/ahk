// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
import type {
    premierepro,
    Project,
    ProjectItem,
    Sequence,
    TickTime,
} from "@adobe/premierepro";

/** A clip's position, recorded so it can be found again after the timeline changes */
export interface TrackItemEntry {
    trackIndex: number;
    start: TickTime;
    end: TickTime;
}

export interface FreeTrackResult {
    trackIndex: number;
    needsNewTrack: boolean;
}

export interface SelectedVideoClip {
    trackIndex: number;
    item: any;
    start: TickTime;
    end: TickTime;
}

/**
 * determines the first available free track.
 * Tracks are still checked in order (so we stop at the first free one instead of
 * reading the whole timeline), but the clips within each track are read in parallel.
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

        const overlaps = await Promise.all(items.map(async (item: any) => {
            const [start, end] = await Promise.all([item.getStartTime(), item.getEndTime()]);
            return start.ticksNumber < rangeEnd.ticksNumber && end.ticksNumber > rangeStart.ticksNumber;
        }));

        if (!overlaps.some(Boolean)) {
            return { trackIndex: t, needsNewTrack: false };
        }
    }
    return { trackIndex: trackCount, needsNewTrack: true };
}

/** Finds the single clip on `track` whose start matches `startTime`. */
export async function findItemAtStart(track: any, startTime: TickTime): Promise<any | null> {
    const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);
    const starts = await Promise.all(items.map((item: any) => item.getStartTime()));
    const idx = starts.findIndex((start: TickTime) => start.ticksNumber === startTime.ticksNumber);
    return idx === -1 ? null : items[idx];
}

/** Re-scans the given tracks for clips still sitting at previously-recorded
 *  positions, and returns the matching live TrackItem objects. */
export async function findMatchingItems(
    getTrack: (index: number) => Promise<any>,
    entries: TrackItemEntry[]
): Promise<any[]> {
    const matches = await Promise.all(entries.map(async (entry) => {
        const track = await getTrack(entry.trackIndex);
        const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);

        const isMatch = await Promise.all(items.map(async (item: any) => {
            const [start, end] = await Promise.all([item.getStartTime(), item.getEndTime()]);
            return start.ticksNumber === entry.start.ticksNumber && end.ticksNumber === entry.end.ticksNumber;
        }));

        const idx = isMatch.indexOf(true);
        return idx === -1 ? null : items[idx];
    }));

    return matches.filter((item): item is any => item !== null);
}

/**
 *
 */
export async function gatherSelectedEntries(
    getTrack: (index: number) => Promise<any>,
    trackCount: number
): Promise<TrackItemEntry[]> {
    const perTrack = await Promise.all(
        Array.from({ length: trackCount }, async (_, t): Promise<TrackItemEntry[]> => {
            const track = await getTrack(t);
            const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);

            const entries = await Promise.all(items.map(async (item: any) => {
                if (!(await item.getIsSelected())) return null;
                const [start, end] = await Promise.all([item.getStartTime(), item.getEndTime()]);
                return { trackIndex: t, start, end } as TrackItemEntry;
            }));

            return entries.filter((e): e is TrackItemEntry => e !== null);
        })
    );

    return perTrack.flat();
}

/**
 * gathers every selected clip across all video tracks (tracks and clips are
 * resolved in parallel; ordering is by track index, then clip order on the track)
 */
export async function gatherSelectedVideoClips(sequence: Sequence, trackCount: number): Promise<SelectedVideoClip[]> {
    const tracks = await Promise.all(
        Array.from({ length: trackCount }, (_, t) => sequence.getVideoTrack(t))
    );

    const perTrack = await Promise.all(tracks.map(async (track, trackIndex) => {
        const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);
        const entries = await Promise.all(items.map(async (item: any) => {
            if (!(await item.getIsSelected())) return null;
            const [start, end] = await Promise.all([item.getStartTime(), item.getEndTime()]);
            return { trackIndex, item, start, end } as SelectedVideoClip;
        }));
        return entries.filter((e): e is SelectedVideoClip => e !== null);
    }));

    return perTrack.flat();
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
    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction: any) => {
            const setTempInOutAction = clipProjItem.createSetInOutPointsAction(sliceIn, sliceOut);
            compoundAction.addAction(setTempInOutAction);
        }, "Set temporary nested-item slice");
    });

    // Place. NOTE: placement actions take the raw ProjectItem, not the cast
    // ClipProjectItem -- passing the cast object here is what caused
    // "Invalid parameter." Only the in/out-point actions want the cast one.
    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction: any) => {
            const placeAction = needsNewTrack
                ? editor.createInsertProjectItemAction(nestedProjItem, startTime, videoTrackIndex, audioTrackIndex, false)
                : editor.createOverwriteItemAction(nestedProjItem, startTime, videoTrackIndex, audioTrackIndex);
            compoundAction.addAction(placeAction);
        }, "Place nested-item slice");
    });

    // Restore original in/out immediately -- each pass is self-contained.
    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction: any) => {
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
    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction: any) => {
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
 * find or create a bin
 * @returns {any}
 */
export async function findOrCreateFolderPath(rootItem: any, folderPath: string, createIfMissing: boolean = true): Promise<any> {
    const pathParts = folderPath.split(/[\/\\]+/).filter(p => p);
    let currentFolder = await ppro.FolderItem.cast(rootItem);

    for (let partIndex = 0; partIndex < pathParts.length; partIndex++) {
        const folderName = pathParts[partIndex];
        const isLastFolder = partIndex === pathParts.length - 1;

        const children = await currentFolder.getItems();
        let foundFolder = null;

        for (let i = 0; i < children.length; i++) {
            if (children[i].type === 2 && children[i].name === folderName) {
                foundFolder = await ppro.FolderItem.cast(children[i]);
                break;
            }
        }

        if (!foundFolder) {
            if (createIfMissing && isLastFolder) {
                const project = await ppro.Project.getActiveProject();
                await project.lockedAccess(() => {
                    return project.executeTransaction((compoundAction) => {
                        compoundAction.addAction(currentFolder.createBinAction(folderName, false));
                    }, "Create Bin");
                });
                await new Promise(resolve => setTimeout(resolve, 500));
                const updatedChildren = await currentFolder.getItems();
                for (let i = 0; i < updatedChildren.length; i++) {
                    if (updatedChildren[i].name === folderName) {
                        foundFolder = await ppro.FolderItem.cast(updatedChildren[i]);
                        break;
                    }
                }
                if (!foundFolder) return null;
            } else {
                return null;
            }
        }

        currentFolder = foundFolder;
    }

    return currentFolder;
}

/**
 * searches for a projectItem by name
 * @param {any} [bin] the bin you wish to search in
 * @param {string} [name] the name of the projectItem you wish to search for
 * @param {boolean} [matchFolders] if true, folders (bins) themselves are eligible matches, not just leaf items
 * @returns {any}
 */
export async function searchForItemByName(bin: any, name: string, matchFolders: boolean = false): Promise<any> {
    const children = await bin.getItems();
    for (let i = 0; i < children.length; i++) {
        const child = children[i];
        if (!child) continue;

        if (child.type !== 2 && child.name === name) {
            return child;
        }

        if (child.type === 2) {
            if (matchFolders && child.name === name) {
                return await ppro.FolderItem.cast(child);
            }
            const folder = await ppro.FolderItem.cast(child);
            const found = await searchForItemByName(folder, name, matchFolders);
            if (found) return found;
        }
    }
    return null;
}

/**
 * find and return the desired project item
 * @param {string} [itemPath] itemPath can be just a filename or a full path like "_Assets/Footage/clip.mov"
 * @returns {false | null | ProjectItem}
 */
export async function projItemByPath(itemPath: string): Promise<false | null | ProjectItem> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const lastSlashIndex = Math.max(itemPath.lastIndexOf('/'), itemPath.lastIndexOf('\\'));
    const folderPath = lastSlashIndex > -1 ? itemPath.substring(0, lastSlashIndex) : '';
    const itemName = lastSlashIndex > -1 ? itemPath.substring(lastSlashIndex + 1) : itemPath;

    const rootItem = await project.getRootItem();
    const root = await ppro.FolderItem.cast(rootItem);

    const searchFolder = folderPath
        ? await findOrCreateFolderPath(rootItem, folderPath, false)
        : root;

    if (!searchFolder) return false;

    return await searchForItemByName(searchFolder, itemName);
}

/**
 * finds sequence by projectitem id
 */
export async function findSequenceByProjectItemId(project: Project, targetId: string): Promise<Sequence | null> {
    const sequences = await project.getSequences();
    if (!sequences || sequences.length === 0) return null;

    const ids = await Promise.all(
        sequences.map(async (seq) => {
            const seqProjItem = await seq.getProjectItem();
            return (await seqProjItem.getId()).toString();
        })
    );

    const idx = ids.indexOf(targetId.toString());
    return idx === -1 ? null : sequences[idx];
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

/**
 * Finds a marker that starts on the exact same frame as targetTime.
 * Both the marker's start time and targetTime are aligned to the frame
 * grid before comparing, so this checks "same frame" rather than
 * "close enough" — no tolerance constant needed.
 */
export function findMarkerAtFrame(
    markerList: any[],
    targetTime: any, // already frame-aligned Time object (alignedPos or clipPos)
    frameRate: any
): any | null {
    for (const marker of markerList) {
        const markerAligned = marker.getStart().alignToFrame(frameRate);
        if (markerAligned.ticks === targetTime.ticks) {
            return marker;
        }
    }
    return null;
}

/**
 * Scans all sequences in the active project for names matching
 * "Nested Sequence <number>" and returns the next available name
 * in that series (e.g. "Nested Sequence 05").
 *
 * @returns {string} The next available "Nested Sequence XX" name.
 */
export async function getNextNestedSequenceName(): Promise<string | false> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const sequences = await project.getSequences();
    if (!sequences || sequences.length === 0) {
        return "Nested Sequence 01";
    }

    // Matches "Nested Sequence" followed by one or more digits, case-insensitive.
    const regex = /^Nested Sequence\s+(\d+)\s*$/i;

    let highestNum = 0;
    let padding = 2; // default padding width if none found yet (e.g. "01")

    for (const seq of sequences) {
        if (!seq || !seq.name) continue;

        const match = seq.name.match(regex);
        if (match) {
            const numStr = match[1];
            const num = parseInt(numStr, 10);

            if (num > highestNum) {
                highestNum = num;
                padding = numStr.length;
            }
        }
    }

    const nextNum = highestNum + 1;
    let nextNumStr = String(nextNum);

    if (nextNumStr.length < padding) {
        nextNumStr = nextNumStr.padStart(padding, "0");
    }

    return `Nested Sequence ${nextNumStr}`;
}