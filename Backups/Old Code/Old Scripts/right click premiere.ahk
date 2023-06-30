; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\Editors\Premiere>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\obj>
#Include <Classes\errorLog>
#Include <Functions\trayShortcut>
#Include <Classes\keys>
; }
startupTray()

;//! if you wish to run this script separately, uncomment the below block of text
/*
#SingleInstance force ; only 1 instance of this script may run at a time.
#HotIf WinActive(editors.Premiere.winTitle)
TraySetIcon(ptf.Icons "\mouse.ico") ;because this is now just #include(d) in the main script, if this is here it overides the icon of the main script
*/
;//! - I NO LONGER RUN THIS SCRIPT SEPARATELY. I was running into issues with scripts loading after this one and it then breaking so to compensate I run it WITHIN the `My Scripts.ahk` so it never breaks -Tomshi


; Please note this script was originally written by taran in ahk v1.1 so any of his comment ramblings will go on about code that might not function in ahk v2.0 -Tomshi
; A lot of this script has been adapted and changed by me, keeping track of it all has gotten too confusing and convoluted. Feel free to check out TaranVH on githhub to see his version of this script for ahk v1.1 -Tomshi

;THIS IS A GREAT FIRST SCRIPT FOR AHK NOOBS! IT WORKS WITH VERY LITTLE SETUP. JUST READ THE STUFF BELOW! YAY!
;VIDEO EXPLANATION:  https://youtu.be/O6ERELse_QY?t=23m40s

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NOTE!!
; YOU MUST ASSIGN ALL VARIABLES THAT START WITH `KSA.` with their proper values within `KSA.ini`
; THESE THEN ALSO NEED TO BE SET CORRECTLY WITHIN PREMIERE TO WORK CORRECTLY
; -Tomshi
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;NOTE: This does not, and cannot work on the timeline where there are no tracks visible.
;Explanation: https://twitter.com/boxrNathan/status/927371468371103745

;---------------------------------------------------------------------------------------

;First, we define all the timeline's DEFAULT possible colors.
;(Note that your colors will be different if you changed the UI brightness inside preferences > appearance > brightness.)
;I used Window Spy (it comes with AHK) to detect the exact colors onscreen.
timeline1 := 0x414141 ;timeline color inbetween two clips inside the in/out points ON a targeted track
timeline2 := 0x313131 ;timeline color of the separating LINES between targeted AND non targeted tracks inside the in/out points
timeline3 := 0x1b1b1b ;the timeline color inside in/out points on a NON targeted track
timeline4 := 0x212121 ;the color of the bare timeline NOT inside the in out points (potentially a different version/colour as it doesn't line up with anything for me)
timeline8 := 0x202020 ;the color of the bare timeline NOT inside the in out points (v22.3.1)
timeline9 := 0x1C1C1C ;the color of the bare timeline NOT inside the in out points (v23.1)
timeline5 := 0xDFDFDF ;the color of a SELECTED blank space on the timeline, NOT in the in/out points
timeline6 := 0xE4E4E4 ;the color of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
timeline7 := 0xBEBEBE ;the color of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track

playhead := 0x2D8CEB ;the colour of the playhead
timelineCol := [] ;here we'll just create an array that encapsulates all of the above timeline colours to make things a little easier to keep track of
loop {
	if !IsSet(%"timeline" A_Index%)
		break
	timelineCol.Push(Format("{:#x}", %"timeline" A_Index%))
}

;--------EVERYTHING BELOW THIS LINE WILL ONLY WORK INSIDE PREMIERE PRO!----------

Rbutton::
{
	if !IsSet(timelineCol)
		{
			SendInput("{RButton Up}")
			return
		}
	if GetKeyState("Ctrl") || GetKeyState("Shift") {
		SetTimer(checkStuck, -1)
	}
	coord.s()
	;getting base information
	MouseGetPos(&xpos, &ypos)
	;//! this code block until `skip:` is getting & storing the x/y values of the timeline
	;we do this so we can check later if the playhead is currently on the screen - if it is we'll do a shuttle stop
	;if it isn't we won't
	;the reason we don't want to if the playhead isn't on the screen is because if you hit shuttlestop when it's not
	;your view of the timeline will snap to the playhead

    if prem.timelineXValue = 0 || prem.timelineYValue = 0 || prem.timelineXControl = 0 || prem.timelineYControl = 0
        {
			if !prem.getTimeline()
				return
		}
    if ((xpos > prem.timelineXValue) || (xpos < prem.timelineXControl) || (ypos < prem.timelineYValue) || (ypos > prem.timelineYControl)) ;this line of code ensures that the function does not fire if the mouse is outside the bounds of the timeline. This code should work regardless of where you have the timeline (if you make you're timeline comically small you may encounter issues)
        {
			SendInput("{Rbutton}")
			return
		}
	Color := PixelGetColor(xpos, ypos)
	color2 := PixelGetColor(xpos + 1, ypos)
	;now we begin checking colours
	if (
		Color = timelineCol[5] ||
		Color = timelineCol[6] ||
		Color = timelineCol[7]
	) ;these are the timelineCol colors of a selected clip or blank space, in or outside of in/out points.
		SendInput("{ESC}") ;in Premiere 13.0+, ESCAPE will now deselect clips on the timelineCol, in addition to its other uses. i think it is good to use here, now. But you can swap this out with the hotkey for "DESELECT ALL" within premiere if you'd like.
	else
		{
			loop { ;this loop is checking to see if `color` is one of the predetermined colours
				if A_Index > timelineCol.Length
					{
						SendInput("{Rbutton}") ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were met.
						return
					}
				if Color = timelineCol[A_Index] || Color = playhead
					break
			}
			colourOrNorm := "" ;we use this variable to cut reduce code and track whether the playhead will be moved via leftclicking it or using the "move playhead to cursor" keyboard shortcut
			; //
			; click("middle") ;sends the middle mouse button to BRING FOCUS TO the timeline, WITHOUT selecting any clips or empty spaces between clips. very nice!
			;   - while as stated above, middle clicking the mouse does indeed bring focus to the timeline, for whatever reason having that line active made it so that
			;   - if I ever click RButton and an XButton at the same time, the script would sorta lag and then get stuck in it's loop unable to tell that RButton isn't being held
			; //
			SendInput(KSA.timelineWindow) ;so we'll do this instead
			if Color = playhead ;this block of code ensures that you can still right click a track even if you're directly hovering over the playhead
			{
				if (
					color2 != timelineCol[1] &&
					color2 != timelineCol[2] &&
					color2 != timelineCol[3] &&
					color2 != timelineCol[8] &&
					color2 != timelineCol[4] &&
					color2 != timelineCol[9]
				) {
					SendInput("{Rbutton}")
					return
				}
			}
			if PixelSearch(&throwx, &throwy, prem.timelineXValue, ypos, prem.timelineXControl, ypos, playhead) ;checking to see if the playhead is on the screen
				SendInput(KSA.shuttleStop) ;if it is, we input a shuttle stop
			if PixelSearch(&xcol, &ycol, xpos - 4, ypos, xpos + 6, ypos, playhead)
				{
					block.On()
					SendInput(KSA.selectionPrem)
					MouseMove(xcol, ycol)
					SendInput("{LButton Down}")
					block.Off()
					;ToolTip("left button pressed") ;testing
					colourOrNorm := "colour"
				}
			if !GetKeyState("Rbutton", "P") ;this block will allow you to still tap the activation hotkey and have it move the cursor
				{
					SendInput(KSA.playheadtoCursor) ;check the Keyboard Shortcut.ini/ahk to change this
					;The below checks are to ensure no buttons end up stuck
					keys.check("LButton")
					keys.check("XButton1")
					keys.check("XButton2")
					return
				}
			while GetKeyState("Rbutton", "P")
				{
					if GetKeyState("Ctrl") || GetKeyState("Shift") {
							SetTimer(checkStuck, -1)
							if GetKeyState("Ctrl", "P") ;you still want to be able to hold shift so you can cut all tracks on the timeline
								{
									tool.Cust("Holding control while scrubbing will cause Premiere to freak out")
									break
								}
						}
					static left := 0
					static xbutton := 0
					if colourOrNorm != "colour"
						SendInput(KSA.playheadtoCursor) ;check the Keyboard Shortcut.ini/ahk to change this
					sleep 16 ;this loop will repeat every 16 milliseconds. Lowering this value won't make it go any faster as you're limited by Premiere Pro
					if GetKeyState("LButton", "P")
						left := 1
					if GetKeyState("XButton2", "P")
						{
							xbutton := 1
							left := 1
						}
				}
			if !IsSet(left) || !IsSet(xbutton)
				return
			if colourOrNorm = "colour"
				SendInput("{LButton Up}")
			if left > 0 ;if you press LButton at all while holding the Rbutton, this script will remember and begin playing once you stop moving the playhead
				{ ;this check is purely to allow me to manipulate premiere easier with just my mouse. I sit like a shrimp sometimes alright leave me alone
					SendInput(KSA.playStop)
					if xbutton > 0 ;if you press xbutton2 at all while holding the Rbutton, this script will remember and begin speeding up playback once you stop moving the playhead
						SendInput(KSA.speedUpPlayback)
					left := 0
					xbutton := 0
				}
			return
		}
}

/**
 * This function is to help stop the Ctrl/Shift modifier from getting stuck which can sometimes happen while using this script. Testing for this is difficult and as such, this function may slowly change over time.
 * This function is necessary because some of the hotkeys used in the code above include the Ctrl modifier (^)/Shift modifier (+) - if interupted, this modifier can get placed in a "stuck" state where it will remain "pressed"
 * You may be able to avoid needing this function by simply using hotkeys that do not use modifiers.
 */
checkStuck()
{
	key := ""
	if GetKeyState("Ctrl") && !GetKeyState("Ctrl", "P") && !GetKeyState("Shift")
		key := "ctrl"
	if GetKeyState("Shift") && !GetKeyState("Shift", "P") && !GetKeyState("Ctrl")
		key := "shift"
	if key != ""
		SendInput("{" key " Up}")
	if GetKeyState("Ctrl") && GetKeyState("Shift") && !GetKeyState("Shift", "P") && !GetKeyState("Ctrl", "P")
		{
			SendInput("{Ctrl Up}")
			SendInput("{Shift Up}")
			key := "ctrl & shift"
		}
	if key != ""
		{
			tool.Wait(1)
			tool.Cust(key " key stuck, lifting", 2000)
		}

	SetTimer(, 0)
}

;debugging
/* checkXStuck()
{
	if !GetKeyState("XButton1") && !GetKeyState("XButton2")
		return
	key := ""
	if GetKeyState("XButton1") && !GetKeyState("XButton2")
		key := "XButton1"
	if GetKeyState("XButton2") && !GetKeyState("XButton1")
		key := "XButton2"
	SendInput("{" key " Up}")
	if GetKeyState("XButton1") && GetKeyState("XButton2")
		{
			SendInput("{XButton1 Up}")
			SendInput("{XButton2 Up}")
			key := "XButton1 & XButton2"
		}
	tool.Wait(1)
	tool.Cust(key " key stuck, lifting", 2000)

	SetTimer(, 0)
} */