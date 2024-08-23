#Warn VarUnset, StdOut
; { \\ #Includes
#Include *i <Classes\settings>
#Include *i <Classes\ptf>
; }

try {
    UserSettings := UserPref()
}

SetWorkingDir(A_ScriptDir)
version := (IsSet(UserSettings) && UserSettings.premIsBeta != true && UserSettings.premIsBeta != "true") ? ptf.PremYearVer ".0" : IniRead(A_WorkingDir "\readme.ini", "INFO", "version")

Dir := A_MyDocuments "\Adobe\Adobe Media Encoder\" version "\Presets"
if !DirExist(Dir) {
    MsgBox("Error attempting to run Adobe folder. This folder is usually in the \My Documents directory.`n`nIf you have moved this directory, please adjust the .ini file and try again")
    return
}
Run(Dir)