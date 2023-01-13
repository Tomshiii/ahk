#Include "%A_ScriptDir%\..\lib\Classes\ptf.ahk"
;// the user might not have created the symlink yet so we have to hardcode this one include

SetWorkingDir(ptf.rootDir)

Run(ptf.rootDir "\My Scripts.ahk")
Run(ptf.rootDir "\QMK Keyboard.ahk")
Run(ptf.TimerScripts "\Alt_menu_acceleration_DISABLER.ahk")
Run(ptf.TimerScripts "\autodismiss error.ahk")
;Run(A_WorkingDir "\right click premiere.ahk" ;#include(d) in main script now)
Run(ptf.TimerScripts "\autosave.ahk")
Run(ptf.TimerScripts "\adobe fullscreen check.ahk")
Run(ptf.TimerScripts "\gameCheck.ahk")
Run(ptf.TimerScripts "\Multi-Instance Close.ahk")
Run(ptf.TimerScripts "\premKeyCheck.ahk")
;// I keep text replace in a different place to anyone else who uses this repo
if ptf.rootDir = "E:\Github\ahk" && A_UserName = "Tom" && A_ComputerName = "TOM" && DirExist(ptf.SongQueue) ;I'm really just trying to make sure the stars don't align and this line fires for someone other than me
    Run(ptf["textreplace"])
else
    Run(ptf["textreplaceUser"])