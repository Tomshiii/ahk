#Include General.ahk

/**
 * A GUI window to allow the user to toggle settings contained within the `settings.ini` file
 */
settingsGUI()
{
    ;this function is needed to reload some scripts
    detect()

    try { ;attempting to grab window information on the active window for `gameAddButt()`
        winProcc := WinGetProcessName("A")
        winTitle := WinGetTitle("A")
        if !InStr(winTitle, " ",,, 1)
            titleBlank := winTitle
        else
            {
                getBlank := InStr(winTitle, " ",,, 1)
                titleBlank := SubStr(winTitle, 1, getBlank -1)
            }
    } catch {
        winProcc := ""
        titleBlank := ""
    }

    version := IniRead(A_MyDocuments "\tomshi\settings.ini", "Track", "version")
    if WinExist("Settings " version)
        return
    settingsGUI := Gui("+Resize +MinSize250x AlwaysOnTop", "Settings " version)
    SetTimer(resize, -10)
    resize() => settingsGUI.Opt("-Resize")
    settingsGUI.SetFont("S11")

    noDefault := settingsGUI.Add("Button", "Default W0 H0", "_")

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;Top Titles
    titleText := settingsGUI.Add("Text", "section W100 H25 X9 Y7", "Settings")
    titleText.SetFont("S15 Bold Underline")

    toggleText := settingsGUI.Add("Text", "W100 H20 xs Y+5", "Toggle")
    toggleText.SetFont("S13 Bold")

    adjustText := settingsGUI.Add("Text", "W100 H20 x+125", "Adjust")
    adjustText.SetFont("S13 Bold")
    decimalText := settingsGUI.Add("Text", "W180 H20 x+-40 Y+-18", "(decimals adjustable in .ini)")


    ;----------------------------------------------------------------------------------------------------------------------------------
    ;checkboxes

    checkVal := IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "update check", "true")
    if checkVal = "true"
        {
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked1 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip := "Scripts will check for updates"
        }
    else if checkVal = "false"
        {
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked-1 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip := "Scripts will still check for updates but will not present the user`nwith a GUI when an update is available"
        }
    else if checkVal = "stop"
        {
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked0 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip := "Scripts will NOT check for updates"
        }
    updateCheckToggle.OnEvent("Click", update)
    update(*)
    {
        ToolTip("")
        betaCheck := IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "beta update check") ;storing the beta check value so we can toggle it back on if it was on originally
        updateVal := updateCheckToggle.Value
        if updateVal = 1
            {
                IniWrite("true", A_MyDocuments "\tomshi\settings.ini", "Settings", "update check")
                tool.Cust("Scripts will check for updates", 2000)
                if betaCheck = "true"
                    betaupdateCheckToggle.Value := 1
            }
        else if updateVal = -1
            {
                IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Settings", "update check")
                tool.Cust("Scripts will still check for updates but will not present the user`nwith a GUI when an update is available", 2000)
                if betaCheck = "true"
                    betaupdateCheckToggle.Value := 1
            }
        else if updateVal = 0
            {
                betaupdateCheckToggle.Value := 0
                IniWrite("stop", A_MyDocuments "\tomshi\settings.ini", "Settings", "update check")
                tool.Cust("Scripts will NOT check for updates", 2000)
            }
    }

    betaStart := false ;if the user enables the check for beta updates, we want my main script to reload on exit.
    if IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "beta update check") = "true" && updateCheckToggle.Value != 0
        betaupdateCheckToggle := settingsGUI.Add("Checkbox", "Checked1 xs Y+5", "Check for Beta Updates")
    else
        betaupdateCheckToggle := settingsGUI.Add("Checkbox", "Checked0 xs Y+5", "Check for Beta Updates")
    betaupdateCheckToggle.OnEvent("Click", betaupdate)
    betaupdate(*)
    {
        updateVal := betaupdateCheckToggle.Value
        if updateVal = 1 && updateCheckToggle.Value != 0
            {
                betaStart := true
                IniWrite("true", A_MyDocuments "\tomshi\settings.ini", "Settings", "beta update check")
            }

        else
            {
                betaupdateCheckToggle.Value := 0
                betaStart := false
                IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Settings", "beta update check")
            }
    }

    darkINI := IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "dark mode")
    if darkINI = "true"
        {
            darkCheck := settingsGUI.Add("Checkbox", "Checked1 Y+5", "Dark Mode")
            darkCheck.ToolTip := "A dark theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect"
        }
    else if darkINI = "false"
        {
            darkCheck := settingsGUI.Add("Checkbox", "Checked0 Y+5", "Dark Mode")
            darkCheck.ToolTip := "A lighter theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect"
        }
    else if darkINI = "Disabled"
        {
            darkCheck := settingsGUI.Add("Checkbox", "Checked0 Y+5", "Dark Mode")
            darkCheck.ToolTip := "The users OS version is too low for this feature"
            darkCheck.Opt("+Disabled")
        }
    darkCheck.OnEvent("Click", darkToggle)
    darkToggle(*)
    {
        ToolTip("")
        darkToggleVal := darkCheck.Value
        if darkToggleVal = 1
            {
                IniWrite("true", A_MyDocuments "\tomshi\settings.ini", "Settings", "dark mode")
                darkCheck.ToolTip := "A dark theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect"
                tool.Cust("A dark theme will be applied to certain GUI elements wherever possible", 2000)
                goDark()
            }
        else
            {
                IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Settings", "dark mode")
                darkCheck.ToolTip := "A lighter theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect"
                tool.Cust("A lighter theme will be applied to certain GUI elements wherever possible", 2000)
                goDark(false, "Light")
            }
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;script checkboxes


    if IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "tooltip") = "true"
        {
            toggleToggle := settingsGUI.Add("Checkbox", "Checked1 Y+15", "``autosave.ahk`` tooltips")
            toggleToggle.ToolTip := "``autosave.ahk`` will produce tooltips on the minute, in the last 4min to alert the user a save is coming up"
        }
    else
        {
            toggleToggle := settingsGUI.Add("Checkbox", "Checked0 Y+15", "``autosave.ahk`` tooltips")
            toggleToggle.ToolTip := "``autosave.ahk`` will no longer produce tooltips on the minute, in the last 4min to alert the user a save is coming up"
        }
    toggleToggle.OnEvent("Click", toggle)
    toggle(*)
    {
        detect()
        ToolTip("")
        toggleVal := toggleToggle.Value
        if toggleVal = 1
            {
                IniWrite("true", A_MyDocuments "\tomshi\settings.ini", "Settings", "tooltip")
                toggleToggle.ToolTip := "``autosave.ahk`` will produce tooltips on the minute, in the last 4min to alert the user a save is coming up"
                tool.Cust("``autosave.ahk`` will produce tooltips on the minute, in the last 4min to alert the user a save is coming up", 2000)
            }
        else
            {
                IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Settings", "tooltip")
                toggleToggle.ToolTip := "``autosave.ahk`` will no longer produce tooltips on the minute, in the last 4min to alert the user a save is coming up"
                tool.Cust("``autosave.ahk`` will no longer produce tooltips on the minute, in the last 4min to alert the user a save is coming up", 2000)
            }

        if WinExist("autosave.ahk - AutoHotkey")
            PostMessage 0x0111, 65303,,, "autosave.ahk - AutoHotkey"
    }

    if IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "checklist tooltip") = "true"
        {
            checkTool := settingsGUI.Add("Checkbox", "Checked1 Y+5", "``checklist.ahk`` tooltips")
            checkTool.ToolTip := "``checklist.ahk`` will produce tooltips to remind you if you've paused the timer"
        }
    else
        {
            checkTool := settingsGUI.Add("Checkbox", "Checked0 Y+5", "``checklist.ahk`` tooltips")
            checkTool.ToolTip := "``checklist.ahk`` will no longer produce tooltips to remind you if you've paused the timer"
        }
    checkTool.OnEvent("Click", checkToggle)
    checkToggle(*)
    {
        detect()
        ToolTip("")
        msgboxtext := "Please stop any active checklist timers and restart ``checklist.ahk`` for this change to take effect"
        checkToggleVal := checkTool.Value
        if checkToggleVal = 1
            {
                IniWrite("true", A_MyDocuments "\tomshi\settings.ini", "Settings", "checklist tooltip")
                checkTool.ToolTip := "``checklist.ahk`` will produce tooltips to remind you if you've paused the timer"
                tool.Cust("``checklist.ahk`` will produce tooltips to remind you if you've paused the timer", 2000)
                if WinExist("checklist.ahk - AutoHotkey")
                    MsgBox(msgboxtext,, "48 4096")
            }
        else
            {
                ifDisabled := "`n`nThis setting will override the local setting for your current checklist"
                IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Settings", "checklist tooltip")
                checkTool.ToolTip := "``checklist.ahk`` will no longer produce tooltips to remind you if you've paused the timer"
                tool.Cust("``checklist.ahk`` will no longer produce tooltips to remind you if you've paused the timer", 2000)
                if WinExist("checklist.ahk - AutoHotkey")
                    MsgBox(msgboxtext ifDisabled,, "48 4096")
            }
    }

    if IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "checklist wait") = "true"
        {
            checkWait := settingsGUI.Add("Checkbox", "Checked1 Y+5", "``checklist.ahk`` always wait")
            checkWait.ToolTip := "``checklist.ahk`` will always wait for you to open a premiere project before opening"
        }
    else
        {
            checkWait := settingsGUI.Add("Checkbox", "Checked0 Y+5", "``checklist.ahk`` always wait")
            checkWait.ToolTip := "``checklist.ahk`` will prompt the user if you wish to wait or manually open a project"
        }
    checkWait.OnEvent("Click", waitToggle)
    waitToggle(*)
    {
        detect()
        ToolTip("")
        msgboxtext := "Please stop any active checklist timers and restart ``checklist.ahk`` for this change to take effect"
        checkWaitVal := checkWait.Value
        if checkWaitVal = 1
            {
                IniWrite("true", A_MyDocuments "\tomshi\settings.ini", "Settings", "checklist wait")
                checkWait.ToolTip := "``checklist.ahk`` will always wait for you to open a premiere project before opening"
                tool.Cust("``checklist.ahk`` will always wait for you to open a premiere project before opening", 2.0)
                if WinExist("checklist.ahk - AutoHotkey")
                    MsgBox(msgboxtext,, "48 4096")
            }
        else
            {
                IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Settings", "checklist wait")
                checkWait.ToolTip := "``checklist.ahk`` will prompt the user if you wish to wait or manually open a project"
                tool.Cust("``checklist.ahk`` will prompt the user if you wish to wait or manually open a project", 2.0)
                if WinExist("checklist.ahk - AutoHotkey")
                    MsgBox(msgboxtext,, "48 4096")
            }
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;EDIT BOXES

    adobeGBinitVal := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "adobe GB")
    adobeGBEdit := settingsGUI.Add("Edit", "Section xs+223 ys r1 W50 Number", "")
    settingsGUI.Add("UpDown",, adobeGBinitVal)
    adobeEditText := settingsGUI.Add("Text", "X+5 Y+-20", "``adobeTemp()``")
    adobeEditText.SetFont("cd53c3c")
    settingsGUI.Add("Text", "X+1", " limit (GB)")
    adobeGBEdit.OnEvent("Change", adobeGB)
    adobeGB(*) => IniWrite(adobeGBEdit.Value, A_MyDocuments "\tomshi\settings.ini", "Adjust", "adobe GB")

    adobeFSinitVal := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "adobe FS")
    adobeFSEdit := settingsGUI.Add("Edit", "xs Y+10 r1 W50 Number", "")
    settingsGUI.Add("UpDown",, adobeFSinitVal)
    adobeFSEditText := settingsGUI.Add("Text", "X+5 Y+-28", "``adobe fullscreen check.ahk``")
    adobeFSEditText.SetFont("cd53c3c")
    settingsGUI.Add("Text", "Y+-1", " check rate (sec)")
    adobeFSEdit.OnEvent("Change", adobeFS)
    adobeFS(*)
    {
        detect()
        IniWrite(adobeFSEdit.Value, A_MyDocuments "\tomshi\settings.ini", "Adjust", "adobe FS")
        if WinExist("adobe fullscreen check.ahk - AutoHotkey")
            PostMessage 0x0111, 65303,,, "adobe fullscreen check.ahk - AutoHotkey"
    }

    autosaveMininitVal := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "autosave MIN")
    autosaveMinEdit := settingsGUI.Add("Edit", "xs Y+2 r1 W50 Number", "")
    settingsGUI.Add("UpDown",, autosaveMininitVal)
    autosaveMinEditText := settingsGUI.Add("Text", "X+5 Y+-20", "``autosave.ahk``")
    autosaveMinEditText.SetFont("c4141d5")
    settingsGUI.Add("Text", "X+1", " save rate (min)")
    autosaveMinEdit.OnEvent("Change", autosaveMin)
    autosaveMin(*)
    {
        detect()
        IniWrite(autosaveMinEdit.Value, A_MyDocuments "\tomshi\settings.ini", "Adjust", "autosave MIN")
        if WinExist("autosave.ahk - AutoHotkey")
            PostMessage 0x0111, 65303,,, "autosave.ahk - AutoHotkey"
    }

    gameCheckInitVal := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "game SEC")
    gameCheckEdit := settingsGUI.Add("Edit", "xs Y+10 r1 W50 Number", "")
    settingsGUI.Add("UpDown",, gameCheckInitVal)
    gameCheckEditText := settingsGUI.Add("Text", "X+5 Y+-20", "``gameCheck.ahk``")
    gameCheckEditText.SetFont("c328832")
    settingsGUI.Add("Text", "X+1", " check rate (sec)")
    gameCheckEdit.OnEvent("Change", gameCheckMin)
    gameCheckMin(*)
    {
        detect()
        IniWrite(gameCheckEdit.Value, A_MyDocuments "\tomshi\settings.ini", "Adjust", "game SEC")
        if WinExist("gameCheck.ahk - AutoHotkey")
            PostMessage 0x0111, 65303,,, "gameCheck.ahk - AutoHotkey"
    }

    multiInitVal := IniRead(A_MyDocuments "\tomshi\settings.ini", "Adjust", "multi SEC")
    multiEdit := settingsGUI.Add("Edit", "xs Y+10 r1 W50 Number", "")
    settingsGUI.Add("UpDown",, multiInitVal)
    multiEditText := settingsGUI.Add("Text", "X+5 Y+-28", "``Multi-Instance Close.ahk``")
    multiEditText.SetFont("c983d98")
    settingsGUI.Add("Text", "Y+-1", " check rate (sec)")
    multiEdit.OnEvent("Change", multiMin)
    multiMin(*)
    {
            detect()
            IniWrite(multiEdit.Value, A_MyDocuments "\tomshi\settings.ini", "Adjust", "multi SEC")
            if WinExist("Multi-Instance Close.ahk - AutoHotkey")
                PostMessage 0x0111, 65303,,, "Multi-Instance Close.ahk - AutoHotkey"
        }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;BOTTOM TEXT
    resetText := settingsGUI.Add("Text", "Section W100 H20 X9 Y+20", "Reset")
    resetText.SetFont("S13 Bold")

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;BUTTON TOGGLES

    adobeToggle := settingsGUI.Add("Button", "w100 h30 Y+5", "adobeTemp()")
    adobeUndo := settingsGUI.Add("Button", "w0 h0", "undo?")
    adobeToggle.OnEvent("Click", adobe)
    adobeUndo.OnEvent("Click", adobe)
    adobe(*)
    {
        check := adobeToggle.GetPos(,, &width)
        if width != 0
            {
                togglePos := adobeToggle.GetPos(&toggleX, &toggleY)
                adobeToggle.Move(,, 0, 0)
                adobeUndo.Move(, toggleY, 100, 30)
            }
        else
            {
                togglePos := adobeUndo.GetPos(&undoX, &undoY)
                adobeUndo.Move(,, 0, 0)
                adobeToggle.Move(, undoY, 100, 30)		
            }
    }

    firstToggle := settingsGUI.Add("Button", "w100 h30 Y+-38 X+117", "firstCheck()")
    firstUndo := settingsGUI.Add("Button", "w0 h0", "undo?")
    firstToggle.OnEvent("Click", first)
    firstUndo.OnEvent("Click", first)
    first(*)
    {
        check := firstToggle.GetPos(,, &width)
        if width != 0
            {
                togglePos := firstToggle.GetPos(&toggleX, &toggleY)
                firstToggle.Move(,, 0, 0)
                firstUndo.Move(, toggleY, 100, 30)
            }
        else
            {
                togglePos := firstUndo.GetPos(&undoX, &undoY)
                firstUndo.Move(,, 0, 0)
                firstToggle.Move(, undoY, 100, 30)		
            }
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;OTHER BUTTONS

    gameAdd := settingsGUI.Add("Button", "W120 H40 xs Y+20", "Add game to ``gameCheck.ahk``")
    gameAdd.OnEvent("Click", gameAddButt)
    gameAddButt(*)
    {
        detect()
        oldClip := A_Clipboard
        A_Clipboard := ""
        A_Clipboard := titleBlank " ahk_exe " winProcc
        WinSetAlwaysOnTop(0, "Settings " version)
        settingsGUI.Opt("+Disabled")
        addGame := InputBox("Format: ``GameTitle ahk_exe game.exe```nExample: ``Minecraft ahk_exe javaw.exe`n`nThis function attempted to grab the correct information from the active window before you pulled up the settings GUI and then copied it to the clipboard, it has also prefilled the inputbox with that information. If it's correct hit OK, if not enter in the correct information.`n`n*If not, this info can be found using WindowSpy which comes alongside AHK", "Enter Game Info to Add", "W450 H250", A_Clipboard)
        if addGame.Result = "Cancel"
            {
                A_Clipboard := oldClip
                WinSetAlwaysOnTop(1, "Settings " version)
                settingsGUI.Opt("-Disabled +AlwaysOnTop")
                WinActivate("Settings " version)
            }
        else
            {
                A_Clipboard := oldClip
                if !FileExist(A_WorkingDir "\lib\gameCheck\Game List.ahk")
                    {
                        MsgBox("``Game List.ahk`` not found in the proper directory")
                        settingsGUI.Opt("-Disabled AlwaysOnTop")
                    }
                ;create temp folders
                if !DirExist(A_Temp "\tomshi")
                    DirCreate(A_Temp "\tomshi")
                readGameCheck := FileRead(A_WorkingDir "\lib\gameCheck\Game List.ahk")
                findEnd := InStr(readGameCheck, "; --", 1,, 1)
                addUserInput := StrReplace(readGameCheck, "`n; --", "GroupAdd(" '"' "games" '"' ", " '"' addGame.Value '"' ")`n; --", 1,, 1)
                FileAppend(addUserInput, A_Temp "\tomshi\Game List.ahk")
                FileMove(A_Temp "\tomshi\Game List.ahk", A_WorkingDir "\lib\gameCheck\Game List.ahk", 1)
                if WinExist("gameCheck.ahk - AutoHotkey")
                    PostMessage 0x0111, 65303,,, "gameCheck.ahk - AutoHotkey"
                WinSetAlwaysOnTop(1, "Settings " version)
                settingsGUI.Opt("-Disabled AlwaysOnTop")
                WinActivate("Settings " version)
            }
    }

    iniLink := settingsGUI.Add("Button", "section X+10 Y+-35", "open settings.ini")
    iniLink.OnEvent("Click", ini)
    ini(*)
    {
        settingsGUI.Opt("-AlwaysOnTop")
        if WinExist("settings.ini")
            WinActivate("settings.ini")
        else
            Run(A_MyDocuments "\tomshi\settings.ini")
        WinWait("settings.ini")
        SetTimer(iniWait, -100)
    }
    iniWait()
    {
        if !WinExist("Settings " version)
            {
                SetTimer(, 0)
                goto end
            }
        if WinExist("settings.ini")
            {
                SetTimer(, -1000)
                goto end
            }
        if !WinExist("settings.ini") && WinExist("Settings " version)
            settingsGUI.Opt("+AlwaysOnTop")
        SetTimer(, 0)
        end:
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;STATUS BAR

    workDir := IniRead(A_MyDocuments "\tomshi\settings.ini", "Track", "working dir")
    SB := settingsGUI.Add("StatusBar")
    SB.SetText("  Current working dir: " workDir)
    checkdir := SB.GetPos(,, &width)
    parts := SB.SetParts(width + 20 + (StrLen(workDir)*5))
    SetTimer(statecheck, -100)
    statecheck(*)
    {
        if A_IsSuspended = 0
            state := "Active"
        else
            state := "Suspended"
        SB.SetText(" Scripts " state, 2)
        SetTimer(, -1000)
    }
    SB.SetFont("S9")
    SB.OnEvent("Click", dir)
    dir(*)
    {
        SplitPath(workDir,,,, &path)
        if WinExist("ahk_exe explorer.exe " path)
            WinActivate("ahk_exe explorer.exe " path)
        else
            Run(workDir)
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;GROUP EXIT BUTTONS

    group := settingsGUI.Add("GroupBox", "W101 H95 xs+227 ys-60", "Exit")
    hardResetVar := settingsGUI.Add("Button", "W85 H30 x+-93 y+-75", "Hard Reset")
    hardResetVar.OnEvent("Click", hardres)

    saveAndClose := settingsGUI.Add("Button", "W85 H30 y+5", "Save && Exit")
    saveAndClose.OnEvent("Click", close)

    settingsGUI.OnEvent("Escape", close)
    settingsGUI.OnEvent("Close", close)
    close(*)
    {
        SetTimer(statecheck, 0)
        SetTimer(iniWait, 0)
        ;check 
        if betaStart = true 
            Run(A_ScriptFullPath)
        ;check to see if the user wants to reset adobeTemp()
        checkAdobe := adobeToggle.GetPos(,, &width)
        if width = 0
            IniWrite("", A_MyDocuments "\tomshi\settings.ini", "Track", "adobe temp")
        ;check to see if the user wants to reset firstCheck()
        checkFirst := firstToggle.GetPos(,, &width)
        if width = 0
            IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Track", "first check")
        ;a check incase this settings gui was launched from firstCheck()
        if WinExist("Scripts Release " version)
            WinSetAlwaysOnTop(1, "Scripts Release " version)
        ;before finally closing
        settingsGUI.Destroy()
    }

    hardres(*)
    {
        SetTimer(statecheck, 0)
        SetTimer(iniWait, 0)
        ;check to see if the user wants to reset adobeTemp()
        checkAdobe := adobeToggle.GetPos(,, &width)
        if width = 0
            IniWrite("", A_MyDocuments "\tomshi\settings.ini", "Track", "adobe temp")
        ;check to see if the user wants to reset firstCheck()
        checkFirst := firstToggle.GetPos(,, &width)
        if width = 0
            IniWrite("false", A_MyDocuments "\tomshi\settings.ini", "Track", "first check")
        ;a check incase this settings gui was launched from firstCheck()
        if WinExist("Scripts Release " version)
            WinSetAlwaysOnTop(1, "Scripts Release " version)
        
        hardReset()
    }

    ;the below code allows for the tooltips on hover
    ;code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
    OnMessage(0x0200, On_WM_MOUSEMOVE)
    On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd)
    {
        static PrevHwnd := 0
        if (Hwnd != PrevHwnd)
        {
            Text := "", ToolTip() ; Turn off any previous tooltip.
            CurrControl := GuiCtrlFromHwnd(Hwnd)
            if CurrControl
            {
                if !CurrControl.HasProp("ToolTip")
                    return ; No tooltip for this control.
                Text := CurrControl.ToolTip
                SetTimer () => ToolTip(Text), -1000
                SetTimer () => ToolTip(), -4000 ; Remove the tooltip.
            }
            PrevHwnd := Hwnd
        }
    }

    darkMode := IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "dark mode")
    if darkMode = "true"
        goDark()

    goDark(dark := true, DarkorLight := "Dark")
    {
            titleBarDarkMode(settingsGUI.Hwnd, dark)
            buttonDarkMode(adobeToggle.Hwnd, DarkorLight)
            buttonDarkMode(firstToggle.Hwnd, DarkorLight)
            buttonDarkMode(gameAdd.Hwnd, DarkorLight)
            buttonDarkMode(iniLink.Hwnd, DarkorLight)
            buttonDarkMode(hardResetVar.Hwnd, DarkorLight)
            buttonDarkMode(saveAndClose.Hwnd, DarkorLight)
            buttonDarkMode(adobeUndo.Hwnd, DarkorLight)
            buttonDarkMode(firstUndo.Hwnd, DarkorLight)
    }

    settingsGUI.Show("Center AutoSize")
}

/**
 * This function creates a GUI for the user to select which media player they wish to open.
 * 
 * Currently offers AIMP, Foobar, WMP & VLC.
 * 
 * This function is also used within switchToMusic()
*/
musicGUI()
{
    if WinExist("Music to open?")
        return
    progFi := "C:\Program Files"
    progFi32 := "C:\Program Files (x86)"
    aimpPath := progFi32 "\AIMP3\AIMP.exe"
    foobarPath := progFi32 "\foobar2000\foobar2000.exe"
    wmpPath := progFi32 "\Windows Media Player\wmplayer.exe"
    vlcPath := progFi "\VideoLAN\VLC\vlc.exe"

    ;if there is no music player open, a custom GUI window will open asking which program you'd like to open
    MyGui := Gui("AlwaysOnTop", "Music to open?") ;creates our GUI window
    MyGui.SetFont("S10") ;Sets the size of the font
    MyGui.SetFont("W600") ;Sets the weight of the font (thickness)
    MyGui.Opt("-Resize +MinSize260x120 +MaxSize260x120") ;Sets a minimum size for the window
    ;#now we define the elements of the GUI window
    ;defining AIMP
    aimplogo := MyGui.Add("Picture", "w25 h-1 Y9", A_WorkingDir "\Support Files\images\aimp.png")
    AIMP := MyGui.Add("Button", "X40 Y7", "AIMP")
    AIMP.OnEvent("Click", musicRun)
    ;defining Foobar
    foobarlogo := MyGui.Add("Picture", "w20 h-1 X14 Y40", A_WorkingDir "\Support Files\images\foobar.png")
    foobar := MyGui.Add("Button", "X40 Y40", "Foobar")
    foobar.OnEvent("Click", musicRun)
    ;defining Windows Media Player
    wmplogo := MyGui.Add("Picture", "w25 h-1 X140 Y9", A_WorkingDir "\Support Files\images\wmp.png")
    WMP := MyGui.Add("Button", "X170 Y7", "WMP")
    WMP.OnEvent("Click", musicRun)
    ;defining VLC
    vlclogo := MyGui.Add("Picture", "w28 h-1 X138 Y42", A_WorkingDir "\Support Files\images\vlc.png")
    VLC := MyGui.Add("Button", "X170 Y40", "VLC")
    VLC.OnEvent("Click", musicRun)
    ;defining music folder
    folderlogo := MyGui.Add("Picture", "w25 h-1  X14 Y86", A_WorkingDir "\Support Files\images\explorer.png")
    FOLDERGUI := MyGui.Add("Button", "X42 Y85", "MUSIC FOLDER")
    FOLDERGUI.OnEvent("Click", MUSICFOLDER)
    ;add an invisible button since removing the default off all the others did nothing
    removedefault := MyGui.Add("Button", "Default X0 Y0 W0 H0", "_")
    ;#finished with definitions

    if IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "dark mode") = "true"
        goDark()
    goDark()
    {
        titleBarDarkMode(MyGui.Hwnd)
        buttonDarkMode(AIMP.Hwnd)
        buttonDarkMode(foobar.Hwnd)
        buttonDarkMode(WMP.Hwnd)
        buttonDarkMode(VLC.Hwnd)
        buttonDarkMode(FOLDERGUI.Hwnd)
    }
    
    MyGui.Show()
    ;below is what happens when you click on each button
    musicRun(button, *)
    {
        text := button.Text
        if text = "AIMP"
            Run(aimpPath)
        if text = "Foobar"
            {
                Run(foobarPath)
                text := "foobar2000"
            }
        if text = "WMP"
            {
                Run(wmpPath)
                text := "wmplayer"
            }
        if text = "VLC"
            Run(vlcPath)
        WinWait("ahk_exe " text ".exe")
        WinActivate("ahk_exe " text ".exe")
        MyGui.Destroy()
    }

    MUSICFOLDER(*) {
        musicDir := "S:\Program Files\User\Music\"
        if DirExist(musicDir)
            {
                Run(musicDir)
                WinWait("Music")
                WinActivate("Music")
            }
        else
            {
                scriptPath :=  A_LineFile ;this is taking the path given from A_LineFile
                scriptName := SplitPath(scriptPath, &name) ;and splitting it out into just the .ahk filename
                MsgBox("The requested music folder doesn't exist`n`nWritten dir: " musicDir "`nScript: " name "`nLine: " A_LineNumber-11)
            }
        MyGui.Destroy()
    }
}

/**
 * This function calls a GUI to showcase some useful hotkeys available to the user while running my scripts. This function is also called during firstCheck()
 */
hotkeysGUI() {
    if WinExist("Handy Hotkeys - Tomshi Scripts")
        return
    hotGUI := Gui("", "Handy Hotkeys - Tomshi Scripts")
	hotGUI.SetFont("S11")
	hotGUI.Opt("-Resize AlwaysOnTop")
	Title := hotGUI.Add("Text", "H30 X8 W300", "Handy Hotkeys!")
	Title.SetFont("S15")

    ;all hotkeys
    selection := hotGUI.Add("ListBox", "r10 Choose1", ["#F1", "#F2", "#+r", "#+^r", "#h", "#c", "#f", "#+``", "^+c", "CapsLock & c"])
    selection.OnEvent("Change", text)

    selectionText := hotGUI.Add("Text", "W240 X180 Y80 H100", "Pulls up the settings GUI window to adjust a few settings available to my scripts! This window can also be accessed by right clicking on ``My Scripts.ahk`` in the taskbar. Try it now!")
    text(*) {
        if selection.Value = 1
            {
                selectionText.Move(, 80, "240", "100")
                selectionText.Text := "Pulls up the settings GUI window to adjust a few settings available to my scripts! This window can also be accessed by right clicking on ``My Scripts.ahk`` in the taskbar. Try it now!"
                hotGUI.Move(,, "450", "297")
            }
        if selection.Value = 2
            {
                selectionText.Move(, 80, "240", "100")
                selectionText.Text := "Pulls up an informational window regarding the currently active scripts, as well as a quick and easy way to close/open any of them. Try it now!"
                hotGUI.Move(,, "450", "297")
            }
        if selection.Value = 3
            {
                selectionText.Move(, 60, "380", "220")
                selectionText.Text := "Will refresh all scripts! At anytime if you get stuck in a script press this hotkey to regain control.`n`n(note: refreshing will not stop scripts run separately ie. from a streamdeck as they are their own process and not included in the refresh hotkey).`nAlternatively you can also press ^!{del} (ctrl + alt + del) to access task manager, even if inputs are blocked"
                hotGUI.Move(,, "590", "297")
            }
        if selection.Value = 4
            {
                selectionText.Move(, 60, "380", "220")
                selectionText.Text := "Will rerun all active ahk scripts, effectively hard restarting them!. If at anytime a normal refresh isn't enough attempt this hotkey.`n`n(note: refreshing will not stop scripts run separately ie. from a streamdeck as they are their own process and not included in the refresh hotkey).`nAlternatively you can also press ^!{del} (ctrl + alt + del) to access task manager, even if inputs are blocked"
                hotGUI.Move(,, "590", "297")
            }
        if selection.Value = 5
            {
                selectionText.Move(, 100, "240", "100")
                selectionText.Text := "Will call this GUI so you can reference these hotkeys at any time!"
                hotGUI.Move(,, "450", "297")
            }
        if selection.Value = 6
            {
                selectionText.Move(, 100, "240", "100")
                selectionText.Text := "Will center the current active window in the middle the active display, or move the window to your main display if activated again!"
                hotGUI.Move(,, "450", "297")
            }
        if selection.Value = 7
            {
                selectionText.Move(, 100, "240", "100")
                selectionText.Text := "Will put the active window in fullscreen if it isn't already, or pull it out of fullscreen if it already is!"
                hotGUI.Move(,, "450", "297")
            }
        if selection.Value = 8
            {
                selectionText.Move(, 80, "240", "100")
                selectionText.Text := "(That's : win > SHIFT > ``, not the actual + key)`nWill suspend the ``My Scripts.ahk`` script! - this is similar to using the ``#F2`` hotkey and unticking the same script!"
                hotGUI.Move(,, "450", "297")
            }
        if selection.Value = 9
            {
                selectionText.Move(, 80, "240", "100")
                selectionText.Text := "(That's : win > SHIFT > c, not the actual + key)`nWill search google for whatever text you have highlighted!`nThis hotkey is set to not activate while Premiere Pro/After Effects is active!"
                hotGUI.Move(,, "450", "297")
            }
        if selection.Value = 10
            {
                selectionText.Move(, 100, "240", "100")
                selectionText.Text := "Will remove and then either capitilise or completely lowercase the highlighted text depending on which is less frequent!"
                hotGUI.Move(,, "450", "297")
            }
    }

    ;buttons
    ;remove the default
	noDefault := hotGUI.Add("Button", "X0 Y0 W0 H0", "")
    ;close button
	closeButton := hotGUI.Add("Button", "X8 Y220", "Close")
	closeButton.OnEvent("Click", close)
    ;what happens when you close the GUI
    hotGUI.OnEvent("Escape", close)
    hotGUI.OnEvent("Close", close)
    ;onEvent Functions
	close(*) {
		hotGUI.Destroy()
	}

    if IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "dark mode") = "true"
        goDark()
    goDark()
    {
        titleBarDarkMode(hotGUI.Hwnd)
        buttonDarkMode(closeButton.Hwnd)
        buttonDarkMode(noDefault.Hwnd)
    }
    
    ;Show the GUI
	hotGUI.Show("AutoSize")
}

/**
 * This function calls a GUI help guide the user on what to do now that they've gotten `My Scripts.ahk` to run. This function is called during firstCheck()
 */
todoGUI()
{
    if WinExist("What to Do - Tomshi Scripts")
        return
    todoGUI := Gui("", "What to Do - Tomshi Scripts")
	todoGUI.SetFont("S11")
	todoGUI.Opt("-Resize AlwaysOnTop")
	Title := todoGUI.Add("Text", "H30 X8 W300", "What to Do")
	Title.SetFont("S15")

    bodyText := todoGUI.Add("Text","X8 W550", "
    (
        1. Once you've saved these scripts wherever you wish (the default value is ``E:\Github\ahk\`` if you want all the directory information to just line up without any editing) but if you wish to use a custom directory, my scripts should automatically adjust these variables when you run ``My Scripts.ahk`` (so if you're reading this, your directory should be ``
    )" A_WorkingDir "
    (
        ``) but if you wish to do a sanity check, check the ``location :=`` variable in ``KSA.ahk`` and if it lines up with your directory everything should work as intended.
             // do note; some ``Streamdeck AHK`` scripts still have other hard coded dir's as they are intended for my workflow and may error out if you try to run them. //

        2. Take a look at ``Keyboard Shortcuts.ini`` to set your own keyboard shortcuts for programs as well as define coordinates for a few remaining ImageSearches that cannot use variables for various reasons. These ``KSA`` values are used to allow for easy adjustments instead of needing to dig through scripts!

        3. Feel free to edit any of these scripts to your liking, change any of the hotkeys, then run any of the .ahk files and enjoy!
            - If you don't have a secondary keyboard, don't forget to take a look through QMK Keyboard.ahk to see what functions you can pull out and put on other keys!

        - Scripts that will work with no tinkering include ->
        - Alt Menu acceleration disabler
        - autodismiss error
        - autosave.ahk
        - adobe fullscreen check.ahk
    )")
    closeButton := todoGUI.Add("Button", "X500 Y400", "Close")
    closeButton.OnEvent("Click", close)

    todoGUI.OnEvent("Escape", close)
    todoGUI.OnEvent("Close", close)
    close(*) {
        todoGUI.Destroy()
    }

    if IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "dark mode") = "true"
        goDark()
    goDark()
    {
        titleBarDarkMode(todoGUI.Hwnd)
        buttonDarkMode(closeButton.Hwnd)
    }
    todoGUI.Show()
}

/**
 * This functions pulls up a GUI that shows which of my scripts are active and allows the user to suspend/close them or unsuspend/open them
 */
activeScripts(MyRelease)
{
    detect()
    if WinExist("Tomshi Scripts Release " MyRelease)
        return
    detect()
    MyGui := Gui("", "Tomshi Scripts Release " MyRelease)
    MyGui.SetFont("S11")
    MyGui.Opt("-Resize AlwaysOnTop")
    ;nofocus
    ;add an invisible button since removing the default off all the others did nothing
    removedefault := MyGui.Add("Button", "Default X0 Y0 w0 h0", "_")
    ;active scripts
    text := MyGui.Add("Text", "X8 Y8 W300 H20", "Current active scripts are:")
    text.SetFont("S13")
    if A_IsSuspended = 0
        my := MyGui.Add("CheckBox", "Checked1", "My Scripts.ahk")
    else
        my := MyGui.Add("CheckBox", "Checked0", "My Scripts.ahk")
    SetTimer(checkMain, -100)
    checkMain(*)
    {
        if WinExist("My Scripts.ahk is Suspended")
            WinWaitClose("My Scripts.ahk is Suspended")
        if A_IsSuspended = 0
            my.Value := 1
        else
            my.Value := 0
        SetTimer(, -1000)
    }
    my.ToolTip := "Clicking this checkbox will toggle suspend the script"
    my.OnEvent("Click", myClick)
    if WinExist("Alt_menu_acceleration_DISABLER.ahk - AutoHotkey")
        alt := MyGui.Add("CheckBox", "Checked1", "Alt_menu_acceleration_DISABLER.ahk")
    else
        alt := MyGui.Add("CheckBox", "Checked0", "Alt_menu_acceleration_DISABLER.ahk")
    alt.ToolTip := "Clicking this checkbox will open/close the script"
    alt.OnEvent("Click", scriptClick)
    if WinExist("autodismiss error.ahk - AutoHotkey")
        autodis := MyGui.Add("CheckBox", "Checked1", "autodismiss error.ahk")
    else
        autodis := MyGui.Add("CheckBox", "Checked0", "autodismiss error.ahk")
    autodis.ToolTip := "Clicking this checkbox will open/close the script"
    autodis.OnEvent("Click", scriptClick)
    if WinExist("autosave.ahk - AutoHotkey")
        autosave := MyGui.Add("CheckBox", "Checked1", "autosave.ahk")
    else
        autosave := MyGui.Add("CheckBox", "Checked0", "autosave.ahk")
    autosave.ToolTip := "Clicking this checkbox will open/close the script. Reopening it will restart the autosave timer"
    autosave.OnEvent("Click", scriptClick)
    if WinExist("adobe fullscreen check.ahk - AutoHotkey")
        premFull := MyGui.Add("CheckBox", "Checked1", "adobe fullscreen check.ahk")
    else
        premFull := MyGui.Add("CheckBox", "Checked0", "adobe fullscreen check.ahk")
    premFull.ToolTip := "Clicking this checkbox will open/close the script"
    premFull.OnEvent("Click", scriptClick)
    if WinExist("gameCheck.ahk - AutoHotkey")
        gameCheck := MyGui.Add("CheckBox", "Checked1", "gameCheck.ahk")
    else
        gameCheck := MyGui.Add("CheckBox", "Checked0", "gameCheck.ahk")
    gameCheck.ToolTip := "Clicking this checkbox will open/close the script"
    gameCheck.OnEvent("Click", scriptClick)
    if WinExist("Multi-Instance Close.ahk - AutoHotkey")
        multiCheck := MyGui.Add("CheckBox", "Checked1", "Multi-Instance Close.ahk")
    else
        multiCheck := MyGui.Add("CheckBox", "Checked0", "Multi-Instance Close.ahk")
    multiCheck.ToolTip := "Clicking this checkbox will open/close the script"
    multiCheck.OnEvent("Click", scriptClick)
    if WinExist("QMK Keyboard.ahk - AutoHotkey")
        qmk := MyGui.Add("CheckBox", "Checked1", "QMK Keyboard.ahk")
    else
        qmk := MyGui.Add("CheckBox", "Checked0", "QMK Keyboard.ahk")
    qmk.ToolTip := "Clicking this checkbox will open/close the script"
    qmk.OnEvent("Click", scriptClick)
    if WinExist("Resolve_Example.ahk - AutoHotkey")
        resolve := MyGui.Add("CheckBox", "Checked1", "Resolve_Example.ahk")
    else
        resolve := MyGui.Add("CheckBox", "Checked0", "Resolve_Example.ahk")
    resolve.ToolTip := "Clicking this checkbox will open/close the script"
    resolve.OnEvent("Click", scriptClick)

    ;images
    myImage := MyGui.Add("Picture", "w20 h-1 X275 Y33", A_WorkingDir "\Support Files\Icons\myscript.png")
    altImage := MyGui.Add("Picture", "w20 h-1 X275 Y+5", A_WorkingDir "\Support Files\Icons\error.ico")
    autodisImage := MyGui.Add("Picture", "w20 h-1 X275 Y+2", A_WorkingDir "\Support Files\Icons\dismiss.ico")
    autosaveImage := MyGui.Add("Picture", "w20 h-1 X275 Y+5", A_WorkingDir "\Support Files\Icons\save.ico")
    premFullImage := MyGui.Add("Picture", "w20 h-1 X275 Y+5", A_WorkingDir "\Support Files\Icons\fullscreen.ico")
    gameImage := MyGui.Add("Picture", "w20 h-1 X275 Y+5", A_WorkingDir "\Support Files\Icons\game.png")
    multiImage := MyGui.Add("Picture", "w20 h-1 X275 Y+5", A_WorkingDir "\Support Files\Icons\M-I_C.png")
    qmkImage := MyGui.Add("Picture", "w20 h-1 X275 Y+5", A_WorkingDir "\Support Files\Icons\keyboard.ico")
    resolveImage := MyGui.Add("Picture", "w20 h-1 X275 Y+2", A_WorkingDir "\Support Files\Icons\resolve.png")

    ;close button
    closeButton := MyGui.Add("Button", "X245", "Close")
    closeButton.OnEvent("Click", escape)

    if IniRead(A_MyDocuments "\tomshi\settings.ini", "Settings", "dark mode") = "true"
        goDark()
    goDark()
    {
        titleBarDarkMode(MyGui.Hwnd)
        buttonDarkMode(closeButton.Hwnd)
    }

    ;the below code allows for the tooltips on hover
    ;code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
    OnMessage(0x0200, On_WM_MOUSEMOVE)
    On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd)
    {
        static PrevHwnd := 0
        if (Hwnd != PrevHwnd)
        {
            Text := "", ToolTip() ; Turn off any previous tooltip.
            CurrControl := GuiCtrlFromHwnd(Hwnd)
            if CurrControl
            {
                if !CurrControl.HasProp("ToolTip")
                    return ; No tooltip for this control.
                Text := CurrControl.ToolTip
                SetTimer () => ToolTip(Text), -1000
                SetTimer () => ToolTip(), -4000 ; Remove the tooltip.
            }
            PrevHwnd := Hwnd
        }
    }
    ;below is all of the callback functions
    myClick(*){
        myVal := my.Value
        if myVal = 1
            Suspend(-1)
        else
            Suspend(-1)
    }
    scriptClick(script, *) {
        detect()
        val := script.Value
        if val != 1
            {
                WinClose(script.text " - AutoHotkey")
                return
            }
        if script.text = "My Scripts.ahk" || script.text = "QMK Keyboard.ahk" || script.text = "Resolve_Example.ahk"
            Run(A_WorkingDir "\" script.text)
        else
            Run(A_WorkingDir "\Timer Scripts\" script.text)
    }

    MyGui.OnEvent("Escape", escape)
    escape(*) {
        SetTimer(checkMain, 0)
        MyGui.Destroy()
    }

    MyGui.Show("Center AutoSize")
}