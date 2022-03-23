#SingleInstance Force
;this is a script to just activate my chat window
if WinExist("Twitch - Google Chrome")
    {
        if WinActive()
            return
        else
            {
                WinActivate()
                sleep 50
                ExitApp()
            }
    }
else
    ExitApp()