/**
 * This function contains the logic on what to do when the checklist is closed
 */
close(*) {
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
        IniWrite(ElapsedTime, checklist, "Info", "time")
    newDate(&today)

    if ElapsedTime = checkHours
        FileAppend("\\ The checklist was closed : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec "`n", logs)
    else
        FileAppend("\\ The checklist was closed : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after closing = " forFile " -- seconds at close = " ElapsedTime "`n", logs)
    SetTimer(StopWatch, 0)
    SetTimer(reminder, 0)
    if logElapse = true
        SetTimer(logElapse, 0)
    ;MyGui.Destroy()
    return
}

/**
 * This function will check for `waitUntil.ahk` and close it if it's open
 */
closeWaitUntil()
{
    detect()
    if WinExist("waitUntil.ahk",, browser.vscode.winTitle)
        ProcessClose(WinGetPID("waitUntil.ahk",, browser.vscode.winTitle))
}

OnExit(ExitFunc)

/**
 * This function determines what the script will do if it's forced to exit - ie. a second instance is forced open
 */
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single"
        {
            closeWaitUntil()
            SetTimer(change_msgButton, 0)
            if WinExist("Select commission folder")
                return
            stop()
            close()
        }
    else
        {
            closeWaitUntil()
            close() ;what happens when you close the GUI
        }
}