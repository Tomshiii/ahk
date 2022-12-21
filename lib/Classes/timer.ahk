#Include <Classes\tool>
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

    start() {
        SetTimer(this.timer, this.interval)
        ; tool.Cust("Counter started")
    }

    stop() {
        ; To turn off the timer, we must pass the same object as before:
        SetTimer(this.timer, 0)
        ; tool.Cust("Counter stopped at " this.count)
    }

    ; In this example, the timer calls this method:
    Tick() {
        ++this.count
    }
}