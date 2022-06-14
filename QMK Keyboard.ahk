SetWorkingDir A_ScriptDir
#Include "Functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon(A_WorkingDir "\Support Files\Icons\keyboard.ico")
;SetCapsLockState "AlwaysOff" ;having this on broke my main script for whatever reason
SetNumLockState "AlwaysOn"
#SingleInstance Force ;only one instance of this script may run at a time!
;A_MenuMaskKey := "vk07" ;https://autohotkey.com/boards/viewtopic.php?f=76&t=57683
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm ;prevent taskbar flashing.

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.6.1

;\\CURRENT RELEASE VERSION
;\\v2.3.4

; \\\\\\\\////////////
; THIS SCRIPT WAS ORIGINALLY CREATED BY TARAN FROM LTT, I HAVE SIMPLY ADJUSTED IT TO WORK IN AHK v2.0
; ALSO I AM CURRENTLY USING A PLANCK EZ CUSTOM KEYBOARD WITH CUSTOM QMK FIRMWARE AND NOT USING THE HASU USB -> USB CONVERTER. Check Release v2.2.5.1 and below for a version of this script written for a small secondary numpad
; ANY OF THE SCRIPTS IN THIS FILE CAN BE PULLED OUT AND THEN REPLACED ON A NORMAL KEY ON YOUR NORMAL KEYBOARD
; This script looked very different when initially committed. Its messiness was too much of a pain for me so I've stripped a bunch of
; unnecessary comments
; \\\\\\\\///////////

/*
 This function creates a tooltip to inform the user of the pressed key and that it hasn't been assigned to do anything yet
 */
unassigned() ;create a tooltip for unused keys
{
	ToolTip(A_ThisHotkey " is unassigned")
	SetTimer(timeouttime, -1000)
	timeouttime()
	{
		ToolTip("")
	}
}

/*
 This function is specifically designed for this script as I have a button designed to be pressed alongside another just to open new windows
 @param key is the activation key of the program (not the key to run an additional window). These are NOT listed in KSA simply because this script is so incredibly specific to my workflow
 @param classorexe is just defining if we're trying to grab the class or exe
 @param activate is whatever usually comes after the ahk_class or ahk_exe that ahk is going to use to activate once it's open
 @param runval is whatever you need to put into ahk to run a new instance of the desired program (eg. a file path)
 */
newWin(key, classorexe, activate, runval)
{
	KeyWait(%&key%) ;prevent spamming
	if not WinExist("ahk_" %&classorexe% . %&activate%)
		{
			Run(%&runval%)
			WinWait("ahk_" %&classorexe% . %&activate%)
			WinActivate("ahk_" %&classorexe% . %&activate%) ;in win11 running things won't always activate it and will open in the backround
		}
	else
		Run(%&runval%)
}

/* numpad000()
 A function to suppress multiple keystrokes or to do different things with multiple presses of the same key. This function is here for reference moreso than actual use
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
				if WinExist("ahk_exe Code.exe")
						WinActivate
				else
					Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe"
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
;; https://autohotkey.com/docs/Tutorial.htm

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
#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe") and getKeyState("F24", "P")
;
;===========================================================================
;F24::return ;this line is mandatory for proper functionality

BackSpace::preset("loremipsum") ;(if you already have a text layer click it first, then hover over it, otherwise simply..) -> press this hotkey, then watch as ahk creates a new text layer then drags your preset onto the text layer. ;this hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
SC028 & SC027::manInput("scale", "0", "SC027", "NumpadEnter") ;manually input a scale value
SC028 & /::manInput("position", "0", "/", "NumpadEnter") ;manually input an x value
SC028 & .::manInput("position", "60", ".", "NumpadEnter") ;manually input a y value
SC028 & k::manInput("rotation", "0", "k", "NumpadEnter") ;manually input a rotation value
SC028 & m::manInput("opacity", "0", "m", "NumpadEnter") ;manually input an opacity value
SC028 & l::manInput("level", "0", "l", "NumpadEnter") ;manually input a level value
Enter::reset()
Enter & SC027::keyreset("scale")
Enter & /::keyreset("position")
Enter & .::keyreset("position")
Enter & l::keyreset("level")
Enter & k::keyreset("rotation")
Enter & m::keyreset("opacity")
Right::unassigned()

p::preset("gaussian blur 20") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags one of these presets onto the hovered track
SC027::valuehold("scale", "0") ;press then hold this hotkey and drag to increase/decrese scale. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
/::valuehold("position", "0") ;press then hold this hotkey and drag to increase/decrese x value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Up::unassigned()

o::preset("parametric")
l::valuehold("level", "0") ;press then hold this hotkey and drag to increase/decrese level volume. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values ;this hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
.::valuehold("position", "60") ;press then hold this hotkey and drag to increase/decrese y value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Down::unassigned()

i::preset("croptom")
k::valuehold("rotation", "0") ;press then hold this hotkey and drag to increase/decrease rotation. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
,::movepreview() ;press then hold this hotkey and drag to move position. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Left::unassigned()

u::preset("hflip")
j & SC027::keyframe("scale")
j & /::keyframe("position")
j & .::keyframe("position")
j & l::keyframe("level")
j & k::keyframe("rotation")
j & m::keyframe("opacity")
m::valuehold("opacity", "0")
;PgUp::unassigned()

y::preset("vflip")
h::fxSearch()
n::unassigned()
;Space::unassigned()

t::preset("tint 100")
g::
{
	SendInput(timelineWindow)
	;SendInput(selectAtPlayhead)
	SendInput("^+1")
}
b::num("2550", "0", "200") ;This script moves the "motion tab" then menus through and change values to zoom into a custom coord and zoom level
b & Right::num("3828", "-717", "300") ;This script moves the "motion tab" then menus through and change values to zoom into a custom coord and zoom level

r::preset("Highpass Me")
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
		toolCust("something broke", "1000")
		errorLog(A_ThisHotkey, "Encountered an error attempting to get the ControlClassNN", A_LineFile, A_LineNumber)
		Exit
	}
	SendInput(selectAtPlayhead speedHotkey)
}
v:: ;this hotkey will activate the program monitor, find the margin button (assuming you have it there) and activate/deactivate it
{
	blockOn()
	MouseGetPos(&origX, &origY)
	SendInput(timelineWindow)
	SendInput(timelineWindow)
	/* SendInput(programMonitor)
	SendInput(programMonitor)
	sleep 250
	toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
	ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
	sleep 250 
	if ImageSearch(&x, &y, %&toolx%, %&tooly%, %&toolx% + %&width%, %&tooly% + %&height%, "*2 " Premiere "margin.png") || ImageSearch(&x, &y, %&toolx%, %&tooly%, %&toolx% + %&width%, %&tooly% + %&height%, "*2 " Premiere "margin2.png") ; the above code is if you want to use ClassNN values instead of just searching the right side of the screen. I stopped using that because even though it's more universal, it's just too slow to be useful */
	if ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Premiere "margin.png") || ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Premiere "margin2.png") ;if you don't have your project monitor on your main computer monitor, you can try using the code above instead, ClassNN values are just an absolute pain in the neck and sometimes just choose to break for absolutely no reason (and they're slow for the project monitor for whatever reason). My project window is on the right side of my screen (which is why the first x value is A_ScreenWidth/2 - if yours is on the left you can simply switch these two values
		{
			MouseMove(%&x%, %&y%)
			SendInput("{Click}")
			MouseMove(%&origX%, %&origY%)
			blockOff()
			return
		}
	else
		{
			blockOff()
			toolFind("the margin button", "1000")
			errorLog(A_ThisHotkey, "Couldn't find the margin button", A_LineFile, A_LineNumber)
		}
}
;PgDn::unassigned()

e::gain("-2") ;REDUCE GAIN BY -2db
d::gain("2") ;INCREASE GAIN BY 2db == set g to open gain window
c::gain("-6") ;REDUCE GAIN BY -6db
End::gain("6") ;INCREASE GAIN BY 6db

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

;===========================================================================
;
#HotIf WinActive("ahk_exe AfterFX.exe") and getKeyState("F24", "P")
;
;===========================================================================
;F24::return ;this line is mandatory for proper functionality

BackSpace::unassigned()
SC028::unassigned()
Enter::unassigned()
;Right::unassigned()

p::motionBlur()
SC027::aeScaleAndPos()
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
End::unassigned()

w::aePreset("Drop Shadow")
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


;=============================================================================================================================================
;
#HotIf getKeyState("F24", "P") and WinActive("ahk_exe Photoshop.exe")
;
;=============================================================================================================================================
;F24::return ;this line is mandatory for proper functionality

BackSpace::unassigned()
SC028::unassigned()
Enter::unassigned()
;Right::unassigned()

p::SendInput("!{t}" "b{Right}g") ;open gaussian blur (should really just use the inbuilt hotkey but uh. photoshop is smelly don't @ me)
SC027::psProp("scale.png") ;this assumes you have h/w linked. You'll need more logic if you want separate values
/::psProp("x.png")
;Up::unassigned()
o::unassigned()
l::unassigned()
.::psProp("y.png")
;Down::unassigned()

i::unassigned()
k::psProp("rotate.png")
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
End::unassigned()

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

;===========================================================================
;
#HotIf getKeyState("F24", "P") ;<--Everything after this line will only happen on the secondary keyboard that uses F24.
;
;===========================================================================
;F24::return ;this line is mandatory for proper functionality

BackSpace::unassigned()
SC028::unassigned() ; ' key
Enter::unassigned()
Enter & Up::closeOtherWindow("ahk_class CabinetWClass")
Right::unassigned()
Right & Up::newWin("Up", "class", "CabinetWClass", "explorer.exe")

p::unassigned()
SC027::unassigned()
/::unassigned()
Up::switchToExplorer()

o::unassigned()
l::unassigned()
.::unassigned()
Down::switchToPremiere()

i::unassigned()
k::unassigned()
,::unassigned()
Left::switchToAE()

u::unassigned()
j::unassigned()
m::unassigned()
SC149::firefoxTap()
Enter & SC149::closeOtherWindow("ahk_class MozillaWindowClass")
Right & PgUp::newWin("PgUp", "exe", "firefox.exe", "firefox.exe")

y::unassigned()
h::unassigned()
n:: ;this macro is to find the difference between 2 24h timecodes
{
	start1:
	time1 := InputBox("Write the Start hhmm time here`nDon't use ':'", "Input Start Time", "w200 h110")
	if time1.Result = "Cancel"
		return
	Length1 := StrLen(time1.Value)
	if Length1 != "4"
		{
			MsgBox("You didn't write in hhmm format`nTry again", "Start Time", "16")
			goto start1
		}
	if time1.Value > 2359
		{
			MsgBox("You didn't write in hhmm format`nTry again", "Start Time", "16")
			goto start1
		}
	start2:
	time2 := InputBox("Write the End hhmm time here`nDon't use ':'", "Input End Time", "w200 h110")
	if time2.Result = "Cancel"
		return
	Length2 := StrLen(time2.Value)
	if Length2 != "4"
		{
			MsgBox("You didn't write in hhmm format`nTry again", "End Time", "16")
			goto start2
		}
	if time2.Value > 2359
		{
			MsgBox("You didn't write in hhmm format`nTry again", "End Time", "16")
			goto start2
		}
	diff := DateDiff("20220101" time2.Value, "20220101" time1.Value, "seconds")/"3600"
	value := Round(diff, 2)
	A_Clipboard := value
	toolCust(diff "`nor " value, "2000")
}
Space::switchToEdge()
Right & Space::newWin("Space", "exe", "msedge.exe", "msedge.exe")
Enter & Space::closeOtherWindow("ahk_exe msedge.exe")

t::unassigned()
g::unassigned()
b::unassigned()

r::unassigned()
f::unassigned()
v::unassigned()
PgDn::switchToMusic()
Right & PgDn::musicGUI()

e::unassigned()
d::unassigned()
c::unassigned()
End::unassigned()

w::unassigned()
s:: ;search for checklist file
{
	if WinExist("Adobe Premiere Pro") || WinExist("Adobe After Effects")
		{
			try {
				if WinExist("Adobe Premiere Pro")
					{
						Name := WinGetTitle("Adobe Premiere Pro")
						titlecheck := InStr(Name, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
					}
				else if WinExist("Adobe After Effects")
					{
						Name := WinGetTitle("Adobe After Effects")
						titlecheck := InStr(Name, "Adobe After Effects " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe After Effects [Year]"
					}
				dashLocation := InStr(Name, "-")
				length := StrLen(Name) - dashLocation
			}
			if not titlecheck
				{
					toolCust("You're on a part of Premiere that won't contain the project path", "2000")
					return
				}
			entirePath := SubStr(name, dashLocation + "2", length)
			pathlength := StrLen(entirePath)
			finalSlash := InStr(entirePath, "\",, -1)
			path := SubStr(entirePath, 1, finalSlash - "1")
			SplitPath path, &name
			if WinExist("Checklist - " %&name%)
				{
					WinMove(-371, -233,,, "Checklist - " %&name%) ;move it back into place incase I've moved it
					toolCust("You already have this checklist open", "1000")
					errorLog(A_ThisHotkey, "You already have this checklist open", A_LineFile, A_LineNumber)
					return
				}
			if FileExist(path "\checklist.ahk")
				Run(path "\checklist.ahk")
			else
				{
					try {
						FileCopy("E:\Github\ahk\checklist.ahk", path)
						Run(path "\checklist.ahk")
					} catch as e {
						toolCust("File not found", "1000")
					}
				}
		}
	else
		{
			dir := FileSelect("D2", "E:\comms", "Pick the Edit Directory")
			if dir = ""
				return
			SplitPath dir, &name
			if WinExist("Checklist - " %&name%)
				{
					toolCust("You already have this checklist open", "1000")
					errorLog(A_ThisHotkey, "You already have this checklist open", A_LineFile, A_LineNumber)
					return
				}
			if FileExist(dir "\checklist.ahk")
				Run(dir "\checklist.ahk")
			else
				try {
					FileCopy("E:\Github\ahk\checklist.ahk", dir)
					Run(dir "\checklist.ahk")
				} catch as e {
					toolCust("File not found", "1000")
				}
		}
}
x:: ;opens the directory for the current premiere project
{
	if WinExist("Adobe Premiere Pro") || WinExist("Adobe After Effects")
		{
			try {
				if WinExist("Adobe Premiere Pro")
					{
						Name := WinGetTitle("Adobe Premiere Pro")
						titlecheck := InStr(Name, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
					}
				else if WinExist("Adobe After Effects")
					{
						Name := WinGetTitle("Adobe After Effects")
						titlecheck := InStr(Name, "Adobe After Effects " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe After Effects [Year]"
					}
				dashLocation := InStr(Name, "-")
				length := StrLen(Name) - dashLocation
			}
			if not titlecheck
				{
					toolCust("You're on a part of Premiere that won't contain the project path", "2000")
					return
				}
			entirePath := SubStr(name, dashLocation + "2", length)
			pathlength := StrLen(entirePath)
			finalSlash := InStr(entirePath, "\",, -1)
			path := SubStr(entirePath, 1, finalSlash - "1")
			SplitPath(path,,,, &pathName)
			if WinExist("ahk_class CabinetWClass", %&pathName%, "Adobe" "Editing Checklist", "Adobe")
				{
					WinActivate("ahk_class CabinetWClass", %&pathName%, "Adobe")
					return
				}
			RunWait(path)
			WinWait("ahk_class CabinetWClass", %&pathName%,, "Adobe")
			WinActivate("ahk_class CabinetWClass", %&pathName%, "Adobe")
		}
	else
		{
			toolCust("A Premiere/AE isn't open", "1000")
			errorLog(A_ThisHotkey, "Could not find a Premiere/After Effects window", A_LineFile, A_LineNumber)
			return
		}
}
F15::switchToPhoto()

q::unassigned()
a::unassigned()
z::unassigned()
F16::unassigned()

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
End::unassigned()

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