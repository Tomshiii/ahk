SetWorkingDir A_ScriptDir
#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\keyboard.ico")
SetCapsLockState "AlwaysOff"
#SingleInstance Force ;only one instance of this script may run at a time!
A_MenuMaskKey := "vk07" ;https://autohotkey.com/boards/viewtopic.php?f=76&t=57683
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm ;prevent taskbar flashing.

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.1.3
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.1.12

;\\CURRENT RELEASE VERSION
;\\v2.0

; \\\\\\\\////////////
; THIS SCRIPT WAS ORIGINALLY CREATED BY TARAN FROM LTT, I HAVE SIMPLY ADJUSTED IT TO WORK IN AHK v2.0
; ALSO I CURRENTLY ONLY USE A LIL NUMPAD NOT A WHOLE KEYBOARD SO EVERYTHING ELSE HAS BEEN REMOVED
; ANY OF THE SCRIPTS IN THIS FILE CAN BE PULLED OUT AND THEN REPLACED ON A NORMAL KEY ON YOUR NORMAL KEYBOARD
; This script looked very different when initially committed. Its messiness was too much of a pain for me so I've stripped a bunch of
; unnecessary comments
; \\\\\\\\///////////

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

;; You should probably use something better than Notepad for your scripting. (Do NOT use Word.)
;; I use Notepad++. "Real" programmers recoil from it, but it's fine for my purposes.
;; https://notepad-plus-plus.org/
;; You'll probably want the syntax highlighting:  https://stackoverflow.com/questions/45466733/autohotkey-syntax-highlighting-in-notepad

;;COOL BONUS BECAUSE YOU'RE USING QMK:
;;The up and down keystrokes are registered seperately.
;;Therefore, your macro can do half of its action on the down stroke,
;;And the other half on the up stroke. (using "keywait,")
;;This can be very handy in specific situations.
;;The Corsair K55 keyboard fires the up and down keystrokes instantly.

;===========================================================================
#HotIf getKeyState("F24", "P") ;<--Everything after this line will only happen on the secondary keyboard that uses F24.
;===========================================================================
F24::return ;this line is mandatory for proper functionality


;;================= LOCKING KEYS ======================;;

;SC05C::tooltip, [F24] NumLock -to-> SC05C-International 6
;Numlock is an AWFUL key. I prefer to leave it permanently on.
;It's been changed to International 6, so you can use it with no fear that it'll mess up your numpad.

;;================= NEXT SECTION ======================;;


;;Don't use the 3 keys below for your 2nd keyboard!
;Pause::msgbox, The Pause/Break key is a huge PITA. That's why I remapped it to SC07E
;Break::msgbox, Or is it THIS key? WHO KNOWS!
;CtrlBreak::msgbox, I have no idea what Ctrlbreak is. But it shows up sometimes.
;;Don't use the 3 keys above for your 2nd keyboard! Just don't!!


delete::delete
home::home
end::end
pgup::pgup
pgdn::pgdn
Backspace::
{
	;switchToFirefox(){
	sendinput "{SC0E8}" ;scan code of an unassigned key. Do I NEED this?
	if not WinExist("ahk_class MozillaWindowClass")
		Run "firefox.exe"
	if WinActive("ahk_exe firefox.exe")
		{
		Class := WinGetClass("A")
		;WinGetClass class, A
		if (class = "Mozillawindowclass1")
			msgbox "this is a notification"
		}
	if WinActive("ahk_exe firefox.exe")
		Send "^{tab}"
	else
		{
		;WinRestore ahk_exe firefox.exe
		WinWaitActive "ahk_exe firefox.exe"
		;sometimes winactivate is not enough. the window is brought to the foreground, but not put into FOCUS.
		;the below code should fix that.
		;Controls := WinGetControlsHwnd("ahk_class MozillaWindowClass")
		;WinGet hWnd ID ahk_class MozillaWindowClass
		;Result := DllCall("SetForegroundWindow UInt hWnd")
		;DllCall("SetForegroundWindow" UInt hWnd) 
		}
	}

numpadSub::
	{
		;switchToExplorer(){
		if not WinExist("ahk_class CabinetWClass")
			Run "explorer.exe"
		GroupAdd "taranexplorers", "ahk_class CabinetWClass"
		if WinActive("ahk_exe explorer.exe")
			GroupActivate "taranexplorers", "r"
		else
			if WinExist("ahk_class CabinetWClass")
			WinActivate "ahk_class CabinetWClass" ;you have to use WinActivatebottom if you didn't create a window group.
	}
	
numpadAdd::
	{
		;switchToPremiere(){
		if not WinExist("ahk_class Premiere Pro")
			{
			;Run, Adobe Premiere Pro.exe
			;Adobe Premiere Pro CC 2017
			; Run, C:\Program Files\Adobe\Adobe Premiere Pro CC 2017\Adobe Premiere Pro.exe ;if you have more than one version instlaled, you'll have to specify exactly which one you want to open.
			Run "Adobe Premiere Pro.exe"
			}
		else
			if WinExist("ahk_class Premiere Pro")
			WinActivate "ahk_class Premiere Pro"
	}


;===========================================================================
#HotIf getKeyState("F24", "P") and WinActive("ahk_exe Adobe Premiere Pro.exe")
;===========================================================================
F24::return ;this line is mandatory for proper functionality

delete::delete
home::home
end::end
pgup::pgup
pgdn::pgdn
up::up
down::down
left::left
right::right

numpad0::numpad0
Numpad1::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}-2{ENTER}" ;REDUCE GAIN BY -2db
Numpad2::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}2{ENTER}" ;INCREASE GAIN BY 2db == set g to open gain window
Numpad3::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}6{ENTER}" ;INCREASE GAIN BY 6db
numpad4::numpad4
numpad5::valuehold("38", "1153", "573", "1173", "Numpad5", "0", "0") ;press then hold numpad5 and drag to increase/decrease rotation. Let go of numpad5 to confirm, Simply Tap numpad5 to reset values
numpad6:: ;press then hold numpad6 and drag to move position. Let go of numpad6 to confirm, Simply Tap numpad6 to reset values
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	;MouseMove 142, 1059 ;move to the "motion" tab
	If ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\motion.png") ;moves to the motion tab
			MouseMove(%&x% + "25", %&y%)
	sleep 100
	if GetKeyState("Numpad6", "P") ;gets the state of the f4 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
		{ ;you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable to move the preview window
			Click
			MouseMove 2300, 238 ;move to the preview window
			SendInput "{Click Down}"
			blockOff()
			KeyWait "Numpad6"
			SendInput "{Click Up}"
			;MouseMove %&xpos%, %&ypos% ; // moving the mouse position back to origin after doing this is incredibly disorienting
		}
	else
		{
			;MouseMove 352, 1076 ;move to the reset arrow
			if ImageSearch(&xcol, &ycol, 8, 1049, 589, 1090, "*2 " A_WorkingDir "\ImageSearch\Premiere\reset.png") ;these coords are set higher than they should but for whatever reason it only works if I do that????????
					MouseMove(%&xcol%, %&ycol%)
			Click
			sleep 50
			MouseMove %&xpos%, %&ypos%
			blockOff()
		}
}

numpad7::valuehold("42", "1092", "491", "1109", "Numpad7", "100", "0") ;press then hold numpad7 and drag to increase/decrese scale. Let go of numpad7 to confirm, Simply Tap numpad7 to reset values
numpad8::valuehold("100", "1081", "540", "1087", "Numpad8", "960", "0") ;press then hold numpad8 and drag to increase/decrese x value. Let go of numpad8 to confirm, Simply Tap numpad8 to reset values
numpad9::valuehold("100", "1081", "540", "1087", "Numpad9", "540", "60") ;press then hold numpad9 and drag to increase/decrese y value. Let go of numpad9 to confirm, Simply Tap numpad9 to reset values

;;============ THE NUMPAD WITH NUMLOCK OFF ============;;
numpadins::numpadins
numpadend::numpadend
numpaddown::numpaddown
numpadpgdn::numpadpgdn
numpadleft::numpadleft
numpadclear::numpadclear
numpadright::numpadright
numpadhome::numpadhome
numpadup::numpadup
numpadpgup::numpadpgup

;;====== NUMPAD KEYS THAT DON'T CARE ABOUT NUMLOCK =====;;
;;NumLock::tooltip, DO NOT USE THE NUMLOCK KEY IN YOUR 2ND KEYBOARD! I have replaced it with SC05C-International 6
numpadDiv::numpadDiv
numpadMult::numpadMult
numpadEnter::numpadEnter
numpadDot::numpadDot



;===========================================================================
#HotIf getKeyState("F24", "P") and WinActive("ahk_exe Photoshop.exe")
;===========================================================================
F24::return ;this line is mandatory for proper functionality

numpad5::psProp("Numpad5", "\ImageSearch\Photoshop\rotate.png")
numpad7::psProp("Numpad7", "\ImageSearch\Photoshop\scale.png") ;this assumes you have h/w linked. You'll need more logic if you want separate values
numpad8::psProp("Numpad8", "\ImageSearch\Photoshop\x.png")
numpad9::psProp("Numpad9", "\ImageSearch\Photoshop\y.png")