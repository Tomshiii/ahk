/**
 * @fileoverview Tomshi functions
 * @version 1.0.2
 */

import { getActiveSequence } from "./common";
import { getClipType } from "./properties";

import type {
    premierepro,
    Sequence,
    TickTime,
    VideoTrack,
    TrackItemSelection,
    ProjectItem,
} from "@adobe/premierepro";

// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
const { Constants } = ppro;
const openSequences = new Set<string>();
import * as uxp from "uxp";

/**
 * store sequences
 * @returns {void}
 */
export async function initSequenceTracking(): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    // add currently active sequence as a starting point
    const active = await project.getActiveSequence();
    if (active) openSequences.add(active.guid.toString());

    ppro.EventManager.addEventListener(ppro.SequenceEvent.ACTIVATED, (e: any) => {
        openSequences.add(e.guid.toString());
    });

    ppro.EventManager.addEventListener(ppro.SequenceEvent.CLOSED, (e: any) => {
        openSequences.delete(e.guid.toString());
    });
}

/**
 * saves the current project
 * @returns {boolean}
 */
export async function save(): Promise<Boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    return !!project.save();
}

/**
 * focuses the desired sequence. may cause issues with current selection if you try to focus a sequence that is no longer open
 * @param {String} [ID] the id of the sequence
 * @returns {boolean}
 */
export async function focusSequence(ID: string): Promise<boolean> {
    if (!openSequences.has(ID)) return false;

    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const guid = await ppro.Guid.fromString(ID);
    if (!guid) return false;

    const selectedSequence = await project.getSequence(guid);
    if (!selectedSequence) return false;

    await project.setActiveSequence(selectedSequence);
    return true;
}

/**
 * opens the desired sequence
 * @param {String} [ID] the id of the sequence
 * @returns {boolean}
 */
export async function openSequence(ID: string): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    const origSequence = await project.getActiveSequence();
    if (!project || !origSequence) return false;

    const guid = await ppro.Guid.fromString(ID);
    const SEQguid = await ppro.Guid.toString(origSequence.guid);
    if (!guid) return false;
    if (SEQguid == ID) return true;

    const selectedSequence = await project.getSequence(guid);
    return await project.openSequence(selectedSequence);
}

/**
 * closes the active sequence
 * @returns {void}
 */
export async function closeActiveSequence(): Promise<void> {
    const activeProj = await ppro.Project.getActiveProject();
    const seq = await getActiveSequence();
    return activeProj.closeSequence(seq);
}

/**
 * Moves the playhead
 * @param {boolean} [subtract] whether to add or subtract the desired time to the current playhead position
 * @param {number} [seconds] the amount of seconds you wish to move the playhead. will be automatically converted to the current timebase
 * @returns {void}
 */
export async function movePlayhead(subtract: boolean, seconds: number): Promise<void> {
    const sequence = await getActiveSequence();
    if (!sequence) return;

    const settings = await sequence.getSettings();
    const frameRate = settings.getVideoFrameRate(); // synchronous method call

    const frames = Math.round(seconds * frameRate.value);
    const offset = ppro.TickTime.createWithFrameAndFrameRate(frames, frameRate);

    const currentPos = await sequence.getPlayerPosition();

    const newTime = subtract
        ? currentPos.subtract(offset)
        : currentPos.add(offset);

    await sequence.setPlayerPosition(newTime);
}

/**
 * Moves the playhead in frames
 * @param {boolean} [subtract] whether to add or subtract the desired time to the current playhead position
 * @param {number} [frames] the amount of frames you wish to move the playhead. will be automatically converted to the current timebase
 * @returns {void}
 */
export async function movePlayheadFrames(subtract: boolean, frames: number): Promise<void> {
    const sequence = await getActiveSequence();
    if (!sequence) return;

    const settings = await sequence.getSettings();
    const frameRate = settings.getVideoFrameRate(); // synchronous method call
    const offset = ppro.TickTime.createWithFrameAndFrameRate(frames, frameRate);

    const currentPos = await sequence.getPlayerPosition();

    const newTime = subtract
        ? currentPos.subtract(offset)
        : currentPos.add(offset);

    await sequence.setPlayerPosition(newTime);
}

/**
 * close current active clip at source monitor
 * @returns {void}
 */
export async function closeClipSourceMon(): Promise<any> {
    return ppro.SourceMonitor.closeClip();
}

/**
 * close all clips at source monitor
 * @returns {void}
 */
export async function closeAllClipSourceMon(): Promise<any> {
    return ppro.SourceMonitor.closeAllClips();
}

/**
 * deselect all trackitems
 * @returns {void}
 */
export async function deselectAll(): Promise<void> {
    const sequence = await getActiveSequence();
    if (!sequence) return;

    return await sequence.clearSelection();
}

/**
 * set the sequence zero point
 * @param {number} [frames] the amount of frames. will automatically be converted for the current sequence
 * @returns {void}
 */
export async function setZeroPoint(frames: number): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    const sequence = await getActiveSequence();
    if (!sequence) return;
    const settings = await sequence.getSettings();
    const frameRate = settings.getVideoFrameRate(); // synchronous method call
    const offset = ppro.TickTime.createWithFrameAndFrameRate(frames, frameRate);

     project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            compoundAction.addAction(
                sequence.createSetZeroPointAction(offset)
            );
        });
    });
}

/**
 * determine if there is a selection
 * @returns {boolean}
 */
export async function isSelected(): Promise<boolean> {
    const sequence = await getActiveSequence();
    if (!sequence) return false;
    const selection = await sequence.getSelection();
    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return false;

    return true;
}

/**
 * determine if there is a selection. if there is, return it
 * @returns {TrackItemSelection}
 */
export async function isSelectedReturn(): Promise<TrackItemSelection> {
    const sequence = await getActiveSequence();
    if (!sequence) return false;
    const selection = await sequence.getSelection();
    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return false;

    return items;
}

/**
 * determine if the first selected clip is enabled
 * @returns {boolean}
 */
export async function isClipEnabled(): Promise<boolean> {
    const sequence = await getActiveSequence();
    if (!sequence) return false;

    const items = isSelectedReturn();
    if (!items) return false;
    const isDisabled = await items[0].isDisabled();
    if (isDisabled == true)
        return false;
    return true;
}

/**
 * toggles selected clips
 * @returns {void}
 */
export async function toggleEnabled(): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await project.getActiveSequence();
    if (!sequence) return;

    const selection = await sequence.getSelection();
    if (!selection) return;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return;

    const states: boolean[] = [];
    for (let i = 0; i < items.length; i++) {
        states.push(await items[i].isDisabled());
    }

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (let i = 0; i < items.length; i++) {
                const action = items[i].createSetDisabledAction(!states[i]);
                compoundAction.addAction(action);
            }
        }, "Toggle Enabled");
    });
}

/**
 * return the audio track count
 * @returns {String | null}
 */
export async function getAudioTracks(): Promise<string | null> {
    const sequence = await getActiveSequence();
    if (!sequence) return null;

    return String(await sequence.getAudioTrackCount());
}

/**
 * return the audio track count
 * @returns {String | null}
 */
export async function getVideoTracks(): Promise<string | null> {
    const sequence = await getActiveSequence();
    if (!sequence) return null;

    return String(await sequence.getVideoTrackCount());
}

/**
 * returns the current selection in the project panel
 * @returns {boolean | ProjectItem}
 */
export async function getProjectSelection(): Promise<boolean | ProjectItem> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const selection = await ppro.ProjectUtils.getSelection(project);
    if (!selection) return false;

    const items = await selection.getItems();
    if (!items || items.length === 0) return false;
    return items;
}

/**
 * determine if the currently selected project item is a sequence
 * @returns {boolean}
 */
export async function projectSelectionIsSequence(): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const items = await getProjectSelection();
    if (!items) return false;

    const selectedId = await items[0].getId();
    const sequences = await project.getSequences();
    if (!sequences || sequences.length === 0) return false;

    for (let i = 0; i < sequences.length; i++) {
        const seqProjectItem = await sequences[i].getProjectItem();
        const seqId = await seqProjectItem.getId();
        if (seqId.toString() === selectedId.toString()) return true;
    }

    return false;
}

/**
 * determines if the currently selected clipitem is a sequence
 * @returns {boolean}
 */
export async function clipSelectionIsSequence(): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const selection = await isSelectedReturn();
    if (!selection) return false;

    const projItem = await selection[0].getProjectItem();
    const selectedId = await projItem.getId();

    const sequences = await project.getSequences();
    if (!sequences || sequences.length === 0) return false;

    for (let i = 0; i < sequences.length; i++) {
        const seqProjectItem = await sequences[i].getProjectItem();
        const seqId = await seqProjectItem.getId();
        if (seqId.toString() === selectedId.toString()) return true;
    }

    return false;
}

/**
 * Export file
 * @returns {string | false}
 */
export async function renderInPrem(outputPath: string, presetPath: string): Promise<string | false> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const selection = await ppro.ProjectUtils.getSelection(project);
    if (!selection) return false;

    const items = await selection.getItems();
    if (!items || items.length === 0) return false;

    const selectedId = await items[0].getId();

    const sequences = await project.getSequences();
    if (!sequences || sequences.length === 0) return false;

    let sequence = null;
    for (let i = 0; i < sequences.length; i++) {
        const seqProjectItem = await sequences[i].getProjectItem();
        const seqId = await seqProjectItem.getId();
        if (seqId.toString() === selectedId.toString()) {
            sequence = sequences[i];
            break;
        }
    }
    if (!sequence) return false;

    outputPath = outputPath.replace(/\//g, "\\");
    presetPath = presetPath.replace(/\//g, "\\");

    const rawExtension = await ppro.EncoderManager.getExportFileExtension(sequence, presetPath);
    if (!rawExtension) return false;
    const extension = rawExtension.startsWith(".") ? rawExtension : "." + rawExtension;

    const baseName = sequence.name;
    let finalPath = outputPath + "\\" + baseName;
    let counter = 1;

    while (await fileExists(finalPath + extension)) {
        console.log("file exists, incrementing:", finalPath + extension);
        finalPath = outputPath + "\\" + baseName + "_" + counter;
        counter++;
    }
    console.log("final path chosen:", finalPath + extension);

    finalPath = finalPath + extension;

    const encoder = await ppro.EncoderManager.getManager();
    await encoder.exportSequence(
        sequence,
        ppro.Constants.ExportType.IMMEDIATELY,
        finalPath,
        presetPath
    );

    return finalPath;
}

/**
 * check if file exists
 * @returns {boolean}
 */
export async function fileExists(filePath: string): Promise<boolean> {
    try {
        const fs = require("fs");
        const forwardPath = filePath.replace(/\\/g, "/");
        const lastSlash = forwardPath.lastIndexOf("/");
        const dir = forwardPath.substring(0, lastSlash);
        const fileName = forwardPath.substring(lastSlash + 1);
        const entries = fs.readdirSync("file:" + dir);
        console.log("entries:", entries);
        return entries.includes(fileName);
    } catch (e) {
        console.log("fileExists error:", e);
        return false;
    }
}

/**
 * import file into project
 * @returns {boolean}
 */
export async function importFile(filePath: string, importAsStills: boolean): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;
    const rootBin = await project.getRootItem();
    if (!rootBin) return false;

    return project.importFiles([filePath], false, rootBin, importAsStills);
}

/**
 * move selected clips. may cause visual bugs. see link
 * @link https://forums.creativeclouddeveloper.com/t/reatemoveaction-bugs-invisible-same-source-clip-after-move-and-av-link-breaks-on-backward-audio-move/11831
 * @returns {void}
 */
export async function moveClip(subtract: boolean, seconds: number): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await project.getActiveSequence();
    if (!sequence) return;

    const settings = await sequence.getSettings();
    const frameRate = settings.getVideoFrameRate();
    const frames = Math.round(seconds * frameRate.value);
    const offset = subtract
        ? ppro.TickTime.createWithFrameAndFrameRate(-frames, frameRate)
        : ppro.TickTime.createWithFrameAndFrameRate(frames, frameRate);

    const selection = await sequence.getSelection();
    if (!selection) return;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return;

    // gather start and end times before transaction
    const startTimes = [];
    const endTimes = [];
    for (let i = 0; i < items.length; i++) {
        startTimes.push(await items[i].getStartTime());
        endTimes.push(await items[i].getEndTime());
    }

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction: any) => {
            for (let i = 0; i < items.length; i++) {
                const newStart = subtract ? startTimes[i].subtract(offset) : startTimes[i].add(offset);
                const newEnd = subtract ? endTimes[i].subtract(offset) : endTimes[i].add(offset);
                compoundAction.addAction(items[i].createSetStartAction(newStart));
                compoundAction.addAction(items[i].createSetEndAction(newEnd));
            }
        }, "Move Clip");
    });
}

/**
 * enable or disable all selected clips
 * @param {boolean} [enabled]
 * @returns {void}
 */
export async function setAllEnabledDisabled(enabled: boolean): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await project.getActiveSequence();
    if (!sequence) return;

    const selection = await sequence.getSelection();
    if (!selection) return;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return;

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (let i = 0; i < items.length; i++) {
                const action = items[i].createSetDisabledAction(!enabled);
                compoundAction.addAction(action);
            }
        }, "Set Enabled/Disabled");
    });

    return;
}

/**
 * setup premiere bin structure
 * @returns {void}
 */
export async function setupProjBin(): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const rootItem = await project.getRootItem();
    if (!rootItem) return;

    const rootBins = ["_Assets", "_linked comps & renders", "_Sequences"];
    const subBins = [
        "01_Other",
        "02_Images",
        "03_sfx",
        "04_Music",
        "05_Other Audio",
        "06_Videos",
        "07_Other Assets"
    ];

    async function getChildNames(folder: any): Promise<string[]> {
        const items = await folder.getItems();
        const names: string[] = [];
        for (let i = 0; i < items.length; i++) {
            names.push(items[i].name);
        }
        return names;
    }

    const rootChildren = await getChildNames(rootItem);

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (const binName of rootBins) {
                if (!rootChildren.includes(binName)) {
                    compoundAction.addAction(rootItem.createBinAction(binName, false));
                }
            }
            if (!rootChildren.includes("_Status:Offline")) {
                compoundAction.addAction(rootItem.createSmartBinAction("_Status:Offline", "Offline"));
            }
        }, "Setup Project Bins");
    });

    await new Promise(resolve => setTimeout(resolve, 500));

    const rootChildrenAfter = await rootItem.getItems();
    let assetsBin = null;
    for (let i = 0; i < rootChildrenAfter.length; i++) {
        if (rootChildrenAfter[i].name === "_Assets") {
            assetsBin = await ppro.FolderItem.cast(rootChildrenAfter[i]);
            break;
        }
    }
    if (!assetsBin) return;

    const assetsChildren = await getChildNames(assetsBin);

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (const binName of subBins) {
                if (!assetsChildren.includes(binName)) {
                    compoundAction.addAction(assetsBin.createBinAction(binName, false));
                }
            }
        }, "Setup Assets Sub-Bins");
    });
}

/**
 * make all video tracks of the curret sequence visible
 * @returns {void}
 */
export async function unhideAllVideoTracks(): Promise<void> {
    const sequence = await getActiveSequence();
    if (!sequence) return;

    const trackCount = await sequence.getVideoTrackCount();
    for (let i = 0; i < trackCount; i++) {
        const track = await sequence.getVideoTrack(i);
        await track.setMute(false);
    }
}

/**
 * unmute all audio tracks
 * @returns {void}
 */
export async function unmuteAllTracks(): Promise<void> {
    const sequence = await getActiveSequence();
    if (!sequence) return;

    const trackCount = await sequence.getAudioTrackCount();
    for (let i = 0; i < trackCount; i++) {
        const track = await sequence.getAudioTrack(i);
        await track.setMute(false);
    }
}

/**
 * this function expects a `|` delimited list of param/value pairs; x-y-z|x2-y-z2 where `x` is the name of the setting in premiere's settings object, `y` is the new value, `z` is either `true`/`false` to determine if the `y` value should be interpreted as a number instead of as a string
 * params/values must be distinguished by `-` and settings must be separated by `|`.
 * ie. videoFrameHeight-2160-true|videoFrameWidth-3840-true|videoFrameRate-29.97-true
 * @param {string} [params]
 * @returns {string | void}
 */
export async function setSeqSettings(params: string): Promise<string | void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await getActiveSequence();
    if (!sequence) return;

    const settings = await sequence.getSettings();
    if (!settings) return;

    for (const v of params.split("|")) {
        const split = v.split("-");
        const key = split[0];
        const value = split[1];

        switch (key) {
            case "videoFrameRate": {
                const frameRate = ppro.FrameRate.createWithValue(Number(value));
                await settings.setVideoFrameRate(frameRate);
                break;
            }
            case "videoFrameHeight": {
                const rect = await settings.getVideoFrameRect();
                rect.height = Number(value);
                await settings.setVideoFrameRect(rect);
                break;
            }
            case "videoFrameWidth": {
                const rect = await settings.getVideoFrameRect();
                rect.width = Number(value);
                await settings.setVideoFrameRect(rect);
                break;
            }
            case "videoFieldType":
                await settings.setVideoFieldType(Number(value));
                break;
            case "videoPixelAspectRatio":
                await settings.setVideoPixelAspectRatio(value);
                break;
            case "compositeInLinearColor":
                await settings.setCompositeInLinearColor(value === "true");
                break;
            case "maximumBitDepth":
                await settings.setMaximumBitDepth(value === "true");
                break;
            case "maxRenderQuality":
                await settings.setMaxRenderQuality(value === "true");
                break;
            case "previewCodec":
                await settings.setPreviewCodec(value);
                break;
            case "previewFileFormat":
                await settings.setPreviewFileFormat(value);
                break;
            case "audioDisplayFormat":
                await settings.setAudioDisplayFormat(value as any);
                break;
            case "audioSampleRate": {
                const frameRate = ppro.FrameRate.createWithValue(Number(value));
                await settings.setAudioSampleRate(frameRate);
                break;
            }
            case "editingMode":
                await settings.setEditingMode(value);
                break;
            case "previewFrameRect": {
                const rect = await settings.getPreviewFrameRect();
                const [width, height] = value.split("x").map(Number);
                rect.width = width;
                rect.height = height;
                await settings.setPreviewFrameRect(rect);
                break;
            }
            case "videoDisplayFormat":
                await settings.setVideoDisplayFormat(value as any);
                break;
        }
    }

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            compoundAction.addAction(sequence.createSetSettingsAction(settings));
        }, "Set Sequence Settings");
    });
}

/**
 * toggle linear colour for the active sequence
 * @param {boolean} [enableMaxRenderQual]
 * @returns {boolean | string}
 */
export async function toggleLinearColour(enableMaxRenderQual: boolean): Promise<boolean | string> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return "failure";

    const sequence = await getActiveSequence();
    if (!sequence) return "failure";

    const settings = await sequence.getSettings();
    if (!settings) return "failure";

    const current = await settings.getCompositeInLinearColor();
    const newValue = !current;

    await settings.setCompositeInLinearColor(newValue);

    if (newValue === true && enableMaxRenderQual === true) {
        await settings.setMaxRenderQuality(true);
    }

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            compoundAction.addAction(sequence.createSetSettingsAction(settings));
        }, "Toggle Linear Colour");
    });

    return newValue;
}

/**
 * find or create a bin
 * @returns {any}
 */
async function findOrCreateFolderPath(rootItem: any, folderPath: string, createIfMissing: boolean = true): Promise<any> {
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
                project.lockedAccess(() => {
                    project.executeTransaction((compoundAction) => {
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
 * move selected projectitems to a desired bin. the bin will be created if it doesn't exist
 * @returns {boolean}
 */
export async function moveToAssetsBin(folderPath: string): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const selection = await ppro.ProjectUtils.getSelection(project);
    if (!selection) return false;

    const items = await selection.getItems();
    if (!items || items.length === 0) return false;

    const rootItem = await project.getRootItem();
    if (!rootItem) return false;

    const targetFolder = await findOrCreateFolderPath(rootItem, folderPath, true);
    if (!targetFolder) return false;

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (let i = 0; i < items.length; i++) {
                compoundAction.addAction(targetFolder.createMoveItemAction(items[i], targetFolder));
            }
        }, "Move To Bin");
    });

    return true;
}

/**
 * organise project. expects my folder layout
 * @returns {void}
 */
export async function organiseProject(): Promise<void> {
    await setupProjBin();
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const rootItem = await project.getRootItem();
    if (!rootItem) return;
    const root = await ppro.FolderItem.cast(rootItem);

    const rootChildren = await root.getItems();

    let imageFolder: any = null;
    let videoFolder: any = null;
    let linkedCompsFolder: any = null;

    // find existing folders
    for (let i = 0; i < rootChildren.length; i++) {
        const child = rootChildren[i];
        if (child.type !== 2) continue;

        if (child.name === "_Assets") {
            const assetsFolder = await ppro.FolderItem.cast(child);
            const assetsChildren = await assetsFolder.getItems();
            for (let j = 0; j < assetsChildren.length; j++) {
                const name = assetsChildren[j].name;
                if (name === "Images" || name === "02_Images") {
                    imageFolder = await ppro.FolderItem.cast(assetsChildren[j]);
                } else if (name === "Videos" || name === "06_Videos") {
                    videoFolder = await ppro.FolderItem.cast(assetsChildren[j]);
                }
            }
        } else if (child.name === "_linked comps & renders") {
            linkedCompsFolder = await ppro.FolderItem.cast(child);
        }
    }

    // create missing folders
    const foldersToCreate: string[] = [];
    if (!imageFolder) foldersToCreate.push("02_Images");
    if (!videoFolder) foldersToCreate.push("06_Videos");
    if (!linkedCompsFolder) foldersToCreate.push("_linked comps & renders");

    if (foldersToCreate.length > 0) {
        project.lockedAccess(() => {
            project.executeTransaction((compoundAction) => {
                for (const name of foldersToCreate) {
                    compoundAction.addAction(root.createBinAction(name, false));
                }
            }, "Create Missing Folders");
        });
        await new Promise(resolve => setTimeout(resolve, 500));

        const updatedChildren = await root.getItems();
        for (let i = 0; i < updatedChildren.length; i++) {
            const name = updatedChildren[i].name;
            if (!imageFolder && name === "02_Images") imageFolder = await ppro.FolderItem.cast(updatedChildren[i]);
            if (!videoFolder && name === "06_Videos") videoFolder = await ppro.FolderItem.cast(updatedChildren[i]);
            if (!linkedCompsFolder && name === "_linked comps & renders") linkedCompsFolder = await ppro.FolderItem.cast(updatedChildren[i]);
        }
    }

    // categorise items
    const imageExts = ["jpg", "jpeg", "png", "webp", "heic", "gif"];
    const videoExts = ["mp4", "mov", "avi", "mkv"];
    const images: any[] = [];
    const videos: any[] = [];
    const linkedComps: any[] = [];

    const freshRootChildren = await root.getItems();
    for (let i = 0; i < freshRootChildren.length; i++) {
        const item = freshRootChildren[i];
        const name: string = item.name;
        const ext = name.substring(name.lastIndexOf('.') + 1).toLowerCase();

        if (
            (ext === "aep" && (name.toLowerCase().includes("linked comp"))) ||
            name.substring(name.length - 17).toLowerCase() === ".aep_rendered.mov" ||
            name.substring(0, 15).toLowerCase() === "nested sequence"
        ) {
            linkedComps.push(item);
        } else if (imageExts.includes(ext)) {
            images.push(item);
        } else if (videoExts.includes(ext)) {
            videos.push(item);
        }
    }

    // move items
    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (const item of images) compoundAction.addAction(imageFolder.createMoveItemAction(item, imageFolder));
            for (const item of videos) compoundAction.addAction(videoFolder.createMoveItemAction(item, videoFolder));
            for (const item of linkedComps) compoundAction.addAction(linkedCompsFolder.createMoveItemAction(item, linkedCompsFolder));
        }, "Organise Project");
    });
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

    const sequence = await getActiveSequence();
    if (!sequence) return;

    const selection = await sequence.getSelection();
    if (!selection) return;

    const items = await selection.getTrackItems();
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

    const paramData: { param: any, keyframe: any }[] = [];
    for (let i = 0; i < items.length; i++) {
        const chain = await items[i].getComponentChain();
        if (!chain) continue;

        const component = await chain.getComponentAtIndex(componentIndex);
        if (!component) continue;

        const param = await component.getParam(paramIndex);
        if (!param) continue;

        const keyframe = await param.createKeyframe(coercedValue);
        paramData.push({ param, keyframe });
    }

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (const { param, keyframe } of paramData) {
                try {
                    compoundAction.addAction(param.createSetValueAction(keyframe, true));
                } catch(e) {
                    console.log("error:", e);
                }
            }
        }, "Set Component Param");
    });
}

function dbToEncoded(db: number): number {
    return Math.min(Math.pow(10, (db - 15) / 20), 1.0);
}

function encodedToDb(encoded: number): number {
    return 20 * Math.log(encoded) * Math.LOG10E + 15;
}

/**
 * adjust the audio levels of all selected clips
 * @param {number} [levelInDb] the value to adjust by
 * @returns {void}
 */
export async function changeAllAudioLevels(levelInDb: number): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await getActiveSequence();
    if (!sequence) return;

    const selection = await sequence.getSelection();
    if (!selection) return;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return;

    const playerPosition = await sequence.getPlayerPosition();

    const paramData: { param: any, keyframe: any, isTimeVarying: boolean }[] = [];

    for (let i = 0; i < items.length; i++) {
        if (items[i].constructor.name !== "AudioClipTrackItem") continue;

        const chain = await items[i].getComponentChain();
        if (!chain) continue;

        const component = await chain.getComponentAtIndex(0);
        if (!component) continue;

        const param = await component.getParam(1);
        if (!param) continue;

        const isTimeVarying = await param.isTimeVarying();

        let currentValue: number;
        let keyframe: any;

        if (isTimeVarying) {
            const startTime = await items[i].getStartTime();
            const inPoint = await items[i].getInPoint();
            const clipPos = inPoint.add(playerPosition.subtract(startTime));

            const valueAtTime = await param.getValueAtTime(clipPos);
            currentValue = (valueAtTime as any).value ?? (valueAtTime as any);

            const newEncoded = dbToEncoded(encodedToDb(currentValue) + levelInDb);
            keyframe = await param.createKeyframe(newEncoded);
            keyframe.position = clipPos;
        } else {
            const startValue = await param.getStartValue();
            currentValue = (startValue.value as any).value;

            const newEncoded = dbToEncoded(encodedToDb(currentValue) + levelInDb);
            keyframe = await param.createKeyframe(newEncoded);
        }

        paramData.push({ param, keyframe, isTimeVarying });
    }

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (const { param, keyframe, isTimeVarying } of paramData) {
                try {
                    if (isTimeVarying) {
                        compoundAction.addAction(param.createAddKeyframeAction(keyframe));
                        compoundAction.addAction(param.createSetValueAction(keyframe, true));
                    } else {
                        compoundAction.addAction(param.createSetValueAction(keyframe, true));
                    }
                } catch (e) {
                    console.log("error:", e);
                }
            }
        }, "Change Audio Levels");
    });
}

/**
 * searches for a projectItem by name
 * @param {any} [bin] the bin you wish to search in
 * @param {string} [name] the name of the projectItem you wish to search for
 * @returns {any}
 */
async function searchForItemByName(bin: any, name: string): Promise<any> {
    const children = await bin.getItems();
    for (let i = 0; i < children.length; i++) {
        const child = children[i];
        if (!child) continue;

        if (child.type !== 2 && child.name === name) {
            return child;
        }

        if (child.type === 2) {
            const folder = await ppro.FolderItem.cast(child);
            const found = await searchForItemByName(folder, name);
            if (found) return found;
        }
    }
    return null;
}

/**
 * load the desired item path into the source monitor.
 * @param {string} [itemPath] itemPath can be just a filename or a full path like "_Assets/Footage/clip.mov"
 * @returns {boolean}
 */
export async function loadInSourceMonitor(itemPath: string): Promise<boolean> {
    const loadItem = await projItemByPath(itemPath);
    return await ppro.SourceMonitor.openProjectItem(loadItem);
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
 * add a marker to the current frame
 * @param {number} [colour] the index value of the desired colour
 * @returns {void}
 */
export async function setMarker(colour: string): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await getActiveSequence();
    if (!sequence) return;

    const playerPosition = await sequence.getPlayerPosition();
    const colourIndex = parseInt(colour);
    const settings = await sequence.getSettings();
    const frameRate = settings.getVideoFrameRate();
    const tolerance = 0.001;

    const selection = await sequence.getSelection();
    const items = selection ? await selection.getTrackItems() : [];

    if (!items || items.length === 0) {
        // no selection — add sequence marker at playhead
        const alignedPos = playerPosition.alignToFrame(frameRate);
        const sequenceMarkers = await ppro.Markers.getMarkers(sequence);
        if (!sequenceMarkers) return;

        project.lockedAccess(() => {
            project.executeTransaction((compoundAction) => {
                compoundAction.addAction(sequenceMarkers.createAddMarkerAction(
                    "",
                    ppro.Marker.MARKER_TYPE_COMMENT,
                    alignedPos,
                    ppro.TickTime.TIME_ZERO,
                    ""
                ));
            }, "Add Sequence Marker");
        });

        await new Promise(resolve => setTimeout(resolve, 200));
        const updatedMarkers = await ppro.Markers.getMarkers(sequence);
        const updatedList = updatedMarkers.getMarkers();
        let newMarker = null;
        for (const marker of updatedList) {
            const markerStart = marker.getStart();
            if (Math.abs(markerStart.seconds - alignedPos.seconds) <= tolerance) {
                newMarker = marker;
                break;
            }
        }
        if (newMarker) {
            project.lockedAccess(() => {
                project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(newMarker.createSetColorByIndexAction(colourIndex));
                }, "Set Sequence Marker Color");
            });
        }
        return;
    }

    const processedIds = new Set<string>();

    for (let i = 0; i < items.length; i++) {
        const projItem = await items[i].getProjectItem();
        if (!projItem) continue;

        const itemId = await projItem.getId();
        if (processedIds.has(itemId.toString())) continue;
        processedIds.add(itemId.toString());

        const clipProjItem = await ppro.ClipProjectItem.cast(projItem);
        if (!clipProjItem) continue;

        const startTime = await items[i].getStartTime();
        const inPoint = await items[i].getInPoint();
        const rawClipPos = inPoint.add(playerPosition.subtract(startTime));
        const clipPos = rawClipPos.alignToFrame(frameRate);

        const markers = await ppro.Markers.getMarkers(clipProjItem);
        if (!markers) continue;

        const existingMarkers = markers.getMarkers();
        let existingMarker = null;

        for (const marker of existingMarkers) {
            const markerStart = marker.getStart();
            if (Math.abs(markerStart.seconds - clipPos.seconds) <= tolerance) {
                existingMarker = marker;
                break;
            }
        }

        if (existingMarker) {
            project.lockedAccess(() => {
                project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(existingMarker.createSetColorByIndexAction(colourIndex));
                }, "Set Marker Color");
            });
        } else {
            project.lockedAccess(() => {
                project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(markers.createAddMarkerAction(
                        "",
                        ppro.Marker.MARKER_TYPE_COMMENT,
                        clipPos,
                        ppro.TickTime.TIME_ZERO,
                        ""
                    ));
                }, "Add Marker");
            });

            await new Promise(resolve => setTimeout(resolve, 200));
            const updatedMarkers = await ppro.Markers.getMarkers(clipProjItem);
            const updatedList = updatedMarkers.getMarkers();
            let newMarker = null;
            for (const marker of updatedList) {
                const markerStart = marker.getStart();
                if (Math.abs(markerStart.seconds - clipPos.seconds) <= tolerance) {
                    newMarker = marker;
                    break;
                }
            }
            if (newMarker) {
                project.lockedAccess(() => {
                    project.executeTransaction((compoundAction) => {
                        compoundAction.addAction(newMarker.createSetColorByIndexAction(colourIndex));
                    }, "Set Marker Color");
                });
            }
        }
    }
}

/**
 * apply effects to all selected clips
 * @param {string} [effectName] the name of the effect
 * @returns {boolean}
 */
export async function applyEffectOnAllSelectedClips(effectName: string): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const sequence = await getActiveSequence();
    if (!sequence) return false;

    const selection = await sequence.getSelection();
    if (!selection) return false;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return false;

    const videoFilterFactory = ppro.VideoFilterFactory;
    const audioFilterFactory = ppro.AudioFilterFactory;

    const clipData: { chain: any, component: any }[] = [];

    for (let i = 0; i < items.length; i++) {
        const item = items[i];
        const isVideo = item.constructor.name === "VideoClipTrackItem";

        const chain = await item.getComponentChain();
        if (!chain) continue;

        let component: any = null;

        if (isVideo) {
            const matchNames = [
                effectName,
                `AE.ADBE ${effectName}`,
                `PR.ADBE ${effectName}`,
            ];
            for (const name of matchNames) {
                try {
                    component = await videoFilterFactory.createComponent(name);
                    if (component) break;
                } catch(e) {
                    console.log(`video createComponent(${name}) failed:`, e);
                }
            }
        } else {
            try {
                component = await audioFilterFactory.createComponentByDisplayName(effectName, item);
            } catch(e) {
                console.log(`audio createComponentByDisplayName failed:`, e);
            }
            if (!component) {
                try {
                    component = await audioFilterFactory.createComponent(effectName, item);
                } catch(e) {
                    console.log(`audio createComponent failed:`, e);
                }
            }
        }

        if (!component) {
            continue;
        }

        clipData.push({ chain, component });
    }

    if (clipData.length === 0) return false;

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (const { chain, component } of clipData) {
                try {
                    compoundAction.addAction(chain.createInsertComponentAction(component, 2));
                } catch(e) {
                    console.log("transaction error:", e);
                }
            }
        }, "Apply Effect");
    });

    return true;
}

/**
 * list all effects on selected clips in the console
 * @returns {string}
 */
export async function listEffectsOnSelectedClip(): Promise<string | false> {
    const sequence = await getActiveSequence();
    if (!sequence) return false;

    const selection = await sequence.getSelection();
    if (!selection) return false;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) {
        return false;
    }

    const item = items[0];
    const chain = await item.getComponentChain();
    if (!chain) return false;

    const componentCount = await chain.getComponentCount();
    let effectsList = "Effects on clip:\n";

    for (let i = 0; i < componentCount; i++) {
        const component = await chain.getComponentAtIndex(i);
        const displayName = await component.getDisplayName();
        const matchName = await component.getMatchName();
        effectsList += `${i}: ${displayName} (matchName: ${matchName})\n`;
    }

    console.log(effectsList);
    return effectsList
}

/**
 * return all available effects. when returned as a string will be split between effects with `|` and between video/audio with `||`. replace all `||` and `|` with newlines for easy splitting
 * @returns {string}
 */
export async function listAllAvailableEffects(): Promise<string> {
    const videoFilterFactory = ppro.VideoFilterFactory;
    const audioFilterFactory = ppro.AudioFilterFactory;

    const vidMatchNames = await videoFilterFactory.getMatchNames();
    const audMatchNames = await audioFilterFactory.getDisplayNames();
    console.log("all video match names:", vidMatchNames);
    console.log("all audio match names:", audMatchNames);
    return "VIDEO:||" + vidMatchNames.join("|") + "||AUDIO:||" + audMatchNames.join("|");
}

const SKIPPED_MATCH_NAMES: { [key: string]: boolean } = {
    "AE.ADBE Motion": true,
    "AE.ADBE Opacity": true,
    "AE.ADBE Anchor Point": true,
    "Internal Volume Stereo": true,
    "Internal Channel Volume Stereo": true,
    "Internal Volume Mono": true,
};

interface PropertyEntry {
    displayName: string;
    isTimeVarying: boolean;
    value?: any;
    keyframes?: { time: string; value: any }[];
}

interface EffectEntry {
    matchName: string;
    displayName?: string;
    properties: PropertyEntry[];
}

/**
 * saves all effects on a selected clip (minus defaults) to a json string and returns it
 * @returns {string}
 */
export async function saveEffectSlotJSON(): Promise<string> {
    try {
        const sequence = await getActiveSequence();
        if (!sequence) return "ERROR: no active sequence";

        const selection = await sequence.getSelection();
        if (!selection) return "ERROR: no selection";

        const items = await selection.getTrackItems();
        if (!items || items.length === 0) return "ERROR: no clip selected";

        const payload: { mediaType: string, effects: EffectEntry[] }[] = [];

        for (let i = 0; i < items.length; i++) {
            const item = items[i];
            const mediaType = item.constructor.name === "VideoClipTrackItem" ? "Video" : "Audio";

            const chain = await item.getComponentChain();
            if (!chain) continue;

            const componentCount = await chain.getComponentCount();
            const effects: EffectEntry[] = [];

            for (let c = 0; c < componentCount; c++) {
                const component = await chain.getComponentAtIndex(c);
                const matchName = await component.getMatchName();
                if (SKIPPED_MATCH_NAMES[matchName]) continue;

                const displayName = await component.getDisplayName();
                const paramCount = await component.getParamCount();
                const properties: PropertyEntry[] = [];

                for (let j = 0; j < paramCount; j++) {
                    const param = await component.getParam(j);
                    const paramDisplayName = param.displayName;
                    const isTimeVarying = await param.isTimeVarying();

                    const entry: PropertyEntry = { displayName: paramDisplayName, isTimeVarying };

                    if (isTimeVarying) {
                        const tickTimes = await param.getKeyframeListAsTickTimes();
                        entry.keyframes = [];
                        for (const tickTime of tickTimes) {
                            const kfValue = await param.getValueAtTime(tickTime);
                            entry.keyframes.push({
                                time: tickTime.ticks,
                                value: (kfValue as any)?.value ?? kfValue,
                            });
                        }
                    } else {
                        const startValue = await param.getStartValue();
                        entry.value = (startValue?.value as any)?.value ?? startValue;
                    }

                    properties.push(entry);
                }

                effects.push({ matchName, displayName, properties });
            }

            payload.push({ mediaType, effects });
        }

        return JSON.stringify(payload);
    } catch (e: any) {
        return "ERROR in saveEffectSlotJSON: " + e.toString();
    }
}

/**
 * applies effects from a base64 encoded json string
 * @param {string} [data] a base64 encoded string containing json data for what effects to apply
 * @returns {string}
 */
export async function applyEffectSlotJSON(data: string): Promise<string> {
    let payload: { mediaType: string, effects: EffectEntry[] }[];
    try {
        const jsonStr = atob(data).replace(/\\"/g, '"');
        payload = JSON.parse(jsonStr);
    } catch (e: any) {
        return "ERROR at decode/parse: " + e.toString();
    }

    const project = await ppro.Project.getActiveProject();
    if (!project) return "ERROR: no active project";

    const sequence = await getActiveSequence();
    if (!sequence) return "ERROR: no active sequence";

    const selection = await sequence.getSelection();
    if (!selection) return "ERROR: no selection";

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return "ERROR: no clip selected";

    const allResults: string[] = [];

    for (let i = 0; i < items.length; i++) {
        const item = items[i];
        const mediaType = item.constructor.name === "VideoClipTrackItem" ? "Video" : "Audio";
        const isVideo = mediaType === "Video";

        // find matching bucket
        const bucket = payload.find(b => b.mediaType === mediaType);
        if (!bucket) {
            allResults.push(`[${mediaType}]: SKIPPED (no saved effects for this media type)`);
            continue;
        }

        const chain = await item.getComponentChain();
        if (!chain) {
            allResults.push(`[${mediaType}]: ERROR no component chain`);
            continue;
        }

        for (const fx of bucket.effects) {
            if (SKIPPED_MATCH_NAMES[fx.matchName]) {
                allResults.push(`[${mediaType}] ${fx.matchName}: SKIPPED`);
                continue;
            }

            try {
                let component: any = null;
                if (isVideo) {
                    try {
                        component = await ppro.VideoFilterFactory.createComponent(fx.matchName);
                    } catch {
                        allResults.push(`[${mediaType}] ${fx.matchName}: FAILED (video effect not found)`);
                        continue;
                    }
                } else {
                    try {
                        component = await ppro.AudioFilterFactory.createComponentByDisplayName(fx.displayName ?? fx.matchName, item);
                    } catch {
                        try {
                            component = await ppro.AudioFilterFactory.createComponent(fx.matchName, item);
                        } catch {
                            allResults.push(`[${mediaType}] ${fx.matchName}: FAILED (audio effect not found)`);
                            continue;
                        }
                    }
                }

                if (!component) {
                    allResults.push(`[${mediaType}] ${fx.matchName}: FAILED (component is null)`);
                    continue;
                }

                project.lockedAccess(() => {
                    project.executeTransaction((compoundAction) => {
                        compoundAction.addAction(chain.createInsertComponentAction(component, 2));
                    }, "Insert Effect");
                });

                await new Promise(resolve => setTimeout(resolve, 200));

                const newChain = await item.getComponentChain();
                const newCount = await newChain.getComponentCount();
                let newComponent: any = null;
                for (let c = newCount - 1; c >= 0; c--) {
                    const comp = await newChain.getComponentAtIndex(c);
                    const mn = await comp.getMatchName();
                    if (mn === fx.matchName) {
                        newComponent = comp;
                        break;
                    }
                }

                if (!newComponent) {
                    allResults.push(`[${mediaType}] ${fx.matchName}: FAILED (could not find inserted component)`);
                    continue;
                }

                const paramCount = await newComponent.getParamCount();
                const paramData: { param: any, keyframes?: { keyframe: any }[], staticKeyframe?: any }[] = [];

                for (let j = 0; j < fx.properties.length && j < paramCount; j++) {
                    const savedProp = fx.properties[j];
                    const param = await newComponent.getParam(j);

                    if (savedProp.isTimeVarying && savedProp.keyframes) {
                        const keyframes: { keyframe: any }[] = [];
                        for (const kf of savedProp.keyframes) {
                            const tickTime = ppro.TickTime.createWithTicks(String(kf.time));
                            const keyframe = await param.createKeyframe(kf.value);
                            keyframe.position = tickTime;
                            keyframes.push({ keyframe });
                        }
                        paramData.push({ param, keyframes });
                    } else if (savedProp.value !== undefined) {
                        try {
                            const coerced = typeof savedProp.value === "boolean"
                                ? savedProp.value
                                : typeof savedProp.value === "string" && !isNaN(Number(savedProp.value))
                                    ? Number(savedProp.value)
                                    : savedProp.value;
                            const keyframe = await param.createKeyframe(coerced);
                            paramData.push({ param, staticKeyframe: keyframe });
                        } catch { }
                    }
                }

                project.lockedAccess(() => {
                    project.executeTransaction((compoundAction) => {
                        for (const pd of paramData) {
                            try {
                                if (pd.keyframes) {
                                    compoundAction.addAction(pd.param.createSetTimeVaryingAction(true));
                                    for (const { keyframe } of pd.keyframes) {
                                        compoundAction.addAction(pd.param.createAddKeyframeAction(keyframe));
                                        compoundAction.addAction(pd.param.createSetValueAction(keyframe, false));
                                    }
                                } else if (pd.staticKeyframe) {
                                    compoundAction.addAction(pd.param.createSetTimeVaryingAction(false));
                                    compoundAction.addAction(pd.param.createSetValueAction(pd.staticKeyframe, false));
                                }
                            } catch { }
                        }
                    }, "Restore Effect Params");
                });

                allResults.push(`[${mediaType}] ${fx.matchName}: OK`);
            } catch (e: any) {
                allResults.push(`[${mediaType}] ${fx.matchName}: FAILED -- ${e.toString()}`);
            }
        }
    }

    return "DONE:\n" + allResults.join("\n");
}