#SingleInstance force
SetWorkingDir A_ScriptDir
TraySetIcon(A_WorkingDir "\Icons\fullscreen.ico") ;changes the icon this script uses in the taskbar
#Include "Functions.ahk"
#Requires AutoHotkey v2.0-beta.3
InstallKeybdHook

/*
There are sometimes where Premiere Pro will put itself in an even more "fullscreen" mode when you lose access to the window controls and all your coordinates get messed up.
This scrip is to quickly detect and correct that.
Using window spy get your windows normal fullscreen W & H pixel values (NOT the "client:", the top option in the "active window position" box) and put them in the values below. The script should do the rest.
*/
normal_W := 2576
normal_H := 1416
normal := normal_W ", " normal_H

;//enter your desired frequency in SECONDS in `fire_frequency` then leave `fire` as it is. By default you will see this script checks every 10s
fire_frequency := 10
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
            ;toolCust(title, "1000") ;debugging
            ;if title = "" || title = "Audio Gain" || title = "Save As" || InStr(title, "Encoding") || title = "New Project" || title = "Please select the destination path for your new project." || title = "Select Folder" || title = "Clip Speed / Duration" || title = "Modify Clip" ;// just some of the titles you can come across
            if not titlecheck
                SetTimer(, -fire) ;adds 10s to the timer and will check again after that time has elapsed
            else
                {
                    if A_TimeIdleKeyboard > 1250 ;ensures this script doesn't try to fire while a hotkey is being used
                        {
                            WinGetPos(,, &width, &height)
                            reference := %&width% ", " %&height%
                            ;MsgBox(reference "`n" normal) ;debugging
                            if reference != normal
                                {
                                    SendInput("!{Space}")
                                    sleep 50
                                    SendInput("x")
                                }
                            SetTimer(, -fire) ;adds 10s to the timer and will check again after that time has elapsed
                        }
                    else
                        SetTimer(, -fire) ;adds 10s to the timer and will check again after that time has elapsed
                }
        }
}