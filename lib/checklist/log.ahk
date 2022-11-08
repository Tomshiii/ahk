/**
 * The function that is called when the neccesary amount of minutes have passed and information needs to be logged
 */
logElapse() {
    global logActive := true
    forFile := Round(ElapsedTime / 3600, 3)
    newDate(&today)
    FileAppend(A_Tab "\\ " minutes2 "min has passed since last log : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- current hours = " forFile " -- current seconds = " ElapsedTime "`n", logs)
    SetTimer(, -ms10)
}


/**
 * This function is called when a checkbox is ticked and handles writing the state of any changed checkboxes to the checklist.ini file and then logging that information in the checklist_logs.txt file
 */
logCheckbox(*) {
    forFile := Round(ElapsedTime / 3600, 3)
    logState := "enabled"
    logCheck := "enabling"
    Saved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    for name, value in Saved.OwnProps()
        {
            upperCount := 0
            loop {
                length := StrLen(name)
                static pos := 0
                if A_Index > length
                    break
                letter := SubStr(name, A_Index, 1)
                if IsUpper(letter)
                    {
                        upperCount += 1
                        pos := A_Index
                    }
            }
            if upperCount > 1 && upperCount < 3
                {
                    first := SubStr(name, 1, pos - 1)
                    second := SubStr(name, pos, )
                    name := first A_Space second
                }
            startVal := IniRead(checklist, "Checkboxes", name)
            if startVal != value
                {
                    IniWrite(value, checklist, "Checkboxes", name)
                    if value = 0
                        {
                            logState := "disabled"
                            logCheck := "disabling"
                        }
                    newDate(&today)
                    FileAppend("\\ ``" name "`` was " logState " : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after " logCheck "  = " forFile " -- seconds after " logCheck " = " ElapsedTime "`n", logs)
                }
        }
}

/**
 * A function to cut repeat code - will check the last date in the logs and then break up the group if the last date is different from today
 * @param {var} today is a variable we pass back to the main script that tells the script what the current day is
 */
newDate(&today)
{
    ;getting the last date present in the log file
    getLastDate(&today)
    {
        ;todays date
        today := A_YYYY "_" A_MM "_" A_DD
        read := FileRead(logs)
        if InStr(read, A_YYYY "_",, -1)
            foundpos := InStr(read, A_YYYY "_",, -1)
        else ;this block is just incase you open a checklist in a new year
            {
                lastYear := A_YYYY - 1
                if InStr(read, lastYear "_",, -1)
                    foundpos := InStr(read, lastYear "_",, -1)
                else ;if the last logged years is a long time ago, we will just default back to this year to stop errors
                    {
                        lastdate := A_YYYY
                        return lastdate
                    }

            }
        endpos := InStr(read, ",",, foundpos)
        end := endpos - foundpos
        lastdate := SubStr(read, foundpos, end)
        return lastdate
    }
    lastdate := getLastDate(&today)
    if today != lastdate && lastdate != ""
        FileAppend("}`n`n{ " today " - " timeForLog "`n",  logs)
}