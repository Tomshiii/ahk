;These global variables will be used across some Streamdeck AHK scripts.
#Include "E:\Github\ahk\KSA\Keyboard Shortcut Adjustments.ahk"
global Premiere := location "\Support Files\ImageSearch\Premiere\"
global Windows := location "\Support Files\ImageSearch\Windows\Win11\Settings\"
global Chatterino := location "\Support Files\ImageSearch\Chatterino\"

;recently went through a lot of issues with my pc which basically messed my monitors locations up each time. So now these values are all here so I can easily change them
obsLocation()
{
	if WinExist("ahk_exe obs64.exe")
		WinMove(2553, -936,  974, 1047, "OBS")
}

chatterinoLocationBotshi()
{
	WinMove(3637, 153, 662, 772)
}

chatterinoLocationTomshi()
{
	WinMove(3648, -398, 832, 586)
}

streamelementsLocation()
{
	WinMove(3513,  -936, 974, 1047, "StreamElements - Activity feed")
}

discordLocation()
{
	WinMove(-1080,  -274, 1080, 1600)
}

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

/* blockOn()
 blocks all user inputs [IF YOU GET STUCK IN A SCRIPT USE CTRL + ALT + DEL to open task manager and close AHK]
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

/* toolFind()
 create a tooltip for errors finding things
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

/*
 This function opens up the speed menu and sets the clips speed to whatever is set
 @param amount is what speed you want your clip to be set to
 */
speed(amount)
{
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
	If ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
		{
			SendInput(timelineWindow selectAtPlayhead)
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
	SendInput(speedMenu %&amount% "{ENTER}")
}

/*
 This function finds the scale value, clicks on it, then makes your clip whatever value you want
 @param amount is what you want the scale to be set to
 */
scale(amount)
{
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	If ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " Premiere "scale.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
		{
			If PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "740", %&y% + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
				MouseMove(%&xcol%, %&ycol%)
			else
				{
					blockOff()
					toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}			
		}
	else ;this is for when you have the "toggle animation" keyframe button pressed
		{
			If ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " Premiere "scale2.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
				{
					If PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "740", %&y% + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
						MouseMove(%&xcol%, %&ycol%)
					else
						{
							blockOff()
							toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
							return
						}			
				}
			else ;if everything fails, this else will trigger
				{
					blockOff()
					toolFind("scale", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}		
		}
	SendInput "{Click}"
	SendInput(%&amount%)
	SendInput("{Enter}")
	MouseMove %&xpos%, %&ypos%
	Click("middle")
	blockOff()
}

/*
 This function toggles a pause on the autosave ahk script. Due to the location of this function script, a full filepath has to be given, if you hold these scripts in a different location to me, these will error out
 */
pauseautosave()
{
	DetectHiddenWindows True
	if WinExist("autosave.ahk - AutoHotkey")
		{
			WM_COMMAND := 0x0111
			ID_FILE_PAUSE := 65403
			PostMessage WM_COMMAND, ID_FILE_PAUSE,,, location "\autosave.ahk ahk_class AutoHotkey"
		}
	else
		{
			toolCust("autosave ahk script isn't open", "1000")
			ExitApp()
		}
		
}

/*
 This function toggles a pause on the premiere_fullscreen_check ahk script. Due to the location of this function script, a full filepath has to be given, if you hold these scripts in a different location to me, these will error out
 */
pausewindowmax()
{
	DetectHiddenWindows True
	if WinExist("premiere_fullscreen_check.ahk - AutoHotkey")
		{
			WM_COMMAND := 0x0111
			ID_FILE_PAUSE := 65403
			PostMessage WM_COMMAND, ID_FILE_PAUSE,,, location "\premiere_fullscreen_check.ahk ahk_class AutoHotkey"
		}
	else
		{
			toolCust("fullscreen ahk script isn't open", "1000")
			ExitApp()
		}
}