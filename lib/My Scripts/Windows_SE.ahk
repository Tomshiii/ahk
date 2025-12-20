; { \\ #Includes
;// these includes are only for things directly called within this script, any functions/classes may contain their own includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\reset.ahk
#Include Classes\keys.ahk
#Include Classes\tool.ahk
#Include GUIs\settingsGUI\settingsGUI.ahk
#Include GUIs\activeScripts.ahk
#Include GUIs\hotkeysGUI.ahk
; }

;// these are hotkeys that are supposed to fire everywhere that are EXEMPT from suspention

/*
F11::ListLines() ;debugging
F12::KeyHistory  ;debugging
*/
;reloadHotkey;
#+r::reset.ext_reload() ;this reload script will attempt to reload all* active ahk scripts, not only this main script

;hardresetHotkey;
#+^r::reset.reset() ;this will hard rerun all active ahk scripts

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