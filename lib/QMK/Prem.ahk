; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\tool.ahk
#Include Classes\block.ahk
#Include Classes\ptf.ahk
#Include Classes\winget.ahk
#Include Classes\errorLog.ahk
#Include Classes\WM.ahk
#Include QMK\unassigned.ahk
; }

premTimeline() {
	block.On()
	UserSettings := UserPref()
	__fallback() {
		if !prem.__setTimelineValues(false) {
			block.Off()
			return false
		}
		tool.Cust("This function had to retrieve the coordinates of the timeline and was stopped from`ncontinuing incase you had multiple sequences open and need to go back.`nThis will not happen again.", 4.0,, -20, 14)
	}
	if !prem.__checkTimelineValues() {
		WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")
		if !prem.__waitForTimeline() {
			if !__fallback() {
				block.Off()
				return false
			}
			block.Off()
			return true
		}
	}
	; prem.__focusTimeline()
	block.Off()
	return false
}

SC028 & SC027::prem.manInput("position") ;manually input an x value
; SC028 & /::prem.manInput("position", "60") ;manually input a y value
SC028 & l::prem.manInput("scale") ;manually input a scale value
SC028 & u::prem.manInput("rotation") ;manually input a rotation value
SC028 & y::prem.manInput("opacity") ;manually input an opacity value
SC028 & t::prem.manInput("level") ;manually input a level value
Enter::prem.reset()
Right::unassigned()

p::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Gaussian%20Blur")
SC027::prem.movepreview() ;press then hold this hotkey and drag to move position. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
; /::


o::prem.preset("audio_basic")
l::prem.valuehold("Scale") ;press then hold this hotkey and drag to increase/decrese scale. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Up::unassigned()
.::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Transform")
;Down::unassigned()

i::prem.preset("loremipsum") ;(if you already have a text layer click it first, then hover over it, otherwise simply..) -> press this hotkey, then watch as ahk creates a new text layer then drags your prem.preset onto the text layer. ;this hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
k::prem.gain("-2") ;REDUCE GAIN BY -2db
,::prem.anchorToPosition() ;prem.gain("2") ;INCREASE GAIN BY 2db == set g to open gain window
;Left::unassigned()

u::prem.valuehold("Rotation") ;press then hold this hotkey and drag to increase/decrease rotation. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
j::prem.gain("-6") ;REDUCE GAIN BY -6db
g::prem.gain("6") ;INCREASE GAIN BY 6db
;PgUp::unassigned()

y::prem.valuehold("Opacity")
h::prem.gain("2")
#MaxThreadsBuffer True
n::unassigned()
#MaxThreadsBuffer false
;Space::unassigned()

t:: ;preset for applying an eq effect to lessen harshness of clipping
{
	;// attempt to grab client name from the title dir path
	ClientName := WinGet.ProjClient()
	if !ClientName
		return
	;// read the preset file
	preset := FileRead(ptf["PremPresets"])
	SendInput(KSA.effectControls)
	SendInput(KSA.effectControls)
	;// check if preset for current proj exists
	if InStr(preset, "fix clipping_" ClientName)
		prem.preset("fix clipping_" ClientName)
	else
		prem.preset("fix clipping_default")
}
m:: ;this hotkey will fill the frame to fit the window
{
	if !premTimeline()
		return
	SendInput(KSA.scaleFrameSize)
}
; b::

r::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Lowpass")
f::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Highpass")

v:: ;this hotkey will activate the program monitor, find the margin button (assuming you have it there) and activate/deactivate it
{
	SendInput(KSA.programMonitor)
	SendInput(KSA.premSafeMargins)
	sleep 100
	premTimeline()
}
;PgDn::unassigned()

e::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Tint")
d::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Horizontal%20Flip")
c::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Vertical%20Flip")
End::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Lumetri%20Color")

w::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Drop%20Shadow")
s::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=Crop")
x::prem.fxSearch()
;F15::unassigned()

q::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effect=S_Shake")
a::prem.valuehold("Position") ;press then hold this hotkey and drag to increase/decrese x value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
z::prem.valuehold("Position", "60") ;press then hold this hotkey and drag to increase/decrese y value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values

;F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
; F13::unassigned()
; Home::unassigned()
