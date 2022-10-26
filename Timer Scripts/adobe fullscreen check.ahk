#SingleInstance force
SetWorkingDir A_ScriptDir
TraySetIcon("..\Support Files\Icons\fullscreen.ico") ;changes the icon this script uses in the taskbar
#Include FuncRedirect.ahk
InstallKeybdHook
#Requires AutoHotkey v2.0-beta.12

GroupAdd("adobe", "ahk_exe Adobe Premiere Pro.exe")
GroupAdd("adobe", "ahk_exe AfterFX.exe")
;GroupAdd("adobe", "ahk_exe Photoshop.exe") ;photoshop changes it's window title to the name of the file you're working on and omits "Adobe Photoshop [A_Year]" unlike premiere and ae. Typical

/*
There are sometimes where Premiere Pro will put itself in an even more "fullscreen" mode when you lose access to the window controls and all your coordinates get messed up.
This scrip is to quickly detect and correct that.
I've learnt that it happens when you press ctrl + \
I have \ set in premiere to "Move playhead to cursor" and use it in `right click premiere.ahk` so if a save was being attempted as I was moving the playhead it would occur.
*/

;//enter your desired frequency in SECONDS in `fire_frequency` then leave `fire` as it is. By default you will see this script checks every 5s
fire_frequency := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "adobe FS", 5)
global fire := fire_frequency * 1000

start:
if WinExist("ahk_group adobe")
    SetTimer(check, -1000 -fire)
else
    {
        WinWait("ahk_group adobe")
        goto start
    }

check()
{
    if !WinActive("ahk_group adobe")
        SetTimer(, -fire) ;if premiere isn't currently active when it gets to this check, it will wait 5s before checking again
    else
        {
            title := WinGetTitle("A")
            end := InStr(title, A_Year,, 1, 1) - 1
            getProgram := SubStr(title, 7, end - 7)
            ;tool.Cust(getProgram)
            titlecheck := InStr(title, "Adobe " getProgram A_Space A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            ;tool.Cust(title) ;debugging
            ;if title = "" || title = "Audio Gain" || title = "Save As" || InStr(title, "Encoding") || title = "New Project" || title = "Please select the destination path for your new project." || title = "Select Folder" || title = "Clip Speed / Duration" || title = "Modify Clip" ;// just some of the titles you can come across
            if !titlecheck
                SetTimer(, -fire) ;adds 5s to the timer and will check again after that time has elapsed
            else
                {
                    if A_TimeIdleKeyboard > 1250 ;ensures this script doesn't try to fire while a hotkey is being used
                        {
                            isFullscreen(&title, &full)
                            if full = 0
                                WinMaximize(title)
                            SetTimer(, -fire) ;adds 5s to the timer and will check again after that time has elapsed
                        }
                    else
                        {
                            isFullscreen(&title, &full)
                            if full = 0
                                {
                                    fireRound := Round(fire/1000, 1)
                                    tool.Cust(A_ScriptName " attempted to reset the fullscreen of " getProgram " but was reset due to interactions with a keyboard`nIt will attempt again in " fireRound "s", 2000)
                                    errorLog(A_ScriptName, "attempted to reset the fullscreen of " getProgram " but was reset due to interactions with a keyboard", A_LineFile, A_LineNumber)
                                }
                            SetTimer(, -fire) ;adds 5s to the timer and will check again after that time has elapsed
                        }
                }
        }
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || "Close" || "Reload" || "Error"
        {
            SetTimer(check, 0)
        }
}