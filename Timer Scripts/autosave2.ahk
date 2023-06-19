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
; }

TraySetIcon(ptf.Icons "\save.ico") ;changes the icon this script uses in the taskbar
InstallKeybdHook() ;required so A_TimeIdleKeyboard works and doesn't default back to A_TimeIdle
#WinActivateForce

class adobeAutoSave extends count {
    __New() {
        this.UserSettings := UserPref()
        this.ms := (this.UserSettings.autosave_MIN * 60000)
        this.UserSettings := ""
        super.__New(this.ms)
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

    __changeVar(wParam, lParam, msg, hwnd) {
        try {
            res := WM.Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
            lastUnd := InStr(res, "_", 1, -1)
            var := SubStr(res, 1, lastUnd-1)
            val := SubStr(res, lastUnd+1)
            this.%var% := val
        }
    }

    __checkforEditors() {
        this.premExist := WinExist(prem.winTitle) ? true : false
        this.aeExist   := WinExist(AE.winTitle)   ? true : false
    }

    begin() {
        this.__checkforEditors()
        if this.premExist = false && this.aeExist = false
            return
        if !this.__getOrigWindow()
            return
        if this.premExist = true
            this.__savePrem()
    }

    /** @returns the process ID of the active window */
    __getOrigWindow() {
        try{
            winget.ID(&id)
            return id
        } catch {
            block.Off()
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
            loop files path.Dir "\*.prproj", "F" {
                FileCopy(A_LoopFileFullPath, path.Dir "\Backup\*_" time ".*", 1)
            }
            loop files path.Dir "\*.aep", "F" {
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

    __savePrem() {
        if this.origWindow = "Adobe Premiere Pro.exe"
            this.__checkPremPlayback()
        this.__backupFiles()
        if WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro.exe") {
            block.Off()
            errorLog(Error(A_ScriptName " save attempt cancelled, a window is open that may alter the saving process", -1),, 1)
            return
        }
        this.premWindow := WinGet.PremName()
        if this.premWindow.winTitle = "" && !IsSet(this.premWindow.titleCheck) && !IsSet(this.premWindow.saveCheck) {
            errorLog(UnsetError("autosave.ahk was unable to determine the title of the Premiere Pro Window"), "The user may not have the correct year set within the settings", 1)
            return
        }
        if !this.premWindow.saveCheck
            return
        ;// needs logic to determine whether to save (does it have the title at this point under certain circumstances? the original script has spaghetti code from before winget.PremName() existed)
        ;// then needs proper code to determine how to save - originally it was determined that if the prem window is currently active, using controlsend wouldn't work
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
                        block.Off()
                        SendEvent(KSA.timelineWindow)
                    }
                default: WinActivate("ahk_exe " this.origWind)
            }
        } catch {
            errorLog(TargetError("Couldn't determine the active window"),, 1)
            return
        }
    }

    __reset() {
        this.count := 0

        this.origWindow := ""

        this.premExist := false
        this.aeExist   := false

        this.userPlayback  := false
        this.filesBackedUp := false

        this.premWindow := unset
        this.aeWindow   := unset
    }

    Tick() {
        this.begin()
        this.count := 0
    }
}