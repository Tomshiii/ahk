#Warn VarUnset, StdOut
; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include *i Classes\settings.ahk
#Include *i Classes\ptf.ahk
#Include *i Classes\CLSID_Objs.ahk
; }

try {
   UserSettings := CLSID_Objs.load("UserSettings")
}

SetWorkingDir(A_ScriptDir)
version := (IsSet(UserSettings)) ? ptf.PremYearVer ".0" : IniRead(A_WorkingDir "\readme.ini", "INFO", "version")
incBeta := (IsSet(UserSettings) && ((UserSettings.premIsBeta = true || UserSettings.premIsBeta = "true"))) ? " (Beta)" : ""

Dir := A_MyDocuments "\Adobe\Adobe Media Encoder" incBeta "\" version "\Presets"
if !DirExist(Dir) {
    MsgBox("Error attempting to run Adobe folder. This folder is usually in the \My Documents directory.`n`nIf you have moved this directory, please adjust the .ini file and try again")
    return
}
Run(Dir)