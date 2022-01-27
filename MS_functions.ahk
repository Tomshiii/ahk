SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
#Include "%A_ScriptDir%\KSA\Keyboard Shortcut Adjustments.ahk"

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.9.6

;\\CURRENT RELEASE VERSION
;\\v2.3


; All Code in this script is linked to a function
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
;		Windows Scripts \\ Last updated: v2.9
;
; ===========================================================================================================================================
/* youMouse()
 a function to skip in youtube
 @param tenS is the hotkey for 10s skip in your direction of choice
 @param fiveS is the hotkey for 5s skip in your direction of choice
 */
youMouse(tenS, fiveS)
{
	if A_PriorKey = "Mbutton" ;ensures the hotkey doesn't fire while you're trying to open a link in a new tab
		return
	if WinExist("YouTube")
	{
		lastactive := WinGetID("A") ;fills the variable [lastavtive] with the ID of the current window
		WinActivate() ;activates Youtube if there is a window of it open
		sleep 25 ;sometimes the window won't activate fast enough
		if GetKeyState(longSkip, "P") ;checks to see if you have a second key held down to see whether you want the function to skip 10s or 5s. If you hold down this second button, it will skip 10s
			SendInput(%&tenS%)
		else
			SendInput(%&fiveS%) ;otherwise it will send 5s
		WinActivate(lastactive) ;will reactivate the original window
	}
}

/* monitorWarp()
 warp anywhere on your desktop
 */
monitorWarp(x, y)
{
	coords()
	MouseMove(%&x%, %&y%, 2) ;I need the 2 here as I have multiple monitors and things can be funky moving that far that fast. random ahk problems. Change this if you only have 1/2 monitors and see if it works fine for you
}

/* moveWin()
 A function that will check to see if you're holding the left mouse button, then move any window around however you like
 @param key is what key(s) you want the function to press to move a window around (etc. #Left/#Right)
 */
 moveWin(key)
 {
	if WinActive("ahk_class CabinetWClass") ;this if statement is to check whether windows explorer is active to ensure proper right click functionality is kept
		{
			if A_ThisHotkey = "RButton"
				{
					if not GetKeyState("LButton", "P") ;checks to see if the Left mouse button is held down, if it isn't, the below code will fire. This is here so you can still right click and drag
						{
							SendInput("{RButton Down}")
							KeyWait("RButton")
							SendInput("{RButton Up}")
							return
						}
				}
		}
	if not GetKeyState("LButton", "P") ;checks for the left mouse button as without this check the function will continue to work until you click somewhere else
		{
			SendInput("{" A_ThisHotkey "}")
			return
		}
	else
		{
			window := WinGetTitle("A") ;grabs the title of the active window
			SendInput("{LButton Up}") ;releases the left mouse button to stop it from getting stuck
			if A_ThisHotkey = minimiseHotkey ;this must be set to the hotkey you choose to use to minimise the window
				WinMinimize(window)
			if A_ThisHotkey = maximiseHotkey ;this must be set to the hotkey you choose to use to maximise the window
				WinMaximize(window)
			SendInput(%&key%)
		}
 }

; ===========================================================================================================================================
;
;		discord \\ Last updated: v2.9.2
;
; ===========================================================================================================================================
/* disc()
 This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \ahk\ImageSearch\disc[button].png
 @param button in the png name of a screenshot of the button you want the function to press
 */
disc(button)
;NOTE THESE WILL ONLY WORK IF YOU USE THE SAME DISPLAY SETTINGS AS ME (otherwise you'll need your own screenshots.. tbh you'll probably need your own anyway). YOU WILL LIKELY NEED YOUR OWN SCREENSHOTS AS I HAVE DISCORD ON A VERTICAL SCREEN SO ALL MY SCALING IS WEIRD
;dark theme
;chat font scaling: 20px
;space between message groups: 16px
;zoom level: 100
;saturation; 70%
;ensure this function only fires if discord is active ( #HotIf WinActive("ahk_exe Discord.exe") ) - VERY IMPORTANT
{
	KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
	coordw() ;important to leave this as window as otherwise the image search function will fail to find things
	MouseGetPos(&x, &y)
	WinGetPos(,, &width, &height, "A") ;gets the width and height to help this function work no matter how you have discord
	blockOn()
	click("right") ;this opens the right click context menu on the message you're hovering over
	sleep 50 ;sleep required so the right click context menu has time to open
	if ImageSearch(&xpos, &ypos, %&x% - "200", %&y% -"400",  %&x% + "200", %&y% + "400", "*2 " Discord %&button%) ;searches for the button you've requested
			MouseMove(%&xpos%, %&ypos%)
	else
		{
			sleep 500 ;this is a second attempt incase discord was too slow and didn't catch the button location the first time
			if ImageSearch(&xpos, &ypos, %&x% - "200", %&y% -"400",  %&x% + "200", %&y% + "400", "*2 " Discord %&button%)
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
			if ImageSearch(&xdir, &ydir, 0, %&height%/"2", %&width%, %&height%, "*2 " Discord "DiscDirReply.bmp") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. if you prefer to leave that on, remove from the above sleep 100, to the last else below. The coords here are to search the entire window (but only half the windows height) - (that's what the WinGetPos is for) for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish but it isn't really neccessary.
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
					toolFind("the @ ping button`nor you're in a DM", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
		}
	else
		{
			MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
			blockOff()
		}
}

/*
 This function will toggle the location of discord's window position
 */
discLocation()
{
	position0 := 4480, -123, 1081, 1537 ;we use position0 as a reference later to compare against another value. This is the same coordinates as disc0() down below, make sure you change THEM BOTH
	position1 := -1080, 75, 1080, 1537 ;we use position1 as a reference later to compare against another value. This is the same coordinates as disc1() down below, make sure you change THEM BOTH
	disc0() { ;define your first (defult) position here
		WinMove(4480, -123, 1081, 1537, "ahk_exe Discord.exe")
	}
	disc1() { ;define your second position here
		WinMove(-1080, 75, 1080, 1537, "ahk_exe Discord.exe")
	}
	try { ;this try is here as if you close a window, then immediately try to fire this function there is no "original" window
		original := WinGetID("A")
	} catch as e {
		toolCust("you tried to assign a closed`n window as the last active", "4000")
		SendInput("{Click}")
		return
	}
	static toggle := 0 ;this is what allows us to toggle discords position
	if not WinExist("ahk_exe Discord.exe")
		{
			run("C:\Users\" A_UserName "\AppData\Local\Discord\Update.exe --processStart Discord.exe") ;this will run discord
			WinWait("ahk_exe Discord.exe")
			sleep 1000
			WinActivate("ahk_exe Discord.exe")
			result := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord
			if result = position0 ;here we are comparing discords current position to one of the values we defined above
				{
					toggle := 0
					return
				}
			if result = position1 ;here we are comparing discords current position to one of the values we defined above
				{
					toggle := 1
					return
				}
			if !(result = position0 or result = position1) ;here we're saying if it isn't in EITHER position we defined above, move it into a position
				{
					toggle := 0
					disc0()
					return
				}
			return
		}
	WinActivate("ahk_exe Discord.exe")
	startLocation := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord
	if toggle < 1
		{
			toggle += 1
			disc0()
			newPos := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord AGAIN
			if newPos = startLocation ;so we can compare and ensure it has moved
				disc1()
			return
		}
	if toggle = 1
		{
			toggle -= 1
			disc1()
			newPos := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord AGAIN
			if newPos = startLocation ;so we can compare and ensure it has moved
				disc0()
			return
		}
	if toggle > 1 or toggle < 0 ;this is here just incase the value ever ends up bigger/smaller than it's supposed to
		{
			toggle := 0
			toolCust("stop spamming the function please`nthe functions value was to large/small", "1000")
			return
		}
	try { ;this is here once again to ensure ahk doesn't crash if the original window doesn't actual exist anymore
		WinActivate(original)
	} catch as e {
		toolCust("couldn't find original window", "2000")
		return
	}
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

; ===========================================================================================================================================
;
;		Premiere \\ Last updated: v2.9
;
; ===========================================================================================================================================
/* preset()
 This function will drag and drop any previously saved preset onto the clip you're hovering over. Your saved preset MUST be in a folder for this function to work.
 @param item in this function defines what it will type into the search box (the name of your preset within premiere)
 */
preset(item)
{
	coords()
	blockOn()
	MouseGetPos(&xpos, &ypos)
	SendInput(effectControls) ;highlights the effect controls panel
	SendInput(effectControls) ;premiere is dumb, focus things twice
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
	if A_ThisHotkey = textHotkey ;CHANGE THIS HOTKEY IN THE KEYBOARD SHORTCUTS.INI FILE - this if statement is code specific to text presets
		{
			sleep 100
			ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
			SendInput(newText) ;creates a new text layer, check the keyboard shortcuts ini file to change this
			sleep 100
			if ImageSearch(&x2, &y2, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "graphics.png") ;checks for the graphics panel that opens when you select a text layer
				{
					if ImageSearch(&xeye, &yeye, %&x2%, %&y2%, %&x2% + "200", %&y2% + "100", "*2 " Premiere "eye.png") ;searches for the eye icon for the original text
						{
							MouseMove(%&xeye%, %&yeye%)
							SendInput("{Click}")
							MouseGetPos(&eyeX, &eyeY)
							sleep 50
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
	effectbox() ;this is simply to cut needing to repeat this code below
	{
		SendInput(effectsWindow) ;adjust this in the ini file
		SendInput(findBox) ;adjust this in the ini file
		CaretGetPos(&findx)
		if %&findx% = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
			{
				Loop 40
					{
						sleep 30
						CaretGetPos(&findx)
						if %&findx% != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
							break
						if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
							{
								blockOff()
								toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
								return
							}
					}
			}
		SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
		SendInput("^a" "+{BackSpace}")
		SetTimer(delete, -250)
		delete() ;this function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job
		{
			if WinExist("Delete Item")
				{
					SendInput("{Esc}")
					sleep 100
					SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
					SendInput(findBox)
					CaretGetPos(&find2x)
					if %&find2x% = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
						{
							Loop 40
								{
									sleep 30
									CaretGetPos(&find2x)
									if %&find2x% != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
										break
									if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
										{
											blockOff()
											toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
											return
										}
								}
						}
					SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
					SendInput("^a" "+{BackSpace}")
					sleep 60
					if WinExist("Delete Item")
						{
							SendInput("{Esc}")
							sleep 50
							toolCust("it tried to delete your preset", "2000")
						}
				}
		}
	}
	effectbox()
	coordc() ;change caret coord mode to window
	CaretGetPos(&carx, &cary) ;get the position of the caret (blinking line where you type stuff)
	MouseMove %&carx%, %&cary% ;move to the caret (instead of defined pixel coords) to make it less prone to breaking
	SendInput %&item% ;create a preset of any effect, must be in a folder as well
	MouseMove 40, 68,, "R" ;move down to the saved preset (must be in an additional folder)
	SendInput("{Click Down}")
	if A_ThisHotkey = textHotkey ;set this hotkey within the Keyboard Shortcut Adjustments.ini file
		{
			MouseMove(%&eyeX%, %&eyeY% - "5")
			SendInput("{Click Up}")
			effectbox()
			SendInput(timelineWindow)
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
			return
		}
	MouseMove(%&xpos%, %&ypos%) ;in some scenarios if the mouse moves too fast a video editing software won't realise you're dragging. if this happens to you, add ', "2" ' to the end of this mouse move
	SendInput("{Click Up}")
	effectbox() ;this will delete whatever preset it had typed into the find box
	SendInput(timelineWindow) ;this will rehighlight the timeline after deleting the text from the find box
	blockOff()
}

/*
 This function is to move to the effects window and highlight the search box to allow manual typing
 */
fxSearch()
{
	coords()
	blockOn()
	SendInput(effectsWindow)
	SendInput(effectsWindow) ;adjust this in the ini file
	SendInput(findBox) ;adjust this in the ini file
	CaretGetPos(&findx)
	if %&findx% = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
		{
			Loop 40
				{
					sleep 30
					CaretGetPos(&findx)
					if %&findx% != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
						break
					if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
						{
							blockOff()
							toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
							return
						}
				}
		}
	SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
	SendInput("^a" "+{BackSpace}")
	SetTimer(delete, -250)
	delete() ;this function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job
	{
		if WinExist("Delete Item")
			{
				SendInput("{Esc}")
				sleep 100
				SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
				SendInput(findBox)
				CaretGetPos(&find2x)
				if %&find2x% = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
					{
						Loop 40
							{
								sleep 30
								CaretGetPos(&find2x)
								if %&find2x% != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
									break
								if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
									{
										blockOff()
										toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
										return
									}
							}
					}
				SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
				SendInput("^a" "+{BackSpace}")
				sleep 60
				if WinExist("Delete Item")
					{
						SendInput("{Esc}")
						sleep 50
						toolCust("it tried to delete your preset", "2000")
					}
			}
	}
	blockOff()
}

/* num()
 this function is to simply cut down repeated code on my numpad punch in scripts. it punches the video into my preset values for highlight videos
 @param xval is the pixel value you want this function to paste into the X coord text field in premiere
 @param yval is the pixel value you want this function to paste into the y coord text field in premiere
 @param scale is the scale value you want this function to paste into the scale text field in premiere
 */
num(xval, yval, scale)
{
	KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
	MouseGetPos(&xpos, &ypos)
	coords()
	blockOn()
	SendInput(effectControls)
	SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
	effClassNN := ControlGetClassNN(ControlGetFocus("A"))
	ControlGetPos(&efx, &efy, &width, &height, effClassNN)
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
		{
			SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
			sleep 50
			if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
				{
					toolCust("The wrong clips are selected", "1000")
					blockOff()
					return
				}
		}
	SendInput(timelineWindow) ;adjust this in the ini file
	SendInput(labelRed) ;changes the track colour so I know that the clip has been zoomed in
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "video.png") ;moves to the "video" section of the effects control window tab
		goto next
	else
		{
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
			toolFind("the video section", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	next:
	if ImageSearch(&x2, &y2, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "motion2.png") ;moves to the motion tab
		MouseMove(%&x2% + "10", %&y2% + "10")
	else if ImageSearch(&x3, &y3, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "\motion3.png") ;this is a second check incase "motion" is already highlighted
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

/* valuehold()
 a preset to warp to one of a videos values (scale , x/y, rotation, etc) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
 @param filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
 @param optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
 */
valuehold(filepath, optional)
{
	MouseGetPos(&xpos, &ypos)
	coords()
	blockOn()
	SendInput(effectControls)
	SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height value
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
		{ ;any imagesearches on the effect controls window includes a division variable (ECDivide) as I have my effect controls quite wide and there's no point in searching the entire width as it slows down the script
			SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
			sleep 50
			if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
				{
					toolCust("The wrong clips are selected", "1000")
					blockOff()
					return
				}
		}
	if A_ThisHotkey = levelsHotkey ;THIS IS FOR ADJUSTING THE "LEVEL" PROPERTY, CHANGE IN THE KEYBOARD SHORTCUTS.INI FILE
		{ ;don't add WheelDown's, they suck in hotkeys, idk why, they lag everything out and stop Click's from working
			if ImageSearch(&vidx, &vidy, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "video.png")
				{
					toolCust("you aren't scrolled down", "1000")
					blockOff()
					KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
					return
				}
			else
				goto next
		}
	next:
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% ".png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% "2.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for when you have the "toggle animation" keyframe button pressed
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% "3.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for if the property you want to adjust is "selected"
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% "4.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for if the property you want to adjust is "selected" and you're keyframing
	else
		{
			blockOff()
			toolFind("the image", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
			return
		}
	colour:
	if PixelSearch(&xcol, &ycol, %&x%, %&y% + "2", %&x% + "740", %&y% + "40", 0x288ccf, 3) ;searches for the blue text to the right of the value you want to adjust
		MouseMove(%&xcol% + %&optional%, %&ycol%)
	else if PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "720", %&y% + "40", 0x295C4D, 3) ;searches for a different shade of blue as a fallback
				MouseMove(%&xcol% + %&optional%, %&ycol%)
	else
		{
			blockOff()
			toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
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
			if ImageSearch(&x2, &y2, %&x%, %&y% - "10", %&x% + "1500", %&y% + "20", "*2 " Premiere "reset.png") ;searches for the reset button to the right of the value you want to adjust
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

/* keyreset()
 this function is to turn off keyframing for a given property within premiere pro
 @param filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
 */
keyreset(filepath) ;I think this function is broken atm, I need to do something about it... soon
{
	MouseGetPos(&xpos, &ypos)
	coords()
	blockOn()
	SendInput(effectControls)
	SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height value
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
		{
			SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
			sleep 50
			if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
				{
					toolCust("The wrong clips are selected", "1000")
					blockOff()
					return
				}
		}
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% "2.png")
		goto click
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% "4.png")
		goto click
	else
		{
			toolCust("you're already keyframing", "1000")
			blockOff()
			;KeyWait(A_PriorHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
			return
		}
	click:
	MouseMove(%&x% + "7", %&y% + "4")
	click
	blockOff()
	MouseMove(%&xpos%, %&ypos%)
}

/* keyframe()
 this function is to either turn on keyframing, or create a new keyframe at the cursor for a given property within premiere pro
 @param filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
 */
keyframe(filepath)
{
	MouseGetPos(&xpos, &ypos)
	coords()
	blockOn()
	SendInput(effectControls)
	SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height value
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
		{
			SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
			sleep 50
			if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
				{
					toolCust("The wrong clips are selected", "1000")
					blockOff()
					return
				}
		}
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% "2.png")
		goto next
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% "4.png")
		goto next
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% ".png")
		{
			MouseMove(%&x% + "5", %&y% + "5")
			Click()
			goto end
		}
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&filepath% "3.png")
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
	if ImageSearch(&keyx, &keyy, %&x%, %&y%, %&x% + "500", %&y% + "20", "*2 " Premiere "keyframeButton.png")
		MouseMove(%&keyx% + "3", %&keyy%)
	else if ImageSearch(&keyx, &keyy, %&x%, %&y%, %&x% + "500", %&y% + "20", "*2 " Premiere "keyframeButton2.png")
		MouseMove(%&keyx% + "3", %&keyy%)
	Click()
	end:
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	MouseMove(%&xpos%, %&ypos%)
	blockOff()
}

/* audioDrag()
 this function pulls an audio file out of a separate bin from the project window and back to the cursor (premiere pro)
 @param sfxName is the name of whatever sound you want the function to pull onto the timeline
 */
audioDrag(sfxName)
{
	;I wanted to use a method similar to other premiere functions above, that grabs the classNN value of the panel to do all imagesearches that way instead of needing to define coords, but because I'm using a separate bin which is essentially just a second project window, things get messy, premiere gets slow, and the performance of this function dropped drastically so for this one we're going to stick with coords defined in KSA.ini/ahk
	coords()
	if ImageSearch(&sfxxx, &sfxyy, 3021, 710, 3589, 1261, "*2 " Premiere "binsfx.png") ;checks to make sure you have the sfx bin open as a separate project window
		{
			blockOn()
			coords()
			MouseGetPos(&xpos, &ypos)
			if ImageSearch(&listx, &listy, 3081, 745, 3591, 1265, "*2 " Premiere "list view.png") ;checks to make sure you're in the list view
				{
					MouseMove(%&listx%, %&listy%)
					SendInput("{Click}")
					sleep 100
				}
			SendInput(projectsWindow) ;highlights the project window ~ check the keyboard shortcut ini file to adjust hotkeys
			SendInput(projectsWindow) ;highlights the sfx bin that I have ~ check the keyboard shortcut ini file to adjust hotkeys
			;KeyWait(A_PriorKey) ;I have this set to remapped mouse buttons which instantly "fire" when pressed so can cause errors
			SendInput(findBox)
			CaretGetPos(&findx)
			if %&findx% = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
				{
					Loop 40
						{
							sleep 30
							CaretGetPos(&findx)
							if %&findx% != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
								break
							if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
								{
									blockOff()
									toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
									return
								}
						}
				}
			SendInput("^a" "+{BackSpace}")
			SendInput(%&sfxName%)
			sleep 250 ;the project search is pretty slow so you might need to adjust this
			coordw()
			if ImageSearch(&vlx, &vly, sfxX1, sfxY1, sfxX2, sfxY2, "*2 " Premiere "audio.png") ;searches for the audio image next to an audio file
				{
					MouseMove(%&vlx%, %&vly%)
					SendInput("{Click Down}")
				}
			else if ImageSearch(&vlx, &vly, sfxX1, sfxY1, sfxX2, sfxY2, "*2 " Premiere "audio2.png") ;searches for the audio image next to an audio file
				{
					MouseMove(%&vlx%, %&vly%)
					SendInput("{Click Down}")
				}
			else
				{
					blockOff()
					toolFind("vlc image", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
					coords()
					MouseMove(%&xpos%, %&ypos%)
					return
				}
			coords()
			MouseMove(%&xpos%, %&ypos%)
			SendInput("{Click Up}")
			SendInput(projectsWindow)
			SendInput(projectsWindow)
			SendInput(findBox)
			CaretGetPos(&find2x)
			if %&findx% = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
				{
					Loop 40
						{
							sleep 30
							CaretGetPos(&find2x)
							if %&find2x% != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
								break
							if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
								{
									blockOff()
									toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
									return
								}
						}
				}
			SendInput("^a" "+{BackSpace}" "{Enter}")
			SendInput(timelineWindow)
			blockOff()
		}
	else
		{
			toolCust("you haven't opened the bin", "2000")
		}
 }

/*
audioDrag(folder, sfxName) (old | uses media browser instead of a project bin)
{
	SendInput(mediaBrowser) ;highlights the media browser ~ check the keyboard shortcut ini file to adjust hotkeys
	;KeyWait(A_PriorKey) ;I have this set to remapped mouse buttons which instantly "fire" when pressed so can cause errors
	blockOn()
	coords()
	MouseGetPos(&xpos, &ypos)
	SendInput(mediaBrowser) ;highlights the media browser ~ check the keyboard shortcut ini file to adjust hotkeys
	sleep 10
	if ImageSearch(&sfx, &sfy, mbX1, mbY1, mbX2, mbY2, "*2 " Premiere %&folder% ".png") ;searches for my sfx folder in the media browser to see if it's already selected or not
		{
			MouseMove(%&sfx%, %&sfy%) ;if it isn't selected, this will move to it then click it
			SendInput("{Click}")
			MouseMove(%&xpos%, %&ypos%)
			sleep 100
			goto next
		}
	else if ImageSearch(&sfx, &sfy, mbX1, mbY1, mbX2, mbY2, "*2 " Premiere %&folder% "2.png") ;if it is selected, this will see it, then move on
		goto next
	else ;if everything fails, this else will trigger
		{
			blockOff()
			toolFind("sfx folder", "1000")
			MouseMove(%&xpos%, %&ypos%)
			return
		}
	next:
	SendInput(findBox) ;adjust this in the keyboard shortcuts ini file
	coordc()
	SendInput("^a" "+{BackSpace}") ;deletes anything that might be in the search box
	SendInput(%&sfxName%)
	sleep 150
	if ImageSearch(&vlx, &vly, mbX1, mbY1, mbX2, mbY2, "*2 " Premiere "vlc.png") ;searches for the vlc icon to grab the track
		{
			MouseMove(%&vlx%, %&vly%)
			SendInput("{Click Down}")
		}
	else
		{
			blockOff()
			toolFind("vlc image", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
			MouseMove(%&xpos%, %&ypos%)
			return
		}
	MouseMove(%&xpos%, %&ypos%)
	SendInput("{Click Up}")
	SendInput(mediaBrowser)
	SendInput(findBox)
	SendInput("^a" "+{BackSpace}" "{Enter}")
	sleep 50
	SendInput(timelineWindow)
	blockOff()
}
*/

/* wheelEditPoint()
 move back and forth between edit points from anywhere in premiere
 @param direction is the hotkey within premiere for the direction you want it to go in relation to "edit points"
 */
 wheelEditPoint(direction)
 {
	 ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	 SendInput(%&direction%) ;Set these shortcuts in the keyboards shortcut ini file
 }

/* movepreview()
 This function is to adjust the framing of a video within the preview window in premiere pro. Let go of this hotkey to confirm, simply tap this hotkey to reset values
 */
movepreview()
{
	coords()
	blockOn()
	MouseGetPos(&xpos, &ypos)
	SendInput(effectControls)
	SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height value
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
		{
			SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
			sleep 50
			if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
				{
					toolCust("The wrong clips are selected", "1000")
					blockOff()
					return
				}
		}
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "motion.png") ;moves to the motion tab
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
			MouseMove(moveX, moveY) ;move to the preview window
			SendInput("{Click Down}")
			blockOff()
			KeyWait A_ThisHotkey
			SendInput("{Click Up}")
			;MouseMove(%&xpos%, %&ypos%) ; // moving the mouse position back to origin after doing this is incredibly disorienting
		}
	else
		{
			if ImageSearch(&xcol, &ycol, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "reset.png") ;these coords are set higher than they should but for whatever reason it only works if I do that????????
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

/* reset()
 This script moves the cursor to the reset button to reset the "motion" effects
 */
reset()
{
	KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
	coords()
	blockOn()
	SendInput(effectControls)
	SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height value
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
		{
			SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
			sleep 50
			if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
				{
					toolCust("The wrong clips are selected", "1000")
					blockOff()
					return
				}
		}
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&x2, &y2, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "motion2.png") ;checks if the "motion" value is in view
		goto inputs
	else if ImageSearch(&x2, &y2, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "motion3.png") ;checks if the "motion" value is in view
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
		if ImageSearch(&xcol, &ycol, %&x2%, %&y2% - "20", %&x2% + "700", %&y2% + "20", "*2 " Premiere "reset.png") ;this will look for the reset button directly next to the "motion" value
			MouseMove(%&xcol%, %&ycol%)
		;SendInput, {WheelUp 10} ;not necessary as we use imagesearch to check for the motion value
		click
	MouseMove(%&xpos%, %&ypos%)
	blockOff()
}

/* hotkeyDeactivate()
 this allowed the old version of manInput to work
 */
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

/* hotkeyReactivate()
 this allowed the old version of manInput to work
 */
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

/* manInput()
 This function will warp to and press any value in premiere to manually input a number
 @param property is the value you want to adjust
 @param optional is the optional pixels to move the mouse to grab the Y axis value instead of the X axis
 @param keywaitkey is one of the activation hotkeys
 @param keyend is whatever key you want the function to wait for before finishing
 */
manInput(property, optional, keywaitkey, keyend)
{
	MouseGetPos(&xpos, &ypos)
	coords()
	blockOn()
	SendInput(effectControls)
	SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height value
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;focuses the timeline
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
		{
			SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
			sleep 50
			if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
				{
					toolCust("The wrong clips are selected", "1000")
					blockOff()
					return
				}
		}
	if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&property% ".png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
		goto colour
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&property% "2.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for when you have the "toggle animation" keyframe button pressed
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&property% "3.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
		goto colour ;this is for if the property you want to adjust is "selected"
	else if ImageSearch(&x, &y, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere %&property% "4.png") ;finds the value you want to adjust, then finds the value adjustment to the right of it
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
	;use to be keywaits here.. I think it was for the below deactivate... maybe..
	keywait(%&keywaitkey%)
	;hotkeyDeactivate()
	SendInput("{Click}")
	ToolTip("manInput() is waiting for the " "'" %&keyend% "'" "`nkey to be pressed")
	KeyWait(%&keyend%, "D") ;waits until the final hotkey is pressed before continuing
	ToolTip("")
	SendInput("{Enter}")
	MouseMove(%&xpos%, %&ypos%)
	;hotkeyReactivate()
	Click("middle")
	blockOff()
}

/* gain()
 This function is to increase/decrease gain within premiere pro. This function will check to ensure the timeline is in focus and a clip is selected
 @param amount is the value you want the gain to adjust (eg. -2, 6, etc)
 */
gain(amount)
{
	KeyWait(A_ThisHotkey)
	Critical
	coords()
	try {
			loop {
			SendInput(effectControls)
			SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
			sleep 30
			effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
			if effClassNN = "Edit1" ;checks for the gain window
				{
					SendInput(%&amount% "{Enter}")
					return
				}
			;toolCust(A_Index, "1000") ;debugging
		} until effClassNN != "DroverLord - Window Class3" || effClassNN != "DroverLord - Window Class1"
		} catch as e {
			toolCust("You're spamming too fast", "1000")
			Exit
		}
	try {
		ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height value
	} catch as e {
		toolCust("You're spamming too fast", "1000")
		Exit
	}
	SendInput(timelineWindow)
	if ImageSearch(&x3, &y3, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
		{
			SendInput(timelineWindow selectAtPlayhead) ;~ check the keyboard shortcut ini file to adjust hotkeys
			goto inputs
		}
	else
		{
			classNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
			if classNN = "DroverLord - Window Class3"
				goto inputs
			else
				{
					toolCust("gain macro couldn't figure`nout what to do", "1000")
					return
				}
		}
	inputs:
	SendInput("g" "+{Tab}{UP 3}{DOWN}{TAB}" %&amount% "{ENTER}")
	Critical("off")
}

/* gainSecondary()
 This function opens up the gain menu within premiere pro so I can input it with my secondary keyboard. This function will also check to ensure the timeline is in focus and a clip is selected. I don't really use this anymore
 @param key1 is the hotkey you use to activate this function
 @param key2 is the other hotkey you use to activate this function (if you only use 1 button to activate it, remove one of the keywaits and this variable)
 @param keyend is whatever key you want the function to wait for before finishing
 */
gainSecondary(key1, key2, keyend)
{
	;KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
	SendInput(effectControls)
	SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height value
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
	if ImageSearch(&x3, &y3, %&efx%, %&efy%, %&efx% + (%&width%/ECDivide), %&efy% + %&height%, "*2 " Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
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
;		After Effects \\ Last updated: v2.9
;
; ===========================================================================================================================================
/* aevaluehold()
 A function to warp to one of a videos values within After Effects (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
 @param button is the hotkey within after effects that's used to open up the property you want to adjust
 @param property is the filename of just the property itself ie. "scale" not "scale.png" or "scale2"
 @param optional is for when you need the mouse to move extra coords over to avoid the first "blue" text for some properties
 */
aevaluehold(button, property, optional) ;this function is incredibly touchy and I need to revisit it one day to improve it so that it's actually usable, but for now I don't really use it, after effects is just too jank
{
	coordw()
	MouseGetPos(&x, &y)
	if(%&x% > 550 and %&x% < 2542) and (%&y% > 1010) ;this ensures that this function only tries to activate if it's within the timeline of after effects
		{
			blockOn()
			MouseGetPos(&X, &Y)
			if ImageSearch(&selectX, &selectY, 8, 8, 299, 100, "*2 " AE "selection.png")
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
			if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " AE %&property% ".png")
				goto colour
			else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " AE %&property% "2.png")
				goto colour
			else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " AE %&property% "Key.png")
				goto colour
			else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " AE %&property% "Key2.png")
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

/* aepreset()
 This function allows you to drag and drop effects onto a clip within After Effects at the press of a button
 @param preset is the name of your preset that you wish to drag onto your clip
 */
aePreset(preset)
{
	blockOn()
	coords()
	MouseGetPos(&x, &y)
	colour := PixelGetColor(%&x%, %&y%) ;assigned the pixel colour at the mouse coords to the variable "colour"
	if colour != 0x9E9E9E ;0x9E9E9E is the colour of a selected track - != means "not equal to"
		{
			toolCust("you haven't selected a clip`nor aren't hovering the right spot", "1000")
			blockOff()
			Exit
		}
	SendInput(audioAE effectsAE) ;we first bring focus to another window, then to the effects panel since after effects is all about "toggling" instead of highlighting. These values can be set within KSA.ini
	sleep 100
	effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
	ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
	if ImageSearch(&x2, &y2, %&efx%, %&efy%, %&efx% + %&width%, %&efy% + %&height%, "*2 " AE "findbox.png")
		goto move
	else if ImageSearch(&x2, &y2, %&efx%, %&efy%, %&efx% + %&width%, %&efy% + %&height%, "*2 " AE "findbox2.png")
		goto move
	else
		{
			blockOff()
			toolCust("couldn't find the magnifying glass", "1000")
			return
		}
	move:
	MouseMove(%&x2%, %&y2%)
	SendInput("{Click}")
	SendInput("^a" "+{BackSpace}")
	CaretGetPos(&find)
	if %&find% = "" ;this loop is to make sure after effects finds the text field
		{
			loop 10 {
				sleep 30
				CaretGetPos(&find2x)
				if %&find2x% != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
					break
				toolCust("The function attempted " A_Index " times`n for a total of " A_Index * 30 "ms", "2000")
				if A_Index > 10
					{
						blockOff()
						toolCust("Couldn't determine the caret", "1000")
						return
					}
			}
		}
	SendInput(%&preset%)
	sleep 100
	MouseMove(59, 43, 2, "R") ;moves the mouse relative to the start position to ensure it always grabs the preset you want at mouse speed 2, this helps as after effects can be quite slow
	SendInput("{Click Down}")
	MouseMove(%&x%, %&y%, "2") ;drags the preset back to the starting position (your layer) at mouse speed 2, it's important to slow down the mouse here or after effects won't register you're dragging the preset
	sleep 100
	SendInput("{Click Up}")
	MouseMove(%&x2%, %&y2%)
	SendInput("{Click}")
	SendInput("^a" "+{BackSpace}" "{Enter}") ;deletes whatever was typed into the effects panel
	MouseMove(%&x%, %&y%)
	blockOff()
}

; ===========================================================================================================================================
;
;		Photoshop \\ Last updated: v2.9
;
; ===========================================================================================================================================
/* psProp()
 A function to warp to one of a photos values within Photoshop (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease.
 @param image is the png name of the image that imagesearch will use
 */
psProp(image)
{
	coords()
	MouseGetPos(&xpos, &ypos)
	coordw()
	blockOn()
	if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " Photoshop "text2.png") ;checks to see if you're typing
		SendInput("^{Enter}")
	if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " Photoshop "text.png") ;checks to see if you're in the text tool
		SendInput("v") ;if you are, it'll press v to go to the selection tool
	if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " Photoshop "InTransform.png") ;checks to see if you're already in the free transform window
		{
			if ImageSearch(&x, &y, 60, 30, 744, 64, "*5 " Photoshop %&image%) ;if you are, it'll then search for your button of choice and move to it
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
			if ImageSearch(&x, &y, 111, 30, 744, 64, "*5 " Photoshop %&image%) ;moves to the position variable
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

/* psSave()
 This function is to speed through the twitch emote saving process within photoshop. Doing this manually is incredibly tedious and annoying, so why do it manually?
 */
psSave()
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
		if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " Photoshop "png.png")
			{
				MouseMove(0, 0)
				SendInput("{Enter 2}")
			}

		else
			{
				if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " Photoshop "png2.png")
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

/* psType()
 When you try and save a copy of something in photoshop, it defaults to psd, this is a function to instantly pick the actual filetype you want
 @param filetype is the name of the image you save to pick which filetype you want this function to click on
 */
psType(filetype)
{
	MouseGetPos(&x, &y)
	Send("{TAB}{RIGHT}") ;make sure you don't click anywhere before using this function OR put the caret back in the filename box
	coordw()
	sleep 200 ;photoshop is slow as hell, if you notice it missing the png drop down you may need to increase this delay
	if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " Photoshop %&filetype% ".png")
		{
			SendInput("{Enter}")
			SendInput("+{Tab}")
		}

	else if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " Photoshop %&filetype% "2.png")
		{
			MouseMove(%&xpng%, %&ypng%)
			SendInput("{Click}")
			SendInput("+{Tab}")
		}
	else
		{
			blockOff()
			toolFind("png drop down", "1000")
			return
		}
	MouseMove(%&x%, %&y%)
}

; ===========================================================================================================================================
;
;		Resolve \\ Last updated: v2.9
;
; ===========================================================================================================================================
/* Rscale()
 A function to set the scale of a video within resolve
 @param value is the number you want to type into the text field (100% in reslove requires a 1 here for example)
 @param property is the property you want this function to type a value into (eg. zoom)
 @param plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
 */
Rscale(value, property, plus)
{
	KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
	coordw()
	blockOn()
	SendInput(resolveSelectPlayhead)
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector.png")
		goto video
	else if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
		{
			MouseMove(%&xi%, %&yi%)
			click ;this opens the inspector tab
			goto video
		}
	video:
	if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "video.png") ;if you're already in the video tab, it'll find this image then move on
		goto rest
	else if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png") ;if you aren't already in the video tab, this line will search for it
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
	if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve %&property% ".png") ;searches for the property of choice
		MouseMove(%&xz% + %&plus%, %&yz% + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
	else if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve %&property% "2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
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

/* rfElse()
 A function that gets nested in the resolve scale, x/y and rotation scripts
 @param data is what the script is typing in the text box to reset its value
 */
rfElse(data)
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

/* REffect()
 A function to apply any effect to the clip you're hovering over within Resolve.
 @param folder is the name of your screenshots of the drop down sidebar option (in the effects window) you WANT to be active - both activated and deactivated
 @param effect is the name of the effect you want this function to type into the search box
 */
REffect(folder, effect)
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
	if ImageSearch(&xe, &ye, effectx1, effecty1, effectx2, effecty2, "*1 " Resolve "effects.png") ;checks to see if the effects button is deactivated
		{
			MouseMove(%&xe%, %&ye%)
			SendInput("{Click}")
			goto closeORopen
		}
	else if ImageSearch(&xe, &ye, effectx1, effecty1, effectx2, effecty2, "*1 " Resolve "effects2.png") ;checks to see if the effects button is activated
		goto closeORopen
	else ;if everything fails, this else will trigger
		{
			blockOff()
			toolFind("the effects button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
closeORopen:
	if ImageSearch(&xopen, &yopen, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve "open.png") ;checks to see if the effects window sidebar is open
		goto EffectFolder
	else if ImageSearch(&xclosed, &yclosed, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve "closed.png") ;checks to see if the effects window sidebar is closed
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
	if ImageSearch(&xfx, &yfx, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve %&folder% ".png") ;checks to see if the drop down option you want is activated
		goto SearchButton
	else if ImageSearch(&xfx, &yfx, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve %&folder% "2.png") ;checks to see if the drop down option you want is deactivated
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
	if ImageSearch(&xs, &ys, effectx1, effecty1 + "300", effectx2, effecty2, "*2 " Resolve "search2.png") ;checks to see if the search icon is deactivated
		{
			MouseMove(%&xs%, %&ys%)
			SendInput("{Click}")
			goto final
		}
	else if ImageSearch(&xs, &ys, 8, 8 + "300", effectx2, effecty2, "*2 " Resolve "search3.png") ;checks to see if the search icon is activated
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
	sleep 50
	SendInput(%&effect%)
	MouseMove(0, 130,, "R")
	SendInput("{Click Down}")
	MouseMove(%&xpos%, %&ypos%, 2) ;moves the mouse at a slower, more normal speed because resolve doesn't like it if the mouse warps instantly back to the clip
	SendInput("{Click Up}")
	blockOff()
	return
}

/* rvalhold()
 A function to provide similar functionality within Resolve to my valuehold() function for premiere
 @param property refers to both of the screenshots (either active or not) for the property you wish to adjust
 @param plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
 @param rfelseval is the value you wish to pass to rfelse()
 */
rvalhold(property, plus, rfelseval)
{
	coordw()
	blockOn()
	SendInput(resolveSelectPlayhead)
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector.png")
		goto video
	else if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
		{
			MouseMove(%&xi%, %&yi%)
			click ;this opens the inspector tab
			goto video
		}
	video:
	if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "video.png") ;if you're already in the video tab, it'll find this image then move on
		goto rest
	else if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png") ;if you aren't already in the video tab, this line will search for it
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
	if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve %&property% ".png") ;searches for the property of choice
		MouseMove(%&xz% + %&plus%, %&yz% + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
	else if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve %&property% "2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
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

/* rflip()
 A function to search for and press the horizontal/vertical flip button within Resolve
 @param button is the png name of a screenshot of the button you wish to click (either activated or deactivated)
 */
rflip(button)
{
	coordw()
	blockOn()
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png") ;makes sure the video tab is selected
		{
			MouseMove(%&xn%, %&yn%)
			click
		}
	if ImageSearch(&xh, &yh, propx1, propy1, propx2, propy2, "*5 " Resolve %&button% ".png") ;searches for the button when it isn't activated already
		{
			MouseMove(%&xh%, %&yh%)
			click
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
			return
		}
	else if ImageSearch(&xho, &yho, propx1, propy1, propx2, propy2, "*5 " Resolve %&button% "2.png") ;searches for the button when it is activated already
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

/* rgain()
 A function that allows you to adjust the gain of the selected clip within Resolve similar to my gain macros in premiere. You can't pull this off quite as fast as you can in premiere, but it's still pretty useful
 @param value is how much you want the gain to be adjusted by
 */
rgain(value)
{
	coordw()
	blockOn()
	SendInput(resolveSelectPlayhead)
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector.png")
		goto audio
	else if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
		{
			MouseMove(%&xi%, %&yi%)
			click ;this opens the inspector tab
			goto audio
		}
	audio:
	if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "audio2.png") ;if you're already in the audio tab, it'll find this image then move on
		goto rest
	else if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "audio.png") ;if you aren't already in the audio tab, this line will search for it
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
	if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve "volume.png") ;searches for the volume property
		MouseMove(%&xz% + "215", %&yz% + "5") ;moves the mouse to the value next to volume. This function assumes x/y are linked
	else if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve "volume2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
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
;		VSCode \\ Last updated: v2.9.6
;
; ===========================================================================================================================================
/* vscode()
 A function to quickly naviate between my scripts. For this script to work [explorer.autoReveal] must be set to false in VSCode's settings (File->Preferences->Settings, search for "explorer" and set "explorer.autoReveal")
 @param script is the amount of pixels down the mouse must move from the collapse button to open the script I want.
*/
vscode(script)
{
	KeyWait(A_PriorKey)
	coordw()
	blockOn()
	MouseGetPos(&x, &y)
	if ImageSearch(&xex, &yex, 0, 0, 460, 1390, "*2 " VSCodeImage "explorer.png") ;this imagesearch is checking to ensure you're in the explorer tab
		{
			MouseMove(%&xex%, %&yex%)
			SendInput("{Click}")
			MouseMove(%&x%, %&y%)
			sleep 50
		}
	SendInput(focusWork) ;vscode hides the buttons now all of a sudden.. thanks vscode
	sleep 50
	if ImageSearch(&xex, &yex, 0, 0, 460, 1390, "*2 " VSCodeImage "collapse.png") ;this imagesearch finds the collapse folders button, presses it twice, then moves across and presses the refresh button
		{
			MouseMove(%&xex%, %&yex%)
			SendInput("{Click 2}")
			MouseMove(-271, 40,, "R")
			SendInput("{Click}")
		}
	else
		{
			toolFind("the collapse folders button", "1000")
			blockOff()
			return
		}
	MouseMove(0, %&script%,, "R")
	SendInput("{Click}")
	MouseMove(%&x%, %&y%)
	SendInput(focusCode)
	blockOff()
}
; ===========================================================================================================================================
;
;		QMK Stuff \\ Last updated: v2.5.~
;
; ===========================================================================================================================================
/* numpad000()
 A function to suppress the multiple keystrokes the "000" key sends on my secondary numpad and will in the future be used to do... something
 */
numpad000()
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
;		switch/launch scripts \\ Last updated: v2.9.4
;
; ===========================================================================================================================================
/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToExplorer()
{
	if not WinExist("ahk_class CabinetWClass")
		{
			Run "explorer.exe"
			WinWait("ahk_class CabinetWClass")
			WinActivate "ahk_class CabinetWClass" ;in win11 running explorer won't always activate it, so it'll open in the backround
		}
	GroupAdd "explorers", "ahk_class CabinetWClass"
	if WinActive("ahk_exe explorer.exe")
		GroupActivate "explorers", "r"
	else
		if WinExist("ahk_class CabinetWClass")
			WinActivate "ahk_class CabinetWClass" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This function when called will close all windows of the desired program EXCEPT the active one. Helpful when you accidentally have way too many windows explorer windows open.
 @param program is the ahk_class or ahk_exe of the program you want this function to close
 */
closeOtherWindow(program)
{
	value := WinGetList(%&program%) ;gets a list of all open windows
	toolCust(value.length - 1 " other window(s) closed", "1000") ;tooltip to display how many explorer windows are being closed
	for this_value in value
		{
			if A_Index > 1 ;closes all windows that AREN'T the last active window
				WinClose this_value
		}
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToPremiere()
{
	if not WinExist("ahk_class Premiere Pro")
		{
		Run A_ScriptDir "\shortcuts\Adobe Premiere Pro.exe.lnk"
		}
	else
		if WinExist("ahk_class Premiere Pro")
			WinActivate "ahk_class Premiere Pro"
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToAE()
{
	if not WinExist("ahk_exe AfterFX.exe")
		{
		Run A_ScriptDir "\shortcuts\AfterFX.exe.lnk"
		WinWait("ahk_exe AfterFX.exe")
		WinActivate("ahk_exe AfterFX.exe")
		}
	else
		if WinExist("ahk_exe AfterFX.exe")
			WinActivate "ahk_exe AfterFX.exe"
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToPhoto()
{
	if not WinExist("ahk_exe Photoshop.exe")
		{
		Run A_ScriptDir "\shortcuts\Photoshop.exe.lnk"
		WinWait("ahk_exe Photoshop.exe")
		WinActivate("ahk_exe Photoshop.exe")
		}
	else
		if WinExist("ahk_exe Photoshop.exe")
			WinActivate "ahk_exe Photoshop.exe"
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToFirefox()
{
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
		}
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToOtherFirefoxWindow() ;I use this as a nested function below in firefoxTap(), you can just use this separately
{
	if WinExist("ahk_exe firefox.exe")
		{
			if WinActive("ahk_class MozillaWindowClass")
				{
					GroupAdd "firefoxes", "ahk_class MozillaWindowClass"
					GroupActivate "firefoxes", "r"
				}
			else
				WinActivate "ahk_class MozillaWindowClass"
		}
	else
		Run "firefox.exe"
}

/*
 This function will do different things depending on how many times you press the activation hotkey.
 1 press = switchToFirefox()
 2 press = switchToOtherFirefoxWindow()
 */
firefoxTap()
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
	SetTimer After400, -180 ; Wait for more presses within a 300 millisecond window.

	After400()  ; This is a nested function.
	{
		if winc_presses = 1 ; The key was pressed once.
		{
			switchToFirefox()
		}
		else if winc_presses = 2 ; The key was pressed twice.
		{
			switchToOtherFirefoxWindow()
		}
		else if winc_presses > 2
		{
			;
		}
		; Regardless of which action above was triggered, reset the count to
		; prepare for the next series of presses:
		winc_presses := 0
	}
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToVSC()
{
	if not WinExist("ahk_exe Code.exe")
		Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
		GroupAdd "Code", "ahk_class Chrome_WidgetWin_1"
	if WinActive("ahk_exe Code.exe")
		GroupActivate "Code", "r"
	else
		if WinExist("ahk_exe Code.exe")
			WinActivate "ahk_exe Code.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToGithub()
{
	if not WinExist("ahk_exe GitHubDesktop.exe")
		Run "C:\Users\" A_UserName "\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
		GroupAdd "git", "ahk_class Chrome_WidgetWin_1"
	if WinActive("ahk_exe GitHubDesktop.exe")
		GroupActivate "git", "r"
	else
		if WinExist("ahk_exe GitHubDesktop.exe")
			WinActivate "ahk_exe GitHubDesktop.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToStreamdeck()
{
	if not WinExist("ahk_exe StreamDeck.exe")
		Run A_ProgramFiles "\Elgato\StreamDeck\StreamDeck.exe"
		GroupAdd "stream", "ahk_class Qt5152QWindowIcon"
	if WinActive("ahk_exe StreamDeck.exe")
		GroupActivate "stream", "r"
	else
		if WinExist("ahk_exe Streamdeck.exe")
			WinActivate "ahk_exe StreamDeck.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToExcel()
{
	if not WinExist("ahk_exe EXCEL.EXE")
		{
			Run A_ProgramFiles "\Microsoft Office\root\Office16\EXCEL.EXE"
			WinWait("ahk_exe EXCEL.EXE")
			WinActivate("ahk_exe EXCEL.EXE")
		}
	GroupAdd "xlmain", "ahk_class XLMAIN"
	if WinActive("ahk_exe EXCEL.EXE")
		GroupActivate "xlmain", "r"
	else
		if WinExist("ahk_exe EXCEL.EXE")
			WinActivate "ahk_exe EXCEL.EXE"
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
 switchToWord()
 {
	 if not WinExist("ahk_exe WINWORD.EXE")
		 {
			 Run A_ProgramFiles "\Microsoft Office\root\Office16\WINWORD.EXE"
			 WinWait("ahk_exe WINWORD.EXE")
			 WinActivate("ahk_exe WINWORD.EXE")
		 }
	 GroupAdd "wordgroup", "ahk_class wordgroup"
	 if WinActive("ahk_exe WINWORD.EXE")
		 GroupActivate "wordgroup", "r"
	 else
		 if WinExist("ahk_exe WINWORD.EXE")
			 WinActivate "ahk_exe WINWORD.EXE"
 }

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
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

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToYourPhone()
{
	if not WinExist("ahk_pid 13884") ;this process id may need to be changed for you. I also have no idea if it will stay the same
		Run A_ProgramFiles "\ahk\ahk\shortcuts\Your Phone.lnk"
	GroupAdd "yourphone", "ahk_class ApplicationFrameWindow"
	if WinActive("Your Phone")
		GroupActivate "yourphone", "r"
	else
		if WinExist("Your Phone")
			WinActivate "Your Phone" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToEdge()
{
	if not WinExist("ahk_exe msedge.exe")
		{
			Run "msedge.exe"
			WinWait("ahk_exe msedge.exe")
			WinActivate("ahk_exe msedge.exe")
		}
	GroupAdd "git", "ahk_exe msedge.exe"
	if WinActive("ahk_exe msedge.exe")
		GroupActivate "git", "r"
	else
		if WinExist("ahk_exe msedge.exe")
			WinActivate "ahk_exe msedge.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToMusic()
{
	GroupAdd("MusicPlayers", "ahk_exe wmplayer.exe")
	GroupAdd("MusicPlayers", "ahk_exe vlc.exe")
	GroupAdd("MusicPlayers", "ahk_exe AIMP.exe") 
	GroupAdd("MusicPlayers", "ahk_exe foobar2000.exe")
	if not WinExist("ahk_group MusicPlayers")
		{
			if WinExist("Which MP to open?")
				return
			;if there is no music player open, a custom GUI window will open asking which program you'd like to open
			MyGui := Gui("AlwaysOnTop", "Which MP to open?") ;creates our GUI window
			MyGui.SetFont("S10") ;Sets the size of the font
			MyGui.SetFont("W600") ;Sets the weight of the font (thickness)
			MyGui.Opt("+Resize +MinSize290x10") ;Sets a minimum size for the window
			;now we define the elements of the GUI window
			;defining AIMP
			aimplogo := MyGui.Add("Picture", "w25 h-1 Y9", A_WorkingDir "\Support Files\images\aimp.png")
			AIMPGUI := MyGui.Add("Button", "X40 Y7", "AIMP")
			AIMPGUI.OnEvent("Click", AIMP)
			;defining Foobar
			foobarlogo := MyGui.Add("Picture", "w20 h-1 X14 Y40", A_WorkingDir "\Support Files\images\foobar.png")
			FoobarGUI := MyGui.Add("Button", "X40 Y40", "Foobar")
			FoobarGUI.OnEvent("Click", Foobar)
			;defining Windows Media Player
			wmplogo := MyGui.Add("Picture", "w25 h-1 X140 Y9", A_WorkingDir "\Support Files\images\wmp.png")
			WMPGUI := MyGui.Add("Button", "X170 Y7", "WMP")
			WMPGUI.OnEvent("Click", WMP)
			;defining VLC
			vlclogo := MyGui.Add("Picture", "w28 h-1 X138 Y42", A_WorkingDir "\Support Files\images\vlc.png")
			VLCGUI := MyGui.Add("Button", "X170 Y40", "VLC")
			VLCGUI.OnEvent("Click", VLC)
			;defining music folder
			folderlogo := MyGui.Add("Picture", "w25 h-1  X14 Y86", A_WorkingDir "\Support Files\images\explorer.png")
			FOLDERGUI := MyGui.Add("Button", "X42 Y85", "MUSIC FOLDER")
			FOLDERGUI.OnEvent("Click", MUSICFOLDER)
			;Finished with definitions
			MyGui.Show()
			;below is what happens when you click on each name
			AIMP(*) {
				Run("C:\Program Files (x86)\AIMP\AIMP.exe")
				WinWait("ahk_exe AIMP.exe")
				WinActivate("ahk_exe AIMP.exe")
				MyGui.Destroy()
			}
			Foobar(*) {
				Run("C:\Program Files (x86)\foobar2000\foobar2000.exe")
				WinWait("ahk_exe foobar2000.exe")
				WinActivate("ahk_exe foobar2000.exe")
				MyGui.Destroy()
			}
			WMP(*) {
				Run("C:\Program Files (x86)\Windows Media Player\wmplayer.exe")
				WinWait("ahk_exe wmplayer.exe")
				WinActivate("ahk_exe wmplayer.exe")
				MyGui.Destroy()
			}
			VLC(*) {
				Run("C:\Program Files (x86)\VideoLAN\VLC\vlc.exe")
				WinWait("ahk_exe vlc.exe")
				WinActivate("ahk_exe vlc.exe")
				MyGui.Destroy()
			}
			MUSICFOLDER(*) {
				Run("S:\Program Files\User\Music\")
				WinWait("Music")
				WinActivate("Music")
				MyGui.Destroy()
			}
		}
	if WinActive("ahk_group MusicPlayers")
		{
			GroupActivate "MusicPlayers", "r"
			loop {
				IME := WinGetTitle("A")
				if IME = "Default IME"
					GroupActivate "MusicPlayers", "r"
				if IME != "Default IME"
					break
			}
		}
	else
		if WinExist("ahk_group MusicPlayers")
			{
				WinActivate
				loop {
					IME := WinGetTitle("A")
					if IME = "Default IME"
						WinActivate("ahk_group MusicPlayers")
					if IME != "Default IME"
						break
				}
			}
	;window := WinGetTitle("A") ;debugging
	;toolCust(window, "1000") ;debugging
}

musicGUI()
{
	if WinExist("Which MP to open?")
		return
	;if there is no music player open, a custom GUI window will open asking which program you'd like to open
	MyGui := Gui("AlwaysOnTop", "Which MP to open?") ;creates our GUI window
	MyGui.SetFont("S10") ;Sets the size of the font
	MyGui.SetFont("W600") ;Sets the weight of the font (thickness)
	MyGui.Opt("+Resize +MinSize290x10") ;Sets a minimum size for the window
	;now we define the elements of the GUI window
	;defining AIMP
	aimplogo := MyGui.Add("Picture", "w25 h-1 Y9", A_WorkingDir "\Support Files\images\aimp.png")
	AIMPGUI := MyGui.Add("Button", "X40 Y7", "AIMP")
	AIMPGUI.OnEvent("Click", AIMP)
	;defining Foobar
	foobarlogo := MyGui.Add("Picture", "w20 h-1 X14 Y40", A_WorkingDir "\Support Files\images\foobar.png")
	FoobarGUI := MyGui.Add("Button", "X40 Y40", "Foobar")
	FoobarGUI.OnEvent("Click", Foobar)
	;defining Windows Media Player
	wmplogo := MyGui.Add("Picture", "w25 h-1 X140 Y9", A_WorkingDir "\Support Files\images\wmp.png")
	WMPGUI := MyGui.Add("Button", "X170 Y7", "WMP")
	WMPGUI.OnEvent("Click", WMP)
	;defining VLC
	vlclogo := MyGui.Add("Picture", "w28 h-1 X138 Y42", A_WorkingDir "\Support Files\images\vlc.png")
	VLCGUI := MyGui.Add("Button", "X170 Y40", "VLC")
	VLCGUI.OnEvent("Click", VLC)
	;defining music folder
	folderlogo := MyGui.Add("Picture", "w25 h-1  X14 Y86", A_WorkingDir "\Support Files\images\explorer.png")
	FOLDERGUI := MyGui.Add("Button", "X42 Y85", "MUSIC FOLDER")
	FOLDERGUI.OnEvent("Click", MUSICFOLDER)
	;Finished with definitions
	MyGui.Show()
	;below is what happens when you click on each name
	AIMP(*) {
		Run("C:\Program Files (x86)\AIMP\AIMP.exe")
		WinWait("ahk_exe AIMP.exe")
		WinActivate("ahk_exe AIMP.exe")
		MyGui.Destroy()
	}
	Foobar(*) {
		Run("C:\Program Files (x86)\foobar2000\foobar2000.exe")
		WinWait("ahk_exe foobar2000.exe")
		WinActivate("ahk_exe foobar2000.exe")
		MyGui.Destroy()
	}
	WMP(*) {
		Run("C:\Program Files (x86)\Windows Media Player\wmplayer.exe")
		WinWait("ahk_exe wmplayer.exe")
		WinActivate("ahk_exe wmplayer.exe")
		MyGui.Destroy()
	}
	VLC(*) {
		Run("C:\Program Files (x86)\VideoLAN\VLC\vlc.exe")
		WinWait("ahk_exe vlc.exe")
		WinActivate("ahk_exe vlc.exe")
		MyGui.Destroy()
	}
	MUSICFOLDER(*) {
		Run("S:\Program Files\User\Music\")
		WinWait("Music")
		WinActivate("Music")
		MyGui.Destroy()
	}
}
; ===========================================================================================================================================
; Old
; ===========================================================================================================================================
/*
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