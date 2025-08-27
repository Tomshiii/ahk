#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\ptf>
#Include <Classes\winget>
#Include <Classes\errorLog>
#Include <Classes\WM>
#Include <QMK\unassigned>

premTimeline() {
	block.On()
	UserSettings := UserPref()
	__fallback() {
		if !prem.__setTimelineValues(false) {
			block.Off()
			return
		}
		tool.Cust("This function had to retrieve the coordinates of the timeline and was stopped from`ncontinuing incase you had multiple sequences open and need to go back.`nThis will not happen again.", 4.0,, -20, 14)
	}
	if !prem.__checkTimelineValues() {
		WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")
		if !prem.__waitForTimeline() {
			__fallback()
			block.Off()
			return
		}
	}
	; prem.__focusTimeline()
	block.Off()
	Exit()
}

BackSpace:: ;this hotkey will activate the program monitor, then send the hotkey to activate safe margins
{
	SendInput(KSA.programMonitor)
	SendInput(KSA.premSafeMargins)
	sleep 100
	premTimeline()
}
SC028::prem.movepreview() ;press then hold this hotkey and drag to move position. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
Enter::prem.reset()
Right::unassigned()

p::prem.gain("-2") ;REDUCE GAIN BY -2db
SC027::prem.valuehold("Position") ;press then hold this hotkey and drag to increase/decrese x value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
; /::


o::prem.preset("audio_basic")
l::prem.valuehold("Position", "60") ;press then hold this hotkey and drag to increase/decrese y value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Up::unassigned()
.::prem.preset("Transform Me")
;Down::unassigned()

i::prem.gain("-6") ;REDUCE GAIN BY -6db
k::prem.valuehold("Scale") ;press then hold this hotkey and drag to increase/decrese scale. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
,::prem.anchorToPosition() ;prem.gain("2") ;INCREASE GAIN BY 2db == set g to open gain window
;Left::unassigned()

u::prem.gain("6") ;INCREASE GAIN BY 6db
j::prem.valuehold("Rotation") ;press then hold this hotkey and drag to increase/decrease rotation. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
g::
;PgUp::unassigned()

; y::prem.valuehold("Opacity")
;h::unassigned()
#MaxThreadsBuffer True
n::unassigned()
#MaxThreadsBuffer false
;Space::unassigned()

t::prem.preset("gaussian blur 20") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags one of these presets onto the hovered track
y:: ;this hotkey will fill the frame to fit the window
{
	premTimeline()
	SendInput(KSA.scaleFrameSize)
}
; b::

r::prem.preset("Lowpass Me")
f::prem.preset("Highpass Me")

v::
;PgDn::unassigned()

e::prem.preset("tint 100")
d::prem.preset("hflip")
c::prem.preset("vflip")
;End::

w::unassigned()
s::prem.preset("croptom")
x::prem.fxSearch()
;F15::unassigned()

q::prem.preset("S_Shake Me")
a::
z::

;F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
; F13::unassigned()
; Home::unassigned()
