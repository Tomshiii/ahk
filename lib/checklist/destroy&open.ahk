; { \\ #Includes
#Include <Functions\detect>
#Include <\Classes\ptf>
; }

detect()
if WinExist("checklist.ahk - AutoHotkey")
    WinClose("checklist.ahk - AutoHotkey")
Run(ptf["checklist"])