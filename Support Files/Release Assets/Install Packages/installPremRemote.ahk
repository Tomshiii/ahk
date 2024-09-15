#Include <Classes\errorLog>
#Include <Classes\ptf>
#Include <Classes\cmd>
#Include <Functions\unzip>
#Include <GUIs\cepVer>

;//! This script will NOT complete without NodeJS already being installed

;// this script must be called AFTER symlinks have been generated
;// it requires cmd { & unzip()
SplitPath(A_LineFile,, &workDir)
SetWorkingDir(workDir "\..\..\..\")

getNPM := cmd.result('powershell -c "Get-Command -Name npm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
if !getNPM {
    ;// throw
    errorLog(TargetError("NodeJS is not currently installed. Please install NodeJS before continuing.", -1),,, 1)
    return
}

;// registry key required to run unsigned extensions within Premiere Pro
cepSelect := cepVer()
WinWait(cepSelect.Title)
WinWaitClose(cepSelect.Title)

downloadURl    := "https://github.com/sebinside/PremiereRemote/archive/refs/heads/main.zip"
extensionsPath := A_AppData "\Adobe\CEP\extensions"
remotePath     := extensionsPath "\PremiereRemote"

if DirExist(remotePath) {
    MsgBox("PremiereRemote appears to already be installed!`n`nExiting...")
    return
}

if !DirExist(remotePath)
    DirCreate(remotePath)
Download(downloadURl, extensionsPath "\premExtract.zip")
;// unzip
unzip(extensionsPath "\premExtract.zip", extensionsPath "\.premRemoteExtract\")
DirMove(extensionsPath "\.premRemoteExtract\PremiereRemote-main", extensionsPath "\.premRemoteExtract\PremiereRemote", 1)
DirMove(extensionsPath "\.premRemoteExtract\PremiereRemote", extensionsPath, 1)
;// remove old files/dir
FileDelete(extensionsPath "\premExtract.zip")
DirDelete(extensionsPath "\.premRemoteExtract", 1)

;// build the project
cmd.run(,,, "npm i", remotePath "\client")
cmd.run(,,, "npm i", remotePath "\host")

;// then copy files from install
BackupLocation := A_WorkingDir "\Backups\Adobe Backups\Premiere\PremiereRemote"
if !DirExist(remotePath "\host\src")
    DirCreate(remotePath "\host\src")
loop files BackupLocation "\*.tsx", "F" {
    FileCopy(A_LoopFileFullPath, remotePath "\host\src\" A_loopfilename, true)
}
cmd.run(,,, "npm run build", remotePath "\host")