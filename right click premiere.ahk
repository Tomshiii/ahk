/*
#SingleInstance force ; only 1 instance of this script may run at a time.
InstallMouseHook
InstallKeybdHook
TraySetIcon(ptf.Icons "\mouse.ico") ;because this is now just #include(d) in the main script, if this is here it overides the icon of the main script
CoordMode("Mouse", "screen")
CoordMode("Pixel", "screen")
*/
; I NO LONGER RUN THIS SCRIPT SEPARATELY. I was running into issues with scripts loading after this one and it then breaking so to compensate I run it WITHIN the `My Scripts.ahk` so it never breaks -Tomshi

; { \\ #Includes
#Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Functions\General>
; #Include <\Functions\ptf> ; only need this if you run the script by itself
; }


; Please note this script was originally written by taran in ahk v1.1 so any of his comment ramblings will go on about code that might not function in ahk v2.0 -Tomshi
; A lot of this script has been adapted and changed by me, keeping track of it all has gotten too confusing and convoluted. Feel free to check out TaranVH on githhub to see his version of this script for ahk v1.1 -Tomshi

;THIS IS A GREAT FIRST SCRIPT FOR AHK NOOBS! IT WORKS WITH VERY LITTLE SETUP. JUST READ THE STUFF BELOW! YAY!
;VIDEO EXPLANATION:  https://youtu.be/O6ERELse_QY?t=23m40s

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NOTE THAT YOU MUST ASSIGN "Move playhead to cursor" in Premiere's keyboard shortcuts panel as well as "Playhead to Cursor" in KSA.ini in this directory to the same thing for this script to function properly! -Tomshi
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;NOTE: This does not, and cannot work on the timeline where there are no tracks visible.
;Explanation: https://twitter.com/boxrNathan/status/927371468371103745

;---------------------------------------------------------------------------------------

;First, we define all the timeline's DEFAULT possible colors.
;(Note that your colors will be different if you changed the UI brightness inside preferences > appearance > brightness.)
;I used Window Spy (it comes with AHK) to detect the exact colors onscreen.
timeline1 := 0x414141 ;timeline color inside the in/out points ON a targeted track
timeline2 := 0x313131 ;timeline color of the separating LINES between targeted AND non targeted tracks inside the in/out points
timeline3 := 0x1b1b1b ;the timeline color inside in/out points on a NON targeted track
timeline4 := 0x212121 ;the color of the bare timeline NOT inside the in out points
timeline5 := 0xDFDFDF ;the color of a SELECTED blank space on the timeline, NOT in the in/out points
timeline6 := 0xE4E4E4 ;the color of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
timeline7 := 0xBEBEBE ;the color of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
timeline8 := 0x202020
playhead := 0x2D8CEB ;the colour of the playhead
timelineCol := [timeline1, timeline2, timeline3, timeline4, timeline5, timeline6, timeline7, timeline8] ;here we'll just create an array that encapsulates all of the above to make things a little easier to keep track of

#HotIf WinActive(editors.winTitle["premiere"])
;--------EVERYTHING BELOW THIS LINE WILL ONLY WORK INSIDE PREMIERE PRO!----------

Rbutton::
{
	if GetKeyState("Ctrl") || GetKeyState("Shift") {
		SetTimer(checkStuck, -1)
	}
	;getting base information
	MouseGetPos(&xpos, &ypos)
	;this block until `skip:` is getting & storing the x/y values of the timeline
	;we do this so we can check later if the playhead is currently on the screen - if it is we'll do a shuttle stop
	;if it isn't we won't
	;the reason we don't want to if the playhead isn't on the screen is because if you hit shuttlestop when it's now
	;your view of the timeline will snap to the playhead
	static xValue := 0
    static yValue := 0
    static xControl := 0
    static yControl := 0
    if xValue = 0 || yValue = 0 || xControl = 0 || yControl = 0
        {
            try {
                SendInput(timelineWindow)
                effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
                ControlGetPos(&x, &y, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
                static xValue := width - 22 ;accounting for the scroll bars on the right side of the timeline
                static yValue := y + 46 ;accounting for the area at the top of the timeline that you can drag to move the playhead
                static xControl := x + 238 ;accounting for the column to the left of the timeline
                static yControl := height + 40 ;accounting for the scroll bars at the bottom of the timeline
                tool.Wait()
				script := SplitPathObj(A_LineFile)
                tool.Cust("``" script.Name "`` found the coordinates of the timeline.`nThis macro will not check coordinates again until a script refresh`nIf this script grabbed the wrong coordinates, refresh and try again!", 2.0)
            } catch as e {
                tool.Wait()
                tool.Cust("Couldn't find the ClassNN value")
                errorLog(e, "right click premiere.ahk")
                goto skip
            }
        }
    if xpos > xValue || xpos < xControl || ypos < yValue || ypos > yControl ;this line of code ensures that the function does not fire if the mouse is outside the bounds of the timeline. This code should work regardless of where you have the timeline (if you make you're timeline comically small you may encounter issues)
        {
			SendInput("{Rbutton}")
			return
		}
    skip:

	Color := PixelGetColor(xpos, ypos)
	color2 := PixelGetColor(xpos + 1, ypos)
	;now we begin checking colours
	if (
		Color = timelineCol[5] ||
		Color = timelineCol[6] ||
		Color = timelineCol[7]
	) ;these are the timelineCol colors of a selected clip or blank space, in or outside of in/out points.
		sendinput "{ESC}" ;in Premiere 13.0+, ESCAPE will now deselect clips on the timelineCol, in addition to its other uses. i think it is good to use here, now. But you can swap this out with the hotkey for "DESELECT ALL" within premiere if you'd like.
	else
		{
			loop { ;this loop is checking to see if `color` is one of the predetermined colours
				if A_Index > 8
					{
						SendInput("{Rbutton}") ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were NOT met.
						return
					}
				if Color = timelineCol[A_Index] || Color = playhead
					break
			}
			colourOrNorm := "" ;we use this variable to cut reduce code and track whether the playhead will be moved via leftclicking it or using the "move playhead to cursor" keyboard shortcut
			; click("middle") ;sends the middle mouse button to BRING FOCUS TO the timeline, WITHOUT selecting any clips or empty spaces between clips. very nice!
			;while as stated above, middle clicking the mouse does indeed bring focus to the timeline, for whatever reason having that line active made it so that
			;if I ever clicking RButton and an XButton at the same time, the script would sorta lag and then get stuck in it's loop unable to tell that RButton isn't being held
			SendInput(timelineWindow) ;so we'll do this instead
			if Color = playhead ;this block of code ensures that you can still right click a track even if you're directly hovering over the playhead
			{
				if (
					color2 != timelineCol[1] &&
					color2 != timelineCol[2] &&
					color2 != timelineCol[3] &&
					color2 != timelineCol[8] &&
					color2 != timelineCol[4]
				)
					{
						SendInput("{Rbutton}")
						return
					}
			}
			if PixelSearch(&throwx, &throwy, xValue, ypos, xControl, ypos, playhead) ;checking to see if the playhead is on the screen
				SendInput(shuttleStop) ;if it is, we input a shuttle stop
			if PixelSearch(&xcol, &ycol, xpos - 4, ypos, xpos + 6, ypos, playhead)
				{
					block.On()
					SendInput(selectionPrem)
					MouseMove(xcol, ycol)
					SendInput("{LButton Down}")
					block.Off()
					;ToolTip("left button pressed") ;testing
					colourOrNorm := "colour"
				}
			if !GetKeyState("Rbutton", "P") ;this block will allow you to still tap the activation hotkey and have it move the cursor
				{
					SendInput(playheadtoCursor) ;check the Keyboard Shortcut.ini/ahk to change this
					;The below checks are to ensure no buttons end up stuck
					if GetKeyState("LButton")
						SendInput("{LButton Up}")
					if GetKeyState("XButton1")
						SendInput("{XButton1 Up}")
					if GetKeyState("XButton2")
						SendInput("{XButton2 Up}")
					return
				}
			while GetKeyState("Rbutton", "P")
				{
					if GetKeyState("Ctrl") || GetKeyState("Shift") {
							SetTimer(checkStuck, -1)
							break
						}
					static left := 0
					static xbutton := 0
					if colourOrNorm != "colour"
						SendInput(playheadtoCursor) ;check the Keyboard Shortcut.ini/ahk to change this
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
					SendInput(playStop)
					if xbutton > 0 ;if you press xbutton2 at all while holding the Rbutton, this script will remember and begin speeding up playback once you stop moving the playhead
						SendInput(speedUpPlayback)
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