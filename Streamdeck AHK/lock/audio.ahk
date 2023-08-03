; { \\ #Includes
#Include <Classes\Editors\Premiere>
; }

if !WinActive(prem.winTitle)
    return

prem.excalibur.lockTracks("audio")

;// this is necessary, otherwise the script remains open because the function creates hotkeys
ExitApp()