; { \\ #Includes
#Include <\GUIs>
#Include <\Classes\ptf>
#Include <\Classes\tool>
#Include <\Classes\switchTo>
#Include <\Functions\getHotkeys>
#Include <\Functions\errorLog>
; }

class switchTo {
    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Explorer()
    {
        if !WinExist("ahk_class CabinetWClass") && !WinExist("ahk_class #32770")
            {
                Run("explorer.exe")
                WinWait("ahk_class CabinetWClass")
                WinActivate("ahk_class CabinetWClass") ;in win11 running explorer won't always activate it, so it'll open in the backround
            }
        GroupAdd("explorers", "ahk_class CabinetWClass")
        GroupAdd("explorers", "ahk_class #32770") ;these are save dialoge windows from any program
        if WinActive("ahk_exe explorer.exe")
            GroupActivate("explorers", "r")
        else if WinExist("ahk_class CabinetWClass") || WinExist("ahk_class #32770")
            WinActivate ;you have to use WinActivatebottom if you didn't create a window group.
    }

    /**
     * This function when called will close all windows of the desired program EXCEPT the active one. Helpful when you accidentally have way too many windows open.
     * @param {String} program is the ahk_class or ahk_exe of the program you want this function to close
     */
    static closeOtherWindow(program)
    {
        value := WinGetList(program) ;gets a list of all open windows
        tool.Cust(value.length - 1 " other window(s) closed") ;tooltip to display how many explorer windows are being closed
        for this_value in value
            {
                if A_Index > 1 ;closes all windows that AREN'T the last active window
                    WinClose this_value
            }
    }

    /**
     * This function is specifically designed for this script as I have a button designed to be pressed alongside another just to open new windows
     * @param {String} classorexe is just defining if we're trying to grab the class or exe
     * @param {String} activate is whatever usually comes after the ahk_class or ahk_exe that ahk is going to use to activate once it's open
     * @param {String} runval is whatever you need to put into ahk to run a new instance of the desired program (eg. a file path)
     */
    static newWin(classorexe, activate, runval)
    {
        getHotkeys(&first, &second)
        KeyWait(second) ;prevent spamming
        if WinExist("ahk_" classorexe . activate)
            {
                Run(runval)
                return
            }
        Run(runval)
        WinWait("ahk_" classorexe . activate)
        WinActivate("ahk_" classorexe . activate) ;in win11 running things won't always activate it and will open in the backround
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Premiere()
    {
        if !WinExist(editors.class["premiere"])
            Run(ptf["Premiere"])
        else if WinExist(editors.class["premiere"])
            WinActivate(editors.class["premiere"])
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static AE()
    {
        runae() ;cut repeat code
        {
            Run(ptf["AE"])
            WinWait(editors.winTitle["ae"])
            WinActivate(editors.winTitle["ae"])
        }
        premTitle() ;pulls dir url from prem title and runs ae project in that dir
        {
            try {
                Name := WinGetTitle("Adobe Premiere Pro")
                titlecheck := InStr(Name, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
                dashLocation := InStr(Name, "-")
                length := StrLen(Name) - dashLocation
                if !titlecheck
                    {
                        runae()
                        return
                    }
                entirePath := SubStr(name, dashLocation + "2", length)
                pathlength := StrLen(entirePath)
                finalSlash := InStr(entirePath, "\",, -1)
                path := SubStr(entirePath, 1, finalSlash - "1")
                if !FileExist(path "\*.aep")
                    {
                        runae()
                        return
                    }
                loop files path "\*.aep", "F"
                    {
                        Run(A_LoopFileFullPath)
                        tool.Cust("Running AE file for this project")
                        WinWait(editors.winTitle["ae"])
                        WinActivate(editors.winTitle["ae"])
                        return
                    }
            } catch as e {
                tool.Cust("Couldn't determine proper path from Premiere")
                errorLog(e, A_ThisFunc "()")
                runae()
                return
            }
        }
        if !WinExist(editors.winTitle["ae"]) && WinExist(editors.winTitle["premiere"]) ;if prem is open but AE isn't
            premTitle()
        else if WinExist(editors.winTitle["ae"]) && WinExist(editors.winTitle["premiere"]) ;if both are open
            {
                try {
                    Name := WinGetTitle("Adobe After Effects")
                    titlecheck := InStr(Name, "Adobe After Effects " ptf.AEYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Program [Year]"
                    if slash := InStr(Name, "\",, -1) ;if there's a slash in the title, it means a project is open
                        WinActivate(editors.winTitle["ae"])
                    else
                        premTitle()
                }
            }
        else if WinExist(editors.winTitle["ae"]) && !WinExist(editors.winTitle["premiere"])
            WinActivate(editors.winTitle["ae"])
        else
            runae()
    }

    /**
     * This switchTo function will quickly switch to the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Disc()
    {
        move() => WinMove(-1080, -274, 1080, 1600, "ahk_exe Discord.exe") ;creating a function out of the winmove so you can easily adjust the value
        if !WinExist("ahk_exe Discord.exe")
            {
                Run(ptf.LocalAppData "\Discord\Update.exe --processStart Discord.exe")
                WinWait("ahk_exe Discord.exe")
                if WinGetMinMax("ahk_exe Discord.exe") = 1 ;a return value of 1 means it is maximised
                    WinRestore() ;winrestore will unmaximise it
                move() ;moves it into position after opening
            }
        else
            {
                WinActivate("ahk_exe Discord.exe")
                if WinGetMinMax("ahk_exe Discord.exe") = 1 ;a return value of 1 means it is maximised
                    WinRestore() ;winrestore will unmaximise it
                move() ; just incase it isn't in the right spot/fullscreened for some reason
                tool.Cust("Discord is now active", 500) ;this is simply because it's difficult to tell when discord has focus if it was already open
            }
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Photo()
    {
        if WinExist(editors.winTitle["photoshop"])
            {
                WinActivate(editors.winTitle["photoshop"])
                return
            }
        Run(ptf["Photoshop"])
        WinWait(editors.winTitle["photoshop"])
        WinActivate(editors.winTitle["photoshop"])
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Firefox()
    {
        if !WinExist(browser.class["firefox"])
            Run("firefox.exe")
        if WinActive(browser.winTitle["firefox"])
            this.OtherFirefoxWindow()
        else if WinExist(browser.winTitle["firefox"])
            ;WinRestore ahk_exe firefox.exe
            WinActivate(browser.winTitle["firefox"])
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static OtherFirefoxWindow() ;I use this as a nested function below in firefoxTap(), you can just use this separately
    {
        if !WinExist(browser.winTitle["firefox"])
            {
                Run("firefox.exe")
                return
            }
        if WinActive(browser.class["firefox"])
            {
                GroupAdd("firefoxes", browser.class["firefox"])
                GroupActivate("firefoxes", "r")
                return
            }
        WinActivate(browser.class["firefox"])
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static VSCode()
    {
        if !WinExist(browser.winTitle["vscode"])
            Run(ptf.ProgFi "\Microsoft VS Code\Code.exe")
        GroupAdd("Code", browser.class["vscode"])
        /* if WinActive(browser.winTitle["vscode"])
            GroupActivate("Code", "r") */
        if WinExist(browser.winTitle["vscode"])
            WinActivate(browser.winTitle["vscode"]) ;you have to use WinActivatebottom if you didn't create a window group.
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Github()
    {
        if !WinExist("ahk_exe GitHubDesktop.exe")
            Run(ptf.LocalAppData "\GitHubDesktop\GitHubDesktop.exe")
        GroupAdd("git", "ahk_class Chrome_WidgetWin_1")
        if WinActive("ahk_exe GitHubDesktop.exe")
            GroupActivate("git", "r")
        else if WinExist("ahk_exe GitHubDesktop.exe")
            WinActivate("ahk_exe GitHubDesktop.exe") ;you have to use WinActivatebottom if you didn't create a window group.
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Streamdeck()
    {
        if !WinExist("ahk_exe StreamDeck.exe")
            Run(ptf.ProgFi "\Elgato\StreamDeck\StreamDeck.exe")
        GroupAdd("stream", "ahk_class Qt5152QWindowIcon")
        if WinActive("ahk_exe StreamDeck.exe")
            GroupActivate("stream", "r")
        else if WinExist("ahk_exe Streamdeck.exe")
            WinActivate("ahk_exe StreamDeck.exe") ;you have to use WinActivatebottom if you didn't create a window group.
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Excel()
    {
        if !WinExist("ahk_exe EXCEL.EXE")
            {
                Run(ptf.ProgFi "\Microsoft Office\root\Office16\EXCEL.EXE")
                WinWait("ahk_exe EXCEL.EXE")
                WinActivate("ahk_exe EXCEL.EXE")
            }
        GroupAdd("xlmain", "ahk_class XLMAIN")
        if WinActive("ahk_exe EXCEL.EXE")
            GroupActivate("xlmain", "r")
        else if WinExist("ahk_exe EXCEL.EXE")
            WinActivate("ahk_exe EXCEL.EXE")
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Word()
    {
        if !WinExist("ahk_exe WINWORD.EXE")
            {
                Run(ptf.ProgFi "\Microsoft Office\root\Office16\WINWORD.EXE")
                WinWait("ahk_exe WINWORD.EXE")
                WinActivate("ahk_exe WINWORD.EXE")
            }
        GroupAdd("wordgroup", "ahk_class wordgroup")
        if WinActive("ahk_exe WINWORD.EXE")
            GroupActivate("wordgroup", "r")
        else if WinExist("ahk_exe WINWORD.EXE")
            WinActivate("ahk_exe WINWORD.EXE")
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static WindowSpy()
    {
        if !WinExist("WindowSpy.ahk",, "Visual Studio Code")
            Run(ptf.ProgFi "\AutoHotkey\UX\WindowSpy.ahk")
        GroupAdd("winspy", "ahk_class AutoHotkeyGUI")
        if WinActive("WindowSpy.ahk",, "Visual Studio Code")
            GroupActivate("winspy", "r")
        else if WinExist("WindowSpy.ahk",, "Visual Studio Code")
            WinActivate("WindowSpy.ahk") ;you have to use WinActivatebottom if you didn't create a window group.
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static YourPhone()
    {
        if !WinExist("ahk_pid 13884") ;this process id may need to be changed for you. I also have no idea if it will stay the same
            Run(ptf["YourPhone"])
        GroupAdd("yourphone", "ahk_class ApplicationFrameWindow")
        if WinActive("Your Phone")
            GroupActivate("yourphone", "r")
        else if WinExist("Your Phone")
            WinActivate("Your Phone") ;you have to use WinActivatebottom if you didn't create a window group.
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Edge()
    {
        if !WinExist(browser.winTitle["edge"])
            {
                Run("msedge.exe")
                WinWait(browser.winTitle["edge"])
                WinActivate(browser.winTitle["edge"])
            }
        GroupAdd("git", browser.winTitle["edge"])
        if WinActive(browser.winTitle["edge"])
            GroupActivate("git", "r")
        else if WinExist(browser.winTitle["edge"])
            WinActivate(browser.winTitle["edge"]) ;you have to use WinActivatebottom if you didn't create a window group.
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Music()
    {
        GroupAdd("MusicPlayers", "ahk_exe wmplayer.exe")
        GroupAdd("MusicPlayers", "ahk_exe vlc.exe")
        GroupAdd("MusicPlayers", "ahk_exe AIMP.exe")
        GroupAdd("MusicPlayers", "ahk_exe foobar2000.exe")
        if !WinExist("ahk_group MusicPlayers")
            musicGUI()
        if WinExist("ahk_group MusicPlayers")
            {
                if !WinActive("ahk_group MusicPlayers")
                    WinActivate("ahk_group MusicPlayers")
                else
                    GroupActivate "MusicPlayers", "r"
                loop {
                    IME := WinGetTitle("A")
                    if IME = "Default IME"
                        GroupActivate "MusicPlayers", "r"
                    if IME != "Default IME"
                        break
                }
            }
        ;window := WinGetTitle("A") ;debugging
        ;tool.Cust(window) ;debugging
    }
}

/**
 * This function will do different things depending on how many times you press the activation hotkey.
 *
 * 1 press = switchToFirefox()
 *
 *2 press = switchToOtherFirefoxWindow()
 */
firefoxTap()
{
    static winc_presses := 0
    if winc_presses > 0 ; SetTimer already started, so we log the keypress instead.
    {
        winc_presses += 1
        return
    }
    ; Otherwise, this is the first press of a new series. Set count to 1 and start
    ; the timer:
    winc_presses := 1
    SetTimer After400, -180 ; Wait for more presses within a 300 millisecond window.

    After400()  ; This is a nested function.
    {
        if winc_presses = 1 ; The key was pressed once.
        {
            switchTo.Firefox()
        }
        else if winc_presses = 2 ; The key was pressed twice.
        {
            switchTo.OtherFirefoxWindow()
        }
        else if winc_presses > 2
        {
            ;
        }
        ; Regardless of which action above was triggered, reset the count to
        ; prepare for the next series of presses:
        winc_presses := 0
    }
}