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

Run(ptf.rootDir "\Alex Scripts.ahk")
Run(ptf.TimerScripts "\Alt_menu_acceleration_DISABLER.ahk")
Run(ptf.TimerScripts "\autodismiss error.ahk")
;Run(A_WorkingDir "\Premiere_RightClick.ahk" ;#include(d) in main script now)
Run(ptf.TimerScripts "\autosave.ahk")
Run(ptf.TimerScripts "\Multi-Instance Close.ahk")
Run(ptf.TimerScripts "\premKeyCheck.ahk")
Run(ptf["textreplace"])