;These global variables will be used across some Streamdeck AHK scripts.
SetWorkingDir(ptf.rootDir) ;this is required for KSA to work

; { \\ #Includes
#Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Functions\General>
#Include <\Functions\ptf>
; }

;went through a lot of issues with my pc which basically messed my monitors locations up each time. So now these values are all here so I can easily change them
obsLocation()
{
	if WinExist("ahk_exe obs64.exe")
		WinMove(2553, -936,  974, 1047, "OBS")
}

chatterinoLocationBotshi() => WinMove(3637, 153, 662, 772)

chatterinoLocationTomshi() => WinMove(3648, -398, 832, 586)

streamelementsLocation() => WinMove(3513,  -936, 974, 1047, "StreamElements - Activity feed")

discordlocation() => WinMove(-1080,  -274, 1080, 1600)

/**
 * This function is to cut repeat code across scripts.
 * In windows 11 it's incredibly difficult for ahk to detect the native terminal window, because of this, this script will instead open A_ComSpec and cd to the folder the user is within.
 * @param {any} input the command you wish ahk to send into cmd
 */
convert2(input)
{
	if WinActive("ahk_class CabinetWClass")
		{
			oldClip := ClipboardAll()
			A_Clipboard := ""
			SendInput("{f4}" "^a" "^c") ;F4 highlights the path box, then opens cmd at the current directory
			if !ClipWait(2)
				{
					tool.Cust("didn't get directory information")
					return
				}
			dir := SplitPathObj(A_Clipboard)
			Run(A_ComSpec,,, &cmd)
			WinWaitActive(cmd,, 2)
			sleep 2000
			SendInput(dir.Drive "{Enter}")
			sleep 50
			SendInput("cd " A_Clipboard "{Enter}")
			sleep 50
			SendInput(input) ;this requires you to have ffmpeg in your system path, otherwise this will do nothing
			A_Clipboard := oldClip
		}
}

/**
 * This function opens up the speed menu and sets the clips speed to whatever is set
 * @param {Integer} amount is what speed you want your clip to be set to
 */
speed(amount)
{
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
	if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " ptf.Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
		SendInput(timelineWindow selectAtPlayhead)
	else
		{
			classNN := ControlGetClassNN(ControlGetFocus("A"))
			if classNN = "DroverLord - Window Class3"
				{
					tool.Cust("gain macro couldn't figure`nout what to do")
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
	coord.s()
	block.On()
	MouseGetPos &xpos, &ypos
	if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " ptf.Premiere "scale.png") || ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " ptf.Premiere "scale2.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
		{
			if !PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
				{
					block.Off()
					tool.Cust("the blue text",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
			MouseMove(xcol, ycol)
		}
	SendInput "{Click}"
	SendInput(amount)
	SendInput("{Enter}")
	MouseMove xpos, ypos
	Click("middle")
	block.Off()
}