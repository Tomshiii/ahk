#SingleInstance Force
SetWorkingDir A_ScriptDir
SetDefaultMouseSpeed 0
EnvSet("Windows", "C:\Program Files\ahk\ahk\ImageSearch\Windows\Win11\Settings\")

;
; This script is designed for Windows 11 and its settings menu. Older win10 compatible scripts can be seen backed up in the Win10 folder
;

RunWait("ms-settings:apps-volume")
WinWait("Settings")
if WinExist("Settings")
    WinActivate()
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
if ImageSearch(&outX, &outY, %&ffX% - "5", %&ffY%, 2567, 1447, "*2 " EnvGet("Windows") "output device.png")
    {
        if ImageSearch(&devX, &devY, %&outX%, %&outY% - "30", %&outX% + 2500, %&outY% + "30", "*2 " EnvGet("Windows") "default.png")
            goto end
        else if PixelSearch(&xcol, &ycol, %&outX%, %&outY% - "30", %&outX% + 2500, %&outY% + "30", 0x413C38, 3)
                {
                    MouseMove(%&xcol%, %&ycol%)
                    click
                    MouseGetPos(&newx, &newy)
                    MouseMove(-30, 0,, "R")
                    sleep 100
                    if ImageSearch(&finalX, &finalY, %&newx% - "20", %&newy% - "200", %&newx% + "250", %&newy% + "700", "*2 " EnvGet("Windows") "default3.png")
                        goto end
                    else if ImageSearch(&finalX, &finalY, %&newx% - "20", %&newy% - "200", %&newx% + "250", %&newy% + "700", "*2 " EnvGet("Windows") "default2.png")
                        {
                            MouseMove(%&finalX%, %&finalY%)
                            click
                            goto end
                        }
                }
            else
                {
                    return
                }
        
    }
end:
sleep 200
WinClose("Settings")
ExitApp()