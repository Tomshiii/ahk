/************************************************************************
 * @description provides shared object access across multiple AutoHotkey scripts using Windows COM registration
 * @author tomshi
 * @date 2026/01/30
 * @version 1.0.0
 ***********************************************************************/

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
#Include *i Classes\Editors\Premiere_UIA.ahk
; }

installDir := FileRead(A_AppData "\tomshi\installDir")
SetWorkingDir(installDir)
Persistent()
TraySetIcon(installDir "\Support Files\Icons\core func.ico")

UserSettings := UserPref()
premiere := prem
premUIA := premUIA_Values

uiaCheckRunning := {isRunning: false}
allRegister := [{obj:premiere, name: "prem"}, {obj: uiaCheckRunning, name: "uiaCheckRunning"} , {obj: UserSettings, name: "UserSettings"}, {obj: premUIA, name: "premUIA_Values"}]
for v in allRegister {
    ObjRegisterActive(v.obj, CLSID_Objs[v.name])
}

OnExit(revoke.Bind(allRegister))
revoke(allRegister, *) {
    for v in allRegister {
        ObjRegisterActive(v.obj, "")
    }
}