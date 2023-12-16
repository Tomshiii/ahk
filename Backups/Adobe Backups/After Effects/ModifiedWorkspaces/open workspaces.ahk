#Warn VarUnset, StdOut
; { \\ #Includes
#Include *i <Classes\settings>
#Include *i <Classes\ptf>
; }

try {
    UserSettings := UserPref()
}

SetWorkingDir(A_ScriptDir)
drive := IniRead(A_WorkingDir "\readme.ini", "INFO", "drive letter")
version := IsSet(UserSettings) ? LTrim(ptf.aeIMGver, "v") : IniRead(A_WorkingDir "\readme.ini", "INFO", "version")

Dir := drive ":\Users\" A_UserName "\AppData\Roaming\Adobe\After Effects\" version "\ModifiedWorkspaces"
if !DirExist(Dir) {
    MsgBox("Error attempting to run Adobe folder. This folder is usually in the \AppData\Roaming\ directory.`n`nIf you have moved this directory, please adjust the .ini file and try again")
    return
}
Run(Dir)