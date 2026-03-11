#Warn VarUnset, StdOut
#Requires AutoHotkey v2.0
#Include '%A_Appdata%\tomshi\lib'
#Include *i Classes\Settings.ahk
#Include *i Classes\ptf.ahk
#Include *i Classes\CLSID_Objs.ahk
#Include *i Other\Notify\Notify.ahk
#Include *i Functions\syncDirectories.ahk
#Include *i Functions\notifyIfNotExist.ahk

;// if the user has not generated the symlink yet this script will return
try {
    UserSettings := CLSID_Objs.load("UserSettings")
}
if !IsSet(UserSettings)
    return

SetWorkingDir(ptf.rootDir)

Run(ptf.rootDir "\My Scripts.ahk")
Run(ptf.rootDir "\QMK Keyboard.ahk")
Run(ptf.TimerScripts "\Alt_menu_acceleration_DISABLER.ahk")
; Run(ptf.TimerScripts "\autodismiss error.ahk") ;// adobe added a toggle
;Run(A_WorkingDir "\Premiere_RightClick.ahk" ;#include(d) in main script now)
Run(ptf.TimerScripts "\autosave.ahk")
Run(ptf.TimerScripts "\adobe fullscreen check.ahk")
Run(ptf.TimerScripts "\gameCheck.ahk")
Run(ptf.TimerScripts "\Multi-Instance Close.ahk")
Run(ptf.TimerScripts "\premKeyCheck.ahk")

runApp(path, name, reboot := true) {
    if !FileExist(path)
        return false
    Critical()
    orig := detect()
    switch reboot {
        case true:
            if WinExist(name,, browser.vscode.winTitle)
                ProcessClose(WinGetPID(name,, browser.vscode.winTitle))
            Run(path,, "Hide")
        case false:
            if !WinExist(name,, browser.vscode.winTitle)
                Run(path,, "Hide")
    }
    resetOrigDetect(orig)
    Critical("Off")
    return true
}

;// I keep text replace in a different place to anyone else who uses this repo
if ptf.rootDir = "E:\Github\ahk" && A_UserName = "Tom" && A_ComputerName = "TomPC" && DirExist(ptf.SongQueue) { ;I'm really just trying to make sure the stars don't align and this line fires for someone other than me
    Run(ptf["textreplace"])
    runApp(ptf["HotkeylessAHK"], "HotkeylessAHK.ahk")
    syncDirectories()
    Run(ptf.TimerScripts "\syncOnConnect.ahk")
    ;// run kleopatra
    runApp("C:\Program Files (x86)\Gpg4win\bin\kleopatra.exe", "ahk_exe kleopatra.exe")

    try {
        for memory in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_PhysicalMemory") {
            mt := memory.ConfiguredClockSpeed
            if mt != ""
                break
        }
        if mt != "5600" {
            notifyIfNotExist("XMP",, 'XMP is currently NOT enabled. Ram is running at ' mt 'MT/s', 'C:\Windows\System32\imageres.dll|icon80',,, 'theme=Dark pos=CT dur=5 bdr=Red maxW=400')
        }
    }

    if refreshRate := cmd.result("powershell (Get-CimInstance -ClassName Win32_VideoController | Where-Object {$_.CurrentRefreshRate -ne $null} | Select-Object -First 1).CurrentRefreshRate") != "119" {
        MsgBox("Refresh rate may not be set correctly!`nIt is currently returning: " refreshRate)
    }

    return
}
else if FileExist(ptf["textreplaceUser"])
    Run(ptf["textreplaceUser"])

if FileExist(ptf["HotkeylessAHK"])
    Run(ptf["HotkeylessAHK"])