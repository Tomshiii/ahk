;This script will suspend `My Scripts.ahk` when a listed game is active. This is useful as several of the hotkeys in `My Scripts.ahk` interfere with games

#SingleInstance Force
SetWorkingDir A_ScriptDir ;sets the scripts working directory to the directory it's launched from
TraySetIcon(A_WorkingDir "\Support Files\Icons\game.png")
SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.

;Add games here! you can get this info using WindowSpy that comes with ahk
GroupAdd("games", "Minecraft ahk_exe javaw.exe") ;minecraft
GroupAdd("games", "Terraria ahk_exe Terraria.exe") ;terraria

; --

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
            return
        }
    if !WinActive("ahk_group games") && ask = 1 ;if the user has suspended My Scripts.ahk manually outisde of a game, this block will fire and will prompt the user asking if they wish to unsuspend the scripts
        {
            if ScriptSuspend("My Scripts.ahk", false) = 1
                {
                    check := MsgBox("You have ``My Scripts.ahk`` suspended, do you wish to unsuspend it?`n`nIf this is not an accident, press " '"' "No" '"' " and you will not be asked again this session.", "My Scripts.ahk is Suspended", "4 32 4096") ;prompt the user with a msgbox
                    if check = "No"
                        {
                            ask := 0
                            SetTimer(, -secms)
                            ScriptSuspend("My Scripts.ahk", true)
                        }
                }
        }
    SetTimer(, -secms) ;reset the timer
}



/*
 This function will suspend/unsuspend other scripts
 This script found here: https://stackoverflow.com/questions/14492650/check-if-script-is-suspended-in-autohotkey -- by Lexikos
 */
ScriptSuspend(ScriptName, SuspendOn)
{
    ; Get the HWND of the script main window (which is usually hidden).
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows True
    if scriptHWND := WinExist(ScriptName " ahk_class AutoHotkey")
    {
        ; This constant is defined in the AutoHotkey source code (resource.h):
        static ID_FILE_SUSPEND := 65404

        ; Get the menu bar.
        mainMenu := DllCall("GetMenu", "ptr", scriptHWND)
        ; Get the File menu.
        fileMenu := DllCall("GetSubMenu", "ptr", mainMenu, "int", 0)
        ; Get the state of the menu item.
        state := DllCall("GetMenuState", "ptr", fileMenu, "uint", ID_FILE_SUSPEND, "uint", 0)
        ; Get the checkmark flag.
        isSuspended := state >> 3 & 1
        ; Clean up.
        DllCall("CloseHandle", "ptr", fileMenu)
        DllCall("CloseHandle", "ptr", mainMenu)

        if (!SuspendOn != !isSuspended)
            {
                SendMessage 0x111, ID_FILE_SUSPEND,,, "ahk_id " %&scriptHWND%
                return 1
            }
        else
            return 0
        ; Otherwise, it already in the right state.
    }
    DetectHiddenWindows %&dhw%
}

