;#SingleInstance force ; only 1 instance of this script may run at a time.
/* InstallMouseHook
InstallKeybdHook */
;TraySetIcon(A_WorkingDir "\Support Files\Icons\mouse.ico") ;because this is now just #include(d) in the main script, if this is here it overides the icon of the main script
/* CoordMode "Mouse", "screen"
CoordMode "Pixel", "screen" */
;#Requires AutoHotkey v2.0-beta.6 ;this script requires AutoHotkey v2.0

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
playhead := 0x2D8CEB

#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")
;--------EVERYTHING BELOW THIS LINE WILL ONLY WORK INSIDE PREMIERE PRO!----------

Rbutton::
{
	MouseGetPos &xpos, &ypos
	Color := PixelGetColor(%&xpos%, %&ypos%)
	color2 := PixelGetColor(%&xpos% + 1, %&ypos%)
	if (Color = timeline5 || Color = timeline6 || Color = timeline7) ;these are the timeline colors of a selected clip or blank space, in or outside of in/out points.
		sendinput "{ESC}" ;in Premiere 13.0+, ESCAPE will now deselect clips on the timeline, in addition to its other uses. i think it is good ot use here, now. But you can swap this out with the hotkey for "DESELECT ALL" within premiere if you'd like.
		;send ^+d ;in Premiere, set CTRL SHIFT D to "DESELECT ALL"
	else if (Color = timeline1 || Color = timeline2 || Color = timeline3 || Color = timeline4 || Color = timeline5 || Color = timeline6 || Color = timeline7 || Color = timeline8 || Color = playhead)
		{
			;BREAKTHROUGH -- it looks like a middle mouse click will BRING FOCUS TO a panel without doing ANYTHING ELSE like selecting or going through tabs or anything. Unfortunately, i still can't know with AHK which panel is already in focus.
			if GetKeyState("Rbutton", "P")
				{
					click("middle") ;sends the middle mouse button to BRING FOCUS TO the timeline, WITHOUT selecting any clips or empty spaces between clips. very nice!
					if Color = playhead ;this block of code ensures that you can still right click a track even if you're directly hovering over the playhead
					{
						if (color2 != timeline1 && color2 != timeline2 && color2 != timeline3 && color2 != timeline8 && color2 != timeline4)
							{
								SendInput("{Rbutton}")
								return
							}
					}
					if PixelSearch(&xcol, &ycol, %&xpos% - 4, %&ypos%, %&xpos% + 6, %&ypos%, playhead)
						{
							blockOn()
							MouseMove(%&xcol%, %&ycol%)
							SendInput("{LButton Down}")
							blockOff()
							;ToolTip("left button pressed") ;testing
							loop {
								static left := 0
								static xbutton := 0
								sleep 16 ;this loop will repeat every 16 milliseconds. Lowering this value won't make it go any faster as you're limited by Premiere Pro
								if GetKeyState("LButton", "P")
									left := 1
								if GetKeyState("XButton2", "P")
									{
										xbutton := 1
										left := 1
									}
								if not GetKeyState("Rbutton", "P")
									{
										break
									}
								}
							;ToolTip("")
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
					loop
						{
							static left := 0
							static xbutton := 0
							SendInput(playheadtoCursor) ;check the Keyboard Shortcut.ini/ahk to change this
							sleep 16 ;this loop will repeat every 16 milliseconds. Lowering this value won't make it go any faster as you're limited by Premiere Pro
							if GetKeyState("LButton", "P") ;this code and the check below are additions by Tomshi
								left := 1
							if GetKeyState("XButton2", "P") ;this code and the check below are additions by Tomshi
								{
									xbutton := 1
									left := 1
								}
							if not GetKeyState("Rbutton", "P")
								{
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
				}
			Send("{Escape}") ;in case you end up inside the "delete" right click menu from the timeline
		}
	else
		sendinput("{Rbutton}") ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were NOT met.
}
