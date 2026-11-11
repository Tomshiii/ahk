#Requires AutoHotkey v2.0

SplitPath(A_LineFile,, &currentDir)
origWorkingDir := A_WorkingDir
SetWorkingDir(currentDir)
dir := A_AppData "\Adobe\CEP\extensions\AERemote\host\src"

loop files dir "\*", "F" {
    FileCopy(A_LoopFileFullPath, A_WorkingDir "\" A_LoopFileName, 1)
}

A_WorkingDir := origWorkingDir