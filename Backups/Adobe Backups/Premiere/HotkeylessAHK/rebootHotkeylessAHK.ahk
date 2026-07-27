; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Classes\winext.ahk
#Include Classes\notifyExt.ahk
; }

try arg1 := A_Args[1]
try arg2 := A_Args[2]

canLaunch := (!FileExist(ptf['HotkeylessAHK'])) ? false : true
hotkeylessTitle := IsSet(arg1) ? arg1 : "HotkeylessAHK.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
ignore := IsSet(arg2) ? arg2 : browser.vscode.winTitle "|" A_ScriptName "|My Scripts.ahk"

if hotkeyHWND := winExt.ExistRegex(hotkeylessTitle,, ignore,, true)
    exists := true
if exists != true
    return
try ProcessClose(winExt.PIDRegex(hotkeyHWND,, ignore,, true))
stillExists := winExt.ExistRegex(hotkeylessTitle,, ignore,, true)
if stillExists {
    if !winExt.WaitCloseRegex(stillExists,, 3, ignore,, true) {
        MsgBox("HotkeylessAHK.ahk failed to close, it may have encountered an error", "Error")
        return
    }
}
if !canLaunch {
    MsgBox("HotkeylessAHK.ahk is not installed in the expected location.`n`nExpected dir: " ptf['HotkeylessAHK'])
    return
}
try Run(ptf['HotkeylessAHK'])
notifyExt.showIfNotExist("traymenuHotkeylessReboot",, 'HotkeylessAHK has been rebooted', 'C:\Windows\System32\imageres.dll|icon253',,, 'theme=Dark dur=4 bdr=Gray show=Fade@250 hide=Fade@250 maxW=400')