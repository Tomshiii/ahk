;This script by itself will do nothing but shutdown your pc. The reason I have it is so that I can launch it via a streamdeck multi action that also puts my goxlr into a sleep mode that turns off its rgb

if not WinExist("ahk_exe GoXLR App.exe")
    Run("C:\Program Files (x86)\TC-Helicon\GOXLR\GoXLR App.exe")
WinWait("ahk_exe GoXLR App.exe")
value := MsgBox("Are you sure you wish to shutdown?", "Shutdown", "4")
if value = "Yes"
    Shutdown 1
else
    return