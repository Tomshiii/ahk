#SingleInstance Force
SetWorkingDir A_ScriptDir
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\streaming.ico") ;changes the icon this script uses in the taskbar
;#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
#SingleInstance Force

;	//////////////////////////////////////////////////////////////////////////////////////////////
;
;	This file exists because obs must be run as admin for the best performance
;	And I don't want to bother running my main script as admin 24/7 just for streaming
;	So this script will open alongside everything else for stream to allow for my macros
;
;	//////////////////////////////////////////////////////////////////////////////////////////////
; This is just so I have a way to relaunch it manually as admin for debugging purposes
F6::Run '*RunAs "C:\Program Files\ahk\ahk\Streaming.ahk"'

;===========================================================================================================================================================================
;
;		Stream
;
;===========================================================================================================================================================================
#HotIf not WinActive("ahk_exe Adobe Premiere Pro.exe")
F17::Run "C:\Program Files\ahk\ahk\TomSongQueueue\Builds\SongQueuer.exe" ;lioranboard sends f17 when channel point reward comes through, this program then plays the sound
F16::  ;temporary way to play full mii wii song using lioranboard
{
	Run(A_WorkingDir "\Sounds\Wii Music.mp3")
	sleep 105000
	WinClose("ahk_exe vlc.exe")
}


#HotIf WinExist("ahk_exe obs64.exe")
^+r:: ;this script is to trigger the replay buffer in obs, as well as the source record plugin, I use this to save clips of stream
{
	if WinExist("ahk_exe obs64.exe")
		WinActivate 
	sleep 1000
	SendInput "^p" ;Main replay buffer hotkey must be set to this
	SendInput "^+8" ;Source Record OBS Plugin replay buffer must be set to this
	;sleep 10
	;SendInput, ^+9 ;Source Record OBS Plugin replay buffer must be set to this
	sleep 10
}

F22:: ;opens editing playlist, moves vlc into a small window, changes its audio device to goxlr
{
	SetKeyDelay 100 ;adds 100ms of delay between each "send" input (vlc can't take inputs too fast so this helps)
		run "D:\Program Files\User\Music\pokemon.xspf"
			if WinExist("ahk_exe vlc.exe")
				WinActivate
			else
				WinWait "ahk_exe vlc.exe"
		if WinExist("ahk_exe vlc.exe")
		WinMove 2066, 0, 501, 412
		Send "!ad{Down 3}{enter}"
}