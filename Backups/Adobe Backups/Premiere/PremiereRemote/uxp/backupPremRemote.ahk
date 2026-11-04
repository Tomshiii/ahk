#Requires AutoHotkey v2.0

SplitPath(A_LineFile,, &currentDir)
origWorkingDir := A_WorkingDir
SetWorkingDir(currentDir)
dir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp\client\src\actions"

loop files dir "\*", "D" {
    if A_LoopFileName = "samples"
        continue
    if DirExist(A_WorkingDir "\" A_LoopFileName)
        DirDelete(A_WorkingDir "\" A_LoopFileName, true)
    DirCopy(A_LoopFileFullPath, A_WorkingDir "\" A_LoopFileName, true)
}

loop files dir "\*.ts", "F" {
    FileCopy(A_LoopFileFullPath, A_WorkingDir "\" A_LoopFileName, true)
}

A_WorkingDir := origWorkingDir