;This part 2 exists so that I can run and then hide the streamdeck software without it running anything else as Admin (as that can cause elevation issues with other scripts)

If not WinExist("ahk_exe StreamDeck.exe")
    ;Because I need to run the streamdeck exe as admin, it won't auto launch on startup because windows hates that, so I just have it launch through this script to get around that issue
    run '*RunAs "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"'
if WinExist("ahk_exe Creative Cloud.exe")
    WinClose() ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
if WinExist("ahk_exe StreamDeck.exe")
    WinClose() ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
else
    {
        WinWait("ahk_exe StreamDeck.exe")
        WinClose("ahk_exe StreamDeck.exe") ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
    }
    