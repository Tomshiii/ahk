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

;// open settings instance
UserSettings := CLSID_Objs.load("UserSettings")
SetTimer(check, -50)

changeInterval := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, changeInterval.Bind())  ; 0x004A is WM_COPYDATA

check()
{
    static UserSettings := CLSID_Objs.load("UserSettings")
    value := winExt.ListRegex("ahk_class AutoHotkey",,,, true)
    windows := ""
    for window in value{
        try {
            newWin := WinGetTitle(window)
        }
        if !IsSet(newWin) || !IsSet(window)
            continue
        script := obj.SplitPath(SubStr(newWin, 1, InStr(newWin, " -",,, 1) -1))
        if InStr(windows, script.Name "`n", 1,, 1) && !ignorelist.Has(script.Name)
            {
                tool.Cust("Closing multiple instance of : " script.Name, 3000)
                try {
                    Critical()
                    orig := detect()
                    WinClose(window)
                    resetOrigDetect(orig)
                    Critical("Off")
                }
            }
        windows .= script.Name "`n"
    }
    windows := ""
    SetTimer(, -(UserSettings.multi_SEC * 1000))
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        SetTimer(check, 0)
}