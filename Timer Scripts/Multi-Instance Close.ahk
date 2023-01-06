#SingleInstance Force

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Functions\detect>
#Include <Classes\obj>
; }

TraySetIcon(ptf.Icons "\M-I_C.png")
;This script will check for and close scripts that have multiple instances open
;Even if you have #SingleInstance Force enabled, sometimes while reloading you can end up with a second instance of any given script, this script should hopefully negate that

;This script will not close multiple instances of `checklist.ahk`
set:
sec := 5
if FileExist(ptf["settings"])
    sec := IniRead(ptf["settings"], "Adjust", "multi SEC")
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
            script := obj.SplitPath(path)
            if InStr(windows, script.Name "`n", 1,, 1) && script.Name != "checklist.ahk" && script.Name != "launcher.ahk"
                {
                    tool.Cust("Closing multiple instance of : " script.Name, 3000)
                    try {
                        WinClose(window)
                    }
                }
            windows .= script.Name "`n"
        }
    end:
    SetTimer(, -ms)
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        SetTimer(check, 0)
}