; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\ptf.ahk
; }

dir := ptf.SupportFiles "\Mouse Stuff\"

; the MX Vertical script retries by itself, so start it first
cmd.run(, false,, Format('py -3.13 {1} {2}', "Logi_MX_Vert.py", ""), dir, "Hide")

; wait for the E9 Pro to report in (0 = wait forever, or pass minutes to give up)
batt := waitForE9Pro(0)
if !batt
    ExitApp()

cmd.run(, true,, Format('py -3.13 {1} {2}', "E9Pro.py", ""), dir, "Hide")
cmd.run(, true,, Format('py -3.13 {1} {2}', "E9Pro_set.py", "rate 2000"), dir, "Hide")
cmd.run(, true,, Format('py -3.13 {1} {2}', "E9Pro_set.py", "lights off"), dir, "Hide")
cmd.run(, true,, Format('py -3.13 {1} {2}', "E9Pro_set.py", "dpi 800"), dir, "Hide")
cmd.run(, true,, Format('py -3.13 {1} {2}', "E9Pro_set.py", "power"), dir, "Hide")
cmd.run(, true,, Format('py -3.13 {1} {2}', "E9Pro_set.py", "sensor"), dir, "Hide")

if batt <= 20
    MsgBox("E9Pro mouse battery is low. Consider charging soon.`n`nBattery level: " batt "%")
ExitApp()

waitForE9Pro(timeoutMin := 0) {
    start := A_TickCount
    loop {
        out := cmd.result(Format('py -3.13 {1} {2}', "E9Pro_set.py", "battery"),,, dir)
        if RegExMatch(Trim(out, " `r`n`t"), "^(\d+)%$", &m)
            return Integer(m[1])
        if timeoutMin && (A_TickCount - start > timeoutMin * 60000)
            return false
        Sleep(3000)
    }
}