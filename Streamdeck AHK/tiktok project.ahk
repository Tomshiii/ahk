#SingleInstance Force
SetWorkingDir("C:\Program Files\ahk\ahk")
EnvSet("Premiere", A_WorkingDir "\ImageSearch\Premiere\")
#Include SD_functions.ahk

If WinActive("ahk_exe Adobe Premiere Pro.exe")
    {
        coordw()
        SendInput("!s" "q")
        WinWait("Sequence Settings")
        sleep 500
        MouseMove(0, 0)
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " EnvGet("Premiere") "seq1920.png")
            {
                If PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "150", %&y% + "4", 0x161616, 3)
                    {
                        MouseMove(%&xcol% + "3", %&ycol% + "3")
                        Click()
                        SendInput("^a{Del}" "1080{Tab}1920{Enter}")
                        sleep 100
                        if WinExist("Delete All Previews For This Sequence")
                            SendInput("{Enter}")
                    }
                else
                    {
                        toolCust("can't find colour", "1000")
                        return
                    }
            }
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " EnvGet("Premiere") "seq1280.png")
            {
                If PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "150", %&y% + "4", 0x161616, 3)
                    {
                        MouseMove(%&xcol% + "3", %&ycol% + "3")
                        Click()
                        SendInput("^a{Del}" "1080{Tab}1920{Enter}")
                        sleep 100
                        if WinExist("Delete All Previews For This Sequence")
                            SendInput("{Enter}")
                    }
                else
                    {
                        toolCust("can't find colour", "1000")
                        return
                    }
            }
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " EnvGet("Premiere") "seq720.png")
            {
                If PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "150", %&y% + "4", 0x161616, 3)
                    {
                        MouseMove(%&xcol% + "3", %&ycol% + "3")
                        Click()
                        SendInput("^a{Del}" "1080{Tab}1920{Enter}")
                        sleep 100
                        if WinExist("Delete All Previews For This Sequence")
                            SendInput("{Enter}")
                    }
                else
                    {
                        toolCust("can't find colour", "1000")
                        return
                    }
            }
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " EnvGet("Premiere") "seq1080.png")
            SendInput("{Enter}")
    }
else
    ExitApp()