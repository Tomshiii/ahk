#SingleInstance Force
SetDefaultMouseSpeed 0
#WinActivateForce

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\pause>
#Include <Classes\coord>
; }

;
; This script is designed for Windows 11 and its settings menu. Older win10 compatible scripts can be seen backed up in the Win10 folder
;
firetip() => tool.Cust("Couldn't find firefox")

pause.pause("autosave")
pause.pause("adobe fullscreen check")
coord.s()
MouseGetPos(&sx, &sy)
Run("ms-settings:apps-volume")
WinWait("Settings")
if WinExist("Settings")
    WinActivate()
if WinActive("Settings")
    WinMaximize()
coord.w()
MouseMove(789, 375)
sleep 1000 ;this is necessary otherwise the imagesearches will try to fire before the window even loads
try {
    loop {
        active := WinGetTitle("A")
        if active != "Settings"
            WinActivate("Settings")
        ToolTip("This function searched " A_Index " time(s) to find firefox`nActive window: " active)
        if (
            ImageSearch(&ffX, &ffY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Windows "firefox3.png") ||
            ImageSearch(&ffX, &ffY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Windows "firefox.png") ||
            ImageSearch(&ffX, &ffY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Windows "firefox2.png")
        )
            break
        if A_Index > 5
            {
                ToolTip("")
                firetip()
                pause.pause("autosave")
                pause.pause("adobe fullscreen check")
                return
            }
    }
    MouseMove(ffx, ffy)
    Click()
    sleep 500
    if !ImageSearch(&devX, &devY, ffX, ffY - "30", ffX + 2500, ffY + "30", "*2 " ptf.Windows "default.png")
        {
            SendInput("{Tab 3}")
            sleep 100
            SendInput("{Up 11}")
            sleep 100
           ; SendInput("{Enter}")
        }
} catch as e {
    pause.pause("autosave")
    pause.pause("adobe fullscreen check")
    tool.Cust("Script couldn't activate the Settings Menu")
    return
}
sleep 200
WinClose("Settings")
coord.s()
MouseMove(sx, sy, 2)
pause.pause("autosave")
pause.pause("adobe fullscreen check")
ExitApp()