#SingleInstance Force
; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\settings>
#Include <Classes\Editors\Premiere>
#Include <Classes\WM>
#Include <Classes\ptf>
; }
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA
LabelColour := KSA.labelViolet
UserSettings := UserPref()

if !WinActive(prem.winTitle)
    return
detect()
if WinExist(UserSettings.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")

if prem.__checkTimelineValues() = true {
    sleep 100
    if !prem.__waitForTimeline(3)
        return
}
sleep 100
SendEvent(LabelColour)
sleep 50
prem.saveAndFocusTimeline()
SendEvent(KSA.premRndrReplce)