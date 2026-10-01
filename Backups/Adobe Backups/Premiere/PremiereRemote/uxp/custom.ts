/**
 * @fileoverview Tomshi functions
 * @aiDisclosure I'm not incredibly versed in typescript - I could mostly follow along with CEP logic but a lot of the coding patterns in UXP go relatively over my head (namely transactions, promise's, async vs sync, etc). As such I tend to use Claude to write/convert functions. Always happy to receive any pull requests to replace ai code with stronger code.
 */

import * as common from "./common";
import * as prop from "./properties";
import * as helpers from "./helperfuncs";
import type { EffectEntry, PropertyEntry } from "./helperfuncs";

import type {
    premierepro,
    Sequence,
    TickTime,
    VideoTrack,
    TrackItemSelection,
    AudioClipTrackItem,
    VideoClipTrackItem,
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
 * @version 26.3.0
 */
export async function focusSequence(ID: string): Promise<boolean | string> {
    if (!(await helpers.isPremVerAtLeast("26.3.0")))
        return "null_version_26.3"
    // if (!openSequences.has(ID)) return false;

    const project = await ppro.Project.getActiveProject();
    if (!project) return false;
    const origSeq = await project.getActiveSequence();
    const origGUID = await ppro.Guid.toString(origSeq.guid)
    const origSelection = await origSeq.getSelection();

    // Extract the actual items now, before any clearSelection() call empties out origSelection along with the sequence's live selection state.
    const origItems = await origSelection.getTrackItems();
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

        let ok = false;
        await ppro.TrackItemSelection.createEmptySelection((newSelection) => {
            for (const item of origItems) {
                newSelection.addItem(item, true);
            }
            ok = origSeq.setSelection(newSelection);
        });
        return ok;
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
 * Moves the playhead by a number of seconds, snapped to the frame grid.
 * @param {Integer} seconds Positive moves forward, negative moves backward.
 */
export async function movePlayhead(seconds: number): Promise<void> {
    if (!Number.isFinite(seconds) || seconds === 0) return;
    const sequence = await common.getActiveSequence();
    if (!sequence) return;

    const [settings, currentPos] = await Promise.all([
        sequence.getSettings(),
        sequence.getPlayerPosition(),
    ]);
    const frameRate = settings.getVideoFrameRate();
    const offset = ppro.TickTime.createWithSeconds(Math.abs(seconds));

    let newTime = seconds < 0
        ? currentPos.subtract(offset)
        : currentPos.add(offset);

    if (newTime.ticksNumber < 0) {
        newTime = ppro.TickTime.createWithSeconds(0);
    }

    await sequence.setPlayerPosition(newTime.alignToNearestFrame(frameRate));
}

/**
 * Moves the playhead by a number of frames, snapped to the frame grid.
 * @param {Integer} frames Positive moves forward, negative moves backward.
 */
export async function movePlayheadFrames(frames: number): Promise<void> {
    if (!Number.isInteger(frames) || frames === 0) return;

    const sequence = await common.getActiveSequence();
    if (!sequence) return;

    const [settings, currentPos] = await Promise.all([
        sequence.getSettings(),
        sequence.getPlayerPosition(),
    ]);

    const frameRate = settings.getVideoFrameRate();
    const offset = ppro.TickTime.createWithFrameAndFrameRate(Math.abs(frames), frameRate);
    const base = currentPos.alignToNearestFrame(frameRate);
    let newTime = frames < 0 ? base.subtract(offset) : base.add(offset);
    if (newTime.ticksNumber < 0) {
        newTime = ppro.TickTime.createWithSeconds(0);
    }

    await sequence.setPlayerPosition(newTime);
}

/**
 * returns the current playhead position in ticks
 * @returns {string | false}
 */
export async function getPlayheadPosTicks(): Promise<string | false> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return false;

    const currentPos = await sequence.getPlayerPosition();
    return currentPos.ticks;
}

/**
 * sets the playhead position
 * @param {string} [ticks] the position in ticks to set the playhead
 * @returns {boolean}
 */
export async function setPlayheadPosTicks(ticks: string): Promise<boolean> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return false;

    return await sequence.setPlayerPosition(ppro.TickTime.createWithTicks(ticks));
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

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
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
 * determine if there is a single selection
 * @returns {boolean}
 */
export async function isSelectedSingle(): Promise<boolean> {
    const items = await common.getSelectedTrackItems();
    if (items.length !== 1) return false;
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
 * determines if any of the selected clips are audio files
 */
export async function isSelectedAudio(): Promise<boolean> {
    const items = await common.getSelectedTrackItems();
    if (!items || items.length === 0) return false;

    return items.some((item) => item instanceof ppro.AudioClipTrackItem);
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
    const [project, items] = await Promise.all([
        ppro.Project.getActiveProject(),
        common.getSelectedTrackItems(),
    ]);
    if (!project) return;
    if (!items || items.length === 0) return;

    const states = await Promise.all(items.map((item) => item.isDisabled()));

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
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
    const sequences = await helpers.findSequenceByProjectItemId(project, selectedId);
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

    const sequences = await helpers.findSequenceByProjectItemId(project, selectedId);
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

    const sequence = await helpers.findSequenceByProjectItemId(project, selectedId)
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

    const [rawExtension, encoder] = await Promise.all([
        ppro.EncoderManager.getExportFileExtension(sequence, presetPath),
        ppro.EncoderManager.getManager(),
    ]);
    if (!rawExtension) return false;
    const extension = rawExtension.startsWith(".") ? rawExtension : "." + rawExtension;

    const baseName = sequence.name;
    let finalPath = outputPath + "\\" + baseName;
    let counter = 1;

    while (await helpers.fileExists(finalPath + extension)) {
        console.log("file exists, incrementing:", finalPath + extension);
        finalPath = outputPath + "\\" + baseName + "_" + counter;
        counter++;
    }
    console.log("final path chosen:", finalPath + extension);

    finalPath = finalPath + extension;

    await encoder.exportSequence(
        sequence,
        ppro.Constants.ExportType.IMMEDIATELY,
        finalPath,
        presetPath
    );

    return finalPath;
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
        const folder = await helpers.findOrCreateFolderPath(rootBin, importPath, true);
        if (folder) targetFolder = folder;
    }

    return project.importFiles([filePath], false, targetFolder, importAsStills);
}

/**
 * move selected clips. may cause visual bugs. see link
 * @link https://forums.creativeclouddeveloper.com/t/reatemoveaction-bugs-invisible-same-source-clip-after-move-and-av-link-breaks-on-backward-audio-move/11831
 * @param {number} seconds Positive moves the clips later, negative moves them earlier. (Signature changed: the old `subtract` boolean is gone.)
 * @returns {void}
 */
export async function moveClip(seconds: number): Promise<void> {
    if (!Number.isFinite(seconds) || seconds === 0) return;

    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const sequence = await project.getActiveSequence();
    if (!sequence) return;

    const [settings, items] = await Promise.all([
        sequence.getSettings(),
        common.getSelectedTrackItems(),
    ]);
    if (!items || items.length === 0) return;

    const subtract = seconds < 0;
    const frameRate = settings.getVideoFrameRate();
    const frames = Math.round(Math.abs(seconds) * frameRate.value);
    if (frames === 0) return;
    // Always a positive offset; direction is handled with add/subtract below
    const offset = ppro.TickTime.createWithFrameAndFrameRate(frames, frameRate);

    // gather start and end times before transaction
    const [startTimes, endTimes] = await Promise.all([
        Promise.all(items.map((item) => item.getStartTime())),
        Promise.all(items.map((item) => item.getEndTime())),
    ]);

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction: any) => {
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
    const [project, items] = await Promise.all([
        ppro.Project.getActiveProject(),
        common.getSelectedTrackItems(),
    ]);
    if (!project) return;
    if (!items || items.length === 0) return;

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            for (let i = 0; i < items.length; i++) {
                const action = items[i].createSetDisabledAction(!enabled);
                compoundAction.addAction(action);
            }
        }, "Set Enabled/Disabled");
    });

    return;
}

/**
 * setup premiere bin structure, optionally seeding "_Assets/01_Other" with standard assets
 * (adjustment layers, mattes, blank audio, etc.) copied out of a template project.
 *
 * @param {string} [templateProjectPath] absolute path to a template .prproj to pull standard assets from. Step is skipped if omitted.
 * @param {boolean} [includeOptionalAssets] also copy Black Video / Color Matte / Bars and Tone / blank audio, not just the adjustment layers
 * @returns {void}
 */
export async function setupProjBin(
    templateProjectPath: string,
    includeOptionalAssets: boolean = true
): Promise<void> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return;

    const rootItem = await project.getRootItem();
    if (!rootItem) return;

    const ROOTBINS = ["_Assets", "_linked comps & renders", "_Sequences"];
    const SUBBINS = [
        "01_Other",
        "02_Images",
        "03_sfx",
        "04_Music",
        "05_Other Audio",
        "06_Videos",
        "07_Other Assets"
    ];
    const TEMPLATE_ADJUSTMENT_LAYERS = [
        "_colour_adjust layer",
        "_members",
        "_members_bonus",
        "_transform_adjust layer",
        "Adjustment Layer"
    ];

    const TEMPLATE_OPTIONAL_ASSETS = [
        "Black Video",
        "Color Matte_white",
        "Bars and Tone - Rec 709",
        "blank.wav",
        "blank_long.wav"
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

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            for (const binName of ROOTBINS) {
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

    const assetsBin = await helpers.findOrCreateFolderPath(rootItem, "_Assets", false);
    if (!assetsBin) return;

    const assetsChildren = await getChildNames(assetsBin);

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            for (const binName of SUBBINS) {
                if (!assetsChildren.includes(binName)) {
                    compoundAction.addAction(assetsBin.createBinAction(binName, false));
                }
            }
        }, "Setup Assets Sub-Bins");
    });

    if (!templateProjectPath) return;

    await new Promise(resolve => setTimeout(resolve, 500));

    // "01_Other" is guaranteed to exist by now, so createIfMissing isn't needed here
    const otherBin = await helpers.findOrCreateFolderPath(rootItem, "_Assets/01_Other", false);
    if (!otherBin) return;

    // Skip names already present, so re-running this is a no-op for items already imported
    const otherBinChildren = await getChildNames(otherBin);

    // Stage the entire template project in a throwaway bin at root so its full
    // contents don't dump directly into the project panel
    const stagingFolder = await helpers.findOrCreateFolderPath(rootItem, "__TemplateImportStaging__", true);
    if (!stagingFolder) return;

    // Equivalent of File > Import > picking a .prproj — brings in the ENTIRE
    // template project's bin structure, nested under a bin named after the file
    const importSuccess = await project.importFiles(
        [templateProjectPath],
        true,
        stagingFolder,
        false
    );

    if (!importSuccess) {
        await project.lockedAccess(() => {
            return project.executeTransaction((compoundAction) => {
                compoundAction.addAction(rootItem.createRemoveItemAction(stagingFolder));
            }, "Remove Template Import Staging Bin");
        });
        return;
    }

    await new Promise(resolve => setTimeout(resolve, 500));

    // The template's own "01_Other" bin will be nested somewhere inside the
    // imported wrapper bin (named after the template file) — location is dynamic,
    // so this uses matchFolders rather than a fixed path
    const templateOtherBin = await helpers.searchForItemByName(stagingFolder, "01_Other", true);

    if (templateOtherBin) {
        const wantedNames = includeOptionalAssets
            ? [...TEMPLATE_ADJUSTMENT_LAYERS, ...TEMPLATE_OPTIONAL_ASSETS]
            : TEMPLATE_ADJUSTMENT_LAYERS;

        const sourceItems = await templateOtherBin.getItems();
        const matches = sourceItems.filter((item: any) =>
            wantedNames.includes(item.name) && !otherBinChildren.includes(item.name)
        );

        await project.lockedAccess(() => {
            return project.executeTransaction((compoundAction) => {
                for (const item of matches) {
                    compoundAction.addAction(otherBin.createMoveItemAction(item, otherBin));
                }
                compoundAction.addAction(rootItem.createRemoveItemAction(stagingFolder));
            }, "Import Template Assets Into 01_Other");
        });
    } else {
        await project.lockedAccess(() => {
            return project.executeTransaction((compoundAction) => {
                compoundAction.addAction(rootItem.createRemoveItemAction(stagingFolder));
            }, "Remove Template Import Staging Bin");
        });
    }

    const audSeq = "Main Sequence-for audio"
    const audSeqExists = await helpers.searchForItemByName(rootItem, audSeq)
    if (!audSeqExists) {
        await helpers.importSequencesFromProject(project, templateProjectPath, audSeq);
    }
}

/**
 * make all video tracks of the curret sequence visible
 * @returns {void}
 */
export async function unhideAllVideoTracks(): Promise<void> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return;

    const trackCount = await sequence.getVideoTrackCount();
    await Promise.all(
        Array.from({ length: trackCount }, async (_, i) => {
            const track = await sequence.getVideoTrack(i);
            await track.setMute(false);
        })
    );
}

/**
 * unmute all audio tracks
 * @returns {void}
 */
export async function unmuteAllTracks(): Promise<void> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return;

    const trackCount = await sequence.getAudioTrackCount();
    await Promise.all(
        Array.from({ length: trackCount }, async (_, i) => {
            const track = await sequence.getAudioTrack(i);
            await track.setMute(false);
        })
    );
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

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
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

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            compoundAction.addAction(sequence.createSetSettingsAction(settings));
        }, "Toggle Linear Colour");
    });

    return newValue;
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

    const targetFolder = await helpers.findOrCreateFolderPath(rootItem, folderPath, true);
    if (!targetFolder) return false;

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
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
        await project.lockedAccess(() => {
            return project.executeTransaction((compoundAction) => {
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
    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            for (const item of images) compoundAction.addAction(imageFolder.createMoveItemAction(item, imageFolder));
            for (const item of videos) compoundAction.addAction(videoFolder.createMoveItemAction(item, videoFolder));
            for (const item of linkedComps) compoundAction.addAction(linkedCompsFolder.createMoveItemAction(item, linkedCompsFolder));
        }, "Organise Project");
    });
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

    const [selection, playerPosition] = await Promise.all([
        sequence.getSelection(),
        sequence.getPlayerPosition(),
    ]);
    if (!selection) return;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return;

    const results = await Promise.all(items.map(async (item) => {
        if (item.constructor.name !== "AudioClipTrackItem") return null;

        const chain = await item.getComponentChain();
        if (!chain) return null;

        const component = await chain.getComponentAtIndex(0);
        if (!component) return null;

        const param = await component.getParam(1);
        if (!param) return null;

        const isTimeVarying = await param.isTimeVarying();

        let currentValue: number;
        let keyframe: any;

        if (isTimeVarying) {
            const [startTime, inPoint] = await Promise.all([
                item.getStartTime(),
                item.getInPoint(),
            ]);
            const clipPos = inPoint.add(playerPosition.subtract(startTime));

            const valueAtTime = await param.getValueAtTime(clipPos);
            currentValue = (valueAtTime as any).value ?? (valueAtTime as any);

            const newEncoded = helpers.dbToEncoded(helpers.encodedToDb(currentValue) + levelInDb);
            keyframe = await param.createKeyframe(newEncoded);
            keyframe.position = clipPos;
        } else {
            const startValue = await param.getStartValue();
            currentValue = (startValue.value as any).value;

            const newEncoded = helpers.dbToEncoded(helpers.encodedToDb(currentValue) + levelInDb);
            keyframe = await param.createKeyframe(newEncoded);
        }

        return { param, keyframe, isTimeVarying };
    }));
    const paramData = results.filter(
        (r): r is { param: any, keyframe: any, isTimeVarying: boolean } => r !== null
    );

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
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
 * load the desired item path into the source monitor.
 * @param {string} [itemPath] itemPath can be just a filename or a full path like "_Assets/Footage/clip.mov"
 * @returns {boolean}
 */
export async function loadInSourceMonitor(itemPath: string): Promise<boolean> {
    const loadItem = await helpers.projItemByPath(itemPath);
    return await ppro.SourceMonitor.openProjectItem(loadItem);
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

    const [playerPosition, settings, selection] = await Promise.all([
        sequence.getPlayerPosition(),
        sequence.getSettings(),
        sequence.getSelection(),
    ]);
    const colourIndex = parseInt(colour);
    const frameRate = settings.getVideoFrameRate();

    const items = selection ? await selection.getTrackItems() : [];

    if (!items || items.length === 0) {
        const alignedPos = playerPosition.alignToFrame(frameRate);
        const sequenceMarkers = await ppro.Markers.getMarkers(sequence);
        if (!sequenceMarkers) return;

        const existingList = sequenceMarkers.getMarkers();
        const match = helpers.findMarkerAtFrame(existingList, alignedPos, frameRate);

        if (match) {
            await project.lockedAccess(() => {
                return project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(match.createSetColorByIndexAction(colourIndex));
                }, "Set Sequence Marker Color");
            });
            return;
        }

        await project.lockedAccess(() => {
            return project.executeTransaction((compoundAction) => {
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
        const newMarker = helpers.findMarkerAtFrame(updatedList, alignedPos, frameRate);
        if (newMarker) {
            await project.lockedAccess(() => {
                return project.executeTransaction((compoundAction) => {
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

        const [startTime, inPoint] = await Promise.all([
            items[i].getStartTime(),
            items[i].getInPoint(),
        ]);
        const rawClipPos = inPoint.add(playerPosition.subtract(startTime));
        const clipPos = rawClipPos.alignToFrame(frameRate);

        const markers = await ppro.Markers.getMarkers(markerOwner);
        if (!markers) continue;

        const existingMarkers = markers.getMarkers();
        const existingMarker = helpers.findMarkerAtFrame(existingMarkers, clipPos, frameRate);

        if (existingMarker) {
            await project.lockedAccess(() => {
                return project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(existingMarker.createSetColorByIndexAction(colourIndex));
                }, "Set Marker Color");
            });
        } else {
            await project.lockedAccess(() => {
                return project.executeTransaction((compoundAction) => {
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
            const newMarker = helpers.findMarkerAtFrame(updatedList, clipPos, frameRate);
            if (newMarker) {
                await project.lockedAccess(() => {
                    return project.executeTransaction((compoundAction) => {
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

    const [playerPosition, settings, selection] = await Promise.all([
        sequence.getPlayerPosition(),
        sequence.getSettings(),
        sequence.getSelection(),
    ]);
    const frameRate = settings.getVideoFrameRate();
    const alignedPos = playerPosition.alignToFrame(frameRate);

    const items = selection ? await selection.getTrackItems() : [];

    if (!items || items.length === 0) {
        // remove sequence marker
        const sequenceMarkers = await ppro.Markers.getMarkers(sequence);
        if (!sequenceMarkers) return;

        const existingList = sequenceMarkers.getMarkers();
        const match = helpers.findMarkerAtFrame(existingList, alignedPos, frameRate);

        if (match) {
            await project.lockedAccess(() => {
                return project.executeTransaction((compoundAction) => {
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

        const [startTime, inPoint] = await Promise.all([
            items[i].getStartTime(),
            items[i].getInPoint(),
        ]);
        const rawClipPos = inPoint.add(playerPosition.subtract(startTime));
        const clipPos = rawClipPos.alignToFrame(frameRate);

        const markers = await ppro.Markers.getMarkers(markerOwner);
        if (!markers) continue;

        const existingMarkers = markers.getMarkers();
        const match = helpers.findMarkerAtFrame(existingMarkers, clipPos, frameRate);

        if (match) {
            await project.lockedAccess(() => {
                return project.executeTransaction((compoundAction) => {
                    compoundAction.addAction(markers.createRemoveMarkerAction(match));
                }, "Remove Marker");
            });
        }
    }
}

/**
 * apply effects to all selected clips
 * @param {string} [effectName] the name of the effect
 * @returns {boolean}
 */
export async function applyEffectOnAllSelectedClips(effectName: string): Promise<boolean> {
    const [project, items] = await Promise.all([
        ppro.Project.getActiveProject(),
        common.getSelectedTrackItems(),
    ]);
    if (!project) return false;
    if (!items || items.length === 0) return false;

    const videoFilterFactory = ppro.VideoFilterFactory;
    const audioFilterFactory = ppro.AudioFilterFactory;

    // Clips are independent, so build their components in parallel. The name
    // fallbacks *within* a clip stay sequential (try one, then the next).
    const results = await Promise.all(items.map(async (item) => {
        const isVideo = item.constructor.name === "VideoClipTrackItem";

        const chain = await item.getComponentChain();
        if (!chain) return null;

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

        if (!component) return null;

        return { chain, component };
    }));
    const clipData = results.filter((r): r is { chain: any, component: any } => r !== null);

    if (clipData.length === 0) return false;

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
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

    const lines = await Promise.all(
        Array.from({ length: componentCount }, async (_, i) => {
            const component = await chain.getComponentAtIndex(i);
            const [displayName, matchName] = await Promise.all([
                component.getDisplayName(),
                component.getMatchName(),
            ]);
            return `${i}: ${displayName} (matchName: ${matchName})\n`;
        })
    );
    const effectsList = "Effects on clip:\n" + lines.join("");

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

    const [vidMatchNames, audMatchNames] = await Promise.all([
        videoFilterFactory.getMatchNames(),
        audioFilterFactory.getDisplayNames(),
    ]);
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

        // Everything below is read-only, so items, components and params are
        // resolved concurrently (Promise.all preserves ordering). Keyframe values
        // are still read one at a time within each param.
        const buckets = await Promise.all(items.map(async (item) => {
            const mediaType = item.constructor.name === "VideoClipTrackItem" ? "Video" : "Audio";

            const chain = await item.getComponentChain();
            if (!chain) return null;

            const componentCount = await chain.getComponentCount();

            // Clip timing, used to work out which time domain the keyframes are in.
            // Best-effort: if it fails we just save without origin info.
            let clipTimes: { inT: bigint, startT: bigint, durT: bigint } | null = null;
            try {
                const [inPoint, clipStart, clipDuration] = await Promise.all([
                    item.getInPoint(),
                    item.getStartTime(),
                    item.getDuration(),
                ]);
                clipTimes = {
                    inT: BigInt(inPoint.ticks),
                    startT: BigInt(clipStart.ticks),
                    durT: BigInt(clipDuration.ticks),
                };
            } catch (e) {
                console.log("saveEffectSlotJSON: could not read clip timing:", e);
            }

            const maybeEffects = await Promise.all(
                Array.from({ length: componentCount }, async (_, c): Promise<EffectEntry | null> => {
                    const component = await chain.getComponentAtIndex(c);
                    const matchName = await component.getMatchName();
                    if (SKIPPED_MATCH_NAMES[matchName]) return null;

                    const [displayName, paramCount] = await Promise.all([
                        component.getDisplayName(),
                        component.getParamCount(),
                    ]);

                    const properties = await Promise.all(
                        Array.from({ length: paramCount }, async (_, j): Promise<PropertyEntry> => {
                            const param = await component.getParam(j);
                            const paramDisplayName = param.displayName;
                            const isTimeVarying = await param.isTimeVarying();

                            const entry: PropertyEntry = { displayName: paramDisplayName, isTimeVarying };

                            if (isTimeVarying) {
                                const tickTimes = await param.getKeyframeListAsTickTimes();
                                // Sequential on purpose (matches the original behaviour)
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

                            return entry;
                        })
                    );

                    const entry: EffectEntry = { matchName, displayName, properties };

                    // Work out whether this effect's keyframe times sit in source time
                    // (relative to the in-point) or sequence time (relative to clip start)
                    const kfTimes = properties.flatMap((p) => p.keyframes ?? []).map((k) => BigInt(k.time));
                    if (clipTimes && kfTimes.length > 0) {
                        const { inT, startT, durT } = clipTimes;
                        if (kfTimes.every((t) => t >= inT && t <= inT + durT)) {
                            entry.timeDomain = "source";
                            entry.timeOrigin = inT.toString();
                        } else if (kfTimes.every((t) => t >= startT && t <= startT + durT)) {
                            entry.timeDomain = "timeline";
                            entry.timeOrigin = startT.toString();
                        }
                    }

                    return entry;
                })
            );

            const effects = maybeEffects.filter((e): e is EffectEntry => e !== null);
            return { mediaType, effects };
        }));

        const payload = buckets.filter(
            (b): b is { mediaType: string, effects: EffectEntry[] } => b !== null
        );

        return JSON.stringify(payload);
    } catch (e: any) {
        return "ERROR in saveEffectSlotJSON: " + e.toString();
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
        payload = await helpers.readAndDecodeText(data);
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

    // Items and effects stay sequential: each effect is inserted and then looked
    // up again by match name, so parallel inserts would confuse that lookup.
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

                await project.lockedAccess(() => {
                    return project.executeTransaction((compoundAction) => {
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
                const keyframeShift = await helpers.computeKeyframeShift(item, fx);
                if (fx.properties.some((p) => p.isTimeVarying)) {
                    console.log(
                        `[applyEffectSlotJSON] ${fx.matchName}: domain=${fx.timeDomain ?? "none"} savedOrigin=${fx.timeOrigin ?? "n/a"} shift=${keyframeShift}`
                    );
                }

                // Kept SEQUENTIAL on purpose: creating keyframes concurrently (per param or
                // per keyframe) stopped the stored keyframes from being applied. Each keyframe
                // is created and positioned before the next one is created.
                const paramData: { param: any, keyframes?: { keyframe: any }[], staticKeyframe?: any }[] = [];

                for (let j = 0; j < fx.properties.length && j < paramCount; j++) {
                    const savedProp = fx.properties[j];
                    const param = await newComponent.getParam(j);

                    if (savedProp.isTimeVarying && savedProp.keyframes) {
                        const keyframes: { keyframe: any }[] = [];
                        const hasAnchors = fx.anchorInPoint !== undefined && fx.anchorOutPoint !== undefined;

                        if (hasAnchors) {
                            // PRESET PATH: scale keyframe timing to fit the target clip's duration
                            const anchorIn = BigInt(fx.anchorInPoint!);
                            const anchorOut = BigInt(fx.anchorOutPoint!);
                            const originalSpan = anchorOut - anchorIn;

                            const clipDuration = await item.getDuration();
                            const clipDurationTicks = BigInt(clipDuration.ticks);

                            for (const kf of savedProp.keyframes) {
                                const relativeOffset = BigInt(kf.time) - anchorIn;
                                const scaledOffset = originalSpan > 0n
                                    ? (relativeOffset * clipDurationTicks) / originalSpan
                                    : relativeOffset;

                                const tickTime = ppro.TickTime.createWithTicks(scaledOffset.toString());
                                const keyframe = await helpers.createParamKeyframe(param, kf.value, `${fx.matchName}/${savedProp.displayName} @ ${tickTime.ticks}`);
                                if (!keyframe) continue;
                                keyframe.position = tickTime;
                                keyframes.push({ keyframe });
                            }
                        } else {
                            // PLAIN JSON PATH: times are absolute, so re-map them onto this clip
                            // (keyframeShift is 0 for the original clip / older saves)
                            for (const kf of savedProp.keyframes) {
                                const tickTime = ppro.TickTime.createWithTicks((BigInt(kf.time) + keyframeShift).toString());
                                const keyframe = await helpers.createParamKeyframe(param, kf.value, `${fx.matchName}/${savedProp.displayName} @ ${tickTime.ticks}`);
                                if (!keyframe) continue;
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
                            const keyframe = await param.createKeyframe(await helpers.toParamValue(coerced));
                            paramData.push({ param, staticKeyframe: keyframe });
                        } catch (e) {
                            console.log(`[applyEffectSlotJSON] static createKeyframe FAILED for ${fx.matchName}/${savedProp.displayName}, value=`, savedProp.value, e);
                        }
                    }
                }

                const txErrors: string[] = [];
                let txOk: any = undefined;
                await project.lockedAccess(() => {
                    txOk = project.executeTransaction((compoundAction) => {
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
                            } catch (e: any) { txErrors.push(String(e)); }
                        }
                    }, "Restore Effect Params");
                });

                // Read back what actually landed so silent failures show up in the result
                const details: string[] = [];
                for (const pd of paramData) {
                    if (!pd.keyframes) continue;
                    try {
                        const applied = await pd.param.getKeyframeListAsTickTimes();
                        details.push(`${pd.param.displayName || "param"}: ${applied.length}/${pd.keyframes.length} keyframes`);
                    } catch (e: any) {
                        details.push(`${pd.param.displayName || "param"}: readback failed (${String(e)})`);
                    }
                }
                const suffix = details.length ? ` [${details.join("; ")}]` : "";
                if (txOk === false || txErrors.length > 0) {
                    allResults.push(`[${mediaType}] ${fx.matchName}: PARTIAL (transaction=${txOk}, errors=${txErrors.join(" | ") || "none"})${suffix}`);
                } else {
                    allResults.push(`[${mediaType}] ${fx.matchName}: OK${suffix}`);
                }
            } catch (e: any) {
                allResults.push(`[${mediaType}] ${fx.matchName}: FAILED -- ${e.toString()}`);
            }
        }
    }

    console.log("[applyEffectSlotJSON] result:\n" + allResults.join("\n"));
    return "DONE:\n" + allResults.join("\n");
}

/**
 * adds adjustment layer above selected clips
 * @param {string} [adjustmentLayerPath] the bin path to the adjustment layer you wish to add above the selected clips
 * @param {boolean} [makeSelection] whether you wish for the newly added adjustment layer to become the selected clip
 * @returns {void}
 * @version 26.3.0
 */
export async function addMatchedAdjustmentLayer(adjustmentLayerPath: string, makeSelection: boolean): Promise<void | string> {
    if (!(await helpers.isPremVerAtLeast("26.3.0")))
        return "null_version_26.3"
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

    const [rawProjItem, editor] = await Promise.all([
        helpers.projItemByPath(adjustmentLayerPath),
        ppro.SequenceEditor.getEditor(sequence),
    ]);
    if (!rawProjItem) {
        alert('Could not find adjustment layer at path: "' + adjustmentLayerPath + '"');
        return;
    }
    const clipProjItem = await ppro.ClipProjectItem.cast(rawProjItem);

    // --- Gather selected clips per video track ---
    // Looping tracks and checking getIsSelected() per clip avoids having to
    // distinguish video vs audio items coming back from sequence.getSelection(),
    // since that returns a mixed VideoClipTrackItem | AudioClipTrackItem array.
    const videoTrackCount = await sequence.getVideoTrackCount();
    const selectedEntries = await helpers.gatherSelectedVideoClips(sequence, videoTrackCount);

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
    const { trackIndex: targetTrackIndex, needsNewTrack } = await helpers.findFirstFreeTrack(
        (i) => sequence.getVideoTrack(i),
        videoTrackCount,
        overallStart,
        overallEnd,
        highestTrackIndex + 1
    );

    // --- Read the adjustment layer's original in/out points, to restore afterward ---
    const [originalInPoint, originalOutPoint] = await Promise.all([
        clipProjItem.getInPoint(ppro.Constants.MediaType.VIDEO),
        clipProjItem.getOutPoint(ppro.Constants.MediaType.VIDEO),
    ]);
    const invalidTime = ppro.TickTime.TIME_INVALID;
    const hadOriginalInOut = !originalInPoint.equals(invalidTime) && !originalOutPoint.equals(invalidTime);

    const zeroTime = ppro.TickTime.TIME_ZERO;
    const startTime = overallStart; // the exact TickTime Premiere gave us for the earliest selected clip's start
    const audioTrackIndex = 0;

    // --- Steps 1-3 below MUST stay sequential (each is its own committed transaction) ---

    // --- Step 1: commit the temporary in/out points as their own transaction,
    // BEFORE the placement action is even created. The insert/overwrite action
    // appears to capture the project item's duration at the moment it's created,
    // not when the transaction actually executes -- so bundling this into the same
    // transaction as the placement doesn't work. Committing it first guarantees the
    // placed clip can never be longer than the free space already verified above,
    // so it can't overwrite anything adjacent on the target track. ---
    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            const setTempInOutAction = clipProjItem.createSetInOutPointsAction(zeroTime, durationTime);
            compoundAction.addAction(setTempInOutAction);
        }, "Set temporary adjustment layer duration");
    });

    // --- Step 2: place it, now that the project item's own duration already
    // matches exactly what we need. ---
    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            const placeAction = needsNewTrack
                ? editor.createInsertProjectItemAction(rawProjItem, startTime, targetTrackIndex, audioTrackIndex, false)
                : editor.createOverwriteItemAction(rawProjItem, startTime, targetTrackIndex, audioTrackIndex);
            compoundAction.addAction(placeAction);
        }, "Add matched adjustment layer");
    });

    // --- Step 3: restore the project item's original in/out points so manually
    // dragging it in from the bin afterward isn't affected. ---
    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
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
            await ppro.TrackItemSelection.createEmptySelection((selection) => {
                selection.addItem(placedClip);
                sequence.setSelection(selection);
            });
        }
    }
}

/**
 * add transitions to certain audio edit points. This will (hopefully in the future) enable adding audio transitions to any audio clips that are either enabled, or have an enabled clip adjacent to them. This will not add transitions to clips that already contain them.
 * ! Currently this function is non functional as there are api shortcomings. Hopefully this is one day useable
 * ! this function would need to be adjusted to not add transitions to bars and tone
 * ? potentially also add a param to ignore any tracks below a certain track index (to completely ignore music/sfx)
 */
export async function addTransitionsToEnabledAudioEditPoints(dryRun: boolean, debug: boolean) {
    const project = await ppro.Project.getActiveProject();
    const sequence = await project.getActiveSequence();

    if (!sequence) {
        console.warn("No active sequence.");
        return;
    }

    const audioTrackCount = await sequence.getAudioTrackCount();
    const results = [];

    for (let trackIndex = 0; trackIndex < audioTrackCount; trackIndex++) {
        const audioTrack = await sequence.getAudioTrack(trackIndex);

        // false = don't include empty/gap track items, just real clips
        // Defensively filter out any null/undefined entries - some track item
        // queries can return sparse arrays with nulls in gap slots.
        const rawClips = await audioTrack.getTrackItems(Constants.TrackItemType.CLIP, false);
        const clips = (rawClips || []).filter(Boolean);

        if (clips.length < 2) continue;

        // Pull back any transitions ALREADY on this track (existing, user-placed
        // ones included) so we can skip edit points that already have one.
        //
        // KNOWN LIMITATION: as of the current UXP release, Premiere reports the
        // correct *count* of transition track items on an audio track, but the
        // objects themselves come back as null (no AudioTransition wrapper class
        // is implemented yet - the same "not built out yet" state Adobe has
        // confirmed for CaptionTrack items). That means we can detect that
        // transitions exist, but not which edit points they're on, so this
        // check cannot safely be used to skip specific edit points right now.
        // Filtered for null/undefined entries; see debug logging below.
        const loadTransitions = async () => {
            const rawTransitions = await audioTrack.getTrackItems(Constants.TrackItemType.TRANSITION, true);
            const existingTransitions = (rawTransitions || []).filter(Boolean);
            const transitionRanges = await Promise.all(
                existingTransitions.map(async (t) => {
                    const [start, end] = await Promise.all([t.getStartTime(), t.getEndTime()]);
                    return { start: start.ticksNumber, end: end.ticksNumber };
                })
            );
            return { rawTransitions, existingTransitions, transitionRanges };
        };

        // Everything below is read-only and independent, so it's fetched in one go:
        //  - every clip's disabled state ONCE (guarantees clip N's state is never
        //    checked twice as we slide the window across edit points)
        //  - every clip's start/end ONCE (ticks for the precise overlap comparison,
        //    seconds purely for the human-readable timecode in the log line)
        //  - any transitions already on the track
        const [disabledStates, clipRanges, transitionInfo] = await Promise.all([
            Promise.all(clips.map((clip) => clip.isDisabled())),
            Promise.all(
                clips.map(async (clip) => {
                    const [start, end] = await Promise.all([clip.getStartTime(), clip.getEndTime()]);
                    return {
                        startTicks: start.ticksNumber,
                        endTicks: end.ticksNumber,
                        startSeconds: start.seconds,
                        endSeconds: end.seconds,
                    };
                })
            ),
            loadTransitions(),
        ]);
        const { rawTransitions, existingTransitions, transitionRanges } = transitionInfo;

        if (debug) {
            console.log(`Track ${trackIndex}: raw transition item count = ${(rawTransitions || []).length}, after filtering nulls = ${existingTransitions.length}`);
            transitionRanges.forEach((r, idx) => {
                console.log(`  transition[${idx}]: startTicks=${r.start} endTicks=${r.end} (~${helpers.formatTimecode(r.start / 254016000000)} to ${helpers.formatTimecode(r.end / 254016000000)})`);
            });
        }

        let skippedBothDisabled = 0;
        let skippedAlreadyHasTransition = 0;
        let qualified = 0;

        for (let i = 0; i < clips.length - 1; i++) {
            const leftClip = clips[i];
            const rightClip = clips[i + 1];
            const leftDisabled = disabledStates[i];
            const rightDisabled = disabledStates[i + 1];

            const bothDisabled = leftDisabled && rightDisabled;

            if (bothDisabled) {
                // Skip entirely - neither clip contributes audio, no transition needed.
                skippedBothDisabled++;
                continue;
            }

            // The edit point sits between leftClip's end and rightClip's start.
            // If a transition already straddles that point (whether it was placed
            // by the user or a prior run of this script), leave it alone.
            const editPointTick = (clipRanges[i].endTicks + clipRanges[i + 1].startTicks) / 2;
            const editPointSeconds = (clipRanges[i].endSeconds + clipRanges[i + 1].startSeconds) / 2;
            const alreadyHasTransition = transitionRanges.some(
                (r) => editPointTick >= r.start && editPointTick < r.end
            );

            if (debug) {
                console.log(
                    `  editPoint[${i}] @ ${helpers.formatTimecode(editPointSeconds)}: ` +
                    `leftEndTicks=${clipRanges[i].endTicks} rightStartTicks=${clipRanges[i + 1].startTicks} ` +
                    `midpointTick=${editPointTick} -> alreadyHasTransition=${alreadyHasTransition}`
                );
            }

            if (alreadyHasTransition) {
                skippedAlreadyHasTransition++;
                continue;
            }

            // At least one side is enabled, and no transition exists yet -> qualifies.
            qualified++;
            results.push({ trackIndex, editPointIndex: i, leftClip, rightClip, editPointSeconds });

            if (!dryRun) {
                await applyAudioTransitionAtEditPoint(project, leftClip, rightClip);
            } else {
                const [leftName, rightName] = await Promise.all([leftClip.getName(), rightClip.getName()]);
                console.log(
                    `[${helpers.formatTimecode(editPointSeconds)}] Would add transition on track ${trackIndex}, edit point ${i} - between "${leftName}" (disabled=${leftDisabled}) and "${rightName}" (disabled=${rightDisabled})`
                );
            }
        }

        console.log(
            `Track ${trackIndex} summary: ${clips.length} clips, ${clips.length - 1} edit points, ` +
            `${existingTransitions.length} existing transitions found, ` +
            `${skippedBothDisabled} skipped (both disabled), ` +
            `${skippedAlreadyHasTransition} skipped (already has transition), ` +
            `${qualified} qualified`
        );
    }

    return results;
}


/**
 * STUB - fill this in once an audio transition creation API exists.
 * Pattern mirrors the *documented* video equivalent so it's a drop-in
 * once/if AudioClipTrackItem gets createAddAudioTransitionAction (or
 * similar), or if TransitionFactory gains createAudioTransition().
 */
export async function applyAudioTransitionAtEditPoint(project: Project, leftClip: AudioClipTrackItem, rightClip: AudioClipTrackItem, options = {}) {
    const {
        matchName = "Constant Power", // placeholder - not a confirmed matchName
        durationSeconds = 1,
        applyToStart = false,
    } = options;

    await project.lockedAccess(async () => {
        // --- Not currently supported for audio, shown for structure only ---
        // const transition = TransitionFactory.createAudioTransition(matchName); // does not exist yet
        // const transitionOptions = new AddTransitionOptions()
        //   .setApplyToStart(applyToStart)
        //   .setDuration(TickTime.createWithSeconds(durationSeconds));
        // const action = leftClip.createAddAudioTransitionAction(transition, transitionOptions); // does not exist yet
        // await project.executeTransaction((compoundAction) => {
        //   compoundAction.addAction(action);
        // }, "Add audio transition");

        throw new Error(
            "applyAudioTransitionAtEditPoint: no audio transition creation API is currently exposed by UXP. See comments above."
        );
    });
}


/**
 * nest selection, remove audio and replace with nested audio track
 * @version 26.3.0
 */
export async function nestSelectionReplaceNestedAudio(
    ignoreTrackTargeting: boolean = false,
    makeSelection: boolean = true,
    subsequenceName: string,
    ignoreVideoTracks: string = "",
    ignoreAudioTracks: string = ""
): Promise<void | string> {
    if (!(await helpers.isPremVerAtLeast("26.3.0")))
        return "null_version_26.3"
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

    const editor = await ppro.SequenceEditor.getEditor(sequence);
    const ignoreVideoTrackIndexes = helpers.parseTrackList(ignoreVideoTracks);
    const ignoreAudioTrackIndexes = helpers.parseTrackList(ignoreAudioTracks);

    // --- Step 1: capture the FULL selection (video + audio) before nesting.
    const [videoTrackCount, audioTrackCount] = await Promise.all([
        sequence.getVideoTrackCount(),
        sequence.getAudioTrackCount(),
    ]);

    const [selectedVideoEntries, selectedAudioEntries] = await Promise.all([
        helpers.gatherSelectedEntries((i) => sequence.getVideoTrack(i), videoTrackCount),
        helpers.gatherSelectedEntries((i) => sequence.getAudioTrack(i), audioTrackCount),
    ]);

    if (selectedVideoEntries.length === 0 && selectedAudioEntries.length === 0) {
        alert("No clips are selected in the timeline.");
        return;
    }

    const haveVideo = selectedVideoEntries.length > 0;
    const haveAudio = selectedAudioEntries.length > 0;

    let highestVideoTrackIndex = -1;
    let combinedStart: TickTime | null = null; // earliest point across video + audio -- the nest's internal zero
    let videoStart: TickTime | null = null;
    let videoEnd: TickTime | null = null;
    let audioStart: TickTime | null = null;
    let audioEnd: TickTime | null = null;

    for (const entry of selectedVideoEntries) {
        if (!videoStart || entry.start.ticksNumber < videoStart.ticksNumber) videoStart = entry.start;
        if (!videoEnd || entry.end.ticksNumber > videoEnd.ticksNumber) videoEnd = entry.end;
        if (entry.trackIndex > highestVideoTrackIndex) highestVideoTrackIndex = entry.trackIndex;
    }
    for (const entry of selectedAudioEntries) {
        if (!audioStart || entry.start.ticksNumber < audioStart.ticksNumber) audioStart = entry.start;
        if (!audioEnd || entry.end.ticksNumber > audioEnd.ticksNumber) audioEnd = entry.end;
    }
    for (const entry of [...selectedVideoEntries, ...selectedAudioEntries]) {
        if (!combinedStart || entry.start.ticksNumber < combinedStart.ticksNumber) combinedStart = entry.start;
    }

    // --- Step 2: build the nest. ---
    const subsequence = await sequence.createSubsequence(ignoreTrackTargeting);
    if (!subsequence) {
        alert("Failed to create subsequence.");
        return;
    }
    const nestedProjItem = await subsequence.getProjectItem();
    if (!nestedProjItem) {
        alert("Could not resolve the nested item -- skipping timeline replacement.");
        return;
    }
    const clipProjItem = await ppro.ClipProjectItem.cast(nestedProjItem);

    if (subsequenceName) {
        await project.lockedAccess(() => {
            return project.executeTransaction((compoundAction) => {
                const renameAction = nestedProjItem.createSetNameAction(subsequenceName);
                compoundAction.addAction(renameAction);
            }, "Rename nested sequence");
        });
    }

    // --- Step 3: re-scan and remove the original clips left behind by
    // createSubsequence(). The two scans are read-only, so they run together;
    // the two removals are transactions and stay sequential. ---
    const [videoOrphans, audioOrphans] = await Promise.all([
        helpers.findMatchingItems((i) => sequence.getVideoTrack(i), selectedVideoEntries),
        helpers.findMatchingItems((i) => sequence.getAudioTrack(i), selectedAudioEntries),
    ]);

    await helpers.removeItems(project, editor, videoOrphans, ppro.Constants.MediaType.VIDEO, "Remove original video after nest");
    await helpers.removeItems(project, editor, audioOrphans, ppro.Constants.MediaType.AUDIO, "Remove original audio after nest");

    // --- Step 4: capture original in/out for restoring between/after passes. ---
    const zeroTime = ppro.TickTime.TIME_ZERO;
    const invalidTime = ppro.TickTime.TIME_INVALID;
    const inOutMediaType = haveVideo ? ppro.Constants.MediaType.VIDEO : ppro.Constants.MediaType.AUDIO;
    const [originalInPoint, originalOutPoint] = await Promise.all([
        clipProjItem.getInPoint(inOutMediaType),
        clipProjItem.getOutPoint(inOutMediaType),
    ]);
    const hadOriginalInOut = !originalInPoint.equals(invalidTime) && !originalOutPoint.equals(invalidTime);

    // --- Step 5: video pass -- reuse the topmost originally-selected video
    // track, starting exactly where the video itself started (not dragged
    // back by any earlier J-cut audio lead-in). ---
    if (haveVideo) {
        const sliceIn = videoStart.subtract(combinedStart);
        const sliceOut = videoEnd.subtract(combinedStart);
        await helpers.placeMediaSlice(
            project, editor, sequence, nestedProjItem, clipProjItem,
            sliceIn, sliceOut, videoStart,
            highestVideoTrackIndex, true,
            originalInPoint, originalOutPoint, hadOriginalInOut,
            ignoreVideoTrackIndexes, ignoreAudioTrackIndexes
        );
    }

    // --- Step 6: audio pass -- first audio track with free space across
    // audio's own range, starting exactly where the audio itself started. ---
    if (haveAudio) {
        const sliceIn = audioStart.subtract(combinedStart);
        const sliceOut = audioEnd.subtract(combinedStart);
        const refreshedAudioTrackCount = await sequence.getAudioTrackCount();
        const audioTarget = await helpers.findFirstFreeTrack(
            (i) => sequence.getAudioTrack(i),
            refreshedAudioTrackCount,
            audioStart,
            audioEnd,
            0,
            ignoreAudioTrackIndexes
        );
        await helpers.placeMediaSlice(
            project, editor, sequence, nestedProjItem, clipProjItem,
            sliceIn, sliceOut, audioStart,
            audioTarget.trackIndex, false,
            originalInPoint, originalOutPoint, hadOriginalInOut,
            ignoreVideoTrackIndexes, ignoreAudioTrackIndexes
        );
    }

    // --- Step 7 (optional): select the newly placed video clip (preferred)
    // or audio clip. ---
    if (makeSelection) {
        if (haveVideo) {
            const track = await sequence.getVideoTrack(highestVideoTrackIndex);
            const item = await helpers.findItemAtStart(track, videoStart);
            if (item) {
                await ppro.TrackItemSelection.createEmptySelection((selection) => {
                    selection.addItem(item);
                    sequence.setSelection(selection);
                });
            }
        } else if (haveAudio) {
            const refreshedAudioTrackCount = await sequence.getAudioTrackCount();
            const audioTarget = await helpers.findFirstFreeTrack(
                (i) => sequence.getAudioTrack(i),
                refreshedAudioTrackCount,
                audioStart,
                audioEnd,
                0,
                ignoreAudioTrackIndexes
            );
            const track = await sequence.getAudioTrack(audioTarget.trackIndex);
            const item = await helpers.findItemAtStart(track, audioStart);
            if (item) {
                await ppro.TrackItemSelection.createEmptySelection((selection) => {
                    selection.addItem(item);
                    sequence.setSelection(selection);
                });
            }
        }
    }
}

/**
 * copies the value of a Transform component's Anchor Point parameter to its Position parameter, if the clip has exactly one Transform effect
 * @returns {boolean}
 */
export async function anchorToPosition(): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const sequence = await common.getActiveSequence();
    if (!sequence) return false;

    const items = await common.getSelectedTrackItems();
    if (!items || items.length !== 1) return false;

    const item = items[0];
    const chain = await item.getComponentChain();
    if (!chain) return false;

    const componentCount = await chain.getComponentCount();

    // Look up every component's display name in parallel, then keep the Transforms
    const components = await Promise.all(
        Array.from({ length: componentCount }, (_, i) => chain.getComponentAtIndex(i))
    );
    const displayNames = await Promise.all(components.map((c: any) => c.getDisplayName()));
    const transformComponents: any[] = components.filter((_: any, i: number) => displayNames[i] === "Transform");

    if (transformComponents.length !== 1) return false;

    const transform = transformComponents[0];
    const paramCount = await transform.getParamCount();

    const transformParams = await Promise.all(
        Array.from({ length: paramCount }, (_, p) => transform.getParam(p))
    );

    let anchorPointParam: any = null;
    let positionParam: any = null;

    for (const param of transformParams) {
        if (param.displayName === "Anchor Point") anchorPointParam = param;
        else if (param.displayName === "Position") positionParam = param;
    }

    if (!anchorPointParam || !positionParam) return false;

    const anchorIsTimeVarying = await anchorPointParam.isTimeVarying();
    let rawAnchorValue: any;

    if (anchorIsTimeVarying) {
        const playerPosition = await sequence.getPlayerPosition();
        rawAnchorValue = await anchorPointParam.getValueAtTime(playerPosition);
    } else {
        rawAnchorValue = await anchorPointParam.getStartValue();
    }

    // unwrap down to the raw [x, y] array
    const unwrapped = (rawAnchorValue as any)?.value ?? rawAnchorValue;
    const point = (unwrapped as any)?.value ?? unwrapped;

    if (!Array.isArray(point) || typeof point[0] !== "number" || typeof point[1] !== "number") {
        console.log("could not resolve x/y from anchor value:", point);
        return false;
    }

    const anchorPointF = await ppro.PointF(point[0], point[1]);

    const positionIsTimeVarying = await positionParam.isTimeVarying();
    const positionKeyframe = await positionParam.createKeyframe(anchorPointF);

    let success = false;
    await project.lockedAccess(() => {
        success = project.executeTransaction((compoundAction) => {
            if (positionIsTimeVarying) {
                compoundAction.addAction(positionParam.createAddKeyframeAction(positionKeyframe));
            }
            compoundAction.addAction(positionParam.createSetValueAction(positionKeyframe, true));
        }, "Sync Transform Anchor to Position");
    });

    return success;
}

/**
 * deselects the current selection then returns it as a selection
 * @version 26.3.0
 */
export async function resetSelection(): Promise<boolean | string> {
    if (!(await helpers.isPremVerAtLeast("26.3.0")))
        return "null_version_26.3"
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;

    const origSeq = await project.getActiveSequence();
    const origSelection = await origSeq.getSelection();
    const items = await origSelection.getTrackItems();
    await origSeq.clearSelection();
    await deselectAll();

    let ok = false;
    await ppro.TrackItemSelection.createEmptySelection((newSelection) => {
        for (const item of items) {
            newSelection.addItem(item, true);
        }
        ok = origSeq.setSelection(newSelection);
    });

    return ok;
}

/**
 * a simple ping to confirm the UXP extension is currently loaded and able to respond
 * @returns {boolean}
 */
export async function isPanelOpen(): Promise<boolean> {
    return true;
}

/**
 * match selected clips to the clip on the lowest track index
 */
export async function matchSelectedClipsToLowestTrack(): Promise<void> {
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

    // --- Gather selected clips per video track ---
    const videoTrackCount = await sequence.getVideoTrackCount();
    const selectedEntries = await helpers.gatherSelectedVideoClips(sequence, videoTrackCount);

    if (selectedEntries.length === 0) {
        alert("No video clips are selected in the timeline.");
        return;
    }
    if (selectedEntries.length === 1) {
        return;
    }

    // Find the entry on the lowest track index (ties broken by earliest start)
    let referenceEntry = selectedEntries[0];
    for (const entry of selectedEntries) {
        if (
            entry.trackIndex < referenceEntry.trackIndex ||
            (entry.trackIndex === referenceEntry.trackIndex &&
                entry.start.ticksNumber < referenceEntry.start.ticksNumber)
        ) {
            referenceEntry = entry;
        }
    }

    const refStart = referenceEntry.start;
    const refEnd = referenceEntry.end;
    if (refEnd.ticksNumber - refStart.ticksNumber <= 0) {
        alert("Invalid reference clip duration.");
        return;
    }

    const selectedItems = new Set(selectedEntries.map((e) => e.item));

    // Validate against unselected neighbors before touching anything.
    // Targets are checked in parallel; results come back in target order, so the
    // "blocked" list reads the same as the old sequential version.
    const blockedResults = await Promise.all(
        selectedEntries.map(async (target) => {
            if (target.item === referenceEntry.item) return null;

            const track = await sequence.getVideoTrack(target.trackIndex);
            const items = track.getTrackItems(ppro.Constants.TrackItemType.CLIP, false);

            const others = items.filter((other: any) => other !== target.item && !selectedItems.has(other));
            const overlaps = await Promise.all(others.map(async (other: any) => {
                const [otherStart, otherEnd] = await Promise.all([other.getStartTime(), other.getEndTime()]);
                return otherStart.ticksNumber < refEnd.ticksNumber && otherEnd.ticksNumber > refStart.ticksNumber;
            }));

            return overlaps.some(Boolean) ? await target.item.getName() : null;
        })
    );
    const blocked = blockedResults.filter((n): n is string => n !== null);

    if (blocked.length > 0) {
        alert(
            "Cannot match the following clip(s) to the reference range -- an unselected " +
            "clip is in the way on the same track: " + blocked.join(", ")
        );
        return;
    }

    await project.lockedAccess(() => {
        return project.executeTransaction((compoundAction) => {
            for (const target of selectedEntries) {
                if (target.item === referenceEntry.item) continue;

                const endFirst = refStart.ticksNumber < target.start.ticksNumber;

                if (endFirst) {
                    compoundAction.addAction(target.item.createSetEndAction(refEnd));
                    compoundAction.addAction(target.item.createSetStartAction(refStart));
                } else {
                    compoundAction.addAction(target.item.createSetStartAction(refStart));
                    compoundAction.addAction(target.item.createSetEndAction(refEnd));
                }
            }
        }, "Match selected clips to lowest track");
    });
}