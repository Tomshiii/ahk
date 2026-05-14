/************************************************************************
 * @description provides shared object access across multiple AutoHotkey scripts using Windows COM registration
 * @author tomshi
 * @date 2026/05/14
 * @version 1.0.14
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
#Include *i Classes\errorLog.ahk
#Include *i Other\ObjRegisterActive.ahk
#Include *i Other\WinEvent.ahk
#Include *i Classes\Editors\Premiere.ahk
#Include *i Classes\Editors\Premiere_UIA.ahk
#Include *i Functions\isReload.ahk
#Include *i KSA\Keyboard Shortcut Adjustments.ahk
; }
try getReload := A_Args.Get(1)

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
Loading  := {isLoading: true}
KSA      := KeyShortAdjust(true)
determineActive := {isRunning: false}

allRegister := [{obj:premiere, name: "prem"}, {obj: UserSettings, name: "UserSettings"}, {obj:KSA, name: "KSA"}, {obj: Loading, name: "Loading"}, {obj: determineActive, name: "determineActive"}]
for v in allRegister {
    ObjRegisterActive(v.obj, CLSID_Objs[v.name])
}
Loading.isLoading := false


if UserSettings.Set_UIA_on_load = true && (isReload(getReload ?? false))
    SetTimer(doStartup, -3000)
doStartup(*) {
    if !premUIA_Values.determineUIA_Exist() {
        __tryFunc(prem.__setTimelineValues())
        __tryFunc(prem.getTimeline(false))
    }
}
__tryFunc(tryFunc*) {
    for v in tryFunc {
        if Type(v) = "Func"
            try v
    }
}


OnExit(revoke.Bind(allRegister))
revoke(allRegister, *) {
    try WinEvent.Stop()
    for v in allRegister {
        try ObjRegisterActive(v.obj, "")
    }
}

OnError(checkRPC)
checkRPC(err, *) {
    Extra   := (err.HasProp('Extra'))   ? err.Extra   : "", File    := (err.HasProp('File'))    ? err.File    : ""
    Line    := (err.HasProp('Line'))    ? err.Line    : "", Message := (err.HasProp('Message')) ? err.Message : ""
    Stack   := (err.HasProp('Stack'))   ? err.Stack   : "", What    := (err.HasProp('What'))    ? err.What    : ""
    errorLog(Error("Handler caught error: " err.Message, err.what, err.Extra), "File: " err.file " | Line: " err.Line)
    if err.Message = "(0x800706BA) The RPC server is unavailable." {
        errorLog(TargetError("Script could not interact with ``RPC Server``.", what, Extra), stack)
        Run(ptf.SupportFiles "\reloadAll.ahk")
        ; ExitApp()
    }
}