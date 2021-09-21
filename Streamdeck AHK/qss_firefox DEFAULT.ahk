#SingleInstance Force
SetWorkingDir A_ScriptDir
SetDefaultMouseSpeed 0
EnvSet("Windows", "C:\Program Files\ahk\ahk\ImageSearch\Windows\Settings\")

RunWait("ms-settings:apps-volume")
sleep 300
coordmode "pixel", "window"
coordmode "mouse", "window"
SendInput("{tab}")
MouseMove(274, 126)
Click()
if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "ffDARK.png")
    goto next
else
    {
        if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "ffLIGHT.png")
            goto next
        else
            {
                SendInput("{WheelDown 5}")
                sleep 1000
                if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "ffDARK.png")
                    goto next
                else
                    {
                        if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "ffLIGHT.png")
                            goto next
                        else
                            {
                                SendInput("{WheelDown 5}")
                                sleep 1000
                                if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "ffDARK.png")
                                    goto next
                                else
                                    {
                                        if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " EnvGet("Windows") "ffLIGHT.png")
                                            goto next
                                        else
                                            {
                                                SendInput("{WheelDown 5}")
                                            }
                                    }
                            }
                            
                    }
            }
            
    }



next:
;MouseMove(%&ffX%, %&ffY%)
;MouseGetPos(&pix, &piy)
If PixelSearch(&xcol, &ycol, %&ffX% + "250", %&ffY% - "10", %&ffX% + "600", %&ffY% + "40", 0xD8D8D8, 3)
    {
        MouseMove(%&xcol%, %&ycol%)
        Click()
        SendInput("{Enter}")
        SendInput("{Up 15}")
    }
    
else
    {
        If PixelSearch(&xcol, &ycol, %&ffX% + "250", %&ffY% - "10", %&ffX% + "600", %&ffY% + "40", 0x979797, 3)
            {
                MouseMove(%&xcol%, %&ycol%)
                Click()
                SendInput("{Enter}")
                SendInput("{Up 15}")                
            }
    }
sleep 200
WinClose("Settings")
ExitApp()