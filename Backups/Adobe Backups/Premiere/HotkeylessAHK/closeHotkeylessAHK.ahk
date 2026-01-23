; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Functions\detect.ahk
#Include Classes\winExt.ahk
; }

title := "HotkeylessAHK.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
ignore := browser.vscode.winTitle "|" A_ScriptName
exists := winExt.ExistRegex(title,, ignore,, true)
if exists = false
    return
if winExt.CountRegex(title,, ignore) <= 1 {
    ProcessClose(winExt.PIDRegex(exists,, ignore))
    return
}
list := winExt.ListRegex(title,, ignore)
for v in list {
    ProcessClose(winExt.PIDRegex(v,, ignore))
}