/************************************************************************
 * @description The central "hub" script for my entire repo. Handles most windows scripts + some editing scripts.
 * The ahk version listed below is the version I am using while generating the current release (so the version that is being tested on)
 * @file My Scripts.ahk
 * @author Tomshi
 * @date 2023/03/05
 * @version v2.10.2
 * @ahk_ver 2.0.2
 ***********************************************************************/

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.31.3

#SingleInstance Force
#Requires AutoHotkey v2.0

; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Apps\Discord>
#Include <Classes\Apps\VSCode>
#Include <Classes\Editors\After Effects>
#Include <Classes\Editors\Photoshop>
#Include <Classes\Editors\Premiere>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\switchTo>
#Include <Classes\Move>
#Include <Classes\winget>
#Include <Classes\Startup>
#Include <Classes\obj>
#Include <Classes\clip>
#Include <Functions\reload_reset_exit>
#Include <Functions\errorLog>
#Include <Functions\mouseDrag>
#Include <Functions\getLocalVer>
#Include <Functions\fastWheel>
#Include <Functions\youMouse>
#Include <Functions\jumpChar>
#Include <Functions\refreshWin>
#Include <Functions\getHotkeys>
#Include <Classes\keys>
#Include <Functions\delaySI>
#Include <GUIs\settingsGUI\settingsGUI>
#Include <GUIs\activeScripts>
#Include <GUIs\hotkeysGUI>
;#Include right click premiere.ahk ;this file is included towards the bottom of the script - it was stopping the below `startup functions` from firing
; }

;//! Setting up script defaults.
SetWorkingDir(ptf.rootDir)             ;sets the scripts working directory to the directory it's launched from
SetNumLockState("AlwaysOn")            ;sets numlock to always on (you can still it for macros)
SetCapsLockState("AlwaysOff")          ;sets caps lock to always off (you can still it for macros)
SetScrollLockState("AlwaysOff")        ;sets scroll lock to always off (you can still it for macros)
SetDefaultMouseSpeed(0)                ;sets default MouseMove speed to 0 (instant)
SetWinDelay(0)                         ;sets default WinMove speed to 0 (instant)
A_MaxHotkeysPerInterval := 400         ;BE VERY CAREFUL WITH THIS SETTING. If you make this value too high, you could run into issues if you accidentally create an infinite loop
TraySetIcon(ptf.Icons "\myscript.png") ;changes the icon this script uses in the taskbar



; ============================================================================================================================================
;
; 													 THIS SCRIPT IS DESIGNED FOR v2.0 OF AUTOHOTKEY
;				 											   IT WILL NOT RUN IN v1.1
;									--------------------------------------------------------------------------------
;										           Everything in this script is functional within v2.0
;									   any code like `errorLog()` or `hardReset()` etc are all functions and defined
;										in the various `..\lib\` scripts. Look there for specific code to edit.
;
;                                       any code like `block.On()` or `tool.Cust()` etc are functions within a class
;										       and also defined within the various `..\lib\` scripts.
;
; ============================================================================================================================================
;
; This script was created by & for Tomshi (https://www.youtube.com/c/tomshiii, https://www.twitch.tv/tomshi)
; Its purpose is to help speed up editing and random interactions with windows.
; Copyright (C) <2023>  <Tom Tomshi>
;
; You are free to modify this script to your own personal uses/needs, but you must follow the terms shown in the license file in the root directory of this repo (basically just keep source code available)
; You should have received a copy of the GNU General Public License along with this script.  If not, see <https://www.gnu.org/licenses/>
;
; Please give credit to the foundation if you build on top of it, similar to how I have below, otherwise you're free to do as you wish
; Youtube playlist going through some of my AHK changes/updates (https://www.youtube.com/playlist?list=PL8txOlLUZiqXXr2PNOsNSXeCB1171lQ1b)
;
; ============================================================================================================================================

; A chunk of the code in the original versions of this script was either directly inspired by, or originally copied from Taran, a previous editor for LTT (https://github.com/TaranVH/)
; I eventually modified some of his code to work with v2.0 of ahk and continued to adapt and modify things for my own workflow. His videos on the subject are what got me into AHK to begin with and what brought the foundation of the original version of this script to life.
; These scripts now contain mostly my own work with some code from others here and there, this code is usually referenced/linked in comments.

; I use a streamdeck to run a lot of my scripts which is why a bunch of them are separated out into their own scripts in the \Streamdeck AHK\ folder.

; I use to use notepad++ to edit this script, if you want proper syntax highlighting in notepad++ for ahk go here: https://www.autohotkey.com/boards/viewtopic.php?t=50
; I now use VSCode which can be found here: https://code.visualstudio.com/
; AHK (and v2.0) syntax highlighting can be installed within the program itself.

; If you EVER get stuck in some code within any of these scripts REFRESH THE SCRIPT - by default I have it set to `win + shift + r` - and it will work anywhere (unless you're clicked on a program run as admin) if refreshing doesn't work open up task manager with ctrl + shift + esc and use your keyboard to find all instances of autohotkey and force close them.

; If you encounter any issues with these scripts, feel free to submit an issue on the github repo: https://www.github.com/tomshiii/ahk/
; If you wish to contribute to these scripts, feel free to submit a pull request on the repo (fork the repo, then submitt a pull request of your fork)

; =======================================================================================================================================
;
;
;				STARTUP
;
; =======================================================================================================================================
start := Startup()
start.generate()               ;generates/replaces the `settings.ini` file every release
start.locationReplace()        ;runs the location variable
start.updateChecker()          ;runs the update checker
start.trayMen()                ;adds the ability to toggle checking for updates when you right click on this scripts tray icon
start.firstCheck()             ;runs the firstCheck() function
start.oldError()               ;runs the loop to delete old log files
start.adobeTemp()              ;runs the loop to delete cache files
start.libUpdateCheck()         ;runs a loop to check for lib updates
start.updateAHK()              ;checks for a newer version of ahk and alerts the user asking if they wish to download it
start.monitorAlert()           ;checks the users monitor work area for any changes

;=============================================================================================================================================
;
;		Windows
;
;=============================================================================================================================================
#HotIf ;code below here (until the next #HotIf) will work anywhere
#SuspendExempt ;this and the below "false" are required so you can turn off suspending this script with the hotkey listed below
/*
F11::ListLines() ;debugging
F12::KeyHistory  ;debugging
*/
;reloadHotkey;
#+r::reload_reset_exit("reload") ;this reload script will attempt to reload all* active ahk scripts, not only this main script

;hardresetHotkey;
#+^r::reload_reset_exit("reset") ;this will hard rerun all active ahk scripts

;unstickKeysHotkey;
#F11::keys.allUp() ;this function will attempt to unstick as many keys as possible
;panicExitHotkey;
#F12::reload_reset_exit("exit") ;this is a panic button and will shutdown all active ahk scripts
;panicExitALLHotkey;
#+F12::reload_reset_exit("exit", true) ;this is a panic button and will shutdown all active ahk scripts INCLUDING the checklist.ahk script

;settingsHotkey;
#F1::settingsGUI() ;This hotkey will pull up the hotkey GUI

;activescriptsHotkey;
#F2::activeScripts() ;This hotkey pulls up a GUI that gives information regarding all current active scripts, as well as offering the ability to close/open any of them by simply unchecking/checking the corresponding box

;handyhotkeysHotkey;
#h::hotkeysGUI() ;this hotkey pulls up a GUI showing some useful hotkeys at your disposal while using these scripts

;suspendHotkey;
#+`:: ;this hotkey is to suspent THIS script. This is helpful when playing games as this script will try to fire and do whacky stuff while you're playing games
{
	if A_IsSuspended = 0
		tool.Cust("you suspended hotkeys from the main script")
	else
		tool.Cust("you renabled hotkeys from the main script")
	Suspend(-1) ; toggle suspends this script.
}
#SuspendExempt false

;capsHotkey;
SC03A:: ;double tap capslock to activate it, double tap to deactivate it. We need this hotkey because I have capslock disabled by default
{
	if A_PriorHotkey = A_ThisHotkey && A_TimeSincePriorHotkey < 250
		SetCapsLockState !GetKeyState("CapsLock", "T")
}

;centreHotkey;
#c:: ;this hotkey will center the active window in the middle of the active monitor
{ ;this scripts math can act a bit funky with vertical monitors. Especially with with programs like discord that have a minimum width
	mainMon := 1 ;set which monitor your main monitor is (usually 1, but can check in windows display settings)
	title := ""
	static win := "" ;a variable we'll hold the title of the window in
	static toggle := 1 ;a variable to determine whether to centre on the current display or move to the main one
	winget.Title(&title)
	monitor := WinGet.WinMonitor(title) ;now we run the above function we created
	if win = "" || win != title ;if our win variable doesn't have a title yet, or if it doesn't match the active window we run this code block to reset values
		{
			win := title
			toggle := 1
		}
	start:
	switch toggle {
		case 1: ;first toggle
			width := monitor.right - monitor.left ;determining the width of the current monitor
			height := monitor.bottom - monitor.top ;determining the height of the current monitor
			if winget.isFullscreen(&title2, title) ;checking if the window is fullscreen
				WinRestore(title2,, "Editing Checklist -") ;winrestore will unmaximise it

			newWidth := width / 1.6 ;determining our new width
			newHeight := height / 1.6 ;determining our new height
			newX := (monitor.left + (width - newWidth)/2) ;using math to centre our newly created window
			newY := (monitor.bottom - (height + newHeight)/2) ;using math to centre our newly created window
			;MsgBox("monitor = " monitor "`nwidth = " width "`nheight = " height "`nnewWidth = " newWidth "`nnewHeight = " newHeight "`nnewX = " newX "`nnewY = " newY "`nx = " x2 "`ny = " y2 "`nleft = " monitor.left "`nright = " right2 "`ntop = " top2 "`nbottom = " monitor.bottom) ;debugging
			if monitor != mainMon ;if the current monitor isn't our main monitor we will increment the toggle variable
				toggle += 1
			else ;otherwise we reset the win variable
				win := ""
		case 2: ;second toggle
			MonitorGet(mainMon, &left, &top, &right, &bottom) ;this will reset our variables with information for the main monitor
			monitor.monitor := mainMon ;then we set the monitor value to the main monitor
			monitor.left := left
			monitor.top := top
			monitor.right := right
			monitor.bottom := bottom
			toggle := 1 ;reset our toggle
			win := "" ;reset our win variable
			goto start ;and go back to the beginning
	}
	if InStr(title, "YouTube") && IsSet(newHeight) && monitor.monitor = mainMon ;My main monitor is 1440p so I want my youtube window to be a little bigger if I centre it
		{
			newHeight := newHeight * 1.3
			newY := newY / 2.25
		}
	if InStr(title, "VLC media player") && IsSet(newHeight) && monitor.monitor = mainMon ;I want vlc to be a size for 16:9 video to get rid of any letterboxing
		{
			newHeight := 900
			newWidth := 1416
		}
	try{
		WinMove(newX, newY, newWidth, newHeight, title,, "Editing Checklist -") ;then we attempt to move the window
	}
}

;fullscreenHotkey;
#f:: ;this hotkey will fullscreen the active window if it isn't already. If it is already fullscreened, it will pull it out of fullscreen
{
	if !winget.isFullscreen(&title)
		WinMaximize(title)
	else
		WinRestore(title) ;winrestore will unmaximise it
}

;jump10charLeftHotkey;
SC03A & Left::
;jump10charRightHotkey;
SC03A & Right::jumpChar()

;refreshWinHotkey;
SC03A & F5::refreshWin("A", wingetProcessPath("A"))

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		launch programs
;
;---------------------------------------------------------------------------------------------------------------------------------------------
#HotIf not GetKeyState("F24", "P") ;important so certain things don't try and override my second keyboard
;windowspyHotkey;
Pause::switchTo.WindowSpy() ;run/swap to windowspy
;vscodeHotkey;
RWin::switchTo.VSCode() ;run/swap to vscode
;streamdeckHotkey;
ScrollLock::switchTo.Streamdeck() ;run/swap to the streamdeck program
;taskmangerHotkey;
PrintScreen::SendInput("^+{Esc}") ;open taskmanager
;excelHotkey;
PgUp::switchTo.Excel() ;run/swap to excel

;This script is to open the ahk documentation. If ctrl is held, highlighted text will be searched
;akhdocuHotkey;
AppsKey::
;// both are needed here otherwise using ctrl+appskey might fail to work if the active window grabs it first
;ahksearchHotkey;
^AppsKey::
{
	;// logic if ctrl isn't being held
	if !GetKeyState("Ctrl", "P")
		{
			LinkClicked("", false)
			return
		}
	previous := ClipboardAll()
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	if !ClipWait(1) ;if the clipboard doesn't contain data after 1s this block fires
		{
			LinkClicked("", false)
			A_Clipboard := previous
			return
		}
	LinkClicked(A_Clipboard)
	A_Clipboard := previous

	/**
	 * Open the local ahk documentation if it can be found
	 * else open the online documentation
	 *
	 * This function originated in `ui-dash.ahk` found in `C:\Program Files\AutoHotkey\UX`
	 * @param {String} command is what you want to search for in the docs
	 */
	LinkClicked(command, search := true) {
		path := obj.SplitPath(A_AhkPath)
		;// hopefully this never has to fire as browsers are unpredictable and there's no easy way to wait for things to load
        if !FileExist(chm := path.dir '\AutoHotkey.chm')
			{
				if !WinExist("AutoHotkey v2")
					RunWait("https://www.autohotkey.com/docs/v2/index.htm")
				else
					{
						WinActivate("AutoHotkey v2")
						goto find
					}
				sleep 1500
				if !WinExist("Quick Reference | AutoHotkey v2")
					{
						tool.Cust("something went wrong")
						return
					}
				if WinExist("Quick Reference | AutoHotkey v2") && !WinActive("Quick Reference | AutoHotkey v2")
					WinActivate("Quick Reference | AutoHotkey v2")
				goto find
			}
		if !WinExist("AutoHotkey v2 Help")
			{
				Run('hh.exe "ms-its:' chm '::docs/"Program.htm">How to use the program',,, &id)
				WinWait("ahk_pid " id)
				sleep 200
			}
		if !WinActive("AutoHotkey v2 Help")
			{
				WinActivate()
				if !WinWaitActive(,, 1)
					WinActivate()
				;// if the window is minimised, then activated, chances are it won't actually accept any inputs
				;// so we simulate a click on the window to alert it we want to input commands
				ControlClick("X216 Y72")
				sleep 200
			}
		find:
		if search = false
			return
		SendInput("!s")
		SendInput("^a")
		SendInput("{BackSpace}")
		if command = ""
			return
		SendInput(command)
		SendInput("{Enter}")
    }
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;move mouse along one axis
;moveXhotkey;
SC03A & XButton2::
;moveYhotkey;
SC03A & XButton1::move.XorY()

#HotIf WinActive("ahk_class CabinetWClass") || WinActive("ahk_class #32770") ;windows explorer
;explorerbackHotkey;
F21::SendInput("!{Up}") ;Moves back 1 folder in the tree in explorer
;showmoreHotkey;
F18:: ;open the "show more options" menu in win11
{
	;// I think I may have just changed my registry to always pull up the old menu within windows
	;// and so I don't ever use this hotkey anymore and can't guarantee it even still functions
	;Keep in mind I use dark mode on win11. Things will be different in light mode/other versions of windows
	if GetKeyState("LButton", "P") ;this is here so that moveWin() can function within windows Explorer. It is only necessary because I use the same button for both scripts.
		{
			SendInput("{LButton Up}")
			WinMaximize
			return
		}
	MouseGetPos(&mx, &my)
	wingetPos(,, &width, &height, "A")
	colour1 := 0x4D4D4D ;when hovering a folder
	colour2 := 0xFFDA70
	colour3 := 0x353535 ;when already clicked on
	colour4 := 0x777777 ;when already clicked on
	colour := PixelGetColor(mx, my)
	if ImageSearch(&x, &y, 0, 0, width, height, "*5 " ptf.Explorer "showmore.png")
		{
			;tool.Cust(colour "`n imagesearch fired") ;for debugging
			;SendInput("{Esc}")
			;SendInput("{Click}")
			if colour = colour1 || colour = colour2
				{
					;SendInput("{Click}")
					SendInput("{Esc 3}" "+{F10}")
				}
			else
				SendInput("{Esc}" "+{F10}" "+{F10}")
			return
		}
	switch colour {
		case colour1, colour2:
			SendInput("{Click}")
			SendInput("{Esc}" "+{F10}")
			return
		default:
			SendInput("{Esc}" "+{F10}")
			return
	}
}

#HotIf WinActive(vscode.winTitle)
;vscodemsHotkey;
!a::VSCode.script(15) ;clicks on the `my scripts` script in vscode
;vscodefuncHotkey;
!f::VSCode.script() ;clicks on my `functions` script in vscode
;vscodeqmkHotkey;
!q::VSCode.script(16) ;clicks on my `qmk` script in vscode
;vscodechangeHotkey;
!c::VSCode.script(12) ;clicks on my `changelog` file in vscode
;vscodeTestHotkey;
!t::VSCode.script()
;vscodesearchHotkey;
$^f::VSCode.search()
;vscodecutHotkey;
$^x::VSCode.cut()
;vscodeCopyHotkey;
$^c::VSCode.copy()
;vscodeHideBar;
^b::delaySI(15, KSA.hideSideBar, KSA.hideActivityBar)

#HotIf WinActive(browser.firefox.winTitle)
;pauseyoutubeHotkey;
Media_Play_Pause:: ;pauses youtube video if there is one.
{
	coord.s()
	MouseGetPos(&x, &y)
	coord.w()
	SetTitleMatchMode 2
	needle := "YouTube"
	winget.Title(&title)
	if InStr(title, needle)
		{
			if InStr(title, "Subscriptions - YouTube Mozilla Firefox", 1) || title = "YouTube Mozilla Firefox"
				{
					SendInput("{Media_Play_Pause}")
					return
				}
			SendInput("{Space}")
			return
		}
	else loop {
		wingetPos(,, &width,, "A")
		if ImageSearch(&xpos, &ypos, 0, 0, width, "60", "*2 " ptf.firefox "youtube1.png") || ImageSearch(&xpos, &ypos, 0, 0, width, "60", "*2 " ptf.firefox "youtube2.png")
			{
				MouseMove(xpos, ypos, 2) ;2 speed is only necessary because of my multiple monitors - if I start my mouse in a certain position, it'll get stuck on the corner of my main monitor and close the firefox tab
				SendInput("{Click}")
				coord.s()
				MouseMove(x, y, 2)
				break
			}
		else
			switchTo.OtherFirefoxWindow()
		if A_Index > 5
			{
				tool.Cust("Couldn't find a youtube tab")
				try {
					WinActivate(title) ;reactivates the original window
				} catch as e {
					tool.Cust("Failed to get information on last active window")
					errorLog(e)
				}
				SendInput("{Media_Play_Pause}") ;if it can't find a youtube window it will simply send through a regular play pause input
				return
			}
	}
	SendInput("{Space}")
}

;the below disables the numpad on youtube so you don't accidentally skip around a video
;numpadytHotkey;
Numpad0::
Numpad1::
Numpad2::
Numpad3::
Numpad4::
Numpad5::
Numpad6::
Numpad7::
Numpad8::
Numpad9::
{
	SetTitleMatchMode 2
	needle := "YouTube"
	winget.Title(&title)
	if (InStr(title, needle))
		return
	else
		SendInput("{" A_ThisHotkey "}")
}

;pinfirefoxHotkey;
RAlt & p:: ;This hotkey is to pin the first two tabs
{
	keys.allWait("first")
	Send("!d") ;opens the alt context menu to begin detatching the firefox tab
	sleep 100
	delaySI(50, "+{TAB 3}", "+{F10}", "p", "{Right}", "+{F10}" "p" "{Left}")
}

;movetabHotkey;
XButton2:: ;these two hotkeys are activated by right clicking on a tab then pressing either of the two side mouse buttons
;movetab2Hotkey;
XButton1::move.Tab()

^+d::
{
	if !WinActive("Google Sheets")
		{
			SendInput(A_ThisHotkey)
			return
		}
	SendInput(A_DDD " - " FormatTime(A_Now, "d") "/" A_MM)
}

;=============================================================================================================================================
;
;		Discord
;
;=============================================================================================================================================
#HotIf WinActive(discord.winTitle) ;some scripts to speed up discord interactions
;SCO3A is the scancode for the CapsLock button. Had issues with using "CapsLock" as it would require a refresh every now and then before these discord scripts would work. Currently testing using the scancodes to see if that fixes it.
;alright scancodes didn't fix it, idk why but sometimes this function won't work until you refresh the main script. Might have to do with where I have it located in this script, maybe pulling it out into it's own script would fix it, or maybe discord is just dumb, who knows.
;scratch that, figured out what it is, in my qmk keyboard script I also had setcapslock to off and for whatever reason if that script was reloaded, my main script would break
;disceditHotkey;
SC03A & e::discord.button("DiscEdit.png") ;edit the message you're hovering over
;discreplyHotkey;
SC03A & r::discord.button("DiscReply.png") ;reply to the message you're hovering over ;this reply hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
;discreactHotkey;
SC03A & a::discord.button("DiscReact.png") ;add a reaction to the message you're hovering over
;discdeleteHotkey;
SC03A & d::discord.button("DiscDelete.png") ;delete the message you're hovering over. Also hold shift to skip the prompt
^+t::Run(ptf["DiscordTS"]) ;opens discord timestamp program [https://github.com/TimeTravelPenguin/DiscordTimeStamper]

;discitalicHotkey;
+*::discord.surround("*")
;discBacktickHotkey;
`::discord.surround("``")
;discParenthHotkey;
(::discord.surround("()")

;discserverHotkey;
F1::discord.Unread() ;will click any unread servers
;discmsgHotkey;
F2::discord.Unread(2) ;will click any unread channels
;discdmHotkey;
F3:: ;this hotkey is to click the "discord" button in discord to access your dm's
{
	WinActivate(discord.winTitle)
	block.On()
	MouseGetPos(&origx, &origy)
	MouseMove(34, 52, 2)
	SendInput("{Click}")
	MouseMove(origx, origy, 2)
	block.Off()
}

;=============================================================================================================================================
;
;		Photoshop
;
;=============================================================================================================================================
#HotIf WinActive(editors.Photoshop.winTitle) && !GetKeyState("F24")
;pngHotkey;
^+p::ps.Type("png") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
;jpgHotkey;
^+j::ps.Type("jpg") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a jpg instead of the default psd

;photopenHotkey;
XButton1::mouseDrag(KSA.handTool, KSA.penTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;photoselectHotkey;
Xbutton2::mouseDrag(KSA.handTool, KSA.selectionTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;photozoomHotkey;
z::mouseDrag(KSA.zoomTool, KSA.selectionTool) ;changes the tool to the zoom tool while z button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;F1::ps.Save()

;=============================================================================================================================================
;
;		After Effects
;
;=============================================================================================================================================
#HotIf WinActive(editors.AE.winTitle) && !GetKeyState("F24")
;aetimelineHotkey;
Xbutton1::ae.timeline() ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aeselectionHotkey;
Xbutton2::mouseDrag(KSA.handAE, KSA.selectionAE) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aepreviousframeHotkey;
F21::SendInput(KSA.previousKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys
;aenextframeHotkey;
F23::SendInput(KSA.nextKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys

;=============================================================================================================================================
;
;		Premiere
;
;=============================================================================================================================================
#HotIf WinActive("Adobe Premiere Pro 20" ptf.PremYearVer) && !GetKeyState("F24")
;stopTabHotkey;
Tab::return

#HotIf WinActive(editors.Premiere.winTitle) && !GetKeyState("F24")
;There use to be a lot of macros about here in the script, they have since been removed and moved to their own individual .ahk files as launching them directly
;via a streamdeck is far more effecient; 1. because I only ever launch them via the streamdeck anyway & 2. because that no longer requires me to eat up a hotkey
;that I could use elsewhere, to run them. These mentioned scripts can be found in the \Streamdeck AHK\ folder.

;linkActivateHotkey;
~^l::SendInput(KSA.selectAtPlayhead)

;prem^DeleteHotkey;
Ctrl & BackSpace::
{
	;// Premiere is really dumb and doesn't let you ctrl + backspace
	;// this hotkey is to return  that functionality
	SendMode("Event")
	SetKeyDelay(15)
	sendLeft() {
		Send("{Ctrl Down}{Shift Down}")
		Send("{Left}")
		Send("{Shift Up}{Ctrl Up}")
	}
	keys.allWait("second")
	sendLeft()
	store := clip.clear()
	Send("^c")
	if !ClipWait(0.1) || check := (StrLen(A_Clipboard) = 1) ? 1 : 0
		{
			additional := true
			if IsSet(check) && check = 1
				Send("{Right}")
			else if A_Clipboard = A_Space
				{
					Send("{Right}")
					Send("{BackSpace}")
					additional := false
				}
			Send("{Space}")
			Send("{Left}")
			sendLeft()
			Send("{BackSpace}")
			if additional
				Send("{Delete}")
		}
	Send("{BackSpace}")
	clip.returnClip(store.storedClip)
}

;premselecttoolHotkey;
SC03A & v:: ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it
{
	coord.s()
	MouseGetPos(&xpos, &ypos)
	SendInput(KSA.toolsWindow)
	SendInput(KSA.toolsWindow)
	sleep 50
	try {
        toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
		ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
    } catch as e {
        tool.Cust("Couldn't find the ClassNN value")
        errorLog(e)
    }
	;MouseMove 34, 917 ;location of the selection tool
	if width = 0 || height = 0
		{
			loop {
				;for whatever reason, if you're clicked on another panel, then try to hit this hotkey, `ControlGetPos` refuses to actually get any value, I have no idea why. This loop will attempt to get that information anyway, but if it fails will fallback to the hotkey you have set within premiere
				;tool.Cust(A_Index "`n" width "`n" height, "100")
				if A_Index > 3
					{
						SendInput(KSA.selectionPrem)
						errorLog(UnsetError("Couldn't get dimensions of the class window", -1)
									, "Used the selection hotkey instead", 1)
						return
					}
				sleep 100
				SendInput(KSA.toolsWindow)
				toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
				ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
			} until width != 0 || height != 0
		}
	if height < 80 ;idk why but if the toolbar panel is less than 80 pixels tall the imagesearch fails for me????, but it only does that if using the &width/&height values of the controlgetpos. Ahk is weird sometimes
		multiply := "3"
	else
		multiply := "1"
	loop {
		if ImageSearch(&x, &y, toolx, tooly, toolx + width, tooly + height * multiply, "*2 " ptf.Premiere "selection.png") ;moves to the selection tool
			{
				MouseMove(x, y)
				break
			}
		sleep 100
		if A_Index > 3
			{
				SendInput(KSA.selectionPrem)
				SendInput(KSA.programMonitor)
				errorLog(Error("Couldn't find the selection tool", -1)
							, "Used the selection hotkey instead", 1)
				return
			}
	}
	SendInput("{Click}")
	MouseMove(xpos, ypos)
	SendInput(KSA.programMonitor)
}

;premprojectHotkey;
RAlt & p:: ;This hotkey pulls out the project window and moves it to my second monitor since adobe refuses to just save its position in your workspace
{
	coord.s()
	shiftval := 0
	MouseGetPos(&xpos, &ypos)
	KeyWait("Alt")
	if GetKeyState("Ctrl", "P")
		{
			KeyWait("Ctrl")
			goto added
		}
	if GetKeyState("RShift", "P")
		{
			KeyWait("RShift")
			shiftval := 1
		}
	SendInput(KSA.resetWorkspace)
	sleep 1500
	SendInput(KSA.timelineWindow) ;adjust this shortcut in the ini file
	SendInput(KSA.projectsWindow) ;adjust this shortcut in the ini file
	SendInput(KSA.projectsWindow) ;adjust this shortcut in the ini file
	sleep 300
	WinGetPos(&sanX, &sanY,,, "A")
	;if you have this panel on a different monitor ahk won't be able to find it because of premiere weirdness so this value will be used in some fallback code down below
	coord.w()
	try {
		loop {
			ClassNN := ControlGetClassNN(ControlGetFocus("A"))
			ControlGetPos(&toolx, &tooly, &width, &height, ClassNN)
			/* if ClassNN != "DroverLord - Window Class3"
				break */
			;the window you're searching for can end up being window class 3. Wicked. The function will now attempt to continue on without these values if it doesn't get them as it can still work due to other information we grab along the way
			if A_Index > 5
				{
					;tool.Cust("Function failed to find project window")
					break
				}
		}
	} catch as e {
			tool.Cust("Function failed to find project window")
			errorLog(e)
			return
		}
	;MsgBox("x " toolx "`ny " tooly "`nwidth " width "`nheight " height "`nclass " ClassNN) ;debugging
	block.On()
	try {
		if ImageSearch(&prx, &pry, toolx - 5, tooly - 20, toolx + 1000, tooly + 100, "*2 " ptf.Premiere "project.png") || ImageSearch(&prx, &pry, toolx - 5, tooly - 20, toolx + 1000, tooly + 100, "*2 " ptf.Premiere "project2.png") ;searches for the project window to grab the track
			goto move
		/* else if ImageSearch(&prx, &pry, toolx, tooly, width, height, "*2 " ptf.Premiere "project2.png") ;I honestly have no idea what the original purpose of this line was
			goto bin */
		else
			{
				coord.s()
				if ImageSearch(&prx, &pry, sanX - 5, sanY - 20, sanX + 1000, sanY + 100, "*2 " ptf.Premiere "project.png") || ImageSearch(&prx, &pry, sanX - 5, sanY - 20, sanX + 1000, sanY + 100, "*2 " ptf.Premiere "project2.png") ;This is the fallback code if you have it on a different monitor
					goto move
				else
					throw Error("Couldn't find the project window", -1)
			}
	} catch Error as e {
		block.Off()
		errorLog(e, "If this happens consistently, it may be an issue with premiere", 1)
		return
	}
	move:
	MouseMove(prx+5, pry+3)
	SendInput("{Click Down}")
	coord.s()
	Sleep 100
	MouseMove 3592, 444, 2
	sleep 50
	SendInput("{Click Up}")
	MouseMove(xpos, ypos)
	if shiftval = 1
		{
			block.Off()
			return
		}
	bin:
	if !WinExist("_Editing Stuff")
		{
			Run(ptf.EditingStuff)
			if !WinWaitActive("_Editing Stuff",, 2) && WinExist("_Editing Stuff")
				WinActivate("_Editing Stuff")
			sleep 100
			if !WinActive("_Editing Stuff")
				{
					block.Off()
					errorLog(TargetError("Activating the editing folder failed", -1),, 1)
					return
				}
		}
	else
		{
			WinActivate("_Editing Stuff")
			SendInput("{Up}")
		}
	sleep 250
	if winget.isFullscreen(&title)
		WinRestore(title) ;winrestore will unmaximise it
	newWidth := 1600
	newHeight := 900
	newX := A_ScreenWidth / 2 - newWidth / 2
	newY := newX / 2
	; Move any window that's not the desktop
	try{
		WinMove(newX, newY, newWidth, newHeight, title)
	}
	sleep 250
	coord.w()
	MouseMove(0, 0)
	loop {
		if ImageSearch(&foldx, &foldy, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Explorer "sfx.png")
			break
		sleep 100
		if A_Index > 50
			{
				block.Off()
				errorLog(TargetError("Couldn't find the sfx folder in Windows Explorer", -1),, 1)
				return
			}
	}
	MouseMove(foldx + 9, foldy + 5, 2)
	SendInput("{Click Down}")
	;sleep 2000
	coord.s()
	MouseMove(3240, 564, 2)
	SendInput("{Click Up}")
	switchTo.Premiere()
	WinWait("Import Files",, 2)
	WinWaitClose("Import Files", 20)
	sleep 1000
	added:
	coord.w()
	WinActivate(editors.Premiere.winTitle)
	if ImageSearch(&listx, &listy, 10, 3, 1038, 1072, "*2 " ptf.Premiere "list view.png")
		{
			MouseMove(listx, listy)
			SendInput("{Click}")
			sleep 100
		}
	if !ImageSearch(&fold2x, &fold2y, 10, 3, 1038, 1072, "*2 " ptf.Premiere "sfxinproj.png") && !ImageSearch(&fold2x, &fold2y, 10, 3, 1038, 1072, "*2 " ptf.Premiere "sfxinproj2.png")
		{
			block.Off()
			errorLog(TargetError("Couldn't find the sfx folder in Premiere Pro", -1),, 1)
			return
		}
	MouseMove(fold2x + 5, fold2y + 2)
	SendInput("{Click 2}")
	sleep 100
	loop {
		if ImageSearch(&fold3x, &fold3y, 10, 0, 1038, 1072, "*2 " ptf.Premiere "binsfx.png")
			{
				MouseMove(fold3x + 20, fold3y + 4, 2)
				SendInput("{Click Down}")
				MouseMove(772, 993, 2)
				sleep 250
				SendInput("{Click Up Left}")
				break
			}
		if A_Index > 5
			{
				block.Off()
				errorLog(TargetError("Couldn't find the bin", -1),, 1)
				return
			}
	}
	coord.s()
	MouseMove(xpos, ypos)
	block.Off()
}

;12forwardHotkey;
PgDn::
{
	SendInput(KSA.effectControls)
	SendInput(KSA.effectControls)
	SendInput("{Right 12}")
}
;12backHotkey;
PgUp::
{
	SendInput(KSA.effectControls)
	SendInput(KSA.effectControls)
	SendInput("{Left 12}")
}
;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;previouseditHotkey;
F21::prem.wheelEditPoint(KSA.previousEditPoint) ;goes to the next edit point towards the left
;nexteditHotkey;
F23::prem.wheelEditPoint(KSA.nextEditPoint) ;goes to the next edit point towards the right
;playstopHotkey;
F18::SendInput(KSA.playStop) ;alternate way to play/stop the timeline with a mouse button
;nudgedownHotkey;
Xbutton1::SendInput(KSA.nudgeDown) ;Set ctrl w to "Nudge Clip Selection Down"
;mousedrag1Hotkey;
LAlt & Xbutton2:: ;this is necessary for the below function to work
;mousedrag2Hotkey;
Xbutton2::prem.mousedrag(KSA.handPrem, KSA.selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

#Include *i right click premiere.ahk ;I have this here instead of running it separately because sometimes if the main script loads after this one things get funky and break because of priorities and stuff

;bonkHotkey;
F19::prem.audioDrag("Bonk - Sound Effect (HD).wav") ;drag my bleep (goose) sfx to the cursor ;I have a button on my mouse spit out F19 & F20
;bleepHotkey;
F20::prem.audioDrag("bleep")

;=============================================================================================================================================
;
;		other - NOT an editor
;
;=============================================================================================================================================
#HotIf not WinActive("ahk_group Editors") ;code below here (until the next #HotIf) will trigger as long as premiere pro & after effects aren't active

;winmaxHotkey;
F14::move.Window() ;maximise
;winleftHotkey;
XButton2::move.Window("#{Left}") ;snap left
;winrightHotkey;
XButton1::move.Window("#{Right}") ;snap right
;winminHotkey;
RButton::move.Window() ;minimise

;alwaysontopHotkey;
^SPACE::
{
	tooltipVal := isOnTop()
	isOnTop() {
		try {
			title := WinGetTitle("A")
			ExStyle := wingetExStyle(title)
			if(ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST.
				return "Active window no longer on top`n" '"' title '"'
			return "Active window now on top`n" '"' title '"'
		} catch as e {
			tool.Cust(A_ThisFunc "() couldn't determine the active window or you're attempting to interact with an ahk GUI")
			errorLog(e)
			Exit()
		}

	}
	tool.Cust(tooltipVal, 2.0)
	WinSetAlwaysOnTop -1, "A" ; will toggle the current window to remain on top
}

;searchgoogleHotkey;
^+c:: ;runs a google search of highlighted text
{
	store := clip.clear()
	if !clip.copyWait(store.storedClip)
		return
	Run("https://www.google.com/search?d&q=" A_Clipboard)
	clip.returnClip(store.storedClip)
}

;capitaliseHotkey;
SC03A & c:: ;will attempt to determine whether to capitilise or completely lowercase the highlighted text depending on which is more frequent
{
	store := clip.clear()
	if !clip.copyWait(store.storedClip)
		return
	length := StrLen(A_Clipboard)
	/* if length > 9999 ;personally I started encountering issues at about 16k characters but I'm dropping that just to be safe
		{
			check := MsgBox("Strings that are too large may take a long time to process and are generally unable to be stopped without using taskmanager to kill the process`n`nThey also may eventually start sending gibberish as things aren't able to keep up`n`nAre you sure you wish to continue?", "Double Check", "4 48 4096")
			if check = "No"
				return
		} */
	upperCount := 0
	lowerCount := 0
	nonAlphaCount := 0
	loop length
		{
			test := SubStr(A_Clipboard, A_Index, 1)
			if IsUpper(test) = true
				upperCount += 1
			else if IsLower(test) = true
				lowerCount += 1
			else if IsAlpha(test) = false
				nonAlphaCount += 1
		}
	tool.Cust("Uppercase char = " upperCount "`nLowercase char = " lowerCount "`nAmount of char counted = " length - nonAlphaCount, 2000)
	if upperCount >= ((length - nonAlphaCount)/2)
		StringtoX := StrLower(A_Clipboard)
	else if lowerCount >= ((length - nonAlphaCount)/2)
		StringtoX := StrUpper(A_Clipboard)
	else
		{
			clip.returnClip(store.storedClip)
			msg := "Couldn't determine whether to Uppercase or Lowercase the clipboard`nUppercase char = " upperCount "`nLowercase char = " lowerCount "`nAmount of char counted = " length - nonAlphaCount
			errorLog(Error(msg, -1),, {time: 2.0})
			return
		}
	SendInput("{BackSpace}")
	A_Clipboard := ""
	A_Clipboard := StringtoX
	clip.Wait(store.storedClip)
	SendInput("{ctrl down}v{ctrl up}")
	clip.delayReturn(store.storedClip)
}

;timeHotkey;
^+t::
{
	if WinActive("ahk_group Browsers") && !WinActive("ahk_class #32770")
		{
			SendInput(A_ThisHotkey)
			return
		}
	SendInput(A_YYYY "-" A_MM "-" A_DD)
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;You can check out \mouse settings.png in the root repo to check what mouse buttons I have remapped
;The below scripts are to accelerate scrolling. If you encounter any slowdowns caused by spamming these two hotkeys, make sure no other hotkeys overlap with the activation script - I previously encountered issues with `showmoreHotkey` when they were both set to the same Fkey
;wheelupHotkey;
F14 & WheelDown::fastWheel()
;wheeldownHotkey;
F14 & WheelUp::fastWheel()

;The below scripts are to swap between virtual desktops
;// leaving them as sendinputs stops ;winleft; & ;winright; from firing twice..? ahk is weird
;virtualrightHotkey;
F19 & XButton2::SendInput("^#{Right}")
;virtualleftHotkey;
F19 & XButton1::SendInput("^#{Left}")

;The below scripts are to skip ahead in the youtube player with the mouse
;youskipbackHotkey;
F21::youMouse("j", "{Left}")
;youskipforHotkey;
F23::youMouse("l", "{Right}")

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Premiere F14 scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;// having these scripts above with the other premiere scripts caused `wheelup` and `wheeldown` hotkeys to lag out and cause windows beeping
;// thanks ahk :)
#HotIf WinActive(editors.Premiere.winTitle) && !GetKeyState("F24")
;nudgeupHotkey;
F14::SendInput(KSA.nudgeUp) ;setting this here instead of within premiere is required for the below hotkeys to function properly
;slowDownHotkey;
F14 & F21::SendInput(KSA.slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
;speedUpHotkey;
F14 & F23::SendInput(KSA.speedUpPlayback) ;alternate way to speed up playback on the timeline with mouse buttons