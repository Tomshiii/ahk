/**
 * This function handles what happens when the start button is pressed
 */
start(*) {
    startButton.Move(,, 0, 0) ;hiding the start button
    stopButton.Move(,, 50, 30) ;showing the stop button
    timerText.SetFont("cGreen") ;changing the colours
    timerMinutes.SetFont("cGreen")
    timerSeconds.SetFont("cGreen")
    forFile := Round(ElapsedTime / 3600, 3)
    newDate(&today)
    FileAppend("\\ The timer was started : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Starting Hours = " forFile " -- seconds at start = " ElapsedTime "`n", logs)
    global StartTickCount := A_TickCount ;This allows us to use your computer to determine how much time has past by doing some simple math below
    SetTimer(StopWatch, 10) ;start the timer and loop it as often as possible
    SetTimer(logElapse, -ms10)
    SetTimer(reminder, 0)
}

/**
 * This is the main stopwatch timer itself and is what handles all of the counting and updating the text
 */
StopWatch() {
    if WinExist("Editing Checklist") ;this check is to stop the timer from running once you close the GUI
        {
            if ((A_TickCount - StartTickCount) >= 1000) ;how we determine once more than 1s has passed
                {
                    global StartTickCount += 1000
                    global ElapsedTime += 1
                    displayHours := floorDecimal(ElapsedTime/3600, 3)
                    timerText.Text := displayHours
                    displayMinutes := Floor(((ElapsedTime/3600) - floor(ElapsedTime/3600))*60)
                    timerMinutes.Text := displayMinutes
                    minforSec := Floor(ElapsedTime/60)
                    displaySeconds := Round((((ElapsedTime/60) - minforSec) * 60), 0)
                    timerSeconds.Text := displaySeconds
                }
        }
    else
        SetTimer(StopWatch, 0)
}

/**
 * This function handles what happens when the stop button is pressed
 */
stop(*) {
    if !IsSet(ElapsedTime)
        {
            if !WinExist("Editing Checklist - ")
                Run(A_ScriptFullPath)
            else
                ExitApp()
        }
    forFile := Round(ElapsedTime / 3600, 3)
    checkHours := IniRead(checklist, "Info", "time")
    if ElapsedTime != checkHours
        IniWrite(ElapsedTime, checklist, "Info", "time") ;once the timer is stopped it will write the elapsed time to the ini file
    newDate(&today)
    FileAppend("\\ The timer was stopped : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Stopping Hours = " forFile " -- seconds at stop = " ElapsedTime "`n", logs)
    SetTimer(StopWatch, 0) ;then stop the timer
    startButton.Move(,, 50, 30) ;then show the start button
    stopButton.Move(,, 0, 0) ;and hide the stop button
    timerText.SetFont("cRed") ;and return the colour to red
    timerMinutes.SetFont("cRed")
    timerSeconds.SetFont("cRed")
    SetTimer(logElapse, 0)
    SetTimer(reminder, -ms)
    global startValue := IniRead(checklist, "Info", "time") ;then update startvalue so it will start from the new elapsed time instead of the original
}

/**
 * This function is to reduce copy/paste code in some .OnEvent return functions
 * @param {any} sign is if it's the minus key or plus key
 */
minusOrAdd(sign)
{
    forFile := Round(ElapsedTime / 3600, 3)
    word := ""
    IniWrite(ElapsedTime, checklist, "Info", "time")
    global initialRead := IniRead(checklist, "Info", "time")
    if sign = "-"
        {
            word := "removed"
            funcMinutes := ((List.Text * 60) + 1)
            newValue := initialRead - funcMinutes
        }
    else
        {
            word := "added"
            funcMinutes := ((List.Text * 60) - 1)
            newValue := initialRead + funcMinutes
        }
    if newValue < 0
        newValue := 0
    change := IniWrite(newValue, checklist, "Info", "time")
    SetTimer(StopWatch, -1000)
    timerText.SetFont("cRed")
    timerMinutes.SetFont("cRed")
    timerSeconds.SetFont("cRed")
    startButton.Move(,, 50, 30)
    stopButton.Move(,, 0, 0)
    SetTimer(logElapse, 0)
    SetTimer(reminder, -ms)
    global startValue := IniRead(checklist, "Info", "time")
    global ElapsedTime := 0 + startValue
    global StartTickCount := A_TickCount
    newDate(&today)
    FileAppend("\\ The timer was stopped and " List.Text "min " word " : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after stopping = " forFile " -- seconds after stopping = " ElapsedTime "`n", logs)
}
minusFive(*) {
    minusOrAdd("-")
}
plusFive(*) {
    minusOrAdd("+")
}

/**
 * Reminds the user that they have the timer stopped
 */
reminder()
{
    if WinExist("ahk_exe Adobe Premiere Pro.exe")
        {
            switch settingsToolTrack {
                case 1:
                    tool.Cust("Don't forget you have the timer stopped!", "2000")
                    SetTimer(, -ms)
                case 0:
                    SetTimer(, 0)
            }
        }
    else
        SetTimer(, 0)
}

/**
 * Changes the button names of a generated msgbox
 */
change_msgButton()
{
    if !WinExist("Wait or Continue?")
        return  ; Keep waiting.
    SetTimer(, 0)
    WinActivate("Wait or Continue?")
    ControlSetText("&Wait", "Button1")
    ControlSetText("&Select Now", "Button2")
}

/**
 * This function handles the logic for what happens if `autosave.ahk` attempts to open `checklist.ahk` before they've opened a project and the user selects "wait" in the msgbox
 */
waitUntil()
{
    if !WinExist("Adobe Premiere Pro") && !WinExist("ahk_exe AfterFX.exe")
        {
            pauseautosave()
            ScriptSuspend("autosave.ahk", false)
            SetTimer(, 0)
            return
        }
    dashLocationAgain := unset
    aeLocationAgain := unset
    if WinExist("Adobe Premiere Pro")
        {
            getPremName(&Namepremdash, &titlecheck, &savecheck) ;first we grab some information about the premiere pro window
            if !IsSet(titlecheck) ;we ensure the title variable has been assigned before proceeding forward
                {
                    block.Off()
                    tool.Cust("``titlecheck`` variable wasn't assigned a value")
                    errorLog(A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                    SetTimer(, -1000)
                }
            dashLocationAgain := InStr(Namepremdash, "-")
            if dashLocationAgain = 0
                dashLocationAgain := unset
        }
    else if WinExist("ahk_exe AfterFX.exe")
        {
            aeCheckagain := WinGetTitle("ahk_exe AfterFX.exe")
            if !IsSet(aeCheckagain) ;we ensure the title variable has been assigned before proceeding forward
                {
                    block.Off()
                    tool.Cust("``aeCheckagain`` variable wasn't assigned a value")
                    errorLog(A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                    SetTimer(, -1000)
                }
            if !InStr(aeCheckagain, ":`\")
                {
                    try {
                        aeCheckagain := WinGetTitle("Adobe After Effects")
                    }
                    if !InStr(aeCheckagain, ":`\")
                        aeLocationAgain := unset
                    else
                        aeLocationAgain := InStr(aeCheckagain, ":`\")
                }
        }
    if !IsSet(dashLocationAgain) && !IsSet(aeLocationAgain)
        {
            SetTimer(, -1000)
            return
        }
    Run(A_ScriptFullPath)
    pauseautosave()
    ScriptSuspend("autosave.ahk", false)
    SetTimer(, 0)
}