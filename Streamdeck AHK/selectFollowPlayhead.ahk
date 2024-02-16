; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Functions\delaySI>
; }

if !WinActive(prem.winTitle)
    return

SendInput(ksa.selectFollowPlayhead)