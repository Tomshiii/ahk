/************************************************************************
 * @description a class to contain functions used to action all active ahk scripts
 * @author tomshi
 * @date 2026/01/15
 * @version 1.1.2
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\settings.ahk
#Include Classes\ptf.ahk
#Include Classes\tool.ahk
#Include Classes\Apps\VSCode.ahk
#Include Classes\obj.ahk
#Include Classes\Mip.ahk
#Include Classes\CLSID_Objs.ahk
#Include Functions\detect.ahk
#Include Classes\winGet.ahk
; }

class reset {
    __New() {
        ;// here we're adding all ahk files within `..\Streamdeck AHK\` to the ignore list
        loop files ptf.rootDir "\Streamdeck AHK\*.ahk", "R F" {
            if !this.ignoreScript.Has(A_LoopFileName)
                this.ignoreScript.Set(A_LoopFileName, 1)
        }
        UserSettings := CLSID_Objs.load("UserSettings")
        this.mainScript := UserSettings.MainScriptName

        this.ignoreScript := this.ignoreScript.Set("PC Startup.ahk", 1, "PC Startup_work.ahk", 1, "Initialise.ahk", 1, "Initialise_work.ahk", 1, UserSettings.MainScriptName ".ahk", 1, "launcher.ahk", 1, "Notify Creator.ahk", 1, "MsgBoxCreator.ahk", 1, "syncOnConnect.ahk", 1, "Core Functionality.ahk", 1, )
    }

    mainScript := ""

    ;// this portion of the code defines scripts to ignore within the below function
    ignoreScript := Mip()

    /** @returns a list of open ahk windows */
    __getList() {
        Critical()
        getDetect := detect()
        list := WinGetList("ahk_class AutoHotkey")
        resetOrigDetect(getDetect)
        Critical("Off")
        return list
    }

    /**
     * Parse the value returned by wingetlist
     * @param {Integer} value the value returned by wingetlist
     * @param {Boolean} includeChecklist whether to include `checklist.ahk`
     */
    __parseInfo(value, includeChecklist) {
        Critical()
        getDetect := detect()
        try {
            name := WinGettitle(value,, browser.vscode.winTitle)
            path := SubStr(name, 1, InStr(name, " -",,, 1) -1)
            script := obj.SplitPath(path)
            PID := WinGetPID(script.Name,, browser.vscode.winTitle)
            resetOrigDetect(getDetect)
            Critical("Off")
            if (includeChecklist = false && (script.Name = "checklist.ahk" || script.Name = "test.ahk")) || this.ignoreScript.Has(script.Name) {
                return false
            }
            resetOrigDetect(getDetect)
            return {scriptName: script.name, PID: PID, path: path}
        }
        resetOrigDetect(getDetect)
        Critical("Off")
    }

    /**
    * Attempt to locate the user's ahk install path and run the default UI-editor file to choose an editor.
    */
    __reloadFallback() {
        if WinExist(browser.vscode.winTitle) {
            WinActivate
            return
        }
        if FileExist(VSCode.path) {
            RunWait(VSCode.path)
            sleep 1000
            Run(A_ScriptFullPath)
            return
        }
        editor := MsgBox("The users default editor could not be determined, would you like to set an editor now?", "Invalid default Editor", "4 32 4096")
        if editor = "No"
            return
        installDir := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoHotkey", "InstallDir", 0)
        if !installDir || !FileExist(installDir "\UX\ui-editor.ahk"){
            path := "C:\Program Files\AutoHotkey\ui-editor.ahk"
            MsgBox("Couldn't find the ``ui-editor.ahk`` script, Unless ahk was installed elsewhere, it's usually found here:`n" path)
            return
        }
        Run(installDir "\UX\ui-editor.ahk")
    }

    __attemptReload() {
        Reload()
        ;// if successful, the reload will close this instance during the Sleep, so the line below will never be reached.
        Sleep 1000
        Result := MsgBox("The script could not be reloaded. Would you like to open it for editing?",, 4)
        if Result = "No"
            return
        set := false
        defaultEditor := RegRead("HKEY_CLASSES_ROOT\AutoHotkeyScript\shell\edit\command",, 0)
        if checkQuote := InStr(defaultEditor, '"',,, 2)
            defaultEditor := SubStr(defaultEditor, 2, checkQuote-2)
        if (!IsSet(defaultEditor) || !defaultEditor) {
            this.__reloadFallback()
            return
        }
        ;// if the default editor is VSC and it's not already open, we want to open it FIRST, then open the script
        ;// otherwise vsc will create a whole new workspace for no reason
        if defaultEditor = VSCode.path && !WinExist(browser.vscode.winTitle) {
            set := true
            Run(VSCode.path,,, &pid2)
            if !WinWait("ahk_pid " pid2,, 5)
                Run(defaultEditor)
            sleep 1000
        }
        Run(defaultEditor A_Space '"' A_ScriptFullPath '"',,, &pid)
        if !WinWait("ahk_pid " PID,, 5) && !set {
            this.__reloadFallback()
            return
        }
    }

    /** a func to reset `HotkeylessAHK` to cut repeat code */
    static __resetHotkeyless(close := false) {
        hotkeylessTitle := "HotkeylessAHK.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
        ignore := browser.vscode.winTitle "|" A_ScriptName
        hotkeyHWND := WinGet.ExistRegex(hotkeylessTitle,, ignore,, true)
        if hotkeyHWND
            ProcessClose(WinGet.PIDRegex(hotkeyHWND,, ignore,, true))
        hotkeyHWNDAgain := WinGet.ExistRegex(hotkeylessTitle,, ignore,, true)
        if hotkeyHWNDAgain {
            if !WinGet.WaitCloseRegex(hotkeyHWNDAgain,, 3, ignore,, true) {
                MsgBox("HotkeylessAHK.ahk failed to close, it may have encountered an error", "Error")
                return
            }
        }
        if close = true
            return
        Run(ptf['HotkeylessAHK'])
    }

    /**
     * Reloads all active ahk scripts
     * @param {Boolean} includeChecklist whether to include `checklist.ahk`
     */
    static ext_reload(includeChecklist := false) {
        Critical()
        detect()
        tool.Cust("All active ahk scripts reloading")
        activeWindows := this().__getList()
        for v in activeWindows {
            if !getInfo := this().__parseInfo(v, includeChecklist)
                continue
            if getInfo.scriptName = "HotkeylessAHK.ahk" {
                this.__resetHotkeyless()
                continue
            }
            PostMessage(0x0111, 65303,,, getInfo.scriptName " - AutoHotkey")
        }
        detect(false)
        Critical("Off")
        tool.Wait()
        this().__attemptReload()
    }

    /**
     * Hard resets all active ahk scripts
     * @param {Boolean} includeChecklist whether to include `checklist.ahk`
     */
    static reset(includeChecklist := false) {
        tool.Cust("All active ahk scripts are being rerun")
        activeWindows := this().__getList()
        for v in activeWindows {
            if !getInfo := this().__parseInfo(v, includeChecklist)
                continue
            if getInfo.scriptName = "HotkeylessAHK.ahk" {
                this.__resetHotkeyless()
                continue
            }
            Run(getInfo.path)
        }
        detect(false)
        tool.Wait()
        Run(A_ScriptFullPath) ;// run this current script last so all of the rest actually happen
    }

    /**
     * Closes all active ahk scripts
     * @param {Boolean} includeChecklist whether to include `checklist.ahk`
     */
    static ex_exit(includeChecklist := false) {
        Critical()
        getDetect := detect()
        tool.Cust("All active ahk scripts are being CLOSED")
        activeWindows := this().__getList()
        for v in activeWindows {
            if !getInfo := this().__parseInfo(v, includeChecklist)
                continue
            if getInfo.scriptName = "HotkeylessAHK.ahk" {
                this.__resetHotkeyless(true)
                continue
            }
            ProcessClose(getInfo.PID)
        }
        detect(false)
        Critical("Off")
        tool.Wait()
        hotkeylessTitle := this().mainScript ".ahk ahk_class AutoHotkey"
        ignore := browser.vscode.winTitle
        hotkeyHWND := WinGet.ExistRegex(hotkeylessTitle,, ignore)
        if hotkeyHWND
            ProcessClose(WinGet.PIDRegex(hotkeyHWND,, ignore))
    }
}