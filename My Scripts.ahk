#SingleInstance Force
SetWorkingDir A_ScriptDir
SetNumLockState "AlwaysOn" ;sets numlock to always on
SetCapsLockState "AlwaysOff" ;sets caps lock to always off (you can still use caps lock for macros)
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\Icons\myscript.png") ;changes the icon this script uses in the taskbar
#Include "C:\Program Files\ahk\MS_functions.ahk" ;includes function definitions so they don't clog up this script

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.2.8
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.0.3

;\\CURRENT RELEASE VERSION
;\\v2.0

; ===========================================================================================================================================================
;
; 														THIS SCRIPT IS FOR v2.0 OF AUTOHOTKEY
;				 											IT WILL NOT RUN IN v1.1
;
;												Everything in this script is functional within v2.0
; ===========================================================================================================================================================
;
; This script was created by & for Tomshi (https://www.youtube.com/c/tomshiii, https://www.twitch.tv/tomshi)
; Its purpose is to help speed up editing and random interactions with windows.
; You are free to modify this script to your own personal uses/needs
; Please give credit to the foundation if you build on top of it, similar to how I have below, otherwise you're free to do as you wish
;
; ===========================================================================================================================================================

; A chunk of the code in this script was either directly inspired by, or originally copied from Taran from LTT (https://github.com/TaranVH/) before I modified it to fit v2.0 of ahk,
; his videos on the subject are what got me into AHK to begin with and what brought the foundation of the original version of this script to life
; I use a streamdeck to run a lot of these scripts which is why a bunch of them are bound to F13-24 but really they could be replaced with anything
; basic AHK is about all I know relating to code so the layout might not be "standard" but it helps me read it and maintain it which is more important since it's for personal use

; I use to use notepad++ to edit this script, if you want proper syntax highlighting in notepad++ for ahk go here: https://www.autohotkey.com/boards/viewtopic.php?t=50
; I now use VSCode which can be found here: https://code.visualstudio.com/
; AHK syntax highlighting can be installed within the program itself

;===========================================================================================================================================================================
;
;		Windows
;
;===========================================================================================================================================================================
#HotIf not WinActive("ahk_exe Adobe Premiere Pro.exe") ;code below here (until the next HotIf) will trigger as long as premiere pro isn't active
^!w:: ;this simply warps my mouse to my far monitor bc I'm lazy YEP
{
	coords()
	MouseMove 5044, 340
}

^!+w:: ;this simply warps my mouse to my main monitor bc I'm lazy YEP
{
	coords()
	MouseMove 1280, 720
}

^+a::Run "C:\Program Files\ahk" ;opens my script directory

;!a:: ;edit %a_ScriptDir% ;opens this script in notepad++ if you replace normal notepad with ++ \\don't recommend using this way at all, replacing notepad kinda sucks
;!a:: Run *RunAs "C:\Program Files (x86)\Notepad++\notepad++.exe" "%A_ScriptFullPath%" ;opens in notepad++ without needing to fully replace notepad with notepad++ (preferred) \\use this way
;Opens as admin bc of how I have my scripts located, if you don't need it elevated, remove *RunAs
!a:: ;ignore this version, comment it out and uncomment ^ for notepad++
{
	if WinExist("ahk_exe Code.exe") ;if vscode exists it'll simply activate it, if it doesn't, it'll open it
			WinActivate
	else
		Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe" ;opens in vscode (how I edit it)
}

!r::
{
	Reload
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	;MsgBox "The script could not be reloaded. Would you like to open it for editing?",, 4
	Result := MsgBox("The script could not be reloaded. Would you like to open it for editing?",, 4)
		if Result = "Yes"
			{
				if WinExist("ahk_exe Code.exe")
						WinActivate
				else
					Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe"
			}
}

^+d:: ;Make discord bigger so I can actually read stuff when not streaming
{
	if WinExist("ahk_exe Discord.exe")
	WinMove 4480, -260, 1080, 1488
}

^SPACE::WinSetAlwaysOnTop -1, "A" ; will toggle the current window to remain on top

NumpadDiv::Run "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"

^+c:: ;runs a google search of highlighted text
{
    Send "^c"
    Sleep 50
    Run "https://www.google.com/search?d&q=%clipboard%"
}

#HotIf WinActive("ahk_exe Discord.exe") ;some scripts to speed up discord interactions
^e::discedit() ;edit the message you're hovering over
^r::discreply() ;reply to the message you're hovering over
^!a::discreac() ;add a reaction to the message you're hovering over

;===========================================================================================================================================================================
;
;		Photoshop
;
;===========================================================================================================================================================================
#HotIf WinActive("ahk_exe Photoshop.exe")
^+p:: ;When highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
{
	SetKeyDelay 300 ;photoshop is sometimes slow as heck, delaying things just a bit ensures you get the right thing every time
		Send "{TAB}{RIGHT}"
		SendInput "{Up 21}" ;makes sure you have the top most option selected
		sleep 50 ;this probably isn't needed, but I have here for saftey just because photoshop isn't the best performance wise
		SendInput "{DOWN 17}"
		Send "{Enter}+{Tab}"
}

Xbutton2::mousedrag("p") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset

;===========================================================================================================================================================================
;
;		After Effects
;
;===========================================================================================================================================================================
#HotIf WinActive("ahk_exe AfterFX.exe")
Xbutton1::timeline("981") ;check MS_functions.ahk for the code to this preset
Xbutton2::mousedrag("v") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset

;===========================================================================================================================================================================
;
;		Premiere
;
;===========================================================================================================================================================================
#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")

;There use to be a lot of scripts about here in the script, they have since been removed and moved to their own individual .ahk files as launching them directly
;via a streamdeck is far more effecient; 1. because I only ever launch them via the streamdeck anyway & 2. because that no longer requires me to eat up a hotkey
;that I could use elsewhere, to run them. These mentioned scripts can be found in the \Streamdeck AHK\ folder.

CapsLock & z::^+!z ;\\set zoom out to ^+!z\\
CapsLock & v:: ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it
{
	coords()
	MouseGetPos &xpos, &ypos
	MouseMove 34, 917 ;location of the selection tool
	click
	MouseMove %&xpos%, %&ypos%
}
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;		hold and drag (or click)
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
F1:: ;press then hold F1 and drag to increase/decrese scale. Let go of F1 to confirm, Simply Tap F1 to reset values
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
		MouseMove 227, 1101 ;move to the "scale" value
		sleep 100
		SendInput "{Click Down}"
			if GetKeyState("F1", "P")
			{
				blockOff()
				KeyWait "F1"
				SendInput "{Click Up}"
				MouseMove %&xpos%, %&ypos%
			}
			else
			{
				fElse("100") ;check MS_functions.ahk for the code to this preset
				MouseMove %&xpos%, %&ypos%
				blockOff()
			}
}

F2:: ;press then hold F2 and drag to increase/decrese x value. Let go of F2 to confirm, Simply Tap F2 to reset values
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
		MouseMove 226, 1079 ;move to the "x" value
		sleep 100
		SendInput "{Click Down}"
			if GetKeyState("F2", "P")
			{
				blockOff()
				KeyWait "F2"
				SendInput "{Click Up}"
				MouseMove %&xpos%, %&ypos%
			}
			else
			{
				fElse("960") ;check MS_functions.ahk for the code to this preset
				MouseMove %&xpos%, %&ypos%
				blockOff()
			}
}

F3:: ;press then hold F3 and drag to increase/decrese y value. Let go of F3 to confirm, Simply Tap F3 to reset values
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	MouseMove 275, 1080 ;move to the "y" value
	sleep 100
	SendInput "{Click Down}"
		if GetKeyState("F3", "P")
		{
			blockOff()
			KeyWait "F3"
			SendInput "{Click Up}"
			MouseMove %&xpos%, %&ypos%
		}
		else
		{
			fElse("540") ;check MS_functions.ahk for the code to this preset
			MouseMove %&xpos%, %&ypos%
			blockOff()
		}
}

F4:: ;press then hold F4 and drag to move position. Let go of F4 to confirm, Simply Tap F4 to reset values
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	MouseMove 142, 1059
	sleep 100
		if GetKeyState("F4", "P") ;gets the state of the f4 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
		{ ;you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable move to the preview window
			Click ;move to the "motion" tab
			MouseMove 2300, 238 ;move to the preview window
			SendInput "{Click Down}"
			blockOff()
			KeyWait "F4"
			SendInput "{Click Up}"
			;MouseMove %&xpos%, %&ypos% ; // moving the mouse position back to origin after doing this is incredibly disorienting
		}
		else
		{
			MouseMove 352, 1076
			Click
			sleep 50
			MouseMove %&xpos%, %&ypos%
			blockOff()
		}
}

F5:: ;press then hold F5 and drag to increase/decrease rotation. Let go of F5 to confirm, Simply Tap F5 to reset values
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	MouseMove 219, 1165 ;move to the "rotation" value
	sleep 100
	SendInput "{Click Down}"
		if GetKeyState("F5", "P")
		{
			blockOff()
			KeyWait "F5"
			SendInput "{Click Up}"
			MouseMove %&xpos%, %&ypos%
		}
		else
		{
			fElse("0") ;check MS_functions.ahk for the code to this preset
			MouseMove %&xpos%, %&ypos%
			blockOff()
		}
}

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;		NUMPAD SCRIPTS
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Numpad7:: ;This script moves the mouse to a pixel position to highlight the "motion tab" then menu and change values to zoom into a custom coord and zoom level
{
	num() ;check MS_functions.ahk for the code to this preset
	SendInput "{Tab}1912{Tab}0{Tab}200{ENTER}"
	SendInput "{Enter}"
	blockOff()
}

Numpad8:: ;This script moves the mouse to a pixel position to highlight the "motion tab" then menu and change values to zoom into a custom coord and zoom level
{
	num() ;check MS_functions.ahk for the code to this preset
	SendInput "{Tab}2880{Tab}-538{Tab}300"
	SendInput "{Enter}"
	blockOff()
}

Numpad9:: ;This script moves the mouse to a pixel position to reset the "motion" effects
{
	coordw()
	blockOn()
	MouseGetPos &xpos, &ypos
		SendInput "^+9"
		SendInput "{F12}" ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
		MouseMove 359, 1063 ;location for the reset arrow
		;SendInput, {WheelUp 10} ;if you do this, for whatever reason "click" no longer works without an insane amount of delay, idk why
		click
	MouseMove %&xpos%, %&ypos%
	blockOff()
}

Numpad1::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}-2{ENTER}" ;REDUCE GAIN BY -2db
Numpad2::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}2{ENTER}" ;INCREASE GAIN BY 2db == set g to open gain window
Numpad3::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}6{ENTER}" ;INCREASE GAIN BY 6db

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;		Drag and Drop Effect Presets
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
!g::preset("gaussian blur 20") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags one of these presets onto the hovered track
!p::preset("parametric") ;check MS_functions.ahk for the code for these presets
!h::preset("hflip") 
!c::preset("croptom") 

!t:: ;hover over a text element on the timeline, press this hotkey, then watch as ahk drags that preset onto the hovered track
{
	blockOn()
	coords()
	MouseGetPos &xpos, &ypos
		MouseMove 205, 1039 ;move to the top of the effects panel to allow WheelUp to work
		sleep 100
		SendInput "{WheelUp 10}"
		MouseMove 31, 1080 ;hover over the hide/show eye for the default text created on a new text layer
		sleep 500 ;apparently if you don't give premiere half a second before trying to hide a text layer, it just doesn't click?? or it's ahk??
		Click
		sleep 100
		preset("loremipsum")
		MouseMove %&xpos%, %&ypos% ;although this line is usually in the ^preset, if you don't add it again, your curosr gets left on the text eyeball instead of back on the timeline 
}

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WheelRight::+Down ;Set shift down to "Go to next edit point on any track"
WheelLeft::+Up ;Set shift up to "Go to previous edit point on any track
Xbutton1::^w ;Set ctrl w to "Nudge Clip Selection Down"
Xbutton2::mousedrag("v") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset





/*
;===========================================================================================================================================================================
						OLD \\ Nothing below here has been adapted for use with ahk v2.0
;===========================================================================================================================================================================
F6:: ;how to move mouse on one axis
SetKeyDelay, 0
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseGetPos, xposP, yposP
MouseMove, xposP, 513,, R
Return
F6:: ;how to move mouse on one axis, relative to current position
SetKeyDelay, 0
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseMove, 0, 513,, R
Return
*/

#HotIf not WinActive("ahk_exe Adobe Premiere Pro.exe")
/*
;Detatch a firefox tab
#IfWinActive ahk_exe firefox.exe
F14:: ;detatch a tab when it fails to do so
SendInput, !d
sleep, 100
Send, +{TAB}
sleep, 100
Send, +{TAB}
sleep, 100
Send, +{TAB}
sleep, 200
Send, +{F10}
sleep, 200
Send, v
sleep, 200
Send, w
sleep, 200
Return
*/

;change obs profile
/*
F9::
SendInput, !p
SendInput, {DOWN 7}
SendInput, {ENTER}
Return
*/

/*
;open obs and change its profle
^+!o::  ;====learning how WinActivate works====
Run, C:\Program Files\AHK\obs64.lnk
if WinExist("ahk_exe obs64.exe")
	WinActivate
else
	WinWaitActive, ahk_exe obs64.exe
sleep 1000
SendInput, !p
SendInput, {DOWN 7}
SendInput, {ENTER}
Return
*/

/*
~~~~~~~~~~~~~~~~~Timecode Scripts~~~~~~~~~~~~~~~~~
^!c:: ;moves the mouse to the timecode and copies it  //these were mostly for the beginner tutorial, I don't use anymore
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
MouseGetPos, xposP, yposP
	MouseMove, 79,93
	SendInput, {Click}
	SendInput, ^c
MouseMove, %xposP%, %yposP%
	SendInput, {Click}
blockinput, MouseMoveOff
BlockInput, off
Return
^+c:: ;moves the mouse to the timecode and clicks it
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
	MouseMove, 79,93
	SendInput, {Click}
	SendInput, ^c
blockinput, MouseMoveOff
BlockInput, off
Return
*/

/*
;currently replaced by the push to audition streamdeck script
;=========================================================
;		Audition
;=========================================================
#IfWinActive ahk_exe Adobe Audition.exe
F13:: ;Moves mouse and applies Limit preset, then normalises to -3db
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	MouseMove, 300, 380
	SendInput, {Click}l{DOWN 3}{ENTER}
	sleep, 5
	MouseMove, 92, 717
	SendInput, {Click}
	sleep, 2200
	SendInput, !rnn{ENTER}
MouseMove, %xposP%, %yposP%
blockinput, MouseMoveOff
BlockInput, off
Return
*/