;#SingleInstance Force ;LEAVE THIS LIKE THIS SO YOU DON'T ACCIDENTLY OPEN IT AGAIN
#Requires AutoHotkey v2.0-beta.5
TraySetIcon("E:\Github\ahk\Support Files\Icons\checklist.ico") ;YOU WILL NEED TO PUT YOUR OWN WORKING DIRECTORY HERE

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.1.0

;THIS SCRIPT --->>
;isn't designed to be launch from this folder specifically - it gets moved to the current project folder through a few other Streamdeck AHK scripts

;DO NOT RELOAD THIS SCRIPT WITHOUT FIRST STOPPING THE TIMER - PRESSING THE `X` IS FINE BUT RELOADING FROM THE FILE WILL CAUSE IT TO CLOSE WITHOUT WRITING THE ELAPSED TIME

/* toolCust()
  create a tooltip with any message
  * @param message is what you want the tooltip to say
  * @param timeout is how many ms you want the tooltip to last
  */
  toolCust(message, timeout)
  {
      ToolTip(%&message%)
      SetTimer(timeouttime, - %&timeout%)
      timeouttime()
      {
          ToolTip("")
      }
  }

;SET THE AMOUNT OF MINUTES YOU WANT THE REMINDER TIMER TO WAIT HERE
minutes := 1
global ms := minutes * 60000
;SET THE AMOUNT OF MINUTES YOU WANT INBETWEEN EACH TIME THE SCRIPT LOGS HOW MUCH TIME HAS PASSED (purely for backup purposes)
minutes2 := 10
global ms10 := minutes2 * 60000

;checking for ini file
if not FileExist(A_ScriptDir "\checkbox.ini")
    FileAppend("[Info]`ncheckbox4=0`ncheckbox5=0`ncheckbox1=0`ncheckbox2=0`ncheckbox3=0`ncheckbox6=0`ncheckbox7=0`ncheckbox8=0`ncheckbox9=0`ntime=0", A_ScriptDir "\checkbox.ini")
if not FileExist(A_ScriptDir "\checklist_logs.txt")
    FileAppend("Initial creation time : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec "`n`n", A_ScriptDir "\checklist_logs.txt")

;getting dir name for the title
FullFileName := A_ScriptDir
SplitPath FullFileName, &name

;start defining GUI
MyGui := Gui("AlwaysOnTop", "Editing Checklist - " %&name% ".proj")
MyGui.SetFont("S12") ;Sets the size of the font
MyGui.SetFont("W500") ;Sets the weight of the font (thickness)
MyGui.Opt("+MinSize300x300")

;defining title
title := MyGui.Add("Text", "w300", "Checklist - " %&name%)
title.SetFont("bold")

;defining checkboxes
checkbox4 := MyGui.Add("CheckBox",, "First Pass")
checkbox4.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox4")
checkbox4.OnEvent("Click", checkbox4Ini)

checkbox5 := MyGui.Add("CheckBox",, "Second Pass")
checkbox5.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox5")
checkbox5.OnEvent("Click", checkbox5Ini)

checkbox1 := MyGui.Add("CheckBox",, "Twitch overlay")
checkbox1.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox1")
checkbox1.OnEvent("Click", checkbox1Ini)

checkbox2 := MyGui.Add("CheckBox",, "Youtube overlay")
checkbox2.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox2")
checkbox2.OnEvent("Click", checkbox2Ini)

checkbox3 := MyGui.Add("CheckBox",, "Transitions")
checkbox3.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox3")
checkbox3.OnEvent("Click", checkbox3Ini)

checkbox8 := MyGui.Add("CheckBox",, "SFX")
checkbox8.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox8")
checkbox8.OnEvent("Click", checkbox8Ini)

checkbox6 := MyGui.Add("CheckBox",, "Music")
checkbox6.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox6")
checkbox6.OnEvent("Click", checkbox6Ini)

checkbox7 := MyGui.Add("CheckBox",, "Patreon")
checkbox7.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox7")
checkbox7.OnEvent("Click", checkbox7Ini)

checkbox9 := MyGui.Add("CheckBox", "X200 Y38", "Intro")
checkbox9.Value := IniRead(A_ScriptDir "\checkbox.ini", "Info", "checkbox9")
checkbox9.OnEvent("Click", checkbox9Ini)

;timer text
global startValue := IniRead(A_ScriptDir "\checkbox.ini", "Info", "time") ;gets the starting timecode value by reading the ini file
startHoursRounded := Round(startValue/3600, 3) ;getting the hours by dividing the seconds past then rounding to 2dp
startMinutesRounded := Round(startValue/60, 2) ;getting the minutes past by dividing the seconds past then rounding to 2dp

timerHoursText := MyGui.Add("Text", "X14 Y270 W60", "Hours: ") ;defining the hours text
timerHoursText.SetFont("S14")
timerText := MyGui.Add("Text", "X80 Y270 w200", startHoursRounded) ;setting the text that will contain the numbers
timerText.SetFont("S16 cRed")

timerMinutesText := MyGui.Add("Text", "X14 Y300 W80", "Minutes: ") ;defining the minutes text
timerMinutesText.SetFont("S14")

timerMinutes := MyGui.Add("Text", "X100 Y300 w200", startMinutesRounded) ;setting the text that will contain the numbers
timerMinutes.SetFont("S16 cRed")

startButton := MyGui.Add("Button","X120 Y235 w50 h30", "Start") ;defining the start button
startButton.OnEvent("Click", start) ;what happens when you click the start button
stopButton := MyGui.Add("Button","X120 Y235 w0 h0", "Stop") ;defining the stop button and making it invisible for now
stopButton.OnEvent("Click", stop) ;what happens when you click the stop button
group := MyGui.Add("GroupBox", "w150 h100 X177 Y175", "Time Management")

List := MyGui.Add("DropDownList", "r10 Choose5 X190 Y200 w80 h30", ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
minusButton := MyGui.Add("Button","X190 Y235 w60 h30", "-minus") ;defining the -5min button
minusButton.OnEvent("Click", minusFive) ;what happens when you click the -5min button

plusButton := MyGui.Add("Button","X257 Y235 w50 h30", "+add") ;defining the -5min button
plusButton.OnEvent("Click", plusFive) ;what happens when you click the -5min button

FileAppend("\\ The application was opened : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours at opening = " startHoursRounded " -- frames at opening = " startValue "`n", A_ScriptDir "\checklist_logs.txt")
SetTimer(reminder, -ms)

;timer
global StartTickCount := "" ;that is required to start blank or the time will continue to increment while the timer is paused
global ElapsedTime := 0 + startValue ;a starting value for the timer
start(*) {
    startButton.Move(,, 0, 0) ;hiding the start button
    stopButton.Move(,, 50, 30) ;showing the stop button
    timerText.SetFont("cGreen") ;changing the colours
    timerMinutes.SetFont("cGreen")
    forFile := Round(ElapsedTime / 3600, 3)
    FileAppend("\\ The timer was started : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Starting Hours = " forFile " -- frames at start = " ElapsedTime "`n", A_ScriptDir "\checklist_logs.txt")
    global StartTickCount := A_TickCount ;This allows us to use your computer to determine how much time has past by doing some simple math below
    SetTimer(StopWatch, 10) ;start the timer and loop it as often as possible
    SetTimer(logElapse, -ms10)
    SetTimer(reminder, 0)
}
StopWatch() {
    if WinExist("Editing Checklist") ;this check is to stop the timer from running once you close the GUI
        {
            if ((A_TickCount - StartTickCount) >= 1000) ;how we determine once more than 1s has passed
                {
                    global StartTickCount += 1000
                    global ElapsedTime += 1
                    displayHours := Round(ElapsedTime/3600, 3)
                    timerText.Text := displayHours
                    displayMinutes := Round(ElapsedTime/60, 2)
                    timerMinutes.Text := displayMinutes
                }
        }
    else
        SetTimer(StopWatch, 0)
}
stop(*) {
    forFile := Round(ElapsedTime / 3600, 3)
    IniWrite(ElapsedTime, A_ScriptDir "\checkbox.ini", "Info", "time") ;once the timer is stopped it will write the elapsed time to the ini file
    FileAppend("\\ The timer was stopped : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after stopping = " forFile " -- frames at stop = " ElapsedTime "`n", A_ScriptDir "\checklist_logs.txt")
    SetTimer(StopWatch, 0) ;then stop the timer
    startButton.Move(,, 50, 30) ;then show the start button
    stopButton.Move(,, 0, 0) ;and hide the stop button
    timerText.SetFont("cRed") ;and return the colour to red
    timerMinutes.SetFont("cRed")
    SetTimer(logElapse, 0)
    SetTimer(reminder, -ms)
    global startValue := IniRead(A_ScriptDir "\checkbox.ini", "Info", "time") ;then update startvalue so it will start from the new elapsed time instead of the original
}
minusOrAdd(sign) ;this function is to reduce copy/paste code in some .OnEvent return functions
{
    forFile := Round(ElapsedTime / 3600, 3)
    IniWrite(ElapsedTime, A_ScriptDir "\checkbox.ini", "Info", "time")
    global initialRead := IniRead(A_ScriptDir "\checkbox.ini", "Info", "time")
    if sign = "-"
        {
            funcMinutes := ((List.Text * 60) + 1)
            newValue := initialRead - funcMinutes
        }
    else
        {
            funcMinutes := ((List.Text * 60) - 1)
            newValue := initialRead + funcMinutes
        }
    if newValue < 0
        newValue := 0
    change := IniWrite(newValue, A_ScriptDir "\checkbox.ini", "Info", "time")
    SetTimer(StopWatch, -1000)
    timerText.SetFont("cRed")
    timerMinutes.SetFont("cRed")
    startButton.Move(,, 50, 30)
    stopButton.Move(,, 0, 0)
    SetTimer(logElapse, 0)
    SetTimer(reminder, -ms)
    global startValue := IniRead(A_ScriptDir "\checkbox.ini", "Info", "time")
    global ElapsedTime := 0 + startValue
    global StartTickCount := A_TickCount
    FileAppend("\\ The timer was stopped and " List.Text "min removed : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after stopping = " forFile " -- frames after stopping = " ElapsedTime "`n", A_ScriptDir "\checklist_logs.txt")
}
minusFive(*) {
    minusOrAdd("-")
}
plusFive(*) {
    minusOrAdd("+")
}
reminder() {
    if WinExist("ahk_exe Adobe Premiere Pro.exe")
        {
            toolCust("Don't forget you have the timer stopped!", "2000")
            SetTimer(, -ms)
        }
    else
        SetTimer(, 0)
}
logElapse() {
    forFile := Round(ElapsedTime / 3600, 3)
    FileAppend(A_Tab "\\ " minutes2 "min has passed since last log : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- current hours = " forFile " -- current frames = " ElapsedTime "`n", A_ScriptDir "\checklist_logs.txt")
    SetTimer(, -ms10)
}

/*
 This function is here simply to reduce copy pasting of code for the checkboxes below - it keeps track of whether a box is enabled/disabled and also handles writing to the log files when either is done
 @param value is the name of the checkbox (from up above)
 @param value2 is simply `checkboxX.Value`
 @param value3 is simply `checkboxX.Text`
 */
checkbox(value, value2, value3) {
    logState := ""
    logCheck := ""
    forFile := Round(ElapsedTime / 3600, 3)
    IniWrite(%&value2%, A_ScriptDir "\checkbox.ini", "Info", %&value%)
    if %&value2% = 0
        {
            logState := "disabled"
            logCheck := "disabling"
        }
    else
        {
            logState := "enabled"
            logCheck := "enabling"
        }
    FileAppend("\\ ``" %&value3% "`` was " logState " : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after " logCheck "  = " forFile " -- frames after " logCheck " = " ElapsedTime "`n", A_ScriptDir "\checklist_logs.txt")
}
;defining what happens when checkboxes are clicked
checkbox1ini(*) {
    checkbox("checkbox1", checkbox1.Value, checkbox1.Text)
}
checkbox2ini(*) {
    checkbox("checkbox2", checkbox2.Value, checkbox2.Text)
}
checkbox3ini(*) {
    checkbox("checkbox3", checkbox3.Value, checkbox3.Text)
}
checkbox4ini(*) {
    checkbox("checkbox4", checkbox4.Value, checkbox4.Text)
}
checkbox5ini(*) {
    checkbox("checkbox5", checkbox5.Value, checkbox5.Text)
}
checkbox6ini(*) {
    checkbox("checkbox6", checkbox6.Value, checkbox6.Text)
}
checkbox7ini(*) {
    checkbox("checkbox7", checkbox7.Value, checkbox7.Text)
}
checkbox8ini(*) {
    checkbox("checkbox8", checkbox8.Value, checkbox8.Text)
}
checkbox9ini(*) {
    checkbox("checkbox9", checkbox9.Value, checkbox9.Text)
}

MyGui.OnEvent("Close", close) ;what happens when you close the GUI
close(*) {
    forFile := Round(ElapsedTime / 3600, 3)
    IniWrite(ElapsedTime, A_ScriptDir "\checkbox.ini", "Info", "time")
    FileAppend("\\ The application was closed : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after closing = " forFile " -- frames at close = " ElapsedTime "`n", A_ScriptDir "\checklist_logs.txt")
    SetTimer(StopWatch, 0)
    SetTimer(reminder, 0)
    MyGui.Destroy()
    return
}

MyGui.Show("AutoSize")
MyGui.Move(-371, -233,,) ;I have it set to move onto one of my other monitors, if you notice that you can't see it after opening or it keeps warping to a weird location, this line of code is why
;finish defining GUI