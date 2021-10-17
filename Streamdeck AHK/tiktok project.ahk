#SingleInstance Force
SetWorkingDir("C:\Program Files\ahk\ahk")
EnvSet("Premiere", A_WorkingDir "\ImageSearch\Premiere\")
coordw() ;sets coordmode to "window"
{
	coordmode "pixel", "window"
	coordmode "mouse", "window"
}
toolFind(message, timeout) ;create a tooltip for errors finding things
;&message is what you want the tooltip to say after "couldn't find"
;&timeout is how many ms you want the tooltip to last
{
	ToolTip("couldn't find " %&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}
toolCust(message, timeout) ;create a tooltip with any message
;&message is what you want the tooltip to say
;&timeout is how many ms you want the tooltip to last
{
	ToolTip(%&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}
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
                        SendInput("^a{Del}" "720{Tab}1280{Enter}")
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
        if ImageSearch(&x, &y, 7, -1, 664, 188, "*2 " EnvGet("Premiere") "seq720.png")
            SendInput("{Enter}")
    }
else
    ExitApp()