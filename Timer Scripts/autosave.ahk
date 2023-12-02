/************************************************************************
 * @description a script to handle autosaving Premiere Pro & After Effects without requiring user interaction
 * @author tomshi
 * @date 2023/12/02
 * @version 2.1.0.1
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\Settings>
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\Editors\Premiere>
#Include <Classes\switchTo>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\winget>
#Include <Classes\WM>
#Include <Classes\timer>
#Include <Classes\errorLog>
#Include <Functions\trayShortcut>
#Include <Functions\checkStuck>
#Include <Functions\detect>
; }

#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0
#WinActivateForce

ListLines(0)
; KeyHistory(0) ;// this has to be enabled for some code relating to `mouse idle` to work
InstallKeybdHook() ;required so A_TimeIdleKeyboard works and doesn't default back to A_TimeIdle
InstallMouseHook()

TraySetIcon(ptf.Icons "\save.ico") ;changes the icon this script uses in the taskbar
startupTray()

class adobeAutoSave extends count {
    __New() {
        try {
            ;// attempt to grab user settings
            this.UserSettings := UserPref()
            this.ms := (this.UserSettings.autosave_MIN * 60000)
            this.beep := this.UserSettings.autosave_beep
            this.checkMouse := this.UserSettings.autosave_check_mouse
            this.saveOverride := this.UserSettings.autosave_save_override
            this.UserSettings := ""
        }

        ;// initialise timer
        super.__New(this.ms)

        ;// start the timer
        super.start()

        if this.saveOverride == true
            PremHotkeys.__HotkeySet(["^s"], ObjBindMethod(this, '__saveReset'), "I2")
    }

    ;// Class Variables
    UserSettings  := unset
    ms            := (5*60000) ;// 5min
    saveOverride  := true

    origWindow    := ""

    premExist     := false
    aeExist       := false

    userPlayback  := false
    filesBackedUp := false

    premWindow    := unset
    aeWindow      := unset

    idleAttempt   := false

    beep          := true
    checkMouse    := true
    soundName     := ""
    currentVolume := ""
    resetingSave  := false

    programMonX1  := A_ScreenWidth / 2
    programMonX2  := A_ScreenWidth
    programMonY1  := 0
    programMonY2  := A_ScreenHeight

    __saveReset(*) {
        if !WinActive(prem.winTitle) && !WinActive(AE.winTitle) {
            SendInput("^s")
            return
        }
        this.resetingSave := true
        SendInput("^s")
        ;// maybe don't backup files everytime save is pressed... can cause quite large backup folders for long projects
        ; this.__backupFiles()
        super.Stop()
        sleep 3500
        this.__reset()
        super.Start()
    }

    /** This function handles changing the timer frequency when the user adjusts it within `settingsGUI()` */
    __changeVar(val) {
        try {
            super.stop()
            this.interval := (val*60000)
            super.start()
            return
        }
    }

    /** determine whether premiere/ae is open */
    __checkforEditors() {
        this.premExist := WinExist(prem.winTitle) ? true : false
        this.aeExist   := WinExist(AE.winTitle)   ? true : false
    }

    /** handles retrieving the users current sound device, then playing a beep at 50% of its current volume then returning sound back to normal. */
    __playBeep() {
        if (this.soundName = "" || this.currentVolume = "") {
            this.soundName := SoundGetName(), this.currentVolume := SoundGetVolume()
        }
        SoundSetVolume(Round(this.currentVolume/2),, this.soundName)
        SoundBeep(400, 200)
        SoundSetVolume(this.currentVolume,, this.soundName)
    }

    /** check whether the user has recently interacted with their computer */
    __checkIdle() {
        if this.idleAttempt = true
            return
        loop 5 {
            if this.resetingSave = true
                break
            ;// if the user has interacted with the keyboard recently
            ;// or the last pressed key is LButton, RButton or \ & they have interacted with the mouse recently
            ;// the save attempt will be paused and retried
            if (A_TimeIdleKeyboard <= 500)
                || (this.checkMouse = true && ((A_PriorKey = "LButton" || A_PriorKey = "RButton" || A_PriorKey = "\") && A_TimeIdleMouse <= 500))
                || GetKeyState("RButton", "P") {
                if A_Index > 1
                    this.__playBeep()
                errorLog(Error(A_ScriptName " tried to save but you interacted with the keyboard/mouse in the last 0.5s`nautosave will try again in 2.5s"),, {time: 2.0})
                sleep 2500
                continue
            }
            this.idleAttempt := true
            break
        }
    }

    /** @returns {Boolean} true/false on whether it can grab the active window */
    __getOrigWindow() {
        try{
            this.origWindow := winget.ID()
            return true
        } catch {
            errorLog(TargetError("Unable to determine the active window"),, 1)
            return false
        }
    }

    /** backs up all project files in the working directory */
    __backupFiles() {
        if this.filesBackedUp = true
            return
        try {
            time := Format("{}-{}-{}", A_Hour, A_Min, A_Sec)
            path := WinGet.ProjPath()
            if !DirExist(path.Dir "\Backup\" A_YYYY "_" A_MM "_" A_DD)
                DirCreate(path.Dir "\Backup\" A_YYYY "_" A_MM "_" A_DD)
            loop files path.Dir "\*.*", "F" {
                if A_LoopFileExt != "prproj" && A_LoopFileExt != "aep"
                    continue
                FileCopy(A_LoopFileFullPath, path.Dir "\Backup\" A_YYYY "_" A_MM "_" A_DD "\*_" time ".*", 1)
            }
            if FileExist(path.Dir "\checklist_logs.txt")
                FileCopy(path.Dir "\checklist_logs.txt", path.Dir "\Backup\" A_YYYY "_" A_MM "_" A_DD "\*_" time ".*", 1)
            if FileExist(path.Dir "\checklist.ini")
                FileCopy(path.Dir "\checklist.ini", path.Dir "\Backup\" A_YYYY "_" A_MM "_" A_DD "\*_" time ".*", 1)
            this.filesBackedUp := true
        }
    }

    /**
     * Attempts to check whether the user was playing back on the timeline within Premiere.
     * *note: this function will only work if the user has their program monitor on their main display*
     */
    __checkPremPlayback() {
        ;// if you don't have your project monitor on your main computer monitor this section of code will always fail
        if !ImageSearch(&x, &y, this.programMonX1, this.programMonY1, this.programMonX2, this.programMonY2, "*2 " ptf.Premiere "stop.png")
            return

        tool.Cust("If you were playing back anything, this function should resume it", 2.0,, 30, 2)
        this.userPlayback := true
    }

    /** this function will double check to see if playback has resumed */
    __checkPlayback() {
        loop 3 {
            ;// if you don't have your project monitor on your main computer monitor this section of code will always fail
            if !ImageSearch(&x, &y, this.programMonX1, this.programMonY1, this.programMonX2, this.programMonY2, "*2 " ptf.Premiere "stop.png") {
                prem.__checkTimelineFocus()
                sleep 250
                SendEvent(KSA.playStop)
                continue
            }
            return
        }
    }

    /**
     * Check for a window containing a class used by windows to denote that a file select/dir select GUI is open (ie. a save window)
     * @param {String} which denotes which application exe to check for. Defaults to `Adobe Premiere Pro` - After Effects would be `AfterFX`
     * @returns {Boolean} true if the window **doesn't** exist or false if it does
     */
    __checkDialogueClass(which := "Adobe Premiere Pro") {
        if WinExist("ahk_class #32770 ahk_exe " which ".exe") {
            return false
        }
        return true
    }

    /** This function is fallback code for if `My Scripts.ahk` isn't currently open and autosave can't ask it for timeline coords */
    __fallback() {
        if !prem.__checkTimeline()
            return
        sleep 100
        prem.__checkTimelineFocus()
        sleep 250
        SendEvent(KSA.playStop)
        this.__checkPlayback()
        prem.__checkTimelineFocus()
    }

    /** Attempts to reactivate the originally active window. If the original window is Premiere, it will attempt to resume playback if necessary */
    __reactivateWindow() {
        try {
            checkActive := WinGet.ID()
            if this.origWindow = checkActive && this.userPlayback = false
                return
            switch this.origWindow {
                case "ahk_class CabinetWClass": WinActivate("ahk_class CabinetWClass")
                case "Adobe Premiere Pro.exe":
                    if !WinActive(prem.winTitle)
                        switchTo.Premiere()
                    if this.userPlayback = false
                        return
                    ;// if the user was originally playing back on the timeline
                    ;// we resume that playback here
                    try {
                        detect()
                        if !prem.__checkTimelineValues() {
                            if !WinExist(ptf.MainScriptName ".ahk") {
                                this.__fallback()
                                return
                            }
                            WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, ptf.MainScriptName ".ahk")
                            if !prem.__waitForTimeline() {
                                this.__fallback()
                                return
                            }
                        }
                        this.__fallback()
                    }
                default: WinActivate("ahk_exe " this.origWind)
            }
        } catch {
            errorLog(TargetError("Couldn't determine the active window"),, 1)
            return
        }
    }

    /** saves premiere */
    __savePrem() {

        ;// backing up project files
        this.__backupFiles()

        ;// checking for save dialogue box
        if !this.__checkDialogueClass()
            return

        ;// getting window title/information
        this.premWindow := WinGet.PremName()
        if !this.premWindow || Type(this.premWindow) != "Object" ||
            ((this.premWindow.winTitle = "" || !this.premWindow.wintitle) &&
            this.premWindow.titleCheck = -1 && this.premWindow.saveCheck = -1) {
            errorLog(UnsetError("autosave.ahk was unable to determine the title of the Premiere Pro window"), "The user may not have the correct year set within the settings", 1)
            return
        }

        ;// if save NOT required, exit early
        if !this.premWindow.saveCheck {
            tool.Cust("Premiere save not required, cancelling")
            return
        }

        ;// this should cover occurrences where another window is open within premiere
        if (currentProg := WinGet.ID() = prem.winTitle && ((name := WinGetTitle("A")) != "" && name != this.premWindow.wintitle)) {
            errorLog(TargetError("Premiere is potentially busy and the save attempt was aborted", -1),, 1)
            return
        }

        ;// checking idle status
        this.__checkIdle()
        if this.idleAttempt = false
            return

        ;// checking if prem is the originally active window
        if this.origWindow = "Adobe Premiere Pro.exe"
            this.__checkPremPlayback()

        try {
            block.On()
            ;// attempt to send save
            if GetKeyState("Shift") || GetKeyState("Shift", "P")
                SendInput("{Shift Up}")
            ;// if the user manually saves inbetween grabbing the title and this timer attempting to save
            ;// this part will throw if it's not inside a try block
            ControlSend("{Ctrl Down}{s Down}{s Up}{Ctrl Up}",, this.premWindow.wintitle)
        } catch {
            block.Off()
            return
        }

        ;// waiting for save dialogue to open & close
        if !WinWait("Save Project",, 3) {
            block.Off()
            return
        }
        if !WinWaitClose("Save Project",, 3) {
            block.Off()
            return
        }
    }

    /** saves after effects */
    __saveAE() {

        ;// backing up project files
        this.__backupFiles()

        ;// checking for save dialogue box
        if !this.__checkDialogueClass("AfterFX")
            return

        ;// checking idle status
        this.__checkIdle()
        if this.idleAttempt = false
            return

        ;// if AE is the active window, a normal save will be fine
        if this.origWindow = WinGetProcessName(editors.AE.winTitle) {
            SendEvent("^s")
            if !WinWait("Save Project",, 3)
                return
            if !WinWaitClose("Save Project",, 3)
                return
            sleep 200
            return
        }

        ;// if AE ISN'T the active window, attempting to save it in the background will force it into the foreground which can be super disorienting/annoying
        ;// so we have to work around that

        ;// getting window title/information
        this.aeWindow := WinGet.AEName()
        if !this.aeWindow || Type(this.aeWindow) != "Object" ||
            ((this.aeWindow.winTitle = "" || !this.aeWindow.wintitle) &&
            this.aeWindow.titleCheck = -1 && this.aeWindow.saveCheck = -1) {
            errorLog(UnsetError("autosave.ahk was unable to determine the title of the After Effects window"), "The user may not have the correct year set within the settings", 1)
            return
        }

        ;// if save NOT required, exit early
        if !this.aeWindow.saveCheck {
            tool.Cust("AE save not required, cancelling")
            return
        }

        WinSetTransparent(0, editors.AE.winTitle)
        try {
            ;// attempt to send save
            if GetKeyState("Shift") || GetKeyState("Shift", "P")
                SendInput("{Shift Up}")
            ;// if the user manually saves inbetween grabbing the title and this timer attempting to save
            ;// this part will throw if it's not inside a try block
            ControlSend("{Ctrl Down}s{Ctrl Up}",, this.aeWindow.winTitle)
        } catch {
            WinMoveBottom(editors.AE.winTitle)
            WinSetTransparent("Off", editors.AE.winTitle)
            return
        }
        if WinWait("Save As",, 3) {
            ControlSend("{Esc}",, "Save As " editors.AE.winTitle)
        }
        if !WinWaitClose("Save Project",, 3)
            return
        ;// maybe need to force switch back to original window here?
        try {
            WinMoveBottom(editors.AE.winTitle)
            WinSetTransparent("Off", editors.AE.winTitle)
        }
    }

    /** checks to see if the script the user has defined as their main script is running */
    __checkMainScript() {
        detect()
        if WinExist(ptf.MainScriptName ".ahk")
            return true
        return false
    }

    /** attempts to check if `Premiere_RightClick.ahk` is active */
    __checkRClick() {
        if this.__checkMainScript() {
            WM.Send_WM_COPYDATA("Premiere_RightClick," A_ScriptName, ptf.MainScriptName ".ahk")
            if prem.RClickIsActive = true
                return true
        }
        return false
    }

    /** This function begins the saving process */
    begin() {
        ;// check for prem/ae
        this.__checkforEditors()
        if this.premExist = false && this.aeExist = false
            return

        ;// begin blocking user inputs
        block.On("SendAndMouse")

        ;// this script will attempt to NOT fire if Premiere_RightClick.ahk is active
        if this.__checkRClick() = true {
            this.__reset()
            return
        }

        ;// grab originally active window
        if !this.__getOrigWindow() {
            this.__reset()
            return
        }

        ;// save prem
        if this.premExist = true
            this.__savePrem()

        ;// save ae
        if this.aeExist = true
            this.__saveAE()
    }

    /** resets all internal variables */
    __reset() {
        this.count         := 0,     this.origWindow    := "",
        this.premExist     := false, this.aeExist       := false,
        this.userPlayback  := false, this.filesBackedUp := false

        this.premWindow    := unset
        this.aeWindow      := unset
        this.idleAttempt   := false

        this.soundName     := "",    this.currentVolume := "",
        this.resetingSave  := false
        checkstuck()
        block.Off()
    }

    /** This function is called every increment */
    Tick() {
        ;// start the saving process
        this.begin()

        ;// if the above function got to the point that it was able to determine an active window and has been set
        ;// attempt to reactivate it
        if this.origWindow != ""
            this.__reactivateWindow()

        ;// finish up
        this.__reset()
        block.Off()
    }

    /** stops the timer */
    Stop() => super.stop()

    __Delete() {
        try {
            super.stop()
        }
        checkstuck()
        PremHotkeys.__HotkeyReset(["^s"])
        block.Off()
    }
}

;// initialising the timer
autoSave := adobeAutoSave()

;// this is required to allow the script to have its timer adjusted with `settingsGUI()`
changeInterval := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, changeInterval.Bind())  ; 0x004A is WM_COPYDATA

;// defining exit func
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    if (ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error") {
        try {
            autoSave.stop()
        }
        checkstuck()
        PremHotkeys.__HotkeyReset(["^s"])
        block.Off()
    }
}