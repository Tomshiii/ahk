SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.
#SingleInstance Force
#Include "%A_ScriptDir%\lib\KSA\Keyboard Shortcut Adjustments.ahk"
#Include "%A_ScriptDir%\lib\Functions\Startup.ahk"
#Include "%A_ScriptDir%\lib\Functions\After Effects.ahk"
#Include "%A_ScriptDir%\lib\Functions\Photoshop.ahk"
#Include "%A_ScriptDir%\lib\Functions\Premiere.ahk"
#Include "%A_ScriptDir%\lib\Functions\Resolve.ahk"
#Include "%A_ScriptDir%\lib\Functions\switchTo.ahk"
#Include "%A_ScriptDir%\lib\Functions\Windows.ahk"

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.10.2

;\\CURRENT RELEASE VERSION
;\\v2.6

; All of my functions use to be contained within this individual file but have since been split off into their own individual files which can be found in the \Functions\ folder in the root of the directory.
; The text below was all written back when that was the case so it might not make much sense in its current form but just assume everything below relates to everything
; This file now just acts as a script that all the others feed into so that I can just #Include this one script in all my other scripts

; All Code in this script (and the individual functions scripts found in \Functions\) is linked to a function
; for example:
; func(variable)
; 	{
;		code(%&variable%)
;	}
; Then in our main scripts we call on these functions like:
; Hotkey::func("information")
; then whatever you place within the "" will be put wherever you have a %&variable%
; I make use of code like this all throughout this script. All variables are explained above their respective functions and dynamically display that information when you hover over a function if you're using VSCode

; I have made a concious effort throughout the workings of this script to keep out as many raw pixel coords as possible, preferring imagesearches to ensure correct mouse movements
; but even still, an imagesearch still has a definable area that it searches for each image, for example
; ImageSearch(&xpos, &ypos, 312, 64, 1066, 1479,~~~~~) (check the ahk documentation for what each number represents)
; searches in a rectangle defined by the above coords (pixel coords default to window unless you change it to something else)
; These values will be the only thing you should theoretically need to change to get things working in your own setups (outside of potentially needing your own screenshots for things as different setups can mean different colours etc etc)
; Most premiere functions require no tinkering before getting started as we can sneakily grab the coordinates of some panels within premiere without needing to define them anywhere. Not all of my scripts have this kind of treatment though as sometimes it's just not practical, sometimes a function is so heavily reliant on my workspace/workflow that it would be a waste of time as you'd need to change a bunch of stuff anyway, or sometimes it's just not possible with the way I'm doing things.
; For the functions that don't get this special treatment, I have tried to make as many of these values as possible directly editable within KSI.ini to make it both easier and faster for you to adjust these scripts to your own layouts. Take a look over there before looking around in here

; Here we will define a bunch of global variables that we will reference in ImageSearches. This is simply to help cut down the amount of things needed to write out and also to just make things cleaner overall to look at and help discern. Please note I have no way to add dynamic comments to these for VSCode users.
