#SingleInstance Force
; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\settings>
#Include <Classes\Editors\Premiere>
#Include <Classes\WM>
#Include <Classes\ptf>
#Include <Classes\winget>
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
title := WinGet.PremName()
if title.saveCheck != false
    attempt := prem.saveAndFocusTimeline()
SendEvent(KSA.premRndrReplce)
sleep 100
if !WinWait("Render and Replace",, 2) {
    if attempt ?? false = "active" {
        SendInput(KSA.premRndrReplce)
        if !WinWait("Render and Replace",, 2) {
            tool.Cust("Waiting for rendering window timed out.`nLag may have caused the hotkey to be sent before Premiere was ready.")
            return
        }
    }
}