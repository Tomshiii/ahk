#Warn VarUnset, StdOut
#Requires AutoHotkey v2.0
#Include '%A_Appdata%\tomshi\lib'
#Include *i Classes\Settings.ahk
#Include *i Classes\ptf.ahk
#Include *i Classes\CLSID_Objs.ahk
#Include *i Other\Notify\Notify.ahk
#Include *i Functions\deleteDotUnderscore.ahk
#Include *i Functions\syncDirectories.ahk
#Include *i Functions\notifyIfNotExist.ahk

;// if the user has not generated the symlink yet this script will return
try {
    UserSettings := CLSID_Objs.load("UserSettings")
}
if !IsSet(UserSettings)
    return

SetWorkingDir(ptf.rootDir)

Run(ptf.rootDir "\My Scripts.ahk")
Run(ptf.rootDir "\..\ahk_work\QMK Keyboard.ahk")
Run(ptf.TimerScripts "\Alt_menu_acceleration_DISABLER.ahk")
; Run(ptf.TimerScripts "\autodismiss error.ahk") ;// adobe added a toggle
;Run(A_WorkingDir "\Premiere_RightClick.ahk" ;#include(d) in main script now)
Run(ptf.TimerScripts "\autosave.ahk")
; Run(ptf.rootDir "\..\ahk_work\Timer Scripts\adobe fullscreen check.ahk")
Run(ptf.TimerScripts "\adobe fullscreen check.ahk")
Run(ptf.TimerScripts "\gameCheck.ahk")
Run(ptf.TimerScripts "\Multi-Instance Close.ahk")
Run(ptf.TimerScripts "\premKeyCheck.ahk")
Run(ptf["textreplace"])
runApp(ptf["HotkeylessAHK"], "HotkeylessAHK.ahk")

;// run kleopatra
if runApp("C:\Program Files (x86)\Gpg4win\bin\kleopatra.exe", "ahk_exe kleopatra.exe") = false
    runApp("C:\Program Files\Gpg4win\bin\kleopatra.exe", "ahk_exe kleopatra.exe")
runApp(path, name, reboot := true) {
    if !FileExist(path)
        return false
    Critical()
    orig := detect()
    switch reboot {
        case true:
            if WinExist(name,, browser.vscode.winTitle)
                ProcessClose(WinGetPID(name,, browser.vscode.winTitle))
            Run(path,, "Hide")
        case false:
            if !WinExist(name,, browser.vscode.winTitle)
                Run(path,, "Hide")
    }
    resetOrigDetect(orig)
    Critical("Off")
    return true
}

try {
    for memory in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_PhysicalMemory") {
        mt := memory.ConfiguredClockSpeed
        if mt != ""
            break
    }
    if mt != "5600" {
        notifyIfNotExist("XMP",, 'XMP is currently NOT enabled. Ram is running at ' mt 'MT/s', 'C:\Windows\System32\imageres.dll|icon80',,, 'theme=Dark pos=CT dur=5 bdr=Red maxW=400')
    }
}

;//backups
FileCopy(ptf.lib "\My Scripts\Not Editor.ahk", ptf.rootDir "\Backups\Work\Not Editor.ahk", 1)
FileCopy(ptf.lib "\Classes\move.ahk", ptf.rootDir "\Backups\Work\move.ahk", 1)
FileCopy(ptf.lib "\QMK\Work\Prem.ahk", ptf.rootDir "\Backups\Work\QMK\Work\Prem.ahk", 1)

; deleteDotUnderscore("N:\")
; syncDirectories()
; Run(ptf.TimerScripts "\syncOnConnect.ahk")