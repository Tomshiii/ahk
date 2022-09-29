#SingleInstance force ;only one instance of this script may run at a time!
A_MaxHotkeysPerInterval := 2000
verCheck() ;checks to make sure the user is using a compatible version of ahk
TraySetIcon("..\Support Files\Icons\save.ico") ;changes the icon this script uses in the taskbar
#Include FuncRedirect.ahk
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

if !FileExist(A_MyDocuments "\tomshi\settings.ini")
    {
        sleep 5000 ;just incase this script loads before `My Scripts.ahk`
        if !FileExist(A_MyDocuments "\tomshi\settings.ini")
            {
                myrelease := getVer()
                if myrelease = ""
                    myrelease := "v2.5" ;if you're not using `My Scripts.ahk` this line will just autopopulate a number to stop errors
                FileAppend("[Settings]`nupdate check=true`ntooltip=true`n`n[Adjust]`nadobe GB=45`nadobe FS=5`nautosave MIN=5`n`n[Track]`nadobe temp=`nworking dir=" A_WorkingDir "`nfirst check=true`nversion=" MyRelease, A_MyDocuments "\tomshi\settings.ini")
            }
    }

;SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT BEFORE SAVING WITHIN `settings.ini` OR BY PULLING UP THE SETTINGSGUI() WINDOW (by default #F1 or right clicking on `My Scripts.ahk`). (note: adjusting this value to be higher will not change the tooltips that appear every minute towards a save attempt)
minutes := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "autosave MIN")
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
tooltips := IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "tooltip") ;This value can be adjusted at any time by right clicking the tray icon for this script
;is the timer running?
timer := false

A_TrayMenu.Insert("9&", "Tooltip Countdown", tooltipCount)
if tooltips = "true"
    A_TrayMenu.Check("Tooltip Countdown")
if tooltips = "false"
    A_TrayMenu.Uncheck("Tooltip Countdown")
tooltipCount(*)
{
    if tooltips = "true"
        {
            IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Settings", "tooltip")
            A_TrayMenu.Uncheck("Tooltip Countdown")
            reload
        }
    if tooltips = "false"
        {
            IniWrite("true", A_MyDocuments "\tomshi\settings.ini", "Settings", "tooltip")
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
    if tooltips = "true"
        {
            x := Round((minutes * 60) - ElapsedTime)/ 60
            if x < 4 && x > 3.98
                toolCust("4min until a save attempt", 50)
            if x < 3 && x > 2.98
                toolCust("3min until a save attempt", 50)
            if x < 2 && x > 1.98
                toolCust("2min until a save attempt", 50)
            if x < 1 && x > 0.98
                toolCust("1min until a save attempt", 50)
        }
}



;let's define some functions to grab information

/**
 * This function will grab the initial active window
 * @param id is the processname of the active window, we want to pass this value back to the script
 */
getID(&id)
{
    try {
        id := WinGetProcessName("A")
        if WinActive("ahk_exe explorer.exe")
            id := "ahk_class CabinetWClass"
    } catch as e {
        toolCust("couldn't grab active window")
        errorLog(A_ThisFunc "()", "Couldn't define the active window", A_LineFile, A_LineNumber)
    }
}

/**
 * This function will grab the title of premiere if it exists and check to see if a save is necessary
 * @param premCheck is the title of premiere, we want to pass this value back to the script
 * @param titleCheck is checking to see if the premiere window is available to save, we want to pass this value back to the script
 * @param saveCheck is checking for an * in the title to say a save is necessary, we want to pass this value back to the script
 */
getPremName(&premCheck, &titleCheck, &saveCheck)
{
    try {
        if WinExist("ahk_exe Adobe Premiere Pro.exe")
            {
                premCheck := WinGetTitle("ahk_class Premiere Pro")
                titleCheck := InStr(premCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
                saveCheck := SubStr(premCheck, -1, 1) ;this variable will contain "*" if a save is required
            }
        else
            {
                titleCheck := ""
                saveCheck := ""
            }
    } catch as e {
        blockOff()
        toolCust("Couldn't determine the titles of Adobe programs")
        errorLog(A_ThisFunc "()", "Couldn't determine the titles of Adobe programs", A_LineFile, A_LineNumber)
        return
    }
}

/**
 * This function will grab the title of after effects if it exists and check to see if a save is necessary
 * @param aeCheck is the title of after effects, we want to pass this value back to the script
 * @param aeSaveCheck is checking for an * in the title to say a save is necessary, we want to pass this value back to the script
 */
getAEName(&aeCheck, &aeSaveCheck)
{
    try {
        if WinExist("ahk_exe AfterFX.exe")
            {
                aeCheck := WinGetTitle("ahk_exe AfterFX.exe")
                aeSaveCheck := SubStr(aeCheck, -1, 1) ;this variable will contain "*" if a save is required
            }
        else
            aeSaveCheck := ""
    } catch as e {
        blockOff()
        toolCust("Couldn't determine the titles of Adobe programs")
        errorLog(A_ThisFunc "()", "Couldn't determine the titles of Adobe programs", A_LineFile, A_LineNumber)
        return
    }
}

;This next code starts the script

start:
if WinExist("ahk_exe Adobe Premiere Pro.exe") || WinExist("ahk_exe AfterFX.exe")
    {
        SetTimer(save, -ms)
        global StartTickCount := A_TickCount ;for tray function
        SetTimer(StopWatch, 10) ;for tray function
        timer := true
        SetTimer(check, -msChecklist) ;if you do not wish to use the checklist script, simply comment out this timer
    }
else
    {
        WinWait("ahk_exe Adobe Premiere Pro.exe") || WinWait("ahk_exe AfterFX.exe")
        goto start
    }

/**
 * This function is for the above SetTimer & is to check to make sure either of the editors are open & if the checklist is open
 */
check() {
    if !WinExist("ahk_exe Adobe Premiere Pro.exe") && !WinExist("ahk_exe AfterFX.exe") ;this is here so the script won't error out if you close Premiere while it is waiting
        {
            SetTimer(, -msChecklist)
            SetTimer(StopWatch, 0) ;for tray function
            timer := false
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
        toolCust("Don't forget to start the checklist for this project!", 2000)
    SetTimer(, -msChecklist) ;I don't want this to continue checking every minute once it's open so I'm using the larger timer here.
    end3:
}

/**
 * This function is for the above SetTimer & is the entire saving function
 */
save()
{
    if !WinExist("ahk_exe Adobe Premiere Pro.exe") && !WinExist("ahk_exe AfterFX.exe") ;this is here so the script won't error out if you close Premiere while it is waiting
        reload
    SetTimer(StopWatch, 0) ;this stops the timer from counting while the save function is occuring and proceeding into negative numbers
    timer := false

    stop := ""
    ToolTip("Your project is being saved!`nHold tight!`nThis function will timeout after 3s if it gets stuck")

    ;\\ first we grab information on the active window
    getID(&id)

    ;\\ Then we grab the titles of both premiere and after effects so we can make sure to only fire parts of this script if a save is required
    getPremName(&premCheck, &titleCheck, &saveCheck)
    getAEName(&aeCheck, &aeSaveCheck)

    if !IsSet(id) || !IsSet(titleCheck) ;then we check to make sure all of those variables were assigned values
        {
            blockOff()
            toolCust("A variable wasn't assigned a value")
            errorLog(A_ThisFunc "()", "A variable wasn't assigned a value", A_LineFile, A_LineNumber)
            SetTimer(, -ms)
            goto end2
        }
    if WinExist("ahk_exe Adobe Premiere Pro.exe")
        {
            if not titleCheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
                {
                    blockOff()
                    ;MsgBox("1") ;testing
                    toolCust("You're currently doing something`nautosave has be cancelled", 2000)
                    SetTimer(, -ms)
                    goto end2
                }
        }
    if id = "Adobe Premiere Pro.exe" ;this check is a final check to ensure the user doesn't have a menu window (or something similar) open that the first title check didn't grab (because we get the title of premiere in general and not the current active window)
        {
            premWinCheck := WinGetTitle("A")
            premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            if WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro.exe")
                {
                    blockOff()
                    toolCust("A window is currently open that may alter the saving process")
                    errorLog(A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                    SetTimer(, -ms)
                    goto end
                }
            if premWinCheck = ""
                {
                    switchToPremiere()
                    premWinCheck := WinGetTitle("A")
                    premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
                }
            if not premTitleCheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
                {
                    blockOff()
                    ;MsgBox("2") ;testing
                    toolCust("You're currently doing something`nautosave has be cancelled", 2000)
                    SetTimer(, -ms)
                    goto end2
                }
        }
    if saveCheck != "*" ;will check to see if saving is necessary
        {
            if aeSaveCheck = "*" ;this variable will contain "*" if a save is required
                {
                    if WinExist("ahk_class #32770 ahk_exe AfterFX.exe")
                        {
                            blockOff()
                            toolCust("A window is currently open that may alter the saving process")
                            errorLog(A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                            SetTimer(, -ms)
                            goto end
                        }
                    if A_TimeIdleKeyboard <= idle
                        {
                            SetTimer(, -retry)
                            toolCust(A_ScriptName " tried to save but you interacted with the keyboard in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", 3000)
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
            toolCust("No save necessary", 2000)
            try {
                if id = "ahk_class CabinetWClass"
                    WinActivate("ahk_class CabinetWClass")
                else if id = "Adobe Premiere Pro.exe"
                    switchToPremiere()
                else
                    WinActivate("ahk_exe " id)
            } catch as e {
                toolCust("couldn't activate original window")
                errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
            }
            SetTimer(, -ms)
            goto end2
        }

    if id != "Adobe Premiere Pro.exe" ;will activate premiere if it wasn't the original window
        WinActivate("ahk_exe Adobe Premiere Pro.exe")
    try {
        premWinCheck := WinGetTitle("A")
        premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
        if WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro.exe")
            {
                blockOff()
                toolCust("A window is currently open that may alter the saving process")
                errorLog(A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                SetTimer(, -ms)
                goto end
            }
        if premWinCheck = ""
            {
                switchToPremiere()
                premWinCheck := WinGetTitle("A")
                premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            }
        if not premTitleCheck ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
            {
                blockOff()
                ;MsgBox("3") ;testing
                toolCust("You're currently doing something`nautosave has be cancelled", 2000)
                try {
                    if id = "ahk_class CabinetWClass"
                        WinActivate("ahk_class CabinetWClass")
                    else if id = "Adobe Premiere Pro.exe"
                        switchToPremiere()
                    else
                        WinActivate("ahk_exe " id)
                } catch as e {
                    toolCust("couldn't activate original window")
                    errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
                }
                SetTimer(, -ms)
                goto end2
            }
        if ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Premiere "stop.png") ;if you don't have your project monitor on your main computer monitor, you can try using the code above and swapping out x1/2 & y1/2 with the respective properties, ClassNN values are just an absolute pain in the neck and sometimes just choose to break for absolutely no reason - I just got over relying on them for this script. My project window is on the right side of my screen (which is why the first x value is A_ScreenWidth/2 - if yours is on the left you can simply switch these two values
            {
                toolCust("If you were playing back anything, this function should resume it")
                stop := "yes"
            }
        else
            stop := "no"
    } catch as er {
        SendInput("^s") ;attempt a save just in case
        blockOff() ;then bail
        toolCust("failed to find play/stop button")
        errorLog(A_ThisFunc "()", "Couldn't find the play/stop button", A_LineFile, A_LineNumber)
        return
    }

    if A_TimeIdleKeyboard <= idle
        {
            SetTimer(, -retry)
            toolCust(A_ScriptName " tried to save but you interacted with the keyboard in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", 3000)
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
        switchToPremiere()
    } catch as e {
        toolCust("couldn't activate Premiere Pro")
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
    try { ;this is to restore the original active window
        if id = "ahk_class CabinetWClass"
            WinActivate("ahk_class CabinetWClass")
        else if id = "Adobe Premiere Pro.exe"
            switchToPremiere()
        else
            WinActivate("ahk_exe " id)
    } catch as e {
        toolCust("couldn't activate original window")
        errorLog(A_ThisFunc "()", "Couldn't activate the original active window", A_LineFile, A_LineNumber)
    }
    ToolTip("")
    blockOff()
    SetTimer(, -ms) ;reset the timer
    end2:
    if WinExist("ahk_class tooltips_class32") ;checking to see if any tooltips are active
		WinWaitClose("ahk_class tooltips_class32",, 2)
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