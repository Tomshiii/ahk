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

/**
 * sets coordmode to "screen"
 */
coords()
{
	coordmode "pixel", "screen"
	coordmode "mouse", "screen"
}

/**
 * sets coordmode to "window"
 */
coordw()
{
	coordmode "pixel", "window"
	coordmode "mouse", "window"
}

/**
 * blocks all user inputs [IF YOU GET STUCK IN A SCRIPT USE CTRL + ALT + DEL to open task manager and close AHK]
 */
blockOn()
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
	;it has recently come to my attention that all 3 of these operate independantly and doing all 3 of them at once is no different to just using "BlockInput "on"" but uh. oops, too late now I guess
}

/**
 * turns off the blocks on user input
 */
blockOff()
{
	blockinput "MouseMoveOff"
	BlockInput "off"
}

/**
 * Create a tooltip with any message. This tooltip will then follow the cursor and only redraw itself if the user has moved the cursor.
 * @param {string} message is what you want the tooltip to say
 * @param {number} timeout is how many ms you want the tooltip to last. This value can be omitted and it will default to 1s
 * @param {boolean} find is whether you want this function to state "Couldn't find " at the beginning of it's tooltip. Simply add 1 (or true) for this variable if you do, or omit it if you don't
 * @param {number} xy the x & y coordinates you want the tooltip to appear. These values are unset by default and can be omitted
 * @param {number} WhichToolTip omit this parameter if you don't need multiple tooltips to appear simultaneously. Otherwise, this is a number between 1 and 20 to indicate which tooltip window to operate upon. If unspecified, that number is 1 (the first).
 */
toolCust(message, timeout := 1000, find := false, x?, y?, WhichToolTip?)
{
	MouseGetPos(&xpos, &ypos)
	time := A_TickCount
	if find != 1
		messageFind := ""
	else
		messageFind := "Couldn't find "
	ToolTip(messageFind message, x?, y?, WhichToolTip?)
	if !IsSet(x) && !IsSet(y)
		SetTimer(moveWithMouse, 15)
	SetTimer(() => ToolTip("",,, WhichToolTip?), - timeout)
	moveWithMouse()
	{
		if (A_TickCount - time) >= timeout
			{
				SetTimer(, 0)
				ToolTip("")
			}
		MouseGetPos(&newX, &newY)
		if newX != xpos || newY != ypos
			{
				MouseGetPos(&xpos, &ypos)
				ToolTip(messageFind message)
			}
	}
}

/**
 * This function opens up the speed menu and sets the clips speed to whatever is set
 * @param amount is what speed you want your clip to be set to
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
					toolCust("gain macro couldn't figure`nout what to do")
					return
				}
		}
	inputs:
	SendInput(speedMenu amount "{ENTER}")
}

/**
 * This function finds the scale value, clicks on it, then makes your clip whatever value you want
 * @param amount is what you want the scale to be set to
 */
scale(amount)
{
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	If ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " Premiere "scale.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
		{
			If PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
				MouseMove(xcol, ycol)
			else
				{
					blockOff()
					toolCust("the blue text",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
		}
	else ;this is for when you have the "toggle animation" keyframe button pressed
		{
			If ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " Premiere "scale2.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
				{
					If PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
						MouseMove(xcol, ycol)
					else
						{
							blockOff()
							toolCust("the blue text",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
							return
						}
				}
			else ;if everything fails, this else will trigger
				{
					blockOff()
					toolCust("scale",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
		}
	SendInput "{Click}"
	SendInput(amount)
	SendInput("{Enter}")
	MouseMove xpos, ypos
	Click("middle")
	blockOff()
}

/**
 * This function toggles a pause on the autosave ahk script. Due to the location of this function script, a full filepath has to be given, if you hold these scripts in a different location to me, these will error out
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
			toolCust("autosave ahk script isn't open")
			ExitApp()
		}

}

/**
 * This function toggles a pause on the premiere_fullscreen_check ahk script. Due to the location of this function script, a full filepath has to be given, if you hold these scripts in a different location to me, these will error out
 */
pausewindowmax()
{
	DetectHiddenWindows True
	if WinExist("adobe fullscreen check.ahk - AutoHotkey")
		{
			WM_COMMAND := 0x0111
			ID_FILE_PAUSE := 65403
			PostMessage WM_COMMAND, ID_FILE_PAUSE,,, location "\adobe fullscreen check.ahk ahk_class AutoHotkey"
		}
	else
		{
			toolCust("fullscreen ahk script isn't open")
			ExitApp()
		}
}