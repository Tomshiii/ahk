; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Functions\detect.ahk
#Include Classes\winExt.ahk
; }

try arg1 := A_Args[1]
try arg2 := A_Args[2]
hotkeylessTitle := IsSet(arg1) ? arg1 : "\\HotkeylessAHK\.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
ignore := IsSet(arg2) ? arg2 "|" A_ScriptName  : browser.vscode.winTitle "|" A_ScriptName "|My Scripts.ahk"
exists := winExt.ExistRegex(hotkeylessTitle,, ignore,, true)
if exists = false
    return
if winExt.CountRegex(hotkeylessTitle,, ignore,, true) <= 1 {
    try ProcessClose(winExt.PIDRegex("ahk_id " exists,, ignore,, true))
    catch as e {
        MsgBox("ProcessClose failed: " e.Message)
    }
    return
}
list := winExt.ListRegex(hotkeylessTitle,, ignore,, true)
for v in list {
    try ProcessClose(winExt.PIDRegex("ahk_id " v,, ignore,, true))
    catch as e {
        MsgBox("ProcessClose failed: " e.Message)
    }
}