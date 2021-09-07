SetWorkingDir A_ScriptDir
If not WinExist("ahk_exe StreamDeck.exe")
    ;Because I need to run the streamdeck exe as admin, it won't auto launch on startup because windows hates that, so I just have it launch through this script to get around that issue
    run '*RunAs "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"'

SetTimer(open, -30000) ;Simply putting a shortcut to these scripts in your startup folder works fine, I just eventually ended up doing it here after testing a few things and now it's just easier oops.
open()
{
    run A_ScriptDir "\My Scripts.ahk"
    run A_ScriptDir "\QMK Keyboard.ahk"
    run A_ScriptDir "\Alt_menu_acceleration_DISABLER.ahk"
    run A_ScriptDir "\autodismiss error.ahk"
    run A_ScriptDir "\right click premiere.ahk"
    ExitApp
}
