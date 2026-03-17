#SingleInstance Force
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\reset.ahk
#Include Classes\pause.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\WM.ahk
#Include Classes\winExt.ahk
#Include Classes\Editors\Premiere.ahk
#Include Functions\notifyIfNotExist.ahk
#Include Other\Notify\Notify.ahk

;// get list of open ahk scripts
;// get path of said scripts
;// close all scripts (leaving `Core Functionality.ahk` for last)
;// reopen Core Functionality
;// reopen other scripts
;// Pass commandline args to scripts to inform them if they are "reloading" or rerunning

Critical()
Notify.DestroyAll()
try incChecklist := A_Args[1]
try doReset := A_Args[2]
resetter := reset(false, false)
list := resetter.__getList()
listArr := []
coreFuncObj := unset
__checkClose(hwnd, title) {
    if hwnd {
        ProcessClose(hwnd)
        hwnd := winExt.ExistRegex(title,,,, true)
        if hwnd {
            try winExt.CloseRegex(hwnd,,,, true)
            ; try WinClose(hwnd)
        }
    }
}

which := IsSet(doReset) ? "Resetting" : "Reloading"
notifyIfNotExist("reloadAllAlert",, which ' all scripts...', 'C:\Windows\System32\shell32.dll|icon239', 'Windows Pop-up Blocked',, 'pos=TL dur=6 bc=0x131E2D bdr=0x00009B iw=24 maxW=400')
prem.resetCoreFuncVals()
for v in list {
    itemObj := resetter.__parseInfo(v, incChecklist ?? false)
    if !itemObj
        continue
    if itemObj.scriptName = "Core Functionality.ahk"
        continue
    listArr.Push(itemObj)
    if WM.timerScripts.Has(itemObj.scriptName) {
        justName := StrReplace(itemObj.scriptName, ".ahk", "",,, 1)
        justName := StrReplace(justName, A_Space, "_")
        try WM.Send_WM_COPYDATA(justName "_stop," WM.timerScripts[itemObj.scriptName], itemObj.scriptName)
    }
    if itemObj.scriptName = "HotkeylessAHK.ahk" {
        Run(ptf.Backups "\Adobe Backups\Premiere\HotkeylessAHK\closeHotkeylessAHK.ahk")
        continue
    }
    try pause.pause(StrReplace(itemObj.scriptName, ".ahk", ""), false)
}

for v in listArr {
    __checkClose(v.PID, v.scriptName " ahk_class AutoHotkey")
}

if coreFunc := winExt.ExistRegex("Core Functionality.ahk ahk_class AutoHotkey",,,, true) {
    coreFuncObj := resetter.__parseInfo(coreFunc, incChecklist ?? false)
    if !IsSet(coreFuncObj) {
        if Notify.Exist("reloadAllAlert")
            try Notify.Destroy("reloadAllAlert")
        throw TargetError("Could not determine ``Core Functionality.ahk``")
    }
    ProcessClose(coreFunc)
    __checkClose(coreFunc, "Core Functionality.ahk ahk_class AutoHotkey")
}

Run(coreFuncObj.path)

if !CLSID_Objs.waitCoreFuncs(2) {
    sleep 2000
    try CLSID_Objs.load("Loading")
    catch {
        if Notify.Exist("reloadAllAlert")
            try Notify.Destroy("reloadAllAlert")
        throw TimeoutError("Core Functionality.ahk failed to load in time")
    }
}
for v in listArr {
    Run(v.path A_Space (doReset ?? true))
}

Critical("Off")

SetTimer(destroyAlert, -3000)
destroyAlert(*) {
    if Notify.Exist("reloadAllAlert")
        try Notify.Destroy("reloadAllAlert")
    ExitApp()
}