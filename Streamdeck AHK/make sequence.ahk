; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Functions\delaySI>
; }

if !WinActive(prem.winTitle)
    return

delaySI(75, KSA.projectsWindow, KSA.timelineWindow, KSA.premMakeSequence, KSA.timelineWindow)