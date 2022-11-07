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

timerHoursText := MyGui.Add("Text", "X8 " timeHeights["default"] " W18", "H: ") ;defining the hours text
timerHoursText.SetFont("S14")
timerText := MyGui.Add("Text", "X+5 w" width, startHoursRounded) ;setting the text that will contain the numbers
timerText.SetFont("S16 cRed")

timerMinutesText := MyGui.Add("Text", "X+12 W22", "M: ") ;defining the minutes text
timerMinutesText.SetFont("S14")

timerMinutes := MyGui.Add("Text", "X+4 w30", startMinutesRounded) ;setting the text that will contain the numbers
timerMinutes.SetFont("S16 cRed")

timerSecondsText := MyGui.Add("Text", "X+10 W18", "S: ") ;defining the minutes text
timerSecondsText.SetFont("S14")

minutesForSeconds := Floor(startValue/60)
Seconds := Round((((startValue/60) - minutesForSeconds) * 60), 0)
timerSeconds := MyGui.Add("Text", "X+5 w30", Seconds) ;setting the text that will contain the numbers
timerSeconds.SetFont("S16 cRed")