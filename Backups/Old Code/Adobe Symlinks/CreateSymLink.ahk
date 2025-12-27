#Include "%A_LineFile%"
#Include Adobe SymVers\adobeVers.ahk
#Include Adobe SymVers\_Assets\pathU.ahk

SplitPath(A_LineFile,, &workDir)
SetWorkingDir(workDir)
installDir := FileRead(A_Appdata "\tomshi\installDir")
imgsrchPath := installDir '\Support Files\ImageSearch'

runOrAs := (A_IsAdmin = false) ? "*RunAs " : ""
;final command should look like;
; mklink /D "mydocumentspathhere\AutoHotkey\Lib" "rootrepopath\lib"

adobecmd := ""
if IsSet(adobeVers) && IsObject(adobeVers) {
    adobecmd := adobeVers.__generate(imgsrchPath, false, adobecmd)
    if !InStr(adobecmd, "|||")
        RunWait(runOrAs A_ComSpec " /c " adobecmd,, "Hide")
    else {
        cmds := StrSplit(adobecmd, "|||")
        for v in cmds
            RunWait(runOrAs A_ComSpec " /c " v,, "Hide")
    }
}
sleep 100