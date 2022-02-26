#SingleInstance force ;only one instance of this script may run at a time!
A_MaxHotkeysPerInterval := 2000
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
TraySetIcon(A_WorkingDir "\Icons\save.ico") ;changes the icon this script uses in the taskbar
#Include Functions.ahk

;This script will autosave your premire pro project every 5min since adobe refuses to actually do so. Thanks adobe.

/*
 This value will send the keyboard shortcut you have set to activate the Effect Controls Window within Premiere.
 
 Can be set within KSA.ahk/ini
 */
programMonitor := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Program Monitor")

/*
 This value will send the keyboard shortcut you have set to activate the timeline Window within Premiere.
 
 Can be set within KSA.ahk/ini
 */
timelineWindow := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Timeline")

global Premiere := A_WorkingDir "\ImageSearch\Premiere\"




;SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT HERE
minutes := 7.5
global ms := minutes * 60000

start:
if WinExist("ahk_exe Adobe Premiere Pro.exe")
    SetTimer(save, -ms)
else
    {
        WinWait("ahk_exe Adobe Premiere Pro.exe")
        goto start
    }

save()
{
    if not WinExist("ahk_exe Adobe Premiere Pro.exe") ;this is here so the script won't error out if you close Premiere while it is waiting
        reload
    stop := ""
    ToolTip("Your Premiere Pro project is being saved!`nHold tight!")
    try {
        id := WinGetClass("A")
        title := WinGetTitle("A")
    } catch as e {
        toolCust("couldn't grab active window", "1000")
        errorLog("autosave.ahk", "Couldn't define the active window")
    }
    blockOn()
    ;ToolTip("Saving your Premiere project")
    if not WinActive("ahk_exe Adobe Premiere Pro.exe")
        {
            WinActivate("ahk_exe Adobe Premiere Pro.exe")
            sleep 500
            try {
                ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
            } catch as win {
                toolCust("", "10")
            }
        }
    sleep 1000
    if id = "Premiere Pro"
       try {
            ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
            SendInput(programMonitor)
            SendInput(programMonitor)
            sleep 500
            toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
            ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
            sleep 500
            if ImageSearch(&x, &y, %&toolx%, %&tooly%, %&toolx% + %&width%, %&tooly% + %&height%, "*2 " Premiere "stop.png")
                {
                    toolCust("If you were playing back anything, this function should resume it", "1000")
                    stop := "yes"
                }
            else
                stop := "no"
        } catch as er {
            toolCust("failed to find play/stop button", "1000")
            errorLog("autosave.ahk", "Couldn't find the play/stop button")
        }
    SendInput("^s")
    WinWaitClose("Save Project")
    try {
        ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
    } catch as win {
        toolCust("", "10")
    }
    sleep 1000
    if stop = "yes"
        {
            SendInput(timelineWindow)
            SendInput(timelineWindow)
            SendInput("{Space}")
        }
    try {
        WinActivate(title)
    } catch as e {
        toolCust("couldn't activate original window", "1000")
        errorLog("autosave.ahk", "Couldn't activate the original active window")
    }
    blockOff()
    ToolTip("")
    SetTimer(, -ms)
}

