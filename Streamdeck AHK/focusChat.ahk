#SingleInstance Force
;this is a script to just activate the window any route documents are on then progress it forward. I have a habit of clicking off it and scrambling to move it along
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