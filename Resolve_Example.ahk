SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
SetDefaultMouseSpeed 0
#SingleInstance Force
; SetNumLockState "AlwaysOn" ;uncomment if you want numlock to always be ON
; SetCapsLockState "AlwaysOff" ;uncomment if you want capslock to always be OFF
TraySetIcon("C:\Program Files\ahk\ahk\Icons\resolve.png")
#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script ;includes function definitions so they don't clog up this script
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.2.1
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.7.1

;\\CURRENT RELEASE VERSION
;\\v2.2.5.1
; ==================================================================================================
;
; 							THIS SCRIPT IS FOR v2.0 OF AUTOHOTKEY
;				 				IT WILL NOT RUN IN v1.1
;
; ==================================================================================================
;
; This script was created by Tomshi (https://www.youtube.com/c/tomshiii, https://www.twitch.tv/tomshi)
; Its purpose is to port over similar macros from my "My Scripts.ahk" to allow faster editing within resolve for you non adobe editors
; You are free to modify this script to your own personal uses/needs
; Please give credit to the foundation if you build on top of it, otherwise you're free to do as you wish
;
; ==================================================================================================
#HotIf ;WinNotActive("ahk_exe Resolve.exe")

;^!a:: Run "C:\Program Files (x86)\Notepad++\notepad++.exe", A_ScriptFullPath ;opens in notepad++ without needing to fully replace notepad with notepad++ (preferred)
;best way to open this script if you don't use vscode

;!a:: ;if for whatever reason you choose to use vscode instead of notepad++, use this version instead of above
;{
;	if WinExist("ahk_exe Code.exe") ;opens in vscode (how I edit it)
;			WinActivate
;	else
;		Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe" ;opens in vscode (how I edit it)
;}

/* ;added functionality in my main script to reload all scripts
^!r::
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
*/

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; ALL PIXEL VALUES WILL NEED TO BE ADJUSTED IF YOU AREN'T USING A 1440p MONITOR (AND MIGHT STILL EVEN IF YOU ARE)

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; This is an example script I've created for davinci resolve porting over some similar functionality I use
; in my premiere scripts. Things aren't as clean and there may be better ways to do things
; keep in mind I don't use resolve and I've just cooked this up as an example for you to mess with yourself

;=========================================================
;		DAVINCI RESOLVE
;=========================================================
#HotIf WinActive("ahk_exe Resolve.exe")

;=========================================================
;		keyboard shortcut replacements (this is just to make things similar to how I use premiere. Realistically replacing their keybinds in Resolve itself is FAR better)
;=========================================================
; ///// these all assume you're using resolve's default keybinds

q::+[ ; reassign shift[ to ripple start to playhead ;...or assign it to q
w::+] ; reassign shift] to ripple start to playhead ;...or assign it to w
~s::^\ ; ctrl \ is how to split tracks in resolve ;needs ~ or you can't save lmao. likely better to just remap in resolve
XButton2::MButton ; middle mouse is how you normally scroll horizontally in resolve, middle mouse is obnoxious to press though
WheelRight::Down
WheelLeft::Up
;change "normal edit mode" to v to make it like premiere
;change "blade edit mode" to c to make it like how I use premiere
;change "ripple delete" to shift c to make it like how I use premiere

;=========================================================
;		hold and drag (or click)
;=========================================================
F1::rvalhold("zoom", "60", "1") ;press then hold F1 and drag to increase/decrese x position. Let go of F1 to confirm. Tap to reset
F2::rvalhold("position", "80", "1") ;press then hold F2 and drag to increase/decrese x position. Let go of F2 to confirm. Tap to reset
F3::rvalhold("position", "210", "1") ;press then hold F3 and drag to increase/decrese y position. Let go of F3 to confirm. Tap to reset
F4::rvalhold("rotation", "240", "0") ;press then hold F4 and drag to increase/decrese rotation. Let go of F4 to confirm. Tap to reset

;=========================================================
;		flips
;=========================================================
!h::rflip("horizontal") ;flip horizontally. won't do anything if you're scrolled down in the "video" tab already. you could add a wheelup if you wanted
!v::rflip("vertical") ;flip vertically. won't do anything if you're scrolled down in the "video" tab already. you could add a wheelup if you wanted

;=========================================================
;		Scale Adjustments
;=========================================================
^1::Rscale("1", "zoom", "60") ;makes the scale of current selected clip 100
^2::Rscale("2", "zoom", "60") ;makes the scale of current selected clip 200
^3::Rscale("3", "zoom", "60") ;makes the scale of current selected clip 300

;=========================================================
;
;		Drag and Drop Effect Presets
;
;=========================================================
!g::REffect("openfx", "gaussian blur") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags that "favourite" onto the hovered track. Check MS_functions.ahk for the preset code
; this is set up as a preset so you can easily add further hotkeys with 1 line and new defined coords. x (80 in this example) will always remain the same, so just grab the new y coords and you've added a new macro

;=========================================================
;
;		better timeline movement (don't use rightclick, you'll lose context menus)
;
;=========================================================
XButton1::timeline("827", "856", "2550", "845") ;check MS_Functions.ahk for code

;=========================================================
;
;		gain
;
;=========================================================
Numpad1::rgain("-2")
Numpad2::rgain("2")
Numpad3::rgain("6")