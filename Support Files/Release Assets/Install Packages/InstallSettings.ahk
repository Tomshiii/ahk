; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\settings.ahk
; }

installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

UserSettings := UserPref(true)
UserSettings.__delAll()
ExitApp()