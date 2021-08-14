;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance Force
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.1.6

;\\CURRENT RELEASE VERSION
;\\v2.0

; =========================================================================
;		Coordmode \\ Last updated: v2.1.6
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

coordc()
{
	coordmode "caret", "window"
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
;		discord \\ Last updated: v2.1.4
; =========================================================================
disc(button) ;This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \ahk\ImageSearch\disc[button].png
{
	coordw() ;important to leave this as window as otherwise the image search function might try searching your entire screen which isn't desirable
	MouseGetPos(&x, &y)
	blockOn()
	click "right"
	sleep 50 ;sleep required so the right click context menu has time to open
	If ImageSearch(&xpos, &ypos, 312, 64, 1066, 1479, "*2 " A_WorkingDir %&button%) ;*2 is required otherwise it spits out errors. check documentation for definition. These coords define the entire area discord contains text. Recommended to close the right sidebar or do this in a dm so you see the entire area discord normally shows messages
		if "true" ;I don't think this line is necessary??
			MouseMove(%&xpos%, %&ypos%)
	else
		sleep 500 ;this is a second attempt incase discord was too slow and didn't catch the button location the first time
		ImageSearch(&xpos, &ypos, 312, 64, 1066, 1479, "*2 " A_WorkingDir %&button%) ;this line is searching for the location of your selected button. Same goes for above. The coords here are the same as above
		MouseMove(%&xpos%, %&ypos%) ;Move to the location of the button
	;MouseMove(10, 10,, "R") ;moves the mouse out of the corner and actually onto the button | use this if your screenshots don't line up with the button properly
	Click
	sleep 100
	If ImageSearch(&xdir, &ydir, 330, 1380, 1066, 1461, "*2 " A_WorkingDir "\ImageSearch\Discord\DiscDirReply.png") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. If you prefer to leave that on, remove from the above sleep 100, to the else below. The coords here define just the bottom chat box AND the tiny bar that appears about it when you "reply" to someone
		{
			MouseMove(%&xdir%, %&ydir%) ;moves to the @ location
			Click
			MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
			blockOff()
		}
	else
		MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
		blockOff()
}

; =========================================================================
;		Mouse Drag \\ Last updated: v2.0.3
; =========================================================================
mousedrag(tool) ;press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example)
{
	click "middle"
	SendInput "{h}{LButton Down}" ;set hand tool to "h"
	KeyWait "Xbutton2"
	SendInput "{LButton Up}"
	SendInput %&tool% ;this is the button you want the script to press to bring you back to your tool of choice
}

; =========================================================================
;		better timeline movement \\ Last updated: v2.0.3
; =========================================================================
timeline(y) ;a weaker version of the right click premiere script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock)
{
coordw()
blockOn()
MouseGetPos &xpos, &ypos
	MouseMove %&xpos%, %&y% ;the y value you're defining is for the location of the top bar in your video editor that allows you to click it to drag along the timeline
	SendInput "{Click Down}"
	MouseMove %&xpos%, %&ypos%
	blockOff()
	KeyWait "Xbutton1"
	SendInput "{Click Up}"
}

; =========================================================================
;		Premiere \\ Last updated: v2.1.6
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
		SendInput %&item% ;create a preset of any effect, must be in a folder as well
		coordc() ;change caret coord mode to window
		CaretGetPos(&carx, &cary) ;get the position of the caret (blinking line where you type stuff)
		MouseMove %&carx%, %&cary% ;move to the caret (instead of defined pixel coords) to make it less prone to breaking
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

fElse(data) ;a preset for the premiere scale, x/y and rotation scripts ;these wont work for resolve in their current form, you could adjust it to fit easily by copying over that code
{
	Click "{Click Up}"
	sleep 10
	Send %&data% ;what the script is typing in the text box
	;MouseMove x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
	;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
	sleep 50
	send "{enter}"
}

; =========================================================================
;		Resolve \\ Last updated: v2.1.5
; =========================================================================
Rscale(item) ;to set the scale of a video within resolve
{
coordw()
blockOn()
MouseGetPos &xpos, &ypos
	click "2333, 218" ;clicks on video
	SendInput %&item% ;effectively x %
	SendInput "{ENTER}"
	click "2292, 215" ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again.  Using the arrow would honestly be faster here
MouseMove %&xpos%, %&ypos%
blockOff()
}

rfElse(data) ;a preset for the resolve scale, x/y and rotation scripts
{
	SendInput "{Click Up}"
	sleep 10
	Send %&data% ;what the script is typing in the text box
	;MouseMove, x, y ;if you want to press the reset arrow, input the windowspy SCREEN coords here then comment out the above Send^
	;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
	;alternatively you could also run imagesearches like in the other resolve functions to ensure you always end up in the right place
	sleep 10
	send "{enter}"
	click "2295, 240" ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again.
}

Rfav(effect) ;apply any effect to the clip you're hovering over. this script requires the search box to be visible on the left side of the screen
{
coordw() ;
blockOn()
MouseGetPos &xpos, &ypos
If ImageSearch(&xi, &yi, 8, 752, 220, 803, "*2 " A_WorkingDir "\ImageSearch\Resolve\search.png") ;the search bar must be visible for this script to work. The coords in this function are to search for it
	{
		MouseMove(%&xi% + "10", %&yi% + "5")
		Click
		SendInput(%&effect%)
		MouseMove(189, 72,, "R")
		SendInput "{Click Down}"
		MouseMove %&xpos%, %&ypos%, 2
		SendInput "{Click Up}"
		MouseMove(%&xi% + "10", %&yi% + "5")
		click
	}
	else ;if for whatever reason the word "seach" isn't visible in the search box, this part of the function defaults back to just raw pixel coords
		{
			MouseMove(34, 775)
			Click
			SendInput(%&effect%)
			MouseMove(189, 72,, "R")
			SendInput "{Click Down}"
			MouseMove %&xpos%, %&ypos%, 2 ;moves the mouse at a slower, more normal speed because resolve doesn't like it if the mouse warps instantly back to the clip
			SendInput "{Click Up}"
			MouseMove(34, 775)
			click
		}

	SendInput("^a" "{Del}")
	MouseMove %&xpos%, %&ypos%
	click "middle"
blockOff()
}


; =========================================================================
; Old
; =========================================================================
/* ;this was the old way of doing the discord functions (v2.0.7) that included just right clicking and making the user do things. I've saved the one with all variations of code it went through, the other two have been removed for cleanup as they were functionally identical
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
