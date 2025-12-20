; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\Editors\Premiere.ahk
#Include Functions\delaySI.ahk
; }

if !WinActive(prem.winTitle)
    return

SendInput(ksa.selectFollowPlayhead)