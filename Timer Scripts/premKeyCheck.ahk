#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0
ListLines(0)

; { \\ #Includes
#Include <Functions\checkKey>
#Include <Classes\ptf>
; }

TraySetIcon(ptf.Icons "\premKey.png")

start:
if WinExist(editors.Premiere.winTitle)
    SetTimer(doCheck, 100)
else
    WinWait(editors.Premiere.winTitle)
goto start

doCheck()
{
    if !WinExist(editors.Premiere.winTitle)
        {
            SetTimer(, 0)
            return
        }
    checkKey("RButton")
    ;checkKey("LButton") ;don't do this, things break
    checkKey("XButton2")
    checkKey("\")
}