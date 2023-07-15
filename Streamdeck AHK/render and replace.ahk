; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\WM>
; }
onMsgObj := ObjBindMethod(prem, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA
LabelColour := KSA.labelViolet

if !WinActive(prem.winTitle)
    return
detect()
if WinExist("My Scripts.ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, "My Scripts.ahk")

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
sleep 500
if prem.__checkTimelineValues() = true {
    if !prem.__waitForTimeline()
        return
}
SendEvent(KSA.premRndrReplce)