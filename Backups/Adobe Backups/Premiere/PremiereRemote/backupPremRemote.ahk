#Requires AutoHotkey v2.0

SetWorkingDir(A_ScriptDir)
dir := A_AppData "\Adobe\CEP\extensions\PremiereRemote\host\src"

loop files dir "\*", "F" {
    FileCopy(A_LoopFileFullPath, A_WorkingDir "\" A_LoopFileName, 1)
}