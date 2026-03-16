;This script will suspend `My Scripts.ahk` when a listed game is active. This is useful as several of the hotkeys in `My Scripts.ahk` interfere with games

#SingleInstance Force
ListLines(0)
KeyHistory(0)

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Settings.ahk
#Include Classes\ptf.ahk
#Include Classes\pause.ahk
#Include Classes\winget.ahk
#Include Classes\WM.ahk
#Include Classes\Mip.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\timer.ahk
#Include GUIs\gameCheckGUI.ahk
#Include gameCheck\Game List.ahk ;games can either be manually added to the game list linked below OR can be added by pressing the "Add game to `gameCheck.ahk`" button in the settings GUI (default hotkey is win + F1)
#Include Functions\trayShortcut.ahk
; }

TraySetIcon(ptf.Icons "\game.png")

startupTray()

;// defining a GUI the user can access by right clicking the script
A_TrayMenu.Insert("7&") ;adds a divider bar
A_TrayMenu.Insert("8&", "Add Game", gameAdd)

/** This function is called when the user attempts to add a game from the system tray icon */
gameAdd(*) {
    Critical()
    orig := detect()
    value := WinGetList()
    ;// A map containing various win explorer classes that the script will ignore
    ;// otherwise things like the taskbar would populate the GUI instead of the most recently active window
    for this_value in value {
        if WinGet.isProc(this_value)
            continue
        ;// generate the gui
        try title := WinGetTitle(this_value), proc := WinGetProcessName(this_value)
        catch {
            continue
        }
        gameGUI := gameCheckGUI(, title, proc)
        gameGUI.Show("AutoSize")
        break
    }
    resetOrigDetect(orig)
    Critical("Off")
}

gameCheck := gameCheckTimer()

changeInterval := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, changeInterval.Bind())  ; 0x004A is WM_COPYDATA

OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        gameCheck.Stop()
}


class gameCheckTimer extends count {
    __New() {
        this.UserSettings := CLSID_Objs.load("UserSettings")
        this.mainScript := this.UserSettings.MainScriptName
        super.__New(-(this.UserSettings.game_SEC * 1000))
        super.start()
    }

    UserSettings := ""
    mainScript := ""

    ;// game open = true || closed = false
    which := false

    Tick() {
        this.check()
    }

    __remoteStop() {
        try this.Stop()
        return
    }

    /** This function is called by a timer to determine. It keeps track of static variable `ask` to determine if the user has been prompted regarding their script being suspended outside of a game. */
    check() {
        switch this.which {
            case true:
                if !WinActive("ahk_group games") {
                    pause.suspend(this.mainScript ".ahk", false) ;unsuspend
                    this.which := false
                }
            case false:
                if WinActive("ahk_group games") {
                    pause.suspend(this.mainScript ".ahk", true) ;suspend
                    this.which := true
                }
        }
        this.interval := -(this.UserSettings.game_SEC * 1000)
        this.stop()
        this.start()
    }

    __Delete() => super.stop()
}