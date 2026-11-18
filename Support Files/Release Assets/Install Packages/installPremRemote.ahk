; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Apps\docker.ahk
#Include Classes\errorLog.ahk
#Include Classes\cmd.ahk
#Include Classes\Apps\docker.ahk
#Include Classes\constants.ahk
; }

try ec := A_Args[1]
ec := IsSet(ec) ? ec : false

;// registry key required to run unsigned extensions within Premiere Pro
if RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode", "0") != "1"
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

if !FileExist(A_Appdata "\tomshi\installDir") {
    if !ec {
        ;// throw
        errorLog(TargetError("Installation did not complete correctly. Please uninstall and try again.", -1),,, 1)
        return
    }
    ExitApp(CONST.ErrorCode.REPO_INSTALL_FAIL)
}
installDir := FileRead(A_Appdata "\tomshi\installDir")
SetWorkingDir(installDir)

;//! This script will NOT complete without NodeJS already being installed
getNPM := RegRead("HKLM\SOFTWARE\Node.js", "Version", 0)
if !getNPM {
    if !ec {
        ;// throw
        errorLog(TargetError("NodeJS is not currently installed. Please install NodeJS before continuing.", -1),,, 1)
        return
    }
    ExitApp(CONST.ErrorCode.NODEJS_INSTALL_FAIL)
}

if !DirExist(A_AppData "\Adobe") {
    if !ec {
        ;// throw
        errorLog(TargetError("Adobe programs not installed. Extension installation will be aborted.", -1))
        return
    }
    ExitApp(CONST.ErrorCode.ADOBE_NOT_INSTALLED)
}

;// nothing is downloaded here. `generateUpdate.ahk` packages my local PremiereRemote/AERemote (CEP) and PremiereRemote-uxp
;// folders into `<installDir>\premiereRemote` and this script installs them from there
extensionsPath := A_AppData "\Adobe\CEP\extensions"
uxpPluginsPath := A_AppData "\Adobe\UXP\Plugins\External"
uxpCCXDir      := EnvGet("CommonProgramFiles") "\Adobe\UXP\Plugins\External"
stagingDir     := installDir "\premiereRemote"
cepStaging     := stagingDir "\cep"
uxpStaging     := stagingDir "\uxp\PremiereRemote-uxp"
updateUXP      := installDir "\Backups\Adobe Backups\Premiere\PremiereRemote\uxp\build\update_PremiereRemoteUXP.ahk"

if !DirExist(cepStaging) && !DirExist(uxpStaging) {
    if !ec {
        ;// throw
        errorLog(TargetError("PremiereRemote files could not be found. Please try the installation again.", -1),,, 1)
        return
    }
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_STAGING_NOT_FOUND)
}


;//* CEP - PremiereRemote & AERemote
;// `node_modules` isn't packaged so it gets built here
installCEP(name) {
    src := cepStaging "\" name
    dst := extensionsPath "\" name
    if !DirExist(src)
        return true
    DirCreate(extensionsPath)

    ;// /MIR copies new/changed files AND deletes anything in dst that isn't in src. `node_modules` is excluded so it's left alone
    code := RunWait(Format('robocopy "{1}" "{2}" /MIR /XD node_modules /R:1 /W:1 /NFL /NDL /NJH /NJS /NP', src, dst),, "Hide")
    if code >= 8 { ;// 8+ means at least one file failed to copy/delete, usually because Premiere/AE has it open
        if !ec {
            errorLog(TargetError("Couldn't update " name ". Please close Premiere Pro/After Effects, then run`n" installDir "\Support Files\Release Assets\Install Packages\installPremRemote.ahk", -1),,, 1)
            return false
        }
        ExitApp(CONST.ErrorCode.ADOBE_PROGRAM_OPEN)
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
; premOK  := installCEP("PremiereRemote")
premUXP := true
aeOK    := installCEP("AERemote")
if aeOK
    try DirDelete(cepStaging "\AERemote", 1)

;//* UXP - PremiereRemote-uxp
;// extracts the plugin folder. The `client` folder is removed after the .ccx gets installed by `update_PremiereRemoteUXP.ahk`
try {
    if !docker.isInstalled() {
        if !ec
            throw TargetError("Docker needs to be installed", -2)
        ExitApp(CONST.ErrorCode.DOCKER_NOT_INSTALLED)
    }
    uxpDst := uxpPluginsPath "\PremiereRemote-uxp"
    DirCreate(uxpPluginsPath)

    ;// /MIR copies new/changed files and removes stale ones. `node_modules` is excluded so it's left alone
    code := RunWait(Format('robocopy "{1}" "{2}" /MIR /XD node_modules /R:1 /W:1 /NFL /NDL /NJH /NJS /NP', uxpStaging, uxpDst),, "Hide")
    if code >= 8 { ;// 8+ means at least one file failed to copy/delete, usually because Premiere has it open
        if !ec
            throw OSError("robocopy failed (" code ") copying PremiereRemote-uxp")
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_ROBOCOPY_FAIL)
    }
    instPnpm := cmd.run(,,, "pnpm install", uxpDst "\client", "Hide")
    if instPnpm.exitCode != 0 {
        if !ec
            throw MethodError("Failed to install node modules", -1)
        ExitApp(CONST.ErrorCode.PNPM_INSTALL_FAILED)
    }

    ;// rebuild if files were copied (bit 1), stale files were removed (bit 2), or this is a fresh install
    if (code & 3) || !DirExist(uxpDst "\client\node_modules") {
        cmd.run(,,, 'node scripts/generate-api.js', uxpDst "\client", "Hide")
        cmd.run(,,, 'xcopy /s /e /y static\. build\', uxpDst "\client", "Hide")
        cmd.run(,,, 'npx pnpm run bundle', uxpDst "\client", "Hide")
        cmd.run(,,, 'docker compose down && docker compose up --build -d', uxpDst, "Hide")
    }

    ;// install ccx packages
    if FileExist(updateUXP) {
        updUXP := RunWait(updateUXP)
        if updUXP != CONST.ErrorCode.GENERIC_PASS && updUXP != CONST.ErrorCode.PREMIEREREMOTE_INSTALL_PASS && updUXP != CONST.ErrorCode.PREMIEREREMOTE_VER_LOWER {
            if !ec
                throw MethodError("Failed to install Premiere UXP plugin.", -1)
            ExitApp(updUXP)
        }
    }
    if !DirExist(uxpCCXDir) {
        if !ec
            throw MethodError("Failed to install Premiere UXP plugin.", -1)
       ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_FAIL)
    }

    ;// confirm Premiere will actually load the version we just staged
    if RegExMatch(FileRead(uxpDst "\client\manifest.json"), '"version"\s*:\s*"([^"]+)"', &m) {
        found := false
        loop files EnvGet("CommonProgramFiles") "\Adobe\UXP\Plugins\External\de.sebinside.premiereremote_*", "D" {
            if A_LoopFileName = "de.sebinside.premiereremote_" m[1] {
                found := true
                break
            }
        }
        if !found {
            if !ec
                throw TargetError("UXP plugin " m[1] " isn't installed. Premiere is still running the old plugin.", -1)
            ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_FAIL)
        }
    }
} catch as e {
    premUXP := false
    errorLog(e)
    if !ec
        throw e
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_FAIL)
}

;// only remove the packaged files for extensions that installed, a failed one is kept so it can be retried
if premUXP
    try DirDelete(uxpStaging, true)
if aeOK && premUXP
    try DirDelete(stagingDir, 1)

ExitApp(CONST.ErrorCode.GENERIC_PASS)