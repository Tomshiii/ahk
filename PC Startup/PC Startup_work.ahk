#Warn VarUnset, StdOut
#Requires AutoHotkey v2.0
#Include *i <Classes\Settings>
#Include *i <Classes\ptf>
#Include *i <Other\Notify\Notify>
#Include *i <Functions\deleteDotUnderscore>
#Include *i <Functions\syncDirectories>

;// if the user has not generated the symlink yet this script will return
try {
    UserSettings := UserPref()
}
if !IsSet(UserSettings)
    return

SetWorkingDir(ptf.rootDir)

Run(ptf.rootDir "\My Scripts.ahk")
Run(ptf.rootDir "\..\ahk_work\QMK Keyboard.ahk")
Run(ptf.TimerScripts "\Alt_menu_acceleration_DISABLER.ahk")
Run(ptf.TimerScripts "\autodismiss error.ahk")
;Run(A_WorkingDir "\Premiere_RightClick.ahk" ;#include(d) in main script now)
Run(ptf.TimerScripts "\autosave.ahk")
Run(ptf.rootDir "\..\ahk_work\Timer Scripts\adobe fullscreen check.ahk")
Run(ptf.TimerScripts "\gameCheck.ahk")
Run(ptf.TimerScripts "\Multi-Instance Close.ahk")
Run(ptf.TimerScripts "\premKeyCheck.ahk")
Run(ptf["textreplace"])
runApp(ptf["HotkeylessAHK"], "HotkeylessAHK.ahk")

;// run kleopatra
runApp("C:\Program Files (x86)\Gpg4win\bin\kleopatra.exe", "ahk_exe kleopatra.exe")
runApp(path, name) {
    if !FileExist(path)
        return
    orig := detect()
    if WinExist(name,, browser.vscode.winTitle)
        ProcessClose(WinGetPID(name,, browser.vscode.winTitle))
    Run(path,, "Hide")
    resetOrigDetect(orig)
}

try {
    for memory in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_PhysicalMemory") {
        mt := memory.ConfiguredClockSpeed
        if mt != ""
            break
    }
    if mt != "5600" {
        Notify.Show(, 'XMP is currently NOT enabled. Ram is running at ' mt 'MT/s', 'C:\Windows\System32\imageres.dll|icon80',,, 'theme=Dark pos=CT dur=5 bdr=Red maxW=400')
    }
}

;//backups
FileCopy(ptf.rootDir "\Support Files\Streamdeck Files\options.ini", ptf.rootDir "\Backups\Work\options.ini", 1)
FileCopy(ptf.rootDir "\lib\My Scripts\Not Editor.ahk", ptf.rootDir "\Backups\Work\Not Editor.ahk", 1)
FileCopy(ptf.rootDir "\lib\Classes\move.ahk", ptf.rootDir "\Backups\Work\move.ahk", 1)
FileCopy(ptf.rootDir "\lib\QMK\Work\Prem.ahk", ptf.rootDir "\Backups\Work\QMK\Work\Prem.ahk", 1)

deleteDotUnderscore("N:\")
syncDirectories()
Run(ptf.TimerScripts "\syncOnConnect.ahk")