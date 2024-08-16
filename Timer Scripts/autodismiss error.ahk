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

;// June 2024- OR not apparently if you're on the new Spectrum UI because adobe in their infinite wisdom have REMOVED the window title
;// which makes it COMPLETELY impossible to detect... thanks adobe
if VerCompare(prem.currentSetVer, prem.spectrumUI_Version) < 0
    WinEvent.Active((*) => SendInput("{Enter}"), "Warning " prem.winTitle,,, "Clip Mismatch")