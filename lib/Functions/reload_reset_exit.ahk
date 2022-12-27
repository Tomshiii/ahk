; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\Apps\VSCode> ;// only to easy grab the path/wintitle information
#Include <Classes\obj>
#Include <Functions\detect>
; }

/**
 * A function to loop through and either reload or hard reset all* active ahk scripts
 * If this function attempts a reload and fails, it will attempt to read a registry value that contains the users default editor. This value "should" be set after installing ahk. If it isn't, this function will default to VSCode
 */
reload_reset_exit(which, includeChecklist?) {
    all := false
    if IsSet(includeChecklist)
        all := true
    switch which {
        case "reload":
            tool.Cust("all active ahk scripts reloading", 500)
        case "reset":
            tool.Cust("All active ahk scripts are being rerun")
        case "exit":
            tool.Cust("All active ahk scripts are being CLOSED")
    }
    detect()
    value := WinGetList("ahk_class AutoHotkey")
    for this_value in value
        {
            name := WinGettitle(this_value,, browser.vscode.winTitle)
            path := SubStr(name, 1, InStr(name, " -",,, 1) -1)
            script := obj.SplitPath(path)
            if all != true && (script.Name = "checklist.ahk" || script.Name = "My Scripts.ahk" || script.Name = "launcher.ahk")
                continue
            if all = true && (script.Name = "My Scripts.ahk" || script.Name = "launcher.ahk")
                continue
            PID := WinGetPID(script.Name)
            switch which {
                case "reload":
                    PostMessage(0x0111, 65303,,, script.Name " - AutoHotkey")
                case "reset":
                    Run(path)
                case "exit":
                    ProcessClose(PID)
            }

        }
    detect(false)
    tool.Wait()
    switch which {
        case "reset":
            Run(A_ScriptFullPath) ;run this current script last so all of the rest actually happen
        case "exit":
            detect()
            if WinExist("My Scripts.ahk")
                ProcessClose(WinGetPID("My Scripts.ahk",, browser.vscode.winTitle))
        case "reload":
            Reload()
            Sleep 1000 ; if successful, the reload will close this instance during the Sleep, so the line below will never be reached.
            Result := MsgBox("The script could not be reloaded. Would you like to open it for editing?",, 4)
            if Result = "No"
                return
            /**
             * Cut repeat code
             */
            fallback() {
                if WinExist(browser.vscode.winTitle)
                    {
                        WinActivate
                        return
                    }
                if FileExist(VSCode.path)
                    {
                        RunWait(VSCode.path)
                        sleep 1000
                        Run(A_ScriptFullPath)
                        return
                    }
                editor:= MsgBox("The users default editor could not be determined, would you like to set an editor now?", "Invalid default Editor", "4 32 4096")
                if editor = "No"
                    return
                installDir := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoHotkey", "InstallDir", 0)
                if !installDir || !FileExist(installDir "\UX\ui-editor.ahk")
                    {
                        path := "C:\Program Files\AutoHotkey\ui-editor.ahk"
                        MsgBox("Couldn't find the ``ui-editor.ahk`` script, Unless ahk was installed elsewhere, it's usually found here:`n" path)
                        return
                    }
                Run(installDir "\UX\ui-editor.ahk")
            }
            set := false
            defaultEditor := RegRead("HKEY_CLASSES_ROOT\AutoHotkeyScript\shell\edit\command",, 0)
            if checkQuote := InStr(defaultEditor, '"',,, 2)
                defaultEditor := SubStr(defaultEditor, 2, checkQuote-2)
            if !IsSet(defaultEditor) || !defaultEditor
                {
                    fallback()
                    return
                }
            ;// if the default editor is VSC and it's not already open, we want to open it FIRST, then open the script
            ;// otherwise vsc will create a whole new workspace for no reason
            if defaultEditor = VSCode.path && !WinExist(browser.vscode.winTitle)
                {
                    set := true
                    Run(VSCode.path,,, &pid2)
                    if !WinWait("ahk_pid " pid2)
                        Run(defaultEditor)
                    sleep 1000
                }
            Run(defaultEditor A_Space '"' A_ScriptFullPath '"',,, &pid)
            if !WinWait("ahk_pid " PID,, 5) && !set
                {
                    fallback()
                    return
                }
    }
}