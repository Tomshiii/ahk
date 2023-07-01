#SingleInstance force ;only one instance of this script may run at a time!
#Requires AutoHotkey v2.0
ListLines(0)

; { \\ #Includes
#Include <Classes\keys>
#Include <Classes\ptf>
#Include <Classes\timer>
#Include <Functions\trayShortcut>
; }

TraySetIcon(ptf.Icons "\premKey.png")
startupTray()


keyCheck := premKeyCheck()

;// defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        keyCheck.Stop()
}


class premKeyCheck extends count {
    __New() {
        super.__New(100)
        super.start()
    }

    Tick() {
        if !WinExist(Editors.Premiere.winTitle)
            return
    }

    __checkKeys() {
        keys.check("RButton")
        ;keys.check("LButton") ;don't do this, things break
        keys.check("XButton2")
        keys.check("\")
    }

    __Delete() => super.stop()
}