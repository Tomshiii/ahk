; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Startup.ahk
#Include Classes\CLSID_Objs.ahk
; }

installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

if !CLSID_Objs.waitCoreFuncs(2) {
    sleep 2000
    try CLSID_Objs.load("Loading")
    catch {
        throw TimeoutError("Core Functionality.ahk failed to load in time. Try reloading.")
    }
}

start := Startup()
start.generate()
start.__Delete()
ExitApp()