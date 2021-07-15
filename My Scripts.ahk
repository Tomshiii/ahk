#SingleInstance Force
SetWorkingDir, %A_ScriptDir%
SetNumLockState, AlwaysOn
; A lot of the code in this script was either directly inspired by, or copied from Taran from LTT (https://github.com/TaranVH/), his videos on the subject
; are what got me into AHK to begin with and what brought this entire script to life
; I use a streamdeck to run a lot of these scripts which is why most of them are bound to F13-24 but really they could be replaced with anything
; basic AHK is about all I know relating to code so the layout might not be "standard" but it helps me read it and maintain it which is more important since it's for personal use

;================Windows================
#IfWinNotActive ahk_exe Adobe Premiere Pro.exe
^+a:: ;opens my script directory
	Run, C:\Program Files\ahk
return

^+d:: ;Make discord bigger so I can actually read stuff when not streaming
	WinMove, ahk_exe Discord.exe,, 4480, -260, 1080, 1488
Return

F22:: ;opens editing playlist, moves vlc into a small window, changes its audio device to goxlr
	run, D:\Program Files\User\Music\pokemon.xspf
		if WinExist("ahk_exe vlc.exe")
			WinActivate
		else
			WinWaitActive, ahk_exe vlc.exe
	WinMove, VLC,,  2016, 34, 501, 412
	SendInput +a+a+a
Return
;================Stream================
#IfWinNotActive ahk_exe Adobe Premiere Pro.exe

F15:: ;Start everything for stream
SetWinDelay, 0 ;makes windows move instantly
	Run, C:\Program Files\ahk\obs64.lnk ;opening shortcuts helps to make sure obs and ahk have the same admin level so ahk can interact with it, otherwise obs wont accept inputs
		if WinExist("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus
			WinActivate
		else
			WinWaitActive, ahk_exe obs64.exe
	sleep 2500 ; you have to wait a while after obs opens before you can start sending it commands or it'll crash 
	SendInput, !p ;Opens alt context menu - The Above 2.5s sleep is essential as obs crashes if you instantly change the profile
	SendInput, {DOWN 7}
	SendInput, {ENTER} ;Changes profile to main stream profile.
	sleep 2000
	WinMove, OBS,,  2553, -892, 1111, 1047 ;Moves obs into position, important for me to keep because streamelements obs is wider and ruins main obs
{ ;this part of the script is just to set the source record hotkeys until they fix it
		WinActivate, ahk_exe obs64.exe
		SendInput, !f
		sleep 100
		SendInput, s
		sleep 2000
		SendInput, {DOWN 5}
		sleep 200
		SendInput, {TAB 52}
		sleep 200
		SendInput, ^+8
		sleep 1000
		SendInput, {TAB}
		SendInput, +{TAB 53}
		sleep 200
		SendInput, {UP}
		SendInput, {TAB}
		SendInput, {ENTER}
		sleep 200
}
	Run, firefox.exe https://docs.google.com/presentation/d/1b6pCuOIrw4pEF6GACxrBh8C-mB4XsDeHLM50cj4jAkQ/edit#slide=id.g90e8195d3c_16_958 ;opens the AM route doc to pauline questions
		if WinExist("ahk_exe firefox.exe")
			WinActivate
		else
			WinWaitActive, ahk_exe firefox.exe
	sleep 1000 ;waits before opening the next tab or firefox derps out
	Run, firefox.exe https://dashboard.twitch.tv/u/tomshi/stream-manager
	sleep 9000 ;if both tabs don't load in, it can mess with trying to separate them
		if WinExist("ahk_exe firefox.exe")
			WinActivate
		else
			WinWaitActive, ahk_exe firefox.exe ;the following code was yoinked from taran, it's just a deeper method of calling firefox forwards since sometimes it doesn't focus
			WinActivatebottom ahk_exe firefox.exe
			WinGet, hWnd, ID, ahk_class MozillaWindowClass
				DllCall("SetForegroundWindow", UInt, hWnd) 
	SendInput, !d ;opens the alt context menu to begin detatching the firefox tab
	sleep, 100 ;ahk is too fast for firefox, so we must be slow here
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
	sleep, 2000
	WinMove, Twitch,, -6, 0, 1497, 886 ;moves browser tabs into position for stream
	WinMove, All Moons UPDATED v.1.3.0,, 1218, 658, 1347, 747 ;moves browser tabs into position for stream
	;Run, chrome.exe https://dashboard.twitch.tv/u/tomshi/stream-manager only need this if I'm doing something subpoint related
	Run, C:\Program Files\Chatterino\chatterino.exe
	Run, C:\Program Files (x86)\foobar2000\foobar2000.exe
	Run, F:\Twitch\Splits\Splits\LiveSplit_1.7.6\LiveSplit.exe
	Run, C:\Users\Tom\AppData\Local\Programs\streamlabels\StreamLabels.exe
	Run, C:\Program Files\ahk\Streamlabs Chatbot.lnk
	;Run, C:\Program Files\Elgato\GameCapture\GameCapture.exe // replaced by source record plugin
	Run, chrome.exe https://www.twitch.tv/popout/tomshi/chat
	WinMove, ahk_exe Discord.exe,, 4480, 432, 1080, 797 ;moves into position
Return

F16:: ;opens streamelements obs and swaps to botshi profile
	Run, C:\Program Files\ahk\BOTSHI.lnk ;opening shortcuts helps to make sure obs and ahk have the same admin level so ahk can interact with it, otherwise obs wont accept inputs
	;Run, C:\Program Files\ahk\obs64.lnk
		WinWait ahk_exe obs64.exe ;waits until obs is open then brings it into focus. obs live fucked up their integration so you have to physically click on obs live before you can input alt commands. Thanks obs live
		sleep 3000 ;waits a little bit once obs has opened so it doesn't crash
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 457, 928
	SendInput, {Click}, !p ;I have to physically click on streamelements obs before it will accept any inputs, I have no idea why, this didn't happen originally but started happening in obs 27
	sleep 200 ;either these sleeps are necessary, or every SendInput needs to be on a separate line, obs can't take inputs that fast and breaks
	SendInput, {DOWN 6}
	sleep 200
	SendInput, {ENTER}
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

#IfWinExist ahk_exe obs64.exe
^+r:: ;this script is to trigger the replay buffer in obs, as well as the source record plugin, I use this to save clips of stream 
		if WinExist("ahk_exe obs64.exe") ;focuses obs
			WinActivate
		else
			WinWaitActive, ahk_exe obs64.exe
	sleep 1000
	SendInput, ^p ;Main replay buffer hotkey must be set to this
	SendInput, ^+8 ;Source Record OBS Plugin replay buffer must be set to this
	;sleep 10
	;SendInput, ^+9 ;Source Record OBS Plugin replay buffer must be set to this
	sleep 10
Return

;================Audition================
#IfWinActive ahk_exe Adobe Audition.exe
F13:: ;Moves mouse and applies Limit preset, then normalises to -3db
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
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

;================Photoshop================
#IfWinActive ahk_exe Photoshop.exe
^+p:: ;When highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
	SendInput, {TAB}{RIGHT}
	sleep 200
	SendInput, {DOWN 17}
	Sleep 200
	SendInput, {Enter}+{Tab}
Return

;================Premiere================
#IfWinActive ahk_exe Adobe Premiere Pro.exe

F11:: ;hover over an audio track you want normalized, this will then send it to adobe audition to be limited and normalised. If there are multiple audio tracks and you only want one, alt click it individually first.
;SendInput, !{Click} ;alt clicks the audio track to just select it and not the whole track
;sleep 100 ;ahk is too fast
;SetDefaultMouseSpeed 0
;SetKeyDelay, 0
;coordmode, pixel, Screen
;coordmode, mouse, Screen
;MouseGetPos, xposP, yposP
;MouseMove, xposP, 513
	SendInput, {Click Right}
	sleep 200
	SendInput, {Down 8} ;menus down to send to adobe audition
	sleep 200
	SendInput, {Enter}
		if WinExist("ahk_exe Adobe Audition.exe") ;waits until audition opens
			WinActivate
		else
			WinWaitActive, ahk_exe Adobe Audition.exe
	WinMaximize, ahk_exe Adobe Audition.exe ;for whatever reason audition opens windowed sometimes, this just forces fullscreen		
	sleep 4000 ;audition is slow asf to load
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 1192, 632 ;moves the mouse to the middle of the screen
	SendInput, {click} ;clicks in the middle of the screen to ensure the current audio is actually selected, audition is just jank as hell and it's easier to just add this step than to deal with it not working sometimes
	sleep 1000
	MouseMove, 301, 373 ;moves the mouse to the preset selector
	SendInput, {Click}l{DOWN 3}{ENTER} ;menus to the limit preset I have
	sleep, 100
	MouseMove, 80, 714
	SendInput, {Click}
	sleep, 2200
	SendInput, !rnn{ENTER} ;menus to the normalise preset in the alt menu
	sleep, 2200
	MouseMove, 1192, 632 ;moves back to the middle of the screen and clicks
	SendInput, {click}
	SendInput, ^s ;saves so the changes translate over to premiere
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
	WinMinimize, ahk_exe Adobe Audition.exe ;minimises audition and reactivates premiere
	WinActivate, ahk_exe Adobe Premiere Pro.exe
Return

1:: ;press then hold alt and drag to increase/decrese scale. Let go of alt to confirm 
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse ;// can't use block input as you need to drag the mouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 227, 1101
	SendInput, {Click Down}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, 1
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP% 
Return

3:: ;press then hold alt and drag to increase/decrese x position. Let go of alt to confirm 
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse 
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 226, 1079
	SendInput, {Click Down}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, 3
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP% 
Return

4:: ;press then hold alt and drag to increase/decrese y position. Let go of alt to confirm 
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse 
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 275, 1080
	SendInput, {Click Down}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, 4
	SendInput, {Click Up}
MouseMove, %xposP%, %yposP% 
Return

2:: ;press then hold alt and drag to move position. Let go of alt to confirm 
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
coordmode, pixel, Screen
coordmode, mouse, Screen
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
;MouseGetPos, xposP, yposP
	MouseMove, 142, 1059
	SendInput, {Click left} ;you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract 
	MouseMove, 2300, 238 ;with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable
	SendInput, {Click Down}
blockinput, MouseMoveOff
BlockInput, off
	KeyWait, 2
	SendInput, {Click Up}
;MouseMove, %xposP%, %yposP% // moving the mouse position back to origin after doing this is incredibly disorienting 
;MouseMove, %xposP%, %yposP% // moving the mouse position back to origin after doing this is incredibly disorienting 
Return
;~~~~~~~~~~~~~~~~~NUMPAD SCRIPTS~~~~~~~~~~~~~~~~~
Numpad7:: ;This script moves the mouse to a pixel position to highlight the "motion tab" then menu and change values to zoom into a custom coord and zoom level
	SendInput, ^+9
	SendInput, {F5} ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	;Send ^+8 ;highlight the effect control panel
	;Send ^+8 ;again because adobe is dumb and sometimes doesn't highlight if you're fullscreen somewhere
	MouseMove, 122,1060 ;location for "motion"
	SendInput, ^+k ;shuttle stop. idk why this one is still here, but uh, leave it since it's not breaking anything
	SendInput, {Click}
	SendInput, {Tab 2}1912{Tab}0{Tab}200{ENTER}
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

Numpad8:: ;This script moves the mouse to a pixel position to highlight the "motion tab" then menu and change values to zoom into a custom coord and zoom level
	SendInput, ^+9
	SendInput, {F5} ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
	MouseGetPos, xposP, yposP
	MouseMove, 122,1060
	SendInput, {Click}
	SendInput, {Tab 2}2880{Tab}-538{Tab}300
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
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 425, 1063
	SendInput, {Click}
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

Numpad4:: ;GO TO EFFECTS WINDOW AND HIGHLIGHT SEARCH BOX
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
Return
;~~~~~~~~~~~~~~~~~Drag and Drop Effect Presets~~~~~~~~~~~~~~~~~
!g::
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
	SendInput, ^a{DEL}
	SendInput, gaussian blur 20 ;create a preset of blur effect with this name, must be in a folder as well
SetDefaultMouseSpeed 0
SetKeyDelay, 0
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

!p::
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
	SendInput, ^a{DEL}
	SendInput, parametric ;create parametric eq preset with this name, must be in a folder as well
SetDefaultMouseSpeed 0
SetKeyDelay, 0
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

!h::
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
	SendInput, ^+7
	SendInput, ^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
	SendInput, ^a{DEL}
	SendInput, hflip ;create hflip preset with this name, must be in a folder as well
SetDefaultMouseSpeed 0
SetKeyDelay, 0
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
;~~~~~~~~~~~~~~~~~Scale Adjustments~~~~~~~~~~~~~~~~~

^1:: ;makes the scale of current selected clip 100
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 237,1102
	SendInput, {CLICK}100{ENTER}
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

^2:: ;makes the scale of current selected clip 200
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 237,1102
	SendInput, {CLICK}200{ENTER}
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

^3:: ;makes the scale of current selected clip 300
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0
MouseGetPos, xposP, yposP
	MouseMove, 237,1102
	SendInput, {CLICK}300{ENTER}
MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

;~~~~~~~~~~~~~~~~~Mouse Scripts~~~~~~~~~~~~~~~~~
WheelRight:: +Down ;Set shift down to "Go to next edit point on any track"
Return
WheelLeft:: +Up ;Set shift up to "Go to previous edit point on any track
Return

F14::^+w ;Set mouse button to always spit out f14, then set ctrl shift w to "Nudge Clip Selection up"
return

Xbutton1::^w ;Set ctrl w to "Nudge Clip Selection Down"
Return

Xbutton2:: ;changes the tool to the hand tool while mouse button is held
	click middle
	SendInput, {h}{LButton Down} ;set hand tool to "h"
	KeyWait, Xbutton2
	SendInput, {LButton Up}{v} ;set select tool to v
Return
;~~~~~~~~~~~~~~~~~SPEED MACROS~~~~~~~~~~~~~~~~~
^+1:: ;Must set ctrl + d to open the speed menu
	SendInput, ^d20{ENTER} ;Sets speed(s) to 20(or applicable number)
Return

^+2::
	SendInput, ^d25{ENTER}
Return

^+3::
	SendInput, ^d50{ENTER}
Return

^4::
	SendInput, ^d75{ENTER}
Return

^5::
	SendInput, ^d100{ENTER}
Return

^6::
	SendInput, ^d200{ENTER}
Return






; ==================OLD=====================
;F6:: ;how to move mouse on one axis
;SetDefaultMouseSpeed 0
;SetKeyDelay, 0
;coordmode, pixel, Screen
;coordmode, mouse, Screen
;MouseGetPos, xposP, yposP
;MouseMove, xposP, 513,, R
;Return

;F6:: ;how to move mouse on one axis, relative to current position
;SetDefaultMouseSpeed 0
;SetKeyDelay, 0
;coordmode, pixel, Screen
;coordmode, mouse, Screen
;MouseMove, 0, 513,, R
;Return

#IfWinNotActive ahk_exe Adobe Premiere Pro.exe
;Detatch a firefox tab

;#IfWinActive ahk_exe firefox.exe
;F14:: ;detatch a tab when it fails to do so
;SendInput, !d
;sleep, 100
;Send, +{TAB}
;sleep, 100
;Send, +{TAB}
;sleep, 100
;Send, +{TAB}
;sleep, 200
;Send, +{F10}
;sleep, 200
;Send, v
;sleep, 200
;Send, w
;sleep, 200
;Return

;change obs profile

;F9::
;SendInput, !p
;SendInput, {DOWN 7}
;SendInput, {ENTER}
;Return

;open obs and change its profle

;^+!o::  ;====learning how WinActivate works====
;Run, C:\Program Files\AHK\obs64.lnk
;if WinExist("ahk_exe obs64.exe")
	;WinActivate
;else
	;WinWaitActive, ahk_exe obs64.exe
;sleep 1000
;SendInput, !p
;SendInput, {DOWN 7}
;SendInput, {ENTER}
Return

;~~~~~~~~~~~~~~~~~Timecode Scripts~~~~~~~~~~~~~~~~~
;^!c:: ;moves the mouse to the timecode and copies it  //these were mostly for the beginner tutorial, I don't use anymore
;coordmode, pixel, Window
;coordmode, mouse, Window
;BlockInput, SendAndMouse
;BlockInput, MouseMove
;BlockInput, On
;SetKeyDelay, 0
;SetDefaultMouseSpeed 0
;MouseGetPos, xposP, yposP
	;MouseMove, 79,93
	;SendInput, {Click}
	;SendInput, ^c
;MouseMove, %xposP%, %yposP%
	;SendInput, {Click}
;blockinput, MouseMoveOff
;BlockInput, off
;Return

;^+c:: ;moves the mouse to the timecode and clicks it
;coordmode, pixel, Window
;coordmode, mouse, Window
;BlockInput, SendAndMouse
;BlockInput, MouseMove
;BlockInput, On
;SetKeyDelay, 0
;SetDefaultMouseSpeed 0
	;MouseMove, 79,93
	;SendInput, {Click}
	;SendInput, ^c
;blockinput, MouseMoveOff
;BlockInput, off
;Return