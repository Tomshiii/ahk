;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance Force

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.0.7

;\\CURRENT RELEASE VERSION
;\\v2.0

; =========================================================================
;		Coordmode \\ Last updated: v2.0.1
; =========================================================================
coords() ;sets coordmode to "screen"
{
	coordmode "pixel", "screen"
	coordmode "mouse", "screen"
}

coordw() ;sets coordmode to "window"
{
	coordmode "pixel", "window"
	coordmode "mouse", "window"
}

; =========================================================================
;		Blockinput \\ Last updated: v2.0.1
; =========================================================================
blockOn() ;blocks all user inputs
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
}

blockOff() ;turns off the blocks on user input
{
	blockinput "MouseMoveOff"
	BlockInput "off"
}

; =========================================================================
;		Mouse Drag \\ Last updated: v2.0.7
; =========================================================================
;PLEASE NOTE, I ORIGINALLY HAD THIS SCRIPT WARP THE MOUSE TO CERTAIN POSITIONS TO HIT THE RESPECTIVE BUTTONS BUT THE POSITION OF BUTTONS IN DISCORD WITHIN THE RIGHT CLICK CONTEXT MENU CHANGE DEPENDING ON WHAT PERMS YOU HAVE IN A SERVER, SO IT WOULD ALWAYS TRY TO DO RANDOM THINGS LIKE PIN A MESSAGE OR OPEN A THREAD. There isn't really anything you can do about that. I initially tried to just send through multiple down/up inputs but apparently discord rate limits you to like 1 input every .5-1s so that's fun.
discedit()
{
	{
		coords()
		MouseGetPos(&x, &y)
		blockOn()
		if(%&y% > 876) ;this value will need to be adjusted per your monitor. Because my monitor is rotated to sit vertically, "lower" on my screen is actually a higher y pixel value, hence the > instead of <
			{
				click "right"
				MouseMove(%&x%, 948) ;this value will need to be adjusted per your monitor - it's where the edit button sits when your mouse is towards the bottom of discord
				MouseMove(29, 0,, "R")
				;blockOff()
				;keywait "LButton", "D" ;tried to make it so the user presses the button you want since it moves everywhere depending on what perms you have in a server
				;click					;but it was too disorienting to make the user move, click, then warp the mouse back to the og position so
				;MouseMove(%&x%, %&y%)	;this is the best you can do here with the limitations of discord
			}
		else
			{
				click "right"
				MouseMove(29, 111,, "R") ;the y value here will need to be adjusted per your monitor
				;blockOff()				;I'll preserve this code in this first script, but remove it from the following two examples
				;keywait "LButton", "D"
				;click
				;MouseMove(%&x%, %&y%)
			}
		blockOff()
	}
}

discreply()
{
	{
		coords()
		MouseGetPos(&x, &y)
		blockOn()
		if(%&y% > 876) ;this value will need to be adjusted per your monitor
			{
				click "right"
				MouseMove(%&x%, 1017) ;this value will need to be adjusted per your monitor - it's where the reply button sits when your mouse is towards the bottom of discord
				MouseMove(29, 0,, "R")
			}
		else
			{
				click "right"
				MouseMove(29, 153,, "R") ;the y value here will need to be adjusted per your monitor
			}
		blockOff()
	}
}

discreac()
{
	{
		coords()
		MouseGetPos(&x, &y)
		blockOn()
		if(%&y% > 876) ;this value will need to be adjusted per your monitor
			{
				click "right"
				MouseMove(%&x%, 944) ;this value will need to be adjusted per your monitor - it's where the add reaction button sits when your mouse is towards the bottom of discord
				MouseMove(29, 0,, "R")
			}
		else
			{
				click "right"
				MouseMove(29, 71,, "R") ;the y value here will need to be adjusted per your monitor
			}
		blockOff()
	}
}

; =========================================================================
;		Mouse Drag \\ Last updated: v2.0.3
; =========================================================================
mousedrag(item) ;press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example)
{
	click "middle"
	SendInput "{h}{LButton Down}" ;set hand tool to "h"
	KeyWait "Xbutton2"
	SendInput "{LButton Up}"
	SendInput %&item%
}

; =========================================================================
;		better timeline movement \\ Last updated: v2.0.3
; =========================================================================
timeline(item) ;a weaker version of the right click premiere script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock)
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
;		Premiere \\ Last updated: v2.0.3
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

fElse(item) ;a preset for the premiere scale, x/y and rotation scripts ;these wont work for resolve in their current form, you could adjust it to fit easily by copying over that code
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
;		Resolve \\ Last updated: v2.0.4
; =========================================================================
Rscale(item) ;to set the scale of a video within resolve
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

rfElse(item) ;a preset for the resolve scale, x/y and rotation scripts ;these wont work for resolve in their current form, you could adjust it to fit easily by copying over that code
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

Rfav(x, y) ;x and y are the window pixel coords for the "favourite" you want your hotkey to apply to your clip
{
coordw() ;this script requires the "effects library" to be open on the left side of screen
blockOn()
MouseGetPos &xpos, &ypos
	;Click 566 735 ;clicks mag glass in the "effects library" window \\bad idea since clicking it again closes the search bar .-.
	;SendInput gaussian
	MouseMove %&x%, %&y% ;add effect as a favourite instead, makes things easier as clicking the mag glass changes depending on if it's already open
	sleep 100
	SendInput "{Click Down}"
	MouseMove %&xpos%, %&ypos%, 2
	;sleep 500
	SendInput "{Click Up}"
blockOff()
}
