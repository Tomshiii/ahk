; { \\ #Includes
#Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Classes\ptf>
; }

/**
 * press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example)
 * @param {String} tool is the hotkey you want the program to swap TO (ie, hand tool, zoom tool, etc). (consider using values in KSA)
 * @param {String} toolorig is the button you want the script to press to bring you back to your tool of choice. (consider using values in KSA)
*/
mouseDrag(tool, toolorig) {
    if WinActive(editors.AE.winTitle) && (!InStr(WinGetTitle("A"), "Adobe After Effects " ptf.AEYear " -") || WinActive("Save As") || WinActive("Save a Copy"))
        {
            SendInput("{" A_ThisHotkey "}")
            return
        }
    click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
    SendInput(tool "{LButton Down}")
    KeyWait(A_ThisHotkey)
    SendInput("{LButton Up}")
    SendInput(toolorig)
}