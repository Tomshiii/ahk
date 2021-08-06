;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance Force

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.0.3

;\\CURRENT RELEASE VERSION
;\\v1.2

; =========================================================================
;		Coordmode
; =========================================================================
coords()
{
	coordmode "pixel", "screen"
	coordmode "mouse", "screen"
}

coordw()
{
	coordmode "pixel", "window"
	coordmode "mouse", "window"
}

; =========================================================================
;		Blockinput
; =========================================================================
blockOn()
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
}

blockOff()
{
	blockinput "MouseMoveOff"
	BlockInput "off"
}

; =========================================================================
;		Mouse Drag
; =========================================================================
mousedrag(item)
{
	click "middle"
	SendInput "{h}{LButton Down}" ;set hand tool to "h"
	KeyWait "Xbutton2"
	SendInput "{LButton Up}"
	SendInput %&item%
}

; =========================================================================
;		better timeline movement
; =========================================================================
timeline(item)
{
coordw()
blockOn()
MouseGetPos &xpos, &ypos
	MouseMove %&xpos%, %&item%
	SendInput "{Click Down}"
	MouseMove %&xpos%, %&ypos%
	blockOff()
	KeyWait "Xbutton1"
	SendInput "{Click Up}"
}

; =========================================================================
;		Premiere
; =========================================================================
preset(item) ;this preset is for the drag and drop effect presets in premiere
{
	blockOn()
	coords()
	MouseGetPos &xpos, &ypos
		SendInput "^+7"
		SendInput "^b" ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
		SendInput "^a{DEL}"
		SendInput %&item% ;create a preset of blur effect with this name, must be in a folder as well
		MouseMove 2232, 1001 ;move to the magnifying glass in the effects panel
		sleep 100
		MouseMove 40, 68,, "R" ;move down to the saved preset (must be in an additional folder)
		SendInput "{Click Down}"
		MouseMove %&xpos%, %&ypos%
		SendInput "{Click Up}"
	blockOff()
}

num() ;this preset is to simply cut down repeated code on my numpad punch in scripts
{
	coordw()
	blockOn()
	MouseGetPos &xpos, &ypos
		SendInput "^+9"
		SendInput "^{F5}" ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
		click 214, 1016
		SendInput "{WheelUp 30}"
		MouseMove 122,1060 ;location for "motion"
		SendInput "{Click}"
		MouseMove %&xpos%, %&ypos%
}

fElse(item) ;a preset for the premiere scale,x/y and rotation scripts ;these wont work for resolve in their current form, you could adjust it to fit easily by copying over that code
{
	Click "{Click Up}"
	sleep 10
	Send %&item%
	;MouseMove x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
	;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
	sleep 50
	send "{enter}"
}

; =========================================================================
;		Resolve
; =========================================================================
Rscale(item)
{
coordw()
blockOn()
MouseGetPos &xpos, &ypos
	click "2333, 218" ;clicks on video
	SendInput %&item% ;effectively x %
	SendInput "{ENTER}"
	click "2292, 215" ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again. Using the arrow would hoennstly be faster here
MouseMove %&xpos%, %&ypos%
blockOff()
}

rfElse(item)
{
	SendInput "{Click Up}"
	sleep 10
	Send %&item%
	;MouseMove, x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
	;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
	sleep 10
	send "{enter}"
	click "2295, 240"
}