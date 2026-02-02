; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\settings.ahk
; }

installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

UserSettings := UserPref(true)
if UserSettings.working_dir != A_WorkingDir
    UserSettings.working_dir := A_WorkingDir
UserSettings.__delAll()