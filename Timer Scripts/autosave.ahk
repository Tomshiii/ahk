/************************************************************************
 * @description a script to handle autosaving Premiere Pro & After Effects without requiring user interaction
 * @author tomshi
 * @date 2026/10/20
 * @version 2.3.1
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Settings.ahk
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\ptf.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\Editors\Premiere_UIA.ahk
#Include Classes\switchTo.ahk
#Include Classes\tool.ahk
#Include Classes\block.ahk
#Include Classes\winget.ahk
#Include Classes\WM.ahk
#Include Classes\timer.ahk
#Include Classes\log.ahk
#Include Classes\errorLog.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk
#Include Functions\trayShortcut.ahk
#Include Functions\checkStuck.ahk
#Include Functions\detect.ahk
#Include Functions\isObjHasProp.ahk
#Include Other\Notify\Notify.ahk
#Include Other\HighPrecisionSleep.ahk
#Include Other\Promise.ahk
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
    block.Off()
    try autoSave.stop() ;// also tears down the save override InputHook
    checkstuck()
}

/**
 * @param {String} [rClickPrem=RButton] what the user has `rbuttonPrem().movePlayhead()` bound to
 * @param {String} [rClickMove=XButton1] what the user has `rbuttonPrem().movePlayhead(false)` bound to
 * it is recommended to have both of these set to a key as passing nothing will throw an error
 */
class adobeAutoSave extends count {

    __New(rClickPrem := "RButton", rClickMove := "XButton1") {
        try {
            ; this.premUIA.initialise(false) ;// don't do this or every reload it'll force attempt trying to set them
            ;// attempt to grab user settings
            user_props_list := ["autosave_MIN", "autosave_beep", "autosave_check_mouse", "autosave_save_override", "autosave_always_save", "autosave_restart_playback"]
            userPros := CLSID_Objs.loadProp("UserSettings", user_props_list)
            this.ms              := (userPros["autosave_MIN"] * 60000)
            this.beep            := userPros["autosave_beep"]
            this.checkMouse      := userPros["autosave_check_mouse"]
            this.saveOverride    := userPros["autosave_save_override"]
            this.alwaysSave      := userPros["autosave_always_save"]
            this.restartPlayback := userPros["autosave_restart_playback"]
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
    ms            := (5*60000) ;// 5min by default
    saveOverride  := true
    origWindow    := ""
    selfInitiatedSave := false

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
    restartPlayback := false
    premRemoteSave := true
    aeSaveBG      := true

    rClickPrem    := ""
    rClickMove    := ""
    movePlayhead  := InStr(ksa.prem.playheadtoCursor, "{") && InStr(ksa.prem.playheadtoCursor, "}") ? LTrim(RTrim(ksa.prem.playheadtoCursor, "}"), "{")
                                                                                          : ksa.prem.playheadtoCursor
    saveAttemptNotify := false

    programMonX1  := false,  programMonX2 := false
    programMonY1  := false,  programMonY2 := false

    origPanelFocus := ""
    resetAlreadyWaited := false

    ;// state for the save override
    active        := false
    ticking       := false
    saveHook      := ""
    restartFn     := ""
    saveAsWatchFn := ""

    ;// state for the idle check
    idleTotal     := 5
    idleRetryMs   := 2000
    idleThreshold := 500
    idleTimerFn   := ""
    idleResolve   := ""
    idleBarFn     := ""
    idleClearFn   := ""

    /** This function is called every increment */
    Tick() {
        this.ticking := true
        try {
            this.begin()

            ;// if the above function got to the point that it was able to determine an active window and has been set
            ;// attempt to reactivate it
            if this.origWindow != ""
                this.__reactivateWindow()

            ;// finish up
            if this.aeExist = true
                this.__resetAETrans()
            this.__reset()
            block.Off()
        } finally {
            this.ticking := false
        }
    }

    /** stops the timer */
    Stop(doCheckStuck := true) {
        this.active := false
        super.stop()
        this.__stopSaveHook()
        this.__cancelIdleWait()
        this.__stopSaveAsWatch()
        if this.restartFn {
            SetTimer(this.restartFn, 0)
            this.restartFn := ""
        }
        if doCheckStuck
            checkstuck()
        block.Off()
    }

    /** starts the timer */
    Start() {
        this.active := true
        try this.__startSaveHook()
        catch {
            SetTimer((*) => tool.Cust("Attempting to start the save override ``InputHook`` failed.`nA reload may be required for proper functionality."), -1)
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
            block.Off()
            return
        }
        block.Off()

        ;// save prem
        if this.premExist = true
            this.__savePrem()

        ;// save ae
        if this.aeExist = true
            this.__saveAE()
    }

    closeNotifys() {
        notifyArr := ["autosavepremDelay", "autosavepremNextAttempt", "autosavepremPlayback", "autosavePremBusy", "autosavepremSaveCheck", "autosavepremEdit", "autosavepremBusier", "autosavepremSaveAttempt", "autosavepremFailed", "autosaveaeBusy", "autosaveaeSaveCheck", "autosavewaitTimeout"]
        anyExist := false
        for v in notifyArr {
            if notify.Exist(v) {
                anyExist := true
                break
            }
        }
        if !anyExist
            return
        loop notifyArr.Length {
            try Notify.Destroy(notifyArr[A_Index])
        }
    }

    /** starts an `InputHook` that notifies us whenever `s` is pressed (the keystroke itself is passed through untouched) */
    __startSaveHook() {
        if this.saveOverride != true
            return
        if this.saveHook && this.saveHook.InProgress
            return
        ih := InputHook("V I1") ;// V = don't block keys, I1 = ignore input sent by scripts (ours included)
        ih.KeyOpt("s", "N")     ;// N = fire OnKeyDown for this key
        ih.OnKeyDown := this.__onSaveKey.Bind(this)
        ih.OnEnd     := this.__onHookEnd.Bind(this)
        ih.Start()
        this.saveHook := ih
    }

    __stopSaveHook() {
        if !this.saveHook
            return
        ih := this.saveHook
        this.saveHook := "" ;// cleared first so `__onHookEnd` knows this stop was intentional
        try ih.Stop()
    }

    /** InputHooks end on their own once they've collected 1023 characters, so quietly start a new one if that happens */
    __onHookEnd(ih) {
        if ih !== this.saveHook
            return
        this.saveHook := ""
        if this.active && this.saveOverride = true
            SetTimer((*) => this.__startSaveHook(), -1)
    }

    /** fires whenever `s` is pressed - we only care about Ctrl+S inside Premiere/AE */
    __onSaveKey(ih, vk, sc) {
        if this.selfInitiatedSave
            return
        if !GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || GetKeyState("Shift", "P")
            return
        if !(WinActive(prem.winTitle) || WinActive(ae.winTitle))
            return
        SetTimer((*) => this.__userSaved(), -1)
    }

    /** the user saved manually: abort anything in progress and restart the countdown */
    __userSaved() {
        if this.selfInitiatedSave || !this.active
            return
        super.stop()
        this.resetingSave := true
        this.__cancelIdleWait()

        if this.restartFn
            SetTimer(this.restartFn, 0)
        this.restartFn := this.__restartAfterUserSave.Bind(this)
        SetTimer(this.restartFn, -1500)
    }

    __restartAfterUserSave() {
        if !this.active
            return
        ;// let a running tick wind down / the save window close before resetting
        if this.ticking || WinExist("Save Project ahk_exe " prem.exeTitle) {
            SetTimer(this.restartFn, -500)
            return
        }
        this.restartFn := ""
        this.resetAlreadyWaited := true
        this.__reset()
        super.start()
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

    __remoteStop() {
        try this.Stop()
        return
    }

    /** determine whether premiere/ae is open */
    __checkforEditors() {
        this.premExist := winExt.ExistRegex(prem.winTitle) ? true : false
        this.aeExist   := winExt.ExistRegex(AE.winTitle)   ? true : false
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

    /**
     * Makes sure the user has been idle before we save. Safe to call multiple times per tick.
     * `Promise.await()` keeps pumping messages so the retry timers below still fire while we wait.
     * @returns {Boolean} true if it's safe to save
     */
    __ensureIdle() {
        if this.resetingSave = true
            return false
        try {
            ;// no timeout on purpose: `Promise.await()` re-subtracts total elapsed time on every message it pumps,
            ;// so a finite timeout expires far too early. The poll chain always ends on its own (max `idleTotal` attempts).
            return this.__waitForIdle().await() = true
        } catch {
            this.__cancelIdleWait()
            return false
        }
    }

    /**
     * @returns {Promise<Boolean>} resolves `true` once the user is idle, `false` if we gave up or the save was reset
     */
    __waitForIdle() {
        this.__cancelIdleWait()
        return Promise(executor)
        executor(resolve, reject) {
            this.idleResolve := resolve
            this.__idlePoll(1)
        }
    }

    /** is the user currently interacting with the keyboard/mouse? */
    __userIsBusy() {
        ;// if the user has interacted with the keyboard recently
        ;// or the last pressed key is LButton, RButton or \ & they have interacted with the mouse recently
        ;// the save attempt will be paused and retried
        return (A_TimeIdleKeyboard <= this.idleThreshold)
            || (this.checkMouse = true && ((A_PriorKey = "LButton" || A_PriorKey = "RButton" || A_PriorKey = this.movePlayhead) && A_TimeIdleMouse <= 500))
            || this.__checkRClick()
    }

    /** a single idle check. If the user is busy it schedules itself again with a timer instead of looping/sleeping */
    __idlePoll(attempt) {
        this.idleTimerFn := ""

        ;// the user (or a save window) beat us to it
        if this.resetingSave = true || WinExist("Save Project") {
            this.resetingSave := true
            return this.__finishIdle(false)
        }

        ;// user is idle, we're good to go
        if !this.__userIsBusy() {
            this.idleAttempt := true
            return this.__finishIdle(true)
        }

        if attempt > 1 && this.beep = true
            this.__playBeep()
        if !Notify.Exist("autosavepremDelay")
            Notify.Show(A_ScriptName, "Script tried to save but the user interacted with the keyboard/mouse in the last 0.5s.`nPlease wait for the next save attempt:", 'C:\Windows\System32\imageres.dll|icon244', 'Speech Misrecognition',, 'theme=Dark dur=0 show=Fade@250 hide=Fade@250 maxW=400 tag=autosavepremDelay')

        if attempt >= this.idleTotal {
            errorLog(Error(A_ScriptName " tried to save but the user kept interacting with the keyboard/mouse"))
            return this.__finishIdle(false)
        }

        this.__showNextAttempt(attempt)
        this.idleTimerFn := this.__idlePoll.Bind(this, attempt + 1)
        SetTimer(this.idleTimerFn, -this.idleRetryMs)
    }

    /** settles the pending idle promise and cleans up the notifications */
    __finishIdle(result) {
        this.__clearNextAttempt()
        if Notify.Exist("autosavepremDelay")
            try Notify.Destroy("autosavepremDelay", true)
        resolve := this.idleResolve
        this.idleResolve := ""
        if resolve
            resolve(result)
    }

    /** cancels a pending idle wait (if any) - the awaiting code gets `false` */
    __cancelIdleWait() {
        if this.idleTimerFn {
            SetTimer(this.idleTimerFn, 0)
            this.idleTimerFn := ""
        }
        if this.idleResolve
            this.__finishIdle(false)
    }

    /** shows the "Next Attempt" progress bar, animated by a timer rather than a blocking loop */
    __showNextAttempt(attempt) {
        this.__clearNextAttempt()
        ;// timeline per attempt (with the default 2000ms):
        ;//   0 - 1300ms : bar fills
        ;//   1300 - 1600ms : bar sits full so the progress bar's own animation can catch up
        ;//   1600ms : bar is destroyed
        ;//   2000ms : next poll - the gap stops the old bar's fade-out from colliding with the new bar (same tag)
        range := Max(this.idleRetryMs - 700, 500) ;// ms
        nextAttempt := Notify.Show(attempt "/" this.idleTotal " - Next Attempt:",, 'iconi',,, 'theme=Dark dur=0 show=Fade@250 bdr=0x75aedc ts=12 tfo=norm hide=Fade@250 maxW=400 prog=h15 w240 Range0-' range ' Smooth tag=autosavepremNextAttempt')
        this.idleBarFn := this.__animateBar.Bind(this, nextAttempt, A_TickCount, range)
        SetTimer(this.idleBarFn, 15)
    }

    __animateBar(nextAttempt, startTick, range) {
        ;// might get deleted if the user manually saves
        if !Notify.Exist("autosavepremNextAttempt") {
            this.__stopBar()
            return
        }
        elapsed := Min(A_TickCount - startTick, range)
        try nextAttempt["prog"].value := elapsed
        ;// once full, stop updating and remove it after a short hold
        if elapsed >= range {
            this.__stopBar()
            this.idleClearFn := this.__clearNextAttempt.Bind(this)
            SetTimer(this.idleClearFn, -300)
        }
    }

    __stopBar() {
        if this.idleBarFn {
            SetTimer(this.idleBarFn, 0)
            this.idleBarFn := ""
        }
    }

    __clearNextAttempt() {
        this.__stopBar()
        if this.idleClearFn {
            SetTimer(this.idleClearFn, 0)
            this.idleClearFn := ""
        }
        if Notify.Exist("autosavepremNextAttempt")
            try Notify.Destroy("autosavepremNextAttempt", true)
    }

    /** @returns {Boolean} true/false on whether it can grab the active window */
    __getOrigWindow() {
        try{
            this.origWindow := winExt.ProcessNameRegex()
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
            Critical()
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
            Critical("Off")
        }
    }


    /**
     * Check for a window containing a class used by windows to denote that a file select/dir select GUI is open (ie. a save window)
     * @param {String} which denotes which application exe to check for. Defaults to `Adobe Premiere Pro` - After Effects would be `AfterFX`
     * @returns {Boolean} true if the window **doesn't** exist or false if it does
     */
    __checkDialogueClass(which := "Adobe Premiere Pro") {
        if InStr(which, "Premiere Pro") && (WinExist("ahk_class PLUGPLUG_UI_NATIVE_WINDOW_CLASS_NAME ahk_exe " prem.exeTitle) && DirExist(A_AppData "\Knights of the Editing Table\excalibur"))
            return false
        if WinExist("ahk_class #32770 ahk_exe " which ".exe")
            return false
        return true
    }

    /** Attempts to reactivate the originally active window. If the original window is Premiere, it will attempt to resume playback if necessary */
    __reactivateWindow() {
        try {
            checkActive := winExt.ProcessNameRegex()
            if (this.origWindow = checkActive && this.userPlayback = false)
                return
            switch this.origWindow {
                case "CabinetWClass": WinActivate("CabinetWClass")
                case "AfterFX.exe", "AfterFX (Beta).exe": switchTo.AE()
                case "Adobe Premiere Pro.exe", "Adobe Premiere Pro (Beta).exe":
                    isPlaying := prem.isPlaying()
                    if this.restartPlayback = false && isPlaying = true && WinActive("ahk_exe " this.origWindow)
                        prem.stopPlayback()
                    if this.restartPlayback = false && this.userPlayback = false && this.premRemoteSave = true && !WinActive("ahk_exe " this.origWindow)
                        return
                    if !WinActive("ahk_exe " this.origWindow)
                        switchTo.Premiere()
                    if this.restartPlayback = false || this.userPlayback = false
                        return
                    if WinExist("Save Project ahk_exe " this.origWindow) {
                        if !WinWaitClose("Save Project ahk_exe " this.origWindow,, 5) {
                            errorLog(TimeoutError("Waiting for the Save window to close timed out"))
                            notifyExt.showIfNotExist("autosavewaitTimeout",, 'Waiting for the Save window to close timed out, playback may not be returned.', 'iconi',,, 'dur=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
                            return
                        }
                        sleep 150
                    }
                    ;// if the user was originally playing back on the timeline
                    ;// we resume that playback here

                    prem.__focusTimeline()
                    sleep 100
                    SendInput(KSA.prem.playStop)
                    sleep 1000
                    loop 3 {
                        checkPlaying := prem.isPlaying()
                        if checkPlaying != true {
                            prem.__focusTimeline()
                            sleep 100
                            prem.startPlayback()
                            sleep 100
                            continue
                        }
                        break
                    }
                default:
                    if this.premRemoteSave = false
                        WinActivate("ahk_exe " this.origWindow)
            }
        } catch {
            errorLog(TargetError("Couldn't determine the active window"),, 1)
            return
        }
    }

    /** checks against `prem.delayPlayback()` */
    __pendingPlaybackDelay() {
        try return CLSID_Objs.loadProp("prem", "delayTime") != 0
        return false
    }

    /** saves premiere */
    __savePrem() {

        ;// backing up project files
        this.__backupFiles()

        if this.alwaysSave = false && !WinActive(prem.winTitle)
            return

        ;// checking for save dialogue box
        if !this.__checkDialogueClass() {
            notifyExt.showIfNotExist("autosavePremBusy",, 'Premiere appears to be busy, cancelling save attempt...', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            return
        }

        ;// getting window title/information
        this.premWindow := WinGet.PremName()
        checkType := (Type(this.premWindow) != "Object")
        checkTitle := isObjHasProp(this.premWindow, "winTitle", false) && isObjHasProp(this.premWindow, "titleCheck", -1) && isObjHasProp(this.premWindow, "saveCheck", -1)
        checkCanSave := isObjHasProp(this.premWindow, "titleCheck", true)
        if !this.premWindow || checkType || !checkTitle || checkCanSave {
            errorLog(UnsetError("autosave.ahk was unable to determine the title of the Premiere Pro window"), "The user may not have the correct year set within the settings", 1)
            return
        }

        ;// if save NOT required, exit early
        if !this.premWindow.saveCheck {
            notifyExt.showIfNotExist("autosavepremSaveCheck",, 'Premiere save not required, cancelling...', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            ; tool.Cust("Premiere save not required, cancelling")
            return
        }

        if prem.isEditTabActive() = false {
            errorLog(TargetError("The Premiere 'Edit' tab is not currently selected, or the Premiere window could not be found. The save attempt was aborted", -1))
            notifyExt.showIfNotExist("autosavepremEdit",, "The Premiere 'Edit' tab is not currently selected, or the Premiere window could not be found. The save attempt was aborted", 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            return
        }

        ;// this should cover occurrences where another window is open within premiere
        currentProg := winExt.ProcessNameRegex()
        name := WinGet.Title()
        if ("ahk_exe " currentProg = prem.winTitle && (name != "" && name != this.premWindow.wintitle) && ((WinGetClass(this.premWindow.wintitle)) = "#32770")) {
            errorLog(TargetError("Premiere is potentially busy and the save attempt was aborted", -1))
            notifyExt.showIfNotExist("autosavepremBusier",, 'Premiere is potentially busy and the save attempt was aborted', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            return
        }

        ;// the idle check only matters if Premiere is the active window.
        ;// if it isn't, we save in the background straight away
        if (this.origWindow = "Adobe Premiere Pro.exe" || this.origWindow = "Adobe Premiere Pro (Beta).exe") {
            ;// checking idle status
            checkIdle := this.__ensureIdle()
            if !checkIdle || this.resetingSave = true
                return

            ;// the user may have saved (or the title changed) while we were waiting, so check again
            this.premWindow := WinGet.PremName()
            if !this.premWindow || Type(this.premWindow) != "Object" || !this.premWindow.saveCheck
                return

            if this.restartPlayback = true
                this.userPlayback := (prem.isPlaying() = true) ? true : false

            if this.__userIsBusy() || this.__pendingPlaybackDelay() {
                if !this.__ensureIdle()
                    return
            }
        }

        notifyExt.showIfNotExist("autosavepremSaveAttempt",, 'A save attempt is being made...`nInputs may be temporarily blocked', 'C:\Windows\System32\shell32.dll|icon259',,, 'dur=4 show=Fade@250 hide=Fade@250 maxW=400 bdr=0xDCCC75')
        this.saveAttemptNotify := true

        ;// attempts to save using `PremiereRemote`
        this.selfInitiatedSave := true
        saveAttempt := prem.save()
        if !(saveAttempt = true || saveAttempt = "timeout" || saveAttempt = "busy") {
            errorLog(Error("Save failed: " saveAttempt),
                Format("kbIdle={} || priorKey={} || priorHotkey={} || sincePriorHotkey={} || delayTime={}",
                    A_TimeIdleKeyboard, A_PriorKey, A_PriorHotkey, A_TimeSincePriorHotkey,
                    (CLSID_Objs.loadProp("prem", "delayTime"))))
        }
        if saveAttempt = false || saveAttempt = "timeout_nosave" {
            sleep 750
            if this.__userIsBusy() && !this.__ensureIdle() {
                this.selfInitiatedSave := false
                return
            }
            prem.stopPlayback(true) ;// a stray Space may have started playback
            sleep 100
            saveAttempt := prem.save()
        }
        if (saveAttempt = true || saveAttempt = "timeout" || saveAttempt = "busy") {
            sleep 500
            this.selfInitiatedSave := false
            SetTimer((*) => notifyExt.deleteIfExist("autosavepremSaveAttempt"), -500)
            return
        }
        notifyExt.showIfNotExist("autosavepremFailed",, 'PremiereRemote failed to save, falling back`nto a manual save attempt.', 'C:\Windows\System32\imageres.dll|icon80',,, 'theme=Dark dur=5 bdr=0xE96969 show=Fade@250 hide=Fade@250')

        this.premRemoteSave := false
        saveAsTitle := "Save As " editors.Premiere.winTitle
        try {
            block.On()
            checkStuck()

            ;// this script will attempt to NOT fire if Premiere_RightClick.ahk is active
            if this.__checkRClick() = true {
                throw
            }

            this.__startSaveAsWatch(saveAsTitle)

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
            this.__stopSaveAsWatch(saveAsTitle)
            return
        }

        ;// waiting for save dialogue to open & close
        if !WinWait("Save Project",, 3) {
            block.Off()
            this.__stopSaveAsWatch(saveAsTitle)
            return
        }
        block.Off()
        this.__stopSaveAsWatch(saveAsTitle)
        if !WinWaitClose("Save Project",, 3)
            return
    }

    /** saves after effects */
    __saveAE() {

        ;// backing up project files
        this.__backupFiles()

        if this.alwaysSave = false && !WinActive(ae.winTitle)
            return

        ;// checking for save dialogue box
        if !this.__checkDialogueClass("AfterFX") {
            notifyExt.showIfNotExist("autosaveaeBusy",, 'AE appears to be busy, cancelling save attempt...', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            return
        }

        ;// getting window title/information
        this.aeWindow := WinGet.AEName()
        checkType := (Type(this.aeWindow) != "Object")
        checkTitle := isObjHasProp(this.aeWindow, "winTitle", false) && isObjHasProp(this.aeWindow, "titleCheck", -1) && isObjHasProp(this.aeWindow, "saveCheck", -1)
        checkCanSave := isObjHasProp(this.aeWindow, "titleCheck", true)
        if !this.aeWindow || checkType || !checkTitle || checkCanSave  {
            errorLog(UnsetError("autosave.ahk was unable to determine the title of the After Effects window"), "The user may not have the correct year set within the settings", 1)
            return
        }

        ;// if save NOT required, exit early
        if !this.aeWindow.saveCheck {
            notifyExt.showIfNotExist("autosaveaeSaveCheck",, 'AE save not required, cancelling...', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            return
        }

        ;// checking idle status
        if !this.__ensureIdle()
            return

        if this.saveAttemptNotify = false && !Notify.Exist("autosaveaeSaveAttempt")
            notifyExt.showIfNotExist("autosaveaeSaveAttempt",, 'A save attempt is being made...`nInputs may be temporarily blocked', 'C:\Windows\System32\shell32.dll|icon259',,, 'dur=4 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')

        block.On()
        checkStuck()
        saveAsTitle := "Save As " editors.AE.winTitle
        this.__startSaveAsWatch(saveAsTitle)
        this.selfInitiatedSave := true

        try procName := WinGetProcessName(this.aeWindow.winTitle), procClass := WinGetClass(this.aeWindow.wintitle), procClassIsAE := RegExMatch(procClass, "^AE_CApplication_\d{2}(\.\d+)*$")
        catch {
            ;// ae may have crashed
            this.__stopSaveAsWatch(saveAsTitle)
            block.Off()
            this.__resetAETrans()
            return
        }
        checkAgain := this.__checkDialogueClass("AfterFX")
        if ((procName = "AfterFX.exe" || procName = "AfterFX (Beta).exe") && (procClassIsAE != true)) || !checkAgain {
            ;// ae may be busy
            this.__stopSaveAsWatch(saveAsTitle)
            block.Off()
            this.__resetAETrans()
            errorLog(TargetError("After Effects may be busy, aborting save attempt", -1))
            notifyExt.showIfNotExist("autosaveaeBusier",, 'After Effects is potentially busy and the save attempt was aborted', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
            return
        }

        ;// if AE is the active window, a normal save will be fine
        if this.origWindow = procName {
            AE.save()
            if !WinWait("Save Project " editors.AE.winTitle,, 3) {
                this.__stopSaveAsWatch(saveAsTitle)
                block.Off()
                errorLog(TimeoutError("Failed to wait for AE save window to appear"))
                notifyExt.showIfNotExist("autosaveaeBusier",, 'After Effects is potentially busy and the save attempt was aborted', 'iconi',,, 'dur=2 show=Fade@250 hide=Fade@250 maxW=400 bdr=0x75aedc')
                return
            }
            this.__stopSaveAsWatch(saveAsTitle)
            WinWaitClose("Save Project " editors.AE.winTitle,, 3)
            block.Off()
            sleep 200
            return
        }

        ;// if AE ISN'T the active window, attempting to save it in the background will force it into the foreground which can be super disorienting/annoying
        ;// so we have to work around that
        try {
            checkStuck()
            if this.aeSaveBG = true
                WinSetTransparent(0, editors.AE.winTitle)
            ;// if the user manually saves inbetween grabbing the title and this timer attempting to save
            ;// this part will throw if it's not inside a try block
            AE.save()
        } catch {
            block.Off()
            this.__stopSaveAsWatch(saveAsTitle)
            this.__resetAETrans()
            return
        }
        ;// ae isn't the active window here anyway so we should return inputs to the user
        block.Off()

        WinWaitClose("Save Project " editors.AE.winTitle,, 3)
        if this.aeSaveBG = true {
            try {
                ;// only move ae to the bottom if mocha is NOT open
                if !WinExist("ahk_exe mocha4ae_adobe.exe")
                    WinMoveBottom(editors.AE.winTitle)
            }
        }
        this.__stopSaveAsWatch(saveAsTitle)
        this.__resetAETrans()
    }

    /** start a timer that cancels the "Save As" window if it appears */
    __startSaveAsWatch(saveAsTitle) {
        if this.saveAsWatchFn
            return
        this.saveAsWatchFn := this.__cancelSaveAs.Bind(this, saveAsTitle)
        SetTimer(this.saveAsWatchFn, 20)
    }

    __cancelSaveAs(saveAsTitle) {
        try {
            if WinExist(saveAsTitle)
                ControlSend("{Esc}",, saveAsTitle)
        }
    }

    /** stop the timer that cancels the "Save As" window */
    __stopSaveAsWatch(saveAsTitle := "") {
        if this.saveAsWatchFn {
            SetTimer(this.saveAsWatchFn, 0)
            this.saveAsWatchFn := ""
        }
        this.selfInitiatedSave := false
    }

    /** reset after effects window transparency */
    __resetAETrans() {
        try {
            Critical()
            WinWaitClose("Save Project " editors.AE.winTitle) ;// this is necessary, you can't reset transparency of the main window if the save window is open
            sleep 100
            WinSetTransparent(255, editors.AE.winTitle)
            Critical("Off")
        } catch {
            errorLog(Error("Failed to reset transparency", -1),, true)
        }
    }

    /** attempts to check if `Premiere_RightClick.ahk` is active */
    __checkRClick() {
        InstallMouseHook(true)
        isCoreFunc := winExt.ExistRegex("Core Functionality.ahk")
        if isCoreFunc {
            rClick := CLSID_Objs.loadProp("prem", "RClickIsActive")
            if rClick = true || GetKeyState(this.rClickPrem, "P") = true || GetKeyState(this.movePlayhead) = true || GetKeyState(this.rClickMove, "P") = true {
                InstallMouseHook(false)
                premObj := ""
                return true
            }
            premObj := ""
        }
        InstallMouseHook(false)
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
        this.premUIA := ""
        this.premRemoteSave := true
        checkstuck()
        (this.resetAlreadyWaited = true) ? this.closeNotifys() : SetTimer((*) => (this.closeNotifys()), -4500)
        this.resetAlreadyWaited := false
    }

    __Delete() {
        block.Off()
        try this.Stop()
    }
}