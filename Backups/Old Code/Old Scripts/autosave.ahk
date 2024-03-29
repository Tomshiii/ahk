/*
    This script has been replaced with a more efficient and less messy script.
    Enjoy a piece of this repo's history
 */


#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0-beta.12
#Include FuncRedirect.ahk
A_MaxHotkeysPerInterval := 2000
TraySetIcon(ptf.Icons "\save.ico") ;changes the icon this script uses in the taskbar
InstallKeybdHook() ;required so A_TimeIdleKeyboard works and doesn't default back to A_TimeIdle
#WinActivateForce

;right clicking on the tray icon for this script will offer you a button to show you how much time is remaining until the next save attempt
A_TrayMenu.Insert("7&")
A_TrayMenu.Insert("8&", "Time Remaining", timeRemain)
timeRemain(*)
{
    if timer = false
        forTray := "Timer not currently tracking"
    else
        forTray := Round(((minutes * 60) - ElapsedTime)/ 60, 2) "min"
    MsgBox(forTray)
}

;This script will autosave your premire pro project every 5min (by default) since adobe refuses to actually do so consistently. Thanks adobe.
;It will also ensure you have the checklist script for the current project open. If it can find the file, it will open it automatically

if !FileExist(ptf["settings"])
    {
        sleep 5000 ;just incase this script loads before `My Scripts.ahk`
        if !FileExist(ptf["settings"])
            {
                myrelease := getVer()
                if myrelease = ""
                    myrelease := "v2.5" ;if you're not using `My Scripts.ahk` this line will just autopopulate a number to stop errors
                FileAppend("[Settings]`nupdate check=true`ntooltip=true`n`n[Adjust]`nadobe GB=45`nadobe FS=5`nautosave MIN=5`nprem year=" A_Year "`nae year=" A_Year "`n`n[Track]`nadobe temp=`nworking dir=" ptf.rootDir "`nfirst check=true`nversion=" MyRelease, ptf["settings"])
            }
    }

;SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT BEFORE SAVING WITHIN `settings.ini` OR BY PULLING UP THE SETTINGSGUI() WINDOW (by default #F1 or right clicking on `My Scripts.ahk`). (note: adjusting this value to be higher will not change the tools that appear every minute towards a save attempt)
minutes := IniRead(ptf["settings"], "Adjust", "autosave MIN")
global ms := minutes * 60000

;SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT BEFORE REMINDING YOU TO OPEN THE CHECKLIST HERE
minutesChecklist := 0.5
global msChecklist := minutesChecklist * 60000

;SET THE AMOUNT OF SECONDS OF PRIOR KEYBOARD ACTIVITY YOU WANT THE SCRIPT TO USE TO STOP ITSELF FROM FIRING
secondsIdle := 0.5
global idle := secondsIdle * 1000

;SET THE AMOUNT OF SECONDS YOU WANT THE SCRIPT TO WAIT BEFORE RETRYING TO SAVE AFTER THE ABOVE IDLE ACTIVITY STOP OCCURS
secondsRetry := 2.5
global retry := secondsRetry * 1000


;DETERMINES WHETHER YOU WANT THE SCRIPT TO SHOW TOOLTIPS AS IT APPROACHES A SAVE ATTEMPT
tools := IniRead(ptf["settings"], "Settings", "tooltip") ;This value can be adjusted at any time by right clicking the tray icon for this script
;is the timer running?
timer := false

A_TrayMenu.Insert("9&", "Tooltip Countdown", tooltipCount)
if tools = "true"
    A_TrayMenu.Check("Tooltip Countdown")
if tools = "false"
    A_TrayMenu.Uncheck("Tooltip Countdown")
tooltipCount(*)
{
    if tools = "true"
        {
            IniWrite("false", ptf["settings"], "Settings", "tooltip")
            A_TrayMenu.Uncheck("Tooltip Countdown")
            reload
        }
    if tools = "false"
        {
            IniWrite("true", ptf["settings"], "Settings", "tooltip")
            A_TrayMenu.Check("Tooltip Countdown")
            reload
        }
}


;timer for tray function
global StartTickCount := "" ;that is required to start blank or the time will continue to increment while the timer is paused
global ElapsedTime := 0
forTray := "Timer not currently tracking"


StopWatch() {
    timer := true
    if ((A_TickCount - StartTickCount) >= 1000) ;how we determine once more than 1s has passed
        {
            global StartTickCount += 1000
            global ElapsedTime += 1
        }
    if tools = "true"
        {
            x := Round((minutes * 60) - ElapsedTime)/ 60
            if x < 4 && x > 3.98
                tool.Cust("4min until a save attempt", 50)
            if x < 3 && x > 2.98
                tool.Cust("3min until a save attempt", 50)
            if x < 2 && x > 1.98
                tool.Cust("2min until a save attempt", 50)
            if x < 1 && x > 0.98
                tool.Cust("1min until a save attempt", 50)
        }
}

;This next code starts the script

start:
if WinExist(editors.Premiere.winTitle) || WinExist(editors.AE.winTitle)
    {
        SetTimer(save, -ms)
        global StartTickCount := A_TickCount ;for tray function
        SetTimer(StopWatch, 10) ;for tray function
        timer := true
        SetTimer(check, -msChecklist) ;if you do not wish to use the checklist script, simply comment out this timer
    }
else
    {
        sleep 2500
        goto start
    }

/**
 * This function is for the above SetTimer & is to check to make sure either of the editors are open & if the checklist is open
 */
check() {
    if !WinExist(editors.Premiere.winTitle) && !WinExist(editors.AE.winTitle) ;this is here so the script won't error out if you close Premiere while it is waiting
        {
            SetTimer(StopWatch, 0) ;for tray function
            timer := false
            SetTimer(, -msChecklist)
            goto end3
        }
    detect()
    if WinExist("Editing Checklist -")
        {
            SetTimer(, -msChecklist)
            goto end3
        }
    if WinExist("Wait or Continue?")
        WinWaitClose("Wait or Continue?")
    sleep 1000
    if WinExist("waitUntil.ahk")
        {
            SetTimer(, -msChecklist)
            goto end3
        }
    if !WinExist("Select commission folder")
        Run(ptf["checklist"])
    else
        WinWaitClose("Select commission folder")
    tool.Wait()
    if !WinExist("Editing Checklist -")
        tool.Cust("Don't forget to start the checklist for this project!", 2000)
    SetTimer(, -msChecklist) ;I don't want this to continue checking every minute once it's open so I'm using the larger timer here.
    end3:
}

/**
 * This function is for the above SetTimer & is the entire saving function
 */
save()
{
    if !WinExist(editors.Premiere.winTitle) && !WinExist(editors.AE.winTitle) ;this is here so the script won't error out if you close Premiere while it is waiting
        reload
    SetTimer(StopWatch, 0) ;this stops the timer from counting while the save function is occuring and proceeding into negative numbers
    timer := false

    stop := ""
    ToolTip("Your project is being saved!`nHold tight!`nThis function will timeout after 3s if it gets stuck")

    ;\\ first we grab information on the active window
    static origWind := unset
    if !IsSet(origWind)
        {
            try{
                getID(&id)
                origWind := id
            } catch as e {
                block.Off()
                tool.Cust("A variable wasn't assigned a value")
                errorLog(e, A_ThisFunc "()")
                origWind := unset
                SetTimer(, -ms)
                goto end2
            }
        }
    ;\\ Then we grab the titles of both premiere and after effects so we can make sure to only fire parts of this script if a save is required
    getPremName(&premCheck, &titleCheck, &saveCheck)
    getAEName(&aeCheck, &aeSaveCheck)

    if !IsSet(origWind) || !IsSet(titleCheck) ;then we check to make sure all of those variables were assigned values
        {
            block.Off()
            tool.Cust("A variable wasn't assigned a value")
            errorLog(, A_ThisFunc "()", "A variable wasn't assigned a value", A_LineFile, A_LineNumber)
            origWind := unset
            SetTimer(, -ms)
            goto end2
        }
    if WinExist(editors.Premiere.winTitle)
        {
            if !titleCheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
                {
                    block.Off()
                    ;MsgBox("1") ;testing
                    tool.Cust("You're currently doing something`nautosave has be cancelled", 2000)
                    goto end
                }
        }
    if origWind = "Adobe Premiere Pro.exe" ;this check is a final check to ensure the user doesn't have a menu window (or something similar) open that the first title check didn't grab (because we get the title of premiere in general and not the current active window)
        {
            premWinCheck := WinGetTitle("A")
            premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            if WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro.exe")
                {
                    block.Off()
                    tool.Cust("A window is currently open that may alter the saving process")
                    errorLog(, A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                    SetTimer(, -ms)
                    goto end
                }
            if premWinCheck = ""
                {
                    switchTo.Premiere()
                    premWinCheck := WinGetTitle("A")
                    premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
                }
            if !premTitleCheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
                {
                    block.Off()
                    ;MsgBox("2") ;testing
                    tool.Cust("You're currently doing something`nautosave has be cancelled", 2000)
                    goto end
                }
        }
    if saveCheck != "*" ;will check to see if saving is necessary
        {
            if aeSaveCheck = "*" ;this variable will contain "*" if a save is required
                {
                    if WinExist("ahk_class #32770 ahk_exe AfterFX.exe")
                        {
                            block.Off()
                            tool.Cust("A window is currently open that may alter the saving process")
                            errorLog(, A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                            SetTimer(, -ms)
                            goto end
                        }
                    if A_TimeIdleKeyboard <= idle
                        {
                            tool.Cust(A_ScriptName " tried to save but you interacted with the keyboard in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", 3000)
                            SetTimer(, -retry)
                            goto end2
                        }
                    block.On()
                    WinActivate(editors.AE.winTitle)
                    sleep 500
                    SendInput("^s")
                    sleep 250
                    WinWaitClose("Save Project",, 3)
                    goto end
                }
            block.Off()
            tool.Cust("No save necessary", 2000)
            try {
                if origWind = "ahk_class CabinetWClass"
                    WinActivate("ahk_class CabinetWClass")
                else if origWind = "Adobe Premiere Pro.exe"
                    switchTo.Premiere()
                else
                    WinActivate("ahk_exe " origWind)
            } catch as e {
                tool.Cust("couldn't activate original window")
                errorLog(e, A_ThisFunc "()")
            }
            origWind := unset
            SetTimer(, -ms)
            goto end2
        }

    if origWind != "Adobe Premiere Pro.exe" ;will activate premiere if it wasn't the original window
        WinActivate(editors.Premiere.winTitle)
    try {
        premWinCheck := WinGetTitle("A")
        premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
        if WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro.exe")
            {
                block.Off()
                tool.Cust("A window is currently open that may alter the saving process")
                errorLog(, A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                SetTimer(, -ms)
                goto end
            }
        if premWinCheck = ""
            {
                switchTo.Premiere()
                premWinCheck := WinGetTitle("A")
                premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            }
        if !premTitleCheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
            {
                block.Off()
                ;MsgBox("3") ;testing
                tool.Cust("You're currently doing something`nautosave has be cancelled", 2000)
                try {
                    if origWind = "ahk_class CabinetWClass"
                        WinActivate("ahk_class CabinetWClass")
                    else if origWind = "Adobe Premiere Pro.exe"
                        switchTo.Premiere()
                    else
                        WinActivate("ahk_exe " origWind)
                } catch as e {
                    tool.Cust("couldn't activate original window")
                    errorLog(e, A_ThisFunc "()")
                }
                origWind := unset
                SetTimer(, -ms)
                goto end2
            }
        if ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Premiere "stop.png") ;if you don't have your project monitor on your main computer monitor, you can try using the code above and swapping out x1/2 & y1/2 with the respective properties, ClassNN values are just an absolute pain in the neck and sometimes just choose to break for absolutely no reason - I just got over relying on them for this script. My project window is on the right side of my screen (which is why the first x value is A_ScreenWidth/2 - if yours is on the left you can simply switch these two values
            {
                tool.Cust("If you were playing back anything, this function should resume it")
                stop := "yes"
            }
        else
            stop := "no"
    } catch as er {
        SendInput("^s") ;attempt a save just in case
        block.Off() ;then bail
        tool.Cust("failed to find play/stop button")
        errorLog(er, A_ThisFunc "()")
        origWind := unset
        SetTimer(, -ms)
        goto end2
    }

    if A_TimeIdleKeyboard <= idle
        {
            SetTimer(, -retry)
            tool.Cust(A_ScriptName " tried to save but you interacted with the keyboard in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", 3000)
            goto end2
        }

    ;\\ Now we begin
    block.On()

    ;\\ before finally saving
    SendInput("^s")
    WinWait("Save Project",, 3)
    WinWaitClose("Save Project",, 3)

    ;\\ if ae is open we'll check to see if it needs saving, then save it too if required
    if aeSaveCheck = "*"
        {
            WinActivate(editors.AE.winTitle)
            sleep 500
            SendInput("^s")
            sleep 250
            WinWaitClose("Save Project",, 3)
        }

    ;\\ if the originally active window isn't premiere, we don't want to refocus it so we'll jump straight to the end
    if origWind != "Adobe Premiere Pro.exe"
        goto end

    ;\\ if the orginally active window IS premiere, we now refocus premiere
    try {
        sleep 250
        switchTo.Premiere()
    } catch as e {
        tool.Cust("couldn't activate Premiere Pro")
        errorLog(e, A_ThisFunc "()")
    }

    ;\\ if a video was playing, we now start it up again
    if stop = "yes"
        {
            sleep 250
            SendInput(timelineWindow)
            SendInput(timelineWindow)
            sleep 100
            SendInput("{Space}")
            block.Off()
            ToolTip("")
            SendInput(timelineWindow)
            origWind := unset
            SetTimer(, -ms) ;reset the timer
            goto end2
        }

    end:
    try { ;this is to restore the original active window
        if origWind = "ahk_class CabinetWClass"
            WinActivate("ahk_class CabinetWClass")
        else if origWind = "Adobe Premiere Pro.exe"
            switchTo.Premiere()
        else
            WinActivate("ahk_exe " origWind)
    } catch as e {
        tool.Cust("couldn't activate original window")
        errorLog(e, A_ThisFunc "()")
    }
    ToolTip("")
    origWind := unset
    block.Off()
    SetTimer(, -ms) ;reset the timer
    end2:
    tool.Wait()
    global ElapsedTime := 0
    SetTimer(StopWatch, 10)
}


/**
 * This function will grab the release version from the `My Scripts.ahk` file itself. This function makes it so I don't have to change this variable manually every release
 */
getVer()
{
    loop files A_ScriptDir "\*.ahk", "R" ;this loop searches the current script directory for the `My Scripts.ahk` script
        {
            if A_LoopFileName = "My Scripts.ahk"
                {
                    myScriptDir := A_LoopFileFullPath
                    break
                }
            else
                continue
        }
    try {
        releaseString := FileRead(myScriptDir) ;then we're putting the script into memory
    } catch as e {
        return
    } ;then the below block is doing some string manipulation to grab the release version from it
    foundpos := InStr(releaseString, 'v',,,2)
    endpos := InStr(releaseString, '"', , foundpos, 1)
    end := endpos - foundpos
    version := SubStr(releaseString, foundpos, end)
    return version ;before returning the version back to the function
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || "Close" || "Reload" || "Error"
        {
            SetTimer(check, 0)
            SetTimer(StopWatch, 0)
            SetTimer(save, 0)
        }
}