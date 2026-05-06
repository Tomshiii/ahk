; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Settings.ahk
#Include Classes\ptf.ahk
#Include Classes\tool.ahk
#Include Classes\obj.ahk
#Include Classes\WM.ahk
#Include Classes\CLSID_Objs.ahk
#Include Functions\detect.ahk
#Include Functions\trayShortcut.ahk
#Include Multi-Instance Close\ignoreList.ahk
; }

#SingleInstance Force
ListLines(0)
KeyHistory(0)


TraySetIcon(ptf.Icons "\M-I_C.png")
;This script will check for and close scripts that have multiple instances open
;Even if you have #SingleInstance Force enabled, sometimes while reloading you can end up with a second instance of any given script, this script should hopefully negate that

startupTray()

UserSettings := CLSID_Objs.clone("UserSettings")
SetTimer(check, (UserSettings.multi_SEC * 1000))


onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA
multiRemoteStop := stopper()

class stopper {
    __remoteStop() {
        Persistent()
        try SetTimer(check, 0)
    }
}

check()
{
    value := winExt.ListRegex("ahk_class AutoHotkey",,,, true)
    windows := ""
    for window in value{
        try {
            newWin := WinGetTitle(window)
        }
        if !IsSet(newWin) || !IsSet(window)
            continue
        isScript := InStr(newWin, " -",,, 1)
        if !isScript
            continue
        script := obj.SplitPath(SubStr(newWin, 1, isScript -1))
        if InStr(windows, script.Name "`n", 1,, 1) && !ignorelist.Has(script.Name)
            {
                tool.Cust("Closing multiple instance of : " script.Name, 3000)
                try {
                    Critical()
                    ProcessClose(window)
                    window := winExt.ExistRegex(script.Name,,,, true)
                    if window {
                        try winExt.CloseRegex(window,,,, true)
                        ; try WinClose(hwnd)
                    }
                    Critical("Off")
                }
            }
        windows .= script.Name "`n"
    }
    windows := ""
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        try SetTimer(check, 0)
}