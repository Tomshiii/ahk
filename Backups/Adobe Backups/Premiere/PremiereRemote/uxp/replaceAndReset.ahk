; { \\ #Includes
#Include funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\constants.ahk
#Include Classes\winGet.ahk
#Include Functions\getCCXVersion.ahk
#Include Functions\determineAdobeVer.ahk
#Include Other\JSON.ahk
; }

try isCCx := A_Args[1]
if !IsSet(isCCx) || isCCx = "unset"
    isCCx := getExtensionVersion()
try ec := A_Args[2]
ec := IsSet(ec) && ec != 0 && ec != "0" ? ec : false
try isAE_CCx := A_Args[3]
if !IsSet(isAE_CCx) || isAE_CCx = "unset"
    isAE_CCx := getExtensionVersion("AERemote")

if RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode", "0") != "1"
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

if !docker.isInstalled() {
    if !ec
        throw TargetError("Docker needs to be installed", -2)
    ExitApp(CONST.ErrorCode.DOCKER_NOT_INSTALLED)
}
SplitPath(A_LineFile,, &currentDir)
SetWorkingDir(currentDir)

;// ======= manifest =======
InstalledDir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp"
__replaceCompose()
dir := InstalledDir "\client"
manifest := dir "\manifest.json"
if FileExist(manifest) {
    fil := json.parse(FileRead(manifest))
    if fil['requiredPermissions']['localFileSystem'] != "fullAccess" || fil["entrypoints"][1]["label"]["default"] != "PremiereRemote" {
        ;// full access is required for some functions to check if files exist (ie. `renderInPrem` to ensure it doesn't overwrite a file that already exists)
        fil['requiredPermissions']['localFileSystem'] := "fullAccess"
        fil["entrypoints"][1]["label"]["default"] := "PremiereRemote"
        FileAppend(json.stringify(fil), dir "\manifest_temp.json")
        FileDelete(manifest)
        FileMove(dir "\manifest_temp.json", manifest, true)
    }
}

;// ======= docker =======
dockerAhk := "ahk_exe Docker Desktop.exe"
dockerFile := "C:\Program Files\Docker\Docker\Docker Desktop.exe"
__runAndWait(dockerAhk, dockerFile, true,, 0)

prReplace := RunWait("replacePremRemote.ahk false " ec)
if prReplace != CONST.ErrorCode.GENERIC_PASS
    ExitApp(prReplace)
aeDir := winget.PathU(currentDir "\..\..\..\After Effects\AERemote\uxp")
aeReplace := RunWait(aeDir "\replaceAERemote.ahk false " ec)
if aeReplace != CONST.ErrorCode.GENERIC_PASS
    ExitApp(aeReplace)
resetBuild := RunWait("resetBuild.ahk " isCCx A_Space isAE_CCx)
ExitApp(resetBuild)