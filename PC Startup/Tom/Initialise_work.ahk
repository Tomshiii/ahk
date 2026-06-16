#Warn VarUnset, StdOut
#Requires AutoHotkey v2.0
#Include '%A_Appdata%\tomshi\lib'
#Include *i Classes\CLSID_Objs.ahk
#Include *i Functions\getLocalVer.ahk

if !ProcessExist("explorer.exe") {
    WinWait("explorer.exe")
    sleep 2000
}

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

;// set verson file
getVer := getLocalVer()
verFile := A_AppData "\tomshi\version"
if !FileExist(verFile) {
    FileAppend(getVer, verFile)
} else {
    currVer := FileRead(verFile)
    if VerCompare(getVer, currVer) > 0 {
        FileDelete(verFile)
        FileAppend(getVer, verFile)
    }
}

;// the rest
Run(installDir "\PC Startup\Tom\PC Startup_work.ahk")