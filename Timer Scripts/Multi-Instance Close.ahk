#SingleInstance Force
TraySetIcon("..\Support Files\Icons\M-I_C.png")
#Include FuncRedirect.ahk
;This script will check for and close scripts that have multiple instances open
;Even if you have #SingleInstance Force enabled, sometimes while reloading you can end up with a second instance of any given script, this script should hopefully negate that

;This script will not close multiple instances of `checklist.ahk`
set:
sec := 5
if FileExist(ptf.files["settings"])
    sec := IniRead(ptf.files["settings"], "Adjust", "multi SEC")
global ms := sec * 1000

if IsSet(ms) ;we don't want the timer starting before the ms variable has been set
    SetTimer(check, -1)
else
    goto set
check()
{
    detect()
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
                    tool.Cust("Closing multiple instance of : " ScriptName, 3000)
                    try {
                        WinClose(window)
                    }
                }
            windows .= ScriptName "`n"
        }
    end:
    SetTimer(, -ms)
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || "Close" || "Reload" || "Error"
        {
            SetTimer(check, 0)
        }
}