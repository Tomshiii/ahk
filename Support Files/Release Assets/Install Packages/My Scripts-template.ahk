#SingleInstance Force
#Requires AutoHotkey v2.0

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\Settings.ahk
#Include Classes\ptf.ahk
#Include Classes\Startup.ahk

 ;// add all other required #Include's
; }

;//! THIS FILE SHOULD ONLY SERVE AS AN EXAMPLE, IT WILL BE OVERRIDDEN DURING ANY UPDATES
;//! MAKE YOUR OWN FILES IN THEIR OWN LOCATION

SetWorkingDir(ptf.rootDir)
SetDefaultMouseSpeed(0)
SetWinDelay(0)
A_MaxHotkeysPerInterval := 400
A_MenuMaskKey := "vkD7"

OnExit(__exit)
__exit(ExitReason, ExitCode) {
    try WinEvent.Stop()
    if ExitReason = "Shutdown"
        ExitApp()
}

start := Startup()
start.trayMen()
start.oldLogs()

;// if using adobe apps
start.adobeTemp()
start.adobeVerOverride()
start.checkVersJSON()
;//
start.checkShortcuts()
start.__Delete()
start := ""
errorLog({state:"empty"})

#HotIf
; ...

;// if using Premiere and wish to use `Premiere_RightClick.ahk`

;//! Premiere
; #HotIf WinActive(editors.Premiere.winTitle) && !GetKeyState("F24")

;#Include My Scripts\Premiere.ahk ;this is MY premiere hotkeys. It is recommended you replace this with your own

;// I have this here instead of running it separately because sometimes if the main script loads after this one things get funky and break because of priorities and stuff
; #Include Classes\Editors\Premiere_RightClick.ahk
; Ctrl & \::return