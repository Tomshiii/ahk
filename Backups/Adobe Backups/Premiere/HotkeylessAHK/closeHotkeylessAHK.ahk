#Include <Classes\ptf>
#Include <Functions\detect>
#Include <Classes\winGet>

title := "HotkeylessAHK.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
ignore := browser.vscode.winTitle "|" A_ScriptName
exists := WinGet.ExistRegex(title,, ignore)
if exists = false
    return
if WinGet.CountRegex(title,, ignore) <= 1 {
    ProcessClose(winget.PIDRegex(exists,, ignore))
    return
}
list := WinGet.ListRegex(title,, ignore)
for v in list {
    ProcessClose(winget.PIDRegex(v,, ignore))
}