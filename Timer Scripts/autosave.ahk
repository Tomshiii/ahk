#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0
ListLines(0)
KeyHistory(0)

; { \\ #Includes
#Include <Classes\Settings>
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\switchTo>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\winget>
#Include <Classes\switchTo>
#Include <Functions\detect>
#Include <Functions\errorLog>
; }

TraySetIcon(ptf.Icons "\save.ico") ;changes the icon this script uses in the taskbar
InstallKeybdHook() ;required so A_TimeIdleKeyboard works and doesn't default back to A_TimeIdle
#WinActivateForce

;! right clicking on the tray icon for this script will offer you a button to show you how much time is remaining until the next save attempt
A_TrayMenu.Insert("7&")
A_TrayMenu.Insert("8&", "Time Remaining", timeRemain)
timeRemain(*)
{
    if timer = false
        forTray := "Timer not currently tracking"
    else
        forTray := half ? "Will retry in: " Round((((minutes * 60)/2) - ElapsedTime)/ 60, 2) "min" : "Will save in: " Round(((minutes * 60) - ElapsedTime)/ 60, 2) "min"
    MsgBox(forTray, "Next Save - " A_ScriptName)
}

;// This script will autosave your premire pro/after effects project every 5min (by default) since adobe refuses to actually do so consistently. Thanks adobe.
;// It can also ensure you have the checklist script for the current project open. This can be disabled in `settingsGUI()`

;! This file requires you to properly set the "year" value for both programs in `settings.ini` (or in settingsGUI() #F1 by default). This value is whatever year appears in the title of the respective program

;// SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT BEFORE SAVING WITHIN `settings.ini` OR BY PULLING UP THE SETTINGSGUI() WINDOW (by default #F1 or right clicking on `My Scripts.ahk`). (note: adjusting this value to be higher will not change the tooltips that appear every minute towards a save attempt)

;// if a save attempt occurs and is deemed not necessary, the following attempt will happen in 1/2 the amount of time set below. Once a save happens, the script will return to this value
minutes := UserSettings.autosave_MIN
global ms := minutes * 60000

;// SET THE AMOUNT OF MINUTES YOU WANT THIS SCRIPT TO WAIT BEFORE REMINDING YOU TO OPEN THE CHECKLIST HERE
minutesChecklist := 0.5
global msChecklist := minutesChecklist * 60000

;// SET THE AMOUNT OF SECONDS OF PRIOR KEYBOARD ACTIVITY YOU WANT THE SCRIPT TO USE TO STOP ITSELF FROM FIRING
secondsIdle := 0.5
global idle := secondsIdle * 1000

;// SET THE AMOUNT OF SECONDS YOU WANT THE SCRIPT TO WAIT BEFORE RETRYING TO SAVE AFTER THE ABOVE IDLE ACTIVITY STOP OCCURS
secondsRetry := 2.5
global retry := secondsRetry * 1000

;// DETERMINES WHETHER YOU WANT THE SCRIPT TO SHOW TOOLTIPS AS IT APPROACHES A SAVE ATTEMPT
tools := UserSettings.tooltip ;This value can be adjusted at any time by right clicking the tray icon for this script

;// setting some default values
timer := false
half := false

A_TrayMenu.Insert("9&", "Tooltip Countdown", tooltipCount)
if tools = true
    A_TrayMenu.Check("Tooltip Countdown")
tooltipCount(*)
{
    switch tools {
        case true:
            UserSettings.tooltip := false
            A_TrayMenu.Uncheck("Tooltip Countdown")
        case false:
            UserSettings.tooltip := true
            A_TrayMenu.Check("Tooltip Countdown")
        }
    reload
}

;// timer for tray function
global StartTickCount := "" ;that is required to start blank or the time will continue to increment while the timer is paused
global ElapsedTime := 0
forTray := "Timer not currently tracking"

StopWatch() {
    global timer := true
    if ((A_TickCount - StartTickCount) >= 1000) ;how we determine once more than 1s has passed
        {
            global StartTickCount += 1000
            global ElapsedTime += 1
        }
    if tools = "true"
        {
            toolFunc(min) {
                tool.Wait()
                tool.Cust(min "min until a save attempt", 2.0,,, -30, 3)
                tool.Wait()
            }
            ;// turn this into a func to do it automatically instead of hard coding values
            x := half ? Round(((minutes * 60)/2) - ElapsedTime)/60 : Round((minutes * 60) - ElapsedTime)/ 60
            if x < 4 && x > 3.98
                toolFunc(4)
            if x < 3 && x > 2.98
                toolFunc(3)
            if x < 2 && x > 1.98
                toolFunc(2)
            if x < 1 && x > 0.98
                toolFunc(1)
            if x < 0.5 && x > 0.48
                toolFunc(0.5)
        }
}

;// starting the main part of the script

start:
if WinExist(editors.Premiere.winTitle) || WinExist(editors.AE.winTitle)
    {
        SetTimer(save, -ms)
        global StartTickCount := A_TickCount ;for tray function
        SetTimer(StopWatch, 10) ;for tray function
        global timer := true
        if UserSettings.autosave_check_checklist = true
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
            global timer := false
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
    global timer := false
    global half := false

    stop := ""
    premSaveTrack := 0
    aeSaveTrack := 0
    avoid := 0

    ;// checking to see if a save is necessary
    premVal := WinExist(editors.Premiere.winTitle) ? winget.PremName(&premCheck) : {winTitle: Editors.Premiere.winTitle, titleCheck: unset, saveCheck: false}
    aeVal   := WinExist(editors.AE.winTitle)       ? winget.AEName(&aeCheck)     : {winTitle: Editors.ae.winTitle, titleCheck: unset, saveCheck: false}

    ;// if the program is not responding, we'll reset the timer and cancel the attempted save
    if InStr(premCheck ?? 0, "(Not Responding)") || InStr(aeCheck ?? 0, "(Not Responding)")
        {
            SetTimer(, -retry)
            goto theEnd
        }
    ;// if a save isn't necessary, we'll simply skip the save attempt
    if !premVal.saveCheck && !aeVal.saveCheck
        goto end

    if (A_TimeIdleKeyboard <= idle) || ((A_PriorKey = "LButton" || A_PriorKey = "RButton" || A_PriorKey = "\") && A_TimeIdleMouse <= idle) || GetKeyState("RButton", "P")
        {
            tool.Cust(A_ScriptName " tried to save but you interacted with the keyboard/mouse in the last " secondsIdle "s`nthe script will try again in " secondsRetry "s", 3000)
            SetTimer(, -retry)
            goto theEnd
        }

    block.On("SendAndMouse")
    ;// checking if keys that cause problems are currently being held down
    ;// if they are, release them
    playheadCheck := GetKeyState("\") ;//! the user may have changed this value in their KSA.ini but I don't *think* other keys cause premiere to go haywire..?
    rbutCheck     := GetKeyState("RButton", "P")
    if rbutCheck || playheadCheck
        {
            if rbutCheck
                SendInput("{RButton Up}")
            if playheadCheck
                SendInput("{\ Up}")
        }

    ;// keeping track of save attempts
    attempt := 0
    attempt:
    if attempt = 3
        {
            switchTo.Premiere() ; last ditch effort to get a save off properly
            SendInput(KSA.timelineWindow)
        }
    attempt++

    ;// first we grab information on the active window
    static origWind := unset
    if !IsSet(origWind)
        {
            try{
                winget.ID(&id)
                origWind := id
            } catch as e {
                block.Off()
                tool.Cust("A variable wasn't assigned a value")
                errorLog(e)
                origWind := unset
                SetTimer(, -ms)
                goto theEnd
            }
        }

    ;// If premiere is the active window, we're checking to see if the user is playing back footage on the timeline
    if origWind = "Adobe Premiere Pro.exe"
        {
            if ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Premiere "stop.png") ;if you don't have your project monitor on your main computer monitor, you can try using the code above and swapping out x1/2 & y1/2 with the respective classNN properties, ClassNN values are just an absolute pain in the neck and sometimes just choose to break for absolutely no reason - I just got over relying on them for this script. My project window is on the right side of my screen (which is why the first x value is A_ScreenWidth/2 - if yours is on the left you can simply switch these two values
            {
                tool.Cust("If you were playing back anything, this function should resume it", 2.0,,, 30, 2)
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
    if WinExist(editors.Premiere.winTitle) && premVal.saveCheck = true
        {
            premWinCheck := WinGetTitle(editors.Premiere.winTitle)
            premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro 20" ptf.PremYearVer " -")
            premTitleCheck2 := InStr(premVal.winTitle, "Adobe Premiere Pro 20" ptf.PremYearVer " -") ;same as above except checking a different variable (depending on whether you check the ahk_exe or the ahk_class returns different results under different circumstances)
            if WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro.exe")
                {
                    avoid := 1
                    block.Off()
                    errorLog(Error(A_ScriptName " save attempt cancelled, a window is open that may alter the saving process", -1),, 1)
                    SetTimer(, -ms)
                    goto end
                }
            ;// debugging
            ; appendCheck(checkNum, premTitleCheck, premTitleCheck2, premWinCheck, premVal.winTitle, whichNum) => FileAppend("check" checkNum "`ntitle: " premTitleCheck "`n" "title2: " premTitleCheck2 "`npremWinCheck: " premWinCheck "`nprem.winTitle: " premVal.winTitle "`nwhich: " whichNum "`n---------------`n", "test.txt")
            ; appendCheck(1, premTitleCheck, premTitleCheck2, premWinCheck, premVal.winTitle, 0)

            if premWinCheck = "" && premVal.winTitle = ""
                {
                    switchTo.Premiere()
                    premWinCheck := WinGetTitle("A")
                    premTitleCheck := InStr(premWinCheck, "Adobe Premiere Pro 20" ptf.PremYearVer " -")
                    ; appendCheck(2, premTitleCheck, premTitleCheck2, premWinCheck, premVal.winTitle, "0_2") ;// debugging
                }
            if !premTitleCheck && !premTitleCheck2 ;if you're using another window (ie rendering something, changing gain, etc) this part of the code will trip, cancelling the autosave
                {
                    avoid := 1
                    block.Off()
                    tool.Cust("You're currently doing something`nautosave has be cancelled", 2000)
                    goto end
                }

            premSave(title?, variation := "default", swap := false) {
                tool.Cust("Saving Premiere")
                switch variation {
                    case "focus":
                        if swap
                            switchTo.Premiere()
                        SendInput(KSA.timelineWindow)
                        SendInput(KSA.timelineWindow)
                        SendInput("{Ctrl Down}s{Ctrl Up}")
                        ; appendCheck("3_focus", premTitleCheck, premTitleCheck2, premWinCheck, premVal.winTitle, "premsave() swap: " swap) ;// debugging
                    default:
                        ControlSend("{Ctrl Down}{s Down}{s Up}{Ctrl Up}",, title)
                        ; appendCheck("3_bg", premTitleCheck, premTitleCheck2, premWinCheck, premVal.winTitle, "premsave() bg") ;// debugging
                }
                if WinWait("Save Project",, 2)
                    WinWaitClose("Save Project",, 2)
                premSaveTrack := 1
            }
            if premVal.saveCheck = true && origWind = "Adobe Premiere Pro.exe"
                {
                    if premWinCheck != ""
                        premSave(, "focus")
                    else if premVal.winTitle != ""
                        premSave(, "focus", 1)
                }
            else if premVal.saveCheck = true && premWinCheck != 0
                premSave(premWinCheck)
            else if premVal.saveCheck = true && premVal.winTitle != 0
                premSave(premVal.winTitle)
        }


    /**
     * This part of the script will check to see if after effects requires a save
     * If you have AE in view (but not the active window) when this function attempts to save it, you may see it disappear from view -
     * This is to avoid after effects flashing on the screen as, when you save after effects, it FORCES itself to be in focus (typical adobe nonsense)
     * So this function will first make ae transparent, save, refocus the original window, then winmovebottom AE so it doesn't force itself to the top
     */
    if WinExist(editors.AE.winTitle) && aeVal.saveCheck = true
        {
            if origWind != WinGetProcessName(editors.AE.winTitle)
                {
                    if WinExist("ahk_class #32770 ahk_exe AfterFX.exe")
                        {
                            avoid := 1
                            block.Off()
                            tool.Wait()
                            errorLog(Error(A_ScriptName " save attempt cancelled, a window is open that may alter the saving process", -1),, 1)
                            goto end
                        }
                    tool.Wait()
                    tool.Cust("Saving AE")
                    WinSetTransparent(0, editors.AE.winTitle)
                    ControlSend("{Ctrl Down}s{Ctrl Up}",, aeVal.winTitle)
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
                    aeVal.SaveTrack := 1
                    goto end
                }
            else if origWind = WinGetProcessName(aeVal.winTitle)
                {
                    if WinExist("ahk_class #32770 ahk_exe AfterFX.exe")
                        {
                            SetTimer(, -ms)
                            block.Off()
                            tool.Wait()
                            errorLog(Error(A_ScriptName " save attempt cancelled, a window is open that may alter the saving process", -1),, 1)
                            goto end
                        }
                    tool.Wait()
                    tool.Cust("Saving AE")
                    SendInput("^s")
                    WinWaitClose("Save Project",, 3)
                }
        }

        ;// double checking to see if the saves worked
        if WinExist(editors.Premiere.winTitle)
            premDouble := winget.PremName()
        if WinExist(editors.AE.winTitle)
            aeDouble := winget.AEName()
        if ((WinExist(editors.Premiere.winTitle) && premDouble.saveCheck = true) || (WinExist(editors.AE.winTitle) && aeDouble.saveCheck = true)) && attempt < 3
            goto attempt
        else if ((WinExist(editors.Premiere.winTitle) && premDouble.saveCheck = true) || (WinExist(editors.AE.winTitle) && aeDouble.saveCheck = true)) && attempt >= 3
            tool.Cust("Couldn't properly save after " attempt " attempts", 2.0)

        ;// replaying playback if necessary
        replayPlayback(title) {
            try {
                replayCheck := WinGet.PremName()
                if title != replayCheck.winTitle
                    title := replayCheck.winTitle
                sleep 250
                ControlSend(KSA.timelineWindow,, title)
                ControlSend(KSA.timelineWindow,, title)
                sleep 100
                ControlSend(KSA.playStop,, title)
                block.Off()
                ToolTip("")
                ControlSend(KSA.timelineWindow,, title)
            }
        }
        if stop = "yes" && premWinCheck != "" && premSaveTrack = 1
            replayPlayback(premWinCheck)
        else if stop = "yes" && premVal.winTitle != "" premSaveTrack = 1
            replayPlayback(premVal.winTitle)


        end:
        ;// if a save isn't necessary, the next save will happen in half the time
        if aeSaveTrack = 0 && premSaveTrack = 0 && avoid = 0
            {
                global half := true
                static origWind := unset
                tool.Wait()
                tool.Cust("No save necessary")
            }

        ;// reactivating the original window if necessary
        if !IsSet(origWind)
            goto ignore
        try {
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
            errorLog(e)
        }

        ignore:
        ;// resetting values and windows
        if WinExist(editors.AE.winTitle)
            WinSetTransparent(255, editors.AE.winTitle) ;just incase
        block.Off()
        tool.Wait()
        ToolTip("")
        origWind := unset
        if aeSaveTrack = 0 && premSaveTrack = 0 && avoid = 0
            SetTimer(, -(ms/2)) ;reset the timer
        else
            SetTimer(, -ms) ;reset the timer

        theEnd:
        if WinExist(editors.AE.winTitle)
            WinSetTransparent(255, editors.AE.winTitle) ;just incase
        block.Off()
        tool.Wait()
        global ElapsedTime := 0
        SetTimer(StopWatch, 10)
}


;// defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        {
            SetTimer(check, 0)
            SetTimer(StopWatch, 0)
            SetTimer(save, 0)
        }
}