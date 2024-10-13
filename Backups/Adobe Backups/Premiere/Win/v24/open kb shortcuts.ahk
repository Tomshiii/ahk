#Warn VarUnset, StdOut
; { \\ #Includes
#Include *i <Classes\settings>
#Include *i <Classes\ptf>
; }

try {
    UserSettings := UserPref()
}

SetWorkingDir(A_ScriptDir)
version := (IsSet(UserSettings)) ? ptf.PremYearVer ".0" : IniRead(A_WorkingDir "\readme.ini", "INFO", "version")
incBeta := (IsSet(UserSettings) && (UserSettings.premIsBeta = true || UserSettings.premIsBeta = "true")) ? " (Beta)" : ""

Dir := A_MyDocuments "\Adobe\Premiere Pro" incBeta "\" version "\Profile-" A_UserName "\Win"
dirver := IsSet(UserSettings) ? ptf.premIMGver : version
if !DirExist(Dir) {
    MsgBox("You either have the incorrect version set within ``settingsGUI()`` (current version set: " dirver ") or you have installed Premiere Pro to a different location.`n`nThis folder is usually in the \My Documents\ directory.`nIf you have moved this directory, please adjust the .ini file and try again", "Error attempting to run Adobe folder", 0x30)
    return
}
Run(Dir)