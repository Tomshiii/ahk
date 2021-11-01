SetWorkingDir("C:\Program Files\ahk\ahk")
SetDefaultMouseSpeed 0
EnvSet("Premiere", A_WorkingDir "\ImageSearch\Premiere\")
#Include SD_functions.ahk

If WinActive("ahk_exe Adobe Premiere Pro.exe")
	{
		coords()
		blockOn()
		MouseGetPos &xpos, &ypos
		If ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") "scale.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
			{
				If PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "740", %&y% + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
					MouseMove(%&xcol%, %&ycol%)
				else
					{
						blockOff()
						toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
						return
					}			
			}
		else ;this is for when you have the "toggle animation" keyframe button pressed
			{
				If ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " EnvGet("Premiere") "scale2.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
					{
						If PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "740", %&y% + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
							MouseMove(%&xcol%, %&ycol%)
						else
							{
								blockOff()
								toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
								return
							}			
					}
				else ;if everything fails, this else will trigger
					{
						blockOff()
						toolFind("scale", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
						return
					}		
			}
		SendInput "{Click}"
		SendInput("100")
		SendInput("{Enter}")
		MouseMove %&xpos%, %&ypos%
		Click("middle")
		blockOff()
	}
else
	ExitApp()
ExitApp