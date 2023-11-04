/************************************************************************
 * @description The central "hub" script for my entire repo. Handles most windows scripts + some editing scripts.
 * The ahk version listed below is the version I am using while generating the current release (so the version that is being tested on)
 * @file My Scripts.ahk
 * @author Tomshi
 * @date 2023/10/28
 * @version v2.13.0
 * @ahk_ver 2.0.10
 ***********************************************************************/

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.33.13

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
#Include <Classes\reset>
#Include <Classes\keys>
#Include <Classes\errorLog>
#Include <Functions\mouseDrag>
#Include <Functions\getLocalVer>
#Include <Functions\fastWheel>
#Include <Functions\youMouse>
#Include <Functions\jumpChar>
#Include <Functions\refreshWin>
#Include <Functions\getHotkeys>
#Include <Functions\alwaysOnTop>
#Include <Functions\pauseYT>
#Include <Functions\delaySI>
#Include <Functions\isDoubleClick>
#Include <Functions\multiKeyPress>
#Include <GUIs\settingsGUI\settingsGUI>
#Include <GUIs\activeScripts>
#Include <GUIs\hotkeysGUI>
;#Include Premiere_RightClick.ahk ;this file is included towards the bottom of the script - it was stopping the below `startup functions` from firing
; }

;//! Setting up script defaults.
SetWorkingDir(ptf.rootDir)             ;sets the scripts working directory to the directory it's launched from
SetNumLockState("AlwaysOn")            ;sets numlock to always on (you can still it for macros)
SetCapsLockState("AlwaysOff")          ;sets caps lock to always off (you can still it for macros)
SetScrollLockState("AlwaysOff")        ;sets scroll lock to always off (you can still it for macros)
SetDefaultMouseSpeed(0)                ;sets default MouseMove speed to 0 (instant)
SetWinDelay(0)                         ;sets default WinMove speed to 0 (instant)
A_MaxHotkeysPerInterval := 400         ;BE VERY CAREFUL WITH THIS SETTING. If you make this value too high, you could run into issues if you accidentally create an infinite loop
A_MenuMaskKey := "vkD7"				   ;necessary for `alt_menu_acceleration_disabler.ahk` to work correctly
TraySetIcon(ptf.Icons "\myscript.png") ;changes the icon this script uses in the taskbar



; ============================================================================================================================================
;
; 													 THIS SCRIPT IS DESIGNED FOR v2.0 OF AUTOHOTKEY
;				 											   IT WILL NOT RUN IN v1.1
;									--------------------------------------------------------------------------------
;										           Everything in this script is functional within v2.0
;									   any code like `errorLog()` or `hardReset()` etc are all functions and defined
;										in the various `..\lib\Functions` scripts. Look there for specific code to edit.
;
;                                       any code like `block.On()` or `tool.Cust()` etc are functions within a class
;										       and also defined within the various `..\lib\Classes\` scripts.
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
start.updateChecker()          ;runs the update checker
start.trayMen()                ;adds the ability to toggle checking for updates when you right click on this scripts tray icon
start.firstCheck()             ;runs the firstCheck() function
start.oldLogs()                ;runs the loop to delete old log files
start.adobeTemp()              ;runs the loop to delete cache files
start.libUpdateCheck()         ;runs a loop to check for lib updates
start.updateAHK()              ;checks for a newer version of ahk and alerts the user asking if they wish to download it
start.monitorAlert()           ;checks the users monitor work area for any changes
start.__Delete()

;// so streamdeck scripts can receive premiere timeline coords
onMsgObj := ObjBindMethod(WM, "__recieveMessage")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA
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
#+r::reset.ext_reload() ;this reload script will attempt to reload all* active ahk scripts, not only this main script

;hardresetHotkey;
#+^r::reset.reset() ;this will hard rerun all active ahk scripts

;unstickKeysHotkey;
#F11::keys.allUp() ;this function will attempt to unstick as many keys as possible
;panicExitHotkey;
#F12::reset.ex_exit() ;this is a panic button and will shutdown all active ahk scripts
;panicExitALLHotkey;
#+F12::reset.ex_exit(true) ;this is a panic button and will shutdown all active ahk scripts INCLUDING the checklist.ahk script

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
	if !isDoubleClick()
		return
	SetCapsLockState !GetKeyState("CapsLock", "T")
}

;centreHotkey;
#c::move.winCenter(1.25)
#+c::move.winCenterWide()

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
#HotIf !GetKeyState("F24", "P") ;important so certain things don't try and override my second keyboard

#SuspendExempt true
;myhkeyisbrokenfmlHotkey;
$h::multiKeyPress((*) => SendInput("h"), (*) => Exit(), (*) => Exit(), -25)
#SuspendExempt false

;windowspyHotkey;
Pause::switchTo.WindowSpy() ;run/swap to windowspy
;vscodeHotkey;
PrintScreen::switchTo.VSCode() ;run/swap to vscode
;streamdeckHotkey;
ScrollLock::switchTo.Streamdeck() ;run/swap to the streamdeck program

;This script is to open the ahk documentation. If ctrl is held, highlighted text will be searched
;akhdocuHotkey;
RWin::
;// both are needed here otherwise using ctrl+appskey might fail to work if the active window grabs it first
;ahksearchHotkey;
RShift & RWin::
{
	;// logic if ctrl isn't being held
	if !GetKeyState("RShift", "P")
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

;SubUnderHotkey;
+NumpadSub::_

#HotIf WinActive("ahk_class CabinetWClass") || WinActive("ahk_class #32770") ;windows explorer
;explorerbackHotkey;
F21::SendInput("!{Up}") ;Moves back 1 folder in the tree in explorer

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
;vscodeTodoHotkey;
!d::VSCode.script()
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
Media_Play_Pause::pauseYT() ;pauses youtube video if there is one.


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
	ignore := "YouTube Studio"
	winget.Title(&title)
	if (InStr(title, needle) && !InStr(title, ignore))
		return
	SendInput("{" A_ThisHotkey "}")
}

;movetabHotkey;
XButton2:: ;these two hotkeys are activated by right clicking on a tab then pressing either of the two side mouse buttons
;movetab2Hotkey;
XButton1::move.Tab()

;extraEnterHotkey;
PgDn::Enter ;// I use a TKL keyboard and miss my NumpadEnter key

;=============================================================================================================================================
;
;		Discord
;
;=============================================================================================================================================
#HotIf WinActive(discord.winTitle) ;some scripts to speed up discord interactions

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
*::discord.surround("*")
;discBacktickHotkey;
`::discord.surround("``")
;discParenthHotkey;
(::discord.surround("()")

;discserverHotkey;
F1::discord.Unread() ;will click any unread servers
;discmsgHotkey;
F2::discord.Unread(2) ;will click any unread channels
;discdmHotkey;
F3::discord.DMs()


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
#HotIf WinActive(editors.Premiere.winTitle) && !GetKeyState("F24")
;stopTabHotkey;
Shift & Tab::
$Tab::
{
	if !isDoubleClick()
		return
	sendMod := (GetKeyState("Shift", "P")) ? "+" : ""
	SendInput(sendMod "{Tab}")
}

;spaceDelayHotkey;
Space::prem.delayPlayback()

;linkActivateHotkey;
~^l::SendInput(KSA.selectAtPlayhead)

;prem^DeleteHotkey;
Ctrl & BackSpace::prem.wordBackspace()

;premselecttoolHotkey;
SC03A & v::prem.selectionTool()

;premprojectHotkey;
RAlt & p::prem.openEditingDir(ptf.EditingStuff)

;12forwardHotkey;
PgDn::prem.moveKeyframes("right", 12)
;12backHotkey;
PgUp::prem.moveKeyframes("left", 12)

;premrippleTrimHotkey;
q::
w::prem.rippleTrim()

;thumbScrollHotkey;
F12::prem.thumbScroll()

;premresetHotkey;
F5::prem.reset()

;premnumpadGainHotkey;
~Numpad1::
~Numpad2::
~Numpad3::
~Numpad4::
~Numpad5::
~Numpad6::
~Numpad7::
~Numpad8::
~Numpad9::prem.numpadGain()

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;previouspremkeyframeHotkey;
Shift & F21::prem.wheelEditPoint(KSA.effectControls, KSA.prempreviousKeyframe, "second") ;goes to the next keyframe point towards the left
;nextpremkeyframeHotkey;
Shift & F23::prem.wheelEditPoint(KSA.effectControls, KSA.premnextKeyframe, "second") ;goes to the next keyframe towards the right

;previouseditHotkey;
F21::prem.wheelEditPoint(KSA.timelineWindow, KSA.previousEditPoint) ;goes to the next edit point towards the left
;nexteditHotkey;
F23::prem.wheelEditPoint(KSA.timelineWindow, KSA.nextEditPoint) ;goes to the next edit point towards the right

;playstopHotkey;
F18::SendInput(KSA.playStop) ;alternate way to play/stop the timeline with a mouse button
;mousedrag1Hotkey;
LAlt & Xbutton2:: ;this is necessary for the below function to work
;mousedrag2Hotkey;
Xbutton2::prem.mousedrag(KSA.handPrem, KSA.selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

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

/* z & -::
z & =::
z & Up::
z & Down::move.adjust("y")
z::z
x & -::
x & =::
x & Left::
x & Right::move.adjust()
x::x */

;alwaysontopHotkey;
^SPACE::alwaysOnTop()

;searchgoogleHotkey;
^+c::clip.search() ;runs a google search of highlighted text

;capitaliseHotkey;
SC03A & c::clip.capitilise()

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
;		Premiere F14/position specific scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;// having these scripts above with the other premiere scripts caused `wheelup` and `wheeldown` hotkeys to lag out and cause windows beeping
;// thanks ahk :)
#HotIf WinActive(editors.Premiere.winTitle) && !GetKeyState("F24")
;slowDownHotkey;
F14 & F21::SendInput(KSA.slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
;speedUpHotkey;
F14 & F23::SendInput(KSA.speedUpPlayback) ;alternate way to speed up playback on the timeline with mouse buttons

#MaxThreadsBuffer true
Alt & WheelUp::
Alt & WheelDown::
Shift & WheelUp::
Shift & WheelDown::prem.accelScroll(5, 25)
#MaxThreadsBuffer false

;// I have this here instead of running it separately because sometimes if the main script loads after this one things get funky and break because of priorities and stuff
#Include <Classes\Editors\Premiere_RightClick>

;stopfullscreenpremHotkey;
Ctrl & \::return