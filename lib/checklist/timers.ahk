#Include <Classes\timer>

class checklistTimer extends count {
    __New(newRepeat := 1000) {
        super.__New(newRepeat)
        this.logger   := checklistLog(10*1000)
        this.reminder := checklistReminder(ms)
    }
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
        forFile := Round(this.count / 3600, 3)
        newDate(&today)
        timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)
        FileAppend("\\ The timer was started : " timeStr " -- Starting Hours = " forFile " -- seconds at start = " this.count "`n", logs)
        super.start() ;start the timer
        this.logger.start()
        this.reminder.stop()
    }

    Tick() {
        ++this.count
        this.StopWatch()
    }

    /**
     * This function handles updating the text and is called by `tick()`
     */
    StopWatch() {
        displayHours := Format("{:.3f}", floorDecimal(this.count/3600, 3)) ;
        timerText.Text := displayHours
        displayMinutes := Floor(((this.count/3600) - floor(this.count/3600))*60)
        timerMinutes.Text := displayMinutes
        minforSec := Floor(this.count/60)
        displaySeconds := Round((((this.count/60) - minforSec) * 60), 0)
        timerSeconds.Text := displaySeconds
    }

    /**
     * This function handles what happens when the stop button is pressed
     */
    stop(*) {
        forFile := Round(this.count / 3600, 3)
        checkHours := IniRead(checklist, "Info", "time")
        if this.count != checkHours
            IniWrite(this.count, checklist, "Info", "time") ;once the timer is stopped it will write the elapsed time to the ini file
        newDate(&today)
        timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)
        FileAppend("\\ The timer was stopped : " timeStr " -- Stopping Hours = " forFile " -- seconds at stop = " this.count "`n", logs)
        super.stop() ;then stop the timer
        startButton.Move(,, 50, 30) ;then show the start button
        stopButton.Move(,, 0, 0) ;and hide the stop button
        timerText.SetFont("cRed") ;and return the colour to red
        timerMinutes.SetFont("cRed")
        timerSeconds.SetFont("cRed")
        this.logger.stop()
        this.reminder.start()
        global startValue := IniRead(checklist, "Info", "time") ;then update startvalue so it will start from the new elapsed time instead of the original
    }

    /**
     * This function is to reduce copy/paste code in some .OnEvent return functions
     * @param {String} sign is if it's the minus key or plus key
     */
    minusOrAdd(sign)
    {
        forFile := Round(this.count / 3600, 3)
        word := ""
        IniWrite(this.count, checklist, "Info", "time")
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
        SetTimer(this.StopWatch(), -1000)
        super.stop()
        this.logger.stop()
        this.reminder.stop()
        global startValue := IniRead(checklist, "Info", "time")
        this.count := 0 + startValue
        newDate(&today)
        timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)
        FileAppend("\\ The timer was stopped and " List.Text "min " word " : " timeStr " -- Hours after stopping = " forFile " -- seconds after stopping = " this.count "`n", logs)
    }
    minusFive(*) {
        this.minusOrAdd("-")
    }
    plusFive(*) {
        this.minusOrAdd("+")
    }
}

class checklistLog extends count {
    __New(repeat := ms10) {
        super.__New(repeat)
        this.logActive := false
    }

    Tick() {
        ++this.count
        this.timePassed()
    }

    /**
     * This method handles initiating the log timer
     */
    timePassed() {
        this.logActive := true
        forFile := Round(timer.count / 3600, 3)
        newDate(&today)
        timeStr := Format("{}_{}_{}, {}:{}:{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec)
        FileAppend(A_Tab "\\ " minutes2 "min has passed since last log : " timeStr " -- current hours = " forFile " -- current seconds = " timer.count "`n", logs)
        SetTimer(this.timer, this.interval)
    }

    /**
     * This method is handles stopping the log timer
     */
    timeStop() {
        this.logActive := false
        SetTimer(this.timer, 0)
    }
}

class checklistReminder extends count {
    __New(repeat := ms) {
        super.__New(repeat)
    }

    Tick() {
        ++this.count
        this.reminder()
    }

    /**
     * Reminds the user that they have the timer stopped
     */
    reminder()
    {
        if !WinExist(editors.Premiere.winTitle)
            {
                SetTimer(this.timer, 0)
                return
            }
        switch settingsToolTrack {
            case 1:
                tool.Cust("Don't forget you have the timer stopped!", "2000",,, 30, 20)
                SetTimer(this.timer, -ms)
                return
            case 0:
                SetTimer(this.timer, 0)
                return
        }
    }
}