#Warn VarUnset, StdOut
#Requires AutoHotkey v2.0
#Include '%A_Appdata%\tomshi\lib'
#Include *i Classes\CLSID_Objs.ahk
#Include *i Classes\winExt.ahk
#Include *i Functions\isReload.ahk

if !ProcessExist("explorer.exe") {
    WinWait("explorer.exe")
    sleep 2000
}


if !FileExist(A_Appdata "\tomshi\installDir")
    return
installDir := FileRead(A_Appdata "\tomshi\installDir")

hotkeylessTitle := "\\Core Functionality\.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
ignore := "ahk_exe Code.exe"
if exists := winExt.ExistRegex(hotkeylessTitle,, ignore,, true) {
    try ProcessClose(winExt.PIDRegex("ahk_id " exists,, ignore,, true))
}

try Run(installDir "\Core Functionality.ahk")
catch {
    if !isReload()
        Reload()
}
if !CLSID_Objs.waitCoreFuncs(15) {
    sleep 2000
    try CLSID_Objs.load("Loading")
    catch {
        throw TimeoutError("Core Functionality.ahk failed to load in time")
    }
}

Run(installDir "\PC Startup\Tom\PC Startup.ahk")