/************************************************************************
 * @description provides shared object access across multiple AutoHotkey scripts using Windows COM registration
 * @author tomshi
 * @date 2026/04/20
 * @version 1.0.6
 ***********************************************************************/

#SingleInstance Force
#Requires AutoHotkey v2.0
#Warn VarUnset, StdOut

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include *i Classes\Settings.ahk
#Include *i Classes\ptf.ahk
#Include *i Classes\CLSID_Objs.ahk
#Include *i Classes\WM.ahk
#Include *i Other\ObjRegisterActive.ahk
#Include *i Other\WinEvent.ahk
#Include *i Classes\Editors\Premiere.ahk
#Include *i Classes\Editors\Premiere_UIA.ahk
; }

;// this allows `notifyIfNotExist()` to send its prompts to Core Functionality
;// fixes notify GUIs hanging when called from `HotkeylessAHK`
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

installDir := FileRead(A_AppData "\tomshi\installDir")
SplitPath(A_LineFile,, &currentDir)
if currentDir != installDir {
    throw TargetError("Installation has been moved, this will cause issues.`nMove the installation back or reinstall in the new location.",, installDir)
}
SetWorkingDir(installDir)
Persistent()
TraySetIcon(installDir "\Support Files\Icons\core func.ico")

UserSettings := UserPref()
premiere := prem
premUIA := premUIA_Values
Loading := {isLoading: true}

allRegister := [{obj:premiere, name: "prem"}, {obj: UserSettings, name: "UserSettings"}, {obj: premUIA, name: "premUIA_Values"}, {obj: Loading, name: "Loading"}]
for v in allRegister {
    ObjRegisterActive(v.obj, CLSID_Objs[v.name])
}
Loading.isLoading := false

OnExit(revoke.Bind(allRegister))
revoke(allRegister, *) {
    try WinEvent.Stop()
    for v in allRegister {
        try ObjRegisterActive(v.obj, "")
    }
}