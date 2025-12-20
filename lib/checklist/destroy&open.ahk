; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Functions\detect.ahk
#Include Classes\ptf.ahk
; }

detect()
if WinExist("checklist.ahk - AutoHotkey")
    WinClose("checklist.ahk - AutoHotkey")
Run(ptf["checklist"])