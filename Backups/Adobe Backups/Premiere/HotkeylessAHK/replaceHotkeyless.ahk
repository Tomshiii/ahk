SplitPath(A_LineFile,, &thisDir)
SetWorkingDir(thisDir)

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\winget.ahk
; }

hotkeylessFile := A_WorkingDir "\HotkeylessAHK.ahk"
desiredFolder := WinGet.pathU(A_WorkingDir "..\..\..\..\..\..\HotkeylessAHK-3.0.0")
if !DirExist(desiredFolder)
    return
FileCopy(hotkeylessFile, desiredFolder "\*.*", true)