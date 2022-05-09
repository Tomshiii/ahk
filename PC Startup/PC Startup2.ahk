;This part 2 exists so that I can run and then hide the streamdeck software without it running anything else as Admin (as that can cause elevation issues with other scripts)
goxlr() {
    Run("C:\Program Files (x86)\TC-Helicon\GOXLR\GoXLR App.exe")
    WinWait("ahk_exe GoXLR App.exe")
    sleep 1000
    WinMinimize("ahk_exe GoXLR App.exe")
    ProcessClose("GoXLR App.exe") ;for whatever reason the goxlr app doesn't grab the streamdeck software on the first load. idk why, just technology things. So we force close it and try again just for good measure
    sleep 1000
    Run("C:\Program Files (x86)\TC-Helicon\GOXLR\GoXLR App.exe")
    WinWait("ahk_exe GoXLR App.exe")
    sleep 1000
    WinMinimize("ahk_exe GoXLR App.exe")
}

If not WinExist("ahk_exe StreamDeck.exe")
    ;Because I need to run the streamdeck exe as admin, it won't auto launch on startup because windows hates that, so I just have it launch through this script to get around that issue
    run '*RunAs "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"'
if WinExist("ahk_exe Creative Cloud.exe")
    WinClose() ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
if WinExist("ahk_exe GoXLR App.exe")
    {
        WinWait("ahk_exe StreamDeck.exe")
        ProcessClose("GoXLR App.exe") ;I need the goxlr software to be opened after the streamdeck software is open so it automatically connects the plugin
        SetTimer(goxlr, -2000)
    }
else
    {
        WinWait("ahk_exe StreamDeck.exe")
        SetTimer(goxlr, -2000)
    }
if WinExist("ahk_exe StreamDeck.exe")
    WinClose() ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
else
    {
        WinWait("ahk_exe StreamDeck.exe")
        WinClose("ahk_exe StreamDeck.exe") ;closing these programs just pushes them into the hidden part of the taskbar, which is what I want
    }
    