#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\ptf>
#Include <Classes\winget>
#Include <Functions\errorLog>
#Include <QMK\unassigned>

BackSpace & SC027::prem.keyframe("position")
BackSpace & /::prem.keyframe("position")
BackSpace & l::prem.keyframe("scale")
BackSpace & t::prem.keyframe("level")
BackSpace & u::prem.keyframe("rotation")
BackSpace & y::prem.keyframe("opacity")
SC028 & SC027::prem.manInput("position") ;manually input an x value
SC028 & /::prem.manInput("position", "60") ;manually input a y value
SC028 & l::prem.manInput("scale") ;manually input a scale value
SC028 & u::prem.manInput("rotation") ;manually input a rotation value
SC028 & y::prem.manInput("opacity") ;manually input an opacity value
SC028 & t::prem.manInput("level") ;manually input a level value
Enter::prem.reset()
Enter & SC027::prem.keyreset("position")
Enter & /::prem.keyreset("position")
Enter & l::prem.keyreset("scale")
Enter & t::prem.keyreset("level")
Enter & u::prem.keyreset("rotation")
Enter & y::prem.keyreset("opacity")
Right::unassigned()

p::prem.preset("gaussian blur 20") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags one of these presets onto the hovered track
SC027::prem.valuehold("position") ;press then hold this hotkey and drag to increase/decrese x value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
/::prem.valuehold("position", "60") ;press then hold this hotkey and drag to increase/decrese y value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values


o::prem.preset("parametric")
l::prem.valuehold("scale") ;press then hold this hotkey and drag to increase/decrese scale. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Up::unassigned()
.::prem.movepreview() ;press then hold this hotkey and drag to move position. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Down::unassigned()

i::prem.preset("loremipsum") ;(if you already have a text layer click it first, then hover over it, otherwise simply..) -> press this hotkey, then watch as ahk creates a new text layer then drags your prem.preset onto the text layer. ;this hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
k::prem.gain("-2") ;REDUCE GAIN BY -2db
,::prem.gain("2") ;INCREASE GAIN BY 2db == set g to open gain window
;Left::unassigned()

u::prem.valuehold("rotation") ;press then hold this hotkey and drag to increase/decrease rotation. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
j::prem.gain("-6") ;REDUCE GAIN BY -6db
m::prem.gain("6") ;INCREASE GAIN BY 6db
;PgUp::unassigned()

y::prem.valuehold("opacity")
;h::unassigned()
n::prem.zoom()
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
g:: ;this hotkey will fill the frame to fit the window
{
	SendInput(KSA.timelineWindow)
	;SendInput(KSA.selectAtPlayhead)
	SendInput(KSA.scaleFrameSize)
}
b::prem.preset("transform_MINE")

r::prem.preset("tint 100")
f:: ;this macro is to open the speed menu
{
	SendInput(KSA.timelineWindow)
	SendInput(KSA.timelineWindow)
	try {
		loop 3 {
			effClassNN := ControlGetClassNN(ControlGetFocus("A"))
			if effClassNN != "DroverLord - Window Class3"
				break
			sleep 30
		}
	} catch as e {
		tool.Cust("something broke")
		errorLog(e)
		Exit
	}
	SendInput(KSA.selectAtPlayhead KSA.speedHotkey)
}
v:: ;this hotkey will activate the program monitor, find the margin button (assuming you have it there) and activate/deactivate it
{
	SendInput(KSA.programMonitor)
	SendInput(KSA.programMonitor)
	SendInput(KSA.premSafeMargins)
	SendInput(KSA.timelineWindow)
}
;PgDn::unassigned()

e::prem.preset("Highpass Me")
d::prem.preset("hflip")
c::prem.preset("vflip")
;End::

w::unassigned()
s::prem.preset("croptom")
x::prem.fxSearch()
;F15::unassigned()

q::unassigned()
a::unassigned()
z::unassigned()
;F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()
