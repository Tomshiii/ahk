#Include *i Adobe SymVers\adobeVers.ahk

SetWorkingDir(A_ScriptDir)

if !DirExist(A_MyDocuments "\AutoHotkey")
    DirCreate(A_MyDocuments "\AutoHotkey")

ahklib := A_MyDocuments '\AutoHotkey\Lib'
path := pathU(A_ScriptDir '\..\..\Lib')
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
    adobecmd := adobeVers.__generate(imgsrchPath, true, adobecmd)
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


/**
     * Returns a fully qualified path
     * @link https://www.autohotkey.com/boards/viewtopic.php?t=120582&p=535232
     * @author SKAN
     * @param {String} path the path to your desired file/path
     * @returns {String} the path
     */
pathU(path) {
    OutFile := Format("{:260}", "")
    DllCall("Kernel32\GetFullPathNameW", "str", path, "uint",260, "str", OutFile, "ptr", 0)
    ; DllCall("Shell32\PathYetAnotherMakeUniqueName", "str", OutFile, "str", OutFile, "ptr", 0, "ptr", 0)
    return OutFile
}