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
		prem.swapChannels(1)
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
	if WinActive("Modify Clip " prem.winTitle) || WinActive("Audio Gain " prem.winTitle) {
		SendInput("{Enter}")
		return
	}
	prem.delayPlayback()
}

;linkActivateHotkey;
~^l::SendInput(KSA.selectAtPlayhead)

;prem^DeleteHotkey;
; Ctrl & BackSpace::prem.wordBackspace()

;premselecttoolHotkey;
SC03A & v::prem.selectionTool()

;premprojectHotkey;
RAlt & p::prem.openEditingDir(ptf.EditingStuff)

;12forwardHotkey;
PgDn::prem.moveKeyframes("right", 12)
;12backHotkey;
PgUp::prem.moveKeyframes("left", 12)

;premrippleTrimHotkey;
q::
w::prem.rippleTrim()

;thumbScrollHotkey;
F12::prem.thumbScroll()

;premresetHotkey;
F5::prem.reset()

;premnumpadGainHotkey;
~Numpad1::
~Numpad2::
~Numpad3::
~Numpad4::
~Numpad5::
~Numpad6::
~Numpad7::
~Numpad8::
~Numpad9::prem.numpadGain()

NumpadMult::Tab

$+1::
$+2::
$+3::prem.zoomPreviewWindow(A_ThisHotkey)

`::
{
	allowedTitles := Map(
		"Modify Clip",		 true,
		"Audio Gain",		 true,
	)
	activeWin := WinGetTitle("A")
	if !allowedTitles.Has(activeWin) {
		SendInput("{``}")
		return
	}
	SendInput("{Enter}")
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;previouspremkeyframeHotkey;
Shift & F21::prem.wheelEditPoint(KSA.effectControls, KSA.prempreviousKeyframe, "second") ;goes to the next keyframe point towards the left
;nextpremkeyframeHotkey;
Shift & F23::prem.wheelEditPoint(KSA.effectControls, KSA.premnextKeyframe, "second") ;goes to the next keyframe towards the right

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

;bonkHotkey;
; F19::prem.audioDrag("Bonk - Sound Effect (HD).wav") ;drag my bleep (goose) sfx to the cursor ;I have a button on my mouse spit out F19 & F20
;bleepHotkey;
; F20::prem.audioDrag("bleep")

;slowDownHotkey;
F14 & F21::SendInput(KSA.slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
;speedUpHotkey;
F14 & F23::SendInput(KSA.speedUpPlayback) ;alternate way to speed up playback on the timeline with mouse buttons

#MaxThreadsBuffer true
Alt & WheelUp::
Alt & WheelDown::
Shift & WheelUp::
Shift & WheelDown::prem.accelScroll(5, 25)
#MaxThreadsBuffer false