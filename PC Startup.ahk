SetWorkingDir A_ScriptDir
If not WinExist("ahk_exe StreamDeck.exe")
    ;Because I need to run the streamdeck exe as admin, it won't auto launch on startup because windows hates that, so I just have it launch through this script to get around that issue
    run '*RunAs "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"'

SetTimer(open, -60000)
;because I use capslock for some macros, I have to open my main script delayed, if I don't then those capslock macros will fail to be recognised until I refresh the script. So this is just a little 1min~ timer to launch my main script
open()
{
    run A_ScriptDir "\My Scripts.ahk"
    run A_ScriptDir "\QMK Keyboard.ahk"
    ;
    sleep 5000
    run A_ScriptDir "\My Scripts.ahk"
    ExitApp
}
