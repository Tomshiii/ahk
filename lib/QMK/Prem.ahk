#Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Classes\Editors\Premiere>
#Include <\Classes\tool>
#Include <\Classes\block>
#Include <\Classes\ptf>
#Include <\Functions\errorLog>
#Include <\QMK\unassigned>

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

t::prem.valuehold("level") ;press then hold this hotkey and drag to increase/decrese level volume. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values ;this hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
g:: ;this hotkey will fill the frame to fit the window
{
	SendInput(timelineWindow)
	;SendInput(selectAtPlayhead)
	SendInput(scaleFrameSize)
}
b::unassigned()

r::prem.preset("tint 100")
f:: ;this macro is to open the speed menu
{
	SendInput(timelineWindow)
	SendInput(timelineWindow)
	try {
		loop 3 {
			effClassNN := ControlGetClassNN(ControlGetFocus("A"))
			if effClassNN != "DroverLord - Window Class3"
				break
			sleep 30
		}
	} catch as e {
		tool.Cust("something broke")
		errorLog(e, A_ThisHotkey "::")
		Exit
	}
	SendInput(selectAtPlayhead speedHotkey)
}
v:: ;this hotkey will activate the program monitor, find the margin button (assuming you have it there) and activate/deactivate it
{
	block.On()
	MouseGetPos(&origX, &origY)
	SendInput(timelineWindow)
	SendInput(timelineWindow)
	/* SendInput(programMonitor)
	SendInput(programMonitor)
	sleep 250
	toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
	ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
	sleep 250
	if ImageSearch(&x, &y, toolx, tooly, toolx + width, tooly + height, "*2 " Premiere "margin.png") || ImageSearch(&x, &y, toolx, tooly, toolx + width, tooly + height, "*2 " Premiere "margin2.png") ; the above code is if you want to use ClassNN values instead of just searching the right side of the screen. I stopped using that because even though it's more universal, it's just too slow to be useful */
	if !ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Premiere "margin.png") && !ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Premiere "margin2.png") ;if you don't have your project monitor on your main computer monitor, you can try using the code above instead, ClassNN values are just an absolute pain in the neck and sometimes just choose to break for absolutely no reason (and they're slow for the project monitor for whatever reason). My project window is on the right side of my screen (which is why the first x value is A_ScreenWidth/2 - if yours is on the left you can simply switch these two values
		{
			block.Off()
			tool.Cust("the margin button",, 1)
			errorLog(, A_ThisHotkey "::", "Couldn't find the margin button", A_LineFile, A_LineNumber)
			return
		}
	MouseMove(x, y)
	SendInput("{Click}")
	MouseMove(origX, origY)
	block.Off()
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
F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()
