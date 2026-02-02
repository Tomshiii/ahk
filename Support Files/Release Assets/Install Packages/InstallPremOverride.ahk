; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Startup.ahk
; }

;// attempt to set current adobe versions for the first time
installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

start := Startup()
start.adobeVerOverride()
start.__Delete()
ExitApp()