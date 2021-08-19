#SingleInstance Force
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir
SetNumLockState "AlwaysOn" ;sets numlock to always on
SetCapsLockState "AlwaysOff" ;sets caps lock to always off (you can still use caps lock for macros)
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\myscript.png") ;changes the icon this script uses in the taskbar
#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.2.22
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.1.10

;\\CURRENT RELEASE VERSION
;\\v2.0

; ===========================================================================================================================================================
;
; 														THIS SCRIPT IS FOR v2.0 OF AUTOHOTKEY
;				 											IT WILL NOT RUN IN v1.1
;									--------------------------------------------------------------------------------
;												Everything in this script is functional within v2.0
;											any code like "blockon()" "coords()" etc are all defined
;										in the MS_functions.ahk script. Look there for specific code to edit
;
; ===========================================================================================================================================================
;
; This script was created by & for Tomshi (https://www.youtube.com/c/tomshiii, https://www.twitch.tv/tomshi)
; Its purpose is to help speed up editing and random interactions with windows.
; You are free to modify this script to your own personal uses/needs
; Please give credit to the foundation if you build on top of it, similar to how I have below, otherwise you're free to do as you wish
; Youtube Video going through all (at the time) of my ahk v2.0 scripts (https://youtu.be/3rFDEonACxo)
; Youtube Video showing how AHK can speed up editing workflows (https://youtu.be/Iv-oR7An_iI)
;
; ===========================================================================================================================================================

; A chunk of the code in the original versions of this script was either directly inspired by, or originally copied from Taran from LTT (https://github.com/TaranVH/) before
; I modified it to fit v2.0 of ahk and made a bunch of other changes, his videos on the subject are what got me into AHK to begin with and what brought the foundation of the original
; version of this script to life.
; I use a streamdeck to run a lot of these scripts which is why a bunch of them are separated out into their own scripts in the \Streamdeck AHK\ folder
; basic AHK is about all I know relating to code so the layout might not be "standard" but it helps me read it and maintain it which is more important since it's for personal use

; I use to use notepad++ to edit this script, if you want proper syntax highlighting in notepad++ for ahk go here: https://www.autohotkey.com/boards/viewtopic.php?t=50
; I now use VSCode which can be found here: https://code.visualstudio.com/
; AHK (and v2.0) syntax highlighting can be installed within the program itself.

;===========================================================================================================================================================================
;
;		Windows
;
;===========================================================================================================================================================================
#HotIf not WinActive("ahk_exe Adobe Premiere Pro.exe") ;code below here (until the next HotIf) will trigger as long as premiere pro isn't active
^!w:: ;this simply warps my mouse to my far monitor bc I'm lazy YEP
{
	coords()
	MouseMove 5044, 340
}

^!+w:: ;this simply warps my mouse to my main monitor bc I'm lazy YEP
{
	coords()
	MouseMove 1280, 720
}

^+a::Run "C:\Program Files\ahk\ahk" ;opens my script directory

;!a:: ;edit %a_ScriptDir% ;opens this script in notepad++ if you replace normal notepad with ++ \\don't recommend using this way at all, replacing notepad kinda sucks
;!a:: Run *RunAs "C:\Program Files (x86)\Notepad++\notepad++.exe" "%A_ScriptFullPath%" ;opens in notepad++ without needing to fully replace notepad with notepad++ (preferred) \\use this way
;Opens as admin bc of how I have my scripts located, if you don't need it elevated, remove *RunAs
!a:: ;ignore this version, comment it out and uncomment ^ for notepad++
{
	if WinExist("ahk_exe Code.exe") ;if vscode exists it'll simply activate it, if it doesn't, it'll open it
			WinActivate
	else
		Run "C:\Users\Tom\AppData\Local\\Programs\Microsoft VS Code\Code.exe" ;opens in vscode (how I edit it)
}

!r::
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

^+d:: ;Make discord bigger so I can actually read stuff when not streaming
{
	if WinExist("ahk_exe Discord.exe")
	WinMove 4480, -260, 1080, 1488
}

^SPACE::WinSetAlwaysOnTop -1, "A" ; will toggle the current window to remain on top

NumLock::Run A_ProgramFiles "\Microsoft Office\root\Office16\EXCEL.EXE" ;run microsoft excel.

^+c:: ;runs a google search of highlighted text
{
	A_Clipboard := "" ;clears the clipboard
	Send "^c"
	ClipWait ;waits for the clipboard to contain data
	Run "https://www.google.com/search?d&q=" A_Clipboard
}

;These two scripts are to open highlighted text in the ahk documentation
AppsKey:: run "https://lexikos.github.io/v2/docs/AutoHotkey.htm" ;opens ahk documentation
^AppsKey:: ;opens highlighted ahk command in the documentation
{
	A_Clipboard := "" ;clears the clipboard
	Send "^c"
	ClipWait ;waits for the clipboard to contain data
	Run "https://lexikos.github.io/v2/docs/commands/" A_Clipboard ".htm"
}

#HotIf WinActive("ahk_exe Discord.exe") ;some scripts to speed up discord interactions
CapsLock & e::disc("\ImageSearch\Discord\DiscEdit.png") ;edit the message you're hovering over
CapsLock & r::disc("\ImageSearch\Discord\DiscReply.png") ;reply to the message you're hovering over
CapsLock & a::disc("\ImageSearch\Discord\DiscReact.png") ;add a reaction to the message you're hovering over
CapsLock & d::disc("\ImageSearch\Discord\DiscDelete.png") ;delete the message you're hovering over. Also hold shift to skip the prompt

;===========================================================================================================================================================================
;
;		Photoshop
;
;===========================================================================================================================================================================
#HotIf WinActive("ahk_exe Photoshop.exe")
^+p:: ;When highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
{
	SetKeyDelay 300 ;photoshop is sometimes slow as heck, delaying things just a bit ensures you get the right thing every time
		Send "{TAB}{RIGHT}"
		SendInput "{Up 21}" ;makes sure you have the top most option selected
		sleep 50 ;this probably isn't needed, but I have here for saftey just because photoshop isn't the best performance wise
		SendInput "{DOWN 17}"
		Send "{Enter}+{Tab}"
}

XButton1::mousedrag("h", "XButton1", "P") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset
Xbutton2::mousedrag("h", "XButton2", "v") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset
+z::mousedrag("z", "z", "v") ;changes the tool to the zoom tool while z button is held ;check MS_functions.ahk for the code to this preset

;===========================================================================================================================================================================
;
;		After Effects
;
;===========================================================================================================================================================================
#HotIf WinActive("ahk_exe AfterFX.exe")
Xbutton1::timeline("981") ;check MS_functions.ahk for the code to this preset
Xbutton2::mousedrag("h", "XButton2", "v") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset

;===========================================================================================================================================================================
;
;		Premiere
;
;===========================================================================================================================================================================
#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")

;There use to be a lot of scripts about here in the script, they have since been removed and moved to their own individual .ahk files as launching them directly
;via a streamdeck is far more effecient; 1. because I only ever launch them via the streamdeck anyway & 2. because that no longer requires me to eat up a hotkey
;that I could use elsewhere, to run them. These mentioned scripts can be found in the \Streamdeck AHK\ folder.

CapsLock & z::^+!z ;\\set zoom out to ^+!z\\
CapsLock & v:: ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it
{
	coords()
	MouseGetPos &xpos, &ypos
	;MouseMove 34, 917 ;location of the selection tool
	If ImageSearch(&x, &y, 0, 854, 396, 1003, "*2 " A_WorkingDir "\ImageSearch\Premiere\selection.png") ;moves to the selection tool
			MouseMove(%&x%, %&y%)
	click
	MouseMove %&xpos%, %&ypos%
}

^F1:: ;clicks the scale window so you can input your own values - then waits for you to hit enter to warp the cursor back 
{
	coords()
	BlockInput "MouseMove"
	BlockInput "On"
	MouseGetPos &xpos, &ypos
	If PixelSearch(&xcol, &ycol, 42, 1092, 491, 1109, 0x288ccf, 3) ;looks for the blue text to the right of scale
		MouseMove(%&xcol%, %&ycol%)
	KeyWait("F1") ;waits for you to let go of F1
	SendInput "{Click}"
	KeyWait("``", "D") ;waits until the ` is pressed before continuing
	SendInput("{Enter}")
	MouseMove %&xpos%, %&ypos%
	Click("middle")
	blockOff()
}

^MButton:: ;drag my bleep (goose) sfx to the cursor
{
	KeyWait("Ctrl")
	KeyWait("MButton")
	blockOn()
	coords()
	MouseGetPos &xpos, &ypos
		SendInput "^+5"
		sleep 100
		click "2299", "1048"
		SendInput "^b" ;Requires you to set ctrl shift 6 to the projects window, then ctrl b to select find box
		coordc()
		SendInput "^a{DEL}"
		SendInput("Goose_honk")
		CaretGetPos(&carx, &cary)
		MouseMove(%&carx% - "60", %&cary% + "60")
		sleep 50
		SendInput("{Click Down}")
		/* ;this code was to pull it out of the project window. the project windows search is stupid though
		sleep 200
		If ImageSearch(&x, &y, 2560, 188, 3044, 1228, "*5 " A_WorkingDir "\ImageSearch\Premiere\goose.png") ;moves to the goose sfx
			{
				MouseMove(%&x% + "20", %&y% + "5")
				SendInput("{Click Down}")
			}
		else
		{
			If ImageSearch(&x2, &y2, 2560, 188, 3044, 1228, "*5 " A_WorkingDir "\ImageSearch\Premiere\goose2.png") ;moves to the goose sfx if already highlighted
			{
				MouseMove(%&x2% + "20", %&y2% + "5")
				SendInput("{Click Down}")
			}
		}
		*/
		MouseMove(%&xpos%, %&ypos%)
		SendInput("{Click Up}")
		;SendInput "^+6"
		;SendInput "^b" ;Requires you to set ctrl shift 6 to the projects window, then ctrl b to select find box
		;SendInput "^a{DEL}"
		;Click("middle")
		blockOff()
}

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;		hold and drag (or click)
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
F1::valuehold("42", "1092", "491", "1109", "F1", "100", "0") ;press then hold F1 and drag to increase/decrese scale. Let go of F1 to confirm, Simply Tap F1 to reset values
F2::valuehold("100", "1081", "540", "1087", "F2", "960", "0") ;press then hold F2 and drag to increase/decrese x value. Let go of F2 to confirm, Simply Tap F2 to reset values
F3::valuehold("100", "1081", "540", "1087", "F3", "540", "60") ;press then hold F3 and drag to increase/decrese y value. Let go of F3 to confirm, Simply Tap F3 to reset values

F4:: ;press then hold F4 and drag to move position. Let go of F4 to confirm, Simply Tap F4 to reset values
{
	;SendInput, d ;d must be set to "select clip at playhead" //if a clip is already selected the effects disappear :)
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
	;MouseMove 142, 1059 ;move to the "motion" tab
	If ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\motion.png") ;moves to the motion tab
			MouseMove(%&x% + "25", %&y%)
	sleep 100
	if GetKeyState("F4", "P") ;gets the state of the f4 key, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
		{ ;you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable to move the preview window
			Click
			MouseMove 2300, 238 ;move to the preview window
			SendInput "{Click Down}"
			blockOff()
			KeyWait "F4"
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

F5::valuehold("38", "1153", "573", "1173", "F5", "0", "0") ;press then hold F5 and drag to increase/decrease rotation. Let go of F5 to confirm, Simply Tap F5 to reset values

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;		NUMPAD SCRIPTS
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Numpad7::num("2550", "0", "200") ;This script moves the "motion tab" then menus through and change values to zoom into a custom coord and zoom level
Numpad8::num("3828", "-717", "300") ;This script moves the "motion tab" then menus through and change values to zoom into a custom coord and zoom level
Numpad9:: ;This script moves the reset button to reset the "motion" effects
{
	coordw()
	blockOn()
	MouseGetPos &xpos, &ypos
		SendInput "^+9"
		SendInput "{F12}" ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
		;MouseMove 359, 1063 ;location for the reset arrow
		if ImageSearch(&xcol, &ycol, 8, 1049, 589, 1090, "*2 " A_WorkingDir "\ImageSearch\Premiere\reset.png") ;these coords are set higher than they should but for whatever reason it only works if I do that????????
			MouseMove(%&xcol%, %&ycol%)
		;SendInput, {WheelUp 10} ;if you do this, for whatever reason "click" no longer works without an insane amount of delay, idk why
		click
	MouseMove %&xpos%, %&ypos%
	blockOff()
}

Numpad1::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}-2{ENTER}" ;REDUCE GAIN BY -2db
Numpad2::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}2{ENTER}" ;INCREASE GAIN BY 2db == set g to open gain window
Numpad3::SendInput "g" "+{Tab}{UP 3}{DOWN}{TAB}6{ENTER}" ;INCREASE GAIN BY 6db



;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;		Drag and Drop Effect Presets
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
!g::preset("gaussian blur 20") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags one of these presets onto the hovered track
!p::preset("parametric") ;check MS_functions.ahk for the code for these presets
!h::preset("hflip") 
!c::preset("croptom") 

!t:: ;hover over a text element on the timeline, press this hotkey, then watch as ahk drags that preset onto the hovered track
{
	blockOn()
	coords()
	MouseGetPos &xpos, &ypos
		MouseMove 205, 1039 ;move to the top of the effects panel to allow WheelUp to work
		sleep 100
		SendInput "{WheelUp 10}"
		MouseMove 31, 1080 ;hover over the hide/show eye for the default text created on a new text layer
		sleep 500 ;apparently if you don't give premiere half a second before trying to hide a text layer, it just doesn't click?? or it's ahk??
		Click
		sleep 100
		preset("loremipsum")
		MouseMove %&xpos%, %&ypos% ;although this line is usually in the ^preset, if you don't add it again, your curosr gets left on the text eyeball instead of back on the timeline 
}

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WheelRight::+Down ;Set shift down to "Go to next edit point on any track"
WheelLeft::+Up ;Set shift up to "Go to previous edit point on any track
Xbutton1::^w ;Set ctrl w to "Nudge Clip Selection Down"
Xbutton2::mousedrag("h", "XButton2", "v") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset





/*
;===========================================================================================================================================================================
						OLD \\ Code below here might not be converted to ahk v2.0 code
;===========================================================================================================================================================================
F6:: ;how to move mouse on one axis
SetKeyDelay, 0
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseGetPos, xposP, yposP
MouseMove, xposP, 513,, R
Return
F6:: ;how to move mouse on one axis, relative to current position
SetKeyDelay, 0
coordmode, pixel, Screen
coordmode, mouse, Screen
MouseMove, 0, 513,, R
Return
*/