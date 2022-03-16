#SingleInstance force ;only one instance of this script may run at a time!
A_MaxHotkeysPerInterval := 2000
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
TraySetIcon(A_WorkingDir "\Icons\save.ico") ;changes the icon this script uses in the taskbar
#Include Functions.ahk

;This script will autosave your premire pro project every 7.5min since adobe refuses to actually do so. Thanks adobe.

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
;pauseautosaveHotkey;
#+1:: ;this is a toggle to pause/unpause the autosave script. Will also remind the user the script is paused
{
	static toggle := 0
	if toggle = 0
		{
			toggle := 1
            SetTimer(save, 0)
			toolCust("You paused the autosave script", "1000")
			SetTimer(reminder, -ms)
			reminder()
			{
				toolCust("Don't forget you have the autosave script paused!", "3000")
				SetTimer(, -ms)
			}
			return
		}
	if toggle = 1
		{
			toggle := 0
            SetTimer(save, -ms)
			toolCust("You unpaused the autosave script", "1000")
			SetTimer(reminder, 0)
		}		
}
save()
{
    if not WinExist("ahk_exe Adobe Premiere Pro.exe") ;this is here so the script won't error out if you close Premiere while it is waiting
        reload

    stop := ""
    ToolTip("Your Premiere Pro project is being saved!`nHold tight!")

    ;\\ first we grab information on the active window
    try {
        id := WinGetClass("A")
        title := WinGetTitle("A")
    } catch as e {
        toolCust("couldn't grab active window", "1000")
        errorLog(A_ThisFunc "()", "Couldn't define the active window", A_LineNumber)
    }

    ;\\ next we activate premiere
    blockOn()
    if not WinActive("ahk_exe Adobe Premiere Pro.exe")
        {
            try {
                WinActivate("ahk_exe Adobe Premiere Pro.exe")
                sleep 500
                ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
            } catch as win {
                toolCust("", "10")
            }
        }
    sleep 1000

    ;\\ now we check to make sure you're not doing something other than using the timeline
    try {
        premCheck := WinGetTitle("A")
        titlecheck := InStr(premCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
    } catch as e {
        toolCust("Premiere wasn't determined to be the active window", "1000")
        errorLog(A_ThisFunc "()", "Premiere wasn't determined to be the active window", A_LineNumber)
    }
    if not titlecheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
        {
            toolCust("You're currently doing something`nautosave has be cancelled", "2000")
            try {
                WinActivate(title)
            } catch as e {
                toolCust("couldn't activate original window", "1000")
                errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineNumber)
            }
            blockOff()
            SetTimer(, -ms)
        }

    ;\\ Now we check to see if the user is playing back a video
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
            errorLog(A_ThisFunc "()", "Couldn't find the play/stop button", A_LineNumber)
        }

    ;\\ before finally saving
    SendInput("^s")
    WinWaitClose("Save Project")

    ;\\ if ae is open we'll save it too
    if WinExist("ahk_exe AfterFX.exe")
        {
            WinActivate("ahk_exe AfterFX.exe")
            sleep 500
            SendInput("^s")
            WinWaitClose("Save Project")
            WinActivate("ahk_exe Adobe Premiere Pro.exe")
            sleep 500
        }
        
    ;\\ now we refocus premiere
    try {
        ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
    } catch as win {
        toolCust("", "10")
    }
    sleep 1000

    ;\\ if a video was playing, we now start it up again
    if stop = "yes"
        {
            SendInput(timelineWindow)
            SendInput(timelineWindow)
            SendInput("{Space}")
        }
    ;\\ before finally refocusing the original window
    if not id = "Premiere Pro"
        {
            try {
                WinActivate(title)
            } catch as e {
                toolCust("couldn't activate original window", "1000")
                errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineNumber)
            }
        }
    blockOff()
    ToolTip("")
    SetTimer(, -ms) ;reset the timer
}

