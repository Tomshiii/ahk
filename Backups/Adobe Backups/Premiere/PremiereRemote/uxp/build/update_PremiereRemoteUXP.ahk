; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\zip.ahk
#Include Classes\errorLog.ahk
#Include Classes\Apps\docker.ahk
#Include Classes\constants.ahk
#Include Functions\getCCXVersion.ahk
#Include Other\JSON.ahk
; }

SplitPath(A_LineFile,, &buildDir)

premCCX := buildDir "\de.sebinside.premiereremote_premierepro.ccx"
aeCCX   := ptf.Backups "\Adobe Backups\After Effects\AERemote\UXP\build\de.sebinside.aeremote_ae.ccx"
if !FileExist(premCCX) || !FileExist(aeCCX)
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_CCX_NOT_FOUND)

if !docker.isInstalled()
    ExitApp(CONST.ErrorCode.DOCKER_NOT_INSTALLED)

installScript := Format('"{1}\install_PremiereRemoteUXP.ahk" 1', buildDir)
premVer := getExtensionVersion()
aeVer   := getExtensionVersion("AERemote")

;// nothing installed yet
if !premVer && !aeVer {
    inst := RunWait(installScript)
    ExitApp(inst = CONST.ErrorCode.GENERIC_PASS ? CONST.ErrorCode.PREMIEREREMOTE_INSTALL_PASS : inst)
}

;// something is installed - update if either extension is missing or older than the bundled .ccx
premNew := JSON.parse(zip.readFile(premCCX, "manifest.json"))["version"]
aeNew   := JSON.parse(zip.readFile(aeCCX, "manifest.json"))["version"]
needsUpdate := !premVer || !aeVer
            || VerCompare(premNew, premVer) > 0
            || VerCompare(aeNew, aeVer) > 0
if !needsUpdate
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_VER_LOWER)

if MsgBox("You will now be prompted for elevation a few times to uninstall/reinstall the PremiereRemote and AERemote UXP extensions.`n`nDo you wish to continue?",, "4 262144") = "no"
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_CANCEL)
uninst := RunWait(Format('"{1}\uninstall_PremiereRemoteUXP.ahk"', buildDir))
if uninst != CONST.ErrorCode.GENERIC_PASS
    ExitApp(uninst)

ExitApp(RunWait(installScript))