/************************************************************************
 * @description The central "hub" script for my entire repo. Handles most windows scripts + some editing scripts.
 * The ahk version listed below is the version I am using while generating the current release (so the version that is being tested on)
 * @file My Scripts.ahk
 * @author Tomshi
 * @date 2022/12/18
 * @version v2.8.2
 * @ahk_ver 2.0-rc.2
 ***********************************************************************/

;\\CURRENT RELEASE VERSION
global MyRelease := getLocalVer()

#SingleInstance Force
SetWorkingDir(ptf.rootDir) ;sets the scripts working directory to the directory it's launched from
SetNumLockState("AlwaysOn") ;sets numlock to always on (you can still it for macros)
SetCapsLockState("AlwaysOff") ;sets caps lock to always off (you can still it for macros)
SetScrollLockState("AlwaysOff") ;sets scroll lock to always off (you can still it for macros)
SetDefaultMouseSpeed(0) ;sets default MouseMove speed to 0 (instant)
SetWinDelay(0) ;sets default WinMove speed to 0 (instant)
A_MaxHotkeysPerInterval := 400 ;BE VERY CAREFUL WITH THIS SETTING. If you make this value too high, you could run into issues if you accidentally create an infinite loop
TraySetIcon(ptf.Icons "\myscript.png") ;changes the icon this script uses in the taskbar

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Apps\Discord>
#Include <Classes\Apps\VSCode>
#Include <Classes\Editors\After Effects>
#Include <Classes\Editors\Photoshop>
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\switchTo>
#Include <Classes\Move>
#Include <Classes\winget>
#Include <Classes\Startup>
#Include <Functions\reload_reset_exit>
#Include <Functions\errorLog>
#Include <Functions\mouseDrag>
#Include <Functions\getLocalVer>
#Include <Functions\fastWheel>
#Include <Functions\youMouse>
#Include <Functions\jumpChar>
#Include <Functions\refreshWin>
#Include <GUIs\settingsGUI\settingsGUI>
#Include <GUIs\activeScripts>
#Include <GUIs\hotkeysGUI>
;#Include right click premiere.ahk ; this file is included towards the bottom of the script - it was stopping the below `startup functions` from firing
; }
#Requires AutoHotkey v2.0

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.25.1
;\\Current QMK Keyboard Version\\At time of last commit
;\\v2.13.4

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
; Copyright (C) <2022>  <Tom Tomshi>
;
; You are free to modify this script to your own personal uses/needs, but you must follow the terms shown in the license file in the root directory of this repo (basically just keep source code available)
; You should have received a copy of the GNU General Public License along with this script.  If not, see <https://www.gnu.org/licenses/>
;
; Please give credit to the foundation if you build on top of it, similar to how I have below, otherwise you're free to do as you wish
; Youtube playlist going through some of my AHK changes/updates (https://www.youtube.com/playlist?list=PL8txOlLUZiqXXr2PNOsNSXeCB1171lQ1b)
;
; ============================================================================================================================================

; A chunk of the code in the original versions of this script was either directly inspired by, or originally copied from Taran from LTT (https://github.com/TaranVH/) before
; I eventually modified it to work with v2.0 of ahk and made a bunch of other changes. His videos on the subject are what got me into AHK to begin with and what brought the foundation of the original
; version of this script to life.
; I use a streamdeck to run a lot of my scripts which is why a bunch of them are separated out into their own scripts in the \Streamdeck AHK\ folder.

; I use to use notepad++ to edit this script, if you want proper syntax highlighting in notepad++ for ahk go here: https://www.autohotkey.com/boards/viewtopic.php?t=50
; I now use VSCode which can be found here: https://code.visualstudio.com/
; AHK (and v2.0) syntax highlighting can be installed within the program itself.

; If you EVER get stuck in some code within any of these scripts REFRESH THE SCRIPT - by default I have it set to win + shift + r - and it will work anywhere (unless you're clicked on a program run as admin) if refreshing doesn't work open up task manager with ctrl + shift + esc and use your keyboard to find all instances of autohotkey and force close them.

; =======================================================================================================================================
;
;
;				STARTUP
;
; =======================================================================================================================================
startup.generate(MyRelease) ;generates/replaces the `settings.ini` file every release
startup.locationReplace() ;runs the location variable
startup.updateChecker(MyRelease) ;runs the update checker
startup.trayMen() ;adds the ability to toggle checking for updates when you right click on this scripts tray icon
startup.firstCheck(MyRelease) ;runs the firstCheck() function
startup.oldError() ;runs the loop to delete old log files
startup.adobeTemp(MyRelease) ;runs the loop to delete cache files
startup.libUpdateCheck() ;runs a loop to check for lib updates
startup.updateAHK() ;checks for a newer version of ahk and alerts the user asking if they wish to download it

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

;panicExitHotkey;
#F12::reload_reset_exit("exit") ;this is a panic button and will shutdown all active ahk scripts
;panicExitALLHotkey;
#+F12::reload_reset_exit("exit", true) ;this is a panic button and will shutdown all active ahk scripts

;settingsHotkey;
#F1::settingsGUI() ;This hotkey will pull up the hotkey GUI

;activescriptsHotkey;
#F2::activeScripts(MyRelease) ;This hotkey pulls up a GUI that gives information regarding all current active scripts, as well as offering the ability to close/open any of them by simply unchecking/checking the corresponding box

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

	/**
	 * This function will determine which monitor the current active window is on, then return some information to help us do some math down below
	 */
	getMonitor()
	{
		winget.Title(&title)
		tryagain:
		wingetPos(&x, &y,,, title,, "Editing Checklist -")
		x := x + 10 ;sometimes windows when fullscreened will be at -8, -8 and not 0, 0
		y := y + 10 ;so we just add 10 pixels to both variables to ensure we're in the correct monitor
		numberofMonitors := SysGet(80)
		loop numberofMonitors {
			try {
				MonitorGet(A_Index, &left, &top, &right, &bottom)
				if x > left && x < right
					{ ;these two if statements determine what monitor the active window is in
						if y < bottom && y > top
							return {monitor: A_Index, left: left, right: right, top: top, bottom: bottom}
					}
			}
			catch as e {
				tool.Cust(A_ThisFunc "() failed to get the monitor that the active window is in")
				errorLog(e, A_ThisFunc "()")
				break
			}
		}
		try { ;if the window is overlapping multiple monitors, fullscreen it first then try again so it is only on the one monitor
			winget.isFullscreen(&testWin, title)
				{
					WinMaximize(title,, "Editing Checklist -")
					goto tryagain
				}
		}
	}
	title := ""
	static win := "" ;a variable we'll hold the title of the window in
	static toggle := 1 ;a variable to determine whether to centre on the current display or move to the main one
	monitor := getMonitor() ;now we run the above function we created
	if !IsObject(monitor) || !IsSet(monitor)
		{
			tool.Cust("Failed to get information about the window/monitor relationship`nThe window may be overlapping monitors")
			errorLog(, A_ThisHotkey "::", "Failed to get information about the window/monitor relationship", A_LineFile, A_LineNumber)
			return
		}
	if win = "" ;if our win variable doesn't have a title yet we run this code block
		{
			win := title
			toggle := 1
		}
	if win != title ;if our win variable doesn't equal the active window we run this code block to reset our values
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
		;tool.Cust("Window: " win "`nToggle: " toggle) ;for whatever reason, producing a tooltip actually breaks functionality.... huh??
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

;These two scripts are to open highlighted text in the ahk documentation
;akhdocuHotkey;
AppsKey:: Run("https://lexikos.github.io/v2/docs/AutoHotkey.htm") ;opens ahk documentation
;ahksearchHotkey;
^AppsKey:: ;opens highlighted ahk command in the documentation
{
	previous := ClipboardAll()
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	if !ClipWait(1) ;waits for the clipboard to contain data
		{
			tool.Cust("Couldn't copy data to clipboard")
			errorLog(, A_ThisHotkey "::", "couldn't copy data to clipboard", A_LineFile, A_LineNumber)
			return
		}
	Run("https://lexikos.github.io/v2/docs/commands/" A_Clipboard ".htm")
	SetTimer(check.bind(A_Clipboard, A_TickCount), 250)
	A_Clipboard := previous

	/**
	 * Will check to see if the desired page has loaded or if an error page occured
	 * @param {String} pass Passes in the clipboard, ie, what you're searching for
	 * @param {Integer} tick Passes in the original tickcount so this timer can time out after 5s
	 */
	check(pass, tick) {
		timepass := A_TickCount-tick
		if !WinExist(browser.firefox.winTitle)
			WinWait(browser.firefox.winTitle)
		title := WinGetTitle(browser.firefox.winTitle)
		if InStr(title, pass)
			{
				SetTimer(, 0)
				return
			}
		if InStr(title, "Error!") || timepass >= 5000
			{
				WinActivate(browser.firefox.winTitle)
				SendInput("^w")
				Run("https://lexikos.github.io/v2/docs/AutoHotkey.htm")
				SetTimer(, 0)
				return
			}
		if InStr(title, "Quick Reference") || timepass >= 5000
			{
				SetTimer(, 0)
				return
			}
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
	;Keep in mind I use dark mode on win11. Things will be different in light mode/other versions of windows
	MouseGetPos(&mx, &my)
	wingetPos(,, &width, &height, "A")
	colour1 := 0x4D4D4D ;when hovering a folder
	colour2 := 0xFFDA70
	colour3 := 0x353535 ;when already clicked on
	colour4 := 0x777777 ;when already clicked on
	colour := PixelGetColor(mx, my)
	if GetKeyState("LButton", "P") ;this is here so that moveWin() can function within windows Explorer. It is only necessary because I use the same button for both scripts.
		{
			SendInput("{LButton Up}")
			WinMaximize
			return
		}
	else if ImageSearch(&x, &y, 0, 0, width, height, "*5 " ptf.Explorer "showmore.png")
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
	else if (colour = colour1 || colour = colour2)
		{
			;tool.Cust(colour "`n colour1&2 fired") ;for debugging
			SendInput("{Click}")
			SendInput("{Esc}" "+{F10}")
			return
		}
	else if (colour = colour3 || colour = colour4)
		{
			;tool.Cust(colour "`n colour3&4 fired") ;for debugging
			SendInput("{Esc}" "+{F10}")
			return
		}
	else
		{
			;tool.Cust(colour "`n final else fired") ;for debugging
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
;vscodesearchHotkey;
$^f::VSCode.search()
;vscodecutHotkey;
$^x::VSCode.cut()
;vscodeCopyHotkey;
$^c::VSCode.copy()

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
					errorLog(e, A_ThisHotkey "::")
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
	KeyWait("Alt")
	Send("!d") ;opens the alt context menu to begin detatching the firefox tab
	sleep 100
	Send("+{TAB 3}")
	sleep 50
	Send("+{F10}")
	sleep 50
	Send("p")
	sleep 50
	Send("{Right}")
	Send("+{F10}" "p" "{Left}")
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
#HotIf WinActive(editors.Photoshop.winTitle)
;pngHotkey;
^+p::ps.Type("png") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
;jpgHotkey;
^+j::ps.Type("jpg") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a jpg instead of the default psd

;photopenHotkey;
XButton1::mouseDrag(handTool, penTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;photoselectHotkey;
Xbutton2::mouseDrag(handTool, selectionTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;photozoomHotkey;
z::mouseDrag(zoomTool, selectionTool) ;changes the tool to the zoom tool while z button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;F1::ps.Save()

;=============================================================================================================================================
;
;		After Effects
;
;=============================================================================================================================================
#HotIf WinActive(editors.AE.winTitle)
;aetimelineHotkey;
Xbutton1::ae.timeline() ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aeselectionHotkey;
Xbutton2::mouseDrag(handAE, selectionAE) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aepreviousframeHotkey;
F21::SendInput(previousKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys
;aenextframeHotkey;
F23::SendInput(nextKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys

;=============================================================================================================================================
;
;		Premiere
;
;=============================================================================================================================================
#HotIf WinActive(editors.Premiere.winTitle)
;There use to be a lot of macros about here in the script, they have since been removed and moved to their own individual .ahk files as launching them directly
;via a streamdeck is far more effecient; 1. because I only ever launch them via the streamdeck anyway & 2. because that no longer requires me to eat up a hotkey
;that I could use elsewhere, to run them. These mentioned scripts can be found in the \Streamdeck AHK\ folder.

;premzoomoutHotkey;
SC03A & z::SendInput(zoomOut) ;\\set zoom out in the keyboard shortcuts ini ;idk why tf I need the scancode for capslock here but I blame premiere
;premselecttoolHotkey;
SC03A & v:: ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it
{
	coord.s()
	MouseGetPos(&xpos, &ypos)
	SendInput(toolsWindow)
	SendInput(toolsWindow)
	sleep 50
	try {
        toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
		ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
    } catch as e {
        tool.Cust("Couldn't find the ClassNN value")
        errorLog(e, A_ThisHotkey "::")
    }
	;MouseMove 34, 917 ;location of the selection tool
	if width = 0 || height = 0
		{
			loop {
				;for whatever reason, if you're clicked on another panel, then try to hit this hotkey, `ControlGetPos` refuses to actually get any value, I have no idea why. This loop will attempt to get that information anyway, but if it fails will fallback to the hotkey you have set within premiere
				;tool.Cust(A_Index "`n" width "`n" height, "100")
				if A_Index > 3
					{
						SendInput(selectionPrem)
						tool.Cust("Couldn't get dimensions of the class window`nUsed the selection hotkey instead", 2000)
						errorLog(, A_ThisHotkey "::", "Couldn't get dimensions of the class window (premiere is a good program), used the selection hotkey instead", A_LineFile, A_LineNumber)
						return
					}
				sleep 100
				SendInput(toolsWindow)
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
				SendInput(selectionPrem)
				tool.Cust("selection tool`nUsed the selection hotkey instead", 2000, 1) ;useful tooltip to help you debug when it can't find what it's looking for
				errorLog(, A_ThisHotkey "::", "Couldn't find the selection tool (premiere is a good program), used the selection hotkey instead", A_LineFile, A_LineNumber)
				return
			}
	}
	SendInput("{Click}")
	MouseMove(xpos, ypos)
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
	SendInput(resetWorkspace)
	sleep 1500
	SendInput(timelineWindow) ;adjust this shortcut in the ini file
	SendInput(projectsWindow) ;adjust this shortcut in the ini file
	SendInput(projectsWindow) ;adjust this shortcut in the ini file
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
					;errorLog(, A_ThisHotkey "::", "Function failed to find ClassNN value that wasn't the timeline", A_LineNumber)
					break
				}
		}
	} catch as e {
			tool.Cust("Function failed to find project window")
			errorLog(e, A_ThisHotkey "::")
			return
		}
	;MsgBox("x " toolx "`ny " tooly "`nwidth " width "`nheight " height "`nclass " ClassNN) ;debugging
	block.On()
	try {
		if ImageSearch(&prx, &pry, toolx - "5", tooly - "20", toolx + "1000", tooly + "100", "*2 " ptf.Premiere "project.png") || ImageSearch(&prx, &pry, toolx - "5", tooly - "20", toolx + "1000", tooly + "100", "*2 " ptf.Premiere "project2.png") ;searches for the project window to grab the track
			goto move
		/* else if ImageSearch(&prx, &pry, toolx, tooly, width, height, "*2 " ptf.Premiere "project2.png") ;I honestly have no idea what the original purpose of this line was
			goto bin */
		else
			{
				coord.s()
				if ImageSearch(&prx, &pry, sanX - "5", sanY - "20", sanX + "1000", sanY + "100", "*2 " ptf.Premiere "project.png") || ImageSearch(&prx, &pry, sanX - "5", sanY - "20", sanX + "1000", sanY + "100", "*2 " ptf.Premiere "project2.png") ;This is the fallback code if you have it on a different monitor
					goto move
				else
					throw Error e
			}
	} catch as e {
		block.Off()
		tool.Cust("Couldn't find the project window`nIf this happens consistently, it may be an issue with premiere")
		errorLog(e, A_ThisHotkey "::")
		return
	}
	move:
	MouseMove(prx + "5", pry +"3")
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
					tool.Cust("activating the editing folder failed", 2000, 1)
					errorLog(, A_ThisHotkey "::", "activating the editing folder failed", A_LineFile, A_LineNumber)
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
				tool.Cust("the sfx folder", 2000, 1)
				errorLog(, A_ThisHotkey "::", "Couldn't find the sfx folder in Windows Explorer", A_LineFile, A_LineNumber)
				return
			}
	}
	MouseMove(foldx + "9", foldy + "5", 2)
	SendInput("{Click Down}")
	;sleep 2000
	coord.s()
	MouseMove(3240, 564, "2")
	SendInput("{Click Up}")
	switchTo.Premiere()
	WinWaitClose("Import Files")
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
			tool.Cust("the sfx folder in premiere", 2000, 1)
			errorLog(, A_ThisHotkey "::", "Couldn't find the sfx folder in Premiere Pro", A_LineFile, A_LineNumber)
			return
		}
	MouseMove(fold2x + "5", fold2y + "2")
	SendInput("{Click 2}")
	sleep 100
	loop {
		if ImageSearch(&fold3x, &fold3y, 10, 0, 1038, 1072, "*2 " ptf.Premiere "binsfx.png")
			{
				MouseMove(fold3x + "20", fold3y + "4", 2)
				SendInput("{Click Down}")
				MouseMove(772, 993, 2)
				sleep 250
				SendInput("{Click Up Left}")
				break
			}
		if A_Index > 5
			{
				block.Off()
				tool.Cust("the bin", 2000, 1)
				errorLog(, A_ThisHotkey "::", "Couldn't find the bin", A_LineFile, A_LineNumber)
				return
			}
	}
	coord.s()
	MouseMove(xpos, ypos)
	block.Off()
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;previouseditHotkey;
F21::prem.wheelEditPoint(previousEditPoint) ;goes to the next edit point towards the left
;nexteditHotkey;
F23::prem.wheelEditPoint(nextEditPoint) ;goes to the next edit point towards the right
;playstopHotkey;
F18::SendInput(playStop) ;alternate way to play/stop the timeline with a mouse button
;nudgeupHotkey;
F14::SendInput(nudgeUp) ;setting this here instead of within premiere is required for the below hotkeys to function properly
;slowDownHotkey;
F14 & F21::SendInput(slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
;speedUpHotkey;
F14 & F23::SendInput(speedUpPlayback) ;alternate way to speed up playback on the timeline with mouse buttons
;nudgedownHotkey;
Xbutton1::SendInput(nudgeDown) ;Set ctrl w to "Nudge Clip Selection Down"
;mousedrag1Hotkey;
LAlt & Xbutton2:: ;this is necessary for the below function to work
;mousedrag2Hotkey;
Xbutton2::prem.mousedrag(handPrem, selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

#Include right click premiere.ahk ;I have this here instead of running it separately because sometimes if the main script loads after this one things get funky and break because of priorities and stuff

;auto excecuting stuff will no longer function below this^ include

;bonkHotkey;
F19::prem.audioDrag("bonk") ;drag my bleep (goose) sfx to the cursor ;I have a button on my mouse spit out F19 & F20
;bleepHotkey;
F20::prem.audioDrag("bleep")

;=============================================================================================================================================
;
;		other - NOT an editor
;
;=============================================================================================================================================
#HotIf not WinActive("ahk_group Editors") ;code below here (until the next #HotIf) will trigger as long as premiere pro & after effects aren't active

;winmaxHotkey;
F14::move.Window("") ;maximise
;winleftHotkey;
XButton2::move.Window("#{Left}") ;snap left
;winrightHotkey;
XButton1::move.Window("#{Right}") ;snap right
;winminHotkey;
RButton::move.Window("") ;minimise

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
			else
				return "Active window now on top`n" '"' title '"'
		} catch as e {
			tool.Cust(A_ThisFunc "() couldn't determine the active window or you're attempting to interact with an ahk GUI")
			errorLog(e, A_ThisFunc "()")
			Exit()
		}

	}
	tool.Cust(tooltipVal, 2.0)
	WinSetAlwaysOnTop -1, "A" ; will toggle the current window to remain on top
}

;searchgoogleHotkey;
^+c:: ;runs a google search of highlighted text
{
	previous := ClipboardAll()
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	if !ClipWait(1) ;waits for the clipboard to contain data
		{
			tool.Cust("Couldn't copy data to clipboard")
			errorLog(, A_ThisHotkey "::", "couldn't copy data to clipboard", A_LineFile, A_LineNumber)
			return
		}
	Run("https://www.google.com/search?d&q=" A_Clipboard)
	A_Clipboard := previous
}

;capitaliseHotkey;
SC03A & c:: ;will attempt to determine whether to capitilise or completely lowercase the highlighted text depending on which is more frequent
{
	previous := ClipboardAll()
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	if !ClipWait(1) ;waits for the clipboard to contain data
		{
			A_Clipboard := previous
			tool.Cust("Couldn't copy data to clipboard")
			errorLog(, A_ThisHotkey "::", "couldn't copy data to clipboard", A_LineFile, A_LineNumber)
			return
		}
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
			A_Clipboard := previous
			tool.Cust("Couldn't determine whether to Uppercase or Lowercase the clipboard`nUppercase char = " upperCount "`nLowercase char = " lowerCount "`nAmount of char counted = " length - nonAlphaCount, 2000)
			return
		}
	SendInput("{BackSpace}")
	A_Clipboard := ""
	A_Clipboard := StringtoX
	ClipWait(1)
	SendInput("{ctrl down}v{ctrl up}")
	SetTimer(() => A_Clipboard := previous, -1000)
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
;virtualrightHotkey;
F19 & XButton2::SendInput("^#{Right}") ;you don't need these two as a sendinput, the syntax highlighting I'm using just see's ^#Right as an error and it's annoying
;virtualleftHotkey;
F19 & XButton1::SendInput("^#{Left}")

;The below scripts are to skip ahead in the youtube player with the mouse
;youskipbackHotkey;
F21::youMouse("j", "{Left}")
;youskipforHotkey;
F23::youMouse("l", "{Right}")