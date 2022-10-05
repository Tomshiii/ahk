;These global variables will be used across some Streamdeck AHK scripts.
#Include "..\lib\KSA\Keyboard Shortcut Adjustments.ahk"
#Include "..\lib\Functions\General.ahk"
global Windows := location "\Support Files\ImageSearch\Windows\Win11\Settings\"
global Chatterino := location "\Support Files\ImageSearch\Chatterino\"

;recently went through a lot of issues with my pc which basically messed my monitors locations up each time. So now these values are all here so I can easily change them
obsLocation()
{
	if WinExist("ahk_exe obs64.exe")
		WinMove(2553, -936,  974, 1047, "OBS")
}

chatterinoLocationBotshi() => WinMove(3637, 153, 662, 772)

chatterinoLocationTomshi() => WinMove(3648, -398, 832, 586)

streamelementsLocation() => WinMove(3513,  -936, 974, 1047, "StreamElements - Activity feed")

discordLocation() => WinMove(-1080,  -274, 1080, 1600)

/**
 * This function opens up the speed menu and sets the clips speed to whatever is set
 * @param {Integer} amount is what speed you want your clip to be set to
 */
speed(amount)
{
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
	if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
		SendInput(timelineWindow selectAtPlayhead)
	else
		{
			classNN := ControlGetClassNN(ControlGetFocus("A"))
			if classNN = "DroverLord - Window Class3"
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
 * @param {Integer} amount is what you want the scale to be set to
 */
scale(amount)
{
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " Premiere "scale.png") || ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " Premiere "scale2.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
		{
			if !PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
				{
					blockOff()
					toolCust("the blue text",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
			MouseMove(xcol, ycol)
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
	if !WinExist("autosave.ahk - AutoHotkey")
		{
			toolCust("autosave ahk script isn't open")
			ExitApp()
		}
	WM_COMMAND := 0x0111
	ID_FILE_PAUSE := 65403
	PostMessage WM_COMMAND, ID_FILE_PAUSE,,, location "\autosave.ahk ahk_class AutoHotkey"
}

/**
 * This function toggles a pause on the premiere_fullscreen_check ahk script. Due to the location of this function script, a full filepath has to be given, if you hold these scripts in a different location to me, these will error out
 */
pausewindowmax()
{
	DetectHiddenWindows True
	if !WinExist("adobe fullscreen check.ahk - AutoHotkey")
		{
			toolCust("fullscreen ahk script isn't open")
			ExitApp()
		}
	WM_COMMAND := 0x0111
	ID_FILE_PAUSE := 65403
	PostMessage WM_COMMAND, ID_FILE_PAUSE,,, location "\adobe fullscreen check.ahk ahk_class AutoHotkey"
}