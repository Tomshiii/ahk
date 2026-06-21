/**
 * @fileoverview Tomshi functions
 */

import { getActiveSequence } from "./common";

import type {
    premierepro,
    Sequence,
    TickTime,
    VideoTrack,
    TrackItemSelection,
} from "@adobe/premierepro";

// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
const { Constants } = ppro;
const openSequences = new Set<string>();

/**
 * store sequences
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
 * focuses the desired sequence
 * @param {String} [ID] the id of the sequence
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
/*
export async function focusSequence(ID: string): Promise<boolean> {
    const project = await ppro.Project.getActiveProject();
    if (!project) return false;
    const origSequence = await project.getActiveSequence();
    if (!origSequence) return false;

    const guid = await ppro.Guid.fromString(ID);
    if (!guid) return false;

    const selectedSequence = await project.getSequence(guid);
    if (!selectedSequence) return false;
    return await project.setActiveSequence(selectedSequence);;
} */

/**
 * opens the desired sequence
 * @param {String} [ID] the id of the sequence
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
 * Moves the playhead
 * @returns
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
 * close current active clip at source monitor
 */
export async function closeClipSourceMon(): Promise<any> {
    return ppro.SourceMonitor.closeClip();
}

/**
 * close all clips at source monitor
 */
export async function closeAllClipSourceMon(): Promise<any> {
    return ppro.SourceMonitor.closeAllClips();
}

/**
 * deselect all trackitems
 */
export async function deselectAll(): Promise<void> {
    const sequence = await getActiveSequence();
    if (!sequence) return;

    return await sequence.clearSelection();
}

/**
 * set the sequence zero point
 * @param {number} [frames] the amount of frames. will automatically be converted for the current sequence
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
    const sequence = await getActiveSequence();
    if (!sequence) return;
    const items = isSelectedReturn();
    if (!items) return;
    const len = items.length

    for (let i = 0; i < len; i++) {
        items[i].disabled = !items[i].disabled;
      }
}