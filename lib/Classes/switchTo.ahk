/************************************************************************
 * @description A class to contain often used functions to open/cycle between windows of a certain type.
 * @author tomshi
 * @date 2023/07/15
 * @version 1.2.7
 ***********************************************************************/

; { \\ #Includes
#Include <GUIs\musicGUI>
#Include <Classes\ptf>
#Include <Classes\tool>
;programs
#Include <Classes\Apps\VSCode>
#Include <Classes\Apps\Discord>
#Include <Classes\Editors\After Effects>
#Include <Classes\Editors\Premiere>
#Include <Classes\Editors\Photoshop>
#Include <Classes\keys>
#Include <Classes\winget>
#Include <Classes\errorLog>
;funcs
#Include <Functions\getHotkeys>
; }

class switchTo {
    /**
     * This function cuts a lot of repeat code in other functions in this class. It's main goal is to provide the ability to swap between windows of the desired type or open one if there are none already.
     *
     * @param {String} winExistVar is the winTitle you wish to pass into `winWait`
     * @param {String} runVar is the program/path you wish to pass into `Run`
     * @param {String} groupVar is the name you wish to pass into `GroupAdd`
     * @param {String} addClass is the class name you wish to pass into `GroupAdd` if it's different to `winExistVar`
     * @param {String} ignore is the winTitle you wish to pass into the `ignore` parameter of `WinActive`
     */
    __Win(winExistVar, runVar, groupVar, addClass?, ignore?) {
        if !IsSet(addClass)
            addClass := winExistVar
        if !WinExist(winExistVar) {
                try {
                    Run(runVar)
                } catch {
                    errorLog(TargetError("File Doesn't Exist", -1), "Program may not be installed or is installed in an unexpected place", 1)
                    return
                }
                if WinWait(winExistVar,, 2)
                    WinActivate(winExistVar)
                return
            }
        GroupAdd(groupVar, addClass)
        if WinActive(winExistVar,, ignore?)
            GroupActivate(groupVar, "r")
        else if WinExist(winExistVar,, ignore?)
            WinActivate(winExistVar)
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Explorer()
    {
        if !WinExist("ahk_class CabinetWClass") && !WinExist("ahk_class #32770")
            {
                Run("explorer.exe")
                if WinWait("ahk_class CabinetWClass",, 2)
                    WinActivate("ahk_class CabinetWClass") ;in win11 running explorer won't always activate it, so it'll open in the backround
                return
            }
        GroupAdd("explorers", "ahk_class CabinetWClass")
        GroupAdd("explorers", "ahk_class #32770") ;these are save dialoge windows from any program
        GroupAdd("explorers", "ahk_class OperationStatusWindow") ;these are file transfer windows
        if WinActive("ahk_exe explorer.exe")
            GroupActivate("explorers", "r")
        else if WinExist("ahk_class CabinetWClass") || WinExist("ahk_class #32770") || WinExist("ahk_class OperationStatusWindow")
            WinActivate
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
                    WinClose(this_value)
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
        keys.allWait("second")
        if !WinExist("ahk_" classorexe . activate)
            {
                Run(runval)
                if WinWait("ahk_" classorexe . activate,, 2)
                    WinActivate("ahk_" classorexe . activate) ;in win11 running things won't always activate it and will open in the backround
                return
            }
        Run(runval)
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program.
     * This function will run AE using the after effects version defined within `settingsGUI()`
     */
    static Premiere()
    {
        if !WinExist(prem.class) {
            Run(ptf["Premiere"])
            return
        }
        WinActivate(prem.class)
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program.
     * This function will run AE using the after effects version defined within `settingsGUI()`.
     *
     * If AE is already open, this function will also check to make sure AE isn't transparent.
     */
    static AE()
    {
        ;// cut repeat code
        runae() {
            Run(AE.path)
            if WinWait(AE.winTitle,, 2)
                WinActivate(AE.winTitle)
        }


        premTitle() {
            try {
                ;// pulls dir url from prem title and runs ae project in that dir
                path := WinGet.ProjPath()
                if !FileExist(path.dir "\*.aep") {
                    runae()
                    return
                }
                count := 0, foundFile := ""
                loop files path.dir "\*.aep", "F"
                    {
                        foundFile := A_LoopFileFullPath
                        count++
                    }
                switch count {
                    case 1:
                        Run(AE.path A_Space '"' foundFile '"')
                        tool.Cust("Running AE file for this project")
                        if WinWait(AE.winTitle,, 2)
                            WinActivate(AE.winTitle)
                        return
                    default:
                        pick := FileSelect("3", path.dir "\effects.aep", "Which project do you wish to open?", "*.aep")
                        if pick = ""
                            return
                        Run(AE.path A_Space '"' pick '"')
                        tool.Cust("Running selected AE project")
                        if WinWait(AE.winTitle,, 2)
                            WinActivate(AE.winTitle)
                        return
                }
            } catch as e {
                tool.Cust("Couldn't determine proper path from Premiere")
                errorLog(e)
                runae()
                return
            }
        }

        premExist := WinExist(prem.winTitle)
        aeExist   := WinExist(AE.winTitle)

        switch aeExist {
            case false:
                if premExist
                    {
                        premTitle()
                        return
                    }
                runae()
            default:
                checkTrans() {
                    checkTran := WinGetTransparent(editors.AE.winTitle)
                    if IsInteger(checkTran) && checkTran != 255
                        {
                            WinMoveBottom(AE.winTitle)
                            WinSetTransparent(255, AE.winTitle)
                        }
                    WinActivate(AE.winTitle)
                }
                if premExist
                    {
                        try {
                            Name := WinGet.AEName()
                            if InStr(Name.winTitle, "\",, -1) ;if there's a slash in the title, it means a project is open
                                checkTrans()
                            else
                                premTitle()
                        } catch {
                            WinActivate(AE.winTitle)
                        }
                        return
                    }
                ;// if prem doesn't exist
                checkTrans()
        }
    }

    /**
     * This function opens the current `Premiere Pro`/`After Effects` project filepath in windows explorer. If prem/ae isn't open it will attempt to open the `ptf.comms` folder.
     * @returns {Boolean} `true/false` whether the function succeeded or failed
     */
    static adobeProject() {
        ;// if an editor isn't open
        if !WinExist("Adobe Premiere Pro") && !WinExist("Adobe After Effects") {
            ;// check for commissions folder
            if DirExist(ptf.comms) {
                tool.Cust("A Premiere/AE isn't open, opening the comms folder")
                Run(ptf.comms)
                commPath := obj.SplitPath(ptf.comms)
                ;// commPath.name assumes win11 -- if you're on win10 or you've changed it so explorer titles show the full path
                ;// simply use ptf.comms instead
                if !WinWait(commPath.name " ahk_class CabinetWClass", "comms", 2)
                    return false
                WinActivate(commPath.name " ahk_class CabinetWClass", "comms")
                return true
            }
            ;// if the folder doesn't exist
            errorLog(Error("Couldn't determine a Premiere/After Effects window & backup directory doesn't exist", -1, ptf.comms),, 1)
            return false
        }
        if !path := WinGet.ProjPath()
            return false
        ;// win11 by default names an explorer window the folder you're in
        getFolderName := SubStr(path.dir, InStr(path.dir, "\",, -1)+1)

        ;// checking if a win explorer window for the path is open (this might not work if you have win explorer show the entire path in the title)
        if WinExist(getFolderName " ahk_class CabinetWClass",, "Adobe" "Editing Checklist", "Adobe") {
            WinActivate(getFolderName " ahk_class CabinetWClass",, "Adobe")
            return true
        }
        ;// run the path
        RunWait(path.dir)
        if !WinWait(getFolderName " ahk_class CabinetWClass",, 2, "Adobe") {
            tool.Cust("Waiting for project directory to open timed out")
            return false
        }
        WinActivate(getFolderName " ahk_class CabinetWClass",, "Adobe")
        return true
    }

    /**
     * This switchTo function will quickly switch to the specified program. If there isn't an open window of the desired program, this function will open one
     * @param {Integer} x/y/width/height the coordinates you wish to move discord too. Will default to the values listed at the top of the `discord {` class
     */
    static Disc(x := discord.x, y := discord.y, width := discord.width, height := discord.height)
    {
        move() => WinMove(x, y, width, height, discord.winTitle) ;cut repeat visual clutter. Values assigned in discord class
        if WinExist(discord.winTitle)
            {
                WinActivate(discord.winTitle)
                if WinGet.isFullscreen(, discord.winTitle) ;a return value of 1 means it is maximised
                    WinRestore() ;winrestore will unmaximise it
                move() ; just incase it isn't in the right spot/fullscreened for some reason
                tool.Cust("Discord is now active", 500) ;this is simply because it's difficult to tell when discord has focus if it was already open
                return
            }
        Run(discord.path)
        if !WinWait(discord.winTitle,, 2)
            return
        if WinGet.isFullscreen(, discord.winTitle) ;a return value of 1 means it is maximised
            WinRestore() ;winrestore will unmaximise it
        move() ;moves it into position after opening
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Photo() => this().__Win(PS.winTitle, PS.path, "photoshop")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Firefox()
    {
        if !WinExist(browser.firefox.class) {
            Run("firefox.exe")
            return
        }
        if !WinActive(browser.firefox.winTitle) {
            WinActivate(browser.firefox.winTitle)
            return
        }
        this().__OtherFirefoxWindow()
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    __OtherFirefoxWindow()
    {
        if !WinExist(browser.firefox.winTitle) {
                Run("firefox.exe")
                return
            }
        if WinActive(browser.firefox.class) {
                GroupAdd("firefoxes", browser.firefox.class)
                GroupActivate("firefoxes", "r")
                return
            }
        WinActivate(browser.firefox.class)
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static VSCode() => this().__Win(VSCode.winTitle, VSCode.path, "code")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Github() => this().__Win("ahk_exe GitHubDesktop.exe", ptf.LocalAppData "\GitHubDesktop\GitHubDesktop.exe", "git")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Streamdeck() => this().__Win("ahk_exe StreamDeck.exe", ptf.ProgFi "\Elgato\StreamDeck\StreamDeck.exe", "stream", "ahk_class Qt5152QWindowIcon")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Excel() => this().__Win("ahk_exe EXCEL.EXE", ptf.ProgFi "\Microsoft Office\root\Office16\EXCEL.EXE", "xlmain", "ahk_class XLMAIN")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Word() => this().__Win("ahk_exe WINWORD.EXE", ptf.ProgFi "\Microsoft Office\root\Office16\WINWORD.EXE", "wordgroup", "ahk_class wordgroup")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static WindowSpy() => this().__Win("WindowSpy.ahk", ptf.ProgFi "\AutoHotkey\UX\WindowSpy.ahk", "winspy", "ahk_class AutoHotkeyGUI", VSCode.winTitle)

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static PhoneLink() => this().__Win("Phone Link ahk_exe PhoneExperienceHost.exe", ptf["Phone Link"], "PhoneLink", "ahk_class WinUIDesktopWin32WindowClass")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Edge() => this().__Win(browser.edge.winTitle, "msedge.exe", "edge")

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
                    if IME = "Default IME" {
                        GroupActivate "MusicPlayers", "r"
                        continue
                    }
                    if IME != "Default IME"
                        break
                }
            }
        ;window := WinGetTitle("A") ;debugging
        ;tool.Cust(window) ;debugging
    }
}