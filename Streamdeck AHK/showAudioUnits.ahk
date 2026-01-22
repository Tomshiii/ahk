#SingleInstance Force
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\ptf.ahk
#Include Classes\CLSID_Objs.ahk
; }

if !WinActive(prem.winTitle)
    return

if prem.__checkTimelineValues() = true {
    sleep 100
    if !prem.__waitForTimeline(3)
        return
}

SendInput(ksa.audioTimeUnits)