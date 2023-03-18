; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\obj>
#Include <Classes\WM>
#Include <Functions\detect>
#Include <Multi-Instance Close\ignoreList>
; }

#SingleInstance Force
ListLines(0)
KeyHistory(0)


TraySetIcon(ptf.Icons "\M-I_C.png")
;This script will check for and close scripts that have multiple instances open
;Even if you have #SingleInstance Force enabled, sometimes while reloading you can end up with a second instance of any given script, this script should hopefully negate that

;// open settings instance
UserSettings := UserPref()

;This script will not close multiple instances of `checklist.ahk` or anything within the `ignoreList.ahk` file
set:
ms := UserSettings.multi_SEC * 1000

if IsSet(ms) { ;we don't want the timer starting before the ms variable has been set
    UserSettings := "" ;// close settings instance
    SetTimer(check, -50)
}
else
    goto set

OnMessage(0x004A, changeVar)  ; 0x004A is WM_COPYDATA
changeVar(wParam, lParam, msg, hwnd) {
    try {
        UserSettings := UserPref()
        res := WM.Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
        ;// UserSettings.autosave_MIN_ 5
        lastUnd := InStr(res, "_", 1, -1)
        var := SubStr(res, 1, lastUnd-1)
        val := SubStr(res, lastUnd+1)
        UserSettings.%var% := val
        UserSettings.__Delete()
        SetTimer((*) => reload(), -500)
    }
    return
}

check()
{
    detect()
    value := WinGetList("ahk_class AutoHotkey")
    windows := ""
    for window in value{
        try {
            newWin := WinGettitle(window)
        }
        if !IsSet(newWin) || !IsSet(window)
            continue
        script := obj.SplitPath(SubStr(newWin, 1, InStr(newWin, " -",,, 1) -1))
        if InStr(windows, script.Name "`n", 1,, 1) && !ignorelist.Has(script.Name)
            {
                tool.Cust("Closing multiple instance of : " script.Name, 3000)
                try {
                    WinClose(window)
                }
            }
        windows .= script.Name "`n"
    }
    SetTimer(, -ms)
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        SetTimer(check, 0)
}