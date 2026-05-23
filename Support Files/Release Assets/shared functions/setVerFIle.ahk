#Include '%A_Appdata%\tomshi\lib'
#Include Functions\getLocalVer.ahk

SplitPath(A_LineFile,, &installPackages)
SplitPath(installPackages,, &releaseAss)
SplitPath(releaseAss,, &suppFiles)
SplitPath(suppFiles,, &rootDir)

version := getLocalVer(, rootDir "\My Scripts.ahk")

appFolder := A_AppData "\tomshi"
if FileExist(appFolder "\version")
    FileDelete(appFolder "\version")
FileAppend(version, appFolder "\version")
if FileExist(A_MyDocuments "\tomshi\settings.ini") {
    IniWrite(version, A_MyDocuments "\tomshi\settings.ini", "Track", "version")
}
ExitApp()