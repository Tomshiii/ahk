#SingleInstance Force
TraySetIcon("..\Support Files\Icons\M-I_C.png")
SetTimer(check, -1)
#Include FuncRedirect.ahk
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