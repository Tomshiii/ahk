/************************************************************************
 * @description A class to contain a library of functions that interact with windows and gain information.
 * @author tomshi
 * @date 2023/01/01
 * @version 1.3.2
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Functions\errorLog>
; }

class WinGet {
    /**
     * This function will grab the monitor that the mouse is currently within and return it as well as coordinate information in the form of a function object. ie if your mouse is within monitor 1 having code `monitor := getMouseMonitor()` would make `monitor.monitor` = 1
     * @returns {object} containing the monitor number, the left/right/top/bottom pixel coordinate
     */
    static MouseMonitor()
    {
        coord.s()
        MouseGetPos(&x, &y)
        numberofMonitors := SysGet(80)
        loop numberofMonitors {
            try {
                MonitorGet(A_Index, &left, &Top, &Right, &Bottom)
                if x > left && x < Right
                    {
                        if y < Bottom && y > Top
                            ;MsgBox(x " " y "`n" left " " Right " " Bottom " " Top "`nwithin monitor " A_Index)
                            return {monitor: A_Index, left: left, right: right, top: top, bottom: bottom}
                    }
                if A_Index >= numberofMonitors
                    throw IndexError("Couldn't find the monitor", -1, numberofMonitors)
            }
            catch IndexError as e {
                block.Off() ;to stop the user potentially getting stuck
                tool.Cust(A_ThisFunc "() failed to get the monitor that the mouse is within", 2.0)
                errorLog(e)
                Exit()
            }
        }
    }

    /**
     * This function gets and returns the title for the current active window, autopopulating the `title` variable
     * @param {VarRef} title populates with the active window
     */
    static Title(&title?)
    {
        try {
            check := WinGetProcessName("A")
            if check = "AutoHotkey64.exe"
                ignore := WinGetTitle(check)
            else
                ignore := ""
            title := WinGetTitle("A",, ignore)
            if !IsSet(title) || title = "" || title = "Program Manager"
                throw UnsetError("Couldn't determine the active window or you're attempting to interact with an ahk GUI", -1, title)
            return title
        } catch UnsetError as e {
            errorLog(e,, 1)
            block.Off()
            Exit()
        }
    }

    /**
     * This function is designed to check what state the active window is in. If the window is maximised it will return 1, else it will return 0. It will also populate the `title` variable with the current active window
     * @param {var} title is the active window, this function will populate the `title` variable with the active window
     * @param {String} window is if you wish to provide the function with the window instead of relying it to try and find it based off the active window, this paramater can be omitted
     */
    static isFullscreen(&title?, window := false)
    {
        if window != false
            {
                title := window
                goto skip
            }
        this.Title(&title)
        skip:
        if title = "Program Manager" ;this is the desktop. You don't want the desktop trying to get fullscreened unless you want to replicate the classic windows xp lagscreen
            title := ""
        try {
            return WinGetMinMax(title,, "Editing Checklist -") ;a return value of 1 means it is maximised
        } catch as e {
            tool.Cust(A_ThisFunc "() couldn't determine the active window")
            errorLog(e)
            block.Off()
            Exit
        }
    }

    /**
     * This function will grab the title of premiere if it exists and check to see if a save is necessary
     * @param {VarRef} premCheck is the complete title of premiere
     * @param {VarRef} titleCheck is checking to see if the premiere window is available to save based off what's found in the current title. Will return unset if premiere cannot be found or a boolean false if unavailable to save. Otherwise it will contain a number greater than 0
     * @param {VarRef} saveCheck is checking for an * in the title to say a save is necessary. Will return unset if premiere cannot be found or a boolean false if save is not required. Otherwise it will return boolean true
     * @returns {Object}
     * ```
     * prem := winget.PremName()
     * prem.winTitle        ;// is the current title of the open premiere window
     * prem.titleCheck      ;// a boolean value of if the window is available to save
     * prem.saveCheck       ;// a boolean value of if a save is currently necessary
     * ```
     */
    static PremName(&premCheck?, &titleCheck?, &saveCheck?)
    {
        try {
            if !WinExist(editors.Premiere.winTitle)
                return {winTitle: false, titleCheck: unset, saveCheck: unset}
            premCheck := WinGetTitle(editors.Premiere.class)
            if premCheck = ""
                premCheck := WinGetTitle(editors.Premiere.winTitle)
            titleCheck := InStr(premCheck, "Adobe Premiere Pro 20" ptf.PremYearVer " -") ;we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
            saveCheck := (SubStr(premCheck, -1, 1) = "*") ? true : false
            return {winTitle: premCheck, titleCheck: true, saveCheck: saveCheck}
        } catch as e {
            block.Off()
            tool.Cust("Couldn't determine the titles of Adobe programs")
            errorLog(e)
            return {winTitle: false, titleCheck: unset, saveCheck: unset}
        }
    }

    /**
     * This function will grab the title of after effects if it exists and check to see if a save is necessary
     * @param {VarRef} aeCheck is the complete title of after effects
     * @param {VarRef} titleCheck is checking to see if the after effects window is available to save based off what's found in the current title. Will return unset if after effects cannot be found or a boolean false if unavailable to save. Otherwise it will contain a number greater than 0
     * @param {VarRef} saveCheck is checking for an * in the title to say a save is necessary.  Will return unset if after effects cannot be found or a boolean false if save is not required. Otherwise it will return boolean true
     * @returns {Object}
     * ```
     * ae := winget.AEName()
     * ae.winTitle        ;// is the current title of the open ae window
     * ae.titleCheck      ;// a boolean value of if the window is available to save
     * ae.saveCheck       ;// a boolean value of if a save is currently necessary
     * ```
     */
    static AEName(&aeCheck?, &titleCheck?, &saveCheck?)
    {
        try {
            if !WinExist(editors.AE.winTitle)
                return {winTitle: false, titleCheck: unset, saveCheck: unset}
            aeCheck := WinGetTitle(editors.AE.winTitle)
            titleCheck := InStr(aeCheck, "Adobe After Effects 20" ptf.AEYearVer " -") ;we add the " -" to accomodate a window that is literally just called "Adobe After Effects [Year]"
            saveCheck := (SubStr(aeCheck, -1, 1) = "*") ? true : false
            return {winTitle: aeCheck, titleCheck: true, saveCheck: saveCheck}
        } catch as e {
            block.Off()
            tool.Cust("Couldn't determine the titles of Adobe programs")
            errorLog(e)
            return {winTitle: false, titleCheck: unset, saveCheck: unset}
        }
    }

    /**
     * This function is designed to retrieve the name of the client using some string manipulation of the dir path within Premiere's title. It uses `ptf.comms` as the "root" dir and expects the next folder in the path to be the client name.
     * @return {String} The clients name
     */
    static ProjClient()
    {
        ;// if the user doesn't have either editors active
        if !WinExist(editors.Premiere.winTitle) && !WinExist(editors.AE.winTitle) {
                errorLog(TargetError("Couldn't determine an editor window", -1),, 1)
                return false
            }
        ;// if PremName fails to grab the title
        if !this.PremName(&premCheck, &titleCheck) && !this.AEName(&aeCheck) {
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
     * This function will grab the proccess ID of the current active window
     * @param {var} id is the processname of the active window, we want to pass this value back to the script
     */
    static ID(&id)
    {
        try {
            id := WinGetProcessName("A")
            if WinActive("ahk_exe explorer.exe")
                id := "ahk_class CabinetWClass"
            return true
        } catch as e {
            tool.Cust("couldn't grab active window")
            errorLog(e)
            return false
        }
    }

    /**
     * A function that returns the path of an open explorer window
     *
     * Original code found here by svArtist: https://www.autohotkey.com/boards/viewtopic.php?p=422751#p387113
     * @param {number} hwnd You can pass in the hwnd of the window you wish to focus, else this parameter can be omitted and it will use the active window
     * @returns {String} the directory path of the explorer window
     */
    static ExplorerPath(hwnd := 0)
    {
        if(hwnd==0){
            explorerHwnd := WinActive("ahk_class CabinetWClass")
            if(explorerHwnd==0)
                explorerHwnd := WinExist("ahk_class CabinetWClass")
        }
        else
            explorerHwnd := WinExist("ahk_class CabinetWClass ahk_id " . hwnd)

        if (explorerHwnd){
            for window in ComObject("Shell.Application").Windows{
                try{
                    if (window && window.hwnd && window.hwnd==explorerHwnd)
                        return window.Document.Folder.Self.Path
                }
            }
        }
        return false
    }

    /**
     * A function to return the size of a path in `bytes` by default.
     * Code from: `DepthTrawler` : https://discord.com/channels/115993023636176902/734109033832906874/1053085736196382771 (ahk discord)
     *
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
        if option > 3
            {
                ;// throw
                errorLog(ValueError("Parameter #2 invalid - Value Too High", -1, option),,, 1)
            }
        ;// you convert bytes to another unit by x / (1024^y)
        ;// ie. bytes => MB ; x / (1024x1024x1024) OR x / 1024^2
        return (ComObject("Scripting.FileSystemObject").GetFolder(path).Size)/(1024**(option+1))
    }
}