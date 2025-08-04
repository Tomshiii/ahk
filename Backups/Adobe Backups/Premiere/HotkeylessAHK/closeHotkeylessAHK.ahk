#Include <Classes\ptf>
#Include <Functions\detect>

getorig := detect()
if WinExist("HotkeylessAHK.ahk",, browser.vscode.winTitle)
    ProcessClose(WinGetPID("HotkeylessAHK.ahk",, browser.vscode.winTitle))
resetOrigDetect(getorig)