SetWorkingDir(ptf.rootDir)  ; Ensures a consistent starting directory.
#SingleInstance Force
#Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Functions\Startup>
#Include <\Functions\Editors\After Effects>
#Include <\Functions\Editors\Photoshop>
#Include <\Functions\Editors\Premiere>
#Include <\Functions\Editors\Resolve>
#Include <\Functions\switchTo>
#Include <\Functions\Windows>
#Include <\Apps\Discord>
#Include <\Apps\VSCode>
#Include <\Functions\Move>
#Include <\Functions\GUIs>
#Include <\Other\IncludeLibs>

; \\
    ; This script use to be placed in the root directory, I have since changed the way my scripts are laid out so they include all the necessary files they require for proper function instead of using these bulk files to include everything
; \\


;\\CURRENT RELEASE VERSION
;\\v2.7.0.1

; All of my functions use to be contained within this individual file but have since been split off into their own individual files which can be found in the \Functions\ folder in the root of the directory.
; The text below was all written back when that was the case so it might not make much sense in its current form but just assume everything below relates to everything
; This file now just acts as a script that all the others feed into so that I can just #Include this one script in all my other scripts

; All Code in this script (and the individual functions scripts found in \Functions\) is linked to a function
; for example:
; func(variable)
; 	{
;		code(variable)
;	}
; Then in our main scripts we call on these functions like:
; Hotkey::func("information")
; then whatever you place within the "" will be put wherever you have a variable
; I make use of code like this all throughout this script. All variables are explained above their respective functions and dynamically display that information when you hover over a function if you're using VSCode

; I have made a concious effort throughout the workings of this script to keep out as many raw pixel coords as possible, preferring imagesearches to ensure correct mouse movements
; but even still, an imagesearch still has a definable area that it searches for each image, for example
; ImageSearch(&xpos, &ypos, 312, 64, 1066, 1479,~~~~~) (check the ahk documentation for what each number represents)
; searches in a rectangle defined by the above coords (pixel coords default to window unless you change it to something else)
; These values will be the only thing you should theoretically need to change to get things working in your own setups (outside of potentially needing your own screenshots for things as different setups can mean different colours etc etc)
; Most premiere functions require no tinkering before getting started as we can sneakily grab the coordinates of some panels within premiere without needing to define them anywhere. Not all of my scripts have this kind of treatment though as sometimes it's just not practical, sometimes a function is so heavily reliant on my workspace/workflow that it would be a waste of time as you'd need to change a bunch of stuff anyway, or sometimes it's just not possible with the way I'm doing things.
; For the functions that don't get this special treatment, I have tried to make as many of these values as possible directly editable within KSI.ini to make it both easier and faster for you to adjust these scripts to your own layouts. Take a look over there before looking around in here