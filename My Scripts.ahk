#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir ;sets the scripts working directory to the directory it's launched from
SetNumLockState "AlwaysOn" ;sets numlock to always on (you can still it for macros)
SetCapsLockState "AlwaysOff" ;sets caps lock to always off (you can still it for macros)
SetScrollLockState "AlwaysOff" ;sets scroll lock to always off (you can still it for macros)
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\myscript.png") ;changes the icon this script uses in the taskbar
#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script otherwise you need a full filepath

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.7.11
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.7.17
;\\Current QMK Keyboard Version\\At time of last commit
;\\v2.3

;\\CURRENT RELEASE VERSION
;\\v2.2.4

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
; Youtube playlist going through all my AHK changes/updates (https://www.youtube.com/playlist?list=PL8txOlLUZiqXXr2PNOsNSXeCB1171lQ1b)
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
#SuspendExempt ;this and the below "false" are required so you can turn off suspending this script with the hotkey listed below
#+r:: ;this reload script will now attempt to reload all of my scripts, not only this main script
{
	DetectHiddenWindows True  ; Allows a script's hidden main window to be detected.
	SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.
	if WinExist("QMK Keyboard.ahk")
		PostMessage 0x0111, 65303,,, "QMK Keyboard.ahk - AutoHotkey"
	if WinExist("Resolve_Example.ahk")
		PostMessage 0x0111, 65303,,, "Resolve_Example.ahk - AutoHotkey"
	if WinExist("textreplace.ahk")
		PostMessage 0x0111, 65303,,, "textreplace.ahk - AutoHotkey"
	if WinExist("right click premiere.ahk")
		PostMessage 0x0111, 65303,,, "right click premiere.ahk - AutoHotkey"
	Reload
	Sleep 1000 ; if successful, the reload will close this instance during the Sleep, so the line below will never be reached.
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

#+`::Suspend -1 ;suspends this script. Useful when playing games as this script will try and do whacky stuff while gaming
#SuspendExempt false
;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		launch programs
;
;---------------------------------------------------------------------------------------------------------------------------------------------
PgUp::switchToExcel() ;run microsoft excel.
Pause::switchToWindowSpy() ;run windowspy
RWin::switchToVSC() ;run vscode
ScrollLock::switchToStreamdeck() ;run the streamdeck program
PgDn::firefoxTap() ;open firefox with one tap, switches between windows with two, runs another insance with three
PrintScreen::SendInput("^+{Esc}")

;These two scripts are to open highlighted text in the ahk documentation
AppsKey:: run "https://lexikos.github.io/v2/docs/AutoHotkey.htm" ;opens ahk documentation
^AppsKey:: ;opens highlighted ahk command in the documentation
{
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	ClipWait ;waits for the clipboard to contain data
	Run "https://lexikos.github.io/v2/docs/commands/" A_Clipboard ".htm"
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other
;
;---------------------------------------------------------------------------------------------------------------------------------------------
#HotIf WinActive("ahk_class CabinetWClass") ;windows explorer
WheelLeft::SendInput("!{Up}") ;Moves back 1 folder in the tree in explorer
F14:: ;open the "show more options" menu in win11
{
	if GetKeyState("LButton", "P") ;this is here so that moveWin() can function within windows Explorer. It is only necessary because I use the same button for both scripts.
		{
			SendInput("{LButton Up}")
			WinMaximize
			return
		}
	else if ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, "*5 C:\Program Files\ahk\ahk\ImageSearch\Windows\Win11\Explorer\showmore.png")
		{
			SendInput("{Esc}")
			SendInput("+{F10}")
			/*
			MouseMove(%&x% + "3", %&y% + "3")
			click
			MouseMove(%&mx%, %&my%) ;why does win11 open the new menu FROM the button instead of replacing the old menu ffs
			*/ ;return it to this way if ms ever fixes^
			return
		}
	else
		{
			SendInput("+{F10}")
		}
}

#HotIf WinActive("ahk_exe Code.exe")
!a::vscode("MS") ;clicks on the my scripts script in vscode
!f::vscode("Func") ;clicks on my msfunctions script in vscode 
!q::vscode("QMK") ;clicks on my qmk script in vscode
!c::vscode("Change") ;clicks on my changelog file in vscode

#HotIf WinActive("ahk_exe firefox.exe")
Media_Play_Pause:: ;pauses youtube video if there is one.
{
	SetTitleMatchMode 2
	needle := "YouTube"
	Loop 40
		{
			title := WinGetTitle("A")
			;WinGetTitle title
			if not WinActive("ahk_exe firefox.exe")
				break
			if (InStr(title, needle))
				Break
			Else
				send "^{Tab}"
			sleep 25
			if A_Index = 8
				switchToOtherFirefoxWindow()
			if A_Index = 16
				switchToOtherFirefoxWindow()
			if A_Index = 24
				switchToOtherFirefoxWindow()
			if A_Index = 30
				switchToOtherFirefoxWindow()
			if A_Index = 36
				{
					SendInput("{Media_Play_Pause}") ;if it can't find a youtube window it will simply send through a regular play pause input
					return
				}
		}
	SendInput("{Space}") ;if it finds a youtube window it will hit space to pause/play it
}
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
SC03A & r::disc("DiscReply.png") ;reply to the message you're hovering over ;this reply hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
SC03A & a::disc("DiscReact.png") ;add a reaction to the message you're hovering over
SC03A & d::disc("DiscDelete.png") ;delete the message you're hovering over. Also hold shift to skip the prompt

;=============================================================================================================================================
;
;		Photoshop
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Photoshop.exe")
^+p::psType("png") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
^+j::psType("jpg") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a jpg instead of the default psd

XButton1::mousedrag(handTool, penTool) ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
Xbutton2::mousedrag(handTool, selectionTool) ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
z::mousedrag(zoomTool, selectionTool) ;changes the tool to the zoom tool while z button is held ;check MS_functions.ahk for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
F1::SendInput("!{t}" "b{Right}g") ;open gaussian blur (should really just use the inbuilt hotkey but uh. photoshop is smelly don't @ me)
;F1::psSave()

;=============================================================================================================================================
;
;		After Effects
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe AfterFX.exe")
Xbutton1::timeline("981", "550", "2542", "996") ;check MS_functions.ahk for the code to this preset & the keyboard ini file for keyboard shortcuts
Xbutton2::mousedrag(handAE, selectionAE) ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset & the keyboard ini file for keyboard shortcuts
WheelRight::SendInput(nextKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys
WheelLeft::SendInput(previousKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys

;=============================================================================================================================================
;
;		Premiere
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")
;There use to be a lot of scripts about here in the script, they have since been removed and moved to their own individual .ahk files as launching them directly
;via a streamdeck is far more effecient; 1. because I only ever launch them via the streamdeck anyway & 2. because that no longer requires me to eat up a hotkey
;that I could use elsewhere, to run them. These mentioned scripts can be found in the \Streamdeck AHK\ folder.

SC03A & z::SendInput(zoomOut) ;\\set zoom out in the keyboard shortcuts ini ;idk why tf I need the scancode for capslock here but I blame premiere
SC03A & v:: ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it
{
	coords()
	MouseGetPos(&xpos, &ypos)
	;MouseMove 34, 917 ;location of the selection tool
	if ImageSearch(&x, &y, toolX1, toolY1, toolX2, toolY2, "*2 " EnvGet("Premiere") "selection.png") ;moves to the selection tool
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
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;brings focus to premiere's timeline so the below activation of the project window DEFINITELY happens
	SendInput(projectsWindow) ;adjust this shortcut in the ini file
	blockOn()
	coords()
	MouseGetPos(&xpos, &ypos)
	if ImageSearch(&prx, &pry, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "project.png") ;searches for the project window to grab the track
		goto move
	else if ImageSearch(&prx, &pry, 1244, 940, 2558, 1394, "*2 " EnvGet("Premiere") "project2.png") ;searches for the project window to grab the track
		goto move
	else ;if everything fails, this else will trigger
		{
			blockOff()
			toolFind("project window", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	move:
	MouseMove(%&prx% + "5", %&pry% +"3")
	SendInput("{Click Down}")
	Sleep 100
	MouseMove 3590, 702, "2"
	SendInput("{Click Up}")
	MouseMove(%&xpos%, %&ypos%)
	blockOff()
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Drag and Drop Effect Presets
;
;---------------------------------------------------------------------------------------------------------------------------------------------
F1::preset("gaussian blur 20") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags one of these presets onto the hovered track
F2::preset("parametric") ;check MS_functions.ahk for the code for these presets
F5::preset("hflip")
F3::preset("croptom")
F4::preset("loremipsum") ;(if you already have a text layer click it first, then hover over it, otherwise simply..) -> press this hotkey, then watch as ahk creates a new text layer then drags your preset onto the text layer. ;this hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
F6::preset("tint 100")

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
WheelRight::wheelEditPoint(nextEditPoint) ;goes to the next edit point towards the right
WheelLeft::wheelEditPoint(previousEditPoint) ;goes to the next edit point towards the left
Xbutton1::SendInput(nudgeDown) ;Set ctrl w to "Nudge Clip Selection Down"
Xbutton2::mousedrag(handPrem, selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

F19::audioDrag("sfx", "Goose_honk") ;drag my bleep (goose) sfx to the cursor ;I have a button on my mouse spit out F19 & F20
F20::audioDrag("sfx", "bleep")



;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other - NOT an editor
;
;---------------------------------------------------------------------------------------------------------------------------------------------
GroupAdd("Editors", "ahk_exe Adobe Premiere Pro.exe")
GroupAdd("Editors", "ahk_exe AfterFX.exe")
#HotIf not WinActive("ahk_group Editors") ;code below here (until the next #HotIf) will trigger as long as premiere pro & after effects aren't active
^!w::monitorWarp("5044", "340") ;this simply warps my mouse to my far monitor bc I'm lazy YEP
^!+w::monitorWarp("1280", "720") ;this simply warps my mouse to my main monitor bc I'm lazy YEP
^+d:: ;Make discord bigger so I can actually read stuff when not streaming
{
	if WinExist("ahk_exe Discord.exe")
		WinMove 4480, -280, 1080, 1537
}

F14::moveWin("") ;maximise
XButton2::moveWin("#{Left}") ;snap left
XButton1::moveWin("#{Right}") ;snap right
RButton::moveWin("") ;minimise

^SPACE::WinSetAlwaysOnTop -1, "A" ; will toggle the current window to remain on top

^+c:: ;runs a google search of highlighted text
{
	A_Clipboard := "" ;clears the clipboard
	Send "^c"
	ClipWait ;waits for the clipboard to contain data
	Run "https://www.google.com/search?d&q=" A_Clipboard
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;You can check out \mouse settings.png in the root repo to check what mouse buttons I have remapped
;The below scripts are to accelerate scrolling
F14 & WheelDown::SendInput("{WheelDown 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
F14 & WheelUp::SendInput("{WheelUp 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.

;The below scripts are to swap between virtual desktops
F19 & XButton2::SendInput("^#{Right}") ;you don't need these two as a sendinput, the syntax highlighting I'm using just see's ^#Right as an error and it's annoying
F19 & XButton1::SendInput("^#{Left}")

;The below scripts are to skip ahead in the youtube player with the mouse
WheelRight::youMouse("l", "{Right}")
WheelLeft::youMouse("j", "{Left}")