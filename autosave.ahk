#SingleInstance force ;only one instance of this script may run at a time!
A_MaxHotkeysPerInterval := 2000
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
TraySetIcon(A_WorkingDir "\Icons\save.ico") ;changes the icon this script uses in the taskbar
#Include Functions.ahk

;This script will autosave your premire pro project every 7.5min (by default) since adobe refuses to actually do so consistently. Thanks adobe.

global Premiere := A_WorkingDir "\ImageSearch\Premiere\"

;SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT HERE
minutes := 7.5
global ms := minutes * 60000

;SET THE AMOUNT OF SECONDS OF PRIOR KEYBOARD ACTIVITY YOU WANT THE SCRIPT TO USE TO STOP ITSELF FROM FIRING
secondsIdle := 0.5
global idle := secondsIdle * 1000

;SET THE AMOUNT OF SECONDS YOU WANT THE SCRIPT TO WAIT BEFORE RETRYING TO SAVE AFTER THE ABOVE IDLE ACTIVITY STOP OCCURS
secondsRetry := 5
global retry := secondsRetry * 1000

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
                if WinExist("ahk_exe Adobe Premiere Pro.exe")
				    toolCust("Don't forget you have the autosave script paused!", "3000")
                else
                    reload
				SetTimer(, -ms)
			}
			return
		}
	if toggle = 1
		{
			toggle := 0
            SetTimer(save, -ms)
			toolCust("You resumed the autosave script", "1000")
			SetTimer(reminder, 0)
		}		
}
save()
{
    if not WinExist("ahk_exe Adobe Premiere Pro.exe") ;this is here so the script won't error out if you close Premiere while it is waiting
        reload

    if A_TimeIdleKeyboard <= idle
        {
            SetTimer(, -retry)
            toolCust(A_ScriptName " tried to save but you interacted with the keyboard in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", "3000")
            goto end2
        }

    stop := ""
    ToolTip("Your Premiere Pro project is being saved!`nHold tight!")

    ;\\ first we grab information on the active window
    try {
        id := WinGetProcessName("A")
        if WinActive("ahk_exe explorer.exe")
            id := "ahk_class CabinetWClass"
    } catch as e {
        toolCust("couldn't grab active window", "1000")
        errorLog(A_ThisFunc "()", "Couldn't define the active window", A_LineNumber)
    }

    ;\\ Now we begin
    blockOn()

    ;\\ First we grab the titles of both premiere and after effects so we can make sure to only fire this script if a save is required
    try {
        if WinExist("ahk_exe Adobe Premiere Pro.exe")
        {
            premCheck := WinGetTitle("ahk_class Premiere Pro")
            titlecheck := InStr(premCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            saveCheck := SubStr(premCheck, -1, 1) ;this variable will contain "*" if a save is required
        }
        if WinExist("ahk_exe AfterFX.exe")
            {
                afterFXTitle := WinGetTitle("ahk_exe AfterFX.exe")
                aeSaveCheck := SubStr(afterFXTitle, -1, 1) ;this variable will contain "*" if a save is required
            }
        if not WinExist("ahk_exe AfterFX.exe")
            aeSaveCheck := ""
    } catch as e {
        toolCust("Couldn't determine the titles of Adobe programs", "1000")
        errorLog(A_ThisFunc "()", "Couldn't determine the titles of Adobe programs", A_LineNumber)
    }
    if not titlecheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
        {
            blockOff()
            toolCust("You're currently doing something`nautosave has be cancelled", "2000")
            try {
                if id = "ahk_class CabinetWClass"
                    WinActivate("ahk_class CabinetWClass")
                else
                    WinActivate("ahk_exe " id)
            } catch as e {
                toolCust("couldn't activate original window", "1000")
                errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineNumber)
            }
            SetTimer(, -ms)
            goto end2
        }
    if saveCheck != "*" ;will check to see if saving is necessary
        {
            if aeSaveCheck = "*" ;this variable will contain "*" if a save is required
                {
                    WinActivate("ahk_exe AfterFX.exe")
                    sleep 500
                    SendInput("^s")
                    sleep 250
                    WinWaitClose("Save Project")
                    goto end
                }
            blockOff()
            toolCust("No save necessary", "2000")
            try {
                if id = "ahk_class CabinetWClass"
                    WinActivate("ahk_class CabinetWClass")
                else
                    WinActivate("ahk_exe " id)
            } catch as e {
                toolCust("couldn't activate original window", "1000")
                errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineNumber)
            }
            SetTimer(, -ms)
            goto end2
        }

    if id != "Adobe Premiere Pro.exe" ;will activate premiere if it wasn't the original window
        WinActivate("ahk_exe Adobe Premiere Pro.exe")
    try {
        SendInput(timelineWindow)
        SendInput(timelineWindow)
        SendInput(programMonitor)
        SendInput(programMonitor)
        sleep 250
        toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
        ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
        sleep 250
        if ImageSearch(&x, &y, %&toolx%, %&tooly%, %&toolx% + %&width%, %&tooly% + %&height%, "*2 " Premiere "stop.png")
            {
                toolCust("If you were playing back anything, this function should resume it", "1000")
                stop := "yes"
            }
        else
            stop := "no"
    } catch as er {
        SendInput("^s") ;attempt a save just in case
        blockOff() ;then bail
        toolCust("failed to find play/stop button", "1000")
        errorLog(A_ThisFunc "()", "Couldn't find the play/stop button", A_LineNumber)
        return
    }

    ;\\ before finally saving
    SendInput("^s")
    WinWait("Save Project")
    WinWaitClose("Save Project")

    ;\\ if ae is open we'll check to see if it needs saving, then save it too if required
    if aeSaveCheck = "*"
        {
            WinActivate("ahk_exe AfterFX.exe")
            sleep 500
            SendInput("^s")
            sleep 250
            WinWaitClose("Save Project")
        }

    ;\\ if the originally active window isn't premiere, we don't want to refocus it so we'll jump straight to the end
    if id != "Adobe Premiere Pro.exe"
        goto end
        
    ;\\ if the orginally active window IS premiere, we now refocus premiere
    try {
        sleep 250
        WinActivate("ahk_exe Adobe Premiere Pro.exe")
    } catch as e {
        toolCust("couldn't activate Premiere Pro", "1000")
        errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineNumber)
    }

    ;\\ if a video was playing, we now start it up again
    if stop = "yes"
        {
            sleep 250
            SendInput(timelineWindow)
            SendInput(timelineWindow)
            sleep 100
            SendInput("{Space}")
            blockOff()
            ToolTip("")
            SetTimer(, -ms) ;reset the timer
            goto end2
        }
    
    end:
    try {
        if id = "ahk_class CabinetWClass"
            WinActivate("ahk_class CabinetWClass")
        else
            WinActivate("ahk_exe " id) ;attempt to reactivate the original window
    } catch as e {
        toolCust("couldn't activate original window", "1000")
        errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineNumber)
    }
    blockOff()
    ToolTip("")
    SetTimer(, -ms) ;reset the timer
    end2:
}

