; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\errorLog.ahk
#Include Classes\ptf.ahk
#Include Classes\cmd.ahk
#Include Functions\unzip.ahk
; }

;//! This script will NOT complete without NodeJS already being installed

;// this script must be called AFTER symlinks have been generated
;// it requires cmd { & unzip()
installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

getNPM := RegRead("HKLM\SOFTWARE\Node.js", "Version", 0)
if !getNPM {
    ;// throw
    errorLog(TargetError("NodeJS is not currently installed. Please install NodeJS before continuing.", -1),,, 1)
    return
}

downloadURl    := "https://github.com/sebinside/PremiereRemote/archive/refs/tags/v2.2.0.zip"
extensionsPath := A_AppData "\Adobe\CEP\extensions"
remotePath     := extensionsPath "\PremiereRemote"

if DirExist(remotePath) {
    /* if MsgBox("PremiereRemote appears to already be installed!`nWould you like to update .tsx files?`n`n(keep in mind this may override any custom functions you've created, but not updating may result in errors with my scripts.)`nIt is recommended you make a backup of the following directory:`n" A_AppData "\Adobe\CEP\extensions\PremiereRemote\host\src\",, 'YesNo Icon?') = "No"
        return */
    if FileExist(extensionsPath "\premExtract.zip")
        FileDelete(extensionsPath "\premExtract.zip")
    RunWait(ptf.rootDir "\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk false")
    RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk 0 1")
    return
}

;// registry key required to run unsigned extensions within Premiere Pro
RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

if !DirExist(remotePath)
    DirCreate(remotePath)
if !FileExist(extensionsPath "\premExtract.zip")
    Download(downloadURl, extensionsPath "\premExtract.zip")
;// unzip
unzip(extensionsPath "\premExtract.zip", extensionsPath "\.premRemoteExtract\")
DirMove(extensionsPath "\.premRemoteExtract\PremiereRemote-main", extensionsPath "\.premRemoteExtract\PremiereRemote", 1)
DirMove(extensionsPath "\.premRemoteExtract\PremiereRemote", extensionsPath, 1)
;// remove old files/dir
FileDelete(extensionsPath "\premExtract.zip")
DirDelete(extensionsPath "\.premRemoteExtract", 1)

;// build the project
cmd.run(,, false, "npm i", remotePath "\client", "Hide")
cmd.run(,, false, "npm i", remotePath "\host", "Hide")

;// then copy files from install
RunWait(ptf.rootDir "\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk false")
cmd.run(,, false, "npm run build", remotePath "\host", "Hide")
ExitApp()