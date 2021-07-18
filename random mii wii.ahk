#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

; ================================================================================================================================

; This script is currently in testing, working with my brother (https://github.com/timetravelpenguin) to automate some things

; ================================================================================================================================


/*
F17::
;WinWait, ahk_exe notepad.exe
;add to stream startup script "run, C:\Users\Tom\AppData\Local\Programs\SoundSwitch\SoundSwitch.exe"
SendInput, !^{F11} ;swaps the playback device using "soundswitch"
Random, s, 1, 12
SoundPlay, %A_ScriptDir%\Sounds\wii%s%.wav, wait
sleep 100
SendInput, !^{F11} ;swaps the playback device using "soundswitch"
return

;can use lioranboard to send f17, but don't know how to buffer playback in ahk yet
/*