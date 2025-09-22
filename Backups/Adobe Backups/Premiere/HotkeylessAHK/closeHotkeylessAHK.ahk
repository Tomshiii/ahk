#Include <Classes\ptf>
#Include <Functions\detect>

getorig := detect()
if WinExist("HotkeylessAHK.ahk",, "- Visual Studio Code " browser.vscode.winTitle)
    ProcessClose(WinGetPID("HotkeylessAHK.ahk",, "- Visual Studio Code " browser.vscode.winTitle))
resetOrigDetect(getorig)