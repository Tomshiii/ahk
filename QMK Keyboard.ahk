; { \\ #Includes
#Include <Classes\ptf>
;there are more includes down below
; }

#Requires AutoHotkey v2.0
SetWorkingDir(ptf.rootDir)
SetDefaultMouseSpeed(0) ;sets default MouseMove speed to 0 (instant)
SetWinDelay(0) ;sets default WinMove speed to 0 (instant)
TraySetIcon(ptf.Icons "\keyboard.ico")
;SetCapsLockState "AlwaysOff" ;having this on broke my main script for whatever reason
SetNumLockState("AlwaysOn")
#SingleInstance Force ;only one instance of this script may run at a time!
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm ;prevent taskbar flashing.

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.13.6

;\\CURRENT RELEASE VERSION
;\\v2.8.2

; \\\\\\\\////////////
; THIS SCRIPT WAS ORIGINALLY CREATED BY TARAN FROM LTT, I HAVE REWORKED IT TO WORK IN AHK v2.0 and then completely changed it to be for my workflow
; ALSO I AM CURRENTLY USING A PLANCK EZ CUSTOM KEYBOARD WITH CUSTOM QMK FIRMWARE AND NOT USING THE HASU USB -> USB CONVERTER. Check Release v2.2.5.1 and below for a version of this script written for a small secondary numpad
; ANY OF THE MACROS/FUNCTIONS IN THIS FILE CAN BE PULLED OUT AND THEN REPLACED ON A NORMAL KEY ON YOUR NORMAL KEYBOARD
; This script looked very different when initially committed. Its messiness was too much of a pain for me so I've stripped a bunch of
; unnecessary comments
; \\\\\\\\///////////

;;WHAT'S THIS ALL ABOUT??
; Check out the wiki page here: https://github.com/Tomshiii/ahk/wiki/QMK.ahk


;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;;
;;+++++++++++++++++ BEGIN SECOND KEYBOARD F24 ASSIGNMENTS +++++++++++++++++++++;;
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;;

;; You should DEFINITELY not be trying to add a 2nd keyboard unless you're already
;; familiar with how AutoHotkey works. I recommend that you at least take this tutorial:
;; https://lexikos.github.io/v2/docs/Tutorial.htm

;;COOL BONUS BECAUSE YOU'RE USING QMK:
;;The up and down keystrokes are registered seperately.
;;Therefore, your macro can do half of its action on the down stroke,
;;And the other half on the up stroke. (using "keywait,")
;;This can be very handy in specific situations.
;;The Corsair K55 keyboard (and most other keyboards that let you make macros/launch things) fires the up and down keystrokes instantly.

;Numlock is an AWFUL key. I prefer to leave it permanently on.

;DEFINE SEPARATE PROGRAMS FIRST, THEN ANYTHING YOU WANT WHEN NO PROGRAM IS ACTIVE ->

;===========================================================================
#HotIf WinActive(editors.Premiere.winTitle) and getKeyState("F24", "P")
#Include <QMK\Prem>
;===========================================================================
#HotIf WinActive(editors.AE.winTitle) and getKeyState("F24", "P")
#Include <QMK\AE>
;===========================================================================
#HotIf getKeyState("F24", "P") and WinActive(editors.Photoshop.winTitle)
#Include <QMK\Photoshop>
;===========================================================================
#HotIf getKeyState("F24", "P") and WinActive(browser.vscode.winTitle)
#Include <QMK\VSCode>
;===========================================================================
#HotIf getKeyState("F24", "P") ;these will work everywhere
#Include <QMK\Always>
;===========================================================================


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/*
Everything I use so you can easy copy paste for new programs

BackSpace::unassigned()
SC028::unassigned() ; ' key
Enter::unassigned()
;Right::unassigned()

p::unassigned()
SC027::unassigned()
/::unassigned()
;Up::unassigned()

o::unassigned()
l::unassigned()
.::unassigned()
;Down::unassigned()

i::unassigned()
k::unassigned()
,::unassigned()
;Left::unassigned()

u::unassigned()
j::unassigned()
m::unassigned()
;PgUp::unassigned()

y::unassigned()
; h::unassigned()
n::unassigned()
;Space::unassigned()

t::unassigned()
g::unassigned()
b::unassigned()

r::unassigned()
f::unassigned()
v::unassigned()
;PgDn::unassigned()

e::unassigned()
d::unassigned()
c::unassigned()
;End::unassigned()

w::unassigned()
;s::unassigned()
;x::unassigned()
;F15::unassigned()

q::unassigned()
a::unassigned()
z::unassigned()
; F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()
 */