#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0
ListLines(0)
KeyHistory(0)

; { \\ #Includes
#Include <Classes\Settings>
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\switchTo>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\winget>
#Include <Classes\switchTo>
#Include <Classes\WM>
#Include <Classes\timer>
#Include <Functions\errorLog>
#Include <Functions\trayShortcut>

#Include <Other\print>
; }

TraySetIcon(ptf.Icons "\save.ico") ;changes the icon this script uses in the taskbar
InstallKeybdHook() ;required so A_TimeIdleKeyboard works and doesn't default back to A_TimeIdle
startupTray()
#WinActivateForce

class adobeAutoSave extends count {
    __New() {
        try {
            this.UserSettings := UserPref()
            this.ms := (this.UserSettings.autosave_MIN * 60000)
            this.UserSettings := ""
        }
        ;// set a fallback default of 5min is usersettings doesn't work
        if this.ms = 0
            this.ms := (5*60000)

        this.ms := 2000

        super.__New(this.ms)
        print("timer started for: " this.ms/60000 "min")
        super.start() ;start the timer
    }

    UserSettings := unset
    ms           := 0

    origWindow := ""

    premExist := false
    aeExist   := false

    userPlayback  := false
    filesBackedUp := false

    premWindow := unset
    aeWindow   := unset

    __checkforEditors() {
        this.premExist := WinExist(prem.winTitle) ? true : false
        this.aeExist   := WinExist(AE.winTitle)   ? true : false
    }

    __checkIdle() {
        attempt := false
        print("checking idle")
        loop 3 {
            if (A_TimeIdleKeyboard <= 500) ||
                ((A_PriorKey = "LButton" || A_PriorKey = "RButton" || A_PriorKey = "\") && A_TimeIdleMouse <= 500) ||
            GetKeyState("RButton", "P")
                {
                    tool.Cust(A_ScriptName " tried to save but you interacted with the keyboard/mouse in the last 0.5s`nautosave will try again in 2.5s", 2.0)
                    sleep 2500
                    continue
                }
            attempt := true
            break
        }
        return attempt
    }

    begin() {
        print("checking for editors")

        ;// check for prem/ae
        this.__checkforEditors()
        print(Format("prem:{}`nae:{}", this.premExist, this.aeExist))
        if this.premExist = false && this.aeExist = false
            return

        if !this.__checkIdle()
            return

        ;// grabbing originally active window
        if !this.__getOrigWindow() {
            this.__reset()
            return
        }
        print("orig window: " this.origWindow)

        ; block.On()

        ;// save prem
        if this.premExist = true
            this.__savePrem()

        ;// save ae
        if this.aeExist = true
            this.__saveAE()

    }

    /** @returns the process ID of the active window */
    __getOrigWindow() {
        try{
            winget.ID(&id)
            this.origWindow := id
            return true
        } catch {
            errorLog(TargetError("Unable to determine the active window"),, 1)
            return false
        }
    }

    __backupFiles() {
        if this.filesBackedUp = true
            return
        try {
            time := Format("{}_{}_{}-{}-{}", A_MM, A_DD, A_Hour, A_Min, A_Sec)
            path := WinGet.ProjPath()
            if !DirExist(path.Dir "\Backup")
                DirCreate(path.Dir "\Backup")
            loop files path.Dir "\Backup\*.*"
                FileDelete(A_LoopFileFullPath)
            loop files path.Dir "\*.*", "F" {
                if A_LoopFileExt != "prproj" && A_LoopFileExt != "aep"
                    continue
                FileCopy(A_LoopFileFullPath, path.Dir "\Backup\*_" time ".*", 1)
            }
            if FileExist(path.Dir "\checklist_logs.txt")
                FileCopy(path.Dir "\checklist_logs.txt", path.Dir "\Backup\*_" time ".*", 1)
            if FileExist(path.Dir "\checklist.ini")
                FileCopy(path.Dir "\checklist.ini", path.Dir "\Backup\*_" time ".*", 1)
            this.filesBackedUp := true
        }
    }

    /**
     * Attempts to check whether the user was playing back on the timeline within Premiere.
     * *note: this function will only work if the user has their program monitor on their main display*
     */
    __checkPremPlayback() {
        ;// if you don't have your project monitor on your main computer monitor this section of code will alwats fail
        if !ImageSearch(&x, &y, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Premiere "stop.png")
            return

        tool.Cust("If you were playing back anything, this function should resume it", 2.0,, 30, 2)
        this.userPlayback := true
    }

    /**
     * Check for a window containing a class used by windows to denote that a file select/dir select GUI is open (ie. a save window)
     * @param {String} which denotes which application exe to check for. Defaults to `Adobe Premiere Pro` - After Effects would be `AfterFX`
     */
    __checkDialogueClass(which := "Adobe Premiere Pro") {
        if WinExist("ahk_class #32770 ahk_exe " which ".exe") {
            errorLog(Error(A_ScriptName " save attempt cancelled, a window is open that may alter the saving process", -1),, 1)
            return false
        }
        return true
    }

    __savePrem() {
        print("saveprem started")

        ;// checking if prem is the originally active window
        if this.origWindow = "Adobe Premiere Pro.exe"
            this.__checkPremPlayback()

        ;// backing up project files
        this.__backupFiles()

        ;// checking for save dialogue box
        if !this.__checkDialogueClass()
            return

        ;// getting window title/information
        this.premWindow := WinGet.PremName()
        if ((this.premWindow.winTitle = "" || !this.premWindow.wintitle) && this.premWindow.titleCheck = -1 && this.premWindow.saveCheck = -1) || (!this.premWindow) {
            errorLog(UnsetError("autosave.ahk was unable to determine the title of the Premiere Pro window"), "The user may not have the correct year set within the settings", 1)
            return
        }
        print(Format("wintitle: {}`ntitlecheck: {}`nsavecheck: {}", this.premWindow.winTitle, this.premWindow.titleCheck, this.premWindow.saveCheck))
        tool.Cust(Format("wintitle: {}`ntitlecheck: {}`nsavecheck: {}", this.premWindow.winTitle, this.premWindow.titleCheck, this.premWindow.saveCheck), 2.0, A_ScreenWidth*.6, A_ScreenHeight*.95)

        ;// if save NOT required, exit early
        if !this.premWindow.saveCheck
            return

        ;// send save
        ControlSend("{Ctrl Down}s{Ctrl Up}")

        ;// waiting for save dialogue to open & close
        if !WinWait("Save Project",, 3)
            return
        if !WinWaitClose("Save Project",, 3)
            return

        ;// needs logic to determine whether to save (does it have the title at this point under certain circumstances? the original script has spaghetti code from before winget.PremName() existed)
        ;// then needs proper code to determine how to save - originally it was determined that if the prem window is currently active, using controlsend wouldn't work (seems to work now???)
    }

    __saveAE() {
        print("saveae started")

        ;// backing up project files
        this.__backupFiles()

        ;// checking for save dialogue box
        if this.__checkDialogueClass("AfterFX")
            return

        ;// if AE is the active window, a normal save will be fine
        if this.origWindow = WinGetProcessName(editors.AE.winTitle) {
            print("ae original window -- saving")
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
        print("ae background window -- saving")

        this.aeWindow := WinGet.AEName()
        WinSetTransparent(0, editors.AE.winTitle)
        ControlSend("{Ctrl Down}s{Ctrl Up}",, this.aeWindow.winTitle)
        if WinWait("Save As",, 0.5) {
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

    /** Attempts to reactivate the originally active window. If the original window is Premiere, it will attempt to resume playback if necessary */
    __reactivateWindow() {
        try {
            WinGet.ID(&checkActive)
            if this.origWindow = checkActive
                return
            switch this.origWindow {
                case "ahk_class CabinetWClass": WinActivate("ahk_class CabinetWClass")
                case "Adobe Premiere Pro.exe":
                    switchTo.Premiere()
                    if this.userPlayback = false
                        return
                    ;// if the user was originally playing back on the timeline
                    ;// we resume that playback here
                    try {
                        sleep 250
                        prem().__checkTimelineFocus()
                        sleep 100
                        SendEvent(KSA.playStop)
                        SendEvent(KSA.timelineWindow)
                    }
                default: WinActivate("ahk_exe " this.origWind)
            }
        } catch {
            errorLog(TargetError("Couldn't determine the active window"),, 1)
            return
        }
    }

    /** resets all internal variables */
    __reset() {
        this.count := 0,             this.origWindow := ""
        this.premExist := false,     this.aeExist   := false
        this.userPlayback  := false, this.filesBackedUp := false

        this.premWindow := unset
        this.aeWindow   := unset
    }

    /** This function is called every increment */
    Tick() {
        this.begin()
        this.__reactivateWindow()
        this.__reset()
        block.Off()
    }

    __Delete() {
        super.stop()
        block.Off()
    }
}

autoSave := adobeAutoSave()