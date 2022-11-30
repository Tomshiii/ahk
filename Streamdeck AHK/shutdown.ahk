#SingleInstance Force
; { \\ #Includes
#Include <Classes\ptf>
; }

;This script by itself will do nothing but shutdown your pc. The reason I have it is so that I can launch it via a streamdeck multi action that also puts my goxlr into a sleep mode that turns off its rgb

if !WinExist("ahk_exe GoXLR App.exe")
    Run(ptf.ProgFi32 "\TC-Helicon\GOXLR\GoXLR App.exe")
WinWait("ahk_exe GoXLR App.exe")
value := MsgBox("Are you sure you wish to shutdown?", "Shutdown", "4 4096")
if value != "Yes"
    return
Shutdown 1