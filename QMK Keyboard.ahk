SetWorkingDir A_ScriptDir
#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\keyboard.ico")
;SetCapsLockState "AlwaysOff" ;having this on broke my main script for whatever reason
SetNumLockState "AlwaysOn"
#SingleInstance Force ;only one instance of this script may run at a time!
A_MenuMaskKey := "vk07" ;https://autohotkey.com/boards/viewtopic.php?f=76&t=57683
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm ;prevent taskbar flashing.

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.1.14
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.4.2

;\\CURRENT RELEASE VERSION
;\\v2.0

; \\\\\\\\////////////
; THIS SCRIPT WAS ORIGINALLY CREATED BY TARAN FROM LTT, I HAVE SIMPLY ADJUSTED IT TO WORK IN AHK v2.0
; ALSO I CURRENTLY ONLY USE A LIL NUMPAD NOT A WHOLE KEYBOARD SO EVERYTHING ELSE HAS BEEN REMOVED
; ANY OF THE SCRIPTS IN THIS FILE CAN BE PULLED OUT AND THEN REPLACED ON A NORMAL KEY ON YOUR NORMAL KEYBOARD
; This script looked very different when initially committed. Its messiness was too much of a pain for me so I've stripped a bunch of
; unnecessary comments
; \\\\\\\\///////////

unassigned() ;create a tooltip for unused keys
{
	ToolTip(A_ThisHotkey " is unassigned")
	SetTimer(timeouttime, -1000)
	timeouttime()
	{
		ToolTip("")
	}
}

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
;It's been changed to International 6 (SC05C), so you can use it with no fear that it'll mess up your numpad.

;DEFINE SEPARATE PROGRAMS FIRST, THEN ANYTHING YOU WANT WHEN NO PROGRAM IS ACTIVE ->

;===========================================================================
;
#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe") and getKeyState("F24", "P")
;
;===========================================================================
F24::return ;this line is mandatory for proper functionality
SC05C::unassigned()

Numpad0::unassigned()
Numpad1::gain("-2") ;REDUCE GAIN BY -2db
SC05C & Numpad1::gainSecondary()
Numpad2::gain("2") ;INCREASE GAIN BY 2db == set g to open gain window
Numpad3::gain("6") ;INCREASE GAIN BY 6db
Numpad4::num("2550", "0", "200") ;This script moves the "motion tab" then menus through and change values to zoom into a custom coord and zoom level
Numpad5::num("3828", "-717", "300") ;This script moves the "motion tab" then menus through and change values to zoom into a custom coord and zoom level
Numpad6::reset()  ;This script moves to the reset button to reset the "motion" effects
Numpad7::valuehold("scale.png", "scale2.png", "0") ;press then hold this hotkey and drag to increase/decrese scale. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
SC05C & Numpad7::manScale("SC05C", "Numpad7", "NumpadEnter") ;manually input a scale value
Numpad8::valuehold("position.png", "position2.png", "0") ;press then hold this hotkey and drag to increase/decrese x value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
Numpad9::valuehold("position.png", "position2.png", "60") ;press then hold this hotkey and drag to increase/decrese y value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values

;numpadSub::unassigned() ;assigned to file explorer
NumpadMult::valuehold("rotation.png", "rotation2.png", "0") ;press then hold this hotkey and drag to increase/decrease rotation. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
NumpadAdd::unassigned()
NumpadEnter::unassigned()
NumpadDot::unassigned()
NumpadDiv::movepreview() ;press then hold this hotkey and drag to move position. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
;Backspace::unassigned() ;assigned to after effects


r::unassigned() ;this is here so manScale() can function properly, it's weird, ignore it

;=============================================================================================================================================
;
#HotIf getKeyState("F24", "P") and WinActive("ahk_exe Photoshop.exe")
;
;=============================================================================================================================================
F24::return ;this line is mandatory for proper functionality
SC05C::unassigned()

Numpad0::unassigned()
Numpad1::unassigned()
Numpad2::unassigned()
Numpad3::unassigned()
Numpad4::unassigned()
numpad5::psProp("rotate.png")
Numpad6::unassigned()
Numpad7::psProp("scale.png") ;this assumes you have h/w linked. You'll need more logic if you want separate values
Numpad8::psProp("x.png")
Numpad9::psProp("y.png")

;numpadSub::unassigned() ;assigned to file explorer
NumpadMult::unassigned()
;NumpadAdd::unassigned() ;assigned to premiere
NumpadEnter::unassigned()
NumpadDot::unassigned()
NumpadDiv::unassigned()
;Backspace::unassigned() ;assigned to after effects



;===========================================================================
;
#HotIf getKeyState("F24", "P") ;<--Everything after this line will only happen on the secondary keyboard that uses F24.
;
;===========================================================================
F24::return ;this line is mandatory for proper functionality


SC05C::unassigned()

Numpad0::unassigned()
Numpad1::unassigned()
Numpad2::unassigned()
Numpad3::unassigned()
Numpad4::unassigned()
Numpad5::unassigned()
Numpad6::unassigned()
Numpad7::unassigned()
Numpad8::unassigned()
Numpad9::unassigned()

NumpadSub::switchToExplorer()
NumpadSub & NumpadMult::run "explorer.exe" ;just opens a new explorer window
NumpadMult::unassigned()
numpadAdd::switchToPremiere()
NumpadEnter::unassigned()
NumpadDot::unassigned()
NumpadDiv::unassigned()
Backspace::switchToAE()







;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/*
Everything I use so you can easy copy paste for new programs

SC05C::unassigned()

Numpad0::unassigned()
Numpad1::unassigned()
Numpad2::unassigned()
Numpad3::unassigned()
Numpad4::unassigned()
Numpad5::unassigned()
Numpad6::unassigned()
Numpad7::unassigned()
Numpad8::unassigned()
Numpad9::unassigned()

;numpadSub::unassigned() ;assigned to file explorer
NumpadMult::unassigned()
;NumpadAdd::unassigned() ;assigned to premiere
NumpadEnter::unassigned()
NumpadDot::unassigned()
NumpadDiv::unassigned()
;Backspace::unassigned() ;assigned to after effects
 */