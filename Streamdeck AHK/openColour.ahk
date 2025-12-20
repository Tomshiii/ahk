; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\Premiere.ahk
#Include KSA\Keyboard Shortcut Adjustments.ahk
; }

if !WinActive(prem.winTitle)
    return
SendInput(ksa.clipColor)