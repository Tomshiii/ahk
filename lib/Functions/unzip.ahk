/**
 * This function creates a comObject to unzip a folder.
 * @link Original function from @MiM in ahk discord: https://discord.com/channels/115993023636176902/1068688397947900084/1068710942327722045 (link may die)
 * @param {String} zipPath the path location of a zip folder you wish to unzip
 * @param {String} unzippedPath the path location you wish the contents of the zip folder to get extracted. If this directory does not already exist, it will be created.
 * @return {Boolean} On success this function will return `true`.
 */
unzip(zipPath, unzippedPath) {
    SplitPath(zipPath,,, &checkZipPathExt)
    if checkZipPathExt != "zip"
        throw TypeError("Requested folder is not a ZIP folder", -2, zipPath)
    SplitPath(unzippedPath,, &unzippedPathDir)
    if !DirExist(unzippedPathDir)
        DirCreate(unzippedPathDir)
    psh := ComObject("Shell.Application")
    psh.Namespace(unzippedPath).CopyHere(psh.Namespace(zipPath).items, 4|16)
    return true
}