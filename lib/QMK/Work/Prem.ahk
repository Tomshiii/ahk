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
	UserSettings := UserPref()
	__fallback() {
		if !prem.__checkTimeline(false)
			return
		tool.Cust("This function had to retrieve the coordinates of the timeline and was stopped from`ncontinuing incase you had multiple sequences open and need to go back.`nThis will not happen again.", 4.0,, -20, 14)
	}
	if !prem.__checkTimelineValues() {
		WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")
		if !prem.__waitForTimeline() {
			__fallback()
			return
		}
	}
	prem.__checkTimelineFocus()
}

; BackSpace::unassigned()
; SC028::unassigned()
Enter::prem.reset()
Enter & SC027::prem.keyreset("position")
Enter & l::prem.keyreset("position")
Enter & k::prem.keyreset("scale")
Enter & g::prem.keyreset("level")
Enter & j::prem.keyreset("rotation")
Enter & h::prem.keyreset("opacity")
Right::unassigned()

t::prem.preset("gaussian blur 20") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags one of these presets onto the hovered track
SC027::prem.valuehold("position") ;press then hold this hotkey and drag to increase/decrese x value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
l::prem.valuehold("position", "60") ;press then hold this hotkey and drag to increase/decrese y value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values


End::prem.preset("audio_basic")
k::prem.valuehold("scale") ;press then hold this hotkey and drag to increase/decrese scale. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Up::unassigned()
SC028::prem.movepreview() ;press then hold this hotkey and drag to move position. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
.::prem.preset("transform Me")
;Down::unassigned()

p::prem.gain("-2") ;REDUCE GAIN BY -2db
o::prem.gain("2") ;INCREASE GAIN BY 2db == set g to open gain window
,::prem.anchorToPosition()
;Left::unassigned()

j::prem.valuehold("rotation") ;press then hold this hotkey and drag to increase/decrease rotation. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
i::prem.gain("-6") ;REDUCE GAIN BY -6db
u::prem.gain("6") ;INCREASE GAIN BY 6db
;PgUp::unassigned()

h::prem.valuehold("opacity")
; n::unassigned()

y:: ;this hotkey will fill the frame to fit the window
{
	premTimeline()
	SendInput(KSA.scaleFrameSize)
}
x::unassigned()

e::prem.preset("Parametric EQ_mine")
c::prem.preset("Lowpass Me")
d::prem.preset("Highpass Me")

BackSpace:: ;this hotkey will activate the program monitor, find the margin button (assuming you have it there) and activate/deactivate it
{
	SendInput(KSA.programMonitor)
	SendInput(KSA.premSafeMargins)
	sleep 100
	premTimeline()
}
PgDn::prem.preset("S_Shake Me")

s::prem.preset("tint 100")
r::prem.preset("hflip")
f::prem.preset("vflip")
;End::

w::prem.preset("Drop Shadow_mine")
F15::prem.preset("croptom")
; x::prem.fxSearch()
;F15::unassigned()

q::unassigned()
a::unassigned()

;F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
; F13::unassigned()
; Home::unassigned()
