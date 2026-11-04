// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
import type { premierepro, Sequence } from "@adobe/premierepro";
import * as helpers from "../helperfuncs";
import * as common from "../common";

/** the only difference between video and audio is which sequence methods get called */
const TRACKS = {
    video: {
        count: (s: Sequence) => s.getVideoTrackCount(),
        get: (s: Sequence, i: number) => s.getVideoTrack(i),
    },
    audio: {
        count: (s: Sequence) => s.getAudioTrackCount(),
        get: (s: Sequence, i: number) => s.getAudioTrack(i),
    },
};
type TrackKind = keyof typeof TRACKS;

/**
 * Returns `[1-based track number, track]` pairs: every track by default, or only
 * the requested numbers. Duplicates and out-of-range numbers are dropped.
 */
async function getTracks(
    sequence: Sequence,
    kind: TrackKind,
    numbers?: Iterable<number>,
): Promise<[number, any][]> {
    const { count, get } = TRACKS[kind];
    const total = await count(sequence);
    const wanted = [
        ...new Set(numbers ?? Array.from({ length: total }, (_, i) => i + 1)),
    ].filter((n) => Number.isInteger(n) && n >= 1 && n <= total);

    return Promise.all(
        wanted.map(async (n) => [n, await get(sequence, n - 1)] as [number, any]),
    );
}

/**
 * Returns the lock status of every video and audio track as a JSON string:
 * {"video":{"1":"locked","2":"unlocked"},"audio":{"1":"unlocked"}}
 * @version 27.1.0
 */
export async function getAllTrackLockStates(): Promise<string | null> {
    if (!(await helpers.isPremVerAtLeast("27.1.0")))
        return "null_version_27.1";

    const sequence = await common.getActiveSequence();
    if (!sequence) return null;

    const [video, audio] = await Promise.all(
        (["video", "audio"] as const).map(async (kind) =>
            Object.fromEntries(
                (await getTracks(sequence, kind)).map(([n, t]) => [
                    n,
                    t.locked ? "locked" : "unlocked",
                ]),
            ),
        ),
    );

    return JSON.stringify({ video, audio });
}

/**
 * Toggles the lock state of the given video and audio tracks in one
 * undoable transaction.
 * @param video - Comma-delimited 1-based video track numbers, e.g. "1,2"
 * @param audio - Comma-delimited 1-based audio track numbers, e.g. "1,3"
 * @returns true if the transaction succeeded
 * @version 27.1.0
 */
export async function toggleTrackLocks(
    video: string,
    audio: string,
): Promise<boolean | string | null> {
    if (!(await helpers.isPremVerAtLeast("27.1.0")))
        return "null_version_27.1";

    const project = await ppro.Project.getActiveProject();
    const sequence = await project?.getActiveSequence();
    if (!project || !sequence) return null;

    const tracks = (
        await Promise.all([
            getTracks(sequence, "video", helpers.parseTrackList(video)),
            getTracks(sequence, "audio", helpers.parseTrackList(audio)),
        ])
    )
        .flat()
        .map(([, track]) => track);

    if (tracks.length === 0) return false;

    let success = false;
    try {
        project.lockedAccess(() => {
            const actions = tracks.map((t) => t.createSetLockedAction(!t.locked));
            success = project.executeTransaction((compound) => {
                actions.forEach((a) => compound.addAction(a));
            }, "Toggle Track Locks");
        });
    } catch {
        // log(...)
    }

    return success;
}