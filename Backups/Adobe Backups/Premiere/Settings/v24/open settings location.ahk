#Warn VarUnset, StdOut
; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include *i Classes\settings.ahk
#Include *i Classes\ptf.ahk
#Include *i Classes\CLSID_Objs.ahk
; }

try {
   premIsBeta := CLSID_Objs.loadProp("UserSettings", "premIsBeta")
}

SetWorkingDir(A_ScriptDir)
version := (IsSet(premIsBeta)) ? ptf.PremYearVer ".0" : IniRead(A_WorkingDir "\readme.ini", "INFO", "version")
incBeta := (IsSet(premIsBeta) && (premIsBeta = true || premIsBeta = "true")) ? " (Beta)" : ""

Dir := A_MyDocuments "\Adobe\Premiere Pro" incBeta "\" version "\Profile-" A_UserName
dirver := IsSet(premIsBeta) ? ptf.premSETver : version
if !DirExist(Dir) {
    MsgBox("You either have the incorrect version set within ``settingsGUI()`` (current version set: " dirver ") or you have installed After Effects to a different location.`n`nThis folder is usually in the \AppData\Roaming\ directory.`nIf you have moved this directory, please adjust the .ini file and try again", "Error attempting to run Adobe folder", 0x30)
    return
}
Run(Dir)