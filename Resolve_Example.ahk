#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
; SetNumLockState, AlwaysOn ;uncomment if you want numlock to always be ON
; SetCapsLockState, AlwaysOff uncomment if you want capslock to always be OFF


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; ALL PIXEL VALUES WILL NEED TO BE ADJUSTED IF YOU AREN'T USING A 1440p MONITOR (AND MIGHT STILL EVEN IF YOU ARE)

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; This is an example script I've created for davinci resolve porting over some similar functionality I use
; in my premiere scripts. Things aren't as clean and there may be better ways to do things
; keep in mind I don't use resolve and I've just cooked this up as an example for you to mess with yourself

;=========================================================
;		DAVINCI RESOLVE
;=========================================================
#IfWinActive ahk_exe Resolve.exe

;=========================================================
;		hold and drag (or click)
;=========================================================
; ///// for these scripts to work, the inspector tab must be open and scrolled to the top
; ///// you could add functionality to scroll up a few times if you run into that being an issue a lot

F1::
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse ;// can't use block input as you need to drag the mouse
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2196, 139 ;this highlights the video tab
	MouseMove, 2329, 215 ;moves to the scale value
	sleep 100
	SendInput, {Click Down}
GetKeyState, stateFirstCheck, F1, P ;gets the state of the f1 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			Click up left
			sleep 10
			Send, 1
			;MouseMove, x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
			;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
			sleep 50
			send, {enter}
			click 2295, 240 ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
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

/*
;Not entirely sure Resolve has similar function to premiere where you can reposition a clip by draggin it around in the preview window
F2:: ;press then hold alt and drag to move position. Let go of alt to confirm 
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
;MouseGetPos, xposP, yposP ;if you wish to use the reset arrow, uncomment this line
BlockInput, On
SetDefaultMouseSpeed 0
	Click 142 1059 ;you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract 
	sleep 100
GetKeyState, stateFirstCheck, F2, P ;gets the state of the f1 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			MouseMove, 418, 1055
			;MsgBox, you've moved to the position
			sleep 50
			Send, {click left}
			blockinput, MouseMoveOff
			BlockInput, off
			MouseMove, %xposP%, %yposP% 
			return
		}
else
	MouseMove, 2300, 238 ;with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable
	SendInput, {Click Down}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, F2
	SendInput, {Click Up}
;MouseMove, %xposP%, %yposP% ; // moving the mouse position back to origin after doing this is incredibly disorienting 
;MouseMove, %xposP%, %yposP% ; // moving the mouse position back to origin after doing this is incredibly disorienting 
Return
*/

F3:: ;press then hold alt and drag to increase/decrese x position. Let go of alt to confirm 
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse 
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2196, 139 ;this highlights the video tab
	MouseMove, 2332, 239 ;moves to the x axis value
	sleep 100
	SendInput, {Click Down}
GetKeyState, stateFirstCheck, F3, P ;gets the state of the f1 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			Click up left
			sleep 10
			Send, 0 
			;MouseMove, x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
			;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
			sleep 50
			send, {enter}
			click 2295, 240 ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
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

F4:: ;press then hold alt and drag to increase/decrese y position. Let go of alt to confirm 
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse 
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2196, 139 ;this highlights the video tab
	MouseMove, 2457, 240 ;moves to the y axis value
	sleep 100
	SendInput, {Click Down}
GetKeyState, stateFirstCheck, F4, P ;gets the state of the f1 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			Click up left
			sleep 10
			Send, 0 
			;MouseMove, x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
			;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
			sleep 50
			send, {enter}
			click 2295, 240 ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
			;MouseMove, %xposP%, %yposP% ;if you want to press the reset arrow, uncomment this line
			;blockinput, MouseMoveOff ;if you want to press the reset arrow, uncomment this line
			;BlockInput, off ;if you want to press the reset arrow, uncomment this line
		}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, F4
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP% 
Return

F5:: ;press then hold alt and drag to increase/decrese scale. Let go of alt to confirm 
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse ;// can't use block input as you need to drag the mouse
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2196, 139 ;this highlights the video tab
	MouseMove, 2456, 265 ;moves to the rotation value
	sleep 100
	SendInput, {Click Down}
GetKeyState, stateFirstCheck, F5, P ;gets the state of the f1 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
	if stateFirstCheck = U ;this function just does what I describe above
		{
			Click up left
			sleep 10
			Send, 0 ;resets rotation to 0
			sleep 50
			send, {enter}
			click 2295, 240 ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
		}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, F5
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP% 
Return

;=========================================================
;		flips
;=========================================================
!h:: ;flip horizontally
SetDefaultMouseSpeed 0
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse 
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2196, 139 ;this highlights the video tab
	click 2301, 363
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

!v:: ;flip vertically
SetDefaultMouseSpeed 0
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse 
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2196, 139 ;this highlights the video tab
	click 2340, 367
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

;=========================================================
;		Scale Adjustments
;=========================================================
^1:: ;makes the scale of current selected clip 100
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2333, 218 ;clicks on video
	SendInput, 1{ENTER} ;effectively 100%
	click 2292, 215 ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

^2:: ;makes the scale of current selected clip 100
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2333, 218 ;clicks on video
	SendInput, 2{ENTER} ;effectively 200%
	click 2292, 215 ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

^3:: ;makes the scale of current selected clip 100
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	click 2333, 218 ;clicks on video
	SendInput, 3{ENTER} ;effectively 300%
	click 2292, 215 ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return




;=========================================================
;		other
;=========================================================

/*
Numpad1::
SetDefaultMouseSpeed 0
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse 
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	click 2257, 141 ;this highlights the audio tab
	click 2454, 216
	SendInput, -2
	MouseMove, 2495, 211
	click ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
blockinput, MouseMoveOff
BlockInput, off
MouseMove, %xposP%, %yposP%
Return
; This is great and all, but only lets you go to preset values, the best way in resolve is to just set a keyboard shortcut
; in the "audio" section to increase/decrease audio by 1/3db
*/