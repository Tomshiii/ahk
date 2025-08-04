SplitPath(A_LineFile,, &thisDir)
SetWorkingDir(thisDir)

#Include <Classes\winget>

hotkeylessFile := A_WorkingDir "\HotkeylessAHK.ahk"
desiredFolder := WinGet.pathU(A_WorkingDir "..\..\..\..\..\..\HotkeylessAHK-3.0.0")
if !DirExist(desiredFolder)
    return
FileCopy(hotkeylessFile, desiredFolder "\*.*", true)