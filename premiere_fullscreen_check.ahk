#SingleInstance force
SetWorkingDir A_ScriptDir
TraySetIcon(A_WorkingDir "\Support Files\Icons\fullscreen.ico") ;changes the icon this script uses in the taskbar
#Include "Functions.ahk"
InstallKeybdHook

;checks to make sure the user is using a compatible version of ahk
verCheck()

/*
There are sometimes where Premiere Pro will put itself in an even more "fullscreen" mode when you lose access to the window controls and all your coordinates get messed up.
This scrip is to quickly detect and correct that.
Using window spy get your windows normal fullscreen W & H pixel values (NOT the "client:", the top option in the "active window position" box) and put them in the values below. The script should do the rest.
*/
normal_W := 2576
normal_H := 1416
normal := normal_W ", " normal_H

;//enter your desired frequency in SECONDS in `fire_frequency` then leave `fire` as it is. By default you will see this script checks every 10s
fire_frequency := 5
global fire := fire_frequency * 1000

start:
if WinExist("ahk_exe Adobe Premiere Pro.exe")
    SetTimer(check, -1000 -fire)
else
    {
        WinWait("ahk_exe Adobe Premiere Pro.exe")
        goto start
    }

check()
{
    if not WinActive("ahk_exe Adobe Premiere Pro.exe")
        SetTimer(, -fire) ;if premiere isn't currently active when it gets to this check, it will wait 10s before checking again
    else
        {
            title := WinGetTitle("A")
            titlecheck := InStr(title, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            ;toolCust(title) ;debugging
            ;if title = "" || title = "Audio Gain" || title = "Save As" || InStr(title, "Encoding") || title = "New Project" || title = "Please select the destination path for your new project." || title = "Select Folder" || title = "Clip Speed / Duration" || title = "Modify Clip" ;// just some of the titles you can come across
            if not titlecheck
                SetTimer(, -fire) ;adds 10s to the timer and will check again after that time has elapsed
            else
                {
                    if A_TimeIdleKeyboard > 1250 ;ensures this script doesn't try to fire while a hotkey is being used
                        {
                            WinGetPos(,, &width, &height)
                            reference := width ", " height
                            ;MsgBox(reference "`n" normal) ;debugging
                            if reference != normal
                                {
                                    blockOn()
                                    SendInput("!{Space}")
                                    sleep 50
                                    SendInput("x")
                                    blockOff()
                                }
                            SetTimer(, -fire) ;adds 10s to the timer and will check again after that time has elapsed
                        }
                    else
                        {
                            WinGetPos(,, &width, &height)
                            reference := width ", " height
                            if reference != normal
                                {
                                    fire2 := fire/1000
                                    fireRound := Round(fire2, 0)
                                    toolCust(A_ScriptName " attempted to reset the fullscreen of Premiere Pro but was reset due to interactions with a keyboard`nIt will attempt again in " fireRound "s", "2000")
                                    errorLog(A_ScriptName, "attempted to reset the fullscreen of Premiere Pro but was reset due to interactions with a keyboard", A_LineFile, A_LineNumber)
                                }
                            SetTimer(, -fire) ;adds 10s to the timer and will check again after that time has elapsed
                        }
                }
        }
}