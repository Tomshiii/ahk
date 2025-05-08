/************************************************************************
 * @description a script to handle autosaving Premiere Pro & After Effects without requiring user interaction
 * @author tomshi
 * @date 2025/05/08
 * @version 2.1.34
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\Settings>
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\Editors\Premiere>
#Include <Classes\Editors\Premiere_UIA>
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
#Include <Other\Notify\Notify>
#Include <Other\WinEvent>
; }

#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0
#WinActivateForce

ListLines(0)
; KeyHistory(0) ;// KeyHistory must not be disabled for some code relating to `mouse idle` to work
InstallKeybdHook() ;required so A_TimeIdleKeyboard works and doesn't default back to A_TimeIdle
;InstallMouseHook() ;// this is set within the function, no idea why but it needs to happen in the func or it just... doesn't work
TraySetIcon(ptf.Icons "\save.ico") ;changes the icon this script uses in the taskbar
startupTray()

;// initialising the timer
autoSave := adobeAutoSave()

;// this is required to allow the script to have its timer adjusted with `settingsGUI()`
changeInterval := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, changeInterval.Bind())  ; 0x004A is WM_COPYDATA

;// defining exit func
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    try {
        WinEvent.Stop()
        autoSave.stop()
    }
    checkstuck()
    block.Off()
}

/**
     * @param {String} [rClickPrem=RButton] what the user has `rbuttonPrem().movePlayhead()` bound to
     * @param {String} [rClickMove=XButton1] what the user has `rbuttonPrem().movePlayhead(false)` bound to
     * it is recommended to have both of these set to a key as passing nothing will throw an error
     */
class adobeAutoSave extends count {

    __New(rClickPrem := "RButton", rClickMove := "XButton1") {
        try {
            this.premUIA := premUIA_Values()
            ;// attempt to grab user settings
            this.UserSettings := UserPref()
            this.ms   := (this.UserSettings.autosave_MIN * 60000)
            this.beep := this.UserSettings.autosave_beep
            this.checkMouse      := this.UserSettings.autosave_check_mouse
            this.saveOverride    := this.UserSettings.autosave_save_override
            this.alwaysSave      := this.UserSettings.autosave_always_save
            this.restartPlayback := this.UserSettings.autosave_restart_playback
            this.mainScript      := this.UserSettings.MainScriptName
            this.UserSettings    := ""
        }

        ;// set variables for some user hotkeys
        this.rClickPrem := rClickPrem, this.rClickMove := rClickMove

        ;// initialise timer
        super.__New(this.ms)

        ;// start the timer
        this.start()
    }

    premUIA := false

    ;// Class Variables
    UserSettings  := unset
    ms            := (5*60000) ;// 5min by default
    saveOverride  := true
    origWindow    := ""

    premExist     := false,  aeExist := false
    premWindow    := unset
    aeWindow      := unset

    userPlayback  := false
    filesBackedUp := false
    idleAttempt   := false
    beep          := true
    checkMouse    := true
    alwaysSave    := true
    soundName     := ""
    currentVolume := ""
    resetingSave  := false
    mainScript    := "My Scripts"
    restartPlayback := false

    rClickPrem    := ""
    rClickMove    := ""
    movePlayhead  := InStr(ksa.playheadtoCursor, "{") && InStr(ksa.playheadtoCursor, "}") ? LTrim(RTrim(ksa.playheadtoCursor, "}"), "{")
                                                                                          : ksa.playheadtoCursor

    programMonX1  := false,  programMonX2 := false
    programMonY1  := false,  programMonY2 := false

    origPanelFocus := ""
    premUIAEl      := false

    /** This function is called every increment */
    Tick() {
        ;// start the saving process
        this.begin()

        ;// if the above function got to the point that it was able to determine an active window and has been set
        ;// attempt to reactivate it
        if this.origWindow != ""
            this.__reactivateWindow()

        ;// finish up
        if this.aeExist = true {
            try aeTrans := WinGetTransColor(editors.AE.winTitle)
            catch {
                this.__reset()
                block.Off()
                return
            }
            if IsInteger(aeTrans) && aeTrans != 255
                this.__resetAETrans()
        }
        this.__reset()
        block.Off()
    }

    /** stops the timer */
    Stop() {
        try {
            super.stop()
            WinEvent.Stop()
        }
        checkstuck()
        block.Off()
    }

    /** starts the timer */
    Start() {
        if this.saveOverride == true {
            try WinEvent.Exist(this.__stopAndReset.Bind(this), "Save Project " prem.exeTitle)
            catch {
                SetTimer((*) => tool.Cust("Attempting to start lib ``WinEvent`` failed.`nA reload may be required for proper functionality."), -1)
            }
        }
        super.start()
    }

    /** This function begins the saving process */
    begin() {
        ;// check for prem/ae
        this.__checkforEditors()
        if this.premExist = false && this.aeExist = false
            return

        ;// begin blocking user inputs
        block.On("SendAndMouse")

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

    __stopAndReset(*) {
        if !WinActive(prem.winTitle) && !WinActive(AE.winTitle) {
            return
        }
        this.Stop()
        this.resetingSave := true, this.idleAttempt := true
        ; sleep 5000
        SetTimer((*) => (this.__reset(), this.Start()), -4500)
    }

    /** This function handles changing the timer frequency when the user adjusts it within `settingsGUI()` */
    __changeVar(val) {
        try {
            this.stop()
            this.interval := (val*60000)
            this.start()
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
            if this.resetingSave = true || WinExist("Save Project") {
                this.resetingSave := true
                break
            }
            ;// if the user has interacted with the keyboard recently
            ;// or the last pressed key is LButton, RButton or \ & they have interacted with the mouse recently
            ;// the save attempt will be paused and retried
            if (A_TimeIdleKeyboard <= 500)
                || (this.checkMouse = true && ((A_PriorKey = "LButton" || A_PriorKey = "RButton" || A_PriorKey = this.movePlayhead) && A_TimeIdleMouse <= 500))
                || this.__checkRClick() {
                if A_Index > 1 && this.beep = true
                    this.__playBeep()
                errorLog(Error(A_ScriptName " tried to save but you interacted with the keyboard/mouse in the last 0.5s autosave will try again in 2.5s"),, {time: 2.0})
                sleep 2500
                continue
            }
            this.idleAttempt := true
            break
        }
        if this.resetingSave = true
            return false
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
        if !this.programMonX1 && !this.programMonX2 && !this.programMonY1 && !this.programMonY2 {
            if !progMon := prem.__uiaCtrlPos(this.premUIA.programMon,,, false)
                return false
            this.programMonX1 := progMon.x+100, this.programMonX2 := progMon.x + progMon.width-100, this.programMonY1 := (progMon.y+progMon.height)*0.7,  this.programMonY2 := progMon.y + progMon.height + 150
        }
        ;// if you don't have your project monitor on your main computer monitor this section of code will always fail
        if !ImageSearch(&x, &y, this.programMonX1, this.programMonY1, this.programMonX2, this.programMonY2, "*2 " ptf.Premiere "stop.png")
            return
        Notify.Show(, 'If you were playing back anything, this function should attempt to resume it', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75AEDC')
        ; tool.Cust("If you were playing back anything, this function should resume it", 2.0,, 30, 2)
        this.userPlayback := true
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

    /**
     * This function is fallback code for if `My Scripts.ahk` isn't currently open and autosave can't ask it for timeline coords
     * @param {Boolean} needFocus pass into the function whether it needs to initially check for timeline focus. This is usually done by checking the original active panel against the user's saved UIA timeline value. If they match, pass `false` into this function
     */
    __fallback(needFocus := true) {
        if !prem.__checkTimeline()
            return
        sleep 100
        if needFocus = true {
            prem.__checkTimelineFocus()
            sleep 250
        }
        SendEvent(KSA.playStop)
        sleep 2000
        loop 3 {
            ;// if you don't have your project monitor on your main computer monitor this section of code will always fail
            if !ImageSearch(&x, &y, this.programMonX1, this.programMonY2/2, this.programMonX2, this.programMonY2, "*2 " ptf.Premiere "stop.png") {
                prem.__checkTimelineFocus()
                sleep 1500
                SendEvent(KSA.playStop)
                continue
            }
            return
        }
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
                case "Adobe After Effects.exe", "Adobe After Effects (Beta).exe": switchTo.AE()
                case "Adobe Premiere Pro.exe", "Adobe Premiere Pro (Beta).exe":
                    if !WinActive(prem.winTitle)
                        switchTo.Premiere()
                    if this.restartPlayback = false || this.userPlayback = false
                        return
                    ;// if the user was originally playing back on the timeline
                    ;// we resume that playback here
                    try this.premUIAEl.AdobeEl.ElementFromPath(this.premUIA.timeline).SetFocus()
                    catch {
                        try {
                            fallbackFocus := (this.origPanelFocus = this.premUIA.timeline) ? false : true
                            detect()
                            if !prem.__checkTimelineValues() {
                                if !WinExist(this.mainScript ".ahk") {
                                    this.__fallback(fallbackFocus)
                                    return
                                }
                                WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, this.mainScript ".ahk")
                                if fallbackFocus = true && !prem.__waitForTimeline() {
                                    this.__fallback(fallbackFocus)
                                    return
                                }
                            }
                            this.__fallback(fallbackFocus)
                        }
                    }
                    sleep 100
                    SendEvent(KSA.playStop)
                    sleep 1000
                    loop 3 {
                        ;// if you don't have your project monitor on your main computer monitor this section of code will always fail
                        if !ImageSearch(&x, &y, this.programMonX1, this.programMonY2/2, this.programMonX2, this.programMonY2, "*2 " ptf.Premiere "stop.png") {
                            try this.premUIAEl.AdobeEl.ElementFromPath(this.premUIA.timeline).SetFocus()
                            sleep 100
                            SendEvent(KSA.playStop)
                            continue
                        }
                        break
                    }
                    try this.premUIAEl.AdobeEl.ElementFromPath(this.premUIA.timeline).SetFocus()
                default: WinActivate("ahk_exe " this.origWindow)
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

        if this.alwaysSave = false && !WinActive(prem.winTitle)
            return

        ;// checking for save dialogue box
        if !this.__checkDialogueClass() {
            Notify.Show(, 'Premiere appears to be busy, cancelling save attempt...', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            return
        }

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
            Notify.Show(, 'Premiere save not required, cancelling...', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            ; tool.Cust("Premiere save not required, cancelling")
            return
        }

        ;// this should cover occurrences where another window is open within premiere
        if (currentProg := WinGet.ID() = prem.winTitle && ((name := WinGetTitle("A")) != "" && name != this.premWindow.wintitle)) {
            errorLog(TargetError("Premiere is potentially busy and the save attempt was aborted", -1),, 1)
            return
        }

        ;// get active UIA panel
        if WinActive(prem.winTitle) {
            try {
                this.premUIAEl := prem.__createUIAelement()
                this.origPanelFocus := this.premUIAEl.activeElement
            }
        }

        ;// checking idle status
        checkIdle := this.__checkIdle()
        if (this.idleAttempt = false || checkIdle = false || this.resetingSave = true)
            return

        ;// checking if prem is the originally active window
        if (this.origWindow = "Adobe Premiere Pro.exe" || this.origWindow = "Adobe Premiere Pro (Beta).exe") && this.restartPlayback = true
            this.__checkPremPlayback()

        Notify.Show(, 'A save attempt is being made...`nInputs may be temporarily blocked', 'C:\Windows\System32\shell32.dll|icon259',,, 'dur=4 show=Fade@250 hide=Fade@250 maxW=400 bdr=0xDCCC75')
        ; tool.Cust("A save attempt is being made`nInputs may be temporarily blocked", 1.5,, -25, 7)

        ;// attempts to save using `PremiereRemote`
        saveAttempt := prem.save()
        if (saveAttempt = true || saveAttempt = "timeout") {
            sleep 500
            return
        }

        try {
            block.On()

            ;// this script will attempt to NOT fire if Premiere_RightClick.ahk is active
            if this.__checkRClick() = true {
                throw
            }

            ;// attempt to send save
            if GetKeyState("Shift") || GetKeyState("Shift", "P")
                SendInput("{Shift Up}")
            if !WinActive(prem.winTitle)
                switchTo.Premiere()
            sleep 25
            ;// if the user manually saves inbetween grabbing the title and this timer attempting to save
            ;// this part will throw if it's not inside a try block
            ControlSend("{Ctrl Down}{s}",, this.premWindow.wintitle)
            sleep 50
            ControlSend("{Ctrl Up}",, this.premWindow.wintitle)
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

        if this.alwaysSave = false && !WinActive(ae.winTitle)
            return

        ;// checking for save dialogue box
        if !this.__checkDialogueClass("AfterFX") {
            Notify.Show(, 'AE appears to be busy, cancelling save attempt...', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            return
        }

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
            Notify.Show(, 'AE save not required, cancelling...', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            ; tool.Cust("AE save not required, cancelling")
            return
        }

        try {
            WinSetTransparent(0, editors.AE.winTitle)
            ;// attempt to send save
            if GetKeyState("Shift") || GetKeyState("Shift", "P")
                SendInput("{Shift Up}")
            ;// if the user manually saves inbetween grabbing the title and this timer attempting to save
            ;// this part will throw if it's not inside a try block
            ControlSend("{Ctrl Down}s{Ctrl Up}",, this.aeWindow.winTitle)
        } catch {
            this.__resetAETrans()
            return
        }
        if WinWait("Save As",, 3) {
            ControlSend("{Esc}",, "Save As " editors.AE.winTitle)
        }
        if !WinWaitClose("Save Project",, 3) {
            this.__resetAETrans()
            return
        }
        this.__resetAETrans()
    }

    /** checks to see if the script the user has defined as their main script is running */
    __checkMainScript() {
        detect()
        if WinExist(this.mainScript ".ahk")
            return true
        return false
    }

    /** reset after effects window transparency */
    __resetAETrans() {
        try {
            WinMoveBottom(editors.AE.winTitle)
            WinSetTransparent("Off", editors.AE.winTitle)
        }
    }

    /** attempts to check if `Premiere_RightClick.ahk` is active */
    __checkRClick() {
        InstallMouseHook(1)
        if this.__checkMainScript() {
            WM.Send_WM_COPYDATA("Premiere_RightClick," A_ScriptName, this.mainScript ".ahk")
            if prem.RClickIsActive = true || GetKeyState(this.rClickPrem, "P") = true || GetKeyState(this.movePlayhead) = true || GetKeyState(this.rClickMove, "P") = true
                return true
        }
        return false
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

        this.origPanelFocus := ""
        this.premUIAEl      := false
        checkstuck()
        block.Off()
    }

    __Delete() {
        try {
            super.stop()
            WinEvent.Stop()
        }
        checkstuck()
        block.Off()
    }
}