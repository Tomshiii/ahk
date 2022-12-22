SetWorkingDir(A_ScriptDir)

if !DirExist(A_MyDocuments "\AutoHotkey")
    DirCreate(A_MyDocuments "\AutoHotkey")

ahklib := A_MyDocuments '\AutoHotkey\Lib'
path := A_ScriptDir '\..\..\Lib'
temp := false

cmdLine := Format('mklink /D `"{}`" `"{}`"'
                  , ahklib, path)
;final command should look like;
; mklink /D "mydocumentspathhere\AutoHotkey\Lib" "rootrepopath\lib"

if DirExist(ahklib)
    {
        SetTimer(change_buttonNames, 15)
        change_buttonNames() {
            if !WinExist("Backup lib files")
                return
            SetTimer(, 0)
            WinActivate("Backup lib files")
            ControlSetText "&Continue", "Button1"
        }
        warn := MsgBox("This script will delete your entire lib folder found here:`n" A_MyDocuments "\AutoHotkey\Lib`n`nIf you use files other than mine, this script will attempt to place them in a backup folder but it's best to not rely on this and back them up yourself.`n`nDo you wish to continue?.", "Backup lib files", "1 48 256 4096")
        if warn = "Cancel"
            return
        try {
            if !DirExist(A_Temp "\tomshi")
                DirCreate(A_Temp "\tomshi")
            DirMove(ahklib, A_Temp "\tomshi\UserBackup", 1)
            temp := true
            if DirExist(ahklib)
                DirDelete(ahklib, 1)
        }
    }

RunWait("*RunAs " A_ComSpec " /c " cmdLine)
if !temp
    return
try {
    DirMove(A_Temp "\tomshi\UserBackup", ahklib "\UserBackup", 1)
}