// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro");

const LIMIT = 10;
const DEFAULT_GUARD_MS = 0;

let seqIds: string[] = [];                              // [0] = current; swap rotates through the rest
let ignore: { id: string; until: number } | null = null; // activation we caused ourselves
const guards = new Map<number, { id: string; seqIds: string[]; until: number }>();
let guardCounter = 0;

async function init() {
    ppro.EventManager.addGlobalEventListener(ppro.Constants.SequenceEvent.ACTIVATED, onActivated, false);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.SequenceEvent.CLOSED, onClosed, true);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.ProjectEvent.ACTIVATED, onProjectChange, false);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.ProjectEvent.CLOSED, reset, false);

    const { seq } = await getActive();
    touch(seq?.guid?.toString());
}
init();

async function getActive() {
    const project = await ppro.Project.getActiveProject();
    const seq = project && await project.getActiveSequence();
    return { project, seq };
}

function touch(id: string) {
    seqIds = [id, ...seqIds.filter(x => x !== id)].slice(0, LIMIT);
}

function reset() {
    guards.clear();
    ignore = null;
    seqIds = [];
}

/** Newest live guard. Also drops expired ones, so no timers are needed. */
function newestGuard() {
    const now = Date.now();
    let newest = null;
    for (const [token, g] of guards) {
        if (g.until <= now) guards.delete(token);
        else newest = g;
    }
    return newest;
}

/** Activates a sequence by id and marks the resulting event as ours. */
async function activateById(id: string) {
    try {
        const { project } = await getActive();
        const seq = await project?.getSequence(ppro.Guid.fromString(id));
        if (!seq) return false;
        ignore = { id, until: Date.now() + 1000 };   // expires, so a no-event switch can't swallow a later one
        await project.setActiveSequence(seq);
        return true;
    } catch {
        ignore = null;
        return false;
    }
}

async function onActivated(e: any) {
    const id = e?.id ?? (await getActive()).seq?.guid?.toString();
    if (!id) return;

    if (ignore && ignore.id === id && Date.now() < ignore.until) {   // our own switch
        ignore = null;
        return;
    }

    // Unexpected switch while a guard is live -> revert, and keep it out of the history
    const g = newestGuard();
    if (g && id !== g.id && await activateById(g.id)) {
        seqIds = [...g.seqIds];
        return;
    }

    touch(id);
}

function onClosed(e: any) {
    const id = e?.id;
    seqIds = seqIds.filter(x => x !== id);
    for (const [token, g] of guards) if (g.id === id) guards.delete(token);
}

function onProjectChange() {
    reset();
    getActive().then(({ seq }) => { const id = seq?.guid?.toString(); if (id) touch(id); });
}

/**
 * Remembers the active sequence. While any guard is live, activating a different sequence
 * is reverted immediately. Each caller gets its own token, so scripts can't disarm each other.
 * @param {number} [windowMs=1500] how long the guard lasts. 0 = indefinite (until disarmed,
 *   its sequence closes, or the project changes)
 * @returns {number|false} token for `disarmSequenceGuard`, or false if there is no active sequence
 */
export async function armSequenceGuard(windowMs?: number | string) {
    const { seq } = await getActive();
    const id = seq?.guid?.toString();
    if (!id) return false;

    let ms = Number(windowMs ?? DEFAULT_GUARD_MS);
    if (windowMs === "" || Number.isNaN(ms)) ms = DEFAULT_GUARD_MS;

    newestGuard();   // prune expired guards
    const token = ++guardCounter;
    guards.set(token, { id, seqIds: [...seqIds], until: ms > 0 ? Date.now() + ms : Infinity });
    return token;
}

/** Ends only this token's guard. Unknown or expired tokens are ignored. */
export function disarmSequenceGuard(token?: string | number) {
    return guards.delete(Number(token));
}

/**
 * Swap between previously active sequences. Closing sequences will remove them from the list.
 * Live guards are retargeted to the new sequence.
 * @param {number} [count=unset] The amount of sequences you wish to toggle between. If left unset, will toggle between the previous 10
 */
export async function swapPreviousSequence(count?: number) {
    const parsed = Number(count);
    const n = Number.isFinite(parsed) ? Math.max(2, Math.floor(parsed)) : LIMIT;
    if (!(await getActive()).project) return false;

    while (seqIds.length > 1) {
        const size = Math.min(n, seqIds.length);
        const head = seqIds.slice(0, size);
        head.push(head.shift()!);
        seqIds = [...head, ...seqIds.slice(size)];

        const targetId = seqIds[0];
        if (await activateById(targetId)) {
            for (const g of guards.values()) { g.id = targetId; g.seqIds = [...seqIds]; }
            return true;
        }
        seqIds = seqIds.filter(x => x !== targetId);   // gone; try the next one
    }
    return false;
}