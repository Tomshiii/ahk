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
#Include Classes\CLSID_Objs.ahk
#Include QMK\unassigned.ahk
; }

BackSpace:: ;this hotkey will activate the program monitor, then send the hotkey to activate safe margins
{
	SendInput(KSA.prem.programMonitor)
	SendInput(ksa.prem.prem.SafeMargins)
	sleep 100
	prem.__focusTimeline()
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
.::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Geometry2")
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

t::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Gaussian%20Blur%20(Legacy)")
y:: ;this hotkey will fill the frame to fit the window
{
	prem.__focusTimeline()
	SendInput(KSA.prem.fitToFrame)
}
; b::

r::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Horizontal%20Flip")
f::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Vertical%20Flip")

v::
;PgDn::unassigned()

e::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Tint")
d::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Highpass")
c::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Lowpass")
End::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=RX%2011%20Dialogue%20Isolate")

w::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Drop%20Shadow")
s::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Crop")
x::prem.fxSearch()
F15::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Crop")

q::prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=S_Shake")
a::
z::

;F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
; F13::unassigned()
; Home::unassigned()
