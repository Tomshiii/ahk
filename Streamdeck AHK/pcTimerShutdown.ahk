#SingleInstance Force

; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\cmd>
#Include <Other\Notify>
; }

;// For `sleep` to be an available option the user needs to download PSTools; https://learn.microsoft.com/en-us/sysinternals/downloads/psshutdown
;// extract the zip and place the contents in: A_WinDir \System32\

shutdownGUI()
class shutdownGUI extends tomshiBasic {
    __New() {
        super.__New(,, "AlwaysOnTop", "Scheduled Shutdown")
        this.AddEdit("w70 Number limit4 veditVal")
        this.AddUpDown("r1 Range0-9999")
        this.AddDropDownList("x+10 w100 Choose1 vdrpdwn", ["sec", "min", "hours"])
        try checkSleep := cmd.result("psshutdown64", 1)
        checkSleep := (!IsSet(checkSleep) || InStr(checkSleep, "'psshutdown64' is not recognized"))  ? "Disabled" : ""
        this.AddCheckbox("x+6 y+-20 Checked0 " checkSleep " vsleepCheck", "Sleep")

        this.AddButton("x8", "Cancel Timer").OnEvent("Click", this.__cancelTimer.Bind(this))
        this.AddButton("x+6", "Schedule").OnEvent("Click", this.__delay.Bind(this))
        this.show()
    }

    __delay(*) {
        switch this["drpdwn"].Text {
            case "sec":  timer := this["editVal"].Value
            case "min":  timer := this["editVal"].Value*60
            case "hours": timer := (this["editVal"].Value*60)*60
        }
        switch this["sleepCheck"].value {
            case 1:
                cmd.run(1,, 1, Format('psshutdown64 -d -v 0 -t {}', timer))
                Notify.Show("Scheduled Sleep", "This computer will sleep in " timer "s", A_WinDir '\system32\shell32.dll|Icon28',,, "POS=BR DUR=3")
            default: cmd.run(,,, "shutdown -s -t " timer)
        }
    }
    __cancelTimer(*) {
        switch this["sleepCheck"].value {
            case 1:
                cancel := cmd.result("psshutdown64 -a", 1)
                if !InStr(cancel, "Shutdown of local system aborted.")
                    return
                Notify.Show("Scheduled Sleep Aborted", "The scheduled sleep has been cancelled.", A_WinDir '\system32\shell32.dll|Icon28',,, "POS=BR DUR=3")
            default: cmd.run(,,, "shutdown -a")
        }
    }
}