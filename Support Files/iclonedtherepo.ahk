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
    (!verFile) ?  FileAppend("v2.18.0", basePath "\version") : ""
    Run(rootPath "\Core Functionality.ahk")
    RunWait(suppFilesDir "\Release Assets\Install Packages\waitCoreFunc.ahk")
    (!verFile) ? RunWait(suppFilesDir "\Release Assets\shared functions\setVerFile.ahk") : ""
    RunWait(suppFilesDir "\Release Assets\Install Packages\baseLineSettings.ahk")
    RunWait(suppFilesDir "\Release Assets\Install Packages\installNode.ahk")
    ;// this won't work anymore as no staging dir's will exist -- needs update eventually
    ; Run(suppFilesDir "\Release Assets\Install Packages\installPremRemote.ahk")
    try RunWait(A_ComSpec "/k git submodule update --init --recursive", rootPath)
}

MsgBox("Process Complete")