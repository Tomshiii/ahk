#SingleInstance Force

;//! this script is mostly designed for my own workflow and isn't really built out with an incredible amount of logic.
;//! it is designed to swap the L/R channel on a single track stereo file.
;//! attempting to use this script on anything else will either produce unintended results or will simply not function at all
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\settings.ahk
#Include Classes\ptf.ahk
#Include Classes\block.ahk
#Include Classes\obj.ahk
#Include Classes\errorLog.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\CLSID_Objs.ahk
; }

if !WinActive(prem.winTitle)
    return

prem.swapChannels()