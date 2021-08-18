SetWorkingDir A_ScriptDir
#Include "C:\Program Files\ahk\ahk\MS_functions.ahk"
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\keyboard.ico")

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.1.1
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.1.9

;\\CURRENT RELEASE VERSION
;\\v2.0

; \\\\\\\\
; THIS SCRIPT WAS ORIGINALLY CREATED BY TARAN FROM LTT, I HAVE SIMPLY ADJUSTED IT TO WORK IN AHK v2.0
; ALSO I CURRENTLY ONLY USE A LIL NUMPAD NOT A WHOLE KEYBOARD SO EVERYTHING ELSE IS COMMENTED OUT
; ANY OF THE SCRIPTS IN THIS FILE CAN BE PULLED OUT AND THEN REPLACED ON A NORMAL KEY ON YOUR NORMAL KEYBOARD
; \\\\\\\\


;;WHAT'S THIS ALL ABOUT??

;;THE SHORT VERSION:
;; https://www.youtube.com/watch?v=kTXK8kZaZ8c

;;THE LONG VERSION:
;; https://www.youtube.com/playlist?list=PLH1gH0v9E3ruYrNyRbHhDe6XDfw4sZdZr

;;LOCATION FOR WHERE TO PUT THIS SCRIPT:
; C:\AHK\2nd-keyboard\HASU_USB\
;;(It's not mandatory for this one, but if you use any of my other scripts, it'll make things easier later.)

;;Location for where to put a shortcut to the script, such that it will start when Windows starts:
;;  Here for just yourself:
;;  C:\Users\YOUR_USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
;;  Or here for all users:
;;  C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp


;#NoEnv
;SendMode "Input"
;InstallKeybdHook
;InstallMouseHook "true", "force" ;<--You'll want to use this if you have scripts that use the mouse.
;#UseHook True
#SingleInstance Force ;only one instance of this script may run at a time!
;A_MaxHotkeysPerInterval := 2000

;;The lines below are optional. Delete them if you need to.
;A_HotkeyModifierTimeout := 60 ; https://autohotkey.com/docs/commands/_HotkeyModifierTimeout.htm
;KeyHistory 200 ; https://autohotkey.com/docs/commands/_KeyHistory.htm ; useful for debugging.
A_MenuMaskKey := "vk07" ;https://autohotkey.com/boards/viewtopic.php?f=76&t=57683
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm ;prevent taskbar flashing.
;;The lines above are optional. Delete them if you need to.








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

#HotIf getKeyState("F24", "P") ;<--Everything after this line will only happen on the secondary keyboard that uses F24.
F24::return ;this line is mandatory for proper functionality

/*
escape::tooltip, "[F24] You might wish to not give a command to escape. Could cause problems. IDK." 

F1::coolFunction("Hello World. From F1") ;<--This is just serving as an example of how you would assign a function to a key

F2::
; tooltip, You pressed F2 on the F24 keyboard! ; This line is commented out! That's similar to deleting it, but it's still here in case you want to bring it back later!
coolFunction("Hello World. From F2")
sleep 10
msgbox, "This is how you do a multi-line key assigment. For the first line, leave the space after the :: blank, and then use a RETURN as the last line."
return

F3::
F4::
F5::
F6::
F7::
F9::
F8::
F10::
F11::
F12::tooltip, you pressed the function key %A_thishotkey% on the [F24] keyboard
;;NOTE that the assignment on the above line will apply to ALL prior lines ending in "::"
;;...which you should know from the AHK tutorial I linked you to.

;;------------------------NEXT ROW--------------------------;;

`::
1::
2::
3::
4::
5::
6::
7::
8::
9::
0::
-::
=::
backspace::tooltip, [F24]  %A_thishotKey%

;;------------------------NEXT ROW--------------------------;;

tab::
q::
w::
e::
r::
t::
y::
u::
i::
o::
p::
[::
]::
\::tooltip, [F24]  %A_thisHotKey%
;;capslock::tooltip, [F24] capslock - this should have been remapped to F20. Keep this line commented out.

;;------------------------NEXT ROW--------------------------;;

a::
s::
d::
f::
g::
h::
j::
K::
l::
`;::
;for the above line, (semicolon) note that the ` is necessary as an escape character -- and that the syntax highlighting might get it wrong.
'::
enter::tooltip, [F24]  %A_thisHotKey%

;;------------------------NEXT ROW--------------------------;;

z::
x::
c::
v::
b::
n::
m::
,::
.::
/::tooltip, [F24]  %A_thishotKey%

space::
tooltip, [F24] SPACEBAR. This will now clear remaining tooltips.
sleep 500
tooltip,
return
;;And THAT^^ is how you do multi-line instructions in AutoHotkey.
;;Notice that the very first line, "space::" cannot have anything else on it.
;;Again, these are fundamentals that you should have learned from the tutorial.


;;===================== MODIFIERS =========================;;

;Lshift::tooltip, Even if you used the "F22_with_modifiers" hex file, these woudn't be wrapped unless you were already holding down some OTHER key. hmm.
;If you DID use F24.hex, then these won't get pressed in the first place.
;Lctrl::tooltip, do not use
;Lwin::tooltip, do not use
;Lalt::tooltip, do not use

;Ralt::tooltip, do not use
;Rwin::tooltip, do not use
;appskey::tooltip, This is not a modifier, but I replaced it with INTERNATIONAL4 (SC079) anyway, because it was able to misbehave.
;Rctrl::tooltip, do not use
;Rshift::tooltip, do not use


;;If you leave the modifier keys alone, it allows for lines like the ones below:
;+z::tooltip, you pressed SHIFT Z on the F24 keyboard.
;^z::tooltip, you pressed CTRL Z on the F24 keyboard.
;!z::tooltip, you pressed ALT Z on the F24 keyboard. I don't recommend this... ALT is dangerous because of menu acceleration, even if you try to disable it like I have
;^!z::tooltip, you pressed CTRL SHIFT Z on the F24 keyboard.
;;Etc.
;;However, I use few to no modifiers on my secondary keyboards... I prefer tap dance instead. The decision is up to you.
;;If you're super confused by all this, don't be. Just use F24.hex and don't worry about the modifiers at all.
;;Also, I have to do some more testing to see if the stuff I said above is actually true, hmmmmmm.


;;================= MODIFIERS REMAPPED ======================;;

;; When you replace these with your own functions, I recommend that you do NOT delete the tooltips. Just comment them out. That way, you always know what was changed to what. It gets very confusing very quickly otherwise.
;; Here is the full list of scan code substitutions that I made:
;; https://docs.google.com/spreadsheets/d/1GSj0gKDxyWAecB3SIyEZ2ssPETZkkxn67gdIwL1zFUs/edit#gid=824607963

SC070::tooltip, [F24] Lshift -to-> SC070-International 2

;; The following 3 assignments MUST use the UP stroke - the down stroke doesn't appear for some reason.
SC071 up::tooltip, [F24] LCtrl -to-> SC071-Language 2
SC072 up::tooltip, [F24] LWin -to-> SC072-Language 1
SC073 up::tooltip, [F24] LAlt -to-> SC073-International 1
; The above 3 assignments MUST up the UP stroke

SC077::tooltip, [F24] RAlt -to-> SC077-Language 4
SC078::tooltip, [F24] RWin -to-> SC078-Language 3
SC079::tooltip, [F24] AppsKey -to-> SC079-International 4
SC07B::tooltip, [F24] RCtrl -to-> SC07B-International 5
SC07D::tooltip, [F24] RShift -to-> SC07D-International 3

;;================= LOCKING KEYS ======================;;

F20::tooltip, [F24] CapsLock -to-> SC06B-F20
SC05C::tooltip, [F24] NumLock -to-> SC05C-International 6
;Numlock is an AWFUL key. I prefer to leave it permanently on.
;It's been changed to International 6, so you can use it with no fear that it'll mess up your numpad.
;;ScrollLock is in the next section.

;;================= NEXT SECTION ======================;;

PrintScreen::tooltip, [F24] %A_thishotKey%
ScrollLock::tooltip, [F24] %A_thishotKey% ;ScrollLock is not so troublesome. I left it alone.
SC07E::tooltip, [F24] Pause -to-> SC07E-Brazillian comma

;;Don't use the 3 keys below for your 2nd keyboard!
;Pause::msgbox, The Pause/Break key is a huge PITA. That's why I remapped it to SC07E
;Break::msgbox, Or is it THIS key? WHO KNOWS!
;CtrlBreak::msgbox, I have no idea what Ctrlbreak is. But it shows up sometimes.
;;Don't use the 3 keys above for your 2nd keyboard! Just don't!!

insert::
*/
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

;;================= NEXT SECTION ======================;;

up::up
down::down
left::left
right::right

;;=========== THE NUMPAD WITH NUMLOCK ON ==============;;
;;; -- (I never turn numlock off, FYI.) -- ;;
;;Please note that SHIFT will make numlock act like it's off...
;;or is it the other way around? AGH! Just don't use shift with the numpad!

numpad0::numpad0
Numpad1::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}-2{ENTER}" ;REDUCE GAIN BY -2db
Numpad2::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}2{ENTER}" ;INCREASE GAIN BY 2db == set g to open gain window
Numpad3::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}6{ENTER}" ;INCREASE GAIN BY 6db
numpad4::numpad4


numpad5:: ;press then hold numpad5 and drag to increase/decrease rotation. Let go of numpad5 to confirm, Simply Tap numpad5 to reset values
If WinActive("ahk_exe Adobe Premiere Pro.exe")
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	;MouseMove 219, 1165 ;move to the "rotation" value
	;If ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\rotation.png") ;moves to the rotation variable ;using an imagesearch here like this is only useful if I make the mouse move across until it "finds" the blue text. idk how to do that yet so this is getting commented out for now
		;MouseMove(%&x%, %&y%)
	If PixelSearch(&xcol, &ycol, 38, 1153, 573, 1173, 0x288ccf, 3) ;looks for the blue text to the right of scale
		MouseMove(%&xcol%, %&ycol%)
	sleep 100
	SendInput "{Click Down}"
		if GetKeyState("Numpad5", "P")
		{
			blockOff()
			KeyWait "Numpad5"
			SendInput "{Click Up}"
			MouseMove %&xpos%, %&ypos%
		}
		else
		{
			fElse("0") ;check MS_functions.ahk for the code to this preset
			MouseMove %&xpos%, %&ypos%
			blockOff()
		}
}
else
	Sleep 10

numpad6:: ;press then hold numpad6 and drag to move position. Let go of numpad6 to confirm, Simply Tap numpad6 to reset values
If WinActive("ahk_exe Adobe Premiere Pro.exe")
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
else
	Sleep 10

numpad7:: ;press then hold numpad7 and drag to increase/decrese scale. Let go of numpad7 to confirm, Simply Tap numpad7 to reset values
If WinActive("ahk_exe Adobe Premiere Pro.exe")
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
		;MouseMove 227, 1101 ;move to the "scale" value
		;If ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\scale.png") ;moves to the scale variable (please note the defined coords need to be tight, otherwise it'll try to click on "uniform scale") ;using an imagesearch here like this is only useful if I make the mouse move across until it "finds" the blue text. idk how to do that yet so this is getting commented out for now
			;MouseMove(%&x%, %&y%)
		If PixelSearch(&xcol, &ycol, 42, 1092, 491, 1109, 0x288ccf, 3) ;looks for the blue text to the right of scale
			MouseMove(%&xcol%, %&ycol%)
		sleep 100
		SendInput "{Click Down}"
			if GetKeyState("Numpad7", "P")
			{
				blockOff()
				KeyWait "Numpad7"
				SendInput "{Click Up}"
				MouseMove %&xpos%, %&ypos%
			}
			else
			{
				fElse("100") ;check MS_functions.ahk for the code to this preset
				MouseMove %&xpos%, %&ypos%
				blockOff()
			}
}
else
	Sleep 10

numpad8:: ;press then hold numpad8 and drag to increase/decrese x value. Let go of numpad8 to confirm, Simply Tap numpad8 to reset values
If WinActive("ahk_exe Adobe Premiere Pro.exe")
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
		;MouseMove 226, 1079 ;move to the "x" value
		;If ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\position.png") ;moves to the position variable ;using an imagesearch here like this is only useful if I make the mouse move across until it "finds" the blue text. idk how to do that yet so this is getting commented out for now
			;MouseMove(%&x%, %&y%)
		If PixelSearch(&xcol, &ycol, 100, 1081, 540, 1087, 0x288ccf, 3) ;looks for the blue text to the right of scale
			MouseMove(%&xcol%, %&ycol%)
		sleep 100
		SendInput "{Click Down}"
			if GetKeyState("Numpad8", "P")
			{
				blockOff()
				KeyWait "Numpad8"
				SendInput "{Click Up}"
				MouseMove %&xpos%, %&ypos%
			}
			else
			{
				fElse("960") ;check MS_functions.ahk for the code to this preset
				MouseMove %&xpos%, %&ypos%
				blockOff()
			}
}
else
	Sleep 10

numpad9:: ;press then hold numpad9 and drag to increase/decrese y value. Let go of numpad9 to confirm, Simply Tap numpad9 to reset values
If WinActive("ahk_exe Adobe Premiere Pro.exe")
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	;MouseMove 275, 1080 ;move to the "y" value
	;If ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\position.png") ;moves to the position variable ;using an imagesearch here like this is only useful if I make the mouse move across until it "finds" the blue text. idk how to do that yet so this is getting commented out for now
		;MouseMove(%&x%, %&y%)
	If PixelSearch(&xcol, &ycol, 100, 1081, 540, 1087, 0x288ccf, 3) ;looks for the blue text to the right of scale
		MouseMove(%&xcol% + "60", %&ycol%) ;moves to the second value (the y value)
	sleep 100
	SendInput "{Click Down}"
		if GetKeyState("Numpad9", "P")
		{
			blockOff()
			KeyWait "Numpad9"
			SendInput "{Click Up}"
			MouseMove %&xpos%, %&ypos%
		}
		else
		{
			fElse("540") ;check MS_functions.ahk for the code to this preset
			MouseMove %&xpos%, %&ypos%
			blockOff()
		}
}
else
	Sleep 10

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

numpadSub::{
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

numpadEnter::numpadEnter
numpadDot::numpadDot

;;================== JUST IN CASE ======================;;
; I tested a CoolerMaster keyboard that had P1 P2 P3 and P4 keys on it,
; which corresponded to some of the super function keys. (F13-F24)
; So I've put those below too, just in case you have the same thing.
; You don't have the option to NOT wrap them, unless you make your own hex file.
/*
F13::
F14::
F15::
F16::
F17::
F18::
F19::tooltip, [F24] %A_thishotKey%
;;;F20:: already used by CapsLock
;;F21::meh
;;F24::might be used by some other keyboard
;;F23::might be used by some other keyboard
;;F24::do not use
 */
;;== MEDIA KEYS CANNOT BE WRAPPED IN F24 WITH THE USB CONVERTER ==;;
;;; otherwise they would be here :(

;;============== END OF ALL KEYBOARD KEYS ===============;;

;#HotIf ;this line will end the F24 secondary keyboard assignments.


;;;---------------IMPORTANT: HOW TO USE #IF THINGIES-------------------

;;You can use more than one #if thingy at a time, but it must be done like so:
;#Hotif (getKeyState("F24", "P")) and WinActive("ahk_exe Adobe Premiere Pro.exe")
;F1:: ;msgbox, You pressed F1 on your secondary keyboard while inside of Premiere Pro

;; HOWEVER, You still would still need to block F1 using #if (getKeyState("F24", "P"))
;; If you don't, it'll pass through normally, any time Premiere is NOT active.
;; Does that make sense? I sure hope so. Experiment with it if you don't understand.

;; Alternatively, you can use the following: (Comment it in, and comment out other instances of F1::)
; #if (getKeyState("F24", "P"))
; F1::
; if WinActive("ahk_exe Adobe Premiere Pro.exe")
; {
	; msgbox, You pressed F1 on your secondary keyboard while inside of Premiere Pro
	; msgbox, And you did it by using if WinActive()
; }
; else
	; msgbox, You pressed F1 on your secondary keyboard while NOT inside of Premiere Pro
;;This is easier to understand, but it's not as clean of a solution.

;; Here is a discussion about all this:
;; https://github.com/TaranVH/2nd-keyboard/issues/65

;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;+++++++++++++++++ END OF SECOND KEYBOARD F24 ASSIGNMENTS ++++++++++++++++++++++
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;;Note that this whole script was written for North American keyboard layouts.
;;IDK what you foreign language peoples are gonna have to do!
;;At the very least, you'll have some duplicate keys.


;;*******************************************************************************
;;*************DEFINE YOUR NORMAL KEY ASSIGNMENTS BELOW THIS LINE****************
;;*******************************************************************************
/*
;;If you assign them BEFORE the second keyboard, they'll overrule it. You don't want that.
#ifwinactive ahk_exe ahk_exe Adobe Premiere Pro.exe
F2::msgbox, You pressed F2 on your normal keyboard while inside of Premiere Pro. `nThis is an autohotkey script by the way - in case you forgot.`nCheck your taskbar to find it.
;; You can of course delete the above line.
#ifwinactive
;;~~~~~~~~~~~~~~~~~DEFINE YOUR FUNCTIONS BELOW THIS LINE~~~~~~~~~~~~~~~~~~~~~~~~~
 */
/*
coolFunction(stuff)
{
msgbox, You called a function with the following parameter:`n`n%stuff%`n`nCongrats!
msgbox, You can put whatever you like in here. `nI've provided links to the functions I use.
; https://github.com/TaranVH/2nd-keyboard/blob/master/Almost_All_Premiere_Functions.ahk
; https://github.com/TaranVH/2nd-keyboard/blob/master/Almost_All_Windows_Functions.ahk
; NOTE that I use #include, rather than writing them out in the same .ahk file.
; https://autohotkey.com/docs/commands/_Include.htm
; This allows me to do fancy stuff, like direct launching scripts from my Stream Deck.
; But you don't need to do that at all. Just write out your functions in the same script.
}

anotherFunction(yeah)
{
msgbox, yup %yeah%
;Just delete this function, lol
}

 */