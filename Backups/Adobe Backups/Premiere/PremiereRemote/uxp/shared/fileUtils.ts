/**
 * check if file exists
 * @returns {boolean}
 */
export async function fileExists(filePath: string): Promise<boolean> {
    try {
        const fs = require("fs");

        // Tolerate surrounding quotes/whitespace and a file:/// prefix
        let p = String(filePath ?? "").trim().replace(/^["']|["']$/g, "");
        p = p.replace(/^file:\/\/\/?/i, "");

        // Not path-shaped (raw JSON / XML / a huge base64 blob)? Don't touch the filesystem.
        if (p.length === 0 || p.length > 1024) return false;
        if (/^[\[{<]/.test(p) || /[\r\n<>|*?"]/.test(p)) return false;

        const forwardPath = p.replace(/\\/g, "/");
        const lastSlash = forwardPath.lastIndexOf("/");
        if (lastSlash <= 0) return false; // no directory part -> readdirSync("") would just throw

        const dir = forwardPath.substring(0, lastSlash);
        const fileName = forwardPath.substring(lastSlash + 1);
        if (!fileName) return false;

        const entries: string[] = fs.readdirSync(dir);
        const wanted = fileName.toLowerCase(); // Windows paths are case-insensitive
        return entries.some((e) => e.toLowerCase() === wanted);
    } catch (e: any) {
        // -4058 (Windows) / -2 / "ENOENT" just mean "that folder or file isn't there"
        const code = e?.code ?? e?.errno ?? e;
        if (code === -4058 || code === -2 || code === "ENOENT") return false;
        console.log("fileExists error:", e);
        return false;
    }
}
