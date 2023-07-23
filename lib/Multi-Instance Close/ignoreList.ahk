; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\Mip>
; }

ignorelist := Mip("checklist.ahk", 1, "launcher.ahk", 1)

;// manually add any
ignorelist.Set(ptf.rootDir "\Streamdeck AHK\Move project.ahk", 1)

;// loop add some dirs
loop files ptf.rootDir "\Streamdeck AHK\download\*.ahk", "F"
    ignorelist.Set(A_LoopFileName, 1)
loop files ptf.rootDir "\Streamdeck AHK\convert2\*.ahk", "F"
    ignorelist.Set(A_LoopFileName, 1)
loop files ptf.rootDir "\Streamdeck AHK\trim\*.ahk", "F"
    ignorelist.Set(A_LoopFileName, 1)
loop files ptf.rootDir "\Streamdeck AHK\update\*.ahk", "F"
    ignorelist.Set(A_LoopFileName, 1)