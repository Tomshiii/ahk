/**
 * @fileoverview Tomshi functions
 * @version 1.0.2
 */
const lfs = storage.localFileSystem;

import { storage } from 'uxp';
import * as common from "./common";
import * as prop from "./properties";
import * as helpers from "./helperfuncs";

import type {
    premierepro,
    Sequence,
    TickTime,
    VideoTrack,
    TrackItemSelection,
    ProjectItem,
    Project,
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
    const active = await common.getActiveSequence();
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
    // if (!openSequences.has(ID)) return false;

    const project = await ppro.Project.getActiveProject();
    if (!project) return false;
    const origSeq = await project.getActiveSequence();
    const origGUID = await ppro.Guid.toString(origSeq.guid)
    const origSelection = await origSeq.getSelection();
    const guid = await ppro.Guid.fromString(ID);
    if (!guid) return false;

    const sequences = await project.getSequences();
    if (!sequences || sequences.length === 0) return false;

    let sequence = null;
    for (let i = 0; i < sequences.length; i++) {
        var seqGUID = String(sequences[i].guid);
        if (String(seqGUID) == ID) {
            sequence = true;
            break;
        }
    }
    if (!sequence) return false;

    const selectedSequence = await project.getSequence(guid);
    if (!selectedSequence) return false;

    await project.setActiveSequence(selectedSequence);
    const newSeq = await project.getActiveSequence();
    const newGUID = await ppro.Guid.toString(newSeq.guid)
    if (String(origGUID) == String(newGUID)) {
        await origSeq.clearSelection();
        await newSeq.clearSelection();
        newSeq.setSelection(origSelection);
    }
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
    const seq = await common.getActiveSequence();
    if (!seq) return;
    return activeProj.closeSequence(seq);
}

/**
 * Moves the playhead
 * @param {boolean} [subtract] whether to add or subtract the desired time to the current playhead position
 * @param {number} [seconds] the amount of seconds you wish to move the playhead. will be automatically converted to the current timebase
 * @returns {void}
 */
export async function movePlayhead(subtract: boolean, seconds: number): Promise<void> {
    const sequence = await common.getActiveSequence();
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
    const sequence = await common.getActiveSequence();
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
    const sequence = await common.getActiveSequence();
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
    const sequence = await common.getActiveSequence();
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
    const items = await common.getSelectedTrackItems();
    if (!items || items.length === 0) return false;
    return true;
}

/**
 * determine if there is a selection of multiple clips
 * @returns {boolean}
 */
export async function isSelectedMultiple(): Promise<boolean> {
    const items = await common.getSelectedTrackItems();
    if (!items || items.length <= 1) return false;

    return true;
}

/**
 * determine if there is a selection. if there is, return it
 * @returns {TrackItemSelection}
 */
export async function isSelectedReturn(): Promise<TrackItemSelection | false> {
    const items = await common.getSelectedTrackItems();
    if (!items || items.length === 0) return false;
    return items;
}

/**
 * determine if the first selected clip is enabled
 * @returns {boolean}
 */
export async function isClipEnabled(): Promise<boolean> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return false;

    const items = await isSelectedReturn();
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

    const items = await common.getSelectedTrackItems();
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
    const sequence = await common.getActiveSequence();
    if (!sequence) return null;

    return String(await sequence.getAudioTrackCount());
}

/**
 * return the audio track count
 * @returns {String | null}
 */
export async function getVideoTracks(): Promise<string | null> {
    const sequence = await common.getActiveSequence();
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
    const sequences = await findSequenceByProjectItemId(project, selectedId);
    if (!sequences) return false;

    return true;
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

    const sequences = await findSequenceByProjectItemId(project, selectedId);
    if (!sequences) return false;

    return true;
}

/**
 * returns the current project selection and ensures the selected item is a sequence
 * @returns {Sequence | false}
 */
export async function getSelectedProjectItemSequence() {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const selection = await getProjectSelection();
    if (!selection) return false;

    const selectedId = await selection[0].getId();

    const sequence = await findSequenceByProjectItemId(project, selectedId)
    if (!sequence) return false;
    return sequence;
}

/**
 * Export selected project item using premiere's renderer
 * @param {string} [outputPath] the folder path you want the file to be exported to
 * @param {string} [presetPath] the path of the preset you wish to use to render the file (note: h265 presets will not work)
 * @returns {string | false}
 */
export async function renderInPrem(outputPath: string, presetPath: string): Promise<string | false> {
    const sequence = await getSelectedProjectItemSequence();
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
        const entries = fs.readdirSync(dir);
        return entries.includes(fileName);
    } catch (e) {
        console.log("fileExists error:", e);
        return false;
    }
}

/**
 * import file into project
 * @param {string} [filePath] a filepath to the file to import. `/` must be `//`; eg. `W://work//352. boys lore video (Main Channel)//timeline renders//Nested Sequence 57_3.mov`
 * @param {string} [importPath] a path representation of which bin to import the file into. if left blank, will default to the root
 * @param {boolean} [importAsStills]
 * @returns {boolean}
 */
export async function importFile(filePath: string, importPath: string, importAsStills: boolean): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;
    const rootBin = await project.getRootItem();
    if (!rootBin) return false;

    let targetFolder = rootBin;
    if (importPath) {
        const folder = await findOrCreateFolderPath(rootBin, importPath, true);
        if (folder) targetFolder = folder;
    }

    return project.importFiles([filePath], false, targetFolder, importAsStills);
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

    const items = await common.getSelectedTrackItems();
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

    const items = await common.getSelectedTrackItems();
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
    const sequence = await common.getActiveSequence();
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
    const sequence = await common.getActiveSequence();
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

    const sequence = await common.getActiveSequence();
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

    const sequence = await common.getActiveSequence();
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
 * Recursively find the folder path (as a string) containing the item with the given nodeId.
 * @returns "" if the item lives directly under rootItem, or null if not found at all.
 */
export async function findItemBinPath(bin: any, targetId: string, currentPath: string): Promise<string | null> {
    const folder = await ppro.FolderItem.cast(bin);
    const children = await folder.getItems();

    for (let i = 0; i < children.length; i++) {
        const child = children[i];
        if (!child) continue;

        const childId = await child.getId();

        if (child.type !== 2 && childId.toString() === targetId.toString()) {
            return currentPath;
        }

        if (child.type === 2) {
            const nextPath = currentPath ? `${currentPath}/${child.name}` : child.name;
            const found = await findItemBinPath(child, targetId, nextPath);
            if (found !== null) return found;
        }
    }
    return null;
}

/**
 * returns the bin path of a selected sequence
 */
export async function getSelectionBinPath(): Promise<false | string> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;
    const selection = await getProjectSelection();
    if (!selection) return false;
    const selectedItem = selection[0];

    // optional: confirm it's actually a sequence
    const isSequence = await getSelectedProjectItemSequence();
    if (!isSequence) return false;

    const selectedId = await selectedItem.getId();

    const rootItem = await project.getRootItem();
    const path = await findItemBinPath(rootItem, selectedId, "");
    return path !== null ? path : "";
}

/**
 * move selected projectitems to a desired bin. the bin will be created if it doesn't exist
 * @returns {boolean}
 */
export async function moveToAssetsBin(folderPath: string): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const selection = await getProjectSelection();
    if (!selection) return false;

    const rootItem = await project.getRootItem();
    if (!rootItem) return false;

    const targetFolder = await findOrCreateFolderPath(rootItem, folderPath, true);
    if (!targetFolder) return false;

    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            for (let i = 0; i < selection.length; i++) {
                compoundAction.addAction(targetFolder.createMoveItemAction(selection[i], targetFolder));
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
                } catch (e) {
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

    const sequence = await common.getActiveSequence();
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
 * @param {string} [colour] the index value of the desired colour
 * @returns {void}
 */
export async function setMarker(colour: string): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await common.getActiveSequence();
    if (!sequence) return;

    const playerPosition = await sequence.getPlayerPosition();
    const colourIndex = parseInt(colour);
    const settings = await sequence.getSettings();
    const frameRate = settings.getVideoFrameRate();

    const selection = await sequence.getSelection();
    const items = selection ? await selection.getTrackItems() : [];

    if (!items || items.length === 0) {
        const alignedPos = playerPosition.alignToFrame(frameRate);
        const sequenceMarkers = await ppro.Markers.getMarkers(sequence);
        if (!sequenceMarkers) return;

        const existingList = sequenceMarkers.getMarkers();
        const match = findMarkerAtFrame(existingList, alignedPos, frameRate);

        if (match) {
            project.lockedAccess(() => {
                project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(match.createSetColorByIndexAction(colourIndex));
                }, "Set Sequence Marker Color");
            });
            return;
        }

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
        const newMarker = findMarkerAtFrame(updatedList, alignedPos, frameRate);
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

        // check if this project item is actually a sequence (multicam)
        let markerOwner: any = clipProjItem;

        const isMulticam = clipProjItem.isMulticamClip();
        const isSeq = clipProjItem.isSequence();

        if (isMulticam || isSeq) {
            const seq = await clipProjItem.getSequence();
            if (seq) markerOwner = seq;
        }

        const startTime = await items[i].getStartTime();
        const inPoint = await items[i].getInPoint();
        const rawClipPos = inPoint.add(playerPosition.subtract(startTime));
        const clipPos = rawClipPos.alignToFrame(frameRate);

        const markers = await ppro.Markers.getMarkers(markerOwner);
        if (!markers) continue;

        const existingMarkers = markers.getMarkers();
        const existingMarker = findMarkerAtFrame(existingMarkers, clipPos, frameRate);

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
            const updatedMarkers = await ppro.Markers.getMarkers(markerOwner);
            const updatedList = updatedMarkers.getMarkers();
            const newMarker = findMarkerAtFrame(updatedList, clipPos, frameRate);
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
 * remove marker closest to the playhead (the playhead can park inbetween frames)
 */
export async function removeMarkerAtPlayhead(): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await common.getActiveSequence();
    if (!sequence) return;

    const playerPosition = await sequence.getPlayerPosition();
    const settings = await sequence.getSettings();
    const frameRate = settings.getVideoFrameRate();
    const alignedPos = playerPosition.alignToFrame(frameRate);

    const selection = await sequence.getSelection();
    const items = selection ? await selection.getTrackItems() : [];

    if (!items || items.length === 0) {
        // remove sequence marker
        const sequenceMarkers = await ppro.Markers.getMarkers(sequence);
        if (!sequenceMarkers) return;

        const existingList = sequenceMarkers.getMarkers();
        const match = findMarkerAtFrame(existingList, alignedPos, frameRate);

        if (match) {
            project.lockedAccess(() => {
                project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(sequenceMarkers.createRemoveMarkerAction(match));
                }, "Remove Sequence Marker");
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

        let markerOwner: any = clipProjItem;
        const isMulticam = clipProjItem.isMulticamClip();
        const isSeq = clipProjItem.isSequence();
        if (isMulticam || isSeq) {
            const seq = await clipProjItem.getSequence();
            if (seq) markerOwner = seq;
        }

        const startTime = await items[i].getStartTime();
        const inPoint = await items[i].getInPoint();
        const rawClipPos = inPoint.add(playerPosition.subtract(startTime));
        const clipPos = rawClipPos.alignToFrame(frameRate);

        const markers = await ppro.Markers.getMarkers(markerOwner);
        if (!markers) continue;

        const existingMarkers = markers.getMarkers();
        const match = findMarkerAtFrame(existingMarkers, clipPos, frameRate);

        if (match) {
            project.lockedAccess(() => {
                project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(markers.createRemoveMarkerAction(match));
                }, "Remove Marker");
            });
        }
    }
}

/**
 * Finds a marker that starts on the exact same frame as targetTime.
 * Both the marker's start time and targetTime are aligned to the frame
 * grid before comparing, so this checks "same frame" rather than
 * "close enough" — no tolerance constant needed.
 */
function findMarkerAtFrame(
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
 * apply effects to all selected clips
 * @param {string} [effectName] the name of the effect
 * @returns {boolean}
 */
export async function applyEffectOnAllSelectedClips(effectName: string): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const items = await common.getSelectedTrackItems();
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
                } catch (e) {
                    console.log(`video createComponent(${name}) failed:`, e);
                }
            }
        } else {
            try {
                component = await audioFilterFactory.createComponentByDisplayName(effectName, item);
            } catch (e) {
                console.log(`audio createComponentByDisplayName failed:`, e);
            }
            if (!component) {
                try {
                    component = await audioFilterFactory.createComponent(effectName, item);
                } catch (e) {
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
                } catch (e) {
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
    const items = await common.getSelectedTrackItems();
    if (!items || items.length === 0) return false;

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
        const sequence = await common.getActiveSequence();
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
 * parses already-decoded text (plain JSON or plain prfpset XML) into buckets
 */
function parsePayloadText(text: string): { mediaType: string, effects: EffectEntry[] }[] | false {
    try {
        const trimmed = text.trim();
        if (trimmed.startsWith("<?xml") || trimmed.startsWith("<PremiereData")) {
            return helpers.prfpsetXmlToBuckets(text);
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
        const exists = await fileExists(filePathOrData);

        if (exists) {
            const url = "file:///" + filePathOrData.replace(/\\/g, "/");
            console.log("resolved url:", url);

            const entry = await lfs.getEntryWithUrl(url);
            console.log("entry:", entry);

            const text = await entry.read({ format: storage.formats.utf8 });
            console.log("read length:", text?.length, "starts with:", text?.slice(0, 30));

            const parsed = parsePayloadText(text);
            console.log("parsed:", parsed);
            return parsed;
        }

        const decoded = atob(filePathOrData);
        return parsePayloadText(decoded);
    } catch (e: any) {
        console.log("readAndDecodeText error:", e);
        return false;
    }
}

/**
 * applies effects from file (custom JSON file or a .prpreset file)
 * @param {string} [data] either the filepath to a file generated using data from `saveEffectSlotJSON()`, a base64 encoded version of data generated by `saveEffectSlotJSON()`, or the filepath to a `.prfpset` file
 * @returns {string}
 */
export async function applyEffectSlotJSON(data: string): Promise<string> {
    let payload: { mediaType: string, effects: EffectEntry[] }[] | false;
    try {
        payload = await readAndDecodeText(data);
    } catch (e: any) {
        return "ERROR at decode/parse: " + e.toString();
    }

    if (!payload) return "ERROR: could not read/parse preset data";

    const project = await ppro.Project.getActiveProject();
    if (!project) return "ERROR: no active project";

    const sequence = await common.getActiveSequence();
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
                        const hasAnchors = fx.anchorInPoint !== undefined && fx.anchorOutPoint !== undefined;

                        if (hasAnchors) {
                            // PRESET PATH: scale keyframe timing to fit the target clip's duration
                            const anchorIn = BigInt(fx.anchorInPoint);
                            const anchorOut = BigInt(fx.anchorOutPoint);
                            const originalSpan = anchorOut - anchorIn;

                            const clipDuration = await item.getDuration();
                            const clipDurationTicks = BigInt(clipDuration.ticks);

                            for (const kf of savedProp.keyframes) {
                                const relativeOffset = BigInt(kf.time) - anchorIn;
                                const scaledOffset = originalSpan > 0n
                                    ? (relativeOffset * clipDurationTicks) / originalSpan
                                    : relativeOffset;

                                const tickTime = ppro.TickTime.createWithTicks(scaledOffset.toString());
                                const keyframe = await param.createKeyframe(kf.value);
                                keyframe.position = tickTime;
                                keyframes.push({ keyframe });
                            }
                        } else {
                            // PLAIN JSON PATH: original behavior, use kf.time as-is (already clip-relative)
                            for (const kf of savedProp.keyframes) {
                                const tickTime = ppro.TickTime.createWithTicks(String(kf.time));
                                const keyframe = await param.createKeyframe(kf.value);
                                keyframe.position = tickTime;
                                keyframes.push({ keyframe });
                            }
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
                    const result = project.executeTransaction((compoundAction) => {
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
                            } catch (e: any) { }
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

/**
 * adds adjustment layer above selected clips
 * @param {string} [adjustmentLayerPath] the bin path to the adjustment layer you wish to add above the selected clips
 * @param {boolean} [makeSelection] whether you wish for the newly added adjustment layer to become the selected clip
 * @returns {void}
 */
export async function addMatchedAdjustmentLayer(adjustmentLayerPath: string, makeSelection: boolean): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) {
        alert("No active project.");
        return;
    }

    const sequence = await project.getActiveSequence();
    if (!sequence) {
        alert("No active sequence.");
        return;
    }

    const rawProjItem = await projItemByPath(adjustmentLayerPath);
    if (!rawProjItem) {
        alert('Could not find adjustment layer at path: "' + adjustmentLayerPath + '"');
        return;
    }
    const clipProjItem = await ppro.ClipProjectItem.cast(rawProjItem);

    const editor = await ppro.SequenceEditor.getEditor(sequence);

    // --- Gather selected clips per video track ---
    // Looping tracks and checking getIsSelected() per clip avoids having to
    // distinguish video vs audio items coming back from sequence.getSelection(),
    // since that returns a mixed VideoClipTrackItem | AudioClipTrackItem array.
    const videoTrackCount = await sequence.getVideoTrackCount();
    const selectedEntries: Array<{ trackIndex: number; start: TickTime; end: TickTime }> = [];

    for (let t = 0; t < videoTrackCount; t++) {
        const track = await sequence.getVideoTrack(t);
        const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);
        for (const item of items) {
            if (await item.getIsSelected()) {
                const start = await item.getStartTime();
                const end = await item.getEndTime();
                selectedEntries.push({ trackIndex: t, start, end });
            }
        }
    }

    if (selectedEntries.length === 0) {
        alert("No video clips are selected in the timeline.");
        return;
    }

    // --- Compute overall time range + the highest (topmost) selected track ---
    // Comparisons/arithmetic use TickTime's own ticksNumber/subtract rather than
    // .seconds, since .seconds is a lossy float for non-integer frame rates
    // (29.97, 23.976, 59.94, etc.) -- round-tripping through it here was the cause
    // of the occasional 1-frame-short result.
    let overallStart: TickTime | null = null;
    let overallEnd: TickTime | null = null;
    let highestTrackIndex = -1;

    for (const entry of selectedEntries) {
        if (!overallStart || entry.start.ticksNumber < overallStart.ticksNumber) overallStart = entry.start;
        if (!overallEnd || entry.end.ticksNumber > overallEnd.ticksNumber) overallEnd = entry.end;
        if (entry.trackIndex > highestTrackIndex) highestTrackIndex = entry.trackIndex;
    }

    const durationTime = overallEnd.subtract(overallStart);
    if (durationTime.seconds <= 0) {
        alert("Invalid selection duration.");
        return;
    }

    // --- Find first video track above the highest selected clip with enough free space ---
    let targetTrackIndex = -1;

    for (let t = highestTrackIndex + 1; t < videoTrackCount; t++) {
        const candidateTrack = await sequence.getVideoTrack(t);
        const items = candidateTrack.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);

        let free = true;
        for (const item of items) {
            const start = await item.getStartTime();
            const end = await item.getEndTime();
            if (start.ticksNumber < overallEnd.ticksNumber && end.ticksNumber > overallStart.ticksNumber) {
                free = false;
                break;
            }
        }

        if (free) {
            targetTrackIndex = t;
            break;
        }
    }

    // No free existing track: target one index past the last existing track.
    const needsNewTrack = targetTrackIndex === -1;
    if (needsNewTrack) {
        targetTrackIndex = videoTrackCount;
    }

    // --- Read the adjustment layer's original in/out points, to restore afterward ---
    const originalInPoint = await clipProjItem.getInPoint(ppro.Constants.MediaType.VIDEO);
    const originalOutPoint = await clipProjItem.getOutPoint(ppro.Constants.MediaType.VIDEO);
    const invalidTime = ppro.TickTime.TIME_INVALID;
    const hadOriginalInOut = !originalInPoint.equals(invalidTime) && !originalOutPoint.equals(invalidTime);

    const zeroTime = ppro.TickTime.TIME_ZERO;
    const startTime = overallStart; // the exact TickTime Premiere gave us for the earliest selected clip's start
    const audioTrackIndex = 0;

    // --- Step 1: commit the temporary in/out points as their own transaction,
    // BEFORE the placement action is even created. The insert/overwrite action
    // appears to capture the project item's duration at the moment it's created,
    // not when the transaction actually executes -- so bundling this into the same
    // transaction as the placement doesn't work. Committing it first guarantees the
    // placed clip can never be longer than the free space already verified above,
    // so it can't overwrite anything adjacent on the target track. ---
    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            const setTempInOutAction = clipProjItem.createSetInOutPointsAction(zeroTime, durationTime);
            compoundAction.addAction(setTempInOutAction);
        }, "Set temporary adjustment layer duration");
    });

    // --- Step 2: place it, now that the project item's own duration already
    // matches exactly what we need. ---
    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            const placeAction = needsNewTrack
                ? editor.createInsertProjectItemAction(rawProjItem, startTime, targetTrackIndex, audioTrackIndex, false)
                : editor.createOverwriteItemAction(rawProjItem, startTime, targetTrackIndex, audioTrackIndex);
            compoundAction.addAction(placeAction);
        }, "Add matched adjustment layer");
    });

    // --- Step 3: restore the project item's original in/out points so manually
    // dragging it in from the bin afterward isn't affected. ---
    project.lockedAccess(() => {
        project.executeTransaction((compoundAction) => {
            const restoreInOutAction = hadOriginalInOut
                ? clipProjItem.createSetInOutPointsAction(originalInPoint, originalOutPoint)
                : clipProjItem.createClearInOutPointsAction();
            compoundAction.addAction(restoreInOutAction);
        }, "Restore adjustment layer duration");
    });

    if (makeSelection) {
        const targetTrack = await sequence.getVideoTrack(targetTrackIndex);
        const trackItemsAfterPlace = targetTrack.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);

        let placedClip = null;
        for (const item of trackItemsAfterPlace) {
            const start = await item.getStartTime();
            if (start.ticksNumber === overallStart.ticksNumber) {
                placedClip = item;
                break;
            }
        }

        if (placedClip) {
            ppro.TrackItemSelection.createEmptySelection((selection) => {
                selection.addItem(placedClip);
                sequence.setSelection(selection);
            });
        }
    }
}

/**
 *
 */
async function findSequenceByProjectItemId(project: Project, targetId: string): Promise<Sequence | null> {
    const sequences = await project.getSequences();
    if (!sequences || sequences.length === 0) return null;
    for (const seq of sequences) {
        const seqProjItem = await seq.getProjectItem();
        if ((await seqProjItem.getId()).toString() === targetId.toString()) return seq;
    }
    return null;
}