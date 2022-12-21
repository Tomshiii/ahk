/**
 * This function contains the logic on what to do when the checklist is closed
 */
close(*) {
    if !IsSet(timer.count)
        {
            if !WinExist("Editing Checklist - ")
                Run(A_ScriptFullPath)
            else
                ExitApp()
        }
    forFile := Round(timer.count / 3600, 3)
    checkHours := IniRead(checklist, "Info", "time")
    if timer.count != checkHours
        IniWrite(timer.count, checklist, "Info", "time")
    newDate(&today)
    timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)

    if timer.count = checkHours
        FileAppend("\\ The checklist was closed : " timeStr "`n", logs)
    else
        FileAppend("\\ The checklist was closed : " timeStr " -- Hours after closing = " forFile " -- seconds at close = " timer.count "`n", logs)
    SetTimer(reminder, 0)
    if log.logElapse = true
        log.timeStop()
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
            timer.stop()
            close()
        }
    else
        {
            closeWaitUntil()
            close() ;what happens when you close the GUI
        }
}