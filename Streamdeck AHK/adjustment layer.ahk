; { \\ #Includes
; #Include <Classes\winget>
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
; }

if WinActive(Editors.Premiere.winTitle)
    {
        SendInput(timelineWindow)
        SendInput(timelineWindow)
        SendInput(projectsWindow)
        SendInput(adjustmentPrem)
    }
if WinActive(Editors.AE.winTitle)
    SendInput(adjustmentAE)