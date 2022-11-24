/************************************************************************
 * @description A class to contain functions that pause/suspend scripts.
 * @author tomshi, Lexikos
 * @date 2022/11/24
 * @version 1.0.0
 ***********************************************************************/

#Include <\Functions\detect>
#Include <\Classes\tool>

class Pause {
    /**
     * This function toggles a pause on the autosave ahk script.
     *
     * @param {String} scriptName is the name of the script you wish to pause, ie. "My Scripts" - do not include the ".ahk"
     */
    static pause(scriptName)
    {
        detect(true, 2)
        if !WinExist(scriptName ".ahk")
            {
                tool.Cust(scriptName ".ahk script isn't open")
                ExitApp()
            }
        WM_COMMAND := 0x0111
        ID_FILE_PAUSE := 65403
        PostMessage WM_COMMAND, ID_FILE_PAUSE,,, "\" scriptName ".ahk ahk_class AutoHotkey"
    }

    /**
     * This function will suspend/unsuspend other scripts
     * This script found here: https://stackoverflow.com/questions/14492650/check-if-script-is-suspended-in-autohotkey -- by Lexikos
     *
     * @param {String} ScriptName is the name of the script, ie. "My Scripts.ahk"
     * @param {Boolean} SuspendOn is a true/false switch to either suspend/unsuspend the desired script
     */
    static Suspend(ScriptName, SuspendOn)
    {
        ; Get the HWND of the script main window (which is usually hidden).
        dhw := A_DetectHiddenWindows
        DetectHiddenWindows True
        if scriptHWND := WinExist(ScriptName " ahk_class AutoHotkey")
        {
            ; This constant is defined in the AutoHotkey source code (resource.h):
            static ID_FILE_SUSPEND := 65404

            ; Get the menu bar.
            mainMenu := DllCall("GetMenu", "ptr", scriptHWND)
            ; Get the File menu.
            fileMenu := DllCall("GetSubMenu", "ptr", mainMenu, "int", 0)
            ; Get the state of the menu item.
            state := DllCall("GetMenuState", "ptr", fileMenu, "uint", ID_FILE_SUSPEND, "uint", 0)
            ; Get the checkmark flag.
            isSuspended := state >> 3 & 1
            ; Clean up.
            DllCall("CloseHandle", "ptr", fileMenu)
            DllCall("CloseHandle", "ptr", mainMenu)

            if (!SuspendOn != !isSuspended)
                {
                    SendMessage 0x111, ID_FILE_SUSPEND,,, "ahk_id " %&scriptHWND%
                    return 1
                }
            else
                return 0
            ; Otherwise, it already in the right state.
        }
        DetectHiddenWindows %&dhw%
    }
}