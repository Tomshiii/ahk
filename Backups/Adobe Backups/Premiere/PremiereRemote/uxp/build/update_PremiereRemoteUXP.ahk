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

if !docker.isInstalled()
    ExitApp(CONST.ErrorCode.DOCKER_NOT_INSTALLED)

if !ver := getExtensionVersion() {
    RunWait(Format('"{1}\install_PremiereRemoteUXP.ahk" "{1}\de.sebinside.premiereremote_premierepro.ccx"', buildDir))
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_PASS)
}

manifest := JSON.parse(zip.readFile(buildDir "\de.sebinside.premiereremote_premierepro.ccx", "manifest.json"))
if VerCompare(manifest["version"], ver) <= 0
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_VER_LOWER)

if MsgBox("You will now be prompted for elevation a few times to uninstall/reinstall the PremiereRemote UXP extension.`n`nDo you wish to continue?",, "4 262144") = "no"
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_CANCEL)
uninst := RunWait(Format('"{1}\uninstall_PremiereRemoteUXP.ahk"', buildDir))
if uninst != CONST.ErrorCode.GENERIC_PASS
    ExitApp(uninst)

inst := RunWait(Format('"{1}\install_PremiereRemoteUXP.ahk" "{1}\de.sebinside.premiereremote_premierepro.ccx"', buildDir))
ExitApp(inst)