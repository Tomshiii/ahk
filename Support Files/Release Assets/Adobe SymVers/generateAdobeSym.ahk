;// this script facilitates regenerating adobe symlink folders without the need to run the main `CreateSymLink.ahk` script

#Include adobeVers.ahk
#Include <Functions\detect>
detect()
RunWait(A_ScriptDir "\deleteAdobeSyms.ahk")
SetWorkingDir(A_ScriptDir "\..\")

imgsrchPath := A_WorkingDir '\..\..\Support Files\ImageSearch'

adobecmd := ""
if IsSet(adobeVers) && IsObject(adobeVers) {
    adobecmd := adobeVers.__generate(imgsrchPath)
    RunWait("*RunAs " A_ComSpec " /c " adobecmd)
}