SetWorkingDir("C:\Program Files\ahk\ahk")
SetDefaultMouseSpeed 0
EnvSet("Premiere", A_WorkingDir "\ImageSearch\Premiere\")
#Include "C:\Program Files\ahk\ahk\KSA\Keyboard Shortcut Adjustments.ahk"
#Include SD_functions.ahk

If WinActive("ahk_exe Adobe Premiere Pro.exe")
	scale("100")