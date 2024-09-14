#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0 ;this script requires AutoHotkey v2.0
ListLines(0)
KeyHistory(0)
; { \\ #Includes
#Include <Classes\ptf>
#Include <Functions\trayShortcut>
#Include <Classes\Editors\Premiere>
#Include <Other\WinEvent>
; }

Persistent()
TraySetIcon(ptf.Icons "\dismiss.ico")

; you know that extremely annoying dialouge box that says,
; "This action will delete existing keyframes. Do you want to continue?"
; Well, now you can auto-dismiss it. That's not as good as WIPING IT FROM THE FACE OF THE EARTH FOREVER, but it's at least a little better.

if VerCompare(prem.currentSetVer, prem.spectrumUI_Version) < 0
    WinEvent.Active((*) => SendInput("{Enter}"), "Warning " prem.winTitle,,, "Clip Mismatch")
else {
    ;// due to adobe removing the window title for this menu in the spectrum ui, we have to find the text instead
    SetTitleMatchMode("Slow")
    WinEvent.Active((*) => SendInput("{Enter}"),,, "This action will delete existing keyframes. Do you want to continue?")
}