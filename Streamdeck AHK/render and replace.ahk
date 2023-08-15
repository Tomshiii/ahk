#SingleInstance Force
; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\WM>
#Include <Classes\ptf>
; }
onMsgObj := ObjBindMethod(prem, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA
LabelColour := KSA.labelViolet

if !WinActive(prem.winTitle)
    return
detect()
if WinExist(ptf.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, ptf.MainScriptName ".ahk")

SendEvent(LabelColour)
sleep 25
SendEvent("^s")
if !WinWait("Save Project",, 3) {
    tool.Cust("Function timed out waiting for save prompt")
    return
}
if !WinWaitClose("Save Project",, 5) {
    tool.Cust("Function timed out waiting for save prompt to close")
    return
}
sleep 750
if prem.__checkTimelineValues() = true {
    sleep 100
    if !prem.__waitForTimeline(3)
        return
}
sleep 100
SendEvent(KSA.premRndrReplce)