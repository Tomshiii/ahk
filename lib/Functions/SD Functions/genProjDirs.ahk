; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Classes\errorLog.ahk
#Include Classes\explorer.ahk
; }

/**
 * Generates all directories for a user's project folder
 * @param {Array} dirs an array of custom folder paths the user wishes to generate if they do no wish to use the default
 */
genProjDirs(dirs?) {
    activeWin := explorer.getPath()
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
            "videos\footage", "audio\music", "audio\sfx",
            "timeline renders", "_project files",
            "renders\draft", "renders\final",  "renders\socials",
            "screenshots"
        ]
    }
    for v in dirs
        DirCreate(SelectedFolder "\" v)
    return SelectedFolder
}