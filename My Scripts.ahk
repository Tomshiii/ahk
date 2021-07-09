#SingleInstance Force
SetWorkingDir, %A_ScriptDir%

; A lot of the code in this script was either directly inspired by, or copied from Taran from LTT (https://github.com/Tomshiii/ahk), his videos on the subject
; are what got me into AHK to begin with and what brought this entire script to life
; I use a streamdeck to run a lot of these scripts which is why most of them are bound to F13-24 but really they could be replaced with anything

;================Windows================
#IfWinNotActive ahk_exe Adobe Premiere Pro.exe
^+a:: ;opens my script directory
Run, C:\Program Files\AHK
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
SendInput +a, +a, +a
Return

#IfWinNotActive ahk_exe firefox.exe ;I do this just because F11 is fullscreen and I guess I can't be bothered using another button
F11:: ;opens the streamdeck app
Run, C:\Program Files\Elgato\StreamDeck\StreamDeck.exe
Return
;================Stream================
#IfWinNotActive ahk_exe Adobe Premiere Pro.exe
F15:: ;Start everything for stream
SetWinDelay, 0 ;makes windows move instantly
Run, C:\Program Files\AHK\obs64.lnk
if WinExist("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus
	WinActivate
else
	WinWaitActive, ahk_exe obs64.exe
sleep 2500 ; you have to wait a while after obs opens before you can start sending it commands or it'll crash 
SendInput, !p ;Changes profile to main stream profile. The Above 1s sleep is essential as obs crashes if you instantly change the profile
SendInput, {DOWN 7}
SendInput, {ENTER}
sleep 2000
WinMove, OBS,,  2553, -892, 1111, 1047 ;Moves obs into position, important to keep because streamelements obs is wider and ruins main obs
Run, firefox.exe https://docs.google.com/presentation/d/1b6pCuOIrw4pEF6GACxrBh8C-mB4XsDeHLM50cj4jAkQ/edit#slide=id.g90e8195d3c_16_958
if WinExist("ahk_exe firefox.exe")
	WinActivate
else
	WinWaitActive, ahk_exe firefox.exe
sleep 1000
Run, firefox.exe https://dashboard.twitch.tv/u/tomshi/stream-manager
sleep 9000 ;if both tabs don't load in, it can mess with trying to separate them
if WinExist("ahk_exe firefox.exe")
	WinActivate
else
	WinWaitActive, ahk_exe firefox.exe ;the following code was yoinked from taran, it's just a deeper method of calling firefox forwards since sometimes it doesn't focus
WinActivatebottom ahk_exe firefox.exe
WinGet, hWnd, ID, ahk_class MozillaWindowClass
	DllCall("SetForegroundWindow", UInt, hWnd) 
SendInput, !d ;Detatches the firefox tab
sleep, 100 ;ahk is too fast for firefox, so we must be slow
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
WinMove, Twitch,, -6, 0, 1497, 886 ;moves into position
WinMove, All Moons UPDATED v.1.3.0,, 1218, 658, 1347, 747 ;moves into position
;Run, chrome.exe https://dashboard.twitch.tv/u/tomshi/stream-manager only need this if I'm doing something subpoint related
Run, C:\Program Files\Chatterino\chatterino.exe
Run, C:\Program Files (x86)\foobar2000\foobar2000.exe
Run, F:\Twitch\Splits\Splits\LiveSplit_1.7.6\LiveSplit.exe
Run, C:\Users\Tom\AppData\Local\Programs\streamlabels\StreamLabels.exe
Run, C:\Program Files\AHK\Streamlabs Chatbot.lnk
;Run, C:\Program Files\Elgato\GameCapture\GameCapture.exe replaced by source record plugin
Run, chrome.exe https://www.twitch.tv/popout/tomshi/chat
WinMove, ahk_exe Discord.exe,, 4480, 432, 1080, 797 ;moves into position
Return

F16:: ;opens streamelements obs and swaps to botshi profile
Run, C:\Program Files\AHK\BOTSHI.lnk
;Run, C:\Program Files\AHK\obs64.lnk
WinWait ahk_exe obs64.exe ;waits until obs is open then brings it into focus. obs live fucked up their integration so you have to physically click on obs live before you can input alt commands. Thanks obs live
	sleep 3000
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0

MouseGetPos, xposP, yposP
MouseMove, 457, 928
SendInput, {Click}, !p
Sleep 200 ;either these sleeps are necessary, or every SendInput needs to be on a separate line, obs can't take inputs that fast and breaks
SendInput, {DOWN 6}
Sleep 200
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
sleep 10
SendInput, ^+9 ;Source Record OBS Plugin replay buffer must be set to this
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
SendInput, {Click}, l, {DOWN 3}, {ENTER}
Sleep, 5
MouseMove, 92, 717
SendInput, {Click}
Sleep, 2200
SendInput, !rnn, {ENTER}

MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

;================Photoshop================
#IfWinActive ahk_exe Photoshop.exe
^+p:: ;When highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
SendInput, {TAB}{RIGHT}
Sleep 200
SendInput, {DOWN 17}
Sleep 200
SendInput, {Enter},+{Tab}
Return

;================Premiere================
#IfWinActive ahk_exe Adobe Premiere Pro.exe
;~~~~~~~~~~~~~~~~~NUMPAD SCRIPTS~~~~~~~~~~~~~~~~~
Numpad7:: ;This script moves the mouse to a pixel position to highlight the "motion tab" then menu and change values to zoom into a custom coord and zoom level
SendInput, ^+9,{F8} ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
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
SendInput, ^+k,{Click}{Tab 2}, 1912, {Tab}, 0, {Tab}, 200, {ENTER}, ^+k

MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

Numpad8:: ;This script moves the mouse to a pixel position to highlight the "motion tab" then menu and change values to zoom into a custom coord and zoom level
SendInput, ^+9,{F8} ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0

MouseGetPos, xposP, yposP
MouseMove, 122,1060
SendInput, {Click}{Tab 2}, 2880, {Tab},-538,{Tab}, 300, {Enter}

MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

Numpad9:: ;This script moves the mouse to a pixel position to reset the "motion" effects
SendInput, ^+9,{F12} ;highlights the timeline, then changes the track colour so I know that clip has been reset back to normal
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0

MouseGetPos, xposP, yposP
MouseMove, 358, 1055
SendInput, {Click}

MouseMove, %xposP%, %yposP% 
blockinput, MouseMoveOff
BlockInput, off
Return

Numpad2:: ;INCREASE GAIN BY 2db == set g to open gain window
SendInput, g, +{Tab}, {UP 3}, {DOWN},  {TAB}, 2, {ENTER}
Return

Numpad1:: ;REDUCE GAIN BY -2db
SendInput, g, +{Tab}, {UP 3}, {DOWN}, {TAB}, -2, {ENTER}
Return

Numpad3:: ;INCREASE GAIN BY 6db
SendInput, g, +{Tab}, {UP 3}, {DOWN}, {TAB}, 6, {ENTER}
Return

Numpad4:: ;GO TO EFFECTS WINDOW AND HIGHLIGHT SEARCH BOX
SendInput, ^+7,^b ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
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
SendInput, {CLICK}, 100, {ENTER}

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
SendInput, {CLICK}, 200, {ENTER}

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
SendInput, {CLICK}, 300, {ENTER}

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
SendInput, {h}{LButton Down} ;set hand tool to "h"
KeyWait, Xbutton2
SendInput, {LButton Up}{v} ;set select tool to v

Return
;~~~~~~~~~~~~~~~~~Timecode Scripts~~~~~~~~~~~~~~~~~
^!c:: ;moves the mouse to the timecode and copies it
coordmode, pixel, Window
coordmode, mouse, Window
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
SetKeyDelay, 0
SetDefaultMouseSpeed 0

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
SetDefaultMouseSpeed 0

MouseMove, 79,93
SendInput, {Click}
SendInput, ^c
blockinput, MouseMoveOff
BlockInput, off
Return
;~~~~~~~~~~~~~~~~~SPEED MACROS~~~~~~~~~~~~~~~~~
^+1:: ;Must set ctrl + d to open the speed menu
	SendInput, ^d, 20, {ENTER} ;Sets speed(s) to 20(or applicable number)
Return

^+2::
	SendInput, ^d, 25, {ENTER}
Return

^+3::
	SendInput, ^d, 50, {ENTER}
Return

^4::
	SendInput, ^d, 75, {ENTER}
Return

^5::
	SendInput, ^d, 100, {ENTER}
Return

^6::
	SendInput, ^d, 200, {ENTER}
Return






; ==================OLD=====================
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
