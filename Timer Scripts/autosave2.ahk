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
#Include <Functions\detect>
#Include <Functions\errorLog>
; }

TraySetIcon(ptf.Icons "\save.ico") ;changes the icon this script uses in the taskbar
InstallKeybdHook() ;required so A_TimeIdleKeyboard works and doesn't default back to A_TimeIdle
#WinActivateForce

class adobeAutoSave extends count {
    __New() {
        this.UserSettings := UserPref()
        this.ms := (this.UserSettings.autosave_MIN * 60000)
        this.Tooltip := this.UserSettings.Tooltip, this.autosave_check_checklist := this.UserSettings.autosave_check_checklist
        this.UserSettings := ""
        super.__New(1000)

        if this.autosave_check_checklist = true
            this.checkChecklist := checkForChecklist()
    }

    UserSettings := unset
    ms := 0
    msChecklist := (0.5*60000) ;// 30s
    idle := (0.5*1000)
    retry := (2.5*1000)
    Tooltip := false
    autosave_check_checklist := false
    half := false
    active := false

    __changeVar(wParam, lParam, msg, hwnd) {
        try {
            res := WM.Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
            lastUnd := InStr(res, "_", 1, -1)
            var := SubStr(res, 1, lastUnd-1)
            val := SubStr(res, lastUnd+1)
            this.%var% := val
        }
    }

    start() {
        this.active := true
        super.start() ;start the timer
        ;// ...
    }

    Tick() {
        ++this.count
        ;// ... code here to check if it's been long enough to attempt a save
        tool.Cust(this.count)
    }
}

class checkForAdobe extends count {
    __New() {
        super.__New(1000)
        this.adobeAS := adobeAutoSave()
        chgeVar := ObjBindMethod(this.adobeAS, "__changeVar")
        OnMessage(0x004A, chgeVar)  ; 0x004A is WM_COPYDATA

        super.start()
    }

    adobeAS := ""

    Tick() {
        ++this.count
        this.__check()
    }

    __check() {
        if (WinExist(editors.Premiere.winTitle) || WinExist(editors.AE.winTitle)) && (this.adobeAS.active = false) {
            this.adobeAS.start()
            this.stop()
        }
    }
}

class checkForChecklist extends count {
    __New() {
        super.__New(1000)
        this.start()
    }

    Tick() {
        ++this.count
    }

    start() {
        super.start()

    }

    __check() {

    }
}

check := checkForAdobe()