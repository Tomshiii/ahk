#SingleInstance Force
#Include SD_functions.ahk
/*
 This value will send the keyboard shortcut you have set to disable the preview window within OBS Studio

 Can be set within KSA.ahk/ini
*/
screenshotOBS := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "OBS", "Screenshot")

;this is a script to just activate the window any route documents are on then progress it forward. I have a habit of clicking off it and scrambling to move it along
if WinExist("ahk_exe obs64.exe")
    {
        if WinActive()
            {
                SendInput(screenshotOBS)
                ExitApp()
            }
        else
            {
                try {
                    title := WinGetTitle("A")
                } catch as e {
                    toolCust("couldn't grab active window", "1000")
                }
                WinActivate()
                sleep 50
                SendInput(screenshotOBS)
                sleep 100
                try {
                    WinActivate(title)
                } catch as e {
                    toolCust("couldn't activate original window", "1000")
                }
                ExitApp()
            }
    }
else
    ExitApp()