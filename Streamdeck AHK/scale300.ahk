SetWorkingDir("C:\Program Files\ahk\ahk")
SetDefaultMouseSpeed 0
#Include SD_functions.ahk

If WinActive("ahk_exe Adobe Premiere Pro.exe")
	scale("300")