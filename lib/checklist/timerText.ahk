;defines all text for the timer. Everything is relative to the previous control, move one to move them all
startHoursRounded := floorDecimal(timer.Count/3600, timer.decimalPlace) ;getting the hours by dividing the seconds past then rounding to 2dp
startMinutesRounded := Floor(((timer.Count/3600) - floor(timer.Count/3600))*60) ;getting the minutes past the hour

timeHeights := Map(
    "default",       "Y224",
)

lengthCheck := StrLen(startHoursRounded)
if lengthCheck > 7
    {
        MsgBox("Time listed in ``checklist.ini`` is too large.")
        return
    }

checklistGUI.AddText("X8 " timeHeights["default"] " W18", "H: ").SetFont("S14") ;defining the hours text
timerText := checklistGUI.Add("Text", "X+5 w60", startHoursRounded) ;setting the text that will contain the numbers
timerText.SetFont("S16 cRed")

checklistGUI.AddText("X+12 W22", "M: ").SetFont("S14") ;defining the minutes text
timerMinutes := checklistGUI.Add("Text", "X+4 w30", startMinutesRounded) ;setting the text that will contain the numbers
timerMinutes.SetFont("S16 cRed")

checklistGUI.AddText("X+10 W18", "S: ").SetFont("S14") ;defining the minutes text

minutesForSeconds := Floor(timer.Count/60)
Seconds := Round((((timer.Count/60) - minutesForSeconds) * 60), 0)
timerSeconds := checklistGUI.Add("Text", "X+5 w30", Seconds) ;setting the text that will contain the numbers
timerSeconds.SetFont("S16 cRed")