/************************************************************************
 * @description a class for common zip operations
 * @author tomshi
 * @date 2026/10/16
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

class zip {
    /**
     * This function creates a comObject to unzip a folder.
     * @link Original function from @MiM in ahk discord: https://discord.com/channels/115993023636176902/1068688397947900084/1068710942327722045 (link may die)
     * @param {String} zipPath the path location of a zip folder you wish to unzip
     * @param {String} unzippedPath the path location you wish the contents of the zip folder to get extracted. If this directory does not already exist, it will be created.
     * @param {Boolean} [checkExt=true] whether the function will check if the passed in path has a `zip` extension
     * @return {Boolean} On success this function will return `true`.
     * @throws {TypeError} If `zipPath` does not have a `.zip` extension.
     */
    static unzip(zipPath, unzippedPath, checkExt := true) {
        SplitPath(zipPath,,, &checkZipPathExt)
        if checkExt && checkZipPathExt != "zip"
            throw TypeError("Requested folder is not a ZIP folder", -2, zipPath)
        SplitPath(unzippedPath,, &unzippedPathDir)
        if !DirExist(unzippedPathDir)
            DirCreate(unzippedPathDir)
        psh := ComObject("Shell.Application")
        psh.Namespace(unzippedPath).CopyHere(psh.Namespace(zipPath).items, 4|16)
        return true
    }

    /**
     * Checks whether a file exists inside a zip archive without extracting it using PowerShell.
     * Uses PowerShell and `System.IO.Compression.ZipFile` to read the archive's entry list.
     * @param {String} zipPath the full path of the zip archive to search.
     * @param {String} fileName the full path of the entry inside the zip, using forward slashes (e.g. `folder/manifest.json`). The comparison is case-insensitive.
     * @return {Boolean} `true` if an entry with that path exists in the archive, otherwise `false`.
     */
    static hasFile(zipPath, fileName) {
        zipPath  := StrReplace(zipPath, "'", "''")
        fileName := StrReplace(fileName, "'", "''")

        ps := "Add-Type -AssemblyName System.IO.Compression.FileSystem; "
            . "$z = [IO.Compression.ZipFile]::OpenRead('" zipPath "'); "
            . "try { $z.Entries.FullName -contains '" fileName "' } finally { $z.Dispose() }"

        command  := 'powershell -NoProfile -Command "' ps '"'
        return (cmd.result(command) = "True")
    }

    /**
     * Reads the contents of a single file inside a zip archive without extracting it to disk using PowerShell.
     * PowerShell returns the entry as Base64 (so no console code page can corrupt it),
     * which is then decoded to bytes with `CryptStringToBinaryW` and converted to a string.
     * @param {String} zipPath the full path of the zip archive.
     * @param {String} entryName the full path of the entry inside the zip, using forward slashes (e.g. `folder/manifest.json`). Match the case exactly, as `GetEntry` can be case-sensitive.
     * @param {String} [encoding="UTF-8"] the text encoding of the entry (e.g. `"UTF-8"`, `"UTF-16"`, `"CP1252"`).
     * @return {String} the decoded text of the entry, with any leading BOM removed.
     * @throws {Error} If the entry is not found in the zip.
     * @throws {Error} If PowerShell returns no output (the error message includes PowerShell's stderr).
     */
    static readFile(zipPath, entryName, encoding := "UTF-8") {
        q := (s) => StrReplace(s, "'", "''")   ; escape ' for PowerShell

        ps := "Add-Type -AssemblyName System.IO.Compression.FileSystem; "
            . "$z = [IO.Compression.ZipFile]::OpenRead('" q(zipPath) "'); "
            . "try { "
            .   "$e = $z.GetEntry('" q(entryName) "'); "
            .   "if (-not $e) { 'ERR:notfound'; exit 2 }; "
            .   "$s = $e.Open(); $ms = New-Object IO.MemoryStream; $s.CopyTo($ms); $s.Dispose(); "
            .   "[Convert]::ToBase64String($ms.ToArray()) "
            . "} finally { $z.Dispose() }"

        res := cmd.result('powershell -NoProfile -Command "' ps '"', true, true)   ; hide, returnObj
        out := Trim(res.StdOut, " `t`r`n")

        if (out = "ERR:notfound")
            throw Error("Entry not found in zip: " entryName)
        if (out = "")
            throw Error("PowerShell returned nothing: " res.StdErr)

        ; Decode Base64 -> bytes
        static CRYPT_STRING_BASE64 := 1
        DllCall("crypt32\CryptStringToBinaryW", "str", out, "uint", 0, "uint", CRYPT_STRING_BASE64
            , "ptr", 0, "uint*", &size := 0, "ptr", 0, "ptr", 0)
        buf := Buffer(size)
        DllCall("crypt32\CryptStringToBinaryW", "str", out, "uint", 0, "uint", CRYPT_STRING_BASE64
            , "ptr", buf, "uint*", &size, "ptr", 0, "ptr", 0)

        text := StrGet(buf, size, encoding)
        if (SubStr(text, 1, 1) = Chr(0xFEFF))   ; strip BOM if present
            text := SubStr(text, 2)
        return text
    }
}