/**
 * @fileoverview Tomshi functions for basic property returns
 */
import * as common from "./common";
import * as helpers from "./helperfuncs";
import * as custom from "./custom";

import type {
    premierepro,
    TickTime
} from "@adobe/premierepro";

// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
const { Constants } = ppro;


/**
 * Returns the guid of the active sequence
 * @returns {string | null} The guid string
 */
export async function getActiveSequenceID(): Promise<string | null> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return null;
    const guid = String(sequence.guid)
    return guid;
}

/**
 * Returns the name of the active sequence
 * @returns {string | null} The name of the active sequence
 */
export async function getActiveSequenceName(): Promise<string | null> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return null;
    return sequence.name;
}

/**
 * return the project path
 * @returns {string | null} project path
 */
export async function getProjPath(): Promise<string | null> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return null;

    return project.path
        .replace(/^\\\\\?\\/, '')  // strip \\?\ prefix
        .replace(/\\/g, '/');      // forward slashes work fine on Windows
}

/**
 * return the project name
 * @returns {string | null} project Name
 */
export async function getProjName(): Promise<string | null> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return null;
    return project.name;
}

/**
 * return premiere's version
 * @returns {string} premiere version
 */
export async function getPremVer(): Promise<string> {
    const { host } = require("uxp");
    return host.version;
}

/**
 * return the source montior item name
 * @returns {string} name of the file open in the source monitor
 */
export async function getSourceMonitorName(): Promise<string | boolean> {
    const item = await ppro.SourceMonitor.getProjectItem();
    if (item==null) return false;
    return item.name;
}

/**
 * return the selected clip type
 * @returns {string | null} "Clip", "Sequence" or "Adjustment Layer" for the first item in the currently selected trackitem
 */
export async function getTrackClipType(): Promise<string | null> {
    const activeSequence = await common.getActiveSequence();
    if (!activeSequence) return null;

    const selection = await activeSequence.getSelection();
    if (!selection) return null;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return null;
    const item = items[0];
    const isAdjust = await item.isAdjustmentLayer();
    if (isAdjust == true) return "Adjustment Layer";

    // nested sequences and multicams are just clips as far as TrackItemType goes
    const projItem = await item.getProjectItem();
    const clipProjItem = projItem && await ppro.ClipProjectItem.cast(projItem);
    if (clipProjItem) {
        const [isMulticam, isSeq] = await Promise.all([
            clipProjItem.isMulticamClip(),
            clipProjItem.isSequence(),
        ]);
        if (isMulticam || isSeq) return "Sequence";
    }

    const type = await item.getType();
    const name = Object.keys(Constants.TrackItemType)
        .find((k) => Constants.TrackItemType[k] === type);

    return name
        ? name.charAt(0) + name.slice(1).toLowerCase()
        : String(type);
}

/**
 * return the media type of the first selected clip
 * @returns {string | null} "Video" or "Audio" for the first item in the currently selected trackitems
 */
export async function getTrackClipMediaType(): Promise<string | null> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return null;

    const selection = await sequence.getSelection();
    if (!selection) return null;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return null;

    const item = items[0];
    if (!item) return null;

    if (item instanceof ppro.VideoClipTrackItem) return "Video";
    if (item instanceof ppro.AudioClipTrackItem) return "Audio";
    return null;
}

/**
 * returns selected project item type
 * @returns {string | null} "Sequence", "Bin", "Clip", "Compound", "File", "Root" or "Style"
 * @version 27.0.0
 */
export async function getProjectItemClipType(): Promise<string | null> {
    if (!(await helpers.isPremVerAtLeast("27.0.0")))
        return "null_version_27.0";
    const project = await ppro.Project.getActiveProject();
    if (!project) return null;

    const selection = await ppro.ProjectUtils.getSelection(project);
    if (!selection) return null;

    const items = await selection.getItems();
    if (!items || items.length === 0) return null;

    const item = items[0];

    // sequences aren't their own ProjectItemType, so check for them first
    const sequence = await helpers.findSequenceByProjectItemId(project, await item.getId());
    if (sequence) return "Sequence";

    // look the name up from the enum so we don't depend on its numbers
    const types = Constants.ProjectItemType as Record<string, number>;
    const name = Object.keys(types).find((k) => types[k] === item.type);

    return name
        ? name.charAt(0) + name.slice(1).toLowerCase() // "Bin", "Clip", "Compound", ...
        : String(item.type);
}

/**
 * returns the sequence framerate
 */
export async function getSeqFrameRate(): Promise<string | null> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return null;
    const settings = await sequence.getSettings();
    const frameRate = settings.getVideoFrameRate();
    return frameRate.value;
}

/**
 * returns the current playhead position as a timecode string, formatted to the active sequence's settings
 * @returns {string | false}
 */
export async function getPlayheadPosTimecode(): Promise<string | false> {
    const sequence = await common.getActiveSequence();
    if (!sequence) {
        return false;
    }

    const [settings, tDisplay, currentPos] = await Promise.all([
        sequence.getSettings(),
        sequence.getSequenceVideoTimeDisplayFormat(),
        sequence.getPlayerPosition(),
    ]);
    const frameRate = settings.getVideoFrameRate();

    if (!(await helpers.isPremVerAtLeast("27.0"))) {
        return helpers.formatTickTimeAsTimecode(currentPos, frameRate, tDisplay.type);
    }
    return ppro.TickTime.timeToTimecode(currentPos, frameRate, tDisplay);
}

// get/set proxies you can't do yet in uxp...

/**
 * returns the rgb background colour as a json string
 * @version 26.5.0
 */
export async function getBackgroundColour(): Promise<string> {
    if (!(await helpers.isPremVerAtLeast("26.5.0")))
        return "null_version_26.5"
    const uxp = require("uxp");
    return await uxp.host.getBackgroundColor();
}