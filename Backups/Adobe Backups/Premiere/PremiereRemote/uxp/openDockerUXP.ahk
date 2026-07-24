; { \\ #Includes
#Include shared\funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\notifyExt.ahk
#Include Other\UIA\UIA.ahk
; }

;// I don't use docker for anything else; if you do you may encounter issues with this script
;// as it's only currently designed to find the first "start" button and press it

;// ======= docker =======
dockerAhk := "ahk_exe Docker Desktop.exe"
dockerFile := "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if !__runAndWait(dockerAhk, dockerFile, false)
    return
if WinActive(dockerAhk) {
    try {
        dockerUIA := UIA.ElementFromHandle(dockerAhk,, false)
        dockerUIA.WaitElement({LocalizedType:"button", Name:"Start"}).invoke()
        winExt.MinimizeRegex(dockerAhk)
    }
}

;// ======= uxp =======
uxpAHK := "ahk_exe Adobe UXP Developer Tools.exe"
uxpFile := "C:\Program Files\Adobe\Adobe UXP Developer Tools\Adobe UXP Developer Tools.exe"
if !__runAndWait(uxpAHK, uxpFile, false)
    return

if !__startUXP() {
    notifyExt.showIfNotExist('uxpRebuildFailed',, "Failed to find UXP window")
    return
}