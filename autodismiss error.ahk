#SingleInstance force ;only one instance of this script may run at a time!
TraySetIcon("C:\Program Files\ahk\ahk\Icons\warning.png")
A_MaxHotkeysPerInterval := 2000
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
;Menu, Tray, Icon, shell32.dll, 303 ; this changes the tray icon to a little check mark!

;you know that extremely annoying dialouge box that says,
; "This action will delete existing keyframes. Do you want to continue?"
;Well, now you can auto-dismiss it. That's not as good as WIPING IT FROM THE FACE OF THE EARTH FOREVER, but it's at least a little better.
;If you know how to hack it so that there is effectively a "don't ask again" checkbox functionality... let me know.
;#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")
DetectHiddenText "1"

lol:
if WinWait("Warning ahk_exe Adobe Premiere Pro.exe")
    sendinput "{enter}"
sleep 100
goto lol