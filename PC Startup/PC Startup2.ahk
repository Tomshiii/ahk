;// PC Startup2 is for me, this is just a few things I need done at startup to make life easier

if !WinExist("ahk_exe Creative Cloud.exe")
    Run("C:\Program Files\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe")
if !WinExist("ahk_exe StreamDeck.exe")
    Run("C:\Program Files\Elgato\StreamDeck\StreamDeck.exe")

SetTimer(open, -5000) ;Simply putting a shortcut to these scripts in your startup folder works fine, I just eventually ended up doing it here after testing a few things and now it's just easier oops.
open()
{
    /* run '*RunAs ' A_WorkingDir "\PC Startup\PC Startup2.ahk"
    ExitApp */
    if WinExist("ahk_exe Creative Cloud.exe")
        WinClose("ahk_exe Creative Cloud.exe") ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
    if WinExist("ahk_exe StreamDeck.exe")
        WinClose("ahk_exe StreamDeck.exe") ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
    else
        {
            WinWait("ahk_exe StreamDeck.exe")
            WinClose("ahk_exe StreamDeck.exe") ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
        }
}