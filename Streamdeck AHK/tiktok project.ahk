#SingleInstance Force
#Include SD_functions.ahk

if WinActive(editors.winTitle["premiere"])
    {
        coord.w()
        SendInput("!s" "q")
        WinWait("Sequence Settings")
        sleep 500
        MouseMove(0, 0)
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " Premiere "seq1920.png")
            {
                if PixelSearch(&xcol, &ycol, x, y, x + "150", y + "4", 0x161616, 3)
                    {
                        MouseMove(xcol + "3", ycol + "3")
                        Click()
                        SendInput("^a{Del}" "1080{Tab}1920{Enter}")
                        sleep 100
                        if WinExist("Delete All Previews For This Sequence")
                            SendInput("{Enter}")
                    }
                else
                    {
                        tool.Cust("can't find colour")
                        return
                    }
            }
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " Premiere "seq1280.png")
            {
                if PixelSearch(&xcol, &ycol, x, y, x + "150", y + "4", 0x161616, 3)
                    {
                        MouseMove(xcol + "3", ycol + "3")
                        Click()
                        SendInput("^a{Del}" "1080{Tab}1920{Enter}")
                        sleep 100
                        if WinExist("Delete All Previews For This Sequence")
                            SendInput("{Enter}")
                    }
                else
                    {
                        tool.Cust("can't find colour")
                        return
                    }
            }
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " Premiere "seq720.png")
            {
                if PixelSearch(&xcol, &ycol, x, y, x + "150", y + "4", 0x161616, 3)
                    {
                        MouseMove(xcol + "3", ycol + "3")
                        Click()
                        SendInput("^a{Del}" "1080{Tab}1920{Enter}")
                        sleep 100
                        if WinExist("Delete All Previews For This Sequence")
                            SendInput("{Enter}")
                    }
                else
                    {
                        tool.Cust("can't find colour")
                        return
                    }
            }
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " Premiere "seq1080.png")
            SendInput("{Enter}")
    }