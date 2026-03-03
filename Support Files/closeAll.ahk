#SingleInstance Force
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\reset.ahk

try incChecklist := A_Args[1]

tool.Cust("All active ahk scripts are being CLOSED")
resetter := reset(false, false)
activeWindows := resetter.__getList()
; logger := Log()
for v in activeWindows {
    if !getInfo := resetter.__parseInfo(v, incChecklist ?? false)
        continue
    if getInfo.scriptName = "HotkeylessAHK.ahk" {
        resetter.__resetHotkeyless(true)
        continue
    }
    ; logger.Append("closing: " getInfo.scriptName)
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