/**
 * @fileoverview Tomshi functions for basic property returns
 */
import * as common from "./common";

import type {
    premierepro,
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
export async function getSourceMonitorName(): Promise<string> {
    const item = await ppro.SourceMonitor.getProjectItem();
    return item.name;
}

/**
 * return the selected clip type
 * @returns {string | null} the clip type for the first item in the currently selected trackitem
 */
export async function getTrackClipType(): Promise<string | null> {
    const sequence = await common.getActiveSequence();
    if (!sequence) return null;

    const selection = await sequence.getSelection();
    if (!selection) return null;

    const items = await selection.getTrackItems();
    if (!items || items.length === 0) return null;

    const first = items[0];
    const type = await first.getType();
    switch (String(type)) {
        case "0": return "Empty";
        case "1": return "Clip";
        case "2": return "Transition";
        case "3": return "Preview";
        case "4": return "Feedback";
    }
    return (String(type));
}

/**
 * returns selected project item type
 * @returns {string | null} selected project item clip type
 */
export async function getProjectItemClipType(): Promise<string | null> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return null;

    const selection = await ppro.ProjectUtils.getSelection(project);
    if (!selection) return null;

    const items = await selection.getItems();
    if (!items || items.length === 0) return null;
    switch (String(items[0].type)) {
        case "1": return "Clip"
        case "2": return "Bin"
        case "3": return "Sequence"
    }
    return String(items[0].type);
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

// get/set proxies you can't do yet in uxp...

