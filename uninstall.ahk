#SingleInstance Force

userResponse := MsgBox("Are you sure you wish to continue?`n`nUninstalling will remove all user settings and custom files/changes to my scripts.`nIt is recommended you create a backup if you ever wish to reinstall.", "Do you wish to continue?", "4404")
if userResponse = "No"
    return

SplitPath(A_LineFile,, &currentDir)
RunWait(currentDir "\Support Files\closeAll.ahk")
docFolder := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Personal", EnvGet("USERPROFILE") "\Documents")
if DirExist(docFolder "\tomshi")
    DirDelete(docFolder "\tomshi", true)
if DirExist(A_AppData "\tomshi")
    DirDelete(A_AppData "\tomshi", true)
try DirDelete(currentDir, true)
catch {
    loop files currentDir "\*", "DF" {
        if A_LoopFileName = "uninstall.ahk"
            continue
        if InStr(A_LoopFileAttrib, "D") {
            DirDelete(A_LoopFileFullPath, true)
            continue
        }
        FileDelete(A_LoopFileFullPath)
    }
}
try FileDelete(A_LineFile)