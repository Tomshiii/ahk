; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Startup.ahk
; }

installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

start := Startup()
start.generate()
start.__Delete()
ExitApp()