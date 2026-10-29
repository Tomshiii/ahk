; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\zip.ahk
#Include Classes\errorLog.ahk
#Include Classes\docker.ahk
#Include Functions\getCCXVersion.ahk
#Include Other\JSON.ahk
; }

SplitPath(A_LineFile,, &buildDir)

if !docker.isInstalled() {
    e := TargetError("Docker needs to be installed to install UXP plugin", -1)
    errorLog(e)
    MsgBox(e.Message)
    ExitApp()
}

if !ver := getExtensionVersion() {
    RunWait(Format('"{1}\install_PremiereRemoteUXP.ahk" "{1}\de.sebinside.premiereremote_premierepro.ccx"', buildDir))
    return
}

manifest := JSON.parse(zip.readFile(buildDir "\de.sebinside.premiereremote_premierepro.ccx", "manifest.json"))
if VerCompare(manifest["version"], ver) <= 0
    return

if MsgBox("You will now be prompted for elevation a few times to uninstall/reinstall the PremiereRemote UXP extension.`n`nDo you wish to continue?",, "4 262144") = "no"
    return
RunWait(Format('"{1}\uninstall_PremiereRemoteUXP.ahk"', buildDir))
RunWait(Format('"{1}\install_PremiereRemoteUXP.ahk" "{1}\de.sebinside.premiereremote_premierepro.ccx"', buildDir))