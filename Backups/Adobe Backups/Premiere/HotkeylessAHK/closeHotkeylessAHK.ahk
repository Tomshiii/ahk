#Include <Classes\ptf>
#Include <Functions\detect>

getorig := detect(, "RegEx")
title := "HotkeylessAHK.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
exists := false
ignore := browser.vscode.winTitle "|" A_ScriptName
if hotkeyHWND := WinExist(title,, ignore)
    exists := true
if exists = false {
    resetOrigDetect(getorig)
    return
}
if WinGetCount(title,, ignore) <= 1 {
    ProcessClose(WinGetPID(hotkeyHWND,, ignore))
    resetOrigDetect(getorig)
    return
}
list := WinGetList(title)
for v in list {
    ProcessClose(WinGetPID(v,, ignore))
}
resetOrigDetect(getorig)