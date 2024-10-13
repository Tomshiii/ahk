#Warn VarUnset, StdOut
; { \\ #Includes
#Include *i <Classes\settings>
#Include *i <Classes\ptf>
; }

try {
    UserSettings := UserPref()
}

SetWorkingDir(A_ScriptDir)
aeVerNum := StrReplace(ptf.aeIMGver, "v", "")
aeVerNumTrim := InStr(aeVerNum, ".",,, 2) ? SubStr(aeVerNum, 1, InStr(aeVerNum, ".",,, 2)-1) : aeVerNum
version := (IsSet(UserSettings)) ? aeVerNumTrim : IniRead(A_WorkingDir "\readme.ini", "INFO", "version")
incBeta := (IsSet(UserSettings) && (UserSettings.aeIsBeta = true || UserSettings.aeIsBeta = "true")) ? " (Beta)" : ""

Dir := A_AppData "\Adobe\After Effects" incBeta "\" version "\ModifiedWorkspaces"
if !DirExist(Dir) {
    MsgBox("Error attempting to run Adobe folder. This folder is usually in the \AppData\Roaming\ directory.`n`nIf you have moved this directory, please adjust the .ini file and try again")
    return
}
Run(Dir)