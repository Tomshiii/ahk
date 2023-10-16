; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\keys>
#Include <Functions\delaySI>
; }

/**
 * This function will activate the desired tool, hold it until the user releases the activation hotkey, then return to the passed in tool. An example is; activate the function > function swaps to the `hand` tool, then upon release returns the user to the `selection` tool
 * @param {String} tool is the hotkey you want the program to swap TO (ie, hand tool, zoom tool, etc). (consider using values in KSA)
 * @param {String} toolorig is the button you want the script to press to bring you back to your tool of choice. (consider using values in KSA)
*/
mouseDrag(tool, toolorig) {
    activeWin := WinGetTitle("A")
    if (WinActive(editors.AE.winTitle) &&
        (
            (!InStr(activeWin, "Adobe After Effects 20" ptf.AEYearVer " -") && !InStr(activeWin, "Adobe After Effects (Beta)")) ||
            WinActive("Save As") ||
            WinActive("Save a Copy")
        )) {
            SendInput("{" A_ThisHotkey "}")
            return
        }
    click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
    sleep 16
    delaySI(25, tool, "{LButton Down}")
    keys.allWait()
    delaySI(25, "{LButton Up}", toolorig)
}