#SingleInstance Force
SetWorkingDir, %A_ScriptDir%
SetNumLockState, AlwaysOn ;sets numlock to always on
SetCapsLockState, AlwaysOff ;sets caps lock to always off (you can still use caps lock for macros)
SetDefaultMouseSpeed, 0
I_Icon = C:\Program Files\ahk\Icons\myscript.png ;you'll need to change this path \\this code changes the icon for the script
ICON [I_Icon]                        ;Changes a compiled script's icon (.exe)
if I_Icon <>
IfExist, %I_Icon%
	Menu, Tray, Icon, %I_Icon%   ;Changes menu tray icon

;\\CURRENT SCRIPT VERSION
;\\v1.0.2

;\\CURRENT RELEASE VERSION
;\\v1.0

; ===========================================================================================================================================================
;
; 										THIS SCRIPT IS FOR v1.1 OF AUTOHOTKEY
;				 					IT WILL NOT RUN IN v2.0 WITHOUT HEAVY MODIFICATION
;
;						I hope to one day port funcitonality to v2.0 - that will take a long time though as
;							I am not a programmer, and a lot of the 2.0 changes go right over my head
;
; ===========================================================================================================================================================
;
; This script was created by & for Tomshi (https://www.youtube.com/c/tomshiii, https://www.twitch.tv/tomshi)
; Its purpose is to help speed up editing and random interactions with windows.
; You are free to modify this script to your own personal uses/needs
; Please give credit to the foundation if you build on top of it, similar to how I have below, otherwise you're free to do as you wish
;
; ===========================================================================================================================================================

; A chunk of the code in this script was either directly inspired by, or copied from Taran from LTT (https://github.com/TaranVH/), his videos on the subject
; are what got me into AHK to begin with and what brought the foundation of this script to life
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
#IfWinNotActive ahk_exe Adobe Premiere Pro.exe
^!w:: ;this simply warps my mouse to my far monitor bc I'm lazy YEP
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseMove, 5044, 340
return

^+a::Run, C:\Program Files\ahk ;opens my script directory

;!a:: ;edit %a_ScriptDir% ;opens this script in notepad++ if you replace normal notepad with ++ \\don't recomment using this way at all, replacing notepad kinda sucks
;!a:: Run *RunAs "C:\Program Files (x86)\Notepad++\notepad++.exe" "%A_ScriptFullPath%" ;opens in notepad++ without needing to fully replace notepad with notepad++ (preferred) \\use this way
;Opens as admin bc of how I have my scripts located, if you don't need it elevated, remove *RunAs
!a:: ;ignore this version, comment it out and uncomment ^ for notepad++
if WinExist("ahk_exe Code.exe")
			WinActivate
		else
			Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe" ;opens in vscode (how I edit it)
return

!r::
Reload
Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
IfMsgBox, Yes, {
	if WinExist("ahk_exe Code.exe")
			WinActivate
	else
			Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe"
		}
return

^+d::WinMove, ahk_exe Discord.exe,, 4480, -260, 1080, 1488 ;Make discord bigger so I can actually read stuff when not streaming

F22:: ;opens editing playlist, moves vlc into a small window, changes its audio device to goxlr
SetKeyDelay, 100
SetWinDelay, 0
	run, D:\Program Files\User\Music\pokemon.xspf
		if WinExist("ahk_exe vlc.exe")
			WinActivate
		else
			WinWaitActive, ahk_exe vlc.exe
	WinMove, VLC media player,, 2066, 0, 501, 412 ;isn't working atm??
	Send, !ad{Down 3}{enter} ;using the alt menu is infinitely faster and more effecient than using the "cycle audio devices" hotkey within vlc

^SPACE::WinSet, AlwaysOnTop, -1, A ; will toggle the current window to remain on top

NumpadDiv::Run, C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE

^+c:: ;runs a google search of highlighted text
    Send, ^c
    Sleep 50
    Run, https://www.google.com/search?d&q=%clipboard%
    Return
;===========================================================================================================================================================================
;
;		Stream
;
;===========================================================================================================================================================================
#IfWinNotActive ahk_exe Adobe Premiere Pro.exe

F17:: ;lioranboard sends f17 when channel point reward comes through, this program then plays the sound
Run, C:\Program Files\ahk\TomSongQueueue\Builds\SongQueuer.exe
Return

#IfWinExist ahk_exe obs64.exe
^+r:: ;this script is to trigger the replay buffer in obs, as well as the source record plugin, I use this to save clips of stream
	WinActivate ahk_exe obs64.exe
	sleep 1000
	SendInput, ^p ;Main replay buffer hotkey must be set to this
	SendInput, ^+8 ;Source Record OBS Plugin replay buffer must be set to this
	;sleep 10
	;SendInput, ^+9 ;Source Record OBS Plugin replay buffer must be set to this
	sleep 10
Return

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

;===========================================================================================================================================================================
;
;		Photoshop
;
;===========================================================================================================================================================================
#IfWinActive ahk_exe Photoshop.exe
^+p:: ;When highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
SetKeyDelay, 300 ;photoshop is sometimes slow as heck, delaying things just a bit ensures you get the right thing every time
	Send, {TAB}{RIGHT}
	SendInput, {Up 21} ;makes sure you have the top most option selected
	sleep 50 ;this probably isn't needed, but I have here for saftey just because photoshop isn't the best performance wise
	SendInput, {DOWN 17}
	Send, {Enter}+{Tab}
Return

Xbutton2:: ;changes the tool to the hand tool while mouse button is held
	click middle
	SendInput, {h}{LButton Down} ;set hand tool to "h"
	KeyWait, Xbutton2
	SendInput, {LButton Up}{p} ;swaps to the pen tool so you can keep on rotoscoping ez
Return

;===========================================================================================================================================================================
;
;		Premiere
;
;===========================================================================================================================================================================
#IfWinActive ahk_exe Adobe Premiere Pro.exe
;===========================================================================================================================================================================
;
;		hold and drag (or click)
;
;===========================================================================================================================================================================
F1:: ;press then hold alt and drag to increase/decrese scale. Let go of alt to confirm
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse ;// can't use block input as you need to drag the mouse
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	MouseMove, 227, 1101
	sleep 100
	SendInput, {Click Down}
GetKeyState, stateFirstCheck, F1, P ;gets the state of the f1 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			Click up left
			sleep 10
			Send, 100
			;MouseMove, x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
			;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
			sleep 50
			send, {enter}
			;MouseMove, %xposP%, %yposP% ;if you want to press the reset arrow, uncomment this line
			;blockinput, MouseMoveOff ;if you want to press the reset arrow, uncomment this line
			;BlockInput, off ;if you want to press the reset arrow, uncomment this line
		}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, F1
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP%
Return

F2:: ;press then hold alt and drag to increase/decrese x position. Let go of alt to confirm
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	MouseMove, 226, 1079
	sleep 100
	SendInput, {Click Down}
GetKeyState, stateFirstCheck, F2, P ;gets the state of the f2 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			Click up left
			sleep 10
			Send, 960 ;I always edit in a 1080p timeline so it's just easier to input those values, you could MouseMove over to the reset arrow instead like F2 if that's better for you
			;MouseMove, x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
			;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
			sleep 50
			send, {enter}
			;MouseMove, %xposP%, %yposP% ;if you want to press the reset arrow, uncomment this line
			;blockinput, MouseMoveOff ;if you want to press the reset arrow, uncomment this line
			;BlockInput, off ;if you want to press the reset arrow, uncomment this line
		}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, F2
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP%
Return

F3:: ;press then hold alt and drag to increase/decrese y position. Let go of alt to confirm
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	MouseMove, 275, 1080
	sleep 100
	SendInput, {Click Down}
GetKeyState, stateFirstCheck, F3, P ;gets the state of the f3 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			Click up left
			sleep 10
			Send, 540 ;I always edit in a 1080p timeline so it's just easier to input those values, you could MouseMove over to the reset arrow instead like F2 if that's better for you
			;MouseMove, x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
			;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
			sleep 50
			send, {enter}
			;MouseMove, %xposP%, %yposP% ;if you want to press the reset arrow, uncomment this line
			;blockinput, MouseMoveOff ;if you want to press the reset arrow, uncomment this line
			;BlockInput, off ;if you want to press the reset arrow, uncomment this line
		}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, F3
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP%
Return

F4:: ;press then hold alt and drag to move position. Let go of alt to confirm
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse
BlockInput, MouseMove
;MouseGetPos, xposP, yposP ;if you wish to use the reset arrow, uncomment this line
BlockInput, On
	Click 142 1059
	sleep 100
GetKeyState, stateFirstCheck, F4, P ;gets the state of the f4 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			MouseMove, 352, 1076
			;MsgBox, you've moved to the position
			sleep 50
			Send, {click left}
			blockinput, MouseMoveOff
			BlockInput, off
			MouseMove, %xposP%, %yposP%
			return
		}
else					;you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract
	MouseMove, 2300, 238 ;with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable
	SendInput, {Click Down}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, F4
	SendInput, {Click Up}
;MouseMove, %xposP%, %yposP% ; // moving the mouse position back to origin after doing this is incredibly disorienting
;MouseMove, %xposP%, %yposP% ; // moving the mouse position back to origin after doing this is incredibly disorienting
Return

F5:: ;press then hold alt and drag to increase/decrese scale. Let go of alt to confirm
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse ;// can't use block input as you need to drag the mouse
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	MouseMove, 219, 1165
	sleep 100
	SendInput, {Click Down}
GetKeyState, stateFirstCheck, F5, P ;gets the state of the f5 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			Click up left
			sleep 10
			Send, 0 ;resets rotation to 0
			sleep 50
			send, {enter}
		}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, F5
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP%
Return

;===========================================================================================================================================================================
;
;		NUMPAD SCRIPTS
;
;===========================================================================================================================================================================
Numpad7:: ;This script moves the mouse to a pixel position to highlight the "motion tab" then menu and change values to zoom into a custom coord and zoom level
	SendInput, ^+9
	SendInput, ^{F5} ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	;Send ^+8 ;highlight the effect control panel
	;Send ^+8 ;again because adobe is dumb and sometimes doesn't highlight if you're fullscreen somewhere
	click, 214, 1016
	SendInput, {WheelUp 30}
	MouseMove, 122,1060 ;location for "motion"
	SendInput, ^+k ;shuttle stop. idk why this one is still here, but uh, leave it since it's not breaking anything
	SendInput, {Click}
	SendInput, {Tab}1912{Tab}0{Tab}200{ENTER}
MouseMove, %xposP%, %yposP%
blockinput, MouseMoveOff
BlockInput, off
Return

Numpad8:: ;This script moves the mouse to a pixel position to highlight the "motion tab" then menu and change values to zoom into a custom coord and zoom level
	SendInput, ^+9
	SendInput, ^{F5} ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	MouseGetPos, xposP, yposP
	click, 214, 1016
	SendInput, {WheelUp 30}
	MouseMove, 122,1060
	SendInput, {Click}
	SendInput, {Tab}2880{Tab}-538{Tab}300
	SendInput, {Enter}
MouseMove, %xposP%, %yposP%
blockinput, MouseMoveOff
BlockInput, off
Return

Numpad9:: ;This script moves the mouse to a pixel position to reset the "motion" effects
	SendInput, ^+9
	SendInput, {F12} ;highlights the timeline, then changes the track colour so I know that clip has been reset back to normal
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	MouseMove, 359, 1063
	;SendInput, {WheelUp 10} ;if you do this, for whatever reason "click" no longer works without an insane amount of delay, idk why
	click
MouseMove, %xposP%, %yposP%
blockinput, MouseMoveOff
BlockInput, off
Return

Numpad2:: ;INCREASE GAIN BY 2db == set g to open gain window
	SendInput, g
	SendInput, +{Tab}{UP 3}{DOWN}{TAB}2{ENTER}
Return

Numpad1:: ;REDUCE GAIN BY -2db
	SendInput, g
	SendInput, +{Tab}{UP 3}{DOWN}{TAB}-2{ENTER}
Return

Numpad3:: ;INCREASE GAIN BY 6db
	SendInput, g
	SendInput, +{Tab}{UP 3}{DOWN}{TAB}6{ENTER}
Return

;===========================================================================================================================================================================
;
;		Drag and Drop Effect Presets
;
;===========================================================================================================================================================================
!g:: ;hover over a track on the timeline, press this hotkey, then watch as ahk drags that preset onto the hovered track
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
	SendInput, ^a{DEL}
	SendInput, gaussian blur 20 ;create a preset of blur effect with this name, must be in a folder as well
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseGetPos, xposP, yposP
	MouseMove, 3354, 259
	sleep 100
	MouseMove, 40, 68,, R
	SendInput, {Click Down}
MouseMove, %xposP%, %yposP%
	SendInput, {Click Up}
blockinput, MouseMoveOff
BlockInput, off
Return

!p:: ;hover over a track on the timeline, press this hotkey, then watch as ahk drags that preset onto the hovered track
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
	SendInput, ^a{DEL}
	SendInput, parametric ;create parametric eq preset with this name, must be in a folder as well
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseGetPos, xposP, yposP
	MouseMove, 3354, 259
		Sleep 100
	MouseMove, 40, 68,, R
	SendInput, {Click Down}
MouseMove, %xposP%, %yposP%
	SendInput, {Click Up}
blockinput, MouseMoveOff
BlockInput, off
Return

!h:: ;hover over a track on the timeline, press this hotkey, then watch as ahk drags that preset onto the hovered track
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
	SendInput, ^a{DEL}
	SendInput, hflip ;create hflip preset with this name, must be in a folder as well
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseGetPos, xposP, yposP
	MouseMove, 3354, 259
		sleep 100
	MouseMove, 40, 68,, R
	SendInput, {Click Down}
MouseMove, %xposP%, %yposP%
	SendInput, {Click Up}
blockinput, MouseMoveOff
BlockInput, off
Return

!c:: ;hover over a track on the timeline, press this hotkey, then watch as ahk drags that preset onto the hovered track
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
	SendInput, ^a{DEL}
	SendInput, croptom ;create croptom preset with this name, must be in a folder as well
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseGetPos, xposP, yposP
	MouseMove, 3354, 259
		sleep 100
	MouseMove, 40, 68,, R
	SendInput, {Click Down}
MouseMove, %xposP%, %yposP%
	SendInput, {Click Up}
blockinput, MouseMoveOff
BlockInput, off
Return

!t:: ;hover over a text element on the timeline, press this hotkey, then watch as ahk drags that preset onto the hovered track
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
	SendInput, ^a{DEL}
	SendInput, loremipsum ;create loremipsum preset with this name, must be in a folder as well
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseGetPos, xposP, yposP
	MouseMove, 205, 1039
	sleep 100
	SendInput, {WheelUp 10}
	MouseMove, 31, 1080
	sleep 500 ;apparently if you don't give premiere half a second before trying to hide a text layer, it just doesn't click?? or it's ahk??
	Click, Left
	sleep 100
	MouseMove, 3354, 259
	MouseMove, 40, 68,, R
	SendInput, {Click Down}
MouseMove, %xposP%, %yposP%
	SendInput, {Click Up}
blockinput, MouseMoveOff
BlockInput, off
Return

;===========================================================================================================================================================================
;
;		Mouse Scripts
;
;===========================================================================================================================================================================
WheelRight:: +Down ;Set shift down to "Go to next edit point on any track"
WheelLeft:: +Up ;Set shift up to "Go to previous edit point on any track
;F14::^+w ;Set mouse button to always spit out f14, then set ctrl shift w to "Nudge Clip Selection up"

Xbutton1::^w ;Set ctrl w to "Nudge Clip Selection Down"

Xbutton2:: ;changes the tool to the hand tool while mouse button is held
	click middle
	SendInput, {h}{LButton Down} ;set hand tool to "h"
	KeyWait, Xbutton2
	SendInput, {LButton Up}{v} ;set select tool to v
Return





/*
;===========================================================================================================================================================================
						OLD
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

#IfWinNotActive ahk_exe Adobe Premiere Pro.exe
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