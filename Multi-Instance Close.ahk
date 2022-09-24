#SingleInstance Force
TraySetIcon(A_ScriptDir "\Support Files\Icons\M-I_C.png")
SetTimer(check, -1)
;This script will check for and close scripts that have multiple instances open
;Even if you have #SingleInstance Force enabled, sometimes while reloading you can end up with a second instance of any given script, this script should hopefully negate that

;This script will not close multiple instances of `checklist.ahk`

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
    SetTimer(, -5000)
}


/* toolCust()
  create a tooltip with any message
  @param message is what you want the tooltip to say
  @param timeout is how many ms you want the tooltip to last. This value can be omitted and it will default to 1s
  @param find is whether you want this function to state "Couldn't find " at the beginning of it's tooltip. Simply add 1 for this variable if you do, or omit it if you don't
  */
toolCust(message, timeout := 1000, find := "")
{
    if find != 1
        messageFind := ""
    else
        messageFind := "Couldn't find "
    ToolTip(messageFind message)
    SetTimer(timeouttime, - timeout)
    timeouttime()
    {
        ToolTip("")
    }
}