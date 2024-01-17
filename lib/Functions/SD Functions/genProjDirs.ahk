; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\winGet>
#Include <Classes\errorLog>
; }

/**
 * Generates all directories for a user's project folder
 * @param {Array/String} dirs an array of custom folder paths the user wishes to generate if they do no wish to use the default
 */
genProjDirs(dirs?) {
    activeWin := WinGet.ExplorerPath()
    defaultDir := activeWin != false ? activeWin : ptf.MyDir "\"
    SelectedFolder := FileSelect("D2", defaultDir, "Select your desired Folder. This Script will create the necessary sub folders")
    if SelectedFolder = ""
        return false
    if (IsSet(dirs) && Type(dirs) != "array") {
        ;// throw
        errorLog(PropertyError("Incorrect data type in Parameter #1", -1), "Must be an array",, 1)
        return
    }
    if !IsSet(dirs) {
        dirs := [
            "videos",                 "audio\music",              "audio\sfx",
            "proxies\colour renders", "proxies\timeline renders", "renders\draft",
            "renders\final",          "_project files",           "screenshots"
        ]
    }
    for v in dirs
        DirCreate(SelectedFolder "\" v)
    return SelectedFolder
}