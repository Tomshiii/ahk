; { \\ #Includes
#Include <Classes\obj>
#Include <Other\Notify\Notify>
; }

/**
 * A function to select a file in an open file explorer window
 * @param {String} [fullPath] the full path of the file you wish to select
 * @param {Boolean} [checkAgain=false] determine whether to check again after 1.5s to ensure the file is selected. If the file is still being operated on by something like `ffmpeg` it may become deselected. This parameter isn't necessary if the file isn't being operated on when this function is called. Defaults to `false`
 * @returns {Boolean} returns `false` on failure/file not existing, returns `true` on success
 */
selectFileInOpenWindow(fullPath, checkAgain := false) {
    if !WinActive("ahk_exe explorer.exe") {
        Notify.Show(, 'Windows explorer is not the active window so a selection could not be made', 'C:\Windows\System32\imageres.dll|icon4', 'Speech Misrecognition',, 'theme=Dark dur=5 bdr=Red maxW=400')
        return false
    }
    hwnd := WinExist("A")
    objPath := obj.SplitPath(fullPath)
    targetPath := objPath.dir
    fileToSelect := objPath.name

    __doActivate(targetPath, fileToSelect, *) {
        if !WinActive("ahk_exe explorer.exe")
            return
        SVSI_SELECT := 0x1
        SVSI_DESELECTOTHERS := 0x4
        SVSI_ENSUREVISIBLE := 0x8
        flags := SVSI_SELECT | SVSI_DESELECTOTHERS | SVSI_ENSUREVISIBLE

        explorerWindows := ComObject("Shell.Application").Windows
        for window in explorerWindows {
            if window.hWnd != hWnd
                continue
            try {
                if (window.Document.Folder.Self.Path = targetPath) {
                    folderView := window.Document
                    itemPath := targetPath "\" fileToSelect
                    folderItem := folderView.Folder.ParseName(fileToSelect)
                    if folderItem {
                        didSelection := true
                        folderView.SelectItem(folderItem, flags)
                        break
                    }
                    continue
                }
            } catch {
                continue
            }
        }
    }
    __doActivate(targetPath, fileToSelect)
    if checkAgain = true
        SetTimer((*) => __doActivate.Bind(targetPath, fileToSelect), -1500)
    return
}