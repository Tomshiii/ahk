; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Other\JSON.ahk
; }

SetWorkingDir(A_ScriptDir)

;// ======= manifest =======
dir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp"
manifest := dir "\manifest.json"
if !FileExist(manifest)
    return
fil := json.parse(FileRead(manifest))
if fil['requiredPermissions']['localFileSystem'] != "fullAccess" {
    ;// full access is required for some functions to check if files exist (ie. `renderInPrem` to ensure it doesn't overwrite a file that already exists)
    fil['requiredPermissions']['localFileSystem'] := "fullAccess"
    FileAppend(json.stringify(fil), dir "\manifest_temp.json")
    FileDelete(manifest)
    FileMove(dir "\manifest_temp.json", manifest)
}

;// ======= docker =======
dockerAhk := "ahk_exe Docker Desktop.exe"
dockerFile := "C:\Program Files\Docker\Docker\Docker Desktop.exe"
__runAndWait(dockerAhk, dockerFile)

;// ======= uxp =======
uxpAHK := "ahk_exe Adobe UXP Developer Tools.exe"
uxpFile := "C:\Program Files\Adobe\Adobe UXP Developer Tools\Adobe UXP Developer Tools.exe"
__runAndWait(uxpAHK, uxpFile)

RunWait("replacePremRemote.ahk false")
Run("resetBuild.ahk")



;// ================================================

__runAndWait(ahkExe, filepath, minimise := true, timeout := 3, sleepTime := 5000) {
    if !WinExist(ahkExe) {
        if !FileExist(filepath)
            return
        Run(filepath)
        if !WinWait(ahkExe,, timeout)
            return
        sleep sleepTime ;// needs time to boot
        if minimise {
            try WinMinimize(ahkExe)
        }
    }
}