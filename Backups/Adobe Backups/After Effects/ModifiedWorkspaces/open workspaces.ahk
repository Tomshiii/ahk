#Warn VarUnset, StdOut
; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include *i Classes\settings.ahk
#Include *i Classes\CLSID_Objs.ahk
; }

try {
    isBeta := CLSID_Objs.loadProp("UserSettings", "aeIsBeta")
}

SetWorkingDir(A_ScriptDir)
aeVerNum := StrReplace(ptf.aeSETver, "v", "")
aeVerNumTrim := InStr(aeVerNum, ".",,, 2) ? SubStr(aeVerNum, 1, InStr(aeVerNum, ".",,, 2)-1) : aeVerNum
version := (IsSet(isBeta)) ? aeVerNumTrim : IniRead(A_WorkingDir "\readme.ini", "INFO", "version")
incBeta := (IsSet(isBeta) && (isBeta = true || isBeta = "true")) ? " (Beta)" : ""

Dir := A_AppData "\Adobe\After Effects" incBeta "\" version "\ModifiedWorkspaces"
if !DirExist(Dir) {
    MsgBox("Error attempting to run Adobe folder. This folder is usually in the \AppData\Roaming\ directory.`n`nIf you have moved this directory, please adjust the .ini file and try again")
    return
}
Run(Dir)