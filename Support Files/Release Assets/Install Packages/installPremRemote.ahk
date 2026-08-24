; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\errorLog.ahk
#Include Classes\ptf.ahk
#Include Classes\cmd.ahk
#Include Functions\unzip.ahk
; }

;//! This script will NOT complete without NodeJS already being installed
installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

getNPM := RegRead("HKLM\SOFTWARE\Node.js", "Version", 0)
if !getNPM {
    ;// throw
    errorLog(TargetError("NodeJS is not currently installed. Please install NodeJS before continuing.", -1),,, 1)
    return
}

remoteVersion  := "2.2.0"
downloadURl    := "https://github.com/sebinside/PremiereRemote/archive/refs/tags/v" remoteVersion ".zip"
AE_dlURL       := "https://github.com/Tomshiii/PremiereRemote/archive/refs/heads/AE.zip"
extensionsPath := A_AppData "\Adobe\CEP\extensions"
remotePath     := extensionsPath "\PremiereRemote"
aeRemotePath   := extensionsPath "\AERemote"
remoteFolder   := extensionsPath "\.premRemoteExtract\PremiereRemote-" remoteVersion
AEremoteFolder   := extensionsPath "\.aeRemoteExtract\PremiereRemote-AE"


replaceRemote(remotePath, extensionsPath, replacePath, resetPath, extract) {
    if DirExist(remotePath) {
        if FileExist(extensionsPath "\" extract ".zip")
            FileDelete(extensionsPath "\" extract ".zip")
        RunWait(replacePath)
        RunWait(resetPath)
        return
    }
}

replaceRemote(remotePath, extensionsPath, ptf.rootDir "\Backups\Adobe Backups\Premiere\PremiereRemote\cep\replacePremRemote.ahk false", ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk 0 1", "premExtract")
replaceRemote(aeRemotePath, extensionsPath, ptf.rootDir "\Backups\Adobe Backups\Premiere\PremiereRemote\cep\replacePremRemote.ahk false AERemote", ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk 0 1 AERemote", "aeExtract")

;// registry key required to run unsigned extensions within Premiere Pro
RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

if !DirExist(remotePath)
    DirCreate(remotePath)
if !FileExist(extensionsPath "\premExtract.zip")
    Download(downloadURl, extensionsPath "\premExtract.zip")
if !FileExist(extensionsPath "\aeExtract.zip")
    Download(AE_dlURL, extensionsPath "\aeExtract.zip")
;// unzip
unzip(extensionsPath "\premExtract.zip", extensionsPath "\.premRemoteExtract\")
unzip(extensionsPath "\aeExtract.zip", extensionsPath "\.aeRemoteExtract\")
if !DirExist(remoteFolder)
    throw TargetError("Error During PremiereRemote Installation. Incorrect version")
if !DirExist(AEremoteFolder)
    throw TargetError("Error During AERemote Installation. Incorrect version")
;// prem
DirMove(remoteFolder, extensionsPath "\.premRemoteExtract\PremiereRemote", 1)
DirMove(extensionsPath "\.premRemoteExtract\PremiereRemote", extensionsPath, 1)
;// ae
DirMove(AEremoteFolder, extensionsPath "\.aeRemoteExtract\AERemote", 1)
DirMove(extensionsPath "\.aeRemoteExtract\AERemote", extensionsPath, 1)

;// remove old files/dir
FileDelete(extensionsPath "\premExtract.zip")
FileDelete(extensionsPath "\aeExtract.zip")
DirDelete(extensionsPath "\.premRemoteExtract", 1)
DirDelete(extensionsPath "\.aeRemoteExtract", 1)

;// build the project
cmd.run(,, false, "npm i", remotePath "\client", "Hide")
cmd.run(,, false, "npm i", remotePath "\host", "Hide")

cmd.run(,, false, "npm i", aeRemotePath "\client", "Hide")
cmd.run(,, false, "npm i", aeRemotePath "\host", "Hide")

;// then copy files from install
RunWait(ptf.rootDir "\Backups\Adobe Backups\Premiere\PremiereRemote\cep\replacePremRemote.ahk false")
RunWait(ptf.rootDir "\Backups\Adobe Backups\Premiere\PremiereRemote\cep\replacePremRemote.ahk 0 AERemote")
cmd.run(,, false, "npm run build", remotePath "\host", "Hide")
cmd.run(,, false, "npm run build", aeRemotePath "\host", "Hide")
ExitApp()