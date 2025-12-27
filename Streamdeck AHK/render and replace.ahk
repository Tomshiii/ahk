#SingleInstance Force
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\WM.ahk
#Include Classes\ptf.ahk
#Include Classes\winget.ahk
#Include Classes\CLSID_Objs.ahk
; }
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA
LabelColour := KSA.labelViolet

if !WinActive(prem.winTitle)
    return

UserSettings := CLSID_Objs.load("UserSettings")
MainScriptName := UserSettings.MainScriptName

if WinGet.ExistRegex(MainScriptName ".ahk",,,, true)
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, MainScriptName ".ahk")

if prem.__checkTimelineValues() = true {
    sleep 100
    if !prem.__waitForTimeline(3)
        return
}
title := WinGet.PremName()
if title.saveCheck != false
    attempt := prem.saveAndFocusTimeline()
sleep 100
SendEvent(LabelColour)
sleep 50
SendEvent(KSA.premRndrReplce)
sleep 100
if !WinWait("Render and Replace",, 2) {
    if (attempt ?? false) = "active" {
        SendInput(KSA.premRndrReplce)
        if !WinWait("Render and Replace",, 2) {
            tool.Cust("Waiting for rendering window timed out.`nLag may have caused the hotkey to be sent before Premiere was ready.")
            return
        }
    }
}
ExitApp() ;// prem.save() uses WinEvent which will cause this script to act persistently