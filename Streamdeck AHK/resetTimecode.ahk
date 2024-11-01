; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\Editors\Premiere>
#Include <Functions\delaySI>
; }

;// resets prem "start time" timecode to 0

if !WinActive(prem.winTitle)
    return

if prem.__checkPremRemoteDir("setZeroPoint") {
    prem.__remoteFunc("setZeroPoint",, "tick=0")
    return
}

startValue := "0"

onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA
UserSettings := UserPref()

detect()
if WinExist(UserSettings.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")

if prem.__checkTimelineValues() = true {
    sleep 100
    if !prem.__waitForTimeline(3)
        return
}

delaySI(50, ksa.modifyStartTime, startValue, "{Enter}")