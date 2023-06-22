/************************************************************************
 * @description move the Premere Pro playhead to the cursor
 * Tested on and designed for v22.3.1 of Premiere. Believed to mostly work within v23+
 * @author tomshi, taranVH
 * @date 2023/06/15
 * @version 2.0.9
 ***********************************************************************/
; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\Editors\Premiere>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\keys>
#Include <Classes\obj>
#Include <Functions\checkStuck>
#Include <GUIs\Premiere Timeline GUI>
; }

;//! if you intend on running this as a separate script, please read the notes below and the wiki page so you're aware of the unexpected behaviours that can cause!
;//! then uncomment the below lines
/*
#SingleInstance force
#HotIf WinActive(editors.Premiere.winTitle)
#Include <Functions\trayShortcut>
TraySetIcon(ptf.Icons "\mouse.ico")
startupTray()
*/

;// Please note the original versions of this script were originally written by TaranVH in ahk v1.1
;// This script has since been adapted for ahk v2.0+ and converted to a class for easier handling of variables and methods. Feel free to check out TaranVH on githhub to see his version of this script for ahk v1.1 -Tomshi

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NOTE!!
; YOU MUST ASSIGN ALL VARIABLES THAT START WITH `KSA.` with their proper values within `KSA.ini`
; THESE THEN ALSO NEED TO BE SET CORRECTLY WITHIN PREMIERE TO WORK CORRECTLY
; TRY RUNNING `adobeKSA.ahk` FOUND: `..\Support Files\Release Assets\`
;
; RUNNING THIS SCRIPT SEPARATELY WHILE OTHER HOTKEYS ARE SET USING THE SAME KEYS AS THIS SCRIPT MAY RESULT IN UNEXPECTED BEHAVIOUR
; TRY RUNNING THIS SCRIPT ALONGSIDE THOSE OTHER HOTKEYS (similarly to how I run this script from within `My Scripts.ahk`) TO ATTEMPT
; TO ESCAPE THIS ODD AHK QUIRK
; -Tomshi
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;NOTE: This does not, and cannot work on the timeline where there are no tracks visible.
;Explanation: https://twitter.com/boxrNathan/status/927371468371103745

;---------------------------------------------------------------------------------------

RButton::rbuttonPrem().movePlayhead()
; MButton::prem().__toggleTimelineFocus()

class rbuttonPrem {
	leftClick    := false
	xbuttonClick := false
	colourOrNorm := ""
	colour := ""
	colour2 := ""

	;First, we define all the timeline's DEFAULT possible colors.
	;(Note that your colors will be different if you changed the UI brightness inside [preferences > appearance > brightness] OR may be different in other versions of premiere)
	;I used Window Spy (it comes with AHK) to detect the exact colors onscreen.
	timeline1  := 0x414141 ;timeline colour inbetween two clips inside the in/out points ON a targeted track
	timeline2  := 0x313131 ;timeline colour of the separating LINES between targeted AND non targeted tracks inside the in/out points
	timeline3  := 0x1b1b1b ;the timeline colour inside in/out points on a NON targeted track
	timeline4  := 0x212121 ;the colour of the bare timeline NOT inside the in out points (above any tracks)
	timeline8  := 0x202020 ;the colour of the bare timeline NOT inside the in out points (v22.3.1)
	timeline9  := 0x1C1C1C ;the colour of the bare timeline NOT inside the in out points (v23.1)
	timeline10 := 0x1D1D1D ;the colour of the bare timeline NOT inside the in out points (v23.4) (above any tracks)
	timeline5  := 0xDFDFDF ;the colour of a SELECTED blank space on the timeline, NOT in the in/out points
	timeline6  := 0xE4E4E4 ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
	timeline7  := 0xBEBEBE ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
	timelineCol := [
		this.timeline1, this.timeline2, this.timeline3,
		this.timeline4, this.timeline5, this.timeline6,
		this.timeline7, this.timeline8, this.timeline9,
		this.timeline10
	]
	playhead := 0x2D8CEB ;the colour of the playhead

	/** Checks to see whether the colour under the cursor indicates that it's a blank track */
	__checkForBlank(colour) {
		;// these are the timelineCol colors of a selected clip or blank space, in or outside of in/out points.
		if (colour = this.timelineCol[5] || colour = this.timelineCol[6] || colour = this.timelineCol[7])
			return true
		return false
	}

	/**
	 * Checks the colour under the cursor to determine if it's one of the predetermined colours
	 * @returns {Boolean} if colour is not one of the predetermined values, returns `false`. Else returns `true`
	 */
	__checkColour(colour) {
		loop { ;// this loop is checking to see if `colour` is one of the predetermined colours
			if A_Index > this.timelineCol.Length
				{
					SendInput("{Rbutton}") ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were met.
					return false
				}
			if colour = this.timelineCol[A_Index] || colour = this.playhead
				return true
		}
	}

	/**
	 * Checks the colour under the cursor to determine if it's potentially a clip
	 * @returns {Boolean} if the colour under the cursor **isn't** a predetermined value, returns `false`. Else returns `true`
	 */
	__checkUnderCursor(colour) {
		if (
			colour != this.timelineCol[1] && colour != this.timelineCol[2] &&
			colour != this.timelineCol[3] && colour != this.timelineCol[4] &&
			colour != this.timelineCol[8] && colour != this.timelineCol[9]
		) {
			SendInput("{Rbutton}")
			return false
		}
		return true
	}

	/**
	 * Checks to see wheteher the playhead can be found on the screen. If it is, `KSA.shuttleStop` is sent.
	 * If the playhead is close to the cursor, the cursor will be moved to it and `LButton` is held down
	 * @param {Object} coordObj an object containing the cursor coords
	 */
	__checkForPlayhead(coordObj) {
		if PixelSearch(&throwx, &throwy, prem.timelineXValue, coordObj.y, prem.timelineXControl, coordObj.y, this.playhead) ;checking to see if the playhead is on the screen
			SendInput(KSA.shuttleStop) ;if it is, we input a shuttle stop
		if PixelSearch(&xcol, &ycol, coordObj.x - 4, coordObj.y, coordObj.x + 6, coordObj.y, this.playhead)
			{
				block.On()
				SendInput(KSA.selectionPrem)
				MouseMove(xcol, ycol)
				SendInput("{LButton Down}")
				block.Off()
				this.colourOrNorm := "colour"
			}
	}

	/**
	 * This function checks to see whether the user simply tapped the right mouse button and moves the playhead
	 * @returns {Boolean} if the user is no longer holding the `RButton`, returns `false`. Else return `true`
	 */
	__checkForTap() {
		if !GetKeyState("RButton", "P") ;this block will allow you to still tap the activation hotkey and have it move the cursor
			{
				SendInput(KSA.playheadtoCursor) ;check the Keyboard Shortcut.ini/ahk to change this
				;The below checks are to ensure no buttons end up stuck
				checkstuck()
				return false
			}
		return true
	}

	/** If `LButton` or `XButton2` was pressed while `RButton` was being held, this function will start playback in either 1x or 2x speed once `RButton` is released */
	__restartPlayback() {
		;this check is purely to allow me to manipulate premiere easier with just my mouse. I sit like a shrimp sometimes alright leave me alone
			SendInput(KSA.playStop)
			if this.xbuttonClick = true ;if you press xbutton2 at all while holding the Rbutton, this script will remember and begin speeding up playback once you stop moving the playhead
				SendInput(KSA.speedUpPlayback)
	}

	/** Set class variables to the found colour */
	__setColours(coordObj) => (this.colour := PixelGetColor(coordObj.x, coordObj.y), this.colour2 := PixelGetColor(coordObj.x + 1, coordObj.y))

	/** Reset class variables */
	__resetClicks() => (this.leftClick := false, this.xbuttonClick := false, this.colourOrNorm := "", this.colour := "", this.colour2 := "")

	/** A functon to define what should happen anytime the class is closed */
	__exit() => (this.__HotkeyReset(), this.__resetClicks(), checkstuck(), Exit())

	/**
	 * Defines what happens when certain buttons are pressed while RButton is held down
	 * @param {Array} arr all keys you wish to assign a function
	 */
	__HotkeySet(arr) {
		try {
			for v in arr {
				Hotkey(v, __set.Bind(v), "On")
			}
		}

		/**
		 * A function to define what each hotkey passed will do
		 * @param {String} which the keyname
		 */
		__set(which, *) {
			switch which {
				case "LButton":  this.leftClick := true
				case "XButton2": this.leftClick := true, this.xbuttonClick := true
			}
		}
	}

	/** Resets the keys used during the loop to their original functions */
	__HotkeyReset() {
		keyArr := ["LButton", "XButton2"]
		for k in keyArr {
			try {
				Hotkey(k, k, "On")
			} catch {
				try {
					Hotkey(k, "Off")
				}
			}
		}
	}

	/**
	 * This is the class method intended to be called by the user, it handles moving the playhead to the cursor when `RButton` is pressed.
	 * This function has built in checks for `LButton` & `XButton2` - check the wiki for more details
	 */
	movePlayhead() {
		if GetKeyState("Ctrl") || GetKeyState("Shift") {
			checkstuck()
		}
		coord.s()
		origMouse := obj.MousePos()
		this.__HotkeySet(["LButton", "XButton2"])
		if !prem.__checkTimeline()
			this.__exit()
		if !prem.__checkCoords(origMouse) {
			SendInput("{Rbutton}")
			this.__exit()
		}
		this.__setColours(origMouse)
		if this.__checkForBlank(this.colour) {
			SendInput("{ESC}") ;in Premiere 13.0+, ESCAPE will now deselect clips on the timelineCol, in addition to its other uses. i think it is good to use here, now. But you can swap this out with the hotkey for "DESELECT ALL" within premiere if you'd like.
			this.__exit()
		}
		if !this.__checkColour(this.colour) {
			this.__exit()
		}
		prem.__checkTimelineFocus()
		if this.colour = this.playhead {
			if !this.__checkUnderCursor(this.colour2) {
				this.__exit()
			}
		}
		this.__checkForPlayhead(origMouse)
		if !this.__checkForTap() {
			this.__exit()
		}
		while GetKeyState("Rbutton", "P") {
			if (GetKeyState("Ctrl") || GetKeyState("Ctrl", "P")) || GetKeyState("Shift") {
				checkstuck()
				if GetKeyState("Ctrl", "P") { ;you still want to be able to hold shift so you can cut all tracks on the timeline
					tool.Cust("Holding control while scrubbing will cause Premiere to freak out")
					break
				}
			}
			if this.colourOrNorm != "colour"
				SendInput(ksa.playheadtoCursor)
			sleep 16
		}
		this.__HotkeyReset()
		if this.colourOrNorm = "colour" {
			SendInput("{LButton Up}")
		}
		if !this.leftClick && !this.xbuttonClick {
			this.__exit()
		}
		if this.leftClick
			this.__restartPlayback()
		this.__exit()
	}

	__Delete() {
		this.__exit()
	}
}