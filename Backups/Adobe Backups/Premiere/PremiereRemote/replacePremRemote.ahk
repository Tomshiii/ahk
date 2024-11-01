installedPath := A_AppData "\Adobe\CEP\extensions\PremiereRemote"
SplitPath(A_LineFile,, &linePath)
backupPath := linePath

if !DirExist(installedPath) {
    MsgBox("PremiereRemote does not appear to be installed, the operation will abort.")
    return
}

if warning := MsgBox("This operation will override the currently installed files. Do you wish to continue?", "Are you sure?", "4 Icon! 0x1000") = "No"
    return

loop files backupPath "\*.tsx", "F" {
    FileCopy(A_LoopFileFullPath, installedPath "\host\src\*.*", true)
}
loop files backupPath "\typings\*.ts", "F" {
    FileCopy(A_LoopFileFullPath, installedPath "\typings\*.*", true)
}
