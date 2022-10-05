#SingleInstance Force
;this is a script to just activate the window any route documents are on then progress it forward. I have a habit of clicking off it and scrambling to move it along
if !WinExist("Google Slides")
    ExitApp()

if !WinActive("Google Slides")
    {
        WinActivate()
        sleep 50
    }
SendInput("{Right}")
ExitApp()