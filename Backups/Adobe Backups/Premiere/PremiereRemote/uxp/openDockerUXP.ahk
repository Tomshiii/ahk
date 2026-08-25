; { \\ #Includes
#Include shared\funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\notifyExt.ahk
#Include Other\UIA\UIA.ahk
; }

;// this script may fail to open the UXP developer tools program if run with debugging through vscode

;// I don't use docker for anything else; if you do you may encounter issues with this script
;// as it's only currently designed to find the first "start" button and press it

dockerAhk := "ahk_exe Docker Desktop.exe"
dockerFile := "C:\Program Files\Docker\Docker\Docker Desktop.exe"
uxpAHK := "ahk_exe Adobe UXP Developer Tools.exe"
uxpFile := "C:\Program Files\Adobe\Adobe UXP Developer Tools\Adobe UXP Developer Tools.exe"


;// ======= docker =======
if !__runAndWait(dockerAhk, dockerFile, false,, 0)
    return
;// ======= uxp =======
if !__runAndWait(uxpAHK, uxpFile, false,, 0)
    return

;// ======= docker =======
if WinWait(dockerAhk,, 3) {
    WinActivate(dockerAhk)
    try {
        dockerUIA := UIA.ElementFromHandle(dockerAhk,, false)
        try dockerUIA.FindElement({Type:50000, Name:"Stop"})
        catch {
            dockerUIA.WaitElement({Type:50000, Name:["Start", "Run"]}, 10000).invoke()
        }
        winExt.MinimizeRegex(dockerAhk)
    }
}


;// ======= uxp =======
if !__startUXP() {
    notifyExt.showIfNotExist('uxpRebuildFailed',, "Failed to find UXP window")
    return
}