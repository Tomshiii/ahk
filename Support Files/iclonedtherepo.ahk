;// symlink libs
;// base settings file
;// version/installDir files
;// install node.js
;// install premremote

#SingleInstance Force

basePath := A_AppData "\tomshi"
baseDir  := DirExist(basePath)
libDir   := DirExist(basePath "\lib")
verFile  := FileExist(basePath "\version")
installFile := FileExist(basePath "\installDir")
if !baseDir || !libDir || !verFile || !installFile {
    SplitPath(A_LineFile,, &suppFilesDir)
    SplitPath(suppFilesDir,, &rootPath)
    (!libDir)  ? DirCopy(rootPath "\lib", basePath "\lib") : ""
    (!installFile) ? FileAppend(rootPath, basePath "\installDir") : ""
    RunWait(suppFilesDir "\Release Assets\Install Packages\baseLineSettings.ahk")
    (!verFile) ? RunWait(suppFilesDir "\Release Assets\shared functions\setVerFile.ahk") : ""
    RunWait(suppFilesDir "\Release Assets\Install Packages\installNode.ahk")
    Run(suppFilesDir "\Release Assets\Install Packages\installPremRemote.ahk")
}

MsgBox("Process Complete")