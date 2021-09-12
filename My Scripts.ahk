#SingleInstance Force
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir
SetNumLockState "AlwaysOn" ;sets numlock to always on (you can still it for macros)
SetCapsLockState "AlwaysOff" ;sets caps lock to always off (you can still it for macros)
SetScrollLockState "AlwaysOff" ;sets scroll lock to always off (you can still it for macros)
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\myscript.png") ;changes the icon this script uses in the taskbar
#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.4.2
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.4.1
;\\Current QMK Keyboard Version\\At time of last commit
;\\v2.1.14

;\\CURRENT RELEASE VERSION
;\\v2.0

; ============================================================================================================================================
;
; 														THIS SCRIPT IS FOR v2.0 OF AUTOHOTKEY
;				 											IT WILL NOT RUN IN v1.1
;									--------------------------------------------------------------------------------
;												Everything in this script is functional within v2.0
;											any code like "blockon()" "coords()" etc are all defined
;										in the MS_functions.ahk script. Look there for specific code to edit
;
; ============================================================================================================================================
;
; This script was created by & for Tomshi (https://www.youtube.com/c/tomshiii, https://www.twitch.tv/tomshi)
; Its purpose is to help speed up editing and random interactions with windows.
; You are free to modify this script to your own personal uses/needs
; Please give credit to the foundation if you build on top of it, similar to how I have below, otherwise you're free to do as you wish
; Youtube Video going through all (at the time) of my ahk v2.0 scripts (https://youtu.be/3rFDEonACxo)
; Youtube Video going through most of the Release v2.1 changes (https://youtu.be/JF_WISVJsPU)
; Youtube Video showing how AHK can speed up editing workflows (https://youtu.be/Iv-oR7An_iI)
;
; ============================================================================================================================================

; A chunk of the code in the original versions of this script was either directly inspired by, or originally copied from Taran from LTT (https://github.com/TaranVH/) before
; I modified it to fit v2.0 of ahk and made a bunch of other changes, his videos on the subject are what got me into AHK to begin with and what brought the foundation of the original
; version of this script to life.
; I use a streamdeck to run a lot of these scripts which is why a bunch of them are separated out into their own scripts in the \Streamdeck AHK\ folder
; basic AHK is about all I know relating to code so the layout might not be "standard" but it helps me read it and maintain it which is more important since it's for personal use

; I use to use notepad++ to edit this script, if you want proper syntax highlighting in notepad++ for ahk go here: https://www.autohotkey.com/boards/viewtopic.php?t=50
; I now use VSCode which can be found here: https://code.visualstudio.com/
; AHK (and v2.0) syntax highlighting can be installed within the program itself.

;Any EnvGet() are defined in MS_Functions.ahk

;=============================================================================================================================================
;
;		Windows
;
;=============================================================================================================================================
#HotIf ;code below here (until the next #HotIf) will work anywhere
;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		launch programs
;
;---------------------------------------------------------------------------------------------------------------------------------------------
PgUp::switchToExcel() ;run microsoft excel.
Pause::switchToWindowSpy() ;run windowspy
RWin::switchToVSC() ;run vscode
ScrollLock::switchToStreamdeck() ;run the streamdeck program
PgDn::switchToFirefox() ;open firefox
!PgDn::switchToOtherFirefoxWindow() ;swap between firefox windows

;These two scripts are to open highlighted text in the ahk documentation
AppsKey:: run "https://lexikos.github.io/v2/docs/AutoHotkey.htm" ;opens ahk documentation
^AppsKey:: ;opens highlighted ahk command in the documentation
{
	A_Clipboard := "" ;clears the clipboard
	Send "^c"
	ClipWait ;waits for the clipboard to contain data
	Run "https://lexikos.github.io/v2/docs/commands/" A_Clipboard ".htm"
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other
;
;---------------------------------------------------------------------------------------------------------------------------------------------
#HotIf WinActive("ahk_class CabinetWClass") ;windows explorer
WheelLeft::SendInput "!{Up}" ;Moves back 1 folder in the tree in explorer

#HotIf WinActive("ahk_exe Code.exe")
!a::vscode("MS")
!f::vscode("Func")
!q::vscode("QMK")

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other - NOT Premiere
;
;---------------------------------------------------------------------------------------------------------------------------------------------
#HotIf not WinActive("ahk_exe Adobe Premiere Pro.exe") ;code below here (until the next #HotIf) will trigger as long as premiere pro isn't active
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
;!a:: ;ignore this version, comment it out and uncomment ^ for notepad++
;{
	;if WinExist("ahk_exe Code.exe") ;if vscode exists it'll simply activate it, if it doesn't, it'll open it
	;		WinActivate
	;else
	;	Run "C:\Users\Tom\AppData\Local\\Programs\Microsoft VS Code\Code.exe" ;opens in vscode (how I edit it)
;}

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

^+c:: ;runs a google search of highlighted text
{
	A_Clipboard := "" ;clears the clipboard
	Send "^c"
	ClipWait ;waits for the clipboard to contain data
	Run "https://www.google.com/search?d&q=" A_Clipboard
}

F14 & WheelDown::SendInput("{WheelDown 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
F14 & WheelUp::SendInput("{WheelUp 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
;=============================================================================================================================================
;
;		Discord
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Discord.exe") ;some scripts to speed up discord interactions
;SCO3A is the scancode for the CapsLock button. Had issues with using "CapsLock" as it would require a refresh every now and then before these discord scripts would work. Currently testing using the scancodes to see if that fixes it.
;alright scancodes didn't fix it, idk why but sometimes this function won't work until you refresh the main script. Might have to do with where I have it located in this script, maybe pulling it out into it's own script would fix it, or maybe discord is just dumb, who knows.
;scratch that, figured out what it is, in my qmk keyboard script I also had setcapslock to off and for whatever reason if that script was reloaded, my main script would break
SC03A & e::disc("DiscEdit.png") ;edit the message you're hovering over
SC03A & r::disc("DiscReply.png") ;reply to the message you're hovering over
SC03A & a::disc("DiscReact.png") ;add a reaction to the message you're hovering over
SC03A & d::disc("DiscDelete.png") ;delete the message you're hovering over. Also hold shift to skip the prompt

;=============================================================================================================================================
;
;		Photoshop
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Photoshop.exe")
^+p:: ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
{
	SetKeyDelay 300 ;photoshop is sometimes slow as heck, delaying things just a bit ensures you get the right thing every time
		Send "{TAB}{RIGHT}"
		SendInput "{Up 21}" ;makes sure you have the top most option selected
		sleep 50 ;this probably isn't needed, but I have here for saftey just because photoshop isn't the best performance wise
		SendInput "{DOWN 17}"
		Send "{Enter}+{Tab}"
}

XButton1::mousedrag("h","P") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset
Xbutton2::mousedrag("h", "v") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset
+z::mousedrag("z", "v") ;changes the tool to the zoom tool while z button is held ;check MS_functions.ahk for the code to this preset
!g::SendInput("!{t}" "b{Right}g") ;open gaussian blur
F1::psSave()

;=============================================================================================================================================
;
;		After Effects
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe AfterFX.exe")
Xbutton1::timeline("981", "550", "2542", "996") ;check MS_functions.ahk for the code to this preset
Xbutton2::mousedrag("h", "v") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset

;=============================================================================================================================================
;
;		Premiere
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")
;There use to be a lot of scripts about here in the script, they have since been removed and moved to their own individual .ahk files as launching them directly
;via a streamdeck is far more effecient; 1. because I only ever launch them via the streamdeck anyway & 2. because that no longer requires me to eat up a hotkey
;that I could use elsewhere, to run them. These mentioned scripts can be found in the \Streamdeck AHK\ folder.

SC03A & z::^+!z ;\\set zoom out to ^+!z\\ ;idk why tf I need the scancode for capslock here but I blame premiere
SC03A & v:: ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it
{
	coords()
	MouseGetPos &xpos, &ypos
	;MouseMove 34, 917 ;location of the selection tool
	If ImageSearch(&x, &y, 0, 854, 396, 1003, "*2 " EnvGet("Premiere") "selection.png") ;moves to the selection tool
			MouseMove(%&x%, %&y%)
	else
		{
			toolFind("selection tool", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	click
	MouseMove %&xpos%, %&ypos%
}

RAlt & p:: ;This hotkey pulls out the project window and moves it to my second monitor since adobe refuses to just save its position in your workspace
{
	KeyWait(A_PriorKey)
	blockOn()
	coords()
	MouseGetPos &xpos, &ypos
	If ImageSearch(&prx, &pry, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "project.png") ;searches for the project window to grab the track
		{
			MouseMove(%&prx% + "5", %&pry% +"3")
			SendInput("{Click Down}")
			Sleep 100
			MouseMove 2562, 223, "2"
			SendInput("{Click Up}")
			MouseMove(%&xpos%, %&ypos%)
			blockOff()
		}
	else
		{
			If ImageSearch(&pr2x, &pr2y, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "project2.png") ;searches for the project window to grab the track
			{
				MouseMove(%&pr2x% + "5", %&pr2y% +"3")
				;MsgBox()
				SendInput("{Click Down}")
				Sleep 100
				MouseMove 2562, 223, "2"
				;MsgBox()
				SendInput("{Click Up}")
				MouseMove(%&xpos%, %&ypos%)
				blockOff()
			}
			else ;if everything fails, this else will trigger
				{
					blockOff()
					toolFind("project window", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
					return
				}
		}

}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Drag and Drop Effect Presets
;
;---------------------------------------------------------------------------------------------------------------------------------------------
!g::preset("gaussian blur 20") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags one of these presets onto the hovered track
!p::preset("parametric") ;check MS_functions.ahk for the code for these presets
!h::preset("hflip")
!c::preset("croptom")

!t:: ;hover over a text element on the timeline, press this hotkey, then watch as ahk drags that preset onto the hovered track
{
	KeyWait(A_PriorKey)
	blockOn()
	coordw()
	MouseGetPos &xpos, &ypos
		SendInput("^t")
		sleep 100
		If ImageSearch(&x2, &y2, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "graphics.png")
			{
				If ImageSearch(&xeye, &yeye, %&x2%, %&y2%, %&x2% + "200", %&y2% + "100", "*2 " EnvGet("Premiere") "eye.png")
					{
						MouseMove(%&xeye%, %&yeye%)
						SendInput("{Click}")
						preset("loremipsum")
						MouseMove %&xpos%, %&ypos% ;although this line is usually in the ^preset, if you don't add it again, your curosr gets left on the text eyeball instead of back on the timeline
						blockOff()
					}
				else
					{
						blockOff()
						toolFind("the eye icon", "1000")
					}
			}
		else
			{
				blockOff()
				toolFind("the graphics tab", "1000")
			}
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
WheelRight::+Down ;Set shift down to "Go to next edit point on any track"
WheelLeft::+Up ;Set shift up to "Go to previous edit point on any track
Xbutton1::^w ;Set ctrl w to "Nudge Clip Selection Down"
Xbutton2::mousedrag("h", "v") ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset

F15:: ;drag my bleep (goose) sfx to the cursor ;I have a button on my mouse spit out F15
{
	SendInput "^+5" ;highlights the media browser
	KeyWait(A_PriorKey)
	blockOn()
	coords()
	MouseGetPos &xpos, &ypos
		SendInput "^+5" ;highlights the media browser
		sleep 10
		If ImageSearch(&sfx, &sfy, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "sfx.png") ;searches for my sfx folder in the media browser to see if it's already selected or not
			{
				MouseMove(%&sfx%, %&sfy%) ;if it isn't selected, this will move to it then click it
				SendInput("{Click}")
				goto next
			}
		else
			{
				If ImageSearch(&sfx, &sfy, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "sfx2.png") ;if it is selected, this will see it, then move on
					goto next
				else ;if everything fails, this else will trigger
					{
						blockOff()
						toolFind("sfx folder", "1000")
						return
					}
			}
		next:
		SendInput "^b" ;Requires you to set ctrl b to select find box
		coordc()
		SendInput("^a{DEL}") ;delets anything that might be in the search box
		SendInput("Goose_honk")
		sleep 50
		If ImageSearch(&vlx, &vly, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "vlc.png") ;searches for the vlc icon to grab the track
			{
				MouseMove(%&vlx%, %&vly%)
				SendInput("{Click Down}")
			}
		else
			{
				blockOff()
				toolFind("vlc image", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
				return
			}
		MouseMove(%&xpos%, %&ypos%)
		SendInput("{Click Up}")
		blockOff()
}



/*
;=============================================================================================================================================
						OLD \\ Code below here might not be converted to ahk v2.0 code
;=============================================================================================================================================
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

^MButton:: ;drag my bleep (goose) sfx to the cursor ;this is the original code for it
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
		 ;this code was to pull it out of the project window. the project windows search is stupid though
		;sleep 200
		;If ImageSearch(&x, &y, 2560, 188, 3044, 1228, "*5 " A_WorkingDir "\ImageSearch\Premiere\goose.png") ;moves to the goose sfx
		;	{
		;		MouseMove(%&x% + "20", %&y% + "5")
		;		SendInput("{Click Down}")
		;	}
		;else
		;{
		;	If ImageSearch(&x2, &y2, 2560, 188, 3044, 1228, "*5 " A_WorkingDir "\ImageSearch\Premiere\goose2.png") ;moves to the goose sfx if already highlighted
		;	{
		;		MouseMove(%&x2% + "20", %&y2% + "5")
		;		SendInput("{Click Down}")
		;	}
		;}

		MouseMove(%&xpos%, %&ypos%)
		SendInput("{Click Up}")
		;SendInput "^+6"
		;SendInput "^b" ;Requires you to set ctrl shift 6 to the projects window, then ctrl b to select find box
		;SendInput "^a{DEL}"
		;Click("middle")
		blockOff()
}
*/