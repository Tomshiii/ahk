; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
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
            script := SplitPathObj(path)
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
                if FileExist(ptf.LocalAppData "\Programs\Microsoft VS Code\Code.exe")
                    {
                        Run(ptf.LocalAppData "\Programs\Microsoft VS Code\Code.exe")
                        return
                    }
                editor:= MsgBox("The users default editor could not be determined, would you like to set an editor now?", "Invalid default Editor", "4 32 4096")
                if editor = "No"
                    return
                if !FileExist(A_AhkPath "..\UX\ui-editor.ahk")
                    {
                        path := SplitPathObj(A_AhkPath)
                        MsgBox("Couldn't find the ``ui-editor.ahk`` script, it's usually found here:`n" path.dir "\ui-editor.ahk")
                        return
                    }
                Run(A_AhkPath "..\UX\ui-editor.ahk")
            }
            defaultEditor := RegRead("HKCR\AutoHotkeyScript\shell\edit\command", "(Default)")
            if !IsSet(defaultEditor) || !defaultEditor
                {
                    fallback()
                    return
                }
            Run(defaultEditor,,, &pid)
            if !WinWait("ahk_pid " PID,, 5)
                {
                    fallback()
                    return
                }
        case "exit":
            detect()
            if WinExist("My Scripts.ahk")
                ProcessClose(WinGetPID("My Scripts.ahk",, browser.vscode.winTitle))
    }
}