SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
SetDefaultMouseSpeed 0
#SingleInstance Force
; SetNumLockState "AlwaysOn" ;uncomment if you want numlock to always be ON
; SetCapsLockState "AlwaysOff" ;uncomment if you want capslock to always be OFF
TraySetIcon(A_WorkingDir "\Icons\resolve.png")
#Include "Functions.ahk" ;includes function definitions so they don't clog up this script. Functions.ahk must be in the same directory as this script ;includes function definitions so they don't clog up this script
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.3
;\\Minimum Version of "Resolve.ahk" Required for this script
;\\v2.9.4

;\\CURRENT RELEASE VERSION
;\\v2.3.4
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
playhead := 0x572523
playhead2 := 0xE64B3D
Rbutton:: ;ports the functionality of "right click premiere.ahk" as best as possible. It will require you to set the y coordinate of your seek bar below as Resolve doesn't have a "move playhead to cursor" hotkey like premiere does
{
    scrub := 0
    coordw()
    blockOn()
    MouseGetPos &xpos, &ypos
    if not ImageSearch(&editx, &editY, 0, A_ScreenHeight / 2, A_ScreenWidth, A_ScreenHeight, "*2 " Resolve "edit.png")
        {
            SendInput("{RButton}")
            blockOff()
            return
        }
    if ImageSearch(&speakX, &speakY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Resolve "speaker1.png")
        {
            scrub := %&speakY% + 74
            goto cont
        }
    else if ImageSearch(&speakX, &speakY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Resolve "speaker2.png")
        {
            scrub := %&speakY% + 74
            goto cont
        }
    else
        {
            blockOff()
            toolCust("Couldn't find reference point for scrub bar", "2000")
            errorLog(A_ThisHotkey, "Couldn't find reference point for scrub bar", A_LineFile, A_LineNumber)
            return
        }
    cont:
    if %&ypos% < scrub
        {
            SendInput("{Rbutton}")
            blockOff
            return
        }
    Color := PixelGetColor(%&xpos%, %&ypos%)
    /* if (Color = timeline5 || Color = timeline6 || Color = timeline7) ;these are the timeline colors of a selected clip or blank space, in or outside of in/out points.
        SendInput(resolveDeselect)
        */
        ;not sure if the above is really needed within resolve. I'm not entirely sure their purpose within premiere and as I don't use resolve I'm unsure of the edge case scenarios you'd run into where this may be necessary
    if (Color = timeline1 || Color = timeline2 || Color = timeline3 || Color = timeline4 || Color = timeline5 || Color = timeline6 || Color = timeline7 || Color = playhead || Color = playhead2)
        {
            if GetKeyState("Rbutton", "P")
                {
                    MouseMove(%&xpos%, scrub) ;this will warp the mouse to the top part of your timeline defined by &timeline
                    SendInput("{Click Down}")
                    MouseMove(%&xpos%, %&ypos%)
                    blockOff()
                    KeyWait(A_ThisHotkey)
                    SendInput("{Click Up}")
                    return
                }
            SendInput(resolveDeselect) ;in case you end up inside the "delete" right click menu from the timeline
            blockOff()
            return
        }
    else
        sendinput("{Rbutton}") ;this is to make up for the lack of a ~ in front of Rbutton. ... ~Rbutton. It allows the command to pass through, but only if the above conditions were NOT met.
        blockOff()
}
;=========================================================
;
;		gain
;
;=========================================================
Numpad1::rgain("-2")
Numpad2::rgain("2")
Numpad3::rgain("6")