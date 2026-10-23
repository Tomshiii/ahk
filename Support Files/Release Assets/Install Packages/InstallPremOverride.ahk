; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Startup.ahk
#Include Classes\errorLog.ahk
; }

if !FileExist(A_Appdata "\tomshi\installDir") {
    ;// throw
    errorLog(TargetError("Installation did not complete correctly. Please uninstall and try again.", -1),,, 1)
    return
}

;// attempt to set current adobe versions for the first time
installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

start := Startup()
start.adobeVerOverride()
start.__Delete()
ExitApp()