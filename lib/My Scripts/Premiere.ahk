; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Functions\isDoubleClick>
; }

;stopTabHotkey;
LCtrl & Tab::
Shift & Tab::
$Tab::
{
	if WinActive("Modify Clip " prem.winTitle) {
		(GetKeyState("LCtrl", "P") = true) ? prem.swapChannels(1) : prem.swapChannels(1, 16, ksa.labelPurple)
		KeyWait("LCtrl")
		return
	}
	if !isDoubleClick()
		return
	sendMod := (GetKeyState("Shift", "P")) ? "+" : ""
	SendInput(sendMod "{Tab}")
}

;spaceDelayHotkey;
Space::
{
	getTitle := WinGetTitle("A")
	isIn(title) => InStr(getTitle, title)
	switch {
		case isIn("Modify Clip"), isIn("Audio Gain"), isIn("Delete Tracks"):
			SendInput("{Enter}")
			return
		case isIn("Save Project"): return
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
	prem.delayPlayback()
}

NumpadEnter::
Enter::
{
	getTitle := WinGetTitle("A")
	isIn(title) => InStr(getTitle, title)
	switch {
		case isIn("Clip Fx Editor"), isIn("Track Fx Editor"):
			delaySI(75, "{Tab}", "+{Tab}") ;// ensures the enter doesn't toggle enable/disabling
			if IsSet(A_PriorKey) && isDoubleClick(750, "key")
				prem.escFxMenu()
			return
		case getTitle == "Save Project": return
		default:
			SendInput("{" A_ThisHotkey "}")
			return
	}
}

Escape::prem.escFxMenu()

;prem^DeleteHotkey;
; Ctrl & BackSpace::prem.wordBackspace()

;premselecttoolHotkey;
SC03A & v::prem.selectionTool()

!+x::prem.rippleCut()

SC03A & d::prem.disableDirectManip()

LAlt & 1::prem.disableAllMuteSolo("mute")
LAlt & 2::prem.disableAllMuteSolo("solo")

LCtrl & 1::prem.toggleLayerButtons("mute")
LCtrl & 2::prem.toggleLayerButtons("solo")
LCtrl & 3::prem.toggleLayerButtons("lock")
LCtrl & 4::prem.toggleLayerButtons("target")

;premrippleTrimHotkey;
q::
w::prem.rippleTrim()

;thumbScrollHotkey;
F12::prem.thumbScroll()

;premresetHotkey;
F5::prem.reset()

;premnumpadGainHotkey;
NumpadSub::
NumpadAdd::prem.numpadGain()

$+c::
{
	if prem.timelineFocusStatus() != true || !CaretGetPos(&carx, &cary) {
		SendInput("+c")
		return
	}
	delaySI(16, ksa.shuttleStop, ksa.premRippleDelete)
	return
}

$+1::
$+2::prem.zoomPreviewWindow(A_ThisHotkey)
$+3::prem.zoomPreviewWindow("+3", true)

^!f::prem.flattenAndColour(ksa.labelIris)
^!+f::prem.pseudoFS()
$+d::
{
	if prem.timelineFocusStatus() != true {
		SendInput("+d")
		return
	}
	delaySI(16, "+d", "{Escape}")
	return
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;previouspremkeyframeHotkey;
Shift & F21::prem.wheelEditPoint(KSA.effectControls, KSA.prempreviousKeyframe, "second", true) ;goes to the next keyframe point towards the left
;nextpremkeyframeHotkey;
Shift & F23::prem.wheelEditPoint(KSA.effectControls, KSA.premnextKeyframe, "second", true) ;goes to the next keyframe towards the right

F20::prem.dragSourceMon("video", "{F20}")
F19::prem.dragSourceMon(, "{F19}", "Bars and Tone - Rec 709")
F14 & F19::prem.dragSourceMon(, "")

;previouseditHotkey;
F21::prem.wheelEditPoint(KSA.timelineWindow, KSA.previousEditPoint,, true) ;goes to the next edit point towards the left
;nexteditHotkey;
F23::prem.wheelEditPoint(KSA.timelineWindow, KSA.nextEditPoint,, true) ;goes to the next edit point towards the right

;mousedrag1Hotkey;
LAlt & Xbutton2:: ;this is necessary for the below function to work
;mousedrag2Hotkey;
Xbutton2::prem.mousedrag(KSA.handPrem, KSA.selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

;slowDownHotkey;
F14 & F21::SendInput(KSA.slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
;speedUpHotkey;
F14 & F23::
{
	delaySI(16, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement) ;alternate way to speed up playback on the timeline with mouse buttons
	keys.allWait()
}

#MaxThreadsBuffer true
LAlt & SC03A::prem.layerSizeAdjust()
Alt & WheelUp::
Alt & WheelDown::
Shift & WheelUp::
Shift & WheelDown::prem.accelScroll(5, 25)
#MaxThreadsBuffer false