// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro");

const LIMIT = 10;
let seqIds = [];            // [0] = current; swap rotates through the rest
let ignoreId = null;        // sequence we just activated programmatically

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
    return e?.target?.guid?.toString?.()
        ?? e?.sequence?.guid?.toString?.()
        ?? null;
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
    console.log("seq closed event:", e, e?.target);
    forget(idFromEvent(e));
}

function onProjectChange() {
    seqIds = [];
    getActive().then(({ seq }) => touch(seq?.guid?.toString()));
}

async function init() {
    ppro.EventManager.addGlobalEventListener(ppro.Constants.SequenceEvent.ACTIVATED, onActivated, false);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.SequenceEvent.CLOSED, onClosed, false);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.ProjectEvent.ACTIVATED, onProjectChange, false);
    ppro.EventManager.addGlobalEventListener(ppro.Constants.ProjectEvent.CLOSED, () => { seqIds = []; }, false);

    const { seq } = await getActive();
    touch(seq?.guid?.toString());
}
init();

/**
 * Exposed to AHK via PremiereRemote (register it the same way as your existing functions)
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