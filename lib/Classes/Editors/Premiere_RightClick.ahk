/************************************************************************
 * @description move the Premere Pro playhead to the cursor
 * Originally designed for v22.3.1 of Premiere. As of 2023/10/13 slowly began moving workflow to v24+
 * Any code after that date is no longer guaranteed to function on previous versions of Premiere.
 * @premVer 24.3
 * @author tomshi, taranVH
 * @date 2024/04/02
 * @version 2.1.1
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
#Include <Classes\winGet>
#Include <Functions\checkStuck>
#Include <Other\MouseHook>
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

;//! For a version of this script that **doesn't** use UIA. Take a look at the script [here](https://github.com/Tomshiii/ahk/blob/v2.11.3/lib/Classes/Editors/Premiere_RightClick.ahk). Just be aware that this version is an older version and as such may be missing future bug fixes/features.

;// Please note the original versions of this script were originally written by TaranVH in ahk v1.1
;// This script has since been adapted for ahk v2.0+ and converted to a class for easier handling of variables and methods. Feel free to check out TaranVH on githhub to see his version of this script for ahk v1.1 -Tomshi

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NOTE!!
YOU MUST ASSIGN ALL VARIABLES THAT START WITH `KSA.` with their proper values within `KSA.ini`
THESE THEN ALSO NEED TO BE SET CORRECTLY WITHIN PREMIERE TO WORK CORRECTLY
TRY RUNNING `adobeKSA.ahk` FOUND: `..\Support Files\Release Assets\`
;
RUNNING THIS SCRIPT SEPARATELY WHILE OTHER HOTKEYS ARE SET USING THE SAME KEYS AS THIS SCRIPT MAY RESULT IN UNEXPECTED BEHAVIOUR
TRY RUNNING THIS SCRIPT ALONGSIDE THOSE OTHER HOTKEYS (similarly to how I run this script from within `My Scripts.ahk`) TO ATTEMPT
TO ESCAPE THIS ODD AHK QUIRK

I've tried using sendeven instead of sendinput in this script multiple times but the simple fact is that sendevent is just too slow and using it means that attempting to right click and then almost immediately leftclick/xbutton click results in no input being registered.
There's probably some dumb hacky way to work around that but ultimately it's just not worth it. I see little to no benefit from using sendevent.
-Tomshi
*/
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;NOTE: This does not, and cannot work on the timeline where there are no tracks visible.
;Explanation: https://twitter.com/boxrNathan/status/927371468371103745

;---------------------------------------------------------------------------------------

;// there may be code that EXPECTS the activation hotkey to be RButton
RButton::rbuttonPrem().movePlayhead()
; MButton::prem().__toggleTimelineFocus()

;// there is code that EXPECTS the activation hotkey to be XButton1
;// including uses of `checkStuck()`
;// beware if modifying this activation hotkey that code adjustments might be necessary
XButton1::rbuttonPrem().movePlayhead(false)

class rbuttonPrem {
	leftClick    := false
	xbuttonClick := false
	colourOrNorm := ""
	colour  := ""
	colour2 := ""

	lh := false
	xh := false

	;First, we define all the timeline's DEFAULT possible colors.
	;(Note that your colors will be different if you changed the UI brightness inside [preferences > appearance > brightness] OR may be different in other versions of premiere)
	;I used Window Spy (it comes with AHK) to detect the exact colors onscreen.
	timeline1  := 0x414141 ;timeline colour inbetween two clips inside the in/out points ON a targeted track
	timeline2  := 0x313131 ;timeline colour of the separating LINES between targeted AND non targeted tracks inside the in/out points
	timeline3  := 0x1b1b1b ;the timeline colour inside in/out points on a UNTARGETED track
	timeline11 := 0x424242 ;the timeline colour inside in/out points on a TARGETED track (v23+)
	timeline4  := 0x212121 ;the colour of the bare timeline NOT inside the in out points (above any tracks)
	timeline8  := 0x202020 ;the colour of the bare timeline NOT inside the in out points (v22.3.1)
	timeline9  := 0x1C1C1C ;the colour of the bare timeline NOT inside the in out points (v23.1)
	timeline10 := 0x1D1D1D ;the colour of the bare timeline NOT inside the in out points (v23.4) (above any tracks)
	timeline5  := 0xDFDFDF ;the colour of a SELECTED blank space on the timeline, NOT in the in/out points
	timeline6  := 0xE4E4E4 ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
	timeline7  := 0xBEBEBE ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
	timelineCol := [
		this.timeline1,  this.timeline2,  this.timeline3,
		this.timeline4,  this.timeline5,  this.timeline6,
		this.timeline7,  this.timeline8,  this.timeline9,
		this.timeline10, this.timeline11
	]

	/**
	 * Checks to see whether the colour under the cursor indicates that it's a blank track
	 * @param {Hexadecimal} colour the colour you wish to check
	 */
	__checkForBlank(colour) {
		;// these are the timelineCol colors of a selected clip or blank space, in or outside of in/out points.
		if (colour = this.timelineCol[5] || colour = this.timelineCol[6] || colour = this.timelineCol[7])
			return true
		return false
	}

	/**
	 * Checks the colour under the cursor to determine if it's one of the predetermined colours
	 * @param {Hexadecimal} colour the colour you wish to check
	 * @returns {Boolean} if colour is not one of the predetermined values, returns `false`. Else returns `true`
	 */
	__checkColour(colour) {
		loop { ;// this loop is checking to see if `colour` is one of the predetermined colours
			if A_Index > this.timelineCol.Length {
				SendInput("{Rbutton}") ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were met.
				return false
			}
			if colour = this.timelineCol[A_Index] || colour = prem.playhead
				return true
		}
	}

	/**
	 * Checks the colour under the cursor to determine if it's potentially a clip
	 * @param {Hexadecimal} colour the colour you wish to check
	 * @returns {Boolean} if the colour under the cursor **isn't** a predetermined value, returns `false`. Else returns `true`
	 */
	__checkUnderCursor(colour) {
		if (
			colour != this.timelineCol[1] && colour != this.timelineCol[2] &&
			colour != this.timelineCol[3] && colour != this.timelineCol[4] &&
			colour != this.timelineCol[8] && colour != this.timelineCol[9] &&
			colour != this.timelineCol[11]
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
	 * @param {Boolean} [search=true] passing in `allChecks` to determine if the function should search near the cursor for the playhead. Disabling this feature if `allChecks` is set to `false` stops the script from potentially clicking on a clip below the cursor
	 */
	__checkForPlayhead(coordObj, search := true) {
		;// checking to see if the playhead is on the screen
		if prem.searchPlayhead({x1: prem.timelineXValue, y1: coordObj.y, x2: prem.timelineXControl, y2: coordObj.y})
			SendInput(KSA.shuttleStop) ;if it is, we input a shuttle stop
		;// this stops the script from potentially clicking a clip if using `rbuttonPrem().movePlayhead(false)`
		if !search
			return
		;// then we check to see if it's relatively close to the cursors position
		if PixelSearch(&xcol, &ycol, coordObj.x - 4, coordObj.y, coordObj.x + 6, coordObj.y, prem.playhead) {
			block.On()
			SendInput(KSA.selectionPrem)
			MouseMove(xcol, ycol)
			SendInput("{LButton Down}")
			block.Off()
			this.colourOrNorm := "colour"
		}
	}

	/**
	 * This function checks to see whether the user simply tapped the activation hotkey and moves the playhead
	 * @param {String} activationHotkey the keyname for the activation hotkey. should be `A_ThisHotkey`
	 * @returns {Boolean} if the user is no longer holding the `RButton`, returns `false`. Else return `true`
	 */
	__checkForTap(activationHotkey) {
		;// this block will allow you to still tap the activation hotkey and have it move the cursor
		if !GetKeyState(activationHotkey, "P") {
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
	__resetClicks() => (this.leftClick := false, this.xbuttonClick := false, this.colourOrNorm := "", this.colour := "", this.colour2 := "", prem.RClickIsActive := false)

	/** A functon to define what should happen anytime the class is closed */
	__exit() {
		try (this.lh != false) ? this.lh.Stop() : ""
		try (this.xh != false) ? this.xh.Stop() : ""
		this.__resetClicks()
		checkstuck()
		Exit()
	}

	/**
	 * This is the class method intended to be called by the user, it handles moving the playhead to the cursor when `RButton` is pressed.
	 * This function has built in checks for `LButton` & `XButton2` - check the wiki for more details
	 * @param {Boolean} [allChecks=true] determines whether the user wishes for the function to make the necessary checks to determine if the cursor is hovering an empty track on the timeline. Setting this value to false allows the function to move the playhead regardless of where on the timeline the cursor is situated. It is not recommended to use this value if your activation hotkey is something like `RButton` as that removes the ability for the keys native function to operate
	 */
	movePlayhead(allChecks := true) {
		;// ensure the main prem window is active before attempting to fire
		getTitle := WinGet.PremName()
		if WingetTitle("A") != gettitle.winTitle {
			SendInput("{Rbutton}")
			return
		}

		InstallMouseHook(1)
		prem.RClickIsActive := true

		;// check for stuck keys
		if GetKeyState("Ctrl") || GetKeyState("Shift") {
			checkstuck()
		}

		;// set coord mode and grab the cursor position
		coord.client()
		origMouse := obj.MousePos()

		;// set what `LButton` & `XButton2` do
		this.lh := MouseHook("LButton Down", (obj, *) => (this.leftClick := true, obj.stop()))
		this.xh := MouseHook("XButton2 Down", (obj, *) => (this.leftClick := true, this.xbuttonClick := true, obj.Stop()))
		this.lh.Start(), this.xh.Start()

		;// checks to see whether the timeline position has been located
		if !prem.__checkTimeline() {
			SendInput("{Rbutton}")
			this.__exit()
		}

		;// checks the coordinates of the mouse against the coordinates of the timeline to ensure the function
		;// only continues if the cursor is within the timeline
		if !prem.__checkCoords(origMouse) {
			SendInput("{Rbutton}")
			this.__exit()
		}

		if allChecks = true {
			;// checks the colour at the mouse cursor and then determines whether the track is blank
			this.__setColours(origMouse)
			if this.__checkForBlank(this.colour) {
				SendInput("{ESC}") ;in Premiere 13.0+, ESCAPE will now deselect clips on the timeline, in addition to its other uses. But you can swap this out with the hotkey for "DESELECT ALL" within premiere if you'd like.
				this.__exit()
			}

			;// checks to see if the colour under the cursor is one already defined within the class
			if !this.__checkColour(this.colour) {
				this.__exit()
			}
		}

		;// check whether the timeline is already in focus & focuses it if it isn't
		prem.__checkTimelineFocus()

		;// determines the position of the playhead
		if this.colour = prem.playhead {
			if !this.__checkUnderCursor(this.colour2) {
				this.__exit()
			}
		}
		this.__checkForPlayhead(origMouse, allChecks)
		if !this.__checkForTap(A_ThisHotkey) {
			this.__exit()
		}

		;// the main loop that will continuously move the playhead to the cursor while RButton is held down
		while GetKeyState(A_ThisHotkey, "P") {
			if (GetKeyState("Ctrl") || GetKeyState("Ctrl", "P")) || GetKeyState("Shift") {
				if allChecks = true
					checkstuck()
				else
					checkStuck(["XButton2", "Ctrl", "Shift"])
				if GetKeyState("Ctrl", "P") { ;you still want to be able to hold shift so you can cut all tracks on the timeline
					tool.Cust("Holding control while scrubbing will cause Premiere to freak out")
					break
				}
			}
			if this.colourOrNorm != "colour"
				SendInput(ksa.playheadtoCursor)
			sleep 16
		}

		;// releases the LButton if it was used to grab the playhead
		if this.colourOrNorm = "colour" {
			SendInput("{LButton Up}")
		}

		if allChecks = true {
			;// resets `LButton` & `XButton2` to their original function
			PremHotkeys.__HotkeyReset(["LButton", "XButton2"])
			;// determines whether to resume playback & how fast to playback
			if !this.leftClick && !this.xbuttonClick {
				this.__exit()
			}
			if this.leftClick
				this.__restartPlayback()
		}

		;// cleans up
		this.__exit()
	}

	__Delete() {
		this.__exit()
	}
}