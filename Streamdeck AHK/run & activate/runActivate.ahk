#Include <Classes\obj>

/**
 * Elgato added the ability to more easily open folders to the streamdeck. This is great but, in win11 at least, opening a directory doesn't seem to guarantee that it will become the focused window. This function is to simply run and activate that window.
 */
runAndActivate(dir, timeout := 2) {
    path := obj.SplitPath(dir)
    if WinExist(dir) || WinExist(path.name) {
        WinActivate()
        return
    }
    Run(dir)
    if WinWait(path.name " ahk_exe explorer.exe",, 2)
        WinActivate()
}