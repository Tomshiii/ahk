// eslint-disable-next-line @typescript-eslint/no-require-imports
const ppro = require("premierepro") as premierepro;
import type {
    premierepro,
    TickTime,
    FrameRate,
} from "@adobe/premierepro";

const { VideoDisplayFormatType } = ppro.Constants;

export function formatTimecode(seconds) {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = Math.floor(seconds % 60);
    const ms = Math.round((seconds - Math.floor(seconds)) * 1000);
    const pad = (n, len = 2) => String(n).padStart(len, "0");
    return `${pad(h)}:${pad(m)}:${pad(s)}.${pad(ms, 3)}`;
}

function computeTotalFrames(tickTime: TickTime, frameRate: FrameRate): number {
    const ticks = BigInt(tickTime.ticks); // exact integer, as a string -- same reasoning as elsewhere in this file
    const ticksPerFrame = BigInt(Math.round(frameRate.ticksPerFrame));
    return Number(ticks / ticksPerFrame); // integer division truncates toward zero; ticks is always >= 0 here, so this is a floor
}

export function formatTickTimeAsTimecode(tickTime: TickTime, frameRate: FrameRate, displayType: number): string {
    const totalFrames = computeTotalFrames(tickTime, frameRate);
    const nominalFps = Math.round(frameRate.value); // only used to pick 24/25/30 buckets below, so float imprecision here is harmless

    switch (displayType) {
        case VideoDisplayFormatType.FRAMES:
            return String(totalFrames);
        case VideoDisplayFormatType.FEET_FRAME_16mm:
            return formatFeetAndFrames(totalFrames, 40);
        case VideoDisplayFormatType.FEET_FRAME_35mm:
            return formatFeetAndFrames(totalFrames, 16);
        case VideoDisplayFormatType.FPS_29_97:
            return formatDropFrameTimecode(totalFrames);
        case VideoDisplayFormatType.FPS_23_976:
        case VideoDisplayFormatType.FPS_25:
        case VideoDisplayFormatType.FPS_29_97_NON_DROP:
        default:
            return formatNonDropFrameTimecode(totalFrames, nominalFps);
    }
}

function padFrames(n: number, width: number = 2): string {
    return String(n).padStart(width, "0");
}

function formatNonDropFrameTimecode(totalFrames: number, nominalFps: number): string {
    const ff = totalFrames % nominalFps;
    const totalSeconds = Math.floor(totalFrames / nominalFps);
    const ss = totalSeconds % 60;
    const totalMinutes = Math.floor(totalSeconds / 60);
    const mm = totalMinutes % 60;
    const hh = Math.floor(totalMinutes / 60);
    return `${padFrames(hh)}:${padFrames(mm)}:${padFrames(ss)}:${padFrames(ff)}`;
}

function formatDropFrameTimecode(totalFrames: number): string {
    const dropFramesPerMin = 2;
    const framesPerMin = 30 * 60 - dropFramesPerMin;
    const framesPer10Min = 30 * 60 * 10 - dropFramesPerMin * 9;

    const d = Math.floor(totalFrames / framesPer10Min);
    const m = totalFrames % framesPer10Min;

    const adjustedFrames =
        totalFrames +
        dropFramesPerMin * 9 * d +
        dropFramesPerMin * (m > dropFramesPerMin ? Math.floor((m - dropFramesPerMin) / framesPerMin) : 0);

    const ff = adjustedFrames % 30;
    const totalSeconds = Math.floor(adjustedFrames / 30);
    const ss = totalSeconds % 60;
    const totalMinutes = Math.floor(totalSeconds / 60);
    const mm = totalMinutes % 60;
    const hh = Math.floor(totalMinutes / 60);
    return `${padFrames(hh)}:${padFrames(mm)}:${padFrames(ss)};${padFrames(ff)}`;
}

function formatFeetAndFrames(totalFrames: number, framesPerFoot: number): string {
    const feet = Math.floor(totalFrames / framesPerFoot);
    const frames = totalFrames % framesPerFoot;
    return `${feet}+${padFrames(frames)}`;
}
