SetWorkingDir A_ScriptDir
#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\keyboard.ico")
SetCapsLockState "AlwaysOff"
SetNumLockState "AlwaysOn"
#SingleInstance Force ;only one instance of this script may run at a time!
A_MenuMaskKey := "vk07" ;https://autohotkey.com/boards/viewtopic.php?f=76&t=57683
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm ;prevent taskbar flashing.

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.1.8
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.3.6

;\\CURRENT RELEASE VERSION
;\\v2.0

; \\\\\\\\////////////
; THIS SCRIPT WAS ORIGINALLY CREATED BY TARAN FROM LTT, I HAVE SIMPLY ADJUSTED IT TO WORK IN AHK v2.0
; ALSO I CURRENTLY ONLY USE A LIL NUMPAD NOT A WHOLE KEYBOARD SO EVERYTHING ELSE HAS BEEN REMOVED
; ANY OF THE SCRIPTS IN THIS FILE CAN BE PULLED OUT AND THEN REPLACED ON A NORMAL KEY ON YOUR NORMAL KEYBOARD
; This script looked very different when initially committed. Its messiness was too much of a pain for me so I've stripped a bunch of
; unnecessary comments
; \\\\\\\\///////////

unassigned(timeout) ;create a tooltip for unused keys
{
	ToolTip(A_ThisHotkey " is unassigned")
	sleep %&timeout%
	ToolTip("")
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
;===========================================================================
;
#HotIf getKeyState("F24", "P") ;<--Everything after this line will only happen on the secondary keyboard that uses F24.
;
;===========================================================================
F24::return ;this line is mandatory for proper functionality


SC05C::unassigned("1000")

Numpad0::unassigned("1000")
Numpad1::unassigned("1000")
Numpad2::unassigned("1000")
Numpad3::unassigned("1000")
Numpad4::unassigned("1000")
Numpad5::unassigned("1000")
Numpad6::unassigned("1000")
;Numpad7::unassigned("1000")
Numpad8::unassigned("1000")
Numpad9::unassigned("1000")

numpadSub::switchToExplorer()
NumpadSub & NumpadMult::run "explorer.exe" ;just opens a new explorer window
NumpadMult::unassigned("1000")
numpadAdd::switchToPremiere()
NumpadEnter::unassigned("1000")
numpadDot::unassigned("1000")
NumpadDiv::unassigned("1000")
Backspace::unassigned("1000")


;===========================================================================
;
#HotIf getKeyState("F24", "P") and WinActive("ahk_exe Adobe Premiere Pro.exe")
;
;===========================================================================
F24::return ;this line is mandatory for proper functionality
SC05C::unassigned("1000")

numpad0::unassigned("1000")
Numpad1::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}-2{ENTER}" ;REDUCE GAIN BY -2db
Numpad2::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}2{ENTER}" ;INCREASE GAIN BY 2db == set g to open gain window
Numpad3::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}6{ENTER}" ;INCREASE GAIN BY 6db
numpad4::num("2550", "0", "200") ;This script moves the "motion tab" then menus through and change values to zoom into a custom coord and zoom level
numpad5::num("3828", "-717", "300") ;This script moves the "motion tab" then menus through and change values to zoom into a custom coord and zoom level
numpad6::reset()  ;This script moves to the reset button to reset the "motion" effects
numpad7::valuehold("\ImageSearch\Premiere\scale.png", "\ImageSearch\Premiere\scale2.png", "0") ;press then hold this hotkey and drag to increase/decrese scale. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
SC05C & Numpad7::manScale("SC05C", "Numpad7", "Enter") ;manually input a scale value
numpad8::valuehold("\ImageSearch\Premiere\position.png", "\ImageSearch\Premiere\position2.png", "0") ;press then hold this hotkey and drag to increase/decrese x value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
numpad9::valuehold("\ImageSearch\Premiere\position.png", "\ImageSearch\Premiere\position2.png", "60") ;press then hold this hotkey and drag to increase/decrese y value. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values

;numpadSub::unassigned("1000") ;file explorer
numpadMult::valuehold("\ImageSearch\Premiere\rotation.png", "\ImageSearch\Premiere\rotation2.png", "0") ;press then hold this hotkey and drag to increase/decrease rotation. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
numpadAdd::unassigned("1000")
NumpadEnter::unassigned("1000")
numpadDot::unassigned("1000")
numpadDiv::movepreview() ;press then hold this hotkey and drag to move position. Let go of this hotkey to confirm, Simply Tap this hotkey to reset values
Backspace::unassigned("1000")



;======================================================================================================================================================
;
#HotIf getKeyState("F24", "P") and WinActive("ahk_exe Photoshop.exe")
;
;======================================================================================================================================================
F24::return ;this line is mandatory for proper functionality
SC05C::unassigned("1000")

Numpad0::unassigned("1000")
Numpad1::unassigned("1000")
Numpad2::unassigned("1000")
Numpad3::unassigned("1000")
Numpad4::unassigned("1000")
numpad5::psProp("\ImageSearch\Photoshop\rotate.png")
Numpad6::unassigned("1000")
numpad7::psProp("\ImageSearch\Photoshop\scale.png") ;this assumes you have h/w linked. You'll need more logic if you want separate values
numpad8::psProp("\ImageSearch\Photoshop\x.png")
numpad9::psProp("\ImageSearch\Photoshop\y.png")

numpadSub::unassigned("1000")
NumpadMult::unassigned("1000")
numpadAdd::unassigned("1000")
NumpadEnter::unassigned("1000")
numpadDot::unassigned("1000")
NumpadDiv::unassigned("1000")
Backspace::unassigned("1000")







;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/*
Everything I use so you can easy copy paste for new programs

SC05C::unassigned("1000")

Numpad0::unassigned("1000")
Numpad1::unassigned("1000")
Numpad2::unassigned("1000")
Numpad3::unassigned("1000")
Numpad4::unassigned("1000")
Numpad5::unassigned("1000")
Numpad6::unassigned("1000")
Numpad7::unassigned("1000")
Numpad8::unassigned("1000")
Numpad9::unassigned("1000")

numpadSub::unassigned("1000")
NumpadMult::unassigned("1000")
numpadAdd::sunassigned("1000")
NumpadEnter::unassigned("1000")
numpadDot::unassigned("1000")
NumpadDiv::unassigned("1000")
Backspace::unassigned("1000")
 */