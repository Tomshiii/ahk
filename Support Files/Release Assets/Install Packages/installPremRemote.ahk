; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\errorLog.ahk
#Include Classes\cmd.ahk
; }

if !FileExist(A_Appdata "\tomshi\installDir") {
    ;// throw
    errorLog(TargetError("Installation did not complete correctly. Please uninstall and try again.", -1),,, 1)
    return
}
installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

;//! This script will NOT complete without NodeJS already being installed
getNPM := RegRead("HKLM\SOFTWARE\Node.js", "Version", 0)
if !getNPM {
    ;// throw
    errorLog(TargetError("NodeJS is not currently installed. Please install NodeJS before continuing.", -1),,, 1)
    return
}

if !DirExist(A_AppData "\Adobe") {
    ;// throw
    errorLog(TargetError("Adobe programs not installed. Extension installation will be aborted.", -1))
    return
}

;// nothing is downloaded here. `generateUpdate.ahk` packages my local PremiereRemote/AERemote (CEP) and PremiereRemote-uxp
;// folders into `<installDir>\premiereRemote` and this script installs them from there
extensionsPath := A_AppData "\Adobe\CEP\extensions"
uxpPluginsPath := A_AppData "\Adobe\UXP\Plugins\External"
stagingDir     := installDir "\premiereRemote"
cepStaging     := stagingDir "\cep"
uxpStaging     := stagingDir "\uxp\PremiereRemote-uxp"
updateUXP      := installDir "\Backups\Adobe Backups\Premiere\PremiereRemote\uxp\build\update_PremiereRemoteUXP.ahk"

if !DirExist(cepStaging) || !DirExist(uxpStaging) {
    ;// throw
    errorLog(TargetError("PremiereRemote files could not be found. Please try the installation again.", -1),,, 1)
    return
}

;// registry key required to run unsigned extensions within Premiere Pro
RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

;//* CEP - PremiereRemote & AERemote
;// `node_modules` isn't packaged so it gets built here
installCEP(name) {
    src := cepStaging "\" name
    dst := extensionsPath "\" name
    if !DirExist(src)
        throw TargetError("Error During " name " Installation. Files are missing.")
    DirCreate(extensionsPath)

    ;// /MIR copies new/changed files AND deletes anything in dst that isn't in src. `node_modules` is excluded so it's left alone
    code := RunWait(Format('robocopy "{1}" "{2}" /MIR /XD node_modules /R:1 /W:1 /NFL /NDL /NJH /NJS /NP', src, dst),, "Hide")
    if code >= 8 { ;// 8+ means at least one file failed to copy/delete, usually because Premiere/AE has it open
        errorLog(TargetError("Couldn't update " name ". Please close Premiere Pro/After Effects, then run`n" installDir "\Support Files\Release Assets\Install Packages\installPremRemote.ahk`nagain.", -1),,, 1)
        return false
    }

    ;// rebuild if files were copied (bit 1), stale files were removed (bit 2), or this is a fresh install
    if (code & 3) || !DirExist(dst "\client\node_modules") || !DirExist(dst "\host\node_modules") {
        cmd.run(,, false, "npm i", dst "\client", "Hide")
        cmd.run(,, false, "npm i", dst "\host", "Hide")
        cmd.run(,, false, "npm run build", dst "\host", "Hide")
    }
    RunWait(installDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk 0 1 " name)
    return true
}
premOK := installCEP("PremiereRemote")
aeOK   := installCEP("AERemote")

;//* UXP - PremiereRemote-uxp
;// extracts the plugin folder. The `client` folder is removed after the .ccx gets installed by `update_PremiereRemoteUXP.ahk`
DirCreate(uxpPluginsPath)
DirCopy(uxpStaging, uxpPluginsPath "\PremiereRemote-uxp", 1)
if FileExist(updateUXP)
    try RunWait(updateUXP)

;// only remove the packaged files for extensions that installed, a failed one is kept so it can be retried
if premOK
    try DirDelete(cepStaging "\PremiereRemote", 1)
if aeOK
    try DirDelete(cepStaging "\AERemote", 1)
if premOK && aeOK
    try DirDelete(stagingDir, 1) ;// also clears the leftover uxp files

ExitApp()