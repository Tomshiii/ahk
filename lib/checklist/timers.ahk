#Include <Classes\timer>

;// set the timer for every 10min??
;//! does this pass the value to the base class??
log := logs(10*1000)

;//! does an extended class call the initial classes constructor??
class logs extends count {
    static logActive := false

    /**
     * This method handles initiating the log timer
     */
    timePassed() {
        this.logActive := true
        forFile := Round(timer.count / 3600, 3)
        newDate(&today)
        timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)
        FileAppend(A_Tab "\\ " minutes2 "min has passed since last log : " timeStr " -- current hours = " forFile " -- current seconds = " timer.count "`n", logs)
        SetTimer(super.timer, super.interval)
    }

    /**
     * This method is handles stopping the log timer
     */
    timeStop() {
        this.logActive := false
        SetTimer(super.timer, 0)
    }
}

class checklistTimer extends count {

    ;// if I have a class like this that extends another class, is there a way to change any of the methods of the base class? or are they stuck as they are?

    /**
     * This function handles what happens when the start button is pressed
     */
    start(*) {
        ;// can these methods have the same name as the base class?? probably not
        startButton.Move(,, 0, 0) ;hiding the start button
        stopButton.Move(,, 50, 30) ;showing the stop button
        timerText.SetFont("cGreen") ;changing the colours
        timerMinutes.SetFont("cGreen")
        timerSeconds.SetFont("cGreen")
        forFile := Round(super.count / 3600, 3)
        newDate(&today)
        timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)
        FileAppend("\\ The timer was started : " timeStr " -- Starting Hours = " forFile " -- seconds at start = " super.count "`n", logs)
        super.start() ;start the timer
        log.start()
        SetTimer(reminder, 0)
    }

    ;//! this function should get removed??
    ;// or keep this part and simply have it called every second using it's own instance of the count class??
    ;// if so readd it being called in other functions
    /**
     * This is the main stopwatch timer itself and is what handles all of the counting and updating the text
     */
    StopWatch() {
        displayHours := floorDecimal(super.count/3600, 3)
        timerText.Text := displayHours
        displayMinutes := Floor(((super.count/3600) - floor(super.count/3600))*60)
        timerMinutes.Text := displayMinutes
        minforSec := Floor(super.count/60)
        displaySeconds := Round((((super.count/60) - minforSec) * 60), 0)
        timerSeconds.Text := displaySeconds
    }

    /**
     * This function handles what happens when the stop button is pressed
     */
    stop(*) {
        if !IsSet(super.count)
            {
                if !WinExist("Editing Checklist - ")
                    Run(A_ScriptFullPath)
                else
                    ExitApp()
            }
        forFile := Round(super.count / 3600, 3)
        checkHours := IniRead(checklist, "Info", "time")
        if super.count != checkHours
            IniWrite(super.count, checklist, "Info", "time") ;once the timer is stopped it will write the elapsed time to the ini file
        newDate(&today)
        timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)
        FileAppend("\\ The timer was stopped : " timeStr " -- Stopping Hours = " forFile " -- seconds at stop = " super.count "`n", logs)
        super.stop() ;then stop the timer
        startButton.Move(,, 50, 30) ;then show the start button
        stopButton.Move(,, 0, 0) ;and hide the stop button
        timerText.SetFont("cRed") ;and return the colour to red
        timerMinutes.SetFont("cRed")
        timerSeconds.SetFont("cRed")
        SetTimer(logElapse, 0)
        global logActive := false
        SetTimer(reminder, -ms)
        global startValue := IniRead(checklist, "Info", "time") ;then update startvalue so it will start from the new elapsed time instead of the original
    }

    /**
     * This function is to reduce copy/paste code in some .OnEvent return functions
     * @param {String} sign is if it's the minus key or plus key
     */
    minusOrAdd(sign)
    {
        forFile := Round(super.count / 3600, 3)
        word := ""
        IniWrite(super.count, checklist, "Info", "time")
        global initialRead := IniRead(checklist, "Info", "time")
        switch sign {
            case "-":
                word := "removed"
                funcMinutes := ((List.Text * 60) + 1)
                newValue := initialRead - funcMinutes
            default:
                word := "added"
                funcMinutes := ((List.Text * 60) - 1)
                newValue := initialRead + funcMinutes
        }
        if newValue < 0
            newValue := 0
        IniWrite(newValue, checklist, "Info", "time")
        SetTimer(StopWatch, -1000)
        timerText.SetFont("cRed")
        timerMinutes.SetFont("cRed")
        timerSeconds.SetFont("cRed")
        startButton.Move(,, 50, 30)
        stopButton.Move(,, 0, 0)
        SetTimer(logElapse, 0)
        global logActive := false
        SetTimer(reminder, -ms)
        global startValue := IniRead(checklist, "Info", "time")
        global super.count := 0 + startValue
        global StartTickCount := A_TickCount
        newDate(&today)
        timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)
        FileAppend("\\ The timer was stopped and " List.Text "min " word " : " timeStr " -- Hours after stopping = " forFile " -- seconds after stopping = " super.count "`n", logs)
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
        if !WinExist(editors.Premiere.winTitle)
            {
                SetTimer(, 0)
                return
            }
        switch settingsToolTrack {
            case 1:
                tool.Cust("Don't forget you have the timer stopped!", "2000",,, 30, 20)
                SetTimer(, -ms)
                return
            case 0:
                SetTimer(, 0)
                return
        }
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
}