if WinExist("User ahk_exe explorer.exe") {
    WinActivate("User ahk_exe explorer.exe")
    return
}

Run(A_AppData "\Code\User")
WinWait("User ahk_exe explorer.exe")
if !WinActive("User ahk_exe explorer.exe")
    WinActivate("User ahk_exe explorer.exe")