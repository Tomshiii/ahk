; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Functions\unzip.ahk
; #Include Classes\winGet.ahk
#Include Classes\errorLog.ahk
#Include Classes\cmd.ahk
; }

;// downloads and installs; https://github.com/sebinside/HotkeylessAHK

;//! This script will NOT complete without NodeJS already being installed

;// this script must be called AFTER symlinks have been generated
;// it requires cmd { & unzip()
installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

getNPM := cmd.result('powershell -c "Get-Command -Name npm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
if !getNPM {
    ;// throw
    errorLog(TargetError("NodeJS is not currently installed. Please install NodeJS before continuing.", -1),,, 1)
    return
}

downloadURl      := "https://github.com/sebinside/HotkeylessAHK/archive/refs/heads/main.zip"
streamdeckPlugin := A_AppData "\Elgato\StreamDeck\Plugins\"
; dlLocation := WinGet.pathU(ptf.rootDir "\..\")
dlLocation := FileSelect("D3", A_WorkingDir, "Select Install Location for HotkeylessAHK")
if !dlLocation
    return

Download(downloadURl, dlLocation "hotkeylessExtract.zip")
;// unzip
unzip(dlLocation "hotkeylessExtract.zip", dlLocation ".hotkeylessExtract\")
dirName := ""
loop files dlLocation "\.hotkeylessExtract\*", "D" {
    DirMove(A_LoopFileFullPath, dlLocation A_LoopFileName)
    dirName := A_LoopFileName
}

;// remove old files/dir
FileDelete(dlLocation "hotkeylessExtract.zip")
DirDelete(dlLocation ".hotkeylessExtract", 1)

try {
    if FileExist(ptf.Backups "\Adobe Backups\Premiere\HotkeylessAHK\replaceHotkeyless.ahk")
        RunWait(ptf.Backups "\Adobe Backups\Premiere\HotkeylessAHK\replaceHotkeyless.ahk")
}

cmd.run(,,, "npm i", dlLocation dirName "\files")

DirMove(dlLocation dirName "\stream-deck-plugin\de.sebinside.hotkeylessahk.sdPlugin", streamdeckPlugin "de.sebinside.hotkeylessahk.sdPlugin", 1)