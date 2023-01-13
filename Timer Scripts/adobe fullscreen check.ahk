#SingleInstance force
#Requires AutoHotkey v2.0
ListLines(0)
KeyHistory(0)

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\winget>
#Include <Classes\timer>
#Include <Functions\errorLog>
; }

SetWorkingDir A_ScriptDir
TraySetIcon(ptf.Icons "\fullscreen.ico") ;changes the icon this script uses in the taskbar
InstallKeybdHook

GroupAdd("adobe", editors.Premiere.winTitle)
GroupAdd("adobe", editors.AE.winTitle)
;GroupAdd("adobe", editors.Photoshop.winTitle) ;photoshop changes it's window title to the name of the file you're working on and omits "Adobe Photoshop [A_Year]" unlike premiere and ae. Typical

/*
There are sometimes where Premiere Pro will put itself in an even more "fullscreen" mode when you lose access to the window controls and all your coordinates get messed up.
This scrip is to quickly detect and correct that.
I've learnt that it happens when you press ctrl + \
I have \ set in premiere to "Move playhead to cursor" and use it in `right click premiere.ahk` so if a save was being attempted as I was moving the playhead it would occur.
*/

;//enter your desired frequency in SECONDS in `fire_frequency` then leave `fire` as it is. By default you will see this script checks every 2s
fire_frequency := IniRead(ptf["settings"], "Adjust", "adobe FS", 5)
fire := fire_frequency * 1000

;// initialise timer
adobeCheck := adobeTimer(fire)
start:
if WinExist("ahk_group adobe")
    adobeCheck.start()
else
    {
        WinWait("ahk_group adobe")
        goto start
    }

class adobeTimer extends count {

    Tick() {
        ++this.count
        this.check()
    }

    check()
    {
        if !WinActive("ahk_group adobe")
            {
                SetTimer(this.timer, -fire) ;if premiere isn't currently active when it gets to this check, it will wait 2s before checking again
                return
            }
        title := WinGetTitle("A")
        if InStr(title, "Adobe Premiere Pro")
            year := "20" ptf.PremYearVer
        else if InStr(title, "Adobe After Effects")
            year := "20" ptf.AEYearVer
        else
            year := A_Year
        if year = ""
            return
        end := InStr(title, year,, 1, 1) - 1
        getProgram := SubStr(title, 7, end - 7)
        titlecheck := InStr(title, "Adobe " getProgram A_Space year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
        if !titlecheck
            {
                SetTimer(this.timer, -fire) ;adds 2s to the timer and will check again after that time has elapsed
                return
            }
        if A_TimeIdleKeyboard > 1250 ;ensures this script doesn't try to fire while a hotkey is being used
            {
                if !winget.isFullscreen(&title)
                    WinMaximize(title)
                SetTimer(this.timer, -fire) ;adds 2s to the timer and will check again after that time has elapsed
                return
            }
        if !winget.isFullscreen(&title)
            {
                fireRound := Round(fire/1000, 1)
                errorLog(Error("Couldn't reset the fullscreen of " getProgram " because the user was interacting with the keyboard", -1)
                            , "It will attempt again in " fireRound "s", {time: 2.0})
            }
        SetTimer(this.timer, -fire) ;adds 2s to the timer and will check again after that time has elapsed
    }
}

;// defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        adobeCheck.Stop()
}