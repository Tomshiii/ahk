try override := A_Args[1]
try folder := A_Args[2]
installedPath := A_AppData "\Adobe\CEP\extensions\" (IsSet(folder) ? folder : "PremiereRemote")
which := (IsSet(folder) && InStr(folder, "AE") ? "AERemote" : "PremiereRemote")
SplitPath(A_LineFile,, &linePath)
SplitPath(linePath,, &premRemotePath)
SplitPath(premRemotePath,, &premPath)
SplitPath(premPath,, &adobePath)
aePath := adobePath "\After Effects\AERemote\cep\"
backupPath := (which = "PremiereRemote") ? linePath : aePath

if !DirExist(installedPath) {
    MsgBox(which " does not appear to be installed, the operation will abort.")
    return
}

if !IsSet(override) || (override != false && override != "false") {
    if warning := MsgBox("This operation will override the currently installed files. Do you wish to continue?", "Are you sure?", "4 Icon! 0x1000") = "No"
        return
}

if !DirExist(installedPath "\host\src")
    DirCreate(installedPath "\host\src")
loop files backupPath "\*.tsx", "F" {
    FileCopy(A_LoopFileFullPath, installedPath "\host\src\*.*", true)
}
if !DirExist(installedPath "\typings")
    DirCreate(installedPath "\typings")
loop files backupPath "\typings\*.ts", "F" {
    FileCopy(A_LoopFileFullPath, installedPath "\typings\*.*", true)
}
