#SingleInstance Ignore
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\ptf.ahk
#Include Classes\wm.ahk
#Include Classes\obj.ahk
; }

if !WinActive(prem.winTitle) || !WinExist(prem.winTitle)
    return

onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
UserSettings := UserPref()
currentName := obj.SplitPath(A_ScriptName)
if WinExist(UserSettings.MainScriptName ".ahk") {
    WM.Send_WM_COPYDATA("Premiere_sc" currentName.NameNoExt "," A_ScriptName, UserSettings.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")
}
prem.screenShot(currentName.NameNoExt)