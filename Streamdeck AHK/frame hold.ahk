; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\Editors\Premiere.ahk
; }

if !WinActive(prem.winTitle)
    return
SendInput(KSA.premFrameHold)