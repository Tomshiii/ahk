#SingleInstance force ;only one instance of this script may run at a time!
A_MaxHotkeysPerInterval := 2000
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
TraySetIcon(A_WorkingDir "\Icons\save.ico") ;changes the icon this script uses in the taskbar

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

/* blockOn()
 blocks all user inputs [IF YOU GET STUCK IN A SCRIPT PRESS YOUR REFRESH HOTKEY (CTRL + R BY DEFAULT) OR USE CTRL + ALT + DEL to open task manager and close AHK]
 */
blockOn()
 {
     BlockInput "SendAndMouse"
     BlockInput "MouseMove"
     BlockInput "On"
     ;it has recently come to my attention that all 3 of these operate independantly and doing all 3 of them at once is no different to just using "BlockInput "on"" but uh. oops, too late now I guess
 }
 
/* blockOff()
  turns off the blocks on user input
  */
blockOff()
 {
     blockinput "MouseMoveOff"
     BlockInput "off"
 }

/* toolCust()
 create a tooltip with any message
 * @param message is what you want the tooltip to say
 * @param timeout is how many ms you want the tooltip to last
 */
toolCust(message, timeout)
{
	ToolTip(%&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}

#+1::
{
    if A_IsPaused = 0
        {
            toolCust("you paused the autosave script", "1000")
            sleep 1500
        }
    else
        toolCust("you unpaused the autosave script", "1000")
    Pause -1 ;pauses/unpauses this script.
}

save:
if WinExist("ahk_exe Adobe Premiere Pro.exe")
    {
        stop := ""
        ToolTip("Your Premiere Pro project is being saved!`nHold tight!")
        try {
            id := WinGetClass("A")
            title := WinGetTitle("A")
        } catch as e {
            toolCust("couldn't grab active window", "1000")
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
        }
        blockOff()
        ToolTip("")
        sleep 300000
        goto save
    }
else
    {
        WinWait("ahk_exe Adobe Premiere Pro.exe")
        sleep 10000
        goto save
    }

