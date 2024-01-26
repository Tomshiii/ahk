#Warn VarUnset, StdOut
#Requires AutoHotkey v2.0
#Include *i <Classes\Settings>
#Include *i <Classes\ptf>

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

;//backups
FileCopy(ptf.rootDir "\Support Files\Streamdeck Files\options.ini", ptf.rootDir "\Backups\Work\options.ini", 1)
FileCopy(ptf.rootDir "\lib\My Scripts\Windows.ahk", ptf.rootDir "\Backups\Work\Windows.ahk", 1)
FileCopy(ptf.rootDir "\lib\Classes\Apps\Discord.ahk", ptf.rootDir "\Backups\Work\Discord.ahk", 1)