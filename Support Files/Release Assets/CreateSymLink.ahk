#Include "%A_LineFile%"
#Include Adobe SymVers\adobeVers.ahk

SplitPath(A_LineFile,, &workDir)
SetWorkingDir(workDir)

if !DirExist(A_MyDocuments "\AutoHotkey")
    DirCreate(A_MyDocuments "\AutoHotkey")

ahklib      := A_MyDocuments '\AutoHotkey\Lib'
path        := pathU(A_WorkingDir '\..\..\Lib')
imgsrchPath := A_WorkingDir '\..\..\Support Files\ImageSearch'

cmdLine := Format('mklink /D `"{}`" `"{}`"'
                  , ahklib, path)

runOrAs := (A_IsAdmin = false) ? "*RunAs " : ""
;final command should look like;
; mklink /D "mydocumentspathhere\AutoHotkey\Lib" "rootrepopath\lib"

if DirExist(ahklib) = "DL"
    DirDelete(ahklib, 1)

adobecmd := cmdLine A_Space
if IsSet(adobeVers) && IsObject(adobeVers) {
    adobecmd := adobeVers.__generate(imgsrchPath, true, adobecmd)
    if !InStr(adobecmd, "|||")
        RunWait(runOrAs A_ComSpec " /c " adobecmd,, "Hide")
    else {
        cmds := StrSplit(adobecmd, "|||")
        for v in cmds
            RunWait(runOrAs A_ComSpec " /c " v,, "Hide")
    }
}
sleep 100

if !DirExist(ahklib) {
    loop 5 {
        if DirExist(ahklib)
            break
        if !DirExist(ahklib) && A_Index < 5 {
            sleep 100
            continue
        }
        if !DirExist(ahklib) && A_Index >= 5 {
            MsgBox("Unable to determine the symlink folder.`nSomething may have gone wrong during generation or waiting for the folder simply timed out.", "Error", "16 4096")
            return
        }
    }
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