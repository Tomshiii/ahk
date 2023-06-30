; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
; }

LabelColour := KSA.labelViolet

if !WinActive(prem.winTitle)
    return
SendEvent(LabelColour)
sleep 25
SendEvent(KSA.premRndrReplce)