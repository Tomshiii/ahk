#SingleInstance Force
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\Editors\After Effects.ahk
#Include Classes\switchTo.ahk
#Include Classes\ptf.ahk
#Include Classes\WM.ahk
#Include Classes\winGet.ahk
#Include Classes\CLSID_Objs.ahk
#Include Functions\detect.ahk
#Include Functions\change_msgButton.ahk
; }
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

__detectMainScript() {
    detect()
    UserSettings := CLSID_Objs.load("UserSettings")
    if !WinExist(UserSettings.MainScriptName ".ahk") {
        sleep 1000
        __final()
        return
    }
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")
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
sleep 750
if !WinExist(AE.winTitle) {
    msgTitle := "New AE or Old"
    SetTimer(change_msgButton.Bind(msgTitle, "New", "Existing"), 16)
    if MsgBox("Would you like to open a new After Effects project`nor open an existing one?", msgTitle, 1) = "OK" {
        ;// exits app after execution
        focusAndContinue()
    }
    directory := WinGet.ProjPath()
    if !fileSlct := FileSelect("3", directory.path, "Select AE project", "*.aep")
        ExitApp()
    Run(prem.path A_Space fileSlct)
    MsgBox("Wait for AE to load and then try sending the clip again", "Try Again")
    ExitApp()
}
focusAndContinue()


focusAndContinue() {
    if !prem.__checkTimelineValues()
        __final()
    sleep 100
    if !prem.__waitForTimeline(3)
        __final()
    __final()
}

__final() {
    SendInput(KSA.rplceAEComp)
    if !WinWait("Save Project " AE.winTitle,, 3)
        ExitApp()
    if !WinWaitClose("Save Project " AE.winTitle,, 5)
        ExitApp()
    switchTo.AE()
    ExitApp()
}