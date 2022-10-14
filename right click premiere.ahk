;#SingleInstance force ; only 1 instance of this script may run at a time.
/* InstallMouseHook
InstallKeybdHook */
;TraySetIcon(A_WorkingDir "\Support Files\Icons\mouse.ico") ;because this is now just #include(d) in the main script, if this is here it overides the icon of the main script
/* CoordMode "Mouse", "screen"
CoordMode "Pixel", "screen" */

; I NO LONGER RUN THIS SCRIPT SEPARATELY. I was running into issues with scripts loading after this one and it then breaking so to compensate I run it WITHIN the `My Scripts.ahk` so it never breaks -Tomshi


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

#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")
;--------EVERYTHING BELOW THIS LINE WILL ONLY WORK INSIDE PREMIERE PRO!----------

Rbutton::
{
	if GetKeyState("Ctrl") {
		SetTimer(checkCtrl, -1)
	}
	;getting base information
	MouseGetPos &xpos, &ypos
	Color := PixelGetColor(xpos, ypos)
	color2 := PixelGetColor(xpos + 1, ypos)

	if (
		Color = timelineCol[5] ||
		Color = timelineCol[6] ||
		Color = timelineCol[7]
	) ;these are the timelineCol colors of a selected clip or blank space, in or outside of in/out points.
		sendinput "{ESC}" ;in Premiere 13.0+, ESCAPE will now deselect clips on the timelineCol, in addition to its other uses. i think it is good to use here, now. But you can swap this out with the hotkey for "DESELECT ALL" within premiere if you'd like.
	else if (
		Color = timelineCol[1] ||
		Color = timelineCol[2] ||
		Color = timelineCol[3] ||
		Color = timelineCol[4] ||
		Color = timelineCol[5] ||
		Color = timelineCol[6] ||
		Color = timelineCol[7] ||
		Color = timelineCol[8] ||
		Color = playhead
	)
		{ ;this block is if the colour at the cursor is one of the above in the `else if()`
			if GetKeyState("Rbutton", "P")
				{
					colourOrNorm := "" ;we use this variable to cut reduce code and track whether the playhead will be moved via leftclicking it or using the "move playhead to cursor" keyboard shortcut
					click("middle") ;sends the middle mouse button to BRING FOCUS TO the timelineCol, WITHOUT selecting any clips or empty spaces between clips. very nice!
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
					SendInput(shuttleStop)
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
					while GetKeyState("Rbutton", "P")
						{
							if GetKeyState("Ctrl") {
									SetTimer(checkCtrl, -2500)
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
			Send("{Escape}") ;in case you end up inside the "delete" right click menu from the timeline
		}
	else
		sendinput("{Rbutton}") ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were NOT met.
}

/**
 * This function is to help stop the Ctrl modifier from getting stuck which can sometimes happen while using this script. Testing for this is difficult and as such, this function may slowly change over time.
 * This function is necessary because some of the hotkeys used in the code above include the Ctrl modifier (^) - if interupted, this modifier can get placed in a "stuck" state where it will remain "pressed"
 * You may be able to avoid needing this function by simply using hotkeys that do not use modifiers.
 */
checkCtrl()
{
	SendInput("{Ctrl Up}")
	tool.Wait(1)
	tool.Cust("ctrl key stuck, lifting", 2000)
	SetTimer(, 0)
}