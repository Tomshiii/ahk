// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro");

import * as common from "../common";

const LIMIT = 10;
let seqIds = [];            // [0] = current; swap rotates through the rest
let ignoreId = null;        // sequence we just activated programmatically

async function init() {
    ppro.EventManager.addGlobalEventListener(ppro.Constants.SequenceEvent.ACTIVATED, onActivated, false);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.SequenceEvent.CLOSED, onClosed, true);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.ProjectEvent.ACTIVATED, onProjectChange, false);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.ProjectEvent.CLOSED, () => { seqIds = []; }, false);

    const { seq } = await getActive();
    touch(seq?.guid?.toString());
}
init();

async function getActive() {
    const project = await ppro.Project.getActiveProject();
    const seq = project && await project.getActiveSequence();
    return { project, seq };
}

function touch(id) {
    if (!id) return;
    seqIds = seqIds.filter(x => x !== id);
    seqIds.unshift(id);
    if (seqIds.length > LIMIT) seqIds.length = LIMIT;
}

function forget(id) {
    if (id) seqIds = seqIds.filter(x => x !== id);
}

function idFromEvent(e) {
    return e?.id ?? null;
}

async function onActivated(e) {
    let id = idFromEvent(e);
    if (!id) {
        const { seq } = await getActive();
        id = seq?.guid?.toString();
    }
    if (id && id === ignoreId) {   // caused by our own swap; list is already rotated
        ignoreId = null;
        return;
    }
    touch(id);
}

async function onClosed(e) {
    forget(idFromEvent(e));
}

function onProjectChange() {
    seqIds = [];
    getActive().then(({ seq }) => touch(seq?.guid?.toString()));
}

const snapshots = new Map<string, { id: string; seqIds: string[] }>();
let snapshotCounter = 0;
let lastToken: string | null = null;
const MAX_SNAPSHOTS = 20;

/**
 * Remembers the currently active sequence (and the swap history) so it can be restored later.
 * @returns {string|false} a token to pass to `restoreActiveSequence`, or false if there is no active sequence
 */
export async function snapshotActiveSequence() {
    const { seq } = await getActive();
    const id = seq?.guid?.toString();
    if (!id) return false;

    const token = String(++snapshotCounter);
    snapshots.set(token, { id, seqIds: [...seqIds] });
    lastToken = token;

    // drop the oldest if restore was never called (e.g. early returns on the AHK side)
    if (snapshots.size > MAX_SNAPSHOTS)
        snapshots.delete(snapshots.keys().next().value!);
    return token;
}

/**
 * Checks whether the active sequence still matches a snapshot, and switches back if not.
 * @param {number} [delayMs=1000] ms to wait before each check
 * @param {number} [checks=1] number of checks. Stops at the first revert
 * @param {string|number} [token] token from `snapshotActiveSequence`. Defaults to the most recent snapshot
 * @returns {"unchanged"|"restored"|false} false = unknown token / nothing to restore
 */
export async function restoreActiveSequence(token?: string | number, delayMs?: number, checks?: number) {
    const key = (token === undefined || token === null || token === "") ? lastToken : String(token);
    const target = key !== null ? snapshots.get(key) : undefined;
    if (key !== null) snapshots.delete(key);
    if (key === lastToken) lastToken = null;
    if (!target) return false;

    const ms = Number.isFinite(Number(delayMs)) ? Number(delayMs) : 1000;
    const n = Number.isFinite(Number(checks)) ? Math.max(1, Math.floor(Number(checks))) : 1;

    for (let i = 0; i < n; i++) {
        await common.sleep(ms);
        const { project, seq } = await getActive();
        if (!project) return false;
        if (seq?.guid?.toString() === target.id) continue;

        try {
            const found = await project.getSequence(ppro.Guid.fromString(target.id));
            if (!found) return false;
            ignoreId = target.id;
            await project.setActiveSequence(found);
            seqIds = [...target.seqIds];
            return "restored";
        } catch {
            ignoreId = null;
            return false;
        }
    }
    return "unchanged";
}

/**
 * Swap between previously active sequences. Closing sequences will remove them from the list.
 * @param {number} [count=unset] The amount of sequences you wish to toggle between. If left unset, will toggle between the previous 10
 */
export async function swapPreviousSequence(count?: number) {
    const parsed = Number(count);
    const n = Number.isFinite(parsed) ? Math.max(2, Math.floor(parsed)) : LIMIT;
    const { project } = await getActive();
    if (!project) return false;

    while (seqIds.length > 1) {
        const size = Math.min(n, seqIds.length);
        const head = seqIds.slice(0, size);
        head.push(head.shift());
        seqIds = [...head, ...seqIds.slice(size)];

        const targetId = seqIds[0];
        try {
            const target = await project.getSequence(ppro.Guid.fromString(targetId));
            if (!target) throw new Error("gone");
            ignoreId = targetId;
            await project.setActiveSequence(target);
            return true;
        } catch {
            ignoreId = null;
            forget(targetId);
        }
    }
    return false;
}