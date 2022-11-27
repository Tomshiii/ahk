;defines all text for the timer. Everything is relative to the previous control, move one to move them all
global startValue := IniRead(checklist, "Info", "time") ;gets the starting timecode value by reading the ini file
startHoursRounded := floorDecimal(startValue/3600, 3) ;getting the hours by dividing the seconds past then rounding to 2dp
startMinutesRounded := Floor(((startValue/3600) - floor(startValue/3600))*60) ;getting the minutes past the hour

timeHeights := Map(
    "default",       "Y224",
)

lengthCheck := StrLen(startHoursRounded)
if lengthCheck > 7
    {
        MsgBox("Time listed in ``checklist.ini`` is too large.")
        return
    }
if lengthCheck < 6
    width := 60
else
    width := 70 + ((lengthCheck-6)*12)

MyGui.AddText("X8 " timeHeights["default"] " W18", "H: ").SetFont("S14") ;defining the hours text
timerText := MyGui.Add("Text", "X+5 w" width, startHoursRounded) ;setting the text that will contain the numbers
timerText.SetFont("S16 cRed")

MyGui.AddText("X+12 W22", "M: ").SetFont("S14") ;defining the minutes text
timerMinutes := MyGui.Add("Text", "X+4 w30", startMinutesRounded) ;setting the text that will contain the numbers
timerMinutes.SetFont("S16 cRed")

MyGui.AddText("X+10 W18", "S: ").SetFont("S14") ;defining the minutes text

minutesForSeconds := Floor(startValue/60)
Seconds := Round((((startValue/60) - minutesForSeconds) * 60), 0)
timerSeconds := MyGui.Add("Text", "X+5 w30", Seconds) ;setting the text that will contain the numbers
timerSeconds.SetFont("S16 cRed")