;This script will suspend `My Scripts.ahk` when a listed game is active. This is useful as several of the hotkeys in `My Scripts.ahk` interfere with games

#SingleInstance Force
ListLines(0)
KeyHistory(0)

; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\pause>
#Include <Classes\winget>
#Include <Classes\WM>
#Include <Classes\Mip>
#Include <GUIs\gameCheckGUI>
#Include <gameCheck\Game List> ;games can either be manually added to the game list linked below OR can be added by pressing the "Add game to `gameCheck.ahk`" button in the settings GUI (default hotkey is win + F1)
#Include <Functions\trayShortcut>
; }

TraySetIcon(ptf.Icons "\game.png")
SetTitleMatchMode(2) ;this is necessary to detect open .ahk scripts

startupTray()

;// open settings instance
UserSettings := UserPref()

;// Set seconds delay
sec := UserSettings.game_SEC
secms := sec * 1000

;// getting info from settings
version := UserSettings.version
mainScript := UserSettings.MainScriptName
UserSettings := "" ;// closing settings instance

OnMessage(0x004A, changeVar)  ; 0x004A is WM_COPYDATA
changeVar(wParam, lParam, msg, hwnd) {
    try {
        UserSettings := UserPref()
        res := WM.Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
        ;// UserSettings.autosave_MIN_ 5
        lastUnd := InStr(res, "_", 1, -1)
        var := SubStr(res, 1, lastUnd-1)
        val := SubStr(res, lastUnd+1)
        UserSettings.%var% := val
        UserSettings.__delAll()
        UserSettings := ""
        SetTimer((*) => reload(), -500)
    }
    return
}

;// defining a GUI the user can access by right clicking the script
A_TrayMenu.Insert("7&") ;adds a divider bar
A_TrayMenu.Insert("8&", "Add Game", gameAdd)

/** This function is called when the user attempts to add a game from the system tray icon */
gameAdd(*) {
    value := WinGetList()
    ;// A map containing various win explorer classes that the script will ignore
    ;// otherwise things like the taskbar would populate the GUI instead of the most recently active window
    for this_value in value {
        if WinGet.isProc(this_value)
            continue
        ;// generate the gui
        gameGUI := gameCheckGUI(, WinGetTitle(this_value), WinGetProcessName(this_value))
        gameGUI.Show("AutoSize")
        break
    }
}

SetTimer(check, secms)

/** This timer is called by `check()` to periodically check if a game window is still active */
notActive() {
    if !WinActive("ahk_group games") {
        pause.suspend(mainScript ".ahk", false) ;unsuspend
        SetTimer(, 0) ;stop this timer
        SetTimer(check, secms)
    }
}

/** This function is called by a timer to determine. It keeps track of static variable `ask` to determine if the user has been prompted regarding their script being suspended outside of a game. */
check() {
    static ask := 1
    ;// if a game is active and My Scripts.ahk isn't suspended
    if WinActive("ahk_group games") {
        pause.suspend(mainScript ".ahk", true) ;suspend
        SetTimer(notActive, secms)
        SetTimer(, 0)
    }
    if ask != 1
        return
    if WinActive("ahk_group games")
        return
    ;// if the user has suspended My Scripts.ahk manually outisde of a game, this block will fire and will prompt the user asking if they wish to unsuspend the scripts
    if pause.suspend(mainScript ".ahk", false) = 1 {
        checkMsg := MsgBox(Format("
        (
            You have ``{}.ahk`` suspended, do you wish to unsuspend it?

            If this is not an accident, press "No" and you will not be asked again this session.
        )", mainScript), mainScript ".ahk is Suspended", "4 32 4096") ;prompt the user with a msgbox
        if checkMsg = "No" {
            ask := 0
            pause.suspend(mainScript ".ahk", true)
        }
    }
}

;// defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if (ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error") {
        pause.suspend(mainScript ".ahk", false)
        SetTimer(check, 0)
        SetTimer(notActive, 0)
    }
}