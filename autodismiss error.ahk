#SingleInstance force ;only one instance of this script may run at a time!
TraySetIcon(A_WorkingDir "\Support Files\Icons\dismiss.ico")
A_MaxHotkeysPerInterval := 2000
#Requires AutoHotkey v2.0-beta.5 ;this script requires AutoHotkey v2.0

; you know that extremely annoying dialouge box that says,
; "This action will delete existing keyframes. Do you want to continue?"
; Well, now you can auto-dismiss it. That's not as good as WIPING IT FROM THE FACE OF THE EARTH FOREVER, but it's at least a little better.
; If you know how to hack it so that there is effectively a "don't ask again" checkbox functionality... let me know.

;DetectHiddenText(1)

lol:
if WinActive("Warning ahk_exe Adobe Premiere Pro.exe",, "Clip Mismatch")
    sendinput "{enter}"
else
    WinWait("Warning ahk_exe Adobe Premiere Pro.exe")
goto lol