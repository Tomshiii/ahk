/************************************************************************
 * @description A class to contain often used functions to open/cycle between windows of a certain type.
 * @author tomshi
 * @date 2024/06/25
 * @version 1.3.10
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <GUIs\musicGUI>
;programs
#Include <Classes\Apps\VSCode>
#Include <Classes\Apps\Discord>
#Include <Classes\Apps\Slack>
#Include <Classes\Editors\After Effects>
#Include <Classes\Editors\Premiere>
#Include <Classes\Editors\Photoshop>
#Include <Classes\keys>
#Include <Classes\winget>
#Include <Classes\errorLog>
;funcs
#Include <Functions\getHotkeys>
#Include <Functions\generateAdobeShortcut>
; }

class switchTo {

    ;// vars for `adobeProject()`
    static adobeProjCount := 0
    static adobeProjCopied := false

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
        ;// the below values will be ignored (but only if `ignoreString` is added to the respective `GroupAdd` down below)
        ignore := Map("ahk_exe hamachi-2-ui.exe", 1)
        ignoreString := ""
        for k, v in ignore
            ignoreString := ignoreString A_Space k
        if !WinExist("ahk_class CabinetWClass") && !WinExist("ahk_class #32770") {
            Run("explorer.exe")
            if WinWait("ahk_class CabinetWClass",, 2)
                WinActivate("ahk_class CabinetWClass") ;in win11 running explorer won't always activate it, so it'll open in the backround
            return
        }
        GroupAdd("explorers", "ahk_class CabinetWClass")
        GroupAdd("explorers", "ahk_class #32770", ignoreString) ;these are usually save dialoge windows from any program
        GroupAdd("explorers", "ahk_class OperationStatusWindow") ;these are usually file transfer windows
        if WinActive("ahk_exe explorer.exe")
            GroupActivate("explorers", "r")
        else if WinExist("ahk_class CabinetWClass") || WinExist("ahk_class #32770") || WinExist("ahk_class OperationStatusWindow")
            WinActivate
    }

    /**
     * This function when called will close all windows of the desired program EXCEPT the active one. Helpful when you accidentally have way too many windows open.
     * @param {String} program is the ahk_class or ahk_exe of the program you want this function to close
     * @param {Boolean} [ttip=true] determine whether you wish for the function to present a tooltip upon completion that displays how many windows were closed
     */
    static closeOtherWindow(program, ttip := true)
    {
        totalWindowsClosed := 0
        storeActive := ""
        ;// we run a loop here that checks itself to ensure that all windows are closed
        ;// as if an explorer window for example contains multiple tabs you will end up with left over windows
        loop {
            value := WinGetList(program) ;gets a list of all open windows
            if value.Length <= 1
                break
            totalWindowsClosed := (totalWindowsClosed = 0) ? value.length - 1 : totalWindowsClosed
            for this_value in value {
                if storeActive != "" && this_value = storeActive
                    continue
                if A_Index = 1 && storeActive = "" {
                    storeActive := this_value
                    continue
                }
                WinClose(this_value)
            }
        }
        if ttip && totalWindowsClosed > 0
            tool.Cust(totalWindowsClosed " other window(s) closed") ;tooltip to display how many explorer windows are being closed
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

    /** This function will check for the existence of Adobe Creative cloud. For use with adobe scripts. This is necessary because unless CC is opened before the program of choice, some synced assets (ie. fonts) will not load within the program and may silently default to the next option in the list. */
    __checkCC() {
        dct := A_DetectHiddenWindows
        ccTitle := "Creative Cloud Desktop"
        DetectHiddenWindows(1)
        if WinExist(ccTitle) {
            A_DetectHiddenWindows := dct
            return true
        }
        try Run(ptf["AdobeCC"],,, &PID)
        catch {
            ;// throw
            A_DetectHiddenWindows := dct
            errorLog(TargetError("File Doesn't Exist", -1), "Program may not be installed or has been installed in an unexpected location.",, 1)
            return
        }
        if !WinWait("ahk_pid " PID,, 5) {
            A_DetectHiddenWindows := dct
            return false
        }
        sleep 5000
        WinClose("ahk_pid " PID)
        A_DetectHiddenWindows := dct
        return true
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program.
     * This function will run Premiere using the Premiere version defined within `settingsGUI()`
     * This function requires a shortcut file to be properly generated within `settingsGUI()` (This can be achieved by adjusting the year or by checking then unchecking the beta checkbox)
     * @param {Boolean} openCC determine whether this function will check for the existence of `Creative Cloud` and open it before proceeding
     */
    static Premiere(openCC := true)
    {
        if openCC = true {
            if !this().__checkCC() {
                MsgBox(A_ThisFunc "() attempted to open ``Adobe Creative Cloud`` and failed. This can happen if the user has installed it to an unexpected location. Please fix the directory link within the function to return functionality to this script." )
                return
            }
        }
        this().__adobeSwitch(prem.class, prem.path, "Adobe Premiere Pro", "prem")
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program.
     * This function will run AE using the after effects version defined within `settingsGUI()`.
     * This function requires a shortcut file to be properly generated within `settingsGUI()` (This can be achieved by adjusting the year or by checking then unchecking the beta checkbox)
     *
     * If AE is already open, this function will also check to make sure AE isn't transparent.
     * @param {Boolean} openCC determine whether this function will check for the existence of `Creative Cloud` and open it before proceeding
     */
    static AE(openCC := true)
    {
        ;// cut repeat code
        runae() {
            try {
                Run(AE.path)
            } catch {
                try {
                    UserSettings := UserPref()
                    generateAdobeShortcut(UserSettings, "Adobe After Effects", UserSettings.ae_year)
                    UserSettings.__delAll()
                    UserSettings := ""
                    sleep 50
                    Run(AE.path)
                } catch {
                    errorLog(TargetError("File Doesn't Exist", -1), "Program may not be installed or shortcut hasn't been generated correctly in ``..\Support Files\shortcuts\``", 3)
                    return
                }
            }
            if WinWait(AE.winTitle,, 2)
                WinActivate(AE.winTitle)
        }

        checkTrans() {
            try {
                checkTran := WinGetTransparent(editors.AE.winTitle)
                if IsInteger(checkTran) && checkTran != 255
                    WinSetTransparent(255, AE.winTitle)
            }
        }

        bringTopActivate() {
            WinMoveTop(ae.winTitle)
            WinActivate(ae.winTitle)
            if WinExist("Mocha AE ahk_exe mocha4ae_adobe.exe",, "Mocha UI") || WinExist("Mocha AE * ahk_exe mocha4ae_adobe.exe",, "Mocha UI")
                try WinActivate()
        }

        if WinExist(ae.winTitle)
            checkTrans()
        /** checks the current project's working directory for any after effects files. If none are present, ae will simply be opened. If 1 is present, it will be opened. If multiple are present, the user will be prompted to select one */
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

        if openCC = true {
            if !this().__checkCC() {
                MsgBox("switchTo." A_ThisFunc "() attempted to open Creative Cloud and failed. This can happen if the user has installed it to an unexpected location. Please fix the directory link within the function to return functionality to this script." )
                return
            }
        }

        premExist := WinExist(prem.winTitle)
        aeExist   := WinExist(AE.winTitle)

        switch aeExist {
            case false:
                if premExist {
                    premTitle()
                    return
                }
                runae()
            default:
                if premExist {
                    try {
                        Name := WinGet.AEName()
                        if !InStr(Name.winTitle, "\",, -1) ;if there's a slash in the title, it means a project is open
                            premTitle()
                    }
                }
                ;// if prem doesn't exist
                checkTrans()
                try bringTopActivate()
                return
        }
    }

    /**
     * This function opens the current `Premiere Pro`/`After Effects` project filepath in windows explorer. If prem/ae isn't open it will attempt to open the `ptf.comms` folder.
     * Double pressing the activation hotkey for this function will instead copy the project path to the user's clipboard
     * @param {String} optionalPath allows the user to navigate to a directory beyond (or before) where the project file is located. See example #1 for more.
     * @returns {Boolean} `true/false` whether the function succeeded or failed
     * ```
     * ;// will open the folder before where the project file is located
     * switchTo.adobeProject("..\")
     *
     * ;// will open the `videos` folder in the same dir as the project folder (if it exists)
     * switchTo.adobeProject("\videos")
     * ```
     */
    static adobeProject(optionalPath := "") {
        this.adobeProjCount++
        ;// gives the user time to double press
        SetTimer(__action, -200)

        __action(*) {
            ;// if an editor isn't open
            if !WinExist("Adobe Premiere Pro") && !WinExist("Adobe After Effects") {
                ;// if the commissions folder doesn't exist
                if !DirExist(ptf.comms) {
                    errorLog(Error("Couldn't determine a Premiere/After Effects window & backup directory doesn't exist", -1, ptf.comms),, 1)
                    return false
                }
                ;// opening the commissions folder
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
            if !path := WinGet.ProjPath()
                return false
            if DirExist(newPath := WinGet.pathU(path.dir "\" optionalPath)) {
                path.dir := newPath
                newDir := obj.SplitPath(SubStr(newPath, 1, StrLen(newPath)-1))
                path.name := newDir.name
            }
            ;// win11 by default names an explorer window the folder you're in
            getFolderName := path.name

            ;// handles the logic required to enable double tap to copy path to clipboard
            if this.adobeProjCount > 1 {
                this.adobeProjCount := 0
                this.adobeProjCopied := true
                A_Clipboard := path.dir
                tool.Cust("Project path copied to clipboard")
                return
            }
            this.adobeProjCount := 0
            ;// halts the second timer if the above block was fired
            if this.adobeProjCopied = true {
                this.adobeProjCopied := false
                return
            }

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
    }

    /**
     * This switchTo function will quickly switch to the specified program. If there isn't an open window of the desired program, this function will open one
     * @param {Boolean} doMove defines whether you want the function to move discord to a certain position. By default it's the coordinates set within the `Discord` class
     * @param {Integer} x/y/width/height an object containing the coordinates you wish to move discord too. Will default to the values listed at the top of the `discord {` class
     * ```
     * switchTo.Disc(true, {x: discord.x,
     *                      y: discord.y,
     *                      width: discord.width,
     *                      height: discord.height})
     * ```
     */
    static Disc(doMove := false, coords?)
    {
        if !IsSet(coords)
            coords := {x: discord.x, y: discord.y, width: discord.width, height: discord.height}
        move() => WinMove(coords.x, coords.y, coords.width, coords.height, discord.winTitle) ;cut repeat visual clutter. Values assigned in discord class
        if WinExist(discord.winTitle) {
            WinActivate(discord.winTitle)
            if doMove = true {
                if WinGet.isFullscreen(, discord.winTitle) ;a return value of 1 means it is maximised
                    WinRestore() ;winrestore will unmaximise it
                move() ; just incase it isn't in the right spot/fullscreened for some reason
            }
            tool.Cust("Discord is now active", 500) ;this is simply because it's difficult to tell when discord has focus if it was already open
            return
        }
        Run(discord.path)
        if !WinWait(discord.winTitle,, 2)
            return
        if doMove = true {
            if WinGet.isFullscreen(, discord.winTitle) ;a return value of 1 means it is maximised
                WinRestore() ;winrestore will unmaximise it
            move() ;moves it into position after opening
        }
    }

    /**
     * A function to cut repeat code. Handles swapping too/running desired adobe program as well as generating shortcut if one does not exist
     * @param {String} adobeClass the class value usually determined using window spy. Can use the values at the top of the respective program's class within this repo (ie. prem.class/ps.class)
     * @param {String} path the path to the shortcut that this function will attempt to run. Can use the values at the top of the respective program's class within this repo (ie. prem.path/ps.path)
     * @param {String} which the string that will be passed to `generateAdobeShortcut(, x, )`.
     * @param {String} year short name used within `settings.ini` to determine which program you are targeting (ie. prem/ae/ps)
    */
    __adobeSwitch(adobeClass, path, which, year) {
        if WinExist(adobeClass) {
            WinActivate(adobeClass)
            return
        }
        try {
            Run(path)
        } catch {
            try {
                UserSettings := UserPref()
                generateAdobeShortcut(UserSettings, which, UserSettings.%year%_year)
                UserSettings.__delAll()
                UserSettings := ""
                sleep 50
                Run(path)
            } catch {
                errorLog(TargetError("File Doesn't Exist", -1), "Program may not be installed or shortcut hasn't been generated correctly in ``..\Support Files\shortcuts\``", 3)
                return
            }
        }
        return
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     */
    static Photoshop() => this().__adobeSwitch(PS.class, PS.path, "Photoshop", "ps")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one.
     * This function may require firefox to be properly installed to the system path
     */
    static Firefox()
    {
        if !WinExist(browser.firefox.class) || (WinExist(browser.firefox.class) && WinActive(browser.firefox.winTitle)) {
            this().__Win(browser.Firefox.winTitle, "firefox.exe", "firefox")
            return
        }
        this().__OtherFirefoxWindow()
    }

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     * This function may require firefox to be properly installed to the system path
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

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static VSCode() => this().__Win(VSCode.winTitle, VSCode.path, "code")

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static Github() => this().__Win("ahk_exe GitHubDesktop.exe", ptf.LocalAppData "\GitHubDesktop\GitHubDesktop.exe", "git")

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static Streamdeck() => this().__Win("ahk_exe StreamDeck.exe", ptf.ProgFi "\Elgato\StreamDeck\StreamDeck.exe", "stream", "ahk_class Qt5152QWindowIcon")

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static Excel() => this().__Win("ahk_exe EXCEL.EXE", ptf.ProgFi "\Microsoft Office\root\Office16\EXCEL.EXE", "xlmain", "ahk_class XLMAIN")

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static Word() => this().__Win("ahk_exe WINWORD.EXE", ptf.ProgFi "\Microsoft Office\root\Office16\WINWORD.EXE", "wordgroup", "ahk_class wordgroup")

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static WindowSpy() => this().__Win("WindowSpy.ahk", ptf.ProgFi "\AutoHotkey\UX\WindowSpy.ahk", "winspy", "ahk_class AutoHotkeyGUI", VSCode.winTitle)

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static PhoneLink() => this().__Win("Phone Link ahk_exe PhoneExperienceHost.exe", ptf["Phone Link"], "PhoneLink", "ahk_class WinUIDesktopWin32WindowClass")

    /**
     * This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
     * @param {String} run the filepath of the file you wish for this function to run if the desired programs aren't already open
     * @param {Object/Boolean} move to determine whether you wish for the function to move the desired program to a specific location. Simply pass `true` to move to a predetermined location, or pass an object containing `{x: , y: , width: , height: }`
     */
    static PhoneProgs(run := A_AppData "\..\Local\Programs\beeper\Beeper.exe", move?) {
        GroupAdd("phoneStuff", "ahk_exe PhoneExperienceHost.exe")
        GroupAdd("phoneStuff", "ahk_exe ahk_exe Beeper.exe")
        this().__Win("ahk_group phoneStuff", run, "phones")
        if !IsSet(move) || (move != true && !IsObject(move))
            return
        coord.s()
        if move = true
            move := {x: 3440, y: -805, width: 740, height: 1080}
        try WinMove(move.x, move.y, move.width, move.height, "ahk_group phoneStuff")
    }

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static Edge() => this().__Win(browser.edge.winTitle, "msedge.exe", "edge")

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static Chrome(focusURL := true) {
        if focusURL = true
            highlightBar := !WinExist(browser.Chrome.winTitle) ? true : false
        this().__Win(browser.Chrome.winTitle, "chrome.exe", "chrome")
        if highlightBar ?? false = true
            SendInput("{F6}")
    }

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
    static Slack() => this().__Win("ahk_exe slack.exe", slack.path, "slack")

    /** This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one */
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
                    if IME != "Default IME" && IME != ""
                        break
                    GroupActivate "MusicPlayers", "r"
                }
            }
        ;window := WinGetTitle("A") ;debugging
        ;tool.Cust(window) ;debugging
    }

    /**
     * This function will attempt to open the local copy of the ahk documentation.
     * If the `modiferKey` key set within the first param is held, it will attempt to search the highlighted word within the documentation
     * @param {String} modifierKey a key you'd like to hold to indicate that you wish to search the highlighted word within the documentation
     */
    static ahkDocs(modifierKey := "RShift") {
        ;// logic if ctrl isn't being held
        if !GetKeyState(modifierKey, "P") {
            LinkClicked("", false)
            return
        }
        previous := ClipboardAll()
        A_Clipboard := "" ;clears the clipboard
        Send("^c")
        if !ClipWait(1) { ;if the clipboard doesn't contain data after 1s this block fires
            LinkClicked("", false)
            A_Clipboard := previous
            return
        }
        LinkClicked(A_Clipboard)
        A_Clipboard := previous

        /**
         * Open the local ahk documentation if it can be found
         * else open the online documentation
         *
         * This function originated in `ui-dash.ahk` found in `C:\Program Files\AutoHotkey\UX`
         * @param {String} command is what you want to search for in the docs
         */
        LinkClicked(command, search := true) {
            path := obj.SplitPath(A_AhkPath)
            ;// hopefully this never has to fire as browsers are unpredictable and there's no easy way to wait for things to load
            if !FileExist(chm := path.dir '\AutoHotkey.chm')
                {
                    if !WinExist("AutoHotkey v2")
                        RunWait("https://www.autohotkey.com/docs/v2/index.htm")
                    else
                        {
                            WinActivate("AutoHotkey v2")
                            goto find
                        }
                    sleep 1500
                    if !WinExist("Quick Reference | AutoHotkey v2") {
                        tool.Cust("something went wrong")
                        return
                    }
                    if WinExist("Quick Reference | AutoHotkey v2") && !WinActive("Quick Reference | AutoHotkey v2")
                        WinActivate("Quick Reference | AutoHotkey v2")
                    goto find
                }
            if !WinExist("AutoHotkey v2 Help") {
                Run('hh.exe "ms-its:' chm '::docs/"Program.htm">How to use the program',,, &id)
                WinWait("ahk_pid " id)
                sleep 200
            }
            if !WinActive("AutoHotkey v2 Help") {
                WinActivate()
                if !WinWaitActive(,, 1)
                    WinActivate()
                ;// if the window is minimised, then activated, chances are it won't actually accept any inputs
                ;// so we simulate a click on the window to alert it we want to input commands
                ControlClick("X216 Y72")
                sleep 200
            }
            find:
            if search = false
                return
            SendInput("!s")
            SendInput("^a")
            SendInput("{BackSpace}")
            if command = ""
                return
            SendInput(command)
            SendInput("{Enter}")
        }
    }
}