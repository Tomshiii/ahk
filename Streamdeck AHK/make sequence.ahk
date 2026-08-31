; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\Editors\Premiere.ahk
#Include Functions\delaySI.ahk
; }

if !WinActive(prem.winTitle)
    return

delaySI(75, KSA.prem.projectsWindow, KSA.prem.timelineWindow, ksa.prem.MakeSequence, KSA.prem.timelineWindow)