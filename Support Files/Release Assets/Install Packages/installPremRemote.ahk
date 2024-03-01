#Include <Classes\errorLog>
#Include <Classes\ptf>
#Include <Classes\cmd>
#Include <Functions\unzip>

;//! This script will NOT complete without NodeJS already being installed

;// this script must be called AFTER symlinks have been generated
;// it requires cmd { & unzip()
SetWorkingDir(A_ScriptDir)
getNPM := cmd.result('powershell -c "Get-Command -Name npm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
if !getNPM {
    ;// throw
    errorLog(TargetError("NodeJS is not currently installed. Please install NodeJS before continuing.", -1),,, 1)
    return
}

;// registry key required to run unsigned extensions within Premiere Pro
if !RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.11", "PlayerDebugMode", 0)
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.11", "PlayerDebugMode")

downloadURl    := "https://github.com/sebinside/PremiereRemote/archive/refs/heads/main.zip"
extensionsPath := A_AppData "\Adobe\CEP\extensions"
remotePath     := extensionsPath "\PremiereRemote"
if !DirExist(remotePath)
    DirCreate(remotePath)
Download(downloadURl, extensionsPath "\premExtract.zip")
;// unzip
unzip(extensionsPath "\premExtract.zip", extensionsPath "\.premRemoteExtract\")
DirMove(extensionsPath "\.premRemoteExtract\PremiereRemote-main", remotePath, 1)
;// remove old files/dir
FileDelete(extensionsPath "\premExtract.zip")
DirDelete(extensionsPath "\.premRemoteExtract", 1)

;// build the project
cmd.run(,,, "npm i", remotePath "\client")
cmd.run(,,, "npm i", remotePath "\host")
cmd.run(,,, "npm run build", remotePath "\host")

;// then copy files from install
BackupLocation := ptf.rootDir "\Backups\Adobe Backups\Premiere\PremiereRemote"
loop files BackupLocation "\*.tsx" {
    FileCopy(A_LoopFileFullPath, remotePath "\host\src\" A_loopfilename, true)
}