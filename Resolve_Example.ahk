SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
SetDefaultMouseSpeed 0
#SingleInstance Force
#Requires AutoHotkey v2.0-beta.12
; SetNumLockState "AlwaysOn" ;uncomment if you want numlock to always be ON. Only have this code active in ONE SCRIPT. Having it in multiple will cause issues
; SetCapsLockState "AlwaysOff" ;uncomment if you want capslock to always be OFF. Only have this code active in ONE SCRIPT. Having it in multiple will cause issues
TraySetIcon(ptf.Icons "\resolve.png")
#Include "Functions.ahk" ;includes function definitions so they don't clog up this script. Functions.ahk must be in the same directory as this script

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.6.3

;\\CURRENT RELEASE VERSION
;\\v2.6.1
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

;any code you want to run all the time should go here

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
F1::rvalhold("zoom", 60, 1) ;press then hold F1 and drag to increase/decrese x position. Let go of F1 to confirm. Tap to reset
F2::rvalhold("position", 80, 1) ;press then hold F2 and drag to increase/decrese x position. Let go of F2 to confirm. Tap to reset
F3::rvalhold("position", 210, 1) ;press then hold F3 and drag to increase/decrese y position. Let go of F3 to confirm. Tap to reset
F4::rvalhold("rotation", 240, 0) ;press then hold F4 and drag to increase/decrese rotation. Let go of F4 to confirm. Tap to reset

;=========================================================
;		flips
;=========================================================
!h::rflip("horizontal") ;flip horizontally. won't do anything if you're scrolled down in the "video" tab already. you could add a wheelup if you wanted
!v::rflip("vertical") ;flip vertically. won't do anything if you're scrolled down in the "video" tab already. you could add a wheelup if you wanted

;=========================================================
;		Scale Adjustments
;=========================================================
^1::Rscale(1, "zoom", 60) ;makes the scale of current selected clip 100
^2::Rscale(2, "zoom", 60) ;makes the scale of current selected clip 200
^3::Rscale(3, "zoom", 60) ;makes the scale of current selected clip 300

;=========================================================
;
;		Drag and Drop Effect Presets
;
;=========================================================
!g::REffect("openfx", "gaussian blur") ;hover over a track on the timeline, press this hotkey, then watch as ahk drags that "favourite" onto the hovered track.
; this is set up as a preset so you can easily add further hotkeys with 1 line and new defined coords.

;=========================================================
;
;		better timeline movement
;
;=========================================================
;set colours
timeline1 := 0x3E3E42 ;timeline color inside the in/out points ON a targeted track
timeline2 := 0x39393E ;timeline color of the separating LINES between targeted AND non targeted tracks inside the in/out points
timeline3 := 0x28282E ;the timeline color inside in/out points on a NON targeted track
timeline4 := 0x1E1E22 ;the color of the bare timeline NOT inside the in out points
timeline5 := 0x3E3E42 ;the color of a SELECTED blank space on the timeline, NOT in the in/out points
timeline6 := 0x3E3E42 ;the color of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
timeline7 := 0x28282E ;the color of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
playhead1 := 0x572523
playhead2 := 0xE64B3D
timelineVal := [timeline1, timeline2, timeline3, timeline4, timeline5, timeline6, timeline7]
playheadVal := [playhead1, playhead2]
Rbutton:: ;ports the functionality of "right click premiere.ahk" as best as possible.
{
    static scrub := unset
    coord.w()
    block.On()
    MouseGetPos &xpos, &ypos
    if !ImageSearch(&editx, &editY, A_ScreenWidth / 3, A_ScreenHeight - 150, A_ScreenWidth, A_ScreenHeight, "*2 " Resolve "edit.png")
        {
            SendInput("{RButton}")
            block.Off()
            return
        }
    if !IsSet(scrub)
        {
            if !ImageSearch(&speakX, &speakY, A_ScreenWidth * 0.7, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Resolve "speaker1.png") && !ImageSearch(&speakX, &speakY, A_ScreenWidth * 0.7, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Resolve "speaker2.png")
                {
                    block.Off()
                    tool.Cust("Couldn't find reference point for scrub bar", 2000)
                    errorLog(A_ThisHotkey, "Couldn't find reference point for scrub bar", A_LineFile, A_LineNumber)
                    return
                }
            scrub := speakY + 74
            tool.Cust("This macro has grabbed the coordinates of your timeline`nIf you move your timeline, you'll need to reload the script to grab new coordinates", 2.5)
        }
    if ypos < scrub
        {
            SendInput("{Rbutton}")
            block.Off()
            return
        }
    Color := PixelGetColor(xpos, ypos)
    /* if (Color = timeline5 || Color = timeline6 || Color = timeline7) ;these are the timeline colors of a selected clip or blank space, in or outside of in/out points.
        SendInput(resolveDeselect)
        */
        ;not sure if the above is really needed within resolve. I'm not entirely sure their purpose within premiere and as I don't use resolve I'm unsure of the edge case scenarios you'd run into where this may be necessary
    if (Color = timelineVal[1] || Color = timelineVal[2] || Color = timelineVal[3] || Color = timelineVal[4] || Color = timelineVal[5] || Color = timelineVal[6] || Color = timelineVal[7] || Color = playheadVal[1]|| Color = playheadVal[2])
        {
            if GetKeyState("Rbutton", "P")
                {
                    MouseMove(xpos, scrub) ;this will warp the mouse to the top part of your timeline defined by &timeline
                    SendInput("{Click Down}")
                    MouseMove(xpos, ypos)
                    block.Off()
                    KeyWait(A_ThisHotkey)
                    SendInput("{Click Up}")
                    return
                }
            SendInput(resolveDeselect) ;in case you end up inside the "delete" right click menu from the timeline
            block.Off()
            return
        }
    sendinput("{Rbutton}") ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were NOT met.
    block.Off()
}
;=========================================================
;
;		gain
;
;=========================================================
Numpad1::rgain(-2)
Numpad2::rgain(2)
Numpad3::rgain(6)