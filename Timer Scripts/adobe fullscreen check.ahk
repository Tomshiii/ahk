#SingleInstance force
#Requires AutoHotkey v2.0
ListLines(0)
KeyHistory(0)

; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\winget>
#Include <Classes\timer>
#Include <Classes\WM>
#Include <Classes\Editors\Premiere>
#Include <Classes\errorLog>
#Include <Functions\trayShortcut>
; }

SetWorkingDir(A_ScriptDir)
TraySetIcon(ptf.Icons "\fullscreen.ico") ;changes the icon this script uses in the taskbar
InstallKeybdHook
startupTray()

/*
There are sometimes where Premiere Pro will put itself in an even more "fullscreen" mode when you lose access to the window controls and all your coordinates get messed up.
This script is to quickly detect and correct that.
I've learnt that it happens when you press ctrl + \
I have \ set in premiere to "Move playhead to cursor" and use it in `Premiere_RightClick.ahk` so if a save was being attempted as I was moving the playhead it would occur.
*/

;// initialise timer
adobeCheck := adobeTimer()

;// the below allows the timer to be adjusted by `settingsGUI()`
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

class adobeTimer extends count {
    __New() {
        try {
            ;// open settings instance and start timer
            UserSettings := UserPref()
            fire_frequency := UserSettings.adobe_FS
            this.fire := (fire_frequency * 1000)
            UserSettings := ""
        }

        super.__New(this.fire)
        super.start()
    }

    ;// default timer (attempts to be overridden by the user's settings value)
    fire := 2000

    Tick() => this.check()

    check() {
        if !WinActive(prem.winTitle) && !WinActive(AE.winTitle)
            return
        if WinActive(prem.winTitle)
            this.__fs(WinGet.PremName(), "Premiere Pro")
        if WinActive(AE.winTitle)
            this.__fs(WinGet.AEName(), "After Effects")
    }

    /**
     * This function handles fullscreening the desired program
     * @param {Object} nameObj an object for the desired name containing {titleCheck:, winTitle:} (using `winget.PremName()/winget.AEName()`)
     * @param {String} progName the name of the program so a tooltip can accurately describe the program it was attempting to operate on
     */
    __fs(nameObj, progName) {
        if ((!IsObject(nameObj)             || !nameObj.HasProp("winTitle") ||
            !nameObj.HasProp("titleCheck")) || !nameObj.titleCheck
        )
            return
        if winget.isFullscreen(, nameObj.winTitle) = true
            return
        if A_TimeIdleKeyboard > 1250 {
            detect()
            ;// this script will attempt to NOT fire if RClickPrem is active
            if !WinExist(ptf.MainScriptName ".ahk") {
                WinMaximize(nameObj.winTitle)
                return
            }
            WM.Send_WM_COPYDATA("Premiere_RightClick," A_ScriptName, ptf.MainScriptName ".ahk")
            sleep 50
            if prem.RClickIsActive = false
                WinMaximize(nameObj.winTitle)
            return
        }
        fireRound := Round(this.fire/1000, 1)
        errorLog(Error("Couldn't reset the fullscreen of " progName " because the user was interacting with the keyboard", -1)
        , "It will attempt again in " fireRound "s", {time: 2.0})
        return
    }

    /** This function handles changing the timer frequency when the user adjusts it within `settingsGUI()` */
    __changeVar(val) {
        try {
            super.stop()
            this.interval := (val*1000)
            super.start()
        }
    }

    __Delete() {
        super.stop()
    }
}

;// defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        adobeCheck.Stop()
}