;what happens when you close the checklist
close(*) {
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
    MyGui.Destroy()
    return
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single"
        {
            if WinExist("Select commission folder")
                return
            stop()   
            close()
        }
}