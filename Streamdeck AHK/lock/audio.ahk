; { \\ #Includes
#Include <Classes\Editors\Premiere>
; }

if !WinActive(prem.winTitle)
    return

Persistent()

prem.excalibur.lockTracks("audio")

SetTimer(__end, 250)
__end() {
    if !WinExist("Lock " StrTitle(SubStr(A_ScriptName, 1, StrLen(A_ScriptName)-4)) " Tracks") {
        prem.Excalibur().__lockNumpadKeys("reset")
        ExitApp()
    }
}