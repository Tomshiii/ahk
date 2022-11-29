; { \\ #Includes
#Include <\Classes\ptf>
#Include <\Classes\tool>
#Include <\Functions\detect>
; }

/**
 * A function to loop through and either reload or hard reset all* active ahk scripts
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
                if Result = "Yes"
                    {
                        if WinExist(browser.vscode.winTitle)
                            WinActivate
                        else
                            Run(ptf.LocalAppData "\Programs\Microsoft VS Code\Code.exe")
                    }
        case "exit":
            detect()
            if WinExist("My Scripts.ahk")
                ProcessClose(WinGetPID("My Scripts.ahk",, browser.vscode.winTitle))
    }
}