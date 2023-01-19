; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\tool>
; }

if WinActive(Editors.Premiere.winTitle)
    {
        SendInput(KSA.timelineWindow)
        SendInput(KSA.timelineWindow)
        SendInput(KSA.projectsWindow)
        SendInput(KSA.adjustmentPrem)
        if !WinWait("Adjustment Layer",, 2)
            {
                tool.Cust("Adjustment layer window didn't open in time")
                return
            }
        if !WinActive("Adjustment Layer")
            WinActivate("Adjustment Layer")
        SendInput("+{Tab}")
        SendInput("{Up 7}")
        SendInput("+{Tab}")
        SendInput("{Down 10}")
        sleep 100
        SendInput("{Enter}")
    }
if WinActive(Editors.AE.winTitle)
    SendInput(KSA.adjustmentAE)