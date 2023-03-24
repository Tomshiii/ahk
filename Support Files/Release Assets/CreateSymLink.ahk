#Include *i Adobe SymVers\adobeVers.ahk

SetWorkingDir(A_ScriptDir)

if !DirExist(A_MyDocuments "\AutoHotkey")
    DirCreate(A_MyDocuments "\AutoHotkey")

ahklib := A_MyDocuments '\AutoHotkey\Lib'
path := A_ScriptDir '\..\..\Lib'
imgsrchPath := A_ScriptDir '\..\..\Support Files\ImageSearch'
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
            if DirExist(ahklib "\UserBackup")
                DirDelete(ahklib "\UserBackup", 1)
            DirMove(ahklib, A_Temp "\tomshi\UserBackup", 1)
            temp := true
            if DirExist(ahklib)
                DirDelete(ahklib, 1)
        }
    }

adobecmd := cmdLine A_Space

if IsSet(adobeVers) && IsObject(adobeVers) {
    for k, v in adobeVers.maps {
        which := adobeVers.which[k]
        for k2, v2 in v {
            ;// will remove any symlinks before attempting to create it so that it doesn't error out
            if DirExist(path := imgsrchPath "\" which "\" k2) && InStr(FileGetAttrib(path), "l") ;// checks to make sure it's still a symbolic link
                DirDelete(path)
            adobecmd := Format('{1} && mklink /D "{2}\{5}\{3}" "{2}\{5}\{4}" ', adobecmd, imgsrchPath, k2, v2, which)
        }
    }
}

RunWait("*RunAs " A_ComSpec " /c " adobecmd)

if !DirExist(ahklib)
    {
        MsgBox("Something went wrong", "Error", "16 4096")
        return
    }
if !temp
    {
        MsgBox("SymLink generated successfully!", "Success", "64 4096")
        return
    }
try {
    DirMove(A_Temp "\tomshi\UserBackup", ahklib "\UserBackup", 1)
    MsgBox("SymLink generated successfully!", "Success", "64 4096")
}
