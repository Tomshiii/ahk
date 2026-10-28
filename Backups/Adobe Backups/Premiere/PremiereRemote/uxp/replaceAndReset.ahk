; { \\ #Includes
#Include funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\CLSID_Objs.ahk
#Include Functions\getCCXVersion.ahk
#Include Other\JSON.ahk
; }

;// this script is designed for me -- if you installed my repo this script will not work correctly as your `\client` folder will be installed in a different location
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

;// ======= uxp =======
uxpAHK := "ahk_exe Adobe UXP Developer Tools.exe"
uxpFile := "C:\Program Files\Adobe\Adobe UXP Developer Tools\Adobe UXP Developer Tools.exe"
if !isCCx
    __runAndWait(uxpAHK, uxpFile)

RunWait("replacePremRemote.ahk false")
RunWait("resetBuild.ahk " isCCx)
if !isCCx
    RunWait("reloadDebugExt.ahk")