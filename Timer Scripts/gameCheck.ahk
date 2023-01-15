;This script will suspend `My Scripts.ahk` when a listed game is active. This is useful as several of the hotkeys in `My Scripts.ahk` interfere with games

#SingleInstance Force
ListLines(0)
KeyHistory(0)

; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\pause>
#Include <Classes\winget>
#Include <GUIs\gameCheckGUI>
#Include <gameCheck\Game List> ;games can either be manually added to the game list linked below OR can be added by pressing the "Add game to `gameCheck.ahk`" button in the settings GUI (default hotkey is win + F1)
; }

TraySetIcon(ptf.Icons "\game.png")
SetTitleMatchMode(2) ;this is necessary to detect open .ahk scripts


;// Set seconds delay
sec := UserSettings.game_SEC
secms := sec * 1000

;// getting info from settings
darkMode := UserSettings.dark_mode
version := UserSettings.version

;// defining a GUI the user can access by right clicking the script
A_TrayMenu.Insert("7&") ;adds a divider bar
A_TrayMenu.Insert("8&", "Add Game", gameAdd)
gameAdd(*) {
    value := WinGetList()
    for this_value in value
        {
            proc := WinGetProcessName(this_value)
            class := WinGetClass(this_value)
            if proc = "explorer.exe" && (
                class = "Button"                   || class = "Shell_TrayWnd"          ||
                class = "NotifyIconOverflowWindow" || class = "Shell_SecondaryTrayWnd" ||
                class = "Progman"
            )
                continue
            else
                {
                    gameGUI := gameCheckGUI(darkMode, version, WinGetTitle(this_value), WinGetProcessName(this_value), "AlwaysOnTop", "Add game to gameCheck.ahk")
                    gameGUI.Show("AutoSize")
                    break
                }
        }
}

SetTimer(check, secms)

/**
 * This timer is called by `check()` to periodically check if a game window is still active
 */
notActive()
{
    if !WinActive("ahk_group games")
        {
            pause.suspend("My Scripts.ahk", false) ;unsuspend
            SetTimer(, 0) ;stop this timer
            SetTimer(check, secms)
        }
}

/**
 * This function is called by a timer to determine
 */
check()
{
    static ask := 1
    if WinActive("ahk_group games") ;if a game is active and My Scripts.ahk isn't suspended
        {
            pause.suspend("My Scripts.ahk", true) ;suspend
            SetTimer(notActive, secms)
            SetTimer(, 0)
        }
    else if !WinActive("ahk_group games") && ask = 1 ;if the user has suspended My Scripts.ahk manually outisde of a game, this block will fire and will prompt the user asking if they wish to unsuspend the scripts
        {
            if pause.suspend("My Scripts.ahk", false) = 1
                {
                    checkMsg := MsgBox("
                    (
                        You have ``My Scripts.ahk`` suspended, do you wish to unsuspend it?

                        If this is not an accident, press "No" and you will not be asked again this session.
                    )", "My Scripts.ahk is Suspended", "4 32 4096") ;prompt the user with a msgbox
                    if checkMsg = "No"
                        {
                            ask := 0
                            pause.suspend("My Scripts.ahk", true)
                        }
                }
        }
}

gameClose(*) {
    if IsSet(varTitle)
        varTitle := ""
    if IsSet(varProc)
        varProc := ""
}

;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || ExitReason = "Close" || ExitReason = "Reload" || ExitReason = "Error"
        {
            pause.suspend("My Scripts.ahk", false)
            SetTimer(check, 0)
            SetTimer(notActive, 0)
        }
}
