; { \\ #Includes
#Include shared\funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Other\JSON.ahk
; }

SetWorkingDir(A_ScriptDir)

;// ======= manifest =======
InstalledDir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp"
if FileExist(InstalledDir "\compose.yaml") && !InStr(FileRead(InstalledDir "\compose.yaml"), "restart: unless-stopped") {
    FileAppend("`t`trestart: unless-stopped", InstalledDir "\compose.yaml")
}
dir := InstalledDir "\client"
manifest := dir "\manifest.json"
if !FileExist(manifest)
    return
fil := json.parse(FileRead(manifest))
if fil['requiredPermissions']['localFileSystem'] != "fullAccess" {
    ;// full access is required for some functions to check if files exist (ie. `renderInPrem` to ensure it doesn't overwrite a file that already exists)
    fil['requiredPermissions']['localFileSystem'] := "fullAccess"
    FileAppend(json.stringify(fil), dir "\manifest_temp.json")
    FileDelete(manifest)
    FileMove(dir "\manifest_temp.json", manifest, true)
}

;// ======= docker =======
dockerAhk := "ahk_exe Docker Desktop.exe"
dockerFile := "C:\Program Files\Docker\Docker\Docker Desktop.exe"
__runAndWait(dockerAhk, dockerFile, true,, 0)

;// ======= uxp =======
uxpAHK := "ahk_exe Adobe UXP Developer Tools.exe"
uxpFile := "C:\Program Files\Adobe\Adobe UXP Developer Tools\Adobe UXP Developer Tools.exe"
__runAndWait(uxpAHK, uxpFile)

RunWait("replacePremRemote.ahk false")
Run("resetBuild.ahk")