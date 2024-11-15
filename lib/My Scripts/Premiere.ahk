; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Functions\isDoubleClick>
; }

;stopTabHotkey;
Shift & Tab::
$Tab::
{
	if WinActive("Modify Clip " prem.winTitle) {
		prem.swapChannels(1, 16, ksa.labelPurple)
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
	switch getTitle := WinGetTitle("A") {
		case "Modify Clip", "Audio Gain":
			SendInput("{Enter}")
			return
		case "Save Project": return
	}
	prem.delayPlayback()
}

NumpadEnter::
Enter::
{
	getTitle := WinGetTitle("A")
	switch {
		case InStr(getTitle, "Clip Fx Editor"), InStr(getTitle, "Track Fx Editor"):
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

$+1::
$+2::
$+3::prem.zoomPreviewWindow(A_ThisHotkey)

^!f::prem.flattenAndColour(ksa.labelIris, false)

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;previouspremkeyframeHotkey;
Shift & F21::prem.wheelEditPoint(KSA.effectControls, KSA.prempreviousKeyframe, "second") ;goes to the next keyframe point towards the left
;nextpremkeyframeHotkey;
Shift & F23::prem.wheelEditPoint(KSA.effectControls, KSA.premnextKeyframe, "second") ;goes to the next keyframe towards the right

F20::prem.dragSourceMon("video", "{F20}")
F19::prem.dragSourceMon(, "{F19}", "Bars and Tone - Rec 709")
F14 & F19::prem.dragSourceMon(, "")

;previouseditHotkey;
F21::prem.wheelEditPoint(KSA.timelineWindow, KSA.previousEditPoint) ;goes to the next edit point towards the left
;nexteditHotkey;
F23::prem.wheelEditPoint(KSA.timelineWindow, KSA.nextEditPoint) ;goes to the next edit point towards the right

;playstopHotkey;
F18::SendInput(KSA.playStop) ;alternate way to play/stop the timeline with a mouse button
;mousedrag1Hotkey;
LAlt & Xbutton2:: ;this is necessary for the below function to work
;mousedrag2Hotkey;
Xbutton2::prem.mousedrag(KSA.handPrem, KSA.selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

;slowDownHotkey;
F14 & F21::SendInput(KSA.slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
;speedUpHotkey;
F14 & F23::
{
	SendInput(ksa.speedUpIncrement ksa.speedUpIncrement ksa.speedUpIncrement ksa.speedUpIncrement ksa.speedUpIncrement) ;alternate way to speed up playback on the timeline with mouse buttons
	keys.allWait()
}

#MaxThreadsBuffer true
Alt & WheelUp::
Alt & WheelDown::
Shift & WheelUp::
Shift & WheelDown::prem.accelScroll(5, 25)
#MaxThreadsBuffer false