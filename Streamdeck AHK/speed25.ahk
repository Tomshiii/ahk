SetWorkingDir("C:\Program Files\ahk\ahk")
EnvSet("Premiere", A_WorkingDir "\ImageSearch\Premiere\")
#Include "C:\Program Files\ahk\ahk\KSA\Keyboard Shortcut Adjustments.ahk"
#Include SD_functions.ahk

If WinActive("ahk_exe Adobe Premiere Pro.exe")
    {
        ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
        If ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " EnvGet("Premiere") "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
            {
                SendInput(timelineWindow selectAtPlayhead)
                goto inputs
            }
        else
            {
                classNN := ControlGetClassNN(ControlGetFocus("A"))
                if "DroverLord - Window Class3"
                    goto inputs
                else
                    {
                        toolCust("gain macro couldn't figure`nout what to do", "1000")
                        return
                    }
            }
        inputs:
        SendInput(speedMenu "25{ENTER}")
    }
else
    ExitApp
ExitApp()