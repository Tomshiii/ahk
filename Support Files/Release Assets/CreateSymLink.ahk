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

adobecmd := cmdLine " && "

for k, v in adobeVers().Premiere {
    adobecmd := Format('{1} mklink /D "{2}\Premiere\{3}" "{2}\Premiere\{4}" && ', adobecmd, imgsrchPath, k, v)
}
for k, v in adobeVers().AE {
    adobecmd := Format('{1} mklink /D "{2}\AE\{3}" "{2}\AE\{4}" && ', adobecmd, imgsrchPath, k, v)
}
adobecmd := SubStr(adobecmd, 1, StrLen(adobecmd) - 4)

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
 * Values of adobe versions that share their images with each other.
 * Versions being listed here do NOT ensure they are completely compatible with my scripts, I do not have the manpower to extensively test version I do not use consistently
 * @param firstvalue is the NEW version
 * @param secondvalue is the version it's copying (so the ACTUAL folder)
 */
class adobeVers {
    Premiere := Map(
        "v23.1",    "v22.2.1",
        "v23.2",    "v22.3.1"
    )
    AE := Map(
        "v23.2.1",  "v22.6"
    )
}