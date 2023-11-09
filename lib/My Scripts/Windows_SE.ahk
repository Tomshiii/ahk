; { \\ #Includes
;// these includes are only for things directly called within this script, any functions/classes may contain their own includes
#Include <Classes\reset>
#Include <Classes\keys>
#Include <Classes\tool>
#Include <GUIs\settingsGUI\settingsGUI>
#Include <GUIs\activeScripts>
#Include <GUIs\hotkeysGUI>
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