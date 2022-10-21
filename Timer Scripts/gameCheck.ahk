;This script will suspend `My Scripts.ahk` when a listed game is active. This is useful as several of the hotkeys in `My Scripts.ahk` interfere with games

#SingleInstance Force
#Include FuncRedirect.ahk
SetWorkingDir A_ScriptDir ;sets the scripts working directory to the directory it's launched from
TraySetIcon("..\Support Files\Icons\game.png")
SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.

;Add games here! you can get this info using WindowSpy that comes with ahk or you can activate `settingsGUI()` (default hotkey is #F1::) while you have the game active, then press the "add game to `gameCheck()`" button. It will attemp to add you game to this list automatically.
;Format: `GameTitle ahk_exe game.exe`
GroupAdd("games", "Minecraft ahk_exe javaw.exe") ;minecraft
GroupAdd("games", "Terraria ahk_exe Terraria.exe") ;terraria
GroupAdd("games", "Overwatch ahk_exe Overwatch.exe") ;overwatch
GroupAdd("games", "Sector's ahk_exe sectorsedge.exe") ;sectorsedge
; -- leave this line it gets used and is needed in settingsGUI()

;Set seconds delay here:
sec := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "game SEC", 2.5)
secms := sec * 1000


SetTimer(check, -secms)
notActive() ;this timer will then start checking to see if the game is still active
{
    if !WinActive("ahk_group games")
        {
            ScriptSuspend("My Scripts.ahk", false) ;unsuspend
            SetTimer(, 0) ;stop this timer
            SetTimer(check, -secms)
        }
    else if WinActive("ahk_group games")
        SetTimer(, -secms)
}
check()
{
    static ask := 1
    if WinActive("ahk_group games") ;if a game is active and My Scripts.ahk isn't suspended
        {
            ScriptSuspend("My Scripts.ahk", true) ;suspend
            SetTimer(notActive, -secms)
            SetTimer(, 0)
        }
    else if !WinActive("ahk_group games") && ask = 1 ;if the user has suspended My Scripts.ahk manually outisde of a game, this block will fire and will prompt the user asking if they wish to unsuspend the scripts
        {
            if ScriptSuspend("My Scripts.ahk", false) = 1
                {
                    checkMsg := MsgBox("You have ``My Scripts.ahk`` suspended, do you wish to unsuspend it?`n`nIf this is not an accident, press " '"' "No" '"' " and you will not be asked again this session.", "My Scripts.ahk is Suspended", "4 32 4096") ;prompt the user with a msgbox
                    if checkMsg = "No"
                        {
                            ask := 0
                            SetTimer(, -secms)
                            ScriptSuspend("My Scripts.ahk", true)
                        }
                    else
                        SetTimer(, -secms)
                }
            else
                SetTimer(, -secms)
        }
    else
        SetTimer(, -secms)
}



;defining what happens if the script is somehow opened a second time and the function is forced to close
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode)
{
    if ExitReason = "Single" || "Close" || "Reload" || "Error"
        {
            ScriptSuspend("My Scripts.ahk", false)
            SetTimer(check, 0)
            SetTimer(notActive, 0)
        }
}
