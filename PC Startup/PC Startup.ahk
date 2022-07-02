SetWorkingDir "E:\Github\ahk"
;// This script is included more as a backup for myself and not really because it's helpful.

run A_WorkingDir "\My Scripts.ahk"
run A_WorkingDir "\QMK Keyboard.ahk"
run A_WorkingDir "\Alt_menu_acceleration_DISABLER.ahk"
run A_WorkingDir "\autodismiss error.ahk"
;run A_WorkingDir "\right click premiere.ahk" ;#include(d) in main script now
run A_WorkingDir "\autosave.ahk"
run A_WorkingDir "\premiere_fullscreen_check.ahk"

if not WinExist("ahk_exe Creative Cloud.exe")
    run "C:\Program Files\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe"
If not WinExist("ahk_exe StreamDeck.exe")
    Run("C:\Program Files\Elgato\StreamDeck\StreamDeck.exe")

SetTimer(open, -5000) ;Simply putting a shortcut to these scripts in your startup folder works fine, I just eventually ended up doing it here after testing a few things and now it's just easier oops.
open()
{
    /* run '*RunAs ' A_WorkingDir "\PC Startup\PC Startup2.ahk"
    ExitApp */
    if WinExist("ahk_exe Creative Cloud.exe")
        WinClose() ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
    if WinExist("ahk_exe StreamDeck.exe")
        WinClose("ahk_exe StreamDeck.exe") ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
    else
        {
            WinWait("ahk_exe StreamDeck.exe")
            WinClose("ahk_exe StreamDeck.exe") ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
        }
}