#SingleInstance Force

#Include <Classes\Startup>
#Include <Classes\ptf>
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\keys>
#Include <Classes\switchTo>
#Include <Classes\coord>
#Include <Classes\clip>
#Include <Classes\block>
#Include <Classes\obj>
#Include <Classes\tool>
#Include <Classes\winGet>
#Include <Classes\timer>
#Include <Classes\Settings>
#Include <Classes\Streamdeck_opt>
#Include <GUIs\settingsGUI\settingsGUI>
#Include <Functions\isDoubleClick>

SetWorkingDir(ptf.rootDir)             ;sets the scripts working directory to the directory it's launched from
SetDefaultMouseSpeed(0)                ;sets default MouseMove speed to 0 (instant)
SetWinDelay(0)                         ;sets default WinMove speed to 0 (instant)
A_MaxHotkeysPerInterval := 400         ;BE VERY CAREFUL WITH THIS SETTING. If you make this value too high, you could run into issues if you accidentally create an infinite loop
A_MenuMaskKey := "vkD7"				   ;necessary for `alt_menu_acceleration_disabler.ahk` to work correctly
TraySetIcon(ptf.Icons "\myscript.png") ;changes the icon this script uses in the taskbar

start := Startup()
start.generate()
SD_Opt().checkCount()
start.gitBranchCheck()
; start.updateChecker()
start.updatePackages(,,,, ["vcredist"])
start.trayMen()
start.oldLogs()
start.adobeTemp()
start.adobeVerOverride()
start.updateAHK()
start.checkShortcuts()
start.__Delete()
errorLog({state:"empty"})

;// so streamdeck scripts can receive premiere timeline coords
onMsgObj := ObjBindMethod(WM, "__recieveMessage")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

#HotIf ;code below here (until the next #HotIf) will work anywhere
#SuspendExempt ;this and the below "false" are required so you can turn off suspending this script with the hotkey listed below

#F1::settingsGUI()

;reloadHotkey;
#+r::reset.ext_reload() ;this reload script will attempt to reload all* active ahk scripts, not only this main script

;hardresetHotkey;
#+^r::reset.reset() ;this will hard rerun all active ahk scripts
#SuspendExempt false
;=============================================================================================================================================
;
;		Premiere
;
;=============================================================================================================================================
#HotIf WinActive(editors.Premiere.winTitle) && !GetKeyState("F24")

;spaceDelayHotkey;
Space::
{
	getTitle := WinGetTitle("A")
	isIn(title) => InStr(getTitle, title)
	switch {
		case isIn("Modify Clip"), isIn("Audio Gain"), isIn("Delete Tracks"):
			SendInput("{Enter}")
			return
		case isIn("Save Project"): return
		case isIn("Clip Fx Editor - DeNoise"):
			SendInput("{Enter}")
			if IsSet(A_PriorKey) && isDoubleClick(750, "key")
				prem.escFxMenu()
			return
		case isIn("Color Picker"), isIn("Add Tracks"):
			if !CaretGetPos(&x, &y) {
				SendInput("{Enter}")
				return
			}
	}
	prem.delayPlayback()
}

;premrippleTrimHotkey;
q::
w::prem.rippleTrim()

Escape::prem.escFxMenu()

;premselecttoolHotkey;
; SC03A & v::prem.selectionTool() ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;mousedrag1Hotkey;
LAlt & XButton1:: ;this is necessary for the below function to work
;mousedrag2Hotkey;
XButton1::prem.mousedrag(KSA.handPrem, KSA.selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts
#Include <Classes\Editors\Premiere_RightClick>