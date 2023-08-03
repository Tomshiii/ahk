; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
; }

if !WinActive(prem.winTitle)
    return
SendInput(KSA.premFrameHold)