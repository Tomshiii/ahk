#SingleInstance Force
SetWorkingDir A_ScriptDir
SetDefaultMouseSpeed 0
EnvSet("Windows", "C:\Program Files\ahk\ahk\ImageSearch\Windows\Win11\Settings\")

;
; This script is designed for Windows 11 and its settings menu. Older win10 compatible scripts can be seen backed up in the Win10 folder
;

MouseGetPos(&sx, &sy)
Run("ms-settings:apps-volume")
WinWait("Settings")
if WinExist("Settings")
    WinActivate()
if WinActive("Settings")
    WinMaximize()
coordmode "pixel", "window"
coordmode "mouse", "window"
MouseMove(789, 375)
if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox3.png")
    goto next
else if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox.png")
    goto next
else if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox2.png")
    goto next
else 
    {
        SendInput("{WheelDown 5}")
        sleep 100
        if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox3.png")
            goto next
        if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox.png")
            goto next
        else if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox2.png")
            goto next
        else
            {
                SendInput("{WheelDown 5}")
                sleep 100
                if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox3.png")
                    goto next
                if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox.png")
                    goto next
                else if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "firefox2.png")
                    goto next
                else
                    {
                        SendInput("{WheelDown 5}")
                    }
            }
    }

next:
MouseMove(%&ffx%, %&ffy%)
Click()
sleep 500
if ImageSearch(&devX, &devY, %&ffX%, %&ffY% - "30", %&ffX% + 2500, %&ffY% + "30", "*2 " EnvGet("Windows") "sample.png")
    goto end
else
    {
        SendInput("{Tab 3}")
        ;sleep 500
        SendInput("{Up 10}")
        sleep 100
        SendInput("{Down 5}")
        sleep 100
        ;SendInput("{Enter}")
    }
end:
sleep 200
WinClose("Settings")
MouseMove(%&sx%, %&sy%)
ExitApp()