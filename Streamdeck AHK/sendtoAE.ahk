; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\Editors\After Effects>
#Include <Classes\switchTo>
#Include <Classes\ptf>
#Include <Classes\WM>
#Include <Functions\detect>
; }
onMsgObj := ObjBindMethod(prem, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

__detectMainScript() {
    detect()
    if !WinExist(ptf.MainScriptName ".ahk") {
        sleep 1000
        __final()
        return
    }
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, ptf.MainScriptName ".ahk")
}

if !WinActive(prem.winTitle)
    return
__detectMainScript()
SendInput("^s")
if !WinWait("Save Project",, 3)
    return
if !WinWaitClose("Save Project",, 5)
    return
if !WinWaitActive(prem.winTitle,, 5)
    return
sleep 500
if !prem.__checkTimelineValues()
    __final()
if !prem.__waitForTimeline()
    __final()
__final()

__final() {
    SendInput(KSA.rplceAEComp)
    if !WinWait("Save Project " AE.winTitle,, 3)
        ExitApp()
    if !WinWaitClose("Save Project " AE.winTitle,, 5)
        ExitApp()
    switchTo.AE()
    ExitApp()
}