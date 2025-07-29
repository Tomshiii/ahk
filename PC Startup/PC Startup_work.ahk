#Warn VarUnset, StdOut
#Requires AutoHotkey v2.0
#Include *i <Classes\Settings>
#Include *i <Classes\ptf>
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
Run(ptf["HotkeylessAHK"])

;// run kleopatra
runKleopatra()
runKleopatra() {
    path := "C:\Program Files (x86)\Gpg4win\bin\kleopatra.exe"
    if !FileExist(path)
        return
    orig := detect()
    if WinExist("ahk_exe kleopatra.exe")
        ProcessClose(WinGetPID("ahk_exe kleopatra.exe"))
    Run(path,, "Hide")
    resetOrigDetect(orig)
}

;//backups
FileCopy(ptf.rootDir "\Support Files\Streamdeck Files\options.ini", ptf.rootDir "\Backups\Work\options.ini", 1)
FileCopy(ptf.rootDir "\lib\My Scripts\Windows.ahk", ptf.rootDir "\Backups\Work\Windows.ahk", 1)
FileCopy(ptf.rootDir "\lib\Classes\move.ahk", ptf.rootDir "\Backups\Work\move.ahk", 1)
FileCopy(ptf.rootDir "\lib\QMK\Work\Prem.ahk", ptf.rootDir "\Backups\Work\QMK\Work\Prem.ahk", 1)

deleteDotUnderscore("N:\")
syncDirectories()
Run(ptf.TimerScripts "\syncOnConnect.ahk")