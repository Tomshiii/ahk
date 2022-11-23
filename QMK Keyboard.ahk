SetWorkingDir(ptf.rootDir)

; { \\ #Includes
#Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Apps\Editors\After Effects>
#Include <\Apps\Editors\Photoshop>
#Include <\Apps\Editors\Premiere>
#Include <\Apps\Editors\Resolve>
#Include <\Apps\Discord>
#Include <\Classes\ptf>
#Include <\Classes\tool>
#Include <\Classes\block>
#Include <\Classes\switchTo>
#Include <\Functions\errorLog>
#Include <\Functions\detect>
; #Include <\Functions\Windows>
#Include <\GUIs>
; }

#Requires AutoHotkey v2.0-beta.12
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon(ptf.Icons "\keyboard.ico")
;SetCapsLockState "AlwaysOff" ;having this on broke my main script for whatever reason
SetNumLockState "AlwaysOn"
#SingleInstance Force ;only one instance of this script may run at a time!
;A_MenuMaskKey := "vk07" ;https://autohotkey.com/boards/viewtopic.php?f=76&t=57683
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm ;prevent taskbar flashing.

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.12.1

;\\CURRENT RELEASE VERSION
;\\v2.7.0.1

; \\\\\\\\////////////
; THIS SCRIPT WAS ORIGINALLY CREATED BY TARAN FROM LTT, I HAVE SIMPLY ADJUSTED IT TO WORK IN AHK v2.0
; ALSO I AM CURRENTLY USING A PLANCK EZ CUSTOM KEYBOARD WITH CUSTOM QMK FIRMWARE AND NOT USING THE HASU USB -> USB CONVERTER. Check Release v2.2.5.1 and below for a version of this script written for a small secondary numpad
; ANY OF THE SCRIPTS IN THIS FILE CAN BE PULLED OUT AND THEN REPLACED ON A NORMAL KEY ON YOUR NORMAL KEYBOARD
; This script looked very different when initially committed. Its messiness was too much of a pain for me so I've stripped a bunch of
; unnecessary comments
; \\\\\\\\///////////

/**
 * This function creates a tooltip to inform the user of the pressed key and that it hasn't been assigned to do anything yet
 */
unassigned() => tool.Cust(A_ThisHotkey " is unassigned") ;create a tooltip for unused keys

/**
 * A function to suppress multiple keystrokes or to do different things with multiple presses of the same key. This function is here for reference moreso than actual use
 */
numpad000()
{
		static winc_presses := 0
		if winc_presses > 0 ; SetTimer already started, so we log the keypress instead.
		{
			winc_presses += 1
			return
		}
		; Otherwise, this is the first press of a new series. Set count to 1 and start
		; the timer:
		winc_presses := 1
		SetTimer After400, -50 ; Wait for more presses within a 400 millisecond window.

		After400()  ; This is a nested function.
		{
			if winc_presses = 1 ; The key was pressed once.
			{
				sleep 10  ; Open a folder.
			}
			else if winc_presses = 2 ; The key was pressed twice.
			{
				; PUT CODE HERE LATER ````````````````````````````````
			}
			else if winc_presses > 2
			{
				sleep 10
			}
			; Regardless of which action above was triggered, reset the count to
			; prepare for the next series of presses:
			winc_presses := 0
		}
}

/*
dele() ;this is here so manInput() can work, you can just ignore this
{
	SendInput("{BackSpace}")
}

;added functionality in my main script to reload all scripts
!+r::
{
	Reload
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	;MsgBox "The script could not be reloaded. Would you like to open it for editing?",, 4
	Result := MsgBox("The script could not be reloaded. Would you like to open it for editing?",, 4)
		if Result = "Yes"
			{
				if WinExist(browser.winTitle["vscode"])
						WinActivate
				else
					Run ptf.LocalAppData "\Programs\Microsoft VS Code\Code.exe"
			}
}
*/

;;WHAT'S THIS ALL ABOUT??

;;THE SHORT VERSION:
;; https://www.youtube.com/watch?v=kTXK8kZaZ8c

;;THE LONG VERSION:
;; https://www.youtube.com/playlist?list=PLH1gH0v9E3ruYrNyRbHhDe6XDfw4sZdZr


;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;;
;;+++++++++++++++++ BEGIN SECOND KEYBOARD F24 ASSIGNMENTS +++++++++++++++++++++;;
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;;

;; You should DEFINITELY not be trying to add a 2nd keyboard unless you're already
;; familiar with how AutoHotkey works. I recommend that you at least take this tutorial:
;; https://lexikos.github.io/v2/docs/Tutorial.htm

;; The point of these is that THE TOOLTIPS ARE MERELY PLACEHOLDERS. When you add a function of your own, you should delete or comment out the tooltip.

;;COOL BONUS BECAUSE YOU'RE USING QMK:
;;The up and down keystrokes are registered seperately.
;;Therefore, your macro can do half of its action on the down stroke,
;;And the other half on the up stroke. (using "keywait,")
;;This can be very handy in specific situations.
;;The Corsair K55 keyboard fires the up and down keystrokes instantly.

;Numlock is an AWFUL key. I prefer to leave it permanently on.

;DEFINE SEPARATE PROGRAMS FIRST, THEN ANYTHING YOU WANT WHEN NO PROGRAM IS ACTIVE ->

;===========================================================================
;
#HotIf WinActive(editors.winTitle["premiere"]) and getKeyState("F24", "P")
;
;===========================================================================
;F24::return ;this line is mandatory for proper functionality


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

;===========================================================================
;
#HotIf WinActive(editors.winTitle["ae"]) and getKeyState("F24", "P")
;
;===========================================================================
;F24::return ;this line is mandatory for proper functionality

BackSpace::unassigned()
SC028::unassigned()
Enter::unassigned()
;Right::unassigned()

p::ae.motionBlur()
SC027::unassigned()
/::unassigned()
;Up::unassigned()

o::unassigned()
l::ae.scaleAndPos()
.::unassigned()
;Down::unassigned()

i::unassigned()
k::unassigned()
,::unassigned()
;Left::unassigned()

u::unassigned()
j::unassigned()
m::unassigned()
;PgUp::unassigned()

y::unassigned()
;h::unassigned()
n::unassigned()
;Space::unassigned()

t::unassigned()
g::unassigned()
b::unassigned()

r::unassigned()
f::unassigned()
v::unassigned()
;PgDn::unassigned()

e::unassigned()
d::unassigned()
c::unassigned()
;End::unassigned()

w::ae.preset("Drop Shadow")
s::unassigned()
x::unassigned()
;F15::unassigned()

q::unassigned()
a::unassigned()
z::unassigned()
F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()


;=============================================================================================================================================
;
#HotIf getKeyState("F24", "P") and WinActive(editors.winTitle["photoshop"])
;
;=============================================================================================================================================
;F24::return ;this line is mandatory for proper functionality

BackSpace::unassigned()
SC028::unassigned()
Enter::unassigned()
;Right::unassigned()

p::SendInput("!t" "b{Right}g") ;open gaussian blur (should really just use the inbuilt hotkey but uh. photoshop is smelly don't @ me)
SC027::ps.Prop("scale.png") ;this assumes you have h/w linked. You'll need more logic if you want separate values
/::unassigned()
;Up::unassigned()
o::unassigned()
l::ps.Prop("x.png")
.::ps.Prop("y.png")
;Down::unassigned()

i::unassigned()
k::unassigned()
,::unassigned()
;Left::unassigned()

u::ps.Prop("rotate.png")
j::unassigned()
m::unassigned()
;PgUp::unassigned()

y::unassigned()
;h::unassigned()
n::unassigned()
;Space::unassigned()

t::unassigned()
g::unassigned()
b::unassigned()

r::unassigned()
f::unassigned()
v::unassigned()
;PgDn::unassigned()

e::unassigned()
d::unassigned()
c::unassigned()
;End::unassigned()

w::unassigned()
s::unassigned()
x::unassigned()
;F15::unassigned()

q::unassigned()
a::unassigned()
z::unassigned()
F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()

;===========================================================================
;
#HotIf getKeyState("F24", "P") ;<--Everything after this line will only happen on the secondary keyboard that uses F24.
;
;===========================================================================
;F24::return ;this line is mandatory for proper functionality

BackSpace::unassigned()
SC028::unassigned() ; ' key
Enter::unassigned()
Enter & Up::switchTo.closeOtherWindow("ahk_class CabinetWClass")
Right::unassigned()
Right & Up::switchTo.newWin("class", "CabinetWClass", "explorer.exe")

p::unassigned()
SC027::unassigned()
/::unassigned()
Up::switchTo.Explorer()

o::unassigned()
l::unassigned()
.::unassigned()
Down::switchTo.Premiere()

i::unassigned()
k::unassigned()
,::unassigned()
Left::switchTo.AE()

u::unassigned()
j::unassigned()
m::unassigned()
SC149::firefoxTap()
Enter & SC149::switchTo.closeOtherWindow(browser.class["firefox"])
Right & PgUp::switchTo.newWin("exe", "firefox.exe", "firefox.exe")

y::unassigned()
h:: ;opens the directory for the current premiere project
{
	if !WinExist("Adobe Premiere Pro") && !WinExist("Adobe After Effects")
		{
			if DirExist(ptf.comms)
				{
					tool.Cust("A Premiere/AE isn't open, opening the comms folder")
					Run(ptf.comms)
					WinWait("ahk_class CabinetWClass", "comms")
					WinActivate("ahk_class CabinetWClass", "comms")
					return
				}
			tool.Cust("A Premiere/AE isn't open")
			errorLog(, A_ThisHotkey "::", "Could not find a Premiere/After Effects window", A_LineFile, A_LineNumber)
			return
		}
	try {
		if WinExist("Adobe Premiere Pro")
			{
				Name := WinGetTitle("Adobe Premiere Pro")
				titlecheck := InStr(Name, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
			}
		else if WinExist("Adobe After Effects")
			{
				Name := WinGetTitle("Adobe After Effects")
				titlecheck := InStr(Name, "Adobe After Effects " ptf.AEYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe After Effects [Year]"
			}
		dashLocation := InStr(Name, "-")
		length := StrLen(Name) - dashLocation
	}
	if !titlecheck
		{
			tool.Cust("You're on a part of Premiere that won't contain the project path", 2000)
			return
		}
	entirePath := SubStr(name, dashLocation + "2", length)
	pathlength := StrLen(entirePath)
	finalSlash := InStr(entirePath, "\",, -1)
	path := SubStr(entirePath, 1, finalSlash - "1")
	SplitPath(path,,,, &pathName)
	if WinExist("ahk_class CabinetWClass", pathName, "Adobe" "Editing Checklist", "Adobe")
		{
			WinActivate("ahk_class CabinetWClass", pathName, "Adobe")
			return
		}
	RunWait(path)
	WinWait("ahk_class CabinetWClass", pathName,, "Adobe")
	WinActivate("ahk_class CabinetWClass", pathName, "Adobe")
}
n::unassigned()
Space::switchTo.Disc()
Right & Space::switchTo.newWin("exe", "msedge.exe", "msedge.exe")
Enter & Space::switchTo.closeOtherWindow(browser.winTitle["edge"])

t::unassigned()
g::unassigned()
b:: ;this macro is to find the difference between 2 24h timecodes
{
	calculateTime(number) ;first we create a function that will return the results the user inputs
	{
		if number = 1
			startorend := "Start"
		else
			startorend := "End"
		start1:
		time := InputBox("Write the " startorend " hhmm time here`nDon't use ':'", "Input " startorend " Time", "w200 h110")
		if time.Result = "Cancel"
			return 0
		Length1 := StrLen(time.Value)
		if Length1 != "4" || time.Value > 2359
			{
				MsgBox("You didn't write in hhmm format`nTry again", startorend " Time", "16")
				goto start1
			}
		else
			return time.Value
	}
	time1 := calculateTime("1") ;then we call it twice
	if time1 = 0
		return
	time2 := calculateTime("2")
	if time2 = 0
		return
	diff := DateDiff("20220101" time2, "20220101" time1, "seconds")/"3600" ;do the math to determine the time difference
	value := Round(diff, 2) ;round the result to 2dp
	A_Clipboard := value ;copy it to the clipboard
	tool.Cust(diff "`nor " value, 2000) ;and create a tooltip to show the user both the complete answer and the rounded answer
}

r::unassigned()
f::unassigned()
v::unassigned()
PgDn::switchTo.Music()
Right & PgDn::musicGUI()

e::unassigned()
d::unassigned()
c::unassigned()
End:: ;search for checklist file
{
	detect()
	if !WinExist("Editing Checklist") && !WinExist("Select commission folder") && !WinExist("checklist.ahk - AutoHotkey")
		Run(ptf["checklist"])
	else if WinExist("Editing Checklist")
		WinMove(-345, -191,,, "Editing Checklist -")
}

w::unassigned()
s::unassigned()
x::unassigned()
F15::switchTo.Photo()

q::unassigned()
a::unassigned()
z::unassigned()
F16::switchTo.Edge()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/*
Everything I use so you can easy copy paste for new programs



BackSpace::unassigned()
SC028::unassigned() ; ' key
Enter::unassigned()
;Right::unassigned()

p::unassigned()
SC027::unassigned()
/::unassigned()
;Up::unassigned()

o::unassigned()
l::unassigned()
.::unassigned()
;Down::unassigned()

i::unassigned()
k::unassigned()
,::unassigned()
;Left::unassigned()

u::unassigned()
j::unassigned()
m::unassigned()
;PgUp::unassigned()

y::unassigned()
h::unassigned()
n::unassigned()
;Space::unassigned()

t::unassigned()
g::unassigned()
b::unassigned()

r::unassigned()
f::unassigned()
v::unassigned()
;PgDn::unassigned()

e::unassigned()
d::unassigned()
c::unassigned()
;End::unassigned()

w::unassigned()
;s::unassigned()
;x::unassigned()
;F15::unassigned()

q::unassigned()
a::unassigned()
z::unassigned()
F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()
 */