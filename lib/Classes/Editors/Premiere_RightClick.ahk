/************************************************************************
 * @description move the Premere Pro playhead to the cursor
 * Originally designed for v22.3.1 of Premiere. As of 2023/10/13 moved workflow to v24+
 * Any code after that date is no longer guaranteed to function on previous versions of Premiere.
 * @premVer 25.0
 * @author tomshi, taranVH
 * @date 2025/05/06
 * @version 2.3.15
 ***********************************************************************/
; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\errorLog>
#Include <Classes\Editors\Premiere>
#Include <Classes\Editors\Premiere_UIA>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\keys>
#Include <Classes\obj>
#Include <Classes\winGet>
#Include <Other\WinEvent>
#Include <Other\Notify\Notify>
#Include <Functions\checkStuck>
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

You must also set the correct version of premiere within `settingsGUI()` to ensure the function attempts to account for the correct UI
;
RUNNING THIS SCRIPT SEPARATELY WHILE OTHER HOTKEYS ARE SET USING THE SAME KEYS AS THIS SCRIPT MAY RESULT IN UNEXPECTED BEHAVIOUR
TRY RUNNING THIS SCRIPT ALONGSIDE THOSE OTHER HOTKEYS (similarly to how I run this script from within `My Scripts.ahk`) TO ATTEMPT
TO ESCAPE THIS ODD AHK QUIRK

I've tried using sendevent instead of sendinput in this script multiple times but the simple fact is that sendevent is just too slow and using it means that attempting to right click and then almost immediately leftclick/xbutton click results in no input being registered.
There's probably some dumb hacky way to work around that but ultimately it's just not worth it. I see little to no benefit from using sendevent.
-Tomshi
*/
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;NOTE: This does not, and cannot work on the timeline where there are no tracks visible.
;Explanation: https://twitter.com/boxrNathan/status/927371468371103745

;---------------------------------------------------------------------------------------

;// there may be code that EXPECTS the activation hotkey to be RButton
RButton::rbuttonPrem().movePlayhead(,, prem.currentSetVer)

;// there is code that EXPECTS the activation hotkey to be XButton1
;// including uses of `checkStuck()`
;// beware if modifying this activation hotkey that code adjustments might be necessary
XButton1::rbuttonPrem().movePlayhead(false,, prem.currentSetVer)

;// a list of colours required for each UI version/theme of premiere I've encountered.
;// I only use the darkest themes, if you use a different theme you'll need to fill out your own and change the variable within `movePlayhead()`
class timelineColours {
	static Spectrum := {
		darkest: [
			"timeline1",  0x3C3C3C, ;timeline colour inbetween two clips inside the in/out points ON a targeted track
			"timeline2",  0x303030, ;timeline colour of the separating LINES between targeted AND non targeted tracks inside the in/out points
			"timeline3",  0x191919, ;the timeline colour inside in/out points on a UNTARGETED track
			"timeline11", 0x3B3B3B, ;the timeline colour inside in/out points on a TARGETED track (v24.5+)
			"timeline12", 0x3E3E3E, ;the timeline colour inside in/out points on a TARGETED track (additional)
			"timeline13", 0x3D3D3D, ;the timeline colour inside in/out points on a TARGETED track (additional)
			"timeline14", 0x3F3F3F, ;the timeline colour inside in/out points on a TARGETED track (additional)
			"timeline4",  0x1D1D1D, ;the colour of the bare timeline NOT inside the in out points (above any tracks)
			"timeline8",  0x202020, ;the colour of the bare timeline NOT inside the in out points (v22.3.1+)
			"timeline9",  0x1C1C1C, ;the colour of the bare timeline NOT inside the in out points (v23.1+)
			"timeline10", 0x1D1D1D, ;the colour of the bare timeline NOT inside the in out points (v23.4+) (above any tracks)
			"timeline5",  0xE2E2E2, ;the colour of a SELECTED blank space on the timeline, NOT in the in/out points
			"timeline6",  0xE7E7E7, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
			"timeline7",  0xC1C1C1, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
		]
	}

	static oldUI := {
		darkest: [
			"timeline1",  0x414141, ;timeline colour inbetween two clips inside the in/out points ON a targeted track
			"timeline2",  0x313131, ;timeline colour of the separating LINES between targeted AND non targeted tracks inside the in/out points
			"timeline3",  0x1b1b1b, ;the timeline colour inside in/out points on a UNTARGETED track
			"timeline11", 0x424242, ;the timeline colour inside in/out points on a TARGETED track (v23-24.4)
			"timeline12", 0x424242, ;the timeline colour inside in/out points on a TARGETED track (additional) (not needed for old UI)
			"timeline13", 0x424242, ;the timeline colour inside in/out points on a TARGETED track (additional) (not needed for old UI)
			"timeline14", 0x424242, ;the timeline colour inside in/out points on a TARGETED track (additional) (not needed for old UI)
			"timeline4",  0x212121, ;the colour of the bare timeline NOT inside the in out points (above any tracks)
			"timeline8",  0x202020, ;the colour of the bare timeline NOT inside the in out points (v22.3.1+)
			"timeline9",  0x1C1C1C, ;the colour of the bare timeline NOT inside the in out points (v23.1+)
			"timeline10", 0x1D1D1D, ;the colour of the bare timeline NOT inside the in out points (v23.4+) (above any tracks)
			"timeline5",  0xDFDFDF, ;the colour of a SELECTED blank space on the timeline, NOT in the in/out points
			"timeline6",  0xE4E4E4, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
			"timeline7",  0xBEBEBE, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
		]
	}
}

class rbuttonPrem {
	leftClick    := false
	xbuttonClick := false
	colourOrNorm := ""
	colour  := ""
	colour2 := ""

	sendHotkey := "{" A_ThisHotkey "}"

	premUIA := false
	origSeq := ""
	remote  := true

	timelineCol := []

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
				SendInput(this.sendHotkey) ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were met.
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
			colour != this.timelineCol[11] && colour != this.timelineCol[12] &&
			colour != this.timelineCol[13] && colour != this.timelineCol[14]
		) {
			SendInput(this.sendHotkey)
			return false
		}
		return true
	}

	/**
	 * Checks to see whether the playhead can be found on the screen. If it is, `KSA.shuttleStop` is sent.
	 * If the playhead is close to the cursor, the cursor will be moved to it and `LButton` is held down
	 * @param {Object} coordObj an object containing the cursor coords
	 * @param {Boolean} [search=true] passing in `allChecks` to determine if the function should search near the cursor for the playhead. Disabling this feature if `allChecks` is set to `false` stops the script from potentially clicking on a clip below the cursor
	 */
	__checkForPlayhead(coordObj, search := true) {
		;// checking to see if the playhead is on the screen
		if !prem.searchPlayhead({x1: prem.timelineXValue, y1: coordObj.y, x2: prem.timelineXControl, y2: coordObj.y}) {
			SendInput(KSA.playheadtoCursor)
			return
		}
		SendInput(KSA.shuttleStop) ;if it is on screen, we input a shuttle stop

		;// this stops the script from potentially clicking a clip if using `rbuttonPrem().movePlayhead(false)`
		if !search {
			SendInput(KSA.playheadtoCursor)
			return
		}

		;// then we check to see if it's relatively close to the cursors position
		if PixelSearch(&xcol, &ycol, coordObj.x - 4, coordObj.y, coordObj.x + 6, coordObj.y, prem.playhead) {
			block.On()
			SendInput(KSA.selectionPrem)
			MouseMove(xcol, ycol)
			SendInput("{LButton Down}")
			block.Off()
			this.colourOrNorm := "colour"

			SetTimer(checktap, -50)
			checktap() {
				if !this.__checkForTap(A_ThisHotkey) {
					SendInput("{LButton Up}")
					Exit()
				}
			}
		}
	}

	/**
	 * This function checks to see whether the user simply tapped the activation
	 * @param {String} activationHotkey the keyname for the activation hotkey. should be `A_ThisHotkey`
	 * @returns {Boolean} if the user is no longer holding the activation hotkey, returns `false`. Else return `true`
	 */
	__checkForTap(activationHotkey) {
		;// this block will allow you to still tap the activation hotkey and have it move the cursor
		if !GetKeyState(activationHotkey, "P") && !GetKeyState(activationHotkey)
			return false
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
	__resetClicks() => (this.leftClick := false, this.xbuttonClick := false, this.colourOrNorm := "", this.colour := "", this.colour2 := "", prem.RClickIsActive := false, this.origSeq := "", this.remote = true)

	/** A functon to define what should happen anytime the class is closed */
	__exit() {
		PremHotkeys.__HotkeyReset(["LButton", "XButton2"])
		this.__resetClicks()
		try WinEvent.Stop()
		checkstuck()
		try SetTimer(this.__ensureSeq, 0)
		Exit()
	}

	/**
	 * Defines what happens when certain buttons are pressed while RButton is held down
	 * @param {Array} arr all keys you wish to assign a function
	 */
	__HotkeySet(arr) {
		PremHotkeys.__HotkeySet(arr, __set)
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

	/**
	 * This function checks to ensure the active sequence hasn't changed since the beginning of the `movePlayhead()` function.
	 * ### Warning; making check amount more than 1 can make it hard to traverse premiere. Ie you let go of right click then immediately open a nested sequence, if you check too many times or `timeWait` is too high, you'll just get instantly kicked back to the original sequence, basically achieving the exact opposite of the functions intention
	 * @param {String} origSequence the ID of the original active sequence
	 * @param {Integer} [checkAmount=1] the amount of times you'd like the function to check if the sequence has changed
	 * @param {Integer} [timeWait=1000] the amount in `ms` of time you'd like the function to wait before rechecking to see if the active sequence has changed.
	 */
	__ensureSeq(origSequence, checkAmount := 1, timeWait := 1000, *) {
		static count := 1
		currentSeq := prem.__remoteFunc("getActiveSequence", true)
		if currentSeq != origSequence {
			prem.__remoteFunc("focusSequence",, "ID=" origSequence)
			return
		}

		count++
		if count > checkAmount {
			count := 1
			SetTimer(, 0)
			return
		}
		else
			SetTimer(, -timeWait)
	}

	/**
	 * Set internal colour variables based on the version of Premiere Pro the user currently has set within `settingsGUI()`
	 * @param {String} UI which UI version should be used. Currently accepts `Spectrum` & `oldUI`
	 * @param {String} theme which theme the user wishes to use. Currently accepts `darkest`
	 */
	__setTimelineCol(UI, theme) {
		for k, v in timelineColours.%UI%.%theme% {
			if Mod(A_Index, 2) != 0
				continue
			varName := timelineColours.%UI%.%theme%[k-1]
			this.timelineCol.Push(Format("0x{:x}", v))
		}
	}

	/**
	 * This is the class method intended to be called by the user, it handles moving the playhead to the cursor when an activation key is pressed (mainly designed for <kbd>RButton</kbd> & <kbd>XButton1</kbd>).
	 * This function has built in checks for <kbd>LButton</kbd> & <kbd>XButton2</kbd> during activation - check the wiki for more details.
	 * This function should work as intended on both the old UI and the Spectrum UI assuming you use the default darkest themeing for both UI versions. Other themes will require the user to add additional colour values to `timelineColours {`
	 *
	 * #### This function has code to exit early in the event that `A_ThisHotkey` gets set to something with `&` in it. If you want to do this on purpose, you will need to remove that block of code.
	 * @param {Boolean} [allChecks=true] determines whether the user wishes for the function to make the necessary checks to determine if the cursor is hovering an empty track on the timeline. Setting this value to false allows the function to move the playhead regardless of where on the timeline the cursor is situated. It is not recommended to use this value if your activation hotkey is something like <kbd>RButton</kbd> as that removes the ability for the keys native function to operate
	 * @param {String} [theme="darkest"] the desired theme the user uses and wishes to use for the required colour values. Currently only "darkest" has mapped values
	 * @param {String} [version=unset] the currently selected version of premiere within `settingsGUI()`. This parameter can usually be filled in using `prem.currentSetVer`
	 * @param {String} [sendOnFailure=unset] what you wish for the script to send in the event that it needs to fallback. What you set for this parameter will be sent to `SendInput()`. If left unset, sends `"{" A_ThisHotkey "}"`
	 */
	movePlayhead(allChecks := true, theme := "darkest", version := unset, sendOnFailure := unset) {
		if !IsSet(version) {
			;// throw
			errorLog(UnsetError("User has not set Paramater #2"),,, true)
		}
		;// sometimes ahk can be a bit slow off the mark if the user clicks multiple buttons at the same time
		;// as their activation hotkey (and those other buttons are setup with other functions)
		;// which can cause A_ThisHotkey to become something else other than RButton (ie. F14 & F23)
		;// If this happens, some code later on will throw because GetKeyState doesn't know how to handle
		;// a hotkey that has `&` in it
		if InStr(A_ThisHotkey, "&") {
			if IsSet(sendOnFailure)
				SendInput(sendOnFailure)
			return
		}

		if IsSet(sendOnFailure)
			this.sendHotkey := sendOnFailure

		;// setting which UI values to use
		switch {
			case VerCompare(version, prem.spectrumUI_Version) >= 0: this.__setTimelineCol("Spectrum", theme)
			case VerCompare(version, prem.spectrumUI_Version) < 0:  this.__setTimelineCol("oldUI", theme)
		}

		;// ensure the main prem window is active before attempting to fire
		getTitle := WinGet.PremName()
		try {
			if WinGetTitle("A") != gettitle.winTitle {
				SendInput(this.sendHotkey)
				return
			}
		} catch {
			return
		}

		try WinEvent.Exist((*) => (prem.dismissWarning()), "DroverLord - Overlay Window ahk_class DroverLord - Window Class")
		try WinEvent.NotActive((*) => (checkstuck(), Exit()), prem.exeTitle)
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
		this.__HotkeySet(["LButton", "XButton2"])

		;// checks to see whether the timeline position has been located
		if !prem.__checkTimeline() {
			SendInput(this.sendHotkey)
			this.__exit()
		}

		;// checks the coordinates of the mouse against the coordinates of the timeline to ensure the function
		;// only continues if the cursor is within the timeline
		if !prem.__checkCoords(origMouse) {
			SendInput(this.sendHotkey)
			this.__exit()
		}

		;// if the timeline isn't the focused window we send escape just in case - this is useful to stop
		;// a bunch of letters being spammed while typing
		;// unfortunately we can't use UIA to check if the program monitor is the focused window
		;// because setting UIA vals this early can cause a tonne of lag during playback
		if !prem.timelineFocusStatus() {
			SendInput("{Escape}")
			sleep 16
		}

		if allChecks = true {
			;// checks the colour at the mouse cursor and then determines whether the track is blank
			this.__setColours(origMouse)
			if this.__checkForBlank(this.colour) {
				SendInput("{ESC}") ;in Premiere 13.0+, ESCAPE will now deselect clips on the timeline, in addition to its other uses. But you can swap this out with the hotkey for "DESELECT ALL" within premiere if you'd like.
				; this.__exit()
			}

			;// checks to see if the colour under the cursor is one already defined within the class
			if !this.__checkColour(this.colour) {
				this.__exit()
			}
		}

		;// determines the position of the playhead
		if this.colour = prem.playhead {
			if !this.__checkUnderCursor(this.colour2) {
				this.__exit()
			}
		}
		this.__checkForPlayhead(origMouse, allChecks)
		if !this.__checkForTap(A_ThisHotkey) {
			SendInput(KSA.playheadtoCursor)
			this.__exit()
		}

		this.premUIA := premUIA_Values()
		try premEl := prem.__createUIAelement(false)

		;// we send a single input here so that in the event UIA is slow to respond because of premiere
		;// the cursor will still move if the user taps the activation hotkey
		SendInput(ksa.playheadtoCursor)

		;// we use a static varibale here to determine if the server is currently active and track that
		;// if any of the premremote functions return false, it won't continue checking them every time the function is fired
		static useRemote := true
		if useRemote = true {
			if !prem.__checkPremRemoteDir("getActiveSequence") || !prem.__checkPremRemoteFunc("focusSequence") {
				useRemote := false
				this.remote := false
				Notify.Show('Error', 'PremiereRemote has either; not been installed, is missing functions, or the panel within Premiere needs to be reloaded.`nrbuttonPrem().movePlayhead() will no longer attempt to use it until a script reload.', 'C:\Windows\System32\imageres.dll|icon94',,, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')
				this.__exit()
			}
			if this.remote = true
				this.origSeq := prem.__remoteFunc("getActiveSequence", true)
			if this.origSeq = false {
				useRemote := false
				Notify.Show(, 'PremiereRemote server is currently not running correctly.`nTry restarting it using ``resetNPM.ahk``', 'C:\Windows\System32\imageres.dll|icon94',,, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250 MALI=Center')
				this.__exit()
			}
		}

		;// focuses the timeline
		try premEl.AdobeEl.ElementFromPath(this.premUIA.timeline).SetFocus()
		catch {
			prem.__checkTimelineFocus()
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
			sleep 30
		}

		;// releases the LButton if it was used to grab the playhead
		if this.colourOrNorm = "colour" {
			SendInput("{LButton Up}")
		}

		;// checks original sequence is still active
		if this.remote = true && useRemote = true
			SetTimer(this.__ensureSeq.Bind(this, this.origSeq, 1), -1)

		if allChecks = true || (allChecks = false && this.leftClick = true) {
			;// determines whether to resume playback & how fast to playback
			if allChecks = true && !this.leftClick && !this.xbuttonClick {
				this.__exit()
			}
			switch allChecks {
				case true:
					if this.leftClick
						this.__restartPlayback()
				case false:
					if this.leftClick
						SendInput("{LButton}")
			}
			;// resets `LButton` & `XButton2` to their original function
			PremHotkeys.__HotkeyReset(["LButton", "XButton2"])
		}

		;// cleans up
		this.__exit()
	}

	__Delete() {
		try WinEvent.Stop()
		this.__exit()
	}
}