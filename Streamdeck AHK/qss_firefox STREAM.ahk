#SingleInstance Force
SetWorkingDir A_ScriptDir
SetDefaultMouseSpeed 0
#Include SD_functions.ahk
#WinActivateForce

;
; This script is designed for Windows 11 and its settings menu. Older win10 compatible scripts can be seen backed up in the Win10 folder
;
firetip()
{
    ToolTip("couldn't find firefox")
    SetTimer(timeouttime, -1000)
	timeouttime()
	{
		ToolTip("")
	}
}
pauseautosave()
pausewindowmax()
coords()
MouseGetPos(&sx, &sy)
Run("ms-settings:apps-volume")
WinWait("Settings")
if WinExist("Settings")
    WinActivate()
if WinActive("Settings")
    WinMaximize()
coordw()
MouseMove(789, 375)
sleep 1000 ;this is necessary otherwise the imagesearches will try to fire before the window even loads
try {
    loop {
        active := WinGetTitle("A")
        if active != "Settings"
            WinActivate("Settings")
        ToolTip("This function searched " A_Index " time(s) to find firefox`nActive window: " active)
        if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " Windows "firefox3.png")
            break
        else if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " Windows "firefox.png")
           break
        else if ImageSearch(&ffX, &ffY, 8, 8, 2567, 1447, "*2 " Windows "firefox2.png")
            break
        ToolTip("")
        if A_Index > 5
            {
                pauseautosave()
                pausewindowmax()
                firetip()
                return
            }
    }
    MouseMove(%&ffx%, %&ffy%)
    Click()
    sleep 500
    if ImageSearch(&devX, &devY, %&ffX%, %&ffY% - "30", %&ffX% + 2500, %&ffY% + "30", "*2 " Windows "sample.png")
        goto end
    else
        {
            SendInput("{Tab 3}")
            ;sleep 500
            SendInput("{Up 10}")
            sleep 100
            SendInput("{Down 5}")
            sleep 100
            ;SendInput("{Enter}")
        }
} catch as e {
    pauseautosave()
    pausewindowmax()
    toolCust("Script couldn't activate the Settings Menu", "1000")
    return
}
end:
sleep 200
WinClose("Settings")
coords()
MouseMove(%&sx%, %&sy%, 2)
pauseautosave()
pausewindowmax()
ExitApp()