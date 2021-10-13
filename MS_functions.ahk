SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance Force
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
#Include "C:\Program Files\ahk\ahk\KSA\Keyboard Shortcut Adjustments.ahk"

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.6.3

;\\CURRENT RELEASE VERSION
;\\v2.2.0.2


; All Code in this script is linked to a function
; for example:
; func(variable)
; 	{
;		code(%&variable%)
;	}
; Then in our main scripts we call on these functions like:
; Hotkey::func("information")
; then whatever you place within the "" will be put wherever you have a %&variable%
; I make use of code like this all throughout this script. All variables are explained underneath their respective functions

; I have made a concious effort throughout the workings of this script to keep out as many raw pixel coords as possible, preferring imagesearches to ensure correct mouse movements
; but even still, an imagesearch still has a definable area that it searches for each image, for example
; ImageSearch(&xpos, &ypos, 312, 64, 1066, 1479,~~~~~) (check the ahk documentation for what each number represents)
; searches in a rectangle defined by the above coords (pixel coords default to window unless you change it to something else)
; These values will be the only thing you should theoretically need to change to get things working in your own setups (outside of potentially needing your own screenshots for things as different setups can mean different colours etc etc)

;EnvSet allows you to store information to call later, via: EnvGet("Discord") for example, which cuts out the need to write ' A_WorkingDir "\ImageSearch\Discord\photoexample.png" ' for every piece of code
EnvSet("Discord", A_WorkingDir "\ImageSearch\Discord\")
EnvSet("Premiere", A_WorkingDir "\ImageSearch\Premiere\")
EnvSet("AE", A_WorkingDir "\ImageSearch\AE\")
EnvSet("Photoshop", A_WorkingDir "\ImageSearch\Photoshop\")
EnvSet("Resolve", A_WorkingDir "\ImageSearch\Resolve\")
EnvSet("VSCode", A_WorkingDir "\ImageSearch\VSCode\")

; ===========================================================================================================================================
;
;		Coordmode \\ Last updated: v2.1.6
;
; ===========================================================================================================================================
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

coordc() ;sets coordmode to "caret"
{
	coordmode "caret", "window"
}

; ===========================================================================================================================================
;
;		Tooltip \\ Last updated: v2.3.13
;
; ===========================================================================================================================================
toolFind(message, timeout) ;create a tooltip for errors finding things
;&message is what you want the tooltip to say after "couldn't find"
;&timeout is how many ms you want the tooltip to last
{
	ToolTip("couldn't find " %&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}

toolCust(message, timeout) ;create a tooltip with any message
;&message is what you want the tooltip to say
;&timeout is how many ms you want the tooltip to last
{
	ToolTip(%&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}
; ===========================================================================================================================================
;
;		Blockinput \\ Last updated: v2.0.1
;
; ===========================================================================================================================================
blockOn() ;blocks all user inputs
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
	;it has recently come to my attention that all 3 of these operate independantly and doing all 3 of them at once is no different to just using "BlockInput "on"" but uh. oops, too late now I guess 
}

blockOff() ;turns off the blocks on user input
{
	blockinput "MouseMoveOff"
	BlockInput "off"
}

; ===========================================================================================================================================
;
;		Windows Scripts \\ Last updated: v2.6.1
;
; ===========================================================================================================================================
youMouse(tenS, fiveS)
;&tenS is the hotkey for 10s skip in your direction of choice
;&fiveS is the hotkey for 5s skip in your direction of choice
{
	if A_PriorKey = "Mbutton"
		return
	if WinExist("YouTube")
	{
		lastactive := WinGetID("A")
		WinActivate()
		if GetKeyState("F14", "P")
			SendInput(%&tenS%)
		else
			SendInput(%&fiveS%)
		WinActivate(lastactive)
	}
}

wheelEditPoint(direction)
;&direction is the hotkey within premiere for the direction you want it to go in relation to "edit points"
{
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro 2021" ;focuses the timeline
	SendInput(%&direction%) ;Set these shortcuts in the keyboards shortcut ini file
}

monitorWarp(x, y)
{
	coords()
	MouseMove(%&x%, %&y%)
}

; ===========================================================================================================================================
;
;		discord \\ Last updated: v2.5.4
;
; ===========================================================================================================================================
disc(button) ;This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \ahk\ImageSearch\disc[button].png
;NOTE THESE WILL ONLY WORK IF YOU USE THE SAME DISPLAY SETTINGS AS ME (otherwise you'll need your own screenshots.. tbh you'll probably need your own anyway). YOU WILL LIKELY NEED YOUR OWN SCREENSHOTS AS I HAVE DISCORD ON A VERTICAL SCREEN SO ALL MY SCALING IS WEIRD
;dark theme
;chat font scaling: 20px
;space between message groups: 16px
;zoom level: 100
;saturation; 70%

;&button in the png name of a screenshot of the button you want the function to press
{
	KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
	coordw() ;important to leave this as window as otherwise the image search function will fail to find things
	MouseGetPos(&x, &y)
	blockOn()
	click("right") ;this opens the right click context menu on the message you're hovering over
	sleep 50 ;sleep required so the right click context menu has time to open
	if ImageSearch(&xpos, &ypos, %&x% - "200", %&y% -"400",  %&x% + "200", %&y% +"400", "*2 " EnvGet("Discord") %&button%)
			MouseMove(%&xpos%, %&ypos%)
	else
		{
			sleep 500 ;this is a second attempt incase discord was too slow and didn't catch the button location the first time
			if ImageSearch(&xpos, &ypos, %&x% - "200", %&y% -"400",  %&x% + "200", %&y% +"400", "*2 " EnvGet("Discord") %&button%)
				MouseMove(%&xpos%, %&ypos%) ;Move to the location of the button
			else ;if everything fails, this else will trigger
				{
					MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
					blockOff()
					toolFind("the requested button", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
		}
	Click
	sleep 100
	if A_ThisHotkey = replyHotkey ;SET THIS ACTIVATION HOTKEY IN THE KEYBOARD SHORTCUTS.ini FILE
		{
			if ImageSearch(&xdir, &ydir, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " EnvGet("Discord") "DiscDirReply.bmp") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. if you prefer to leave that on, remove from the above sleep 100, to the last else below. The coords here are for the entire screen for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish.
				{
					MouseMove(%&xdir%, %&ydir%) ;moves to the @ location
					Click
					MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
					blockOff()
				}
			else
				{
					MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
					blockOff()
					toolFind("the @ ping button", "500") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
		}
	else
		{
			MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
			blockOff()
		}
	
}

; ===========================================================================================================================================
;
;		Mouse Drag \\ Last updated: v2.3
;
; ===========================================================================================================================================
mousedrag(tool, toolorig) ;press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example)
;&tool is the thing you want the program to swap TO (ie, hand tool, zoom tool, etc)
;&toolorig is the button you want the script to press to bring you back to your tool of choice
{
	click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
	SendInput %&tool% "{LButton Down}" 
	KeyWait(A_ThisHotkey)
	SendInput("{LButton Up}")
	SendInput %&toolorig% 
}

; ===========================================================================================================================================
;
;		better timeline movement \\ Last updated: v2.3.11
;
; ===========================================================================================================================================
timeline(timeline, x1, x2, y1) ;a weaker version of the right click premiere script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock)
;&timeline in this function defines the y pixel value of the top bar in your video editor that allows you to click it to drag along the timeline
;x1 is the furthest left pixel value of the timeline that will work with your cursor warping up to grab it
;x2 is the furthest right pixel value of the timeline that will work with your cursor warping up to grab it
;y1 is just below the bar that your mouse will be warping to, this way your mouse doesn't try doing things when you're doing other stuff above the timeline
{
	coordw()
	MouseGetPos(&xpos, &ypos)
	if(%&xpos% > %&x1% and %&xpos% < %&x2%) and (%&ypos% > %&y1%) ;this function will only trigger if your cursor is within the timeline. This ofcourse can break if you accidently move around your workspace
		{
			blockOn()
			MouseMove(%&xpos%, %&timeline%) ;this will warp the mouse to the top part of your timeline defined by &timeline
			SendInput("{Click Down}")
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
			KeyWait(A_ThisHotkey)
			SendInput("{Click Up}")
		}
	else
		return
}

; ===========================================================================================================================================
;
;		Premiere \\ Last updated: v2.6.2
;
; ===========================================================================================================================================
preset(item) ;this preset is for the drag and drop effect presets in premiere
;&item in this function defines what it will type into the search box (the name of your preset within premiere)
{
	KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
	blockOn()
	coords()
	MouseGetPos(&xpos, &ypos)
	if A_ThisHotkey = textHotkey ;CHANGE THIS HOTKEY IN THE KEYBOARD SHORTCUTS.INI FILE
		{
			ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro 2021" ;focuses the timeline
			SendInput(newText) ;creates a new text layer, check the keyboard shortcuts ini file to change this
			sleep 100
			if ImageSearch(&x2, &y2, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "graphics.png")
				{
					if ImageSearch(&xeye, &yeye, %&x2%, %&y2%, %&x2% + "200", %&y2% + "100", "*2 " EnvGet("Premiere") "eye.png")
						{
							MouseMove(%&xeye%, %&yeye%)
							SendInput("{Click}")
							MouseGetPos(&eyeX, &eyeY)
						}
					else
						{
							blockOff()
							toolFind("the eye icon", "1000")
							return
						}
				}
			else
				{
					blockOff()
					toolFind("the graphics tab", "1000")
					return
				}
		}
	SendInput(effectsWindow) ;adjust this in the ini file
	SendInput(findBox) ;adjust this in the ini file
	SendInput("^a{DEL}")
	sleep 60
	coordc() ;change caret coord mode to window
	CaretGetPos(&carx, &cary) ;get the position of the caret (blinking line where you type stuff)
	MouseMove %&carx%, %&cary% ;move to the caret (instead of defined pixel coords) to make it less prone to breaking
	SendInput %&item% ;create a preset of any effect, must be in a folder as well
	MouseMove 40, 68,, "R" ;move down to the saved preset (must be in an additional folder)
	SendInput("{Click Down}")
	if A_ThisHotkey = textHotkey ;set this hotkey within the Keyboard Shortcut Adjustments.ini file
		{
			MouseMove(%&eyeX%, %&eyeY%)
			SendInput("{Click Up}")
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
			return
		}
	MouseMove(%&xpos%, %&ypos%) ;in some scenarios if the mouse moves too fast a video editing software won't realise you're dragging. if this happens to you, add ', "2" ' to the end of this mouse move
	SendInput("{Click Up}")
	blockOff()
}

num(xval, yval, scale) ;this function is to simply cut down repeated code on my numpad punch in scripts. it punches the video into my preset values for highlight videos
;&xval is the pixel value you want this function to paste into the X coord text field in premiere
;&yval is the pixel value you want this function to paste into the y coord text field in premiere
;&scale is the scale value you want this function to paste into the scale text field in premiere
{
	KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
	coordw()
	blockOn()
	MouseGetPos(&xpos, &ypos)
		SendInput(timelineWindow) ;adjust this in the ini file
		SendInput(labelRed) ;changes the track colour so I know that the clip has been zoomed in
		if ImageSearch(&x, &y, 0, 960, 446, 1087, "*2 " EnvGet("Premiere") "video.png") ;moves to the "video" section of the effects control window tab
			goto next
		else
			{
				MouseMove(%&xpos%, %&ypos%)
				blockOff()
				toolFind("the video section", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
				return
			}
		next:
		if ImageSearch(&x2, &y2, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "motion2.png") ;moves to the motion tab
			MouseMove(%&x2% + "10", %&y2% + "10")
		else if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "\motion3.png") ;this is a second check incase "motion" is already highlighted
					MouseMove(%&x3% + "10", %&y3% + "10")
		else ;if everything fails, this else will trigger
			{
				MouseMove(%&xpos%, %&ypos%) ;moves back to the original coords
				blockOff()
				toolFind("the motion tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
				return
			}
		SendInput("{Click}")
		SendInput("{Tab 2}" %&xval% "{Tab}" %&yval% "{Tab}" %&scale% "{ENTER}")
		SendInput("{Enter}")
		MouseMove(%&xpos%, %&ypos%)
		blockOff()
}

/* ;not used anymore
fElse(data) ;a preset for the premiere scale, x/y and rotation scripts ;these wont work for resolve in their current form, you could adjust it to fit easily by copying over that code
;&data is what the script is typing in the text box (what your reset values are. ie 960 for a pixel coord, or 100 for scale)
{
	Click "{Click Up}"
	sleep 10
	Send %&data% 
	;MouseMove x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
	;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
	sleep 50
	send "{enter}"
}
 */

noclips()
{
	coords()
	blockOn()
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro 2021" ;focuses the timeline
	if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") "noclips.png") ;searches to check if no clips are selected
		{
			SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
			sleep 50
			if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
				{
					toolCust("The wrong clips are selected", "1000")
					blockOff()
					return
				}
		}	
	SendInput(effectControls) ;adjust this in the keyboard shortcuts ini file
}

valuehold(filepath, optional) ;a preset to warp to one of a videos values (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
;&filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
;&optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
{
	MouseGetPos(&xpos, &ypos)
	noclips()
	if A_ThisHotkey = levelsHotkey ;THIS IS FOR ADJUSTING THE "LEVEL" PROPERTY, CHANGE IN THE KEYBOARD SHORTCUTS.INI FILE
		{ ;don't add WheelDown's, they suck in hotkeys, idk why, they lag everything out and stop Click's from working
			if ImageSearch(&vidx, &vidy, 0, 911,705, 1354, "*2 " EnvGet("Premiere") "video.png")
				{
					toolCust("you aren't scrolled down", "1000")
					blockOff()
					KeyWait(A_ThisHotkey)
					return
				}
			else
				goto next
		}
	next:
	if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% ".png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% "2.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for when you have the "toggle animation" keyframe button pressed
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% "3.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for if the property you want to adjust is "selected"
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% "4.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for if the property you want to adjust is "selected" and you're keyframing
	else
		{
			blockOff()
			toolFind("the image", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	colour:
	if PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "740", %&y% + "40", 0x288ccf, 3) ;searches for the blue text to the right of the value you want to adjust
		MouseMove(%&xcol% + %&optional%, %&ycol%)
	else if PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "720", %&y% + "40", 0x295C4D, 3) ;searches for a different shade of blue as a fallback
				MouseMove(%&xcol% + %&optional%, %&ycol%)
	else
		{
			blockOff()
			toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	sleep 50 ;required, otherwise it can't know if you're trying to tap to reset
	;I tried messing around with "if A_TimeSincePriorHotkey < 100" instead of a sleep here but premiere would get stuck in a state of "clicking" on the field if I pressed a macro, then let go quickly but after the 100ms. Maybe there's a smarter way to make that work, but honestly just kicking this sleep down to 50 from 100 works fine enough for me and honestly isn't even really noticable.
	if GetKeyState(A_ThisHotkey, "P")
		{
			SendInput("{Click Down}")
			blockOff()
			KeyWait(A_ThisHotkey)
			SendInput("{Click Up}" "{Enter}")
			MouseMove(%&xpos%, %&ypos%)
		}
	else
		{
			if ImageSearch(&x2, &y2, %&x%, %&y% - "10", %&x% + "1500", %&y% + "20", "*2 " EnvGet("Premiere") "reset.png") ;searches for the reset button to the right of the value you want to adjust
				{
					MouseMove(%&x2%, %&y2%)
					SendInput("{Click}")
				}
			else ;if everything fails, this else will trigger
				{
					if A_ThisHotkey = levelsHotkey ;THIS IS FOR ADJUSTING THE "LEVEL" PROPERTY, CHANGE IN THE KEYBOARD SHORTCUTS.INI FILE
						{
							SendInput("{Click}" "0" "{Enter}")
							MouseMove(%&xpos%, %&ypos%)
							blockOff()
							return
						}
					MouseMove(%&xpos%, %&ypos%)
					blockOff()
					toolFind("the reset button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
		}
}

keyreset(filepath)
;&filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
{
	MouseGetPos(&xpos, &ypos)
	noclips()
	if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% "2.png")
		goto click
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% "4.png")
		goto click
	else
		{
			toolCust("you're already keyframing", "1000")
			blockOff()
			return
		}
	click:
	MouseMove(%&x% + "5", %&y% + "2")
	click
	blockOff()
	MouseMove(%&xpos%, %&ypos%)
}

keyframe(filepath)
;&filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
{
	MouseGetPos(&xpos, &ypos)
	noclips()
	if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% "2.png")
		goto next
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% "4.png")
		goto next
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% ".png")
		{
			MouseMove(%&x% + "5", %&y% + "5")
			Click()
			goto end
		}
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&filepath% "3.png")
		{
			MouseMove(%&x% + "5", %&y% + "5")
			Click()
			goto end
		}
	else
		{
			toolCust("ya broke it", "1000")
			blockOff()
			return
		}
	next:
	if ImageSearch(&keyx, &keyy, %&x%, %&y%, %&x% + "500", %&y% + "20", "*2 " EnvGet("Premiere") "keyframeButton.png")
		MouseMove(%&keyx% + "3", %&keyy%)
	else if ImageSearch(&keyx, &keyy, %&x%, %&y%, %&x% + "500", %&y% + "20", "*2 " EnvGet("Premiere") "keyframeButton2.png")
		MouseMove(%&keyx% + "3", %&keyy%)
	Click()
	end:
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro 2021" ;focuses the timeline
	MouseMove(%&xpos%, %&ypos%)
	blockOff()
}

audioDrag(sfxName)
{
	SendInput(mediaBrowser) ;highlights the media browser ~ check the keyboard shortcut ini file to adjust hotkeys
	;KeyWait(A_PriorKey) ;I have this set to remapped mouse buttons which instantly "fire" when pressed so can cause errors
	blockOn()
	coords()
	MouseGetPos(&xpos, &ypos)
		SendInput(mediaBrowser) ;highlights the media browser ~ check the keyboard shortcut ini file to adjust hotkeys
		sleep 10
		if ImageSearch(&sfx, &sfy, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "sfx.png") ;searches for my sfx folder in the media browser to see if it's already selected or not
			{
				MouseMove(%&sfx%, %&sfy%) ;if it isn't selected, this will move to it then click it
				SendInput("{Click}")
				goto next
			}
		else if ImageSearch(&sfx, &sfy, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "sfx2.png") ;if it is selected, this will see it, then move on
			goto next
		else ;if everything fails, this else will trigger
			{
				blockOff()
				toolFind("sfx folder", "1000")
				return
			}
		next:
		SendInput(findBox) ;adjust this in the keyboard shortcuts ini file
		coordc()
		SendInput("^a{DEL}") ;deletes anything that might be in the search box
		SendInput(%&sfxName%)
		sleep 50
		if ImageSearch(&vlx, &vly, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "vlc.png") ;searches for the vlc icon to grab the track
			{
				MouseMove(%&vlx%, %&vly%)
				SendInput("{Click Down}")
			}
		else
			{
				blockOff()
				toolFind("vlc image", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
				return
			}
		MouseMove(%&xpos%, %&ypos%)
		SendInput("{Click Up}")
		blockOff()
}

movepreview() ;press then hold this hotkey and drag to move position. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
{
	coords()
	blockOn()
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "motion.png") ;moves to the motion tab
			MouseMove(%&x% + "25", %&y%)
	else
		{
			blockOff()
			toolFind("the motion tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}

	sleep 100
	if GetKeyState(A_ThisHotkey, "P") ;gets the state of the hotkey, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
		{ ;you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable to move the preview window
			Click
			MouseMove(2300, 238) ;move to the preview window
			SendInput("{Click Down}")
			blockOff()
			KeyWait A_ThisHotkey
			SendInput("{Click Up}")
			;MouseMove(%&xpos%, %&ypos%) ; // moving the mouse position back to origin after doing this is incredibly disorienting
		}
	else
		{
			if ImageSearch(&xcol, &ycol, 8, 1049, 589, 1090, "*2 " EnvGet("Premiere") "reset.png") ;these coords are set higher than they should but for whatever reason it only works if I do that????????
					MouseMove(%&xcol%, %&ycol%)
			else ;if everything fails, this else will trigger
				{
					blockOff()
					MouseMove(%&xpos%, %&ypos%)
					toolFind("the reset button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
			Click
			sleep 50
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
		}
}

reset() ;This script moves to the reset button to reset the "motion" effects
{
	KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
	coordw()
	blockOn()
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&x2, &y2, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "motion2.png") ;checks if the "motion" value is in view
		goto inputs
	else if ImageSearch(&x2, &y2, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "motion3.png") ;checks if the "motion" value is in view
		goto inputs
	else
		{
			blockOff()
			toolFind("the motion value", "1000")
			return
		}
	inputs:
		SendInput(timelineWindow) ;~ check the keyboard shortcut ini file to adjust hotkeys
		SendInput(labelIris) ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
		if ImageSearch(&xcol, &ycol, %&x2%, %&y2% - "20", %&x2% + "700", %&y2% + "20", "*2 " EnvGet("Premiere") "reset.png") ;this will look for the reset button directly next to the "motion" value
			MouseMove(%&xcol%, %&ycol%)
		;SendInput, {WheelUp 10} ;not necessary as we use imagesearch to check for the motion value
		click
	MouseMove(%&xpos%, %&ypos%)
	blockOff()
}

hotkeyDeactivate()
{
	Hotkey("~Numpad0", "r", "On") ;all of these "hotkeys" allow me to use my numpad to input numbers instead of having to take my hand off my mouse to press the numpad on my actual keyboard
	Hotkey("~Numpad1", "r", "On") ;I have it call on "r" because, well, r isn't a key that exists on my numpad. if I put this value at something that's already defined, then the original macros will fire
	;Hotkey("~SC05C & Numpad1", "Numpad1", "On")
	Hotkey("~Numpad2", "r", "On")
	Hotkey("~Numpad3", "r", "On")
	Hotkey("~Numpad4", "r", "On")
	Hotkey("~Numpad5", "r", "On")
	Hotkey("~Numpad6", "r", "On")
	Hotkey("~Numpad7", "r", "On")
	Hotkey("~Numpad8", "r", "On")
	Hotkey("~Numpad9", "r", "On")
	Hotkey("NumpadDot", "e", "On")
	Hotkey("~NumpadEnter", "r", "On")
}

hotkeyReactivate()
{
	Hotkey("Numpad0", "Numpad0")
	Hotkey("Numpad1", "Numpad1")
	Hotkey("Numpad2", "Numpad2")
	Hotkey("Numpad3", "Numpad3")
	Hotkey("Numpad4", "Numpad4")
	Hotkey("Numpad5", "Numpad5")
	Hotkey("Numpad6", "Numpad6")
	Hotkey("Numpad7", "Numpad7")
	Hotkey("Numpad8", "Numpad8")
	Hotkey("Numpad9", "Numpad9")
	Hotkey("NumpadDot", "NumpadDot")
	Hotkey("NumpadEnter", "NumpadEnter")
}

manInput(property, optional, key1, key2, keyend) ;a script that will warp to and press any value in premiere to manually input a number
;&property is the value you want to adjust
;&key1 is the hotkey you use to activate this function
;&key2 is the other hotkey you use to activate this function (if you only use 1 button to activate it, remove one of the keywaits and this variable)
;&keyend is whatever key you want the function to wait for before finishing
{
	coords()
	blockOn()
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&property% ".png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
		goto colour
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&property% "2.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for when you have the "toggle animation" keyframe button pressed
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&property% "3.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for if the property you want to adjust is "selected"
	else if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") %&property% "4.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for if the property you want to adjust is "selected" and you're keyframing
	else ;if everything fails, this else will trigger
		{
			blockOff()
			toolFind("the property you wish to adjust", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	colour:
	if PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "740", %&y% + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
		MouseMove(%&xcol% + %&optional%, %&ycol%)
	else
		{
			blockOff()
			toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	KeyWait(%&key1%) ;waits for you to let go of hotkey
	KeyWait(%&key2%) ;waits for you to let go of hotkey
	hotkeyDeactivate()
	SendInput("{Click}")
	KeyWait(%&keyend%, "D") ;waits until the final hotkey is pressed before continuing
	SendInput("{Enter}")
	MouseMove(%&xpos%, %&ypos%)
	hotkeyReactivate()
	Click("middle")
	blockOff()
}

gain(amount) ;a macro to increase/decrease gain. This macro will check to ensure the timeline is in focus and a clip is selected
;&amount is the value you want the gain to adjust (eg. -2, 6, etc)
{
	KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro 2021"
	if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
		{
			SendInput(timelineWindow selectAtPlayhead) ;~ check the keyboard shortcut ini file to adjust hotkeys
			goto inputs
		}
	else
		{
			classNN := ControlGetClassNN(ControlGetFocus("A"))
			if "DroverLord - Window Class3"
				goto inputs
			else
				{
					toolCust("gain macro couldn't figure`nout what to do", "1000")
					return
				}
		}
	inputs:
	SendInput("g" "+{Tab}{UP 3}{DOWN}{TAB}" %&amount% "{ENTER}")
}

gainSecondary(key1, key2, keyend) ;a macro to open up the gain menu. This macro will check to ensure the timeline is in focus and a clip is selected
;&key1 is the hotkey you use to activate this function
;&key2 is the other hotkey you use to activate this function (if you only use 1 button to activate it, remove one of the keywaits and this variable)
;&keyend is whatever key you want the function to wait for before finishing
{
;KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro 2021"
	if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
		{
			SendInput(timelineWindow selectAtPlayhead) ;~ check the keyboard shortcut ini file to adjust hotkeys
			goto inputs
		}
	else
		{
			classNN := ControlGetClassNN(ControlGetFocus("A"))
			if "DroverLord - Window Class3"
				goto inputs
			else
				{
					toolCust("gain macro couldn't figure`nout what to do", "1000")
					return
				}
		}
	inputs:
	KeyWait(%&key1%) ;waits for you to let go of hotkey
	KeyWait(%&key2%) ;waits for you to let go of hotkey
	hotkeyDeactivate()
	SendInput(gainAdjust) ;~ check the keyboard shortcut ini file to adjust hotkeys
	KeyWait(%&keyend%, "D") ;waits until the final hotkey is pressed before continuing
	hotkeyReactivate()
}
; ===========================================================================================================================================
;
;		After Effects \\ Last updated: v2.6
;
; ===========================================================================================================================================
aevaluehold(button, property, optional) ;a preset to warp to one of a videos values (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
;&button is the hotkey within after effects that's used to open up the property you want to adjust
;&property is the filename of just the property itself ie. "scale" not "scale.png" or "scale2"
;&optional is for when you need the mouse to move extra coords over to avoid the first "blue" text for some properties
{
	coordw()
	MouseGetPos(&x, &y)
	if(%&x% > 550 and %&x% < 2542) and (%&y% > 1010) ;this ensures that this function only tries to activate if it's within the timeline of after effects
		{	
			blockOn()
			MouseGetPos(&X, &Y)
			if ImageSearch(&selectX, &selectY, 8, 8, 299, 100, "*2 " EnvGet("AE") "selection.png")
				{
					MouseMove(%&selectX%, %&selectY%)
					Click
					MouseMove(%&X%, %&Y%)
				}
			Click()
			SendInput(anchorpointProp) ;swaps to a redundant value (in this case "anchor point" because I don't use it) ~ check the keyboard shortcut ini file to adjust hotkeys
			sleep 150
			SendInput(%&button%) ;then swaps to your button of choice. We do this switch second to ensure it and it alone opens (if you already have scale open for example then you press "s" again, scale will hide)
			sleep 300 ;after effects is slow as hell so we have to give it time to swap over or the imagesearch's won't work
			if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " EnvGet("AE") %&property% ".png")
				goto colour
			else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " EnvGet("AE") %&property% "2.png")
				goto colour
			else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " EnvGet("AE") %&property% "Key.png")
				goto colour
			else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " EnvGet("AE") %&property% "Key2.png")
				goto colour
			else
				{
					blockOff()
					toolFind("the property you're after", "1000")
					KeyWait(A_ThisHotkey)
					return
				}
			colour:
			if PixelSearch(&xcol, &ycol, %&propX%, %&propY% + "8", %&propX% + "740", %&propY% + "40", 0x288ccf, 3)
				MouseMove(%&xcol% + %&optional%, %&ycol%)
			;sleep 50
			if GetKeyState(A_ThisHotkey, "P")
				{
					SendInput("{Click Down}")
					blockOff()
					KeyWait(A_ThisHotkey)
					SendInput("{Click Up}")
					MouseMove(%&x%, %&y%)
				}
			else ;if you tap, this function will then right click and menu to the "reset" option in the right click context menu
				{
					Click("Right")
					SendInput("{Up 6}" "{Enter}")
					MouseMove(%&x%, %&y%)
					blockOff()
				}
		}
	else
		toolCust("you're not hovering a track", "1000")
}

; ===========================================================================================================================================
;
;		Photoshop \\ Last updated: v2.6
;
; ===========================================================================================================================================
psProp(image) ;a preset to warp to one of a photos values values (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease.
;&image is the png name of the image that imagesearch will use
{
	coords()
	MouseGetPos(&xpos, &ypos)
	coordw()
	blockOn()
	if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " EnvGet("Photoshop") "text2.png") ;checks to see if you're typing
		SendInput("^{Enter}")
	if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " EnvGet("Photoshop") "text.png") ;checks to see if you're in the text tool
		SendInput("v") ;if you are, it'll press v to go to the selection tool
	if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " EnvGet("Photoshop") "InTransform.png") ;checks to see if you're already in the free transform window
		{
			if ImageSearch(&x, &y, 60, 30, 744, 64, "*5 " EnvGet("Photoshop") %&image%) ;if you are, it'll then search for your button of choice and move to it
				MouseMove(%&x%, %&y%)
			else ;if everything fails, this else will trigger
				{
					blockOff()
					toolFind("the value you wish`nto adjust_1", "1000")
					return
				}
		}
	else
		{
			SendInput(freeTransform) ;if you aren't in the free transform it'll simply press your hotkey to get you into it. check the ini file to adjust this hotkey
			ToolTip("we must wait for photoshop`nbecause it's slow as hell")
			sleep 300 ;photoshop is slow
			ToolTip("")
			if ImageSearch(&x, &y, 111, 30, 744, 64, "*5 " EnvGet("Photoshop") %&image%) ;moves to the position variable
				MouseMove(%&x%, %&y%)
			else ;if everything fails, this else will trigger
				{
					MouseMove(%&xpos%, %&ypos%)
					blockOff()
					toolFind("the value you wish`nto adjust_2", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
		}		
	sleep 100 ;this sleep is necessary for the "tap" functionality below (in the 'else') to work
	SendInput("{Click Down}")
	if GetKeyState(A_ThisHotkey, "P")
		{
			blockOff()
			KeyWait(A_ThisHotkey)
			SendInput("{Click Up}")
			MouseMove(%&xpos%, %&ypos%)
		}
	else ;since we're in photoshop here, we'll simply make the "tap" functionality have ahk hit enter twice so it exits out of the free transform
		{
			Click("{Click Up}")
			;fElse(%&data%) ;check MS_functions.ahk for the code to this preset
			MouseMove(%&xpos%, %&ypos%)
			SendInput("{Enter 2}")
			blockOff()
			return
		}
}

psSave() ;This function is to speed through the twitch emote saving process. Doing this manually is incredibly tedious and annoying, so why do it manually?
;This script will require the latest (or at least the version containing the "save as copy" window) version of photoshop to function
;PHOTOSHOP IS SLOW AS ALL HELL
;if things in this script don't work or get stuck, consider increasing the living hell out of the sleeps along the way
{
	save(size)
	{
		WinActivate("ahk_exe Photoshop.exe")
		blockOn()
		SendInput(imageSize) ;check the keyboard shortcut ini file
		WinWait("Image Size")
		SendInput(%&size% "{tab 2}" %&size% "{Enter}")
		sleep 1000
		SendInput(saveasCopy) ;check the keyboard shortcut ini file
		WinWait("Save a Copy")
	}
	image()
	{
		sleep 500
		Send("{TAB}{RIGHT}")
		coordw()
		sleep 1000
		if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " EnvGet("Photoshop") "pngSel.png")
			{
				MouseMove(0, 0)
				SendInput("{Enter 2}")
			}

		else
			{
				if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " EnvGet("Photoshop") "pngNotSel.png")
					{
						MouseMove(%&xpng%, %&ypng%)
						SendInput("{Click}")
						sleep 50
						MouseMove(0, 0)
						SendInput("{Enter}")
					}
				else
					{
						MouseMove(0, 0)
						blockOff()
						toolFind("png", "1000")
						return
					}
			}
	}

	Emote := InputBox("Please enter an Emote Name.", "Emote Name", "w100 h100")
		if Emote.Result = "Cancel"
			return
		else
			goto dir
	dir:
	dir := DirSelect("*::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", 3, "Pick the destination folder you wish everything to save to.")
		if dir = ""
			return
	next:
	;=============================112x112
	save("112")
	sleep 1000
	SendInput("{F4}" "^a")
	SendInput(Dir "{Enter}")
	sleep 1000
	SendInput("+{Tab 9}")
	sleep 100
	SendInput(Emote.Value "_112")
	image()
	WinWait("PNG Format Options")
	SendInput("{Enter}")
	;=============================56x56
	save("56")
	SendInput("{F4}" "^a")
	SendInput(Dir "{Enter}")
	sleep 1000
	SendInput("+{Tab 9}")
	SendInput(Emote.Value "_56")
	image()
	WinWait("PNG Format Options")
	SendInput("{Enter}")
	;=============================28x28
	save("28")
	SendInput("{F4}" "^a")
	SendInput(Dir "{Enter}")
	sleep 1000
	SendInput("+{Tab 9}")
	SendInput(Emote.Value "_28")
	image()
	WinWait("PNG Format Options")
	SendInput("{Enter}")
	blockOff()
}

; ===========================================================================================================================================
;
;		Resolve \\ Last updated: v2.6
;
; ===========================================================================================================================================
Rscale(value, property, plus) ;to set the scale of a video within resolve
;&value is the number you want to type into the text field (100% in reslove requires a 1 here for example)
;&property is the property you want this function to type a value into (eg. zoom)
;&plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
{
	KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
	coordw()
	blockOn()
	SendInput(resolveSelectPlayhead)
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xi, &yi, 2142, 33, 2561, 115, "*2 " EnvGet("Resolve") "inspector.png")
		goto video
	else if ImageSearch(&xi, &yi, 2142, 33, 2561, 115, "*2 " EnvGet("Resolve") "inspector2.png")
		{
			MouseMove(%&xi%, %&yi%)
			click ;this opens the inspector tab
			goto video
		}
	video:
	if ImageSearch(&xn, &yn, 2148, 116, 2562, 169, "*5 " EnvGet("Resolve") "video.png") ;if you're already in the video tab, it'll find this image then move on
		goto rest
	else if ImageSearch(&xn, &yn, 2148, 116, 2562, 169, "*5 " EnvGet("Resolve") "videoN.png") ;if you aren't already in the video tab, this line will search for it
		{
			MouseMove(%&xn%, %&yn%)
			click ;"2196 139" ;this highlights the video tab
		}
	else
		{
			blockOff()
			MouseMove(%&xpos%, %&ypos%)
			toolFind("video tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	rest:
	if ImageSearch(&xz, &yz, 2147, 86, 2561, 750, "*5 " EnvGet("Resolve") %&property% ".png") ;searches for the property of choice
		MouseMove(%&xz% + %&plus%, %&yz% + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
	else if ImageSearch(&xz, &yz, 2147, 86, 2561, 750, "*5 " EnvGet("Resolve") %&property% "2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
		MouseMove(%&xz% + %&plus%, %&yz% + "5")
	else
		{
			blockOff()
			toolFind("your desired property", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	click
	SendInput(%&value%)
	SendInput("{ENTER}")
	MouseMove(%&xpos%, %&ypos%)
	SendInput("{MButton}")
	blockOff()
}

rfElse(data) ;a preset for the resolve scale, x/y and rotation scripts
;&data is what the script is typing in the text box to reset its value
;this function, as you can probably tell, doesn't use an imagesearch. It absolutely SHOULD, but I don't use resolve and I guess I just never got around to coding in an imagesearch.
{
	SendInput("{Click Up}")
	sleep 10
	Send(%&data%)
	;MouseMove, x, y ;if you want to press the reset arrow, input the windowspy SCREEN coords here then comment out the above Send^
	;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
	;alternatively you could also run imagesearches like in the other resolve functions to ensure you always end up in the right place
	sleep 10
	Send("{Enter}")
}

REffect(folder, effect) ;apply any effect to the clip you're hovering over.
;&folder is the name of your screenshots of the drop down sidebar option (in the effects window) you WANT to be active - both activated and deactivated
;&effect is the name of the effect you want this function to type into the search box

;This function will, in order;
;Check to see if the effects window is open on the left side of the screen
;Check to make sure the effects sidebar is expanded
;Ensure you're clicked on the appropriate drop down
;Open or close/reopen the search bar
;Search for your effect of choice, then drag back to the click you were hovering over originally
{
	KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
	coordw()
	blockOn()
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xe, &ye, 8, 8, 618, 122, "*1 " EnvGet("Resolve") "effects.png") ;checks to see if the effects button is deactivated
		{
			MouseMove(%&xe%, %&ye%)
			SendInput("{Click}")
			goto closeORopen
		}
	else if ImageSearch(&xe, &ye, 8, 8, 618, 122, "*1 " EnvGet("Resolve") "effects2.png") ;checks to see if the effects button is activated
		goto closeORopen
	else ;if everything fails, this else will trigger
		{
			blockOff()
			toolFind("the effects button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
closeORopen:
;MsgBox("close/open")
	if ImageSearch(&xopen, &yopen, 8, 114, 617, 1358, "*2 " EnvGet("Resolve") "open.png") ;checks to see if the effects window sidebar is open
		goto EffectFolder
	else if ImageSearch(&xclosed, &yclosed, 8, 114, 617, 1358, "*2 " EnvGet("Resolve") "closed.png") ;checks to see if the effects window sidebar is closed
		{
			MouseMove(%&xclosed%, %&yclosed%)
			SendInput("{Click}")
			goto EffectFolder
		}
	else
		{
			blockOff()
			toolFind("open/close button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
EffectFolder:
	;MsgBox("effect folder")
	if ImageSearch(&xfx, &yfx, 8, 114, 617, 1358, "*2 " EnvGet("Resolve") %&folder% ".png") ;checks to see if the drop down option you want is activated
		goto SearchButton
	else if ImageSearch(&xfx, &yfx, 8, 114, 617, 1358, "*2 " EnvGet("Resolve") %&folder% "2.png") ;checks to see if the drop down option you want is deactivated
		{
			MouseMove(%&xfx%, %&yfx%)
			SendInput("{Click}")
			goto SearchButton
		}
	else ;if everything fails, this else will trigger
		{
			blockOff()
			toolFind("the fxfolder", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}	
SearchButton:
;MsgBox("search button")
	if ImageSearch(&xs, &ys, 8, 118, 617, 1356, "*2 " EnvGet("Resolve") "search2.png") ;checks to see if the search icon is deactivated
		{
			MouseMove(%&xs%, %&ys%)
			SendInput("{Click}")
			goto final
		}
	else if ImageSearch(&xs, &ys, 8, 118, 617, 1356, "*2 " EnvGet("Resolve") "search3.png") ;checks to see if the search icon is activated
		{
			MouseMove(%&xs%, %&ys%)
			SendInput("{Click 2}")
			goto final
		}
	else ;if everything fails, this else will trigger
		{
			blockOff()
			toolFind("search button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
final:
;MsgBox("final")
	sleep 50
	SendInput(%&effect%)
	MouseMove(0, 130,, "R")
	SendInput("{Click Down}")
	MouseMove(%&xpos%, %&ypos%, 2) ;moves the mouse at a slower, more normal speed because resolve doesn't like it if the mouse warps instantly back to the clip
	SendInput("{Click Up}")
	blockOff()
	return
}

rvalhold(property, plus, rfelseval) ;this function provides similar functionality to my valuehold() function for premiere
;&property refers to both of the screenshots (either active or not) for the property you wish to adjust
;&plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
;&rfelseval is the value you wish to pass to rfelse()
{
	coordw()
	blockOn()
	SendInput(resolveSelectPlayhead)
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xi, &yi, 2142, 33, 2561, 115, "*2 " EnvGet("Resolve") "inspector.png")
		goto video
	else if ImageSearch(&xi, &yi, 2142, 33, 2561, 115, "*2 " EnvGet("Resolve") "inspector2.png")
		{
			MouseMove(%&xi%, %&yi%)
			click ;this opens the inspector tab
			goto video
		}
	video:
	if ImageSearch(&xn, &yn, 2148, 116, 2562, 169, "*5 " EnvGet("Resolve") "video.png") ;if you're already in the video tab, it'll find this image then move on
		goto rest
	else if ImageSearch(&xn, &yn, 2148, 116, 2562, 169, "*5 " EnvGet("Resolve") "videoN.png") ;if you aren't already in the video tab, this line will search for it
		{
			MouseMove(%&xn%, %&yn%)
			click ;"2196 139" ;this highlights the video tab
		}
	else
		{
			blockOff()
			MouseMove(%&xpos%, %&ypos%)
			toolFind("video tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	rest:
	;MouseMove 2329, 215 ;moves to the scale value.
	if ImageSearch(&xz, &yz, 2147, 86, 2561, 750, "*5 " EnvGet("Resolve") %&property% ".png") ;searches for the property of choice
		MouseMove(%&xz% + %&plus%, %&yz% + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
	else if ImageSearch(&xz, &yz, 2147, 86, 2561, 750, "*5 " EnvGet("Resolve") %&property% "2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
		MouseMove(%&xz% + %&plus%, %&yz% + "5")
	else
		{
			blockOff()
			toolFind("your desired property", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	sleep 100
	SendInput("{Click Down}")
	if GetKeyState(A_ThisHotkey, "P")
		{
			blockOff()
			KeyWait(A_ThisHotkey)
			SendInput("{Click Up}")
			MouseMove(%&xpos%, %&ypos%)
		}
	else
		{
			rfElse(%&rfelseval%) ;do note rfelse doesn't use any imagesearch information and just uses raw pixel values (not a great idea), so if you have any issues, do look into changing that
			MouseMove(%&xpos%, %&ypos%)
			SendInput("{MButton}")
			blockOff()
			return
		}
}

rflip(button) ;this function searches for and presses the horizontal/vertical flip button
;&button1 is the png name of a screenshot of the button you wish to click (either activated or deactivated)
{
	coordw()
	blockOn()
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xn, &yn, 2148, 116, 2562, 169, "*5 " EnvGet("Resolve") "videoN.png") ;makes sure the video tab is selected
		{
			MouseMove(%&xn%, %&yn%)
			click
		}
	if ImageSearch(&xh, &yh, 2146, 168, 2556, 382, "*5 " EnvGet("Resolve") %&button% ".png") ;searches for the button when it isn't activated already
		{
			MouseMove(%&xh%, %&yh%)
			click
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
			return
		}
	else if ImageSearch(&xho, &yho, 2146, 168, 2556, 382, "*5 " EnvGet("Resolve") %&button% "2.png") ;searches for the button when it is activated already
		{
			MouseMove(%&xho%, %&yho%)
			click 
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
			return
		}
	else
		{
			blockOff()
			MouseMove(%&xpos%, %&ypos%)
			toolFind("desired button", "1000")
		}
}

rgain(value) ;this function allows you to adjust the gain of the selected clip similar to my gain macros in premiere. You can't pull this off quite as fast as you can in premiere, but it's still pretty useful
;&value is how much you want the gain to be adjusted by
{
	coordw()
	blockOn()
	SendInput(resolveSelectPlayhead)
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xi, &yi, 2142, 33, 2561, 115, "*2 " EnvGet("Resolve") "inspector.png")
		goto audio
	else if ImageSearch(&xi, &yi, 2142, 33, 2561, 115, "*2 " EnvGet("Resolve") "inspector2.png")
		{
			MouseMove(%&xi%, %&yi%)
			click ;this opens the inspector tab
			goto audio
		}
	audio:
	if ImageSearch(&xn, &yn, 2148, 116, 2562, 169, "*5 " EnvGet("Resolve") "audio2.png") ;if you're already in the audio tab, it'll find this image then move on
		goto rest
	else if ImageSearch(&xn, &yn, 2148, 116, 2562, 169, "*5 " EnvGet("Resolve") "audio.png") ;if you aren't already in the audio tab, this line will search for it
		{
			MouseMove(%&xn%, %&yn%)
			click ;"2196 139" ;this highlights the video tab
		}
	else
		{
			blockOff()
			MouseMove(%&xpos%, %&ypos%)
			toolFind("audio tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	rest:
	if ImageSearch(&xz, &yz, 2147, 86, 2561, 750, "*5 " EnvGet("Resolve") "volume.png") ;searches for the volume property
		MouseMove(%&xz% + "215", %&yz% + "5") ;moves the mouse to the value next to volume. This function assumes x/y are linked
	else if ImageSearch(&xz, &yz, 2147, 86, 2561, 750, "*5 " EnvGet("Resolve") "volume2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
		MouseMove(%&xz% + "215", %&yz% + "5")
	else
		{
			blockOff()
			toolFind("your desired property", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	SendInput("{Click 2}")
	A_Clipboard := ""
	;sleep 50
	SendInput("^c")
	ClipWait()
	gain := A_Clipboard + %&value%
	SendInput(gain)
	SendInput("{Enter}")
	MouseMove(%&xpos%, %&ypos%)
	blockOff()
}

; ===========================================================================================================================================
;
;		VSCode \\ Last updated: v2.6.3
;
; ===========================================================================================================================================
vscode(script) ;a script to quickly naviate between my scripts
;&script is just what script I want to open
{
	KeyWait(A_PriorKey)
	coords()
	blockOn()
	MouseGetPos(&x, &y)
	if ImageSearch(&xex, &yex, 0, 0, 460, 1390, "*2 " EnvGet("VSCode") "explorer.png")
		{
			MouseMove(%&xex%, %&yex%)
			SendInput("{Click}")
			MouseMove(%&x%, %&y%)
			sleep 50
		}
	if ImageSearch(&xpos, &ypos, 0, 0, 460, 1390, "*2 " EnvGet("VSCode") %&script% "_Changes.png")
		goto click
	else if ImageSearch(&xpos, &ypos, 0, 0, 460, 1390, "*2 " EnvGet("VSCode") %&script% "_nochanges.png")
		goto click
	else if ImageSearch(&xpos, &ypos, 0, 0, 460, 1390, "*2 " EnvGet("VSCode") %&script% "_red.png")
		goto click
	else if ImageSearch(&xpos, &ypos, 0, 0, 460, 1390, "*2 " EnvGet("VSCode") %&script% "_Highlighted.png")
		goto already
	else if ImageSearch(&xpos, &ypos, 0, 0, 460, 1390, "*2 " EnvGet("VSCode") %&script% "_ChangesHighlighted.png")
		goto already
	else if ImageSearch(&xpos, &ypos, 0, 0, 460, 1390, "*2 " EnvGet("VSCode") %&script% "_redHighlighted.png")
		goto already
	else 
		{
			blockOff()
			toolFind("the script", "1000")
			return
		}
	already:
	{
		blockOff()
		toolCust("you're already in the &" %&script% A_Space "script`nyou dork", "2000")
		return
	}
	click:
	MouseMove(%&xpos%, %&ypos%)
	SendInput("{Click}")
	MouseMove(%&x%, %&y%)
	blockOff()
}

; ===========================================================================================================================================
;
;		QMK Stuff \\ Last updated: v2.5.~
;
; ===========================================================================================================================================
numpad000() ;this function is to suppress the multiple keystrokes the "000" key sends on my secondary numpad and will in the future be used to do... something
{
		static winc_presses := 0
		if winc_presses > 0 ; SetTimer already started, so we log the keypress instead.
		{
			winc_presses += 1
			return
		}
		; Otherwise, this is the first press of a new series. Set count to 1 and start
		; the timer:
		winc_presses := 1
		SetTimer After400, -50 ; Wait for more presses within a 400 millisecond window.
	
		After400()  ; This is a nested function.
		{
			if winc_presses = 1 ; The key was pressed once.
			{
				sleep 10  ; Open a folder.
			}
			else if winc_presses = 2 ; The key was pressed twice.
			{
				; PUT CODE HERE LATER ````````````````````````````````
			}
			else if winc_presses > 2
			{
				sleep 10
			}
			; Regardless of which action above was triggered, reset the count to
			; prepare for the next series of presses:
			winc_presses := 0
		}
}

; ===========================================================================================================================================
;
;		Fkey AutoLaunch \\ Last updated: v2.4.4
;
; ===========================================================================================================================================
switchToExplorer()
{
	if not WinExist("ahk_class CabinetWClass")
		Run "explorer.exe"
	GroupAdd "explorers", "ahk_class CabinetWClass"
	if WinActive("ahk_exe explorer.exe")
		GroupActivate "explorers", "r"
	else
		if WinExist("ahk_class CabinetWClass")
		WinActivate "ahk_class CabinetWClass" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToPremiere()
{
	if not WinExist("ahk_class Premiere Pro")
		{
		;Run, Adobe Premiere Pro.exe
		;Adobe Premiere Pro CC 2017
		; Run, C:\Program Files\Adobe\Adobe Premiere Pro CC 2017\Adobe Premiere Pro.exe ;if you have more than one version instlaled, you'll have to specify exactly which one you want to open.
		Run "Adobe Premiere Pro.exe"
		}
	else
		if WinExist("ahk_class Premiere Pro")
		WinActivate "ahk_class Premiere Pro"
}

switchToAE()
{
	if not WinExist("ahk_exe AfterFX.exe")
		{
		;Run, Adobe Premiere Pro.exe
		;Adobe Premiere Pro CC 2017
		; Run, C:\Program Files\Adobe\Adobe Premiere Pro CC 2017\Adobe Premiere Pro.exe ;if you have more than one version instlaled, you'll have to specify exactly which one you want to open.
		Run "AfterFX.exe"
		}
	else
		if WinExist("ahk_exe AfterFX.exe")
		WinActivate "ahk_exe AfterFX.exe"
}

switchToFirefox()
{
	sendinput "{SC0E8}" ;scan code of an unassigned key. Do I NEED this?
	if not WinExist("ahk_class MozillaWindowClass")
		Run "firefox.exe"
	if WinActive("ahk_exe firefox.exe")
		{
		Class := WinGetClass("A")
		;WinGetClass class, A
		if (class = "Mozillawindowclass1")
			msgbox "this is a notification"
		}
	if WinActive("ahk_exe firefox.exe")
		Send "^{tab}"
	else
		{
			if WinExist("ahk_exe firefox.exe")
				;WinRestore ahk_exe firefox.exe
					WinActivate "ahk_exe firefox.exe"
		;sometimes winactivate is not enough. the window is brought to the foreground, but not put into FOCUS.
		;the below code should fix that.
		;Controls := WinGetControlsHwnd("ahk_class MozillaWindowClass")
		;WinGet hWnd ID ahk_class MozillaWindowClass
		;Result := DllCall("SetForegroundWindow UInt hWnd")
		;DllCall("SetForegroundWindow" UInt hWnd) 
		}
}

switchToOtherFirefoxWindow()
{
;sendinput, {SC0E8} ;scan code of an unassigned key

;Process Exist firefox.exe
;msgbox errorLevel `n%errorLevel%
	if (PID := ProcessExist("firefox.exe"))
	{
		GroupAdd "firefoxes", "ahk_class MozillaWindowClass"
		if WinActive("ahk_class MozillaWindowClass")
			GroupActivate "firefoxes", "r"
		else
			WinActivate "ahk_class MozillaWindowClass"
	}
	else
		Run "firefox.exe"
}

switchToVSC()
{
	if not WinExist("ahk_exe Code.exe")
		Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe"
	GroupAdd "Code", "ahk_class Chrome_WidgetWin_1"
	if WinActive("ahk_exe Code.exe")
		GroupActivate "Code", "r"
	else
		if WinExist("ahk_exe Code.exe")
		WinActivate "ahk_exe Code.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToGithub()
{
	if not WinExist("ahk_exe GitHubDesktop.exe")
		Run "C:\Users\Tom\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
	GroupAdd "git", "ahk_class Chrome_WidgetWin_1"
	if WinActive("ahk_exe GitHubDesktop.exe")
		GroupActivate "git", "r"
	else
		if WinExist("ahk_exe GitHubDesktop.exe")
		WinActivate "ahk_exe GitHubDesktop.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToStreamdeck()
{
	if not WinExist("ahk_exe StreamDeck.exe")
		Run "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"
	GroupAdd "stream", "ahk_class Qt5152QWindowIcon"
	if WinActive("ahk_exe StreamDeck.exe")
		GroupActivate "stream", "r"
	else
		if WinExist("ahk_exe Streamdeck.exe")
		WinActivate "ahk_exe StreamDeck.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToExcel()
{
	if not WinExist("ahk_exe EXCEL.EXE")
		Run A_ProgramFiles "\Microsoft Office\root\Office16\EXCEL.EXE"
	GroupAdd "xlmain", "ahk_class XLMAIN"
	if WinActive("ahk_exe EXCEL.EXE")
		GroupActivate "xlmain", "r"
	else
		if WinExist("ahk_exe EXCEL.EXE")
		WinActivate "ahk_exe EXCEL.EXE"
}

switchToWindowSpy()
{
	if not WinExist("WindowSpy.ahk")
		Run A_ProgramFiles "\AutoHotkey\WindowSpy.ahk"
	GroupAdd "winspy", "ahk_class AutoHotkeyGUI"
	if WinActive("WindowSpy.ahk")
		GroupActivate "winspy", "r"
	else
		if WinExist("WindowSpy.ahk")
		WinActivate "WindowSpy.ahk" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToYourPhone()
{
	if not WinExist("ahk_pid 13884") ;this process id may need to be changed for you. I also have no idea if it will stay the same
		Run "C:\Program Files\ahk\ahk\shortcuts\Your Phone.lnk"
	GroupAdd "yourphone", "ahk_class ApplicationFrameWindow"
	if WinActive("Your Phone")
		GroupActivate "yourphone", "r"
	else
		if WinExist("Your Phone")
		WinActivate "Your Phone" ;you have to use WinActivatebottom if you didn't create a window group.
}

; ===========================================================================================================================================
; Old
; ===========================================================================================================================================
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

this is the original way of doing value hold. Theoretically this isn't that bad, but if I move my effect controls too much, it would theoretically break
valuehold(x1, y1, x2, y2, button, data, optional) ;a preset to warp to one of a videos values (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
;&x1 is the pixel value for the first x coord for PixelSearch
;&y1 is the pixel value for the first y coord for PixelSearch
;&x2 is the pixel value for the second x coord for PixelSearch
;&y2 is the pixel value for the second y coord for PixelSearch
;&button is what button the function is being activated by (if you call this function from F1, put F1 here for example)
;&data is what the script is typing in the text box (what your reset values are. ie 960 for a pixel coord, or 100 for scale)
;&optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
{
	coords()
	blockOn()
	MouseGetPos(&xpos, &ypos)
		;MouseMove 226, 1079 ;move to the "x" value
		;if ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\position.png") ;moves to the position variable ;using an imagesearch here like this is only useful if I make the mouse move across until it "finds" the blue text. idk how to do that yet so this is getting commented out for now
			;MouseMove(%&x%, %&y%)
		if PixelSearch(&xcol, &ycol, %&x1%, %&y1%, %&x2%, %&y2%, 0x288ccf, 3) ;looks for the blue text to the right of scale
			MouseMove(%&xcol% + %&optional%, %&ycol%)
		sleep 100
		SendInput("{Click Down}")
			if GetKeyState(%&button%, "P")
			{
				blockOff()
				KeyWait %&button%
				SendInput("{Click Up}")
				MouseMove(%&xpos%, %&ypos%)
			}
			else
			{
				fElse(%&data%) ;check MS_functions.ahk for the code to this preset
				MouseMove(%&xpos%, %&ypos%)
				blockOff()
			}
}

gain() ;old gain code (v2.3.14)to use imagesearch instead of the ClassNN information
	/*
	if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\motion2.png")
		goto inputs
	else
		{
			if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\motion3.png") ;checks to see if the "motion" tab is highlighted as if it is, you'll start inputting values in that tab instead of adjusting the gain
				{
					SendInput("^+9") ;selects the timeline
					goto inputs
				}
			else
				{
					if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
						{
							SendInput("^+9" "d")
							goto inputs
						}
					else
						{
							toolCust("gain macro couldn't figure`nout what to do", "1000")
							return
						}
				}
		} */