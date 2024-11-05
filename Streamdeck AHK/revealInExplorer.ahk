; { \\ #Includes
#Include <Classes\Editors\Premiere>
#Include <KSA\Keyboard Shortcut Adjustments>
; }

if !WinActive(prem.winTitle)
    return
SendInput(ksa.revealExplorer)