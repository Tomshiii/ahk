; { \\ #Includes
#Include <Classes\ptf>
; }

ignorelist := Map()
ignorelist.CaseSense := "Off"
ignorelist.Set("checklist.ahk", 1, "launcher.ahk", 1)

loop files ptf.rootDir "\Streamdeck AHK\download\*.ahk", "F"
    ignorelist.Set(A_LoopFileName, 1)
loop files ptf.rootDir "\Streamdeck AHK\convert2\*.ahk", "F"
    ignorelist.Set(A_LoopFileName, 1)