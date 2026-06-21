installedPath := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp"
SplitPath(A_LineFile,, &linePath)
backupPath := linePath

if !DirExist(installedPath) {
    MsgBox("PremiereRemote does not appear to be installed, the operation will abort.")
    return
}

try override := A_Args[1]
if !IsSet(override) || (override != false && override != "false") {
    if warning := MsgBox("This operation will override the currently installed files. Do you wish to continue?", "Are you sure?", "4 Icon! 0x1000") = "No"
        return
}

if !DirExist(installedPath "\src\actions")
    DirCreate(installedPath "\src\actions")
loop files backupPath "\*.ts", "F" {
    FileCopy(A_LoopFileFullPath, installedPath "\src\actions\*.*", true)
}