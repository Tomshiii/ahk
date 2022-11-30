#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0-beta.12

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\switchTo>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\winget>
#Include <Classes\switchTo>
#Include <Functions\detect>
#Include <Functions\errorLog>
#Include <Classes\Startup>
; }

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
            toolFunc(min) {
                tool.Wait()
                tool.Cust(min "min until a save attempt", 2.0)
                tool.Wait()
            }
            x := Round((minutes * 60) - ElapsedTime)/ 60
            if x < 4 && x > 3.98
                toolFunc(4)
            if x < 3 && x > 2.98
                toolFunc(3)
            if x < 2 && x > 1.98
                toolFunc(2)
            if x < 1 && x > 0.98
                toolFunc(1)
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
    premSaveTrack := 0
    aeSaveTrack := 0
    avoid := 0
    saveCheck := ""
    aeSaveCheck := ""

    ;checking to see if a save is necessary
    if WinExist(editors.Premiere.winTitle)
        winget.PremName(&premCheck, &titleCheck, &saveCheck)
    if WinExist(editors.AE.winTitle)
        winget.AEName(&aeCheck, &aeSaveCheck)
    if saveCheck != "*" && aeSaveCheck != "*"
        {
            tool.Cust("No save necessary")
            goto ignore
        }

    if A_TimeIdleKeyboard <= idle
        {
            tool.Cust(A_ScriptName " tried to save but you interacted with the keyboard in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", 3000)
            SetTimer(, -retry)
            goto theEnd
        }

    block.On()

    ;\\ first we grab information on the active window
    static origWind := unset
    if !IsSet(origWind)
        {
            try{
                winget.ID(&id)
                origWind := id
            } catch as e {
                block.Off()
                tool.Cust("A variable wasn't assigned a value")
                errorLog(e, A_ThisFunc "()")
                origWind := unset
                SetTimer(, -ms)
                goto theEnd
            }
        }

    ;\\ If premiere is the active window, we're checking to see if the user is playing back footage on the timeline
    if origWind = "Adobe Premiere Pro.exe"
        {
            if ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Premiere "stop.png") ;if you don't have your project monitor on your main computer monitor, you can try using the code above and swapping out x1/2 & y1/2 with the respective properties, ClassNN values are just an absolute pain in the neck and sometimes just choose to break for absolutely no reason - I just got over relying on them for this script. My project window is on the right side of my screen (which is why the first x value is A_ScreenWidth/2 - if yours is on the left you can simply switch these two values
            {
                tool.Cust("If you were playing back anything, this function should resume it")
                stop := "yes"
            }
        else
            stop := "no"
    }

    /**
     * This part of the script will check to see if Premiere requires a save
     * If it does and isn't the active window, it will controlsend ^s
     * otherwise it will sendinput ^s (as using controlsend while active seems to not function properly)
     */
    if WinExist(editors.Premiere.winTitle) && saveCheck = "*"
        {
            premWinCheck := WinGetTitle(editors.Premiere.winTitle)
            premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            premTitleCheck2 := InStr(premCheck, "Adobe Premiere Pro " ptf.PremYear " -") ;same as above except checking a different variable (depending on whether you check the ahk_exe or the ahk_class returns different results under different circumstances)
            if WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro.exe")
                {
                    avoid := 1
                    block.Off()
                    tool.Cust("A window is currently open that may alter the saving process")
                    errorLog(, A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                    SetTimer(, -ms)
                    goto end
                }
            if premWinCheck = "" && premCheck = ""
                {
                    switchTo.Premiere()
                    premWinCheck := WinGetTitle("A")
                    premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
                }
            if !premTitleCheck && !premTitleCheck2 ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
                {
                    avoid := 1
                    block.Off()
                    tool.Cust("You're currently doing something`nautosave has be cancelled", 2000)
                    goto end
                }

            premSave(title) {
                tool.Cust("Saving Premiere")
                ControlSend("{Ctrl Down}s{Ctrl Up}",, title)
                premSaveTrack := 1
            }
            if saveCheck = "*" && origWind = "Adobe Premiere Pro.exe"
                {
                    tool.Cust("Saving Premiere")
                    SendInput("{Ctrl Down}s{Ctrl Up}")
                    premSaveTrack := 1
                }
            else if saveCheck = "*" && premWinCheck != ""
                premSave(premWinCheck)
            else if saveCheck = "*" && premCheck != ""
                premSave(premCheck)
        }


    /**
     * This part of the script will check to see if after effects requires a save
     * If you have AE in view (but not the active window) when this function attempts to save it, you may see it disappear from view -
     * This is to avoid after effects flashing on the screen as, when you save after effects, it FORCES itself to be in focus (typical adobe nonsense)
     * So this function will first make ae transparent, save, refocus the original window, then winmovebottom AE so it doesn't force itself to the top
     */
    if WinExist(editors.AE.winTitle) && aeSaveCheck = "*"
        {
            if aeSaveCheck = "*" && origWind != WinGetProcessName(aeCheck) ;this variable will contain "*" if a save is required
                {
                    if WinExist("ahk_class #32770 ahk_exe AfterFX.exe")
                        {
                            avoid := 1
                            block.Off()
                            tool.Cust("A window is currently open that may alter the saving process")
                            errorLog(, A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                            goto end
                        }
                    tool.Cust("Saving AE")
                    WinSetTransparent(0, editors.AE.winTitle)
                    ControlSend("{Ctrl Down}s{Ctrl Up}",, aeCheck)
                    WinWaitClose("Save Project",, 3)
                    try {
                        if origWind = "ahk_class CabinetWClass"
                            WinActivate("ahk_class CabinetWClass")
                        else if origWind = "Adobe Premiere Pro.exe"
                            switchTo.Premiere()
                        else
                            WinActivate("ahk_exe " origWind)
                    }
                    WinMoveBottom(editors.AE.winTitle)
                    WinSetTransparent(255, editors.AE.winTitle)
                    aeSaveTrack := 1
                    goto end
                }
            else if aeSaveCheck= "*" && origWind = WinGetProcessName(aeCheck) ;this variable will contain "*" if a save is required
                {
                    if WinExist("ahk_class #32770 ahk_exe AfterFX.exe")
                        {
                            SetTimer(, -ms)
                            block.Off()
                            tool.Cust("A window is currently open that may alter the saving process")
                            errorLog(, A_ThisFunc "()", "A window is currently open that may alter the saving process", A_LineFile, A_LineNumber)
                            goto end
                        }
                    tool.Cust("Saving AE")
                    SendInput("^s")
                    WinWaitClose("Save Project",, 3)
                }
        }


        replayPlayback(title) {
            sleep 250
            ControlSend(timelineWindow,, title)
            ControlSend(timelineWindow,, title)
            sleep 100
            ControlSend(playStop,, title)
            block.Off()
            ToolTip("")
            ControlSend(timelineWindow,, title)
        }
        if stop = "yes" && premWinCheck != "" && premSaveTrack = 1
            replayPlayback(premWinCheck)
        else if stop = "yes" && premCheck != "" premSaveTrack = 1
            replayPlayback(premCheck)


        end:
        tool.Wait()
        if aeSaveTrack = 0 && premSaveTrack = 0 && avoid = 0
            tool.Cust("No save necessary")
        if !IsSet(origWind)
            goto ignore
        try { ;this is to restore the original active window
            winget.ID(&newid)
            checkWin := newid
            if origWind = newid
                goto ignore
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
        ignore:
        if WinExist(editors.AE.winTitle)
            WinSetTransparent(255, editors.AE.winTitle) ;just incase
        block.Off()
        tool.Wait()
        ToolTip("")
        origWind := unset
        SetTimer(, -ms) ;reset the timer

        theEnd:
        if WinExist(editors.AE.winTitle)
            WinSetTransparent(255, editors.AE.winTitle) ;just incase
        block.Off()
        tool.Wait()
        global ElapsedTime := 0
        SetTimer(StopWatch, 10)
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