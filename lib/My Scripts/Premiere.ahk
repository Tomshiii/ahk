; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\keys>
#Include <Functions\isDoubleClick>
#Include <Functions\delaySI>
; }

isIn(title) => InStr(WinGetTitle("A"), title)

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

Space::
{
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
	switch {
		case isIn("Clip Fx Editor"), isIn("Track Fx Editor"):
			delaySI(75, "{Tab}", "+{Tab}") ;// ensures the enter doesn't toggle enable/disabling
			if IsSet(A_PriorKey) && isDoubleClick(750, "key")
				prem.escFxMenu()
			return
		case (WinGetTitle("A") == "Save Project"): return
		default:
			SendInput("{" A_ThisHotkey "}")
			return
	}
}

*`::
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
` & 9::prem.gain("-" SubStr(A_ThisHotkey, -1, 1))
<#1::
<#2::
<#3::
<#4::
<#5::
<#6::
<#7::
<#8::
<#9::prem.gain(SubStr(A_ThisHotkey, -1, 1))



NumpadDot::NumpadDot
NumpadDot & NumpadSub::BackSpace

Escape::prem.escFxMenu()

SC03A & v::prem.selectionTool()

^!x::prem.rippleCut()

SC03A & d::prem.disableDirectManip()

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

!w::prem.closeActiveSequence()

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;// next/previous frame hotkeys
Shift & F21::prem.wheelEditPoint(KSA.effectControls, KSA.prempreviousKeyframe, 2, true) ;goes to the next keyframe point towards the left
Shift & F23::prem.wheelEditPoint(KSA.effectControls, KSA.premnextKeyframe, 2, true) ;goes to the next keyframe towards the right

F20::prem.dragSourceMon("video", "{F20}")
F19::prem.dragSourceMon(, "{F19}", "Bars and Tone - Rec 709")
F14 & F19::prem.dragSourceMon(, "")

;// next/previous edit point hotkeys
F21::prem.wheelEditPoint(KSA.timelineWindow, KSA.previousEditPoint,, true) ;goes to the next edit point towards the left
F23::prem.wheelEditPoint(KSA.timelineWindow, KSA.nextEditPoint,, true) ;goes to the next edit point towards the right

;// mousedrag hotkeys
LAlt & Xbutton2:: ;this is necessary for the below function to work
Xbutton2::prem.mousedrag(KSA.handPrem, KSA.selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

;// playback speed change hotkeys
F14 & F21::SendInput(KSA.slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
F14 & F23::
{
	delaySI(16, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement, ksa.speedUpIncrement) ;alternate way to speed up playback on the timeline with mouse buttons
	keys.allWait()
}

LAlt & SC03A::prem.layerSizeAdjust()
Alt & WheelUp::
Alt & WheelDown::
Shift & WheelUp::
Shift & WheelDown::prem.accelScroll(5, 25)


;// allExcept
<!+1::
<!+2::
<!+3::
<!+4::
<!+5::
<!+6::
<!+7::
<!+8::
<!+9::prem.toggleEnabled(, "aud", 1, true)