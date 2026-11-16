; { \\ #Includes
#Include funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Functions\getCCXVersion.ahk
#Include Functions\determineAdobeVer.ahk
#Include Other\JSON.ahk
; }

if RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode", "0") != "1"
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

if !docker.isInstalled()
    throw TargetError("Docker needs to be installed", -2)
try isCCx := A_Args[1]
if !IsSet(isCCx)
    isCCx := getExtensionVersion()
SetWorkingDir(A_ScriptDir)

;// ======= manifest =======
InstalledDir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp"
__replaceCompose()
dir := InstalledDir "\client"
manifest := dir "\manifest.json"
if FileExist(manifest) {
    fil := json.parse(FileRead(manifest))
    if fil['requiredPermissions']['localFileSystem'] != "fullAccess" || fil["entrypoints"][1]["label"]["default"] != "PremiereRemote (UXP)" {
        ;// full access is required for some functions to check if files exist (ie. `renderInPrem` to ensure it doesn't overwrite a file that already exists)
        fil['requiredPermissions']['localFileSystem'] := "fullAccess"
        fil["entrypoints"][1]["label"]["default"] := "PremiereRemote (UXP)"
        FileAppend(json.stringify(fil), dir "\manifest_temp.json")
        FileDelete(manifest)
        FileMove(dir "\manifest_temp.json", manifest, true)
    }
}

;// ======= docker =======
dockerAhk := "ahk_exe Docker Desktop.exe"
dockerFile := "C:\Program Files\Docker\Docker\Docker Desktop.exe"
__runAndWait(dockerAhk, dockerFile, true,, 0)

RunWait("replacePremRemote.ahk false")
RunWait("resetBuild.ahk " isCCx)