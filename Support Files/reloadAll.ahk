#SingleInstance Force
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\reset.ahk
#Include Classes\pause.ahk

;// get list of open ahk scripts
;// get path of said scripts
;// close all scripts (leaving `Core Functionality.ahk` for last)
;// reopen Core Functionality
;// reopen other scripts
;// Pass commandline args to scripts to inform them if they are "reloading" or rerunning

Critical()
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

which := IsSet(doReset) ? "resetting" : "reloading"
tool.Cust(StrTitle(which) " all scripts...", 8000,,, 13)

for v in list {
    itemObj := resetter.__parseInfo(v, incChecklist ?? false)
    if !itemObj
        continue
    if itemObj.scriptName = "Core Functionality.ahk"
        continue
    listArr.Push(itemObj)
    if itemObj.scriptName = "HotkeylessAHK.ahk" {
        Run(ptf.Backups "\Adobe Backups\Premiere\HotkeylessAHK\closeHotkeylessAHK.ahk")
        continue
    }
    pause.pause(StrReplace(itemObj.scriptName, ".ahk", ""))
}

for v in listArr {
    __checkClose(v.PID, v.scriptName " ahk_class AutoHotkey")
}

if coreFunc := winExt.ExistRegex("Core Functionality.ahk ahk_class AutoHotkey",,,, true) {
    coreFuncObj := resetter.__parseInfo(coreFunc, incChecklist ?? false)
    ProcessClose(coreFunc)
    __checkClose(coreFunc, "Core Functionality.ahk ahk_class AutoHotkey")
}

if IsSet(coreFuncObj)
    Run(coreFuncObj.path)

sleep 1500
for v in listArr {
    Run(v.path A_Space (doReset ?? true))
}
tool.Cust("finished " which, 1500,,, 13)
Critical("Off")
tool.Wait(2)
ExitApp()