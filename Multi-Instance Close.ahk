#SingleInstance Force
TraySetIcon(A_ScriptDir "\Support Files\Icons\M-I_C.png")
SetTimer(check, -1)
;This script will check for and close scripts that have multiple instances open
;Even if you have #SingleInstance Force enabled, sometimes while reloading you can end up with a second instance of any given script, this script should hopefully negate that

;This script will not close multiple instances of `checklist.ahk`

sec := 5
if FileExist(A_MyDocuments "\tomshi\settings.ini")
    sec := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "multi SEC")
global ms := sec * 1000

check()
{
    DetectHiddenWindows True  ; Allows a script's hidden main window to be detected.
    SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.
    value := WinGetList("ahk_class AutoHotkey")
    windows := ""
    for window in value
        {
            try {
                newWin := WinGettitle(window)
            }
            if !IsSet(newWin) || !IsSet(window)
                continue
            path := SubStr(newWin, 1, InStr(newWin, " -",,, 1) -1)
            SplitPath(path, &ScriptName)
            if InStr(windows, ScriptName "`n", 1,, 1) && ScriptName != "checklist.ahk" && ScriptName != "launcher.ahk"
                {
                    toolCust("Closing multiple instance of : " ScriptName, 3000)
                    try {
                        WinClose(window)
                    }
                }
            windows .= ScriptName "`n"
        }
    end:
    SetTimer(, -ms)
}


/**
 * Create a tooltip with any message. This tooltip will then follow the cursor and only redraw itself if the user has moved the cursor.
 * @param {string} message is what you want the tooltip to say
 * @param {number} timeout is how many ms you want the tooltip to last. This value can be omitted and it will default to 1s
 * @param {boolean} find is whether you want this function to state "Couldn't find " at the beginning of it's tooltip. Simply add 1 (or true) for this variable if you do, or omit it if you don't
 * @param {number} xy the x & y coordinates you want the tooltip to appear. These values are unset by default and can be omitted
 * @param {number} WhichToolTip omit this parameter if you don't need multiple tooltips to appear simultaneously. Otherwise, this is a number between 1 and 20 to indicate which tooltip window to operate upon. If unspecified, that number is 1 (the first).
 */
toolCust(message, timeout := 1000, find := false, x?, y?, WhichToolTip?)
{
    MouseGetPos(&xpos, &ypos)
    time := A_TickCount
    if find != 1
        messageFind := ""
    else
        messageFind := "Couldn't find "
    ToolTip(messageFind message, x?, y?, WhichToolTip?)
    if !IsSet(x) && !IsSet(y)
        SetTimer(moveWithMouse, 15)
    SetTimer(() => ToolTip("",,, WhichToolTip?), - timeout)
    moveWithMouse()
    {
        if (A_TickCount - time) >= timeout
            {
                SetTimer(, 0)
                ToolTip("")
            }
        MouseGetPos(&newX, &newY)
        if newX != xpos || newY != ypos
            {
                MouseGetPos(&xpos, &ypos)
                ToolTip(messageFind message)
            }
    }
}