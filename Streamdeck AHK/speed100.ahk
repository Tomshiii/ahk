SetWorkingDir("C:\Program Files\ahk\ahk")
EnvSet("Premiere", A_WorkingDir "\ImageSearch\Premiere\")
#Include SD_functions.ahk

If WinActive("ahk_exe Adobe Premiere Pro.exe")
    speed("100")