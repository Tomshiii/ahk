;// this script facilitates regenerating adobe symlink folders without the need to run the main `CreateSymLink.ahk` script

#Include adobeVers.ahk

DetectHiddenWindows(true), SetTitleMatchMode(2)
SplitPath(A_LineFile,, &scptDir)
RunWait(scptDir "\deleteAdobeSyms.ahk")
SetWorkingDir(scptDir "\..\")

imgsrchPath := A_WorkingDir '\..\..\Support Files\ImageSearch'
runOrAs := (A_IsAdmin = false) ? "*RunAs " : ""

adobecmd := ""
if IsSet(adobeVers) && IsObject(adobeVers) {
    adobecmd := adobeVers.__generate(imgsrchPath)
    if !InStr(adobecmd, "|||") {
        RunWait(runOrAs A_ComSpec " /c " adobecmd,, "Hide")
        return
    }
    cmds := StrSplit(adobecmd, "|||")
    for v in cmds
        RunWait(runOrAs A_ComSpec " /c " v,, "Hide")
}