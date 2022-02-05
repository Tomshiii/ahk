SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
#Include "%A_ScriptDir%\KSA\Keyboard Shortcut Adjustments.ahk"
#Include "%A_ScriptDir%\Functions\After Effects.ahk"
#Include "%A_ScriptDir%\Functions\Photoshop.ahk"
#Include "%A_ScriptDir%\Functions\Premiere.ahk"
#Include "%A_ScriptDir%\Functions\Resolve.ahk"
#Include "%A_ScriptDir%\Functions\switchTo.ahk"
#Include "%A_ScriptDir%\Functions\Windows.ahk"

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.10

;\\CURRENT RELEASE VERSION
;\\v2.3.1.1

; All of my functions use to be contained within this individual file but have since been split off into their own individual files which can be found in the \Functions\ folder in the root of the directory

; All Code in this script (and the individual functions scripts found in \Functions\) is linked to a function
; for example:
; func(variable)
; 	{
;		code(%&variable%)
;	}
; Then in our main scripts we call on these functions like:
; Hotkey::func("information")
; then whatever you place within the "" will be put wherever you have a %&variable%
; I make use of code like this all throughout this script. All variables are explained above their respective functions and dynamically display that information when you hover over a function if you're using VSCode

; I have made a concious effort throughout the workings of this script to keep out as many raw pixel coords as possible, preferring imagesearches to ensure correct mouse movements
; but even still, an imagesearch still has a definable area that it searches for each image, for example
; ImageSearch(&xpos, &ypos, 312, 64, 1066, 1479,~~~~~) (check the ahk documentation for what each number represents)
; searches in a rectangle defined by the above coords (pixel coords default to window unless you change it to something else)
; These values will be the only thing you should theoretically need to change to get things working in your own setups (outside of potentially needing your own screenshots for things as different setups can mean different colours etc etc)
; Most premiere functions require no tinkering before getting started as we can sneakily grab the coordinates of some panels within premiere without needing to define them anywhere. Not all of my scripts have this kind of treatment though as sometimes it's just not practical, sometimes a function is so heavily reliant on my workspace/workflow that it would be a waste of time as you'd need to change a bunch of stuff anyway, or sometimes it's just not possible with the way I'm doing things.
; For the functions that don't get this special treatment, I have tried to make as many of these values as possible directly editable within KSI.ini to make it both easier and faster for you to adjust these scripts to your own layouts. Take a look over there before looking around in here

; Here we will define a bunch of global variables that we will reference in ImageSearches. This is simply to help cut down the amount of things needed to write out and also to just make things cleaner overall to look at and help discern. Please note I have no way to add dynamic comments to these for VSCode users.
global Discord := A_WorkingDir "\ImageSearch\Discord\"
global Premiere := A_WorkingDir "\ImageSearch\Premiere\"
global AE := A_WorkingDir "\ImageSearch\AE\"
global Photoshop := A_WorkingDir "\ImageSearch\Photoshop\"
global Resolve := A_WorkingDir "\ImageSearch\Resolve\"
global VSCodeImage := A_WorkingDir "\ImageSearch\VSCode\"
global Explorer := A_WorkingDir "\ImageSearch\Windows\Win11\Explorer\"
global Firefox := A_WorkingDir "\ImageSearch\Firefox\"

; ===========================================================================================================================================
;
;		Coordmode \\ Last updated: v2.1.6
;
; ===========================================================================================================================================
/* coords()
 sets coordmode to "screen"
 */
coords()
{
	coordmode "pixel", "screen"
	coordmode "mouse", "screen"
}

/* coordw()
 sets coordmode to "window"
 */
coordw()
{
	coordmode "pixel", "window"
	coordmode "mouse", "window"
}

/* coordc()
 * sets coordmode to "caret"
 */
coordc()
{
	coordmode "caret", "window"
}

; ===========================================================================================================================================
;
;		Tooltip \\ Last updated: v2.3.13
;
; ===========================================================================================================================================

/* toolFind()
 create a tooltip for errors trying when to find things
 * @param message is what you want the tooltip to say after "couldn't find"
 * @param timeout is how many ms you want the tooltip to last
 */
toolFind(message, timeout)
{
	ToolTip("couldn't find " %&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}

/* toolCust()
 create a tooltip with any message
 * @param message is what you want the tooltip to say
 * @param timeout is how many ms you want the tooltip to last
 */
toolCust(message, timeout)
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
/* blockOn()
 blocks all user inputs [IF YOU GET STUCK IN A SCRIPT PRESS YOUR REFRESH HOTKEY (CTRL + R BY DEFAULT) OR USE CTRL + ALT + DEL to open task manager and close AHK]
 */
blockOn()
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
	;it has recently come to my attention that all 3 of these operate independantly and doing all 3 of them at once is no different to just using "BlockInput "on"" but uh. oops, too late now I guess
}

/* blockOff()
 turns off the blocks on user input
 */
blockOff()
{
	blockinput "MouseMoveOff"
	BlockInput "off"
}

; ===========================================================================================================================================
;
;		Mouse Drag \\ Last updated: v2.9
;
; ===========================================================================================================================================
/* mousedrag()
 press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example). This version is specifically for Premiere Pro, the below function is for any other program
 @param tool is the thing you want the program to swap TO (ie, hand tool, zoom tool, etc)
 @param toolorig is the button you want the script to press to bring you back to your tool of choice
 */
mousedrag(tool, toolorig)
{
	again()
	{
		if A_ThisHotkey = DragKeywait ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
			{
				if not GetKeyState(A_ThisHotkey, "P") ;this is here so it doesn't reactivate if you quickly let go before the timer comes back around
					return
			}
		else if not GetKeyState(DragKeywait, "P")
			return
		click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
		SendInput %&tool% "{LButton Down}"
		if A_ThisHotkey = DragKeywait ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
			KeyWait(A_ThisHotkey)
		else
			KeyWait(DragKeywait) ;A_ThisHotkey won't work here as the assumption is that LAlt & Xbutton2 will be pressed and ahk hates that
		SendInput("{LButton Up}")
		SendInput %&toolorig%
	}
	SetTimer(again, -400)
	again()
}

/* mousedragNotPrem()
 press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example)
 @param tool is the thing you want the program to swap TO (ie, hand tool, zoom tool, etc)
 @param toolorig is the button you want the script to press to bring you back to your tool of choice
 */
mousedragNotPrem(tool, toolorig)
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
/* timeline()
 a weaker version of the right click premiere script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock)
 @param timeline in this function defines the y pixel value of the top bar in your video editor that allows you to click it to drag along the timeline
 @param x1 is the furthest left pixel value of the timeline that will work with your cursor warping up to grab it
 @param x2 is the furthest right pixel value of the timeline that will work with your cursor warping up to grab it
 @param y1 is just below the bar that your mouse will be warping to, this way your mouse doesn't try doing things when you're doing other stuff above the timeline
 */
timeline(timeline, x1, x2, y1)
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









