;// based on code found: https://www.autohotkey.com/docs/v2/lib/SetTimer.htm#ExampleClass

class count {
    /**
     * @params {Integer} repeat the interval in `ms` you want the timer to count in. Alternatively, pass a float (1.0) if you wish to pass in `sec`
     */
    __New(repeat := 1000) {
        if !IsInteger(repeat) && IsFloat(repeat) ;this allows the user to use something like 2.5 to mean 2.5 seconds instead of needing 2500
            repeat := repeat * 1000
        this.interval := repeat
        this.count := 0
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
    }

    /**
     * This function starts the timer
     */
    start() {
        SetTimer(this.timer, this.interval)
    }

    /**
     * This function stops the timer
     */
    stop() {
        SetTimer(this.timer, 0)
    }

    /**
     * This function is called by the timer and updates the instance var `count`
     */
    Tick() {
        ++this.count
    }
}