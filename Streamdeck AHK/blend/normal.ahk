#SingleInstance Force
; { \\ #Includes
#Include <Classes\settings>
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
#Include <Classes\Editors\After Effects>
; }
SetDefaultMouseSpeed(0)
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

if WinActive(Editors.Premiere.winTitle) {
    detect()
    UserSettings := UserPref()
    if WinExist(UserSettings.MainScriptName ".ahk")
        WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")
    prem.valuehold("blend\blendmode",, "normal")
}
if WinActive(Editors.AE.winTitle)
    AE.blendMode()