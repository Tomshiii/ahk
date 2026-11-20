; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\ptf.ahk
; }

try isWork := A_Args[1]
if !IsSet(isWork)
    isWork := 0

dir := ptf.SupportFiles "\Mouse Stuff\"

; the MX Vertical script retries by itself, so start it first
cmd.run(, false,, Format('py -3.13 {1} {2}', "Logi_MX_Vert.py", ""), dir, "Hide")

if isWork
    ExitApp()

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
Notify.Show(, "Battery: " batt "%", 'C:\Windows\System32\mmcndmgr.dll|icon51', (batt > 20 ? 'ding' : 'notify') ,, (batt > 20 ? 'bdr=Green' : "bdr=Red") A_Space 'show=Fade@250 hide=Fade@250 maxW=400')
if batt <= 20 {
    MsgBox("E9Pro mouse battery is low. Consider charging soon.`n`nBattery level: " batt "%")
    ExitApp()
} else {
    sleep 8500 ;// wait for notify gui to close
    ExitApp()
}

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