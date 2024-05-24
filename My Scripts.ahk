/************************************************************************
 * @description The central "hub" script for my entire repo. Handles most windows scripts + some editing scripts.
 * The ahk version listed below is the version I am using while generating the current release (so the version that is being tested on)
 * @file My Scripts.ahk
 * @author Tomshi
 * @date 2024/05/24
 * @version v2.14.5
 * @ahk_ver 2.0.14
 ***********************************************************************/

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.34.6

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
start.updatePackages()         ;checks for updates to packages installed through choco by default
start.trayMen()                ;adds the ability to toggle checking for updates when you right click on this scripts tray icon
start.firstCheck()             ;runs the firstCheck() function
start.oldLogs()                ;runs the loop to delete old log files
start.adobeTemp()              ;runs the loop to delete cache files
start.adobeVerOverride()
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
;//! code below here (until the next #HotIf) will work anywhere
#HotIf
;// these scripts need to be separated out because if any of them are under a hotif with the `GetKeyState` conditional, they lag out because the getkeystate check can't keep up
;// this is only really necessary because the `fastwheel()` functions rapidly fire inputs, any other F14 hotkeys are then only in here because if they are split into other #HotIf's
;// and those hotif's have conditionals that are slow, ahk has to check all of those conditionals and thus drags `fastwheel()` down with it
#Include <My Scripts\F14 Mouse Scripts>

;//! code below here (until the next #HotIf) will work anywhere as long as F24 is not being held
#HotIf !GetKeyState("F24", "P")

;//! Suspend Exempt
#SuspendExempt
#Include <My Scripts\Windows_SE>
#SuspendExempt false

;//! NOT Suspend Exempt
#Include <My Scripts\Windows>

;//! windows explorer
#HotIf WinActive("ahk_class CabinetWClass") || WinActive("ahk_class #32770")

#Include <My Scripts\Windows_Explorer>

;=============================================================================================================================================
;
;		VSCODE
;
;=============================================================================================================================================
;//! VSCode
#HotIf WinActive(vscode.winTitle)
#Include <My Scripts\VSCode>

;=============================================================================================================================================
;
; 		FIREFOX
;
;=============================================================================================================================================
;//! Firefox
#HotIf WinActive(browser.firefox.winTitle)
#Include <My Scripts\Firefox>

;=============================================================================================================================================
;
;		Discord
;
;=============================================================================================================================================
;//! Discord
#HotIf WinActive(discord.winTitle) ;some scripts to speed up discord interactions

#Include <My Scripts\Discord>

;=============================================================================================================================================
;
;		Slack
;
;=============================================================================================================================================
;//! Slack
#HotIf WinActive(Slack.winTitle) ;some scripts to speed up Slack interactions

#Include <My Scripts\Slack>

;=============================================================================================================================================
;
;		Photoshop
;
;=============================================================================================================================================
;//! Photoshop
#HotIf WinActive(editors.Photoshop.winTitle) && !GetKeyState("F24")

#Include <My Scripts\Photoshop>

;=============================================================================================================================================
;
;		After Effects
;
;=============================================================================================================================================
;//! After Effects
#HotIf WinActive(editors.AE.winTitle) && !GetKeyState("F24")

#Include <My Scripts\AE>

;=============================================================================================================================================
;
;		Premiere
;
;=============================================================================================================================================
;//! Premiere
#HotIf WinActive(editors.Premiere.winTitle) && !GetKeyState("F24")

#Include <My Scripts\Premiere>

;=============================================================================================================================================
;
;		other - NOT an editor
;
;=============================================================================================================================================
;//! Anything that isn't in the Editors Group
#HotIf not WinActive("ahk_group Editors") && !GetKeyState("F24") ;code below here (until the next #HotIf) will trigger as long as premiere pro & after effects aren't active

#Include <My Scripts\Not Editor>

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Premiere F14/position specific scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;//! Further Premiere Mouse Scripts
;//* having these scripts above with the other premiere scripts caused `wheelup` and `wheeldown` hotkeys to lag out and cause windows beeping
;//* thanks ahk :)
#HotIf WinActive(editors.Premiere.winTitle) && !GetKeyState("F24")

;// I have this here instead of running it separately because sometimes if the main script loads after this one things get funky and break because of priorities and stuff
#Include <Classes\Editors\Premiere_RightClick>

;//? Attempts to stop adobe fs.ahk from freaking out at times
;stopfullscreenpremHotkey;
Ctrl & \::return