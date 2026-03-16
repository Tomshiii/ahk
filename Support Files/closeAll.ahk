#SingleInstance Force
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\reset.ahk
#Include Classes\pause.ahk
#Include Classes\tool.ahk
#Include Classes\winExt.ahk

try incChecklist := A_Args[1]

tool.Cust("All active ahk scripts are being CLOSED")
resetter := reset(false, false)
activeWindows := resetter.__getList()
; logger := Log()
for v in activeWindows {
    if !getInfo := resetter.__parseInfo(v, incChecklist ?? false)
        continue
    if WM.timerScripts.Has(getInfo.scriptName) {
        justName := StrReplace(getInfo.scriptName, ".ahk", "",,, 1)
        justName := StrReplace(justName, A_Space, "_")
        try WM.Send_WM_COPYDATA(justName "_stop," WM.objName[justName], justName ".ahk")
    }
    if getInfo.scriptName = "HotkeylessAHK.ahk" {
        resetter.__resetHotkeyless(true)
        continue
    }
    ; logger.Append("closing: " getInfo.scriptName)
    pause.pause(StrReplace(getInfo.scriptName, ".ahk", ""), false)
    ProcessClose(getInfo.PID)
    if !checkPID := winExt.ExistRegex(getInfo.PID,, resetter.ignoreString,, true)
        continue
    try WinClose(checkPID)
}
Critical("Off")
tool.Wait()
mainScriptTitle := resetter.mainScript ".ahk ahk_class AutoHotkey"
coreFuncTitle   := "Core Functionality.ahk ahk_class AutoHotkey"
mainScriptHWND  := winExt.ExistRegex(mainScriptTitle,, resetter.ignoreString,, true)
coreFuncHWND    := winExt.ExistRegex(coreFuncTitle,, resetter.ignoreString,, true)
__checkClose(hwnd, title) {
    if hwnd {
        ProcessClose(hwnd)
        hwnd := winExt.ExistRegex(title,, resetter.ignoreString,, true)
        if hwnd {
            try WinClose(hwnd)
        }
    }
}
__checkClose(mainScriptHWND, mainScriptTitle)
__checkClose(coreFuncHWND, coreFuncTitle)