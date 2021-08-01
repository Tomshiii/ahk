;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance Force

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.0.1

;\\CURRENT RELEASE VERSION
;\\v1.1

; =========================================================================
;		Coordmode
; =========================================================================
coords()
{
	coordmode "pixel", "screen"
	coordmode "mouse", "screen"
}

coordw()
{
	coordmode "pixel", "window"
	coordmode "mouse", "window"
}

; =========================================================================
;		Blockinput
; =========================================================================
blockOn()
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
}

blockOff()
{
	blockinput "MouseMoveOff"
	BlockInput "off"
}

; =========================================================================
;		Premiere
; =========================================================================
preset(item) ;this preset is for the drag and drop effect presets in premiere
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
	coordmode "pixel", "Screen"
	coordmode "mouse", "Screen"
	MouseGetPos &xpos, &ypos
		SendInput "^+7"
		SendInput "^b" ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		sleep 60
		SendInput "^a{DEL}"
		SendInput %&item% ;create a preset of blur effect with this name, must be in a folder as well
		MouseMove 3354, 259 ;move to the magnifying glass in the effects panel
		sleep 100
		MouseMove 40, 68,, "R" ;move down to the saved preset (must be in an additional folder)
		SendInput "{Click Down}"
		MouseMove %&xpos%, %&ypos%
		SendInput "{Click Up}"
	blockinput "MouseMoveOff"
	BlockInput "off"
}

num() ;this preset is to simply cut down repeated code on my numpad punch in scripts
{
	coordmode "pixel", "Window"
	coordmode "mouse", "Window"
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
	MouseGetPos &xpos, &ypos
		SendInput "^+9"
		SendInput "^{F5}" ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
		click 214, 1016
		SendInput "{WheelUp 30}"
		MouseMove 122,1060 ;location for "motion"
		SendInput "{Click}"
		MouseMove %&xpos%, %&ypos%
}