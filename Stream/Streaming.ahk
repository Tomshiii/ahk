#SingleInstance Force
SetWorkingDir(ptf.rootDir)
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon(ptf.Icons "\streaming.ico") ;changes the icon this script uses in the taskbar
#Requires AutoHotkey v2.0 ;this script requires AutoHotkey v2.0
#SingleInstance Force

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
; }

IniWrite(0, ptf["StreamINI"], "Number", "Left")

;	//////////////////////////////////////////////////////////////////////////////////////////////
;
;	This file exists because obs must be run as admin for the best performance
;	And I don't want to bother running my main script as admin 24/7 just for streaming
;	So this script will open alongside everything else for stream to allow for my macros
;
;	//////////////////////////////////////////////////////////////////////////////////////////////
; This is just so I have a way to relaunch it manually as admin for debugging purposes
F6::Run('*RunAs ' ptf["StreamAHK"])

;===========================================================================================================================================================================
;
;		Stream
;
;===========================================================================================================================================================================
#HotIf !WinActive(editors.Premiere.winTitle)

F17:: ;lioranboard sends f17 when channel point reward comes through
{
	songs := IniRead(ptf["StreamINI"], "Number", "Left")
	if songs = 1
		{
			KeyWait("F5", "D T105")
			IniWrite(songs - 1, ptf["StreamINI"], "Number", "Left")
			Run(ptf["SongQUEUE"])
			return
		}
	if songs = 0
		Run(ptf["SongQUEUE"])
}

F22::  ;temporary way to play full mii wii song using lioranboard
{
	songs := IniRead(ptf["StreamINI"], "Number", "Left")
	IniWrite(songs + 1, ptf["StreamINI"], "Number", "Left")
	Run(ptf["Wii Music"])
	sleep 105000
	if WinExist("ahk_exe vlc.exe")
		WinClose("ahk_exe vlc.exe")
	IniWrite(0, ptf["StreamINI"], "Number", "Left")
}


#HotIf WinExist("ahk_exe obs64.exe")
^+r:: ;this script is to trigger the replay buffer in obs, as well as the source record plugin, I use this to save clips of stream
{
	if WinExist("ahk_exe obs64.exe")
		WinActivate
	sleep 1000
	SendInput(replayBuffer) ;Main replay buffer hotkey must be set to this
	SendInput(sourceRecord1) ;Source Record OBS Plugin replay buffer must be set to this
	;sleep 10
	;SendInput, ^+9 ;Source Record OBS Plugin replay buffer must be set to this
	sleep 10
}