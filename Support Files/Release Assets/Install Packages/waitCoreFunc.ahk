; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\CLSID_Objs.ahk
; }

if !CLSID_Objs.waitCoreFuncs(15) {
    sleep 2000
    try CLSID_Objs.load("Loading")
    catch {
        throw TimeoutError("Core Functionality.ahk failed to load in time")
    }
}

sleep 1000