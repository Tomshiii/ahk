#SingleInstance force ;only one instance of this script may run at a time!
A_MaxHotkeysPerInterval := 2000
;checks to make sure the user is using a compatible version of ahk
verCheck()
TraySetIcon(A_WorkingDir "\Support Files\Icons\save.ico") ;changes the icon this script uses in the taskbar
#Include Functions.ahk
InstallKeybdHook() ;required so A_TimeIdleKeyboard works and doesn't default back to A_TimeIdle
#WinActivateForce

;This script will autosave your premire pro project every 7.5min (by default) since adobe refuses to actually do so consistently. Thanks adobe.
;It will also ensure you have the checklist script for the current project open. If it can find the file, it will open it automatically

global Premiere := A_WorkingDir "\Support Files\ImageSearch\Premiere\"

;SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT BEFORE SAVING HERE
minutes := 7.5
global ms := minutes * 60000

;SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT BEFORE REMINDING YOU TO OPEN THE CHECKLIST HERE
minutesChecklist := .5
global msChecklist := minutesChecklist * 60000

;SET THE AMOUNT OF SECONDS OF PRIOR KEYBOARD ACTIVITY YOU WANT THE SCRIPT TO USE TO STOP ITSELF FROM FIRING
secondsIdle := 0.5
global idle := secondsIdle * 1000

;SET THE AMOUNT OF SECONDS YOU WANT THE SCRIPT TO WAIT BEFORE RETRYING TO SAVE AFTER THE ABOVE IDLE ACTIVITY STOP OCCURS
secondsRetry := 2.5
global retry := secondsRetry * 1000

start:
if WinExist("ahk_exe Adobe Premiere Pro.exe")
    {
        SetTimer(save, -ms)
        SetTimer(check, -msChecklist) ;if you do not wish to use the checklist script, simply comment out this timer
    }
else
    {
        WinWait("ahk_exe Adobe Premiere Pro.exe")
        goto start
    }

check() {
    if not WinExist("ahk_exe Adobe Premiere Pro.exe") ;this is here so the script won't error out if you close Premiere while it is waiting
        {
            SetTimer(, -msChecklist)
            goto end3
        }
    if WinExist("Editing Checklist")
        {
            SetTimer(, -msChecklist)
            goto end3
        }
    openChecklist() ;this function can be found in \Functions\Premiere.ahk
    if WinExist("ahk_class tooltips_class32") ;checking to see if any tooltips are active before beginning
        WinWaitClose("ahk_class tooltips_class32",, 3)
    if not WinExist("Editing Checklist")
        toolCust("Don't forget to start the checklist for this project!", "2000")
    SetTimer(, -msChecklist) ;I don't want this to continue checking every minute once it's open so I'm using the larger timer here.
    end3:
}

save()
{
    if not WinExist("ahk_exe Adobe Premiere Pro.exe") ;this is here so the script won't error out if you close Premiere while it is waiting
        reload

    stop := ""
    ToolTip("Your Premiere Pro project is being saved!`nHold tight!`nThis function will timeout after 3s if it gets stuck")

    ;\\ first we grab information on the active window
    try {
        id := WinGetProcessName("A")
        if WinActive("ahk_exe explorer.exe")
            id := "ahk_class CabinetWClass"
    } catch as e {
        toolCust("couldn't grab active window", "1000")
        errorLog(A_ThisFunc "()", "Couldn't define the active window", A_LineFile, A_LineNumber)
    }

    ;\\ First we grab the titles of both premiere and after effects so we can make sure to only fire this script if a save is required
    try {
        if WinExist("ahk_exe Adobe Premiere Pro.exe")
        {
            premCheck := WinGetTitle("ahk_class Premiere Pro")
            titlecheck := InStr(premCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            saveCheck := SubStr(premCheck, -1, 1) ;this variable will contain "*" if a save is required
            if titlecheck = ""
                {
                    blockOff()
                    toolCust("``titlecheck`` variable wasn't assigned a value", "1000")
                    errorLog(A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                    goto end2
                }
        }
        if WinExist("ahk_exe AfterFX.exe")
            {
                afterFXTitle := WinGetTitle("ahk_exe AfterFX.exe")
                aeSaveCheck := SubStr(afterFXTitle, -1, 1) ;this variable will contain "*" if a save is required
                if afterFXTitle = ""
                    {
                        blockOff()
                        toolCust("``afterFXTitle`` variable wasn't assigned a value", "1000")
                        errorLog(A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                        goto end2
                    }
            }
        if not WinExist("ahk_exe AfterFX.exe")
            aeSaveCheck := ""
    } catch as e {
        blockOff()
        toolCust("Couldn't determine the titles of Adobe programs", "1000")
        errorLog(A_ThisFunc "()", "Couldn't determine the titles of Adobe programs", A_LineFile, A_LineNumber)
        goto end2
    }
    if not IsSet(titlecheck)
        {
            blockOff()
            toolCust("``titlecheck`` variable wasn't assigned a value", "1000")
            errorLog(A_ThisFunc "()", "``titlecheck`` variable wasn't assigned a value", A_LineFile, A_LineNumber)
            goto end2
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
                errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
                goto end2
            }
            SetTimer(, -ms)
            goto end2
        }
    if id = "Adobe Premiere Pro.exe" ;this check is a final check to ensure the user doesn't have a menu window (or something similar) open that the first title check didn't grab (because we get the title of premiere in general and not the current active window)
        {
            premWinCheck := WinGetTitle("A")
            premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            if not premTitleCheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
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
                        errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
                    }
                    SetTimer(, -ms)
                    goto end2
                }
        }
    if saveCheck != "*" ;will check to see if saving is necessary
        {
            if not IsSet(afterFXTitle)
                {
                    blockOff()
                    toolCust("``afterFXTitle`` variable wasn't assigned a value", "1000")
                    errorLog(A_ThisFunc "()", "``afterFXTitle`` variable wasn't assigned a value", A_LineFile, A_LineNumber)
                    goto end2
                }
            if aeSaveCheck = "*" ;this variable will contain "*" if a save is required
                {
                    if A_TimeIdleKeyboard <= idle
                        {
                            SetTimer(, -retry)
                            toolCust(A_ScriptName " tried to save but you interacted with the keyboard in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", "3000")
                            goto end2
                        }
                    blockOn()
                    WinActivate("ahk_exe AfterFX.exe")
                    sleep 500
                    SendInput("^s")
                    sleep 250
                    WinWaitClose("Save Project",, 3)
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
                errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
            }
            SetTimer(, -ms)
            goto end2
        }

    if id != "Adobe Premiere Pro.exe" ;will activate premiere if it wasn't the original window
        WinActivate("ahk_exe Adobe Premiere Pro.exe")
    try {
        /* SendInput(timelineWindow)
        SendInput(timelineWindow)
        SendInput(programMonitor)
        SendInput(programMonitor)
        sleep 250
        toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
        ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
        sleep 250 */
        premWinCheck := WinGetTitle("A")
        premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
        if premWinCheck = ""
            {
                switchToPremiere()
                premWinCheck := WinGetTitle("A")
                premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            }
        if not premTitleCheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
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
                    errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
                }
                SetTimer(, -ms)
                goto end2
            }
        if ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Premiere "stop.png") ;if you don't have your project monitor on your main computer monitor, you can try using the code above and swapping out x1/2 & y1/2 with the respective properties, ClassNN values are just an absolute pain in the neck and sometimes just choose to break for absolutely no reason - I just got over relying on them for this script. My project window is on the right side of my screen (which is why the first x value is A_ScreenWidth/2 - if yours is on the left you can simply switch these two values
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
        errorLog(A_ThisFunc "()", "Couldn't find the play/stop button", A_LineFile, A_LineNumber)
        return
    }

    if A_TimeIdleKeyboard <= idle
        {
            SetTimer(, -retry)
            toolCust(A_ScriptName " tried to save but you interacted with the keyboard in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", "3000")
            goto end2
        }
    
    ;\\ Now we begin
    blockOn()
        
    ;\\ before finally saving
    SendInput("^s")
    WinWait("Save Project",, 3)
    WinWaitClose("Save Project",, 3)

    ;\\ if ae is open we'll check to see if it needs saving, then save it too if required
    if aeSaveCheck = "*"
        {
            WinActivate("ahk_exe AfterFX.exe")
            sleep 500
            SendInput("^s")
            sleep 250
            WinWaitClose("Save Project",, 3)
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
        errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
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
            SendInput(timelineWindow)
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
        errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
    }
    blockOff()
    ToolTip("")
    SetTimer(, -ms) ;reset the timer
    end2:
}

