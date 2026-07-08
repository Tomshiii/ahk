; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\Editors\Premiere_UIA.ahk
#Include Classes\keys.ahk
#Include Classes\winget.ahk
#Include Classes\notifyExt.ahk
#Include Functions\isDoubleClick.ahk
#Include Functions\delaySI.ahk
; }

isIn(title, ahk_exe?) {
	try getTitle := WinGet.Title()
	catch {
		return false
	}
	exe := (IsSet(ahk_exe) ? A_Space ahk_exe : "")
	return InStr(getTitle exe, title)
}

;// this hotkey is an attempt to stop inputs being sent through to premiere while waiting for excalibur to pop up
/* $^Space::
{
	spellbookExcalFile := A_AppData "\SpellBook\knights_of_the_editing_table.excalibur.json"
	checkRemote := prem.__checkPremRemoteDir('isSelected')
	checkExcal  := prem.Excalibur.__isInstalled()
	checkSpell  := FileExist(spellbookExcalFile)
	if !checkRemote || !checkExcal || !checkSpell {
		notifyExt.showIfNotExist("remoteOrExcalNotExist",, 'PremiereRemote and Excalibur are required for this hotkey to function. `nEither install them or disable this hotkey here;`n' A_linefile,, 'Windows Battery Critical',, 'bdr=Red maxW=400')
		return
	}
	block.On()
	arr := getHotkeysArr()
	readSpell := JSON.parse(FileRead(spellbookExcalFile))
	activationKeys := readSpell["commands"]["excalibur.open"]["shortcut"]
	if activationKeys["key"] != GetKeyName(arr[-1]) && activationKeys["ctrl"] != true {
		block.Off()
		return
	}
	keys.allWait()
	SendInput("{Blind}^{Space}")
	if !WinWait("ahk_class PLUGPLUG_UI_NATIVE_WINDOW_CLASS_NAME",, 2) {
		block.Off()
		return
	}
	sleep 250
	block.Off()
} */

LCtrl & Tab::
Shift & Tab::
$Tab::
{
	titles := "Audio Gain " prem.winTitle "|"
	switch {
		case isIn("Modify Clip", prem.winTitle):
			(GetKeyState("LCtrl", "P") = true) ? prem.swapChannels(1) : prem.swapChannels(1, 16, ksa.labelPurple)
			KeyWait("LCtrl")
			return
		case isIn("Clip Fx Editor"), isIn("Track Fx Editor"):
			SendInput("{Tab}")
			return
		case winExt.ExistRegex(titles):
			sendMod := (GetKeyState("Shift", "P") || GetKeyState("Shift")) ? "+" : ""
			SendInput(sendMod "{Tab}")
			return
		case CaretGetPos(&x, &y):
			/* if !isDoubleClick()
				return */
			sendMod := (GetKeyState("Shift", "P") || GetKeyState("Shift")) ? "+" : ""
			SendInput(sendMod "{Tab}")
			return
	}
	try {
		if !premUIA := premUIA_Values.initialise()
			return
		if premUIA.__isUiaElementActive("effectControls", premUIA) = true {
			sendMod := (GetKeyState("Shift", "P")) ? "+" : ""
			SendInput(sendMod "{Tab}")
			return
		}
	}
	prem.swapPreviousSequence()
}

Space:: ;// make space more useful by closing certain windows
{
	switch {
		case isIn("Modify Clip"), isIn("Audio Gain"), isIn("Delete Tracks"):
			SendInput("{Enter}")
			return
		case isIn("Save Project"):
			if !CaretGetPos(&x, &y)
				return
			SendInput("{Space}")
			return
		case isIn("Clip Fx Editor - DeNoise"):
			SendInput("{Enter}")
			if IsSet(A_PriorKey) && isDoubleClick(750, "key")
				prem.escFxMenu()
			return
		case isIn("Color Picker"), isIn("Add Tracks"):
			if !CaretGetPos(&x, &y) {
				SendInput("{Enter}")
				return
			}
	}
	if GetKeyState("CapsLock") || GetKeyState("CapsLock", "P") {
		if !prem.selectTool("selectionTool")
			return
		prem.__focusTimeline()
		sleep 50
		SendInput("{Space}")
		SetCapsLockState('AlwaysOff')
		return
	}
	timelineStatus := prem.timelineFocusStatus()
	if !timelineStatus || CaretGetPos(&x, &y) {
		SendInput("{Space}")
		return
	}
	prem.delayPlayback()
}

NumpadEnter::
Enter:: ;// close windows by double tapping enter
{
	titles := "Audio Gain " prem.winTitle "|"
	switch {
		case isIn("Clip Fx Editor"), isIn("Track Fx Editor"):
			delaySI(75, "{Tab}", "+{Tab}") ;// ensures the enter doesn't toggle enable/disabling
			if IsSet(A_PriorKey) && isDoubleClick(750, "key")
				prem.escFxMenu()
			return
		case (WinGet.Title() == "Save Project"): return
		case WinExist("ahk_class PLUGPLUG_UI_NATIVE_WINDOW_CLASS_NAME"):
			try class := WinGetClass("A")
			if (IsSet(class) && class ~= "^\{?[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\}?$") {
				SendInput("{" A_ThisHotkey "}")
				return
			}
		case winExt.ExistRegex(titles):
			SendInput("{" A_ThisHotkey "}")
			return
		default:
			;// if I'm typing and I hit enter I want typing to be finished
			;// ie. the text box is deselected and the text tool is swapped back to the selection tool
			if !premUIA := premUIA_Values.initialise() {
				SendInput("{" A_ThisHotkey "}")
            	return
			}
			if prem.timelineVals = false {
				prem.__setTimelineValues()
				return
			}
			currTimelineStatus := prem.timelineFocusStatus()
			activePath := premUIA.__activeElementPath(, premUIA)
            textStatus := premUIA.isToolSelected("textTool", premUIA)
			switch {
				case (InStr(activePath, premUIA.UIA_Path["programMonitor"]) != 1):
					SendInput("{" A_ThisHotkey "}")
					return
				case (currTimelineStatus != true && (InStr(activePath, premUIA.UIA_Path["programMonitor"]) = 1) && textStatus = true):
					if !GetKeyState("Shift") && !GetKeyState("Shift", "P") { ;// this check shouldn't be necessary but.. just incase
						SendInput("{Escape}")
						prem.selectTool("selectionTool")
						sleep 50
						prem.__focusTimeline()
						return
					}
					SendInput("{Blind}{" A_ThisHotkey "}")
					return
				default:
					SendInput("{" A_ThisHotkey "}")
					return
			}
	}
}

*`:: ;// make ` key more useful in different scenarios
{
	switch {
		case isIn("Modify Clip"), isIn("Audio Gain"), isIn("Delete Tracks"), isIn("Clip Fx Editor - DeNoise"), isIn("Clip Fx Editor"), isIn("Track Fx Editor"), isIn("Color Picker"), isIn("Add Tracks"):
			(GetKeyState("LWin", "P") = true) ? SendInput("-")  : SendInput("{BackSpace}")
			return
		case (GetKeyState("Ctrl") || GetKeyState("Shift")):
			ctrl := (GetKeyState("Ctrl") != false) ? "^" : ""
			shft := (GetKeyState("Shift") != false) ? "+" : ""
			SendInput(ctrl shft "``")
			return
		default:
			KeyWait("``")
			SendInput("{``}")

			return
	}
}

;// left hand gain adjust
` & 1::
` & 2::
` & 3::
` & 4::
` & 5::
` & 6::
` & 7::
` & 8::
` & 9::prem.gain(SubStr(A_ThisHotkey, -1, 1))
<#1::
<#2::
<#3::
<#4::
<#5::
<#6::
<#7::
<#8::
<#9::prem.gain("-" SubStr(A_ThisHotkey, -1, 1))



NumpadDot::NumpadDot
NumpadDot & NumpadSub::BackSpace

Escape::prem.escFxMenu()

SC03A & v::prem.selectTool("selectionTool")

^!x::prem.rippleCut()

SC03A & d::prem.disableDirectManip()
SC03A & LButton:: ;// lock vertical movement while adjusting keyframe handles
{
	SetDefaultMouseSpeed(0)
	SetStoreCapsLockMode(true)
	InstallKeybdHook(true)
	storeHotkey := A_ThisHotkey
	capslockState := GetKeyState("CapsLock", "T")
	__resetCaps(storekey, capslockState) {
		if (InStr(storeHotkey, "CapsLock") || InStr(storeHotkey, "sc03a")) && !capslockState
			SetCapsLockState('AlwaysOff')
	}
	; InstallMouseHook()
	coord.c()
	origCoord := obj.MousePos()
	if !premUIA := premUIA_Values.initialise()
		return

	if !premUIA.__isUiaElementActive("effectControls", premUIA) {
		__resetCaps(storeHotkey, capslockState)
		return
	}
	blocker := block_ext()
	blocker.On()
	if GetKeyState("LButton") || GetKeyState("LButton", "P")
		SendInput("{LButton Up}")
	MouseMove(origCoord.x, origCoord.y)
	SendInput("{LButton Down}")
	blocker.Off()
	move.clipMouse("x", true)
	KeyWait("vk14", "L")
	if GetKeyState("LButton") || GetKeyState("LButton", "P")
		SendInput("{LButton Up}")
	move.setMouseClip()
	__resetCaps(storeHotkey, capslockState)
	checkStuck(["CapsLock", "LButton"])
}

^!1::prem.disableAllMuteSolo("mute")
^!2::prem.disableAllMuteSolo("solo")

<^1::prem.toggleLayerButtons("mute")
<^2::prem.toggleLayerButtons("solo")
<^3::prem.toggleLayerButtons("target")
<^4::prem.toggleLayerButtons("lock")

>!1::prem.soloVideo()
>!2::prem.soloVideo("disable")

q::
w::prem.rippleTrim()

F12::prem.thumbScroll()

F5::prem.reset()

NumpadSub::
NumpadAdd::prem.numpadGain()

$+c:: ;// stop playback before ripple deleting as it can go funky in laggy comps
{
	if prem.timelineVals = false {
		prem.__setTimelineValues()
		return
	}
	if !prem.timelineFocusStatus() || CaretGetPos(&carx, &cary) {
		SendInput("+c")
		return
	}
	prem.stopPlayback()
	sleep 30
	SendInput(ksa.premRippleDelete)
	return
}

$+1::
$+2::prem.zoomPreviewWindow(A_ThisHotkey)
$+3::prem.zoomPreviewWindow("+3", true)

^!f::prem.flattenAndColour(ksa.labelIris)
$+d:: ;// deselect edit points after adding transitions
{
	if prem.timelineVals = false {
		prem.__setTimelineValues()
		return
	}
	if !prem.timelineFocusStatus() || CaretGetPos(&carx, &cary) {
		SendInput("+d")
		return
	}
	delaySI(16, "+d", "{Escape}")
	return
}

!w::prem.closeActiveSequence() ;// ~~didn't realise `Application > File > Close` did this natively lol~~ ahh it closes any active panel that's why. ew
!+w::prem.closeActiveSequence(true)

;// this unfortunately causes tonnes of slowdown/lag on chunky timelines :( - I can only assume it's fighting with `__setCurrSeq()` as well
/* $+x:: ;// stop keyframes getting added to all tracks (I never need that, it's super annoying)
$s:: ;// stop "add edit" adding an edit to all tracks when nothing is selected (I have +s for that, fuck off)
{
	if !prem.__checkPremRemoteDir('isSelected') {
		errorLog(MethodError("PremiereRemote is required for this hotkey"),,, true)
		return
	}
	switch {
		case (prem.timelineFocusStatus() != true || CaretGetPos(&carx, &cary)):
			SendInput(SubStr(A_ThisHotkey, 2))
			return
		case (!prem.__remoteFunc('isSelected', true)): return

		default: SendInput(SubStr(A_ThisHotkey, 2))
	}
} */

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------

F20::prem.dragSourceMon("video", "{F20}")
F19::prem.dragSourceMon(, "{F19}", "_Assets/01_Other/Bars and Tone - Rec 709", true)
F14 & F19::prem.dragSourceMon(, "")

;// playback speed change hotkeys
F14 & F21::SendInput(KSA.slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
F14 & F23::
{
	delaySI(16, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement) ;alternate way to speed up playback on the timeline with mouse buttons
	keys.allWait()
}
;// next/previous frame hotkeys
<+F21::prem.wheelEditPoint(KSA.effectControls, KSA.prempreviousKeyframe, 2, true) ;goes to the next keyframe point towards the left
<+F23::prem.wheelEditPoint(KSA.effectControls, KSA.premnextKeyframe, 2, true) ;goes to the next keyframe towards the right

<!F21::prem.wheelEditPoint(ksa.timelineWindow, ksa.selectedClipStart, 2, true, "{LAlt}{F21}")
<!F23::prem.wheelEditPoint(ksa.timelineWindow, ksa.selectedClipEnd, 2, true, "{LAlt}{F23}")
;// next/previous edit point hotkeys
F21::prem.wheelEditPoint(KSA.timelineWindow, KSA.previousEditPoint,, true) ;goes to the next edit point towards the left
F23::prem.wheelEditPoint(KSA.timelineWindow, KSA.nextEditPoint,, true) ;goes to the next edit point towards the right

;// mousedrag hotkeys
*XButton2::prem.mousedrag(KSA.handPrem, KSA.selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts


/* <!WheelUp::
<!WheelDown:: */
<+WheelUp::
<+WheelDown::prem.accelScroll(5, 25)
;// the below needs to be above^ or the below will not fire instantly
LAlt & SC03A::prem.layerSizeAdjust()
LAlt & MButton::prem.layerSizeAdjust(, true)


;// allExcept
^!+`::prem.toggleEnabled(1, "aud",, "all", "settings")
<!+`::prem.toggleEnabled(1, "aud", 1, "all", "settings")
<!+1::
<!+2::
<!+3::
<!+4::
<!+5::
<!+6::
<!+7::
<!+8::
<!+9::prem.toggleEnabled(, "aud", 1, true, "settings")

<!c::prem.__remoteFunc('closeClipSourceMon')
<!+c::prem.__remoteFunc('closeAllClipSourceMon')

!e::prem.__remoteFunc('setAllEnableDisabled',, "enabled=true")
!d::prem.__remoteFunc('setAllEnableDisabled',, "enabled=false")

;// while cursor is within timeline;
; use MButton to Ctrl click (adjust edit points with mouse if left hand isn't on keyboard)
;// while cursor is within program monitor;
; ensure that panning activates even if immediately after a `WheelUp`/`WheelDown` (prem force delays you after a scroll)
~MButton::
{
	try (chkVar := GetKeyState(A_ThisHotkey), chkVar := GetKeyState(A_ThisHotkey, "P"))
	catch {
		return
	}
	if InStr(A_ThisHotkey, "F14")
		return

	__cleanup() => (checkStuck(["Ctrl", "MButton", "LButton", "WheelUp", "WheelDown"]), prem.MButtonPanning := false)
	if prem.MButtonPanning = true {
		__cleanup()
		return
	}
	prem.MButtonPanning := true

	;// ensure the main prem window is active before attempting to fire
	getTitle := WinGet.PremName()
	if !getTitle || !IsObject(getTitle) || !gettitle.winTitle || WinGet.Title() != gettitle.winTitle {
		KeyWait(A_ThisHotkey)
		__cleanup()
		return
	}


	;// checks to see whether the timeline position has been located
	if !prem.__setTimelineValues() {
		KeyWait(A_ThisHotkey)
		__cleanup()
		return
	}

	;// set coord mode and grab the cursor position
	coord.s()
	if !origMouse := obj.MousePos() {
		KeyWait(A_ThisHotkey)
		__cleanup()
		return
	}
	prior := false
	if A_PriorKey = "WheelUp" || A_PriorKey = "WheelDown" {
		__within(coordObj, progmon) {
			if ((coordObj.x > progmon.location.x) && (coordObj.x < progmon.location.x+progmon.location.w) && (coordObj.y < progmon.location.y) && (coordObj.y > progmon.location.y+progmon.location.h))
				return false
			return true
		}
		if !premUIA := premUIA_Values.initialise() {
			KeyWait(A_ThisHotkey)
			__cleanup()
			return
		}
		progmon := premUIA.UIA_Objs["programMonitor"]
		if __within(origMouse, progmon) {
			if A_Cursor != "Unknown" {
				block.On()
				tool.Cust("Waiting for Premiere to enable panning...",,,, 12)
				while (A_Cursor != "Unknown" && GetKeyState("MButton", "P") = true) {
					delaySI(25, "{MButton Up}", "{MButton Down}")
				}
				block.Off()
				tool.Cust("",,,, 12)
			}
			prior := true
		}
	}

	;// checks the coordinates of the mouse against the coordinates of the timeline to ensure the function
	;// only continues if the cursor is within the timeline
	if !prem.__checkCoords(origMouse) {
		KeyWait(A_ThisHotkey)
		__cleanup()
		return
	}
	getCol := PixelGetColor(origMouse.x, origMouse.y)
	switch getCol {
		case prem.keyframeGrey, prem.keyframeBlue:
			delaySI(16, "{LButton Down}", "{Ctrl Down}")
			KeyWait(A_ThisHotkey)
			delaySI(16, "{LButton Up}", "{Ctrl Up}")
			__cleanup()
		default:
			SendInput("{Ctrl Down}{LButton Down}")
			KeyWait(A_ThisHotkey)
			SendInput("{LButton Up}{Ctrl Up}")
			__cleanup()
	}
}

__f14InitialChecks(Key, &kwait) {
	currKeys := getHotkeysArr()
	kwait := currKeys[1]
	if !IsSet(kwait)
		return false
	if GetKeyName(currKeys[1]) != "F14" {
		KeyWait(currKeys[1])
		__cleanup()
		return false
	}
	__cleanup() => (checkStuck(["Ctrl", Key]))
	;// ensure the main prem window is active before attempting to fire
	getTitle := WinGet.PremName()
	if !getTitle || !IsObject(getTitle) || !gettitle.winTitle || WinGet.Title() != gettitle.winTitle {
		KeyWait(currKeys[1])
		__cleanup()
		return false
	}

	;// checks to see whether the timeline position has been located
	if prem.timelineVals = false {
		prem.__setTimelineValues()
		return
	}
	ckValues := prem.__setTimelineValues()
	ckFocus  := prem.timelineFocusStatus()
	if !ckValues || (ckFocus != true) {
		KeyWait(currKeys[1])
		__cleanup()
		return false
	}

	;// set coord mode and grab the cursor position
	coord.s()
	origMouse := obj.MousePos()
	if !origMouse || !prem.__checkCoords(origMouse) {
		KeyWait(currKeys[1])
		__cleanup()
		return false
	}
	return true
}
F14 & MButton::
{
	if !__f14InitialChecks("MButton", &kwait)
		return
	ckDir := prem.__checkPremRemoteDir('isSelected'), ckEnabled := prem.__checkPremRemoteFunc('toggleEnabled')
	if !ckDir || !ckEnabled
		return
	if !prem.__remoteFunc('isSelected', true) {
		tool.Cust("nothing is selected")
		KeyWait(kwait)
		return
	}
	prem.__remoteFunc('toggleEnabled')
}
F14 & LButton::
{
	if !__f14InitialChecks("LButton", &kwait)
		return
	delaySI(16, "{LButton Down}", "{Ctrl Down}")
	KeyWait(kwait)
	delaySI(16, "{LButton Up}", "{Ctrl Up}")
}
F14 & F18::
{
	checkRemote := prem.__checkPremRemoteDir('setMarker')
	initChecks := __f14InitialChecks("F18", &kwait)
	if !checkRemote || !initChecks
		return
	KeyWait(kwait)
	prem.__remoteFunc('setMarker',, "colour=0")
}

WheelUp::
WheelDown::
{
	if prem.MButtonPanning = true {
		checkStuck(["Ctrl", "MButton", "LButton", "WheelUp", "WheelDown"])
		return
	}
	SendInput("{" A_ThisHotkey "}")
}

/** trim script alerts */
~^c::
{
	if !WinActive("ahk_exe Adobe Premiere Pro.exe")
    	return
	sleep 25
	clip.__scriptSplit(A_Clipboard)
}

^!a::prem.__remoteFunc('setAllEnableDisabled',, "enabled=true")
^!d::prem.__remoteFunc('setAllEnableDisabled',, "enabled=false")