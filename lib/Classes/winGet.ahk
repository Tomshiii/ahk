/************************************************************************
 * @description A class to contain a library of functions that interact with windows and gain information.
 * @author tomshi
 * @date 2024/03/21
 * @version 1.5.18
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\errorLog>
#Include <Classes\Mip>
#Include <Classes\Editors\Premiere>
; }

class WinGet {
    /** A map containing common win explorer class names that some functions may wish to ignore */
    static explorerIgnoreMap := Mip(
        "Button", 1, "Shell_TrayWnd", 1, "NotifyIconOverflowWindow", 1,
        "Shell_SecondaryTrayWnd", 1, "Progman", 1, "TopLevelWindowForOverflowXamlIsland", 1,
        "SearchHost", 1
    )

    /**
     * This function is a helper function for a few other functions down below and removes repeat code
     * It compares the coordinates passed into it, to the coordinates of all monitors connected to the system
     * If the passed in coordinates are within one of the monitor coordinates, this function will return the monitor number as well as the monitor coordinates that the original coordinates are within
     */
    __Monitor(x, y)
    {
        numberofMonitors := SysGet(80)
        static attempt := 0
        loop numberofMonitors {
            try {
                MonitorGet(A_Index, &left, &Top, &Right, &Bottom)
                if (x > left && x < Right) && (y < Bottom && y > Top)
                    return {monitor: A_Index, left: left, right: right, top: top, bottom: bottom}
            }
        }
    }

    /**
     * This function will grab the monitor that the active window is currently within and return it as well as coordinate information in the form of a function object.
     *
     * *If a window is overlapping multiple monitors, this function may attempt to fullscreen the window first to get the correct monitor.*
     * @param {String} title? allows you to pass a custom winTitle into the function instead of using the currently active window
     * @returns {Object}
     * ```
     * window := winget.WinMonitor()
     * window.monitor      ;// returns monitor the window is within
     * window.left         ;// returns left x position
     * window.right        ;// returns right x position
     * window.top          ;// returns top y position
     * window.bottom       ;// returns bottom y position
     * ```
     */
    static WinMonitor(title?)
    {
        if !IsSet(title) || title = "A"
            this.Title(&title)
        loop {
            ;// attempt to determine the position of the window
            try WinGetPos(&x ,&y,,, title,, "Editing Checklist -")
            catch {
                errorLog(TargetError("Failed to determine the active window", -1),, 1)
                Exit()
            }
            ;// sometimes windows when fullscreened will be at -8, -8 and not 0, 0
            ;// so we just add 10 pixels to both variables to ensure we're in the correct monitor
            monObj := this().__Monitor(x + 10, y + 10)
            if !IsObject(monObj) {
                if A_Index > 2 {
                    errorLog(UnsetError("Failed to get information about the window/monitor relationship", -1)
                                , "The window may be overlapping monitors", 1)
                    Exit()
                }
                ;// if the window is overlapping multiple monitors, fullscreen it first then try again so it is only on the one monitor
                if !winget.isFullscreen(&testWin, title)
                    {
                        WinMaximize(title,, "Editing Checklist -")
                        continue
                    }
            }
            break
        }
        return {monitor: monObj.monitor, left: monObj.left, right: monObj.right, top:monObj.top, bottom: monObj.bottom}
    }

    /**
     * This function will grab the monitor that the mouse is currently within and return it as well as coordinate information in the form of a function object.
     * @param {Integer} x allows you to pass a custom x coordinate
     * @param {Integer} y allows you to pass a custom y coordinate
     *
     * *Both `x` & `y` have to be passed to the function to test a coordinate, otherwise the function will use the current mouse coordinates*
     * @returns {Object}
     * ```
     * ;mouse is within monitor 1 (2560x1440)
     * monitor := winget.MouseMonitor()
     * monitor.monitor      ;// returns 1
     * monitor.left         ;// returns 0
     * monitor.right        ;// returns 2560
     * monitor.top          ;// returns 0
     * monitor.bottom       ;// returns 1440
     * ```
     * @returns {Object} containing the monitor number, the left/right/top/bottom pixel coordinate
     */
    static MouseMonitor(x?, y?)
    {
        if !IsSet(x?) || !IsSet(y?) {
            coord.s()
            MouseGetPos(&x, &y)
        }
        monObj := this().__Monitor(x, y)
        if !IsObject(monObj)
            {
                errorLog(TargetError("Failed to get the requested monitor", -1),, 1)
                Exit()
            }
        return {monitor: monObj.monitor, left: monObj.left, right: monObj.right, top:monObj.top, bottom: monObj.bottom}
    }


    /**
     * This function gets and returns the title for the current active window, autopopulating the `title` variable
     * @param {VarRef} title populates with the active window
     * @param {Boolean} exitOut determines whether the active thread will `Exit` if it cannot determine the title. Defaults to `true`
     * @returns {String} returns the title
     */
    static Title(&title?, exitOut := true)
    {
        try {
            check := WinGetProcessName("A")
            ignore := (check = "AutoHotkey64.exe") ? WinGetTitle(check) : ""
            title := WinGetTitle("A",, ignore)
            if this.isProc(title) || !IsSet(title) || title = "" || title = "Program Manager"
                throw
            return title
        } catch {
            block.Off()
            if exitOut = true {
                errorLog(UnsetError("Couldn't determine the active window or you're attempting to interact with an ahk GUI", -1),, 1)
                Exit()
            }
        }
    }

    /**
     * This function is designed to check what state the active window is in. If the window is maximised it will return 1, else it will return 0. It will also populate the `title` variable with the current active window
     * @param {VarRef} title is the active window, this function will populate the `title` variable with the active window
     * @param {String} window is if you wish to provide the function with the window instead of relying it to try and find it based off the active window, this paramater can be omitted
     * @returns {Boolean} returns whether the desired window is maximised. A return value of 1 means it is maximised
     */
    static isFullscreen(&title?, window := false)
    {
        title := (window != false) ? window : this.Title(&title)
        ;// this block checks for the desktop or some common win explorer classes we want to ignore. You don't want the desktop trying to get fullscreened unless you want to replicate the classic windows xp lagscreen
        if (this.isProc(WinExist(title)) || (title = "Program Manager"))
            title := ""
        try {
            return WinGetMinMax(title,, "Editing Checklist -") ;a return value of 1 means it is maximised
        } catch {
            errorLog(UnsetError("Couldn't determine the active window or you're attempting to interact with an ahk GUI", -1),, 1)
            block.Off()
            Exit()
        }
    }

    /**
     * Attempts to determine the year of the current open adobe program
     * @param {String} progCheck is a passed in parameter containing the title of the current project
     * @param {String} which which program the user is attempting to find the name of. Must be either `AE` or `Premiere`
     * @returns {String} the YYYY of the currently open adobe program
     */
    __determineAdobeYear(progCheck, which) {
        try {
            ;// attempt to pull the year from the title
            if InStr(SubStr(progCheck, 1, 27), "(Beta)",, 1, 1) {
                return "(Beta)"
            }
            determineYear := SubStr(progCheck, InStr(SubStr(progCheck, 1, 25), "20",, 1, 1), 4)
        } catch {
            ;// fallback to `ptf {`
            switch which {
                case "AE":       determineYear := "20" ptf.AEYearVer
                case "Premiere": determineYear := "20" ptf.PremYearVer
            }
        }
        return determineYear
    }

    /**
     * Attempts to determine the title of the current open adobe program
     * @param {String} which which program the user is attempting to find the name of. Must be either `AE` or `Premiere`
     * @returns {String} the title of the currently open adobe program
     */
    __determineAdobeTitle(which) {
        if (progCheck := WinGetTitle(editors.%which%.class)) = ""
            progCheck := WinGetTitle(editors.%which%.winTitle)
        return progCheck
    }

    /**
     * This function is to reduce repeat code for the adobe name functions below.
     * @param {String} which is defining whether after effects or premiere should be checked
     */
    __AdobeName(which, &progCheck?, &titleCheck?, &saveCheck?) {
        if (which != "AE" && which != "Premiere") {
            ;// throw
            errorLog(ValueError("Incorrect Parameter (#1) Passed to function", -1, which), "Parameter must be 'AE' or 'Premiere'",, 1)
        }
        try {
            if !WinExist(editors.%which%.winTitle)
                return {winTitle: false, titleCheck: -1, saveCheck: -1}
            progCheck := this.__determineAdobeTitle(which)
            adobeYear := this.__determineAdobeYear(progCheck, which)
            switch which {
                ;// we add the " -" to accomodate a window that is literally just called "Adobe -- [Year]"
                case "AE":       title := "Adobe After Effects " adobeYear " -"
                case "Premiere": title := "Adobe Premiere Pro " adobeYear " -"
            }
            titleCheck := InStr(progCheck, title)
            saveCheck := (SubStr(progCheck, -1, 1) = "*") ? true : false
            return {winTitle: progCheck, titleCheck: true, saveCheck: saveCheck}
        } catch as e {
            block.Off()
            tool.Cust("Couldn't determine the titles of Adobe programs")
            errorLog(e)
            return {winTitle: false, titleCheck: -1, saveCheck: -1}
        }
    }

    /**
     * This function will grab the title of premiere if it exists and check to see if a save is necessary
     * @param {VarRef} premCheck is the complete title of premiere
     * @param {VarRef} titleCheck is checking to see if the premiere window is available to save based off what's found in the current title. Will return `-1` if premiere cannot be found or a boolean false if unavailable to save. Otherwise it will contain a number greater than 0
     * @param {VarRef} saveCheck is checking for an * in the title to say a save is necessary. Will return `-1` if premiere cannot be found or a boolean false if save is not required. Otherwise it will return boolean true
     * @returns {Object/Boolean}
     * ```
     * ;// if Premiere isn't open `winget.PremName()` will return 0/false
     * prem := winget.PremName()
     * prem.winTitle        ;// is the current title of the open premiere window
     * prem.titleCheck      ;// a boolean value of if the window is available to save
     * prem.saveCheck       ;// a boolean value of if a save is currently necessary
     * ```
     */
    static PremName(&premCheck?, &titleCheck?, &saveCheck?) {
        premiere := this().__AdobeName("Premiere", &premCheck?, &titleCheck?, &saveCheck?)
        if !premiere.winTitle
            return false
        return {winTitle: premiere.winTitle, titleCheck: premiere.titleCheck, saveCheck: premiere.saveCheck}
    }

    /**
     * This function will grab the title of after effects if it exists and check to see if a save is necessary
     * @param {VarRef} aeCheck is the complete title of after effects
     * @param {VarRef} titleCheck is checking to see if the after effects window is available to save based off what's found in the current title. Will return unset if after effects cannot be found or a boolean false if unavailable to save. Otherwise it will contain a number greater than 0
     * @param {VarRef} saveCheck is checking for an * in the title to say a save is necessary.  Will return unset if after effects cannot be found or a boolean false if save is not required. Otherwise it will return boolean true
     * @returns {Object/Boolean}
     * ```
     * ;// if AE isn't open `winget.AE()` will return 0/false
     * ae := winget.AEName()
     * ae.winTitle        ;// is the current title of the open ae window
     * ae.titleCheck      ;// a boolean value of if the window is available to save
     * ae.saveCheck       ;// a boolean value of if a save is currently necessary
     * ```
     */
    static AEName(&aeCheck?, &titleCheck?, &saveCheck?) {
        ae := this().__AdobeName("AE", &aeCheck?, &titleCheck?, &saveCheck?)
        if !ae.winTitle
            return false
        return {winTitle: ae.winTitle, titleCheck: (IsSet(titleCheck) ? ae.titleCheck : unset), saveCheck: (IsSet(saveCheck) ? ae.saveCheck : unset)}
    }

    /**
     * This function is designed to retrieve the name of the client using some string manipulation of the dir path within Premiere's title. It uses `ptf.comms` as the "root" dir and expects the next folder in the path to be the client name.
     * @returns {String} The clients name
     */
    static ProjClient()
    {
        ;// if the user doesn't have either editors active
        if !WinExist(editors.Premiere.winTitle) && !WinExist(editors.AE.winTitle) {
                errorLog(TargetError("Couldn't determine an editor window", -1),, 1)
                return false
            }
        ;// attempt to grab title
        if !this.PremName(&premCheck) && !this.AEName(&aeCheck) {
            errorLog(TargetError("Unable to determine the client as the title is unable to be obtained", -1),, 1)
            return false
        }
        path := IsSet(premCheck) ? obj.SplitPath(premCheck) : obj.SplitPath(aeCheck)
        ;// if the comms folder isn't in the title path
        if !InStr(path.dir, ptf.comms) {
                errorLog(UnsetError("``ptf.comms`` folder not found in Premiere title", -1, path.dir),, 1)
                return false
            }
        return ClientName := SubStr(
            premCheck,                                                      ;// string
            start := (InStr(premCheck, ptf.comms) + StrLen(ptf.comms) + 1), ;// starting pos
            InStr(premCheck, "\",, start, 1) - start                        ;// length
        )
    }

    /**
     * A function to recover the path within the title of either `Premiere Pro` or `After Effects`
     * @returns {Object}
     * ```
     * ;// "E:\comms\tomshi\video\project.prproj"
     * projPath := winget.ProjPath()
     * projPath.Path       ; E:\comms\tomshi\video\project.prproj
     * projPath.Name       ; project.prproj
     * projPath.Dir        ; E:\comms\tomshi\video
     * projPath.Ext        ; proj
     * projPath.NameNoExt  ; project
     * projPath.Drive      ; E:
     * ```
     */
    static ProjPath()
    {
        if !WinExist(Editors.Premiere.winTitle) && !WinExist(Editors.AE.winTitle)
            return false
        if !WinExist(Editors.Premiere.winTitle) || !prem.__checkPremRemoteDir("projPath") || !entirePath := prem.__remoteFunc("projPath", true) {
            ;// attempt to get the editors name
            try {
                if WinExist(Editors.Premiere.winTitle)
                    WinGet.PremName(&Name, &titlecheck)
                else if WinExist(Editors.AE.winTitle)
                    WinGet.AEName(&Name, &titlecheck)
            }
            ;// if the name returns blank
            if (!titlecheck || titlecheck = -1) {
                tool.Cust("You're on a part of an Editor that won't contain the project path", 2000)
                return false
            }
            ;// string manipulation to get the path
            ;// getting the path
            entirePath := SubStr(name							;// string
                , dashLocation := InStr(Name, "-") + 2			;// start location
                , StrLen(Name) - dashLocation)                  ;// length
        }
        ;// splitting the path
        path := obj.SplitPath(entirePath)
        ;// return object
        return {Path: entirePath, Name: path.Name, Dir: path.Dir, Ext: path.Ext, NameNoExt: path.NameNoExt, Drive: path.Drive}
    }

    /**
     * This function will grab the proccess ID of the current active window
     * @param {VarRef} id is the processname of the active window, we want to pass this value back to the script
     * @returns {String} returns the processname of the active window
     */
    static ID(&id?)
    {
        try {
            id := WinGetProcessName("A")
            if WinActive("ahk_exe explorer.exe")
                id := "ahk_class CabinetWClass"
            return id
        } catch {
            errorLog(TargetError("Couldn't grab information about the active window", -1),, 1)
            return false
        }
    }

    /**
     * A function that returns the path of an open explorer window. Will work with win11 tabs
     * @link Original code found here by lexikos: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=109907
     * @param {Integer} hwnd You can pass in the hwnd of the window you wish to focus, else this parameter can be omitted and it will use the active window
     * @returns {String} the directory path of the explorer window
     */
    static ExplorerPath(hwnd := WinExist("A"))
    {
        activeTab := 0
        try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd) ; File Explorer (Windows 11)
        catch
            return false
        for w in ComObject("Shell.Application").Windows {
            if w.hwnd != hwnd
                continue
            if activeTab { ; The window has tabs, so make sure this is the right one.
                static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
                shellBrowser := ComObjQuery(w, IID_IShellBrowser, IID_IShellBrowser)
                ComCall(3, shellBrowser, "uint*", &thisTab:=0)
                if thisTab != activeTab
                    continue
            }
            return w.Document.Folder.Self.Path
        }
        return false
    }

    /**
     * A function to return the size of a path in `bytes` by default.
     * @link Code from: `DepthTrawler` : https://discord.com/channels/115993023636176902/734109033832906874/1053085736196382771 (ahk discord)
     * @param {String} path is the filepath you wish to check
     * @param {Integer} option decides if you wish for the return value to be something other than `bytes`.
     *
     * `1`: returns `MB`
     *
     * `2`: returns `GB`
     *
     * `3`: returns `TB`
     * @returns {Integer} the filesize in `bytes` by default or in the option selected
     */
    static FolderSize(path, option?) {
        if !IsSet(option)
            return ComObject("Scripting.FileSystemObject").GetFolder(path).Size
        if option > 3 || option < 1 || !IsInteger(option) {
                ;// throw
                errorLog(ValueError("Parameter #2 invalid - Value Out of Range or Not an Integer", -1, option),,, 1)
            }
        ;// you convert bytes to another unit by x / (1024^y)
        ;// ie. bytes => MB ; x / (1024x1024x1024) OR x / 1024^2
        return (ComObject("Scripting.FileSystemObject").GetFolder(path).Size)/(1024**(option+1))
    }

    /**
     * This function checks the desired window to see if it is `ahk_exe explorer.exe` **&&** has a class name that correlates with a known classname specified in a map contained within `WinGet` (`explorerIgnoreMap`)
     * @param {Integer/String} hwnd the hwnd (or window parameter) of the window you wish to check. This value gets passed into `WinGetProcessName()` & `WinGetClass()` Defaults to the active window.
     * @returns {Boolean} returns `true` if the window is one contained within the Map, else returns `false`
     */
    static isProc(hwnd := "A") {
        ;// get processname/class of the first window in the list
        try {
            proc  := WinGetProcessName(hwnd)
            class := WinGetClass(hwnd)
        } catch {
            return false
        }
        ;// check to see if it's a win explorer process identified in a map within this class
        if proc = "explorer.exe" && this.explorerIgnoreMap.Has(class)
            return true
        return false
    }

    /**
     * Returns a fully qualified path
     * @link https://www.autohotkey.com/boards/viewtopic.php?t=120582&p=535232
     * @author SKAN
     * @param {String} path the path to your desired file/path
     * @returns {String} the path
     */
    static pathU(path) {
        OutFile := Format("{:260}", "")
        DllCall("Kernel32\GetFullPathNameW", "str", path, "uint",260, "str", OutFile, "ptr", 0)
        ; DllCall("Shell32\PathYetAnotherMakeUniqueName", "str", OutFile, "str", OutFile, "ptr", 0, "ptr", 0)
        return OutFile
    }
}