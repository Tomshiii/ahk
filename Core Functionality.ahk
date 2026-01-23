#SingleInstance Force
#Requires AutoHotkey v2.0
#Warn VarUnset, StdOut

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include *i Classes\Settings.ahk
#Include *i Classes\ptf.ahk
#Include *i Classes\CLSID_Objs.ahk
#Include *i Other\ObjRegisterActive.ahk
#Include *i Classes\Editors\Premiere.ahk
; }

installDir := FileRead(A_AppData "\tomshi\installDir")
SetWorkingDir(installDir)
Persistent()
TraySetIcon(installDir "\Support Files\Icons\core func.ico")

UserSettings := UserPref()
premiere := prem
; premUIA := premUIA_Values(false)

uiaCheckRunning := {isRunning: false}
allRegister := [{obj:premiere, name: "prem"}, {obj: uiaCheckRunning, name: "uiaCheckRunning"} , {obj: UserSettings, name: "UserSettings"}]
for v in allRegister {
    ObjRegisterActive(v.obj, CLSID_Objs[v.name])
}
; ObjRegisterActive(premUIA, "{6A7B49B5-8947-488D-ABDD-4BC7FFA60B12}")
OnExit(revoke.Bind(allRegister))
revoke(allRegister, *) {
    for v in allRegister {
        ObjRegisterActive(v.obj, "")
    }
}