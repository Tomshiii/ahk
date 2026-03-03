#Warn VarUnset, StdOut
#Requires AutoHotkey v2.0
#Include '%A_Appdata%\tomshi\lib'
#Include *i Classes\CLSID_Objs.ahk

if !FileExist(A_Appdata "\tomshi\installDir")
    return
installDir := FileRead(A_Appdata "\tomshi\installDir")

Run(installDir "\Core Functionality.ahk")
if !CLSID_Objs.waitCoreFuncs(2) {
    sleep 2000
    try CLSID_Objs.load("Loading")
    catch {
        throw TimeoutError("Core Functionality.ahk failed to load in time")
    }
}

Run(installDir "\PC Startup\Tom\PC Startup_work.ahk")