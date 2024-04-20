#SingleInstance Ignore
; { \\ #Includes
#Include <Classes\settings>
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
#Include <Classes\wm>
#Include <Classes\obj>
; }

if !WinActive(prem.winTitle) || !WinExist(prem.winTitle)
    return

onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
UserSettings := UserPref()
currentName := obj.SplitPath(A_ScriptName)
newVal := prem.screenShot(currentName.NameNoExt, true)
if WinExist(UserSettings.MainScriptName ".ahk") && newVal != 0 {
    valSplit := StrSplit(newVal, ",")
    WM.Send_WM_COPYDATA("Premiere_sc" currentName.NameNoExt "," valSplit[1] "," valSplit[2], UserSettings.MainScriptName ".ahk")
}