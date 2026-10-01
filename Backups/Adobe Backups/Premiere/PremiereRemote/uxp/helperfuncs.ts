import * as prop from "./properties";

export * from "./shared/timecode";
export * from "./shared/prfpset";
export * from "./shared/fileUtils";
export * from "./shared/effectsUtils";
export * from "./shared/projectUtils";

/**
 * Compares two dot-separated version strings, AHK VerCompare-style.
 * Missing segments are treated as 0 (e.g. "25.1" == "25.1.0").
 * Non-numeric segments compare as 0.
 * @param {string} a - first version
 * @param {string} b - second version
 * @returns {number} 1 if a > b, -1 if a < b, 0 if equal
 */
export function compareVersions(a: string, b: string): number {
    const segsA = a.split(".");
    const segsB = b.split(".");
    const len = Math.max(segsA.length, segsB.length);

    for (let i = 0; i < len; i++) {
        const numA = parseInt(segsA[i] ?? "0", 10) || 0;
        const numB = parseInt(segsB[i] ?? "0", 10) || 0;

        if (numA > numB) return 1;
        if (numA < numB) return -1;
    }

    return 0;
}

/**
 * Checks whether the current Premiere version is >= the given minimum version.
 * @param {string} minVersion - minimum allowed version, e.g. "24.6.0"
 * @returns {Promise<boolean>} true if current Premiere version >= minVersion
 */
export async function isPremVerAtLeast(minVersion: string): Promise<boolean> {
    const currentVersion = await prop.getPremVer();
    return compareVersions(currentVersion, minVersion) >= 0;
}
