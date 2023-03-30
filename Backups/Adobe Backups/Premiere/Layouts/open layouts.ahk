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
version := IsSet(UserSettings) ? ptf.PremYearVer ".0" : IniRead(A_WorkingDir "\readme.ini", "INFO", "version")

Dir := drive ":\Program Files\User\Documents\Adobe\Premiere Pro\" version "\Profile-" A_UserName "\Layouts"
if !DirExist(Dir) {
    MsgBox("Error attempting to run Adobe folder. This folder is usually in the \My Documents directory.`n`nIf you have moved this directory, please adjust the .ini file and try again")
    return
}
Run(Dir)