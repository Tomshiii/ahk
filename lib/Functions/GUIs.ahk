#Include General.ahk

/**
 * This class is to provide a basic template for all GUIs I create to maintain a consistent theme
 * 
 * @param FontSize allows you to pass in a custom default GUI font size. Defaults to 11, can be omitted
 * @param FontWeight allows you to pass in a custom default GUI font weight. Defaults to 11, can be omitted
 * @param options? allows you to pass in all GUI options that you would normally pass to a GUI. Can be omitted
 * @param title allows you to pass in a title for the GUI. Can be omitted
 */
class tomshiBasic extends Gui {
    __New(FontSize := 11, FontWeight := 500, options?, title:="") {
        super.__new(options?, title, this)
        this.BackColor := 0xF0F0F0
        this.SetFont("S" FontSize " W" FontWeight) ;Sets the size of the font
    }
}

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
    
    darkMode := IniRead(ptf.files["settings"], "Settings", "dark mode")
    version := IniRead(ptf.files["settings"], "Track", "version")

    ;gameCheckGUI
    gameTitle := "Add game to gameCheck.ahk"
    gameCheckSettingGUI := gameCheckGUI(darkMode, version, winTitle, winProcc, "AlwaysOnTop", gameTitle)

    if WinExist("Settings " version)
        return
    settingsGUI := tomshiBasic(,, "+Resize +MinSize250x AlwaysOnTop", "Settings " version)
    SetTimer(resize, -10)
    resize() => settingsGUI.Opt("-Resize")

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

    checkVal := IniRead(ptf.files["settings"], "Settings", "update check", "true")
    switch checkVal {
        case "true":
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked1 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip := "Scripts will check for updates"
        case "false":
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked-1 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip := "Scripts will still check for updates but will not present the user`nwith a GUI when an update is available"
        case "stop":
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked0 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip := "Scripts will NOT check for updates"
    }
    updateCheckToggle.OnEvent("Click", update)
    update(*)
    {
        ToolTip("")
        betaCheck := IniRead(ptf.files["settings"], "Settings", "beta update check") ;storing the beta check value so we can toggle it back on if it was on originally
        updateVal := updateCheckToggle.Value
        switch updateVal {
            case 1: ;true
                IniWrite("true", ptf.files["settings"], "Settings", "update check")
                tool.Cust("Scripts will check for updates", 2000)
                if betaCheck = "true"
                    betaupdateCheckToggle.Value := 1
            case -1: ;false
                IniWrite("false", ptf.files["settings"], "Settings", "update check")
                tool.Cust("Scripts will still check for updates but will not present the user`nwith a GUI when an update is available", 2000)
                if betaCheck = "true"
                    betaupdateCheckToggle.Value := 1
            case 0: ;stop
                betaupdateCheckToggle.Value := 0
                IniWrite("stop", ptf.files["settings"], "Settings", "update check")
                tool.Cust("Scripts will NOT check for updates", 2000)
        }
    }

    betaStart := false ;if the user enables the check for beta updates, we want my main script to reload on exit.
    if IniRead(ptf.files["settings"], "Settings", "beta update check") = "true" && updateCheckToggle.Value != 0
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
                IniWrite("true", ptf.files["settings"], "Settings", "beta update check")
            }

        else
            {
                betaupdateCheckToggle.Value := 0
                betaStart := false
                IniWrite("false", ptf.files["settings"], "Settings", "beta update check")
            }
    }

    darkINI := IniRead(ptf.files["settings"], "Settings", "dark mode")
    darkCheck := settingsGUI.Add("Checkbox", "Checked" trueOrfalse(darkINI) " Y+5", "Dark Mode")
    darkToolY := "A dark theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect"
    darkToolN := "A lighter theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect"
    switch darkINI {
        case "true":
            darkCheck.ToolTip := darkToolY
        case "false":       
            darkCheck.ToolTip := darkToolN
        case "Disabled":
            darkCheck.ToolTip := "The users OS version is too low for this feature"
            darkCheck.Opt("+Disabled")
    }
    darkCheck.OnEvent("Click", darkToggle)
    darkToggle(*)
    {
        ToolTip("")
        darkToggleVal := darkCheck.Value
        switch darkToggleVal {
            case 1:
                IniWrite("true", ptf.files["settings"], "Settings", "dark mode")
                darkCheck.ToolTip := darkToolY
                tool.Cust(darkToolY, 2000)
                goDark()
            case 0:
                IniWrite("false", ptf.files["settings"], "Settings", "dark mode")
                darkCheck.ToolTip := darkToolN
                tool.Cust(darkToolN, 2000)
                goDark(false, "Light")
        }
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;script checkboxes

    tooltipCheck := IniRead(ptf.files["settings"], "Settings", "tooltip")
    toggleToggle := settingsGUI.Add("Checkbox", "Checked" trueOrfalse(tooltipCheck) " Y+15", "``autosave.ahk`` tooltips")
    toggleToolY := "``autosave.ahk`` will produce tooltips on the minute, in the last 4min to alert the user a save is coming up"
    toggleToolN := "``autosave.ahk`` will no longer produce tooltips on the minute, in the last 4min to alert the user a save is coming up"
    switch tooltipCheck {
        case "true":
            toggleToggle.ToolTip := toggleToolY
        case "false":
            toggleToggle.ToolTip := toggleToolN
    }
    toggleToggle.OnEvent("Click", toggle)
    toggle(*)
    {
        detect()
        ToolTip("")
        toggleVal := toggleToggle.Value
        switch toggleVal {
            case 1:
                IniWrite("true", ptf.files["settings"], "Settings", "tooltip")
                toggleToggle.ToolTip := toggleToolY
                tool.Cust(toggleToolY, 2000)
            case 0:
                IniWrite("false", ptf.files["settings"], "Settings", "tooltip")
                toggleToggle.ToolTip := toggleToolN
                tool.Cust(toggleToolN, 2000)
        }
        if WinExist("autosave.ahk - AutoHotkey")
            PostMessage 0x0111, 65303,,, "autosave.ahk - AutoHotkey"
    }

    checklistTooltip := IniRead(ptf.files["settings"], "Settings", "checklist tooltip")
    checkTool := settingsGUI.Add("Checkbox", "Checked" trueOrfalse(checklistTooltip) " Y+5", "``checklist.ahk`` tooltips")
    checkToolY := "``checklist.ahk`` will produce tooltips to remind you if you've paused the timer"
    checkToolN := "``checklist.ahk`` will no longer produce tooltips to remind you if you've paused the timer"
    switch checklistTooltip {
        case "true":
            checkTool.ToolTip := checkToolY
        case "false":
            checkTool.ToolTip := checkToolN
    }
    checkTool.OnEvent("Click", checkToggle)
    checkToggle(*)
    {
        detect()
        ToolTip("")
        msgboxtext := "Please stop any active checklist timers and restart ``checklist.ahk`` for this change to take effect"
        checkToggleVal := checkTool.Value
        switch checkToggleVal {
            case 1:
                IniWrite("true", ptf.files["settings"], "Settings", "checklist tooltip")
                checkTool.ToolTip := checkToolY
                tool.Cust(checkToolY, 2000)
                if WinExist("checklist.ahk - AutoHotkey")
                    MsgBox(msgboxtext,, "48 4096")
            case 0:
                ifDisabled := "`n`nThis setting will override the local setting for your current checklist"
                IniWrite("false", ptf.files["settings"], "Settings", "checklist tooltip")
                checkTool.ToolTip := checkToolN
                tool.Cust(checkToolN, 2000)
                if WinExist("checklist.ahk - AutoHotkey")
                    MsgBox(msgboxtext ifDisabled,, "48 4096")
        }
    }

    checklistWait := IniRead(ptf.files["settings"], "Settings", "checklist wait")
    checkWait := settingsGUI.Add("Checkbox", "Checked" trueOrfalse(checklistWait) " Y+5", "``checklist.ahk`` always wait")
    waitToolY := "``checklist.ahk`` will always wait for you to open a premiere project before opening"
    waitToolN := "``checklist.ahk`` will prompt the user if you wish to wait or manually open a project"
    switch checklistWait {
        case "true":
            checkWait.ToolTip := waitToolY
        case "false":
            checkWait.ToolTip := waitToolN
    }
    checkWait.OnEvent("Click", waitToggle)
    waitToggle(*)
    {
        detect()
        ToolTip("")
        msgboxtext := "Please stop any active checklist timers and restart ``checklist.ahk`` for this change to take effect"
        checkWaitVal := checkWait.Value
        switch checkWaitVal {
            case 1:
                IniWrite("true", ptf.files["settings"], "Settings", "checklist wait")
                checkWait.ToolTip := waitToolY
                tool.Cust(waitToolY, 2.0)
                if WinExist("checklist.ahk - AutoHotkey")
                    MsgBox(msgboxtext,, "48 4096")
            case 0:
                IniWrite("false", ptf.files["settings"], "Settings", "checklist wait")
                checkWait.ToolTip := waitToolN
                tool.Cust(waitToolN, 2.0)
                if WinExist("checklist.ahk - AutoHotkey")
                    MsgBox(msgboxtext,, "48 4096")
        }
    }

    trueOrfalse(var)
    {
        if var = "true"
            return 1
        else
            return 0
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;EDIT BOXES

    adobeGBinitVal := IniRead(ptf.files["settings"], "Adjust", "adobe GB")
    adobeGBEdit := settingsGUI.Add("Edit", "Section xs+223 ys r1 W50 Number", "")
    settingsGUI.Add("UpDown",, adobeGBinitVal)
    adobeEditText := settingsGUI.Add("Text", "X+5 Y+-20", "``adobeTemp()``")
    adobeEditText.SetFont("cd53c3c")
    settingsGUI.Add("Text", "X+1", " limit (GB)")
    adobeGBEdit.OnEvent("Change", adobeGB)
    adobeGB(*) => IniWrite(adobeGBEdit.Value, ptf.files["settings"], "Adjust", "adobe GB")

    adobeFSinitVal := IniRead(ptf.files["settings"], "Adjust", "adobe FS")
    adobeFSEdit := settingsGUI.Add("Edit", "xs Y+10 r1 W50 Number", "")
    settingsGUI.Add("UpDown",, adobeFSinitVal)
    adobeFSEditText := settingsGUI.Add("Text", "X+5 Y+-28", "``adobe fullscreen check.ahk``")
    adobeFSEditText.SetFont("cd53c3c")
    settingsGUI.Add("Text", "Y+-1", " check rate (sec)")
    adobeFSEdit.OnEvent("Change", editCtrl.bind("adobe fullscreen check.ahk", "adobe FS"))

    autosaveMininitVal := IniRead(ptf.files["settings"], "Adjust", "autosave MIN")
    autosaveMinEdit := settingsGUI.Add("Edit", "xs Y+2 r1 W50 Number", "")
    settingsGUI.Add("UpDown",, autosaveMininitVal)
    autosaveMinEditText := settingsGUI.Add("Text", "X+5 Y+-20", "``autosave.ahk``")
    autosaveMinEditText.SetFont("c4141d5")
    settingsGUI.Add("Text", "X+1", " save rate (min)")
    autosaveMinEdit.OnEvent("Change", editCtrl.bind("autosave.ahk", "autosave MIN"))

    gameCheckInitVal := IniRead(ptf.files["settings"], "Adjust", "game SEC")
    gameCheckEdit := settingsGUI.Add("Edit", "xs Y+10 r1 W50 Number", "")
    settingsGUI.Add("UpDown",, gameCheckInitVal)
    gameCheckEditText := settingsGUI.Add("Text", "X+5 Y+-20", "``gameCheck.ahk``")
    gameCheckEditText.SetFont("c328832")
    settingsGUI.Add("Text", "X+1", " check rate (sec)")
    gameCheckEdit.OnEvent("Change", editCtrl.bind("gameCheck.ahk", "game SEC"))

    multiInitVal := IniRead(ptf.files["settings"], "Adjust", "multi SEC")
    multiEdit := settingsGUI.Add("Edit", "xs Y+10 r1 W50 Number", "")
    settingsGUI.Add("UpDown",, multiInitVal)
    multiEditText := settingsGUI.Add("Text", "X+5 Y+-28", "``Multi-Instance Close.ahk``")
    multiEditText.SetFont("c983d98")
    settingsGUI.Add("Text", "Y+-1", " check rate (sec)")
    multiEdit.OnEvent("Change", editCtrl.bind("Multi-Instance Close.ahk", "multi SEC"))

    premInitYear := IniRead(ptf.files["settings"], "Adjust", "prem year")
    premEdit := settingsGUI.Add("Edit", "xs Y+5 r1 W50 Number Limit4", premInitYear)
    premEditText := settingsGUI.Add("Text", "X+5 Y+-20", "Adobe Premiere Year")
    premEditText.SetFont("c8644c7")
    premEdit.OnEvent("Change", editCtrl.Bind("--", "prem year"))
    
    AEInitYear := IniRead(ptf.files["settings"], "Adjust", "ae year")
    AE_Edit := settingsGUI.Add("Edit", "xs Y+10 r1 W50 Number Limit4", AEInitYear)
    AE_EditText := settingsGUI.Add("Text", "X+5 Y+-20", "Adobe After Effects Year")
    AE_EditText.SetFont("c393665")
    AE_Edit.OnEvent("Change", editCtrl.Bind("--", "ae year"))

    editCtrl(script, ini, ctrl, *)
    {
        IniWrite(ctrl.value, ptf.files["settings"], "Adjust", ini)
        if WinExist(script " - AutoHotkey")
            PostMessage 0x0111, 65303,,, script " - AutoHotkey"
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;BOTTOM TEXT
    resetText := settingsGUI.Add("Text", "Section W100 H20 X9 Y+20", "Reset")
    resetText.SetFont("S13 Bold")

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;BUTTON TOGGLES

    adobeToggle := settingsGUI.Add("Button", "w100 h30 Y+5", "adobeTemp()")
    adobeToggle.OnEvent("Click", buttons.bind("adobe"))

    firstToggle := settingsGUI.Add("Button", "w100 h30 X+15", "firstCheck()")
    firstToggle.OnEvent("Click", buttons.bind("first"))

    buttons(which, button, *)
    {
        if which = "adobe"
            buttonTitle := "adobeTemp()"
        if which = "first"
            buttonTitle := "firstCheck()"
        switch button.text {
            case buttonTitle:
                button.Text := "undo?"
            case "undo?":
                button.Text := buttonTitle
        }
    }
    ;----------------------------------------------------------------------------------------------------------------------------------
    ;OTHER BUTTONS

    gameAdd := settingsGUI.Add("Button", "W120 H40 xs Y+20", "Add game to ``gameCheck.ahk``")
    gameAdd.OnEvent("Click", gameAddButt)
    gameAddButt(*)
    {
        gameCheckSettingGUI.Show("AutoSize")
        gameCheckSettingGUI.OnEvent("Close", Gui_Close)
        Gui_Close(*) {
            if WinExist("Settings " version)
                {
                    WinSetAlwaysOnTop(1, "Settings " version)
                    WinActivate("Settings " version)
                }
            gameCheckSettingGUI.Hide()
        }
        WinSetAlwaysOnTop(0, "Settings " version)
        settingsGUI.Opt("+Disabled")
        WinWaitClose(gameTitle)
        settingsGUI.Opt("-Disabled")
    }

    iniLink := settingsGUI.Add("Button", "section X+10 Y+-35", "open settings.ini")
    iniLink.OnEvent("Click", ini)
    ini(*)
    {
        settingsGUI.Opt("-AlwaysOnTop")
        if WinExist("settings.ini") ;if ini already open, get pos, close, and then reopen to refresh
            refreshWin("settings.ini", ptf.files["settings"])
        else
            Run(ptf.files["settings"])
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

    workDir := IniRead(ptf.files["settings"], "Track", "working dir")
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
    hardResetVar.OnEvent("Click", close.bind("hard"))

    saveAndClose := settingsGUI.Add("Button", "W85 H30 y+5", "Save && Exit")
    saveAndClose.OnEvent("Click", close)

    settingsGUI.OnEvent("Escape", close)
    settingsGUI.OnEvent("Close", close)
    close(butt?, *)
    {
        SetTimer(statecheck, 0)
        SetTimer(iniWait, 0)
        if !IsSet(butt) ;have to do it this way instead of using `butt.text` because hitting the X to close would cause an error doing that. Binding the function is the only way
            {
                ;check
                if betaStart = true 
                    Run(A_ScriptFullPath)
            }
        ;check to see if the user wants to reset adobeTemp()
        if adobeToggle.Text = "undo?"
            IniWrite("", ptf.files["settings"], "Track", "adobe temp")
        ;check to see if the user wants to reset firstCheck()
        if firstToggle.Text = "undo?"
            IniWrite("false", ptf.files["settings"], "Track", "first check")
        ;a check incase this settings gui was launched from firstCheck()
        if WinExist("Scripts Release " version)
            WinSetAlwaysOnTop(1, "Scripts Release " version)
        if IsSet(butt) && butt = "hard"
            reload_reset_exit("reset")
        if premEdit.Value != premInitYear || AE_Edit.Value != AEInitYear
            reload_reset_exit("reset")
        ;before finally closing
        settingsGUI.Destroy()
    }

    ;the below code allows for the tooltips on hover
    ;code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
    OnMessage(0x0200, On_WM_MOUSEMOVE)

    ;gets defined at the top of the script
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
    }

    settingsGUI.Show("Center AutoSize")
}

/**
 * A class to define the gameCheck add GUI window
 * 
 * @param dark is passing in whether dark mode is enabled or not
 * @param version is passing in the current version number
 * @param wintitle is passing in the originally active winTitle when `settingsGUI()` was called
 * @param process is passing in the originally active winProcess when `settingsGUI()` was called
 * @param options is defining any GUI options
 * @param title is to set a title for the GUI
 */
class gameCheckGUI extends Gui {
    __new(dark, version, wintitle, process, options?, title:="") {
        super.__new(options?, title, this)
        this.BackColor := 0xF0F0F0
        this.SetFont("S11") ;Sets the size of the font
        this.SetFont("W500") ;Sets the weight of the font (thickness)
        this.Opt("+MinSize450x320 +MaxSize450x")

        ;setting up
        detect()

        ;defining text
        text1 := this.Add("Text", "W440 Center", "Format: ``GameTitle ahk_exe game.exe```nExample: ``Minecraft ahk_exe javaw.exe")
        text2 := this.Add("Text", "Y+4 W440 Center", "*try to remove any information from the title that is likely to change, eg. version numbers or extra text that isn't a part of the game title (Terraria for example adds little quotes to the title that changes everytime you run the game)")
        text2.SetFont("S9 italic")
        text3 := this.Add("Text", "Y+-8 W440", "This function attempted to grab the correct information from the active window before you pulled up the settings GUI and then prefilled the input boxes with that information. If it's correct hit OK, if not enter in the correct information.`n`n*If not, this info can be found using WindowSpy which comes alongside AHK")

        ;defining edit boxes
        gameTitleTitle := this.Add("Text", "Section", "Game Title: ")
        gameTitle := this.Add("Edit", "xs+120 ys-5 r1 -WantReturn vgameTitle w300", wintitle)

        gameProcessText := this.Add("Text", "xs ys+25 Section", "Process Name: ")
        gameProcess := this.Add("Edit", "xs+120 ys-5 r1 -WantReturn vgameProcess w300", "ahk_exe " process)

        ;defining buttons
        addButton := this.Add("Button", "xs+187 ys+30 Section", "add to ``gameCheck.ahk``")
        addButton.OnEvent("Click", addButton_Click.Bind(version, gameTitle.Text, gameProcess.Text))
        cancelButton := this.Add("Button", "xs+175 ys", "cancel")
        cancelButton.OnEvent("Click", cancelButton_Click)

        if dark = "true"
            {
                titleBarDarkMode(this.Hwnd)
                buttonDarkMode(addButton.Hwnd)
                buttonDarkMode(cancelButton.Hwnd)
            }

        /**
         * This function handles the logic behind the add button
         * @param {any} version is the version number that gets passed into the class
         * @param {any} titleVal is the original title name that gets passed into the class
         * @param {any} procVal is the process name that gets passed into the class
         * @param {any} testButton is a default paramater
         * @param {any} unusedInfo is a default paramater
         */
        addButton_Click(version, titleVal, procVal, testButton, unusedInfo) {
            if titleVal != gameTitle.Value
                titleVal := gameTitle.Value
            if procVal != gameProcess.Value
                procVal := gameProcess.Value
            ;check for game list file
            rootDir := IniRead(ptf.files["settings"], "Track", "working dir")
            if !FileExist(rootDir "\lib\gameCheck\Game List.ahk")
                {
                    MsgBox("``Game List.ahk`` not found in the proper directory")
                    this.Hide()
                    WinSetAlwaysOnTop(1, "Settings " version)
                    WinActivate("Settings " version)
                }
            ;create temp folders
            if !DirExist(A_Temp "\tomshi")
                DirCreate(A_Temp "\tomshi")
            readGameCheck := FileRead(rootDir "\lib\gameCheck\Game List.ahk")
            findEnd := InStr(readGameCheck, "; --", 1,, 1)
            addUserInput := StrReplace(readGameCheck, "; --", "GroupAdd(" '"' "games" '"' ", " '"' titleVal " " procVal '"' ")`n; --", 1,, 1)
            FileAppend(addUserInput, A_Temp "\tomshi\Game List.ahk")
            FileMove(A_Temp "\tomshi\Game List.ahk", rootDir "\lib\gameCheck\Game List.ahk", 1)
            if WinExist("gameCheck.ahk - AutoHotkey")
                PostMessage 0x0111, 65303,,, "gameCheck.ahk - AutoHotkey"

            ;check if worked
            readAgain := FileRead(rootDir "\lib\gameCheck\Game List.ahk")
            if InStr(readAgain, "GroupAdd(" '"' "games" '"' ", " '"' titleVal " " procVal '"' ")`n; --", 1,, 1)
                {
                    this.Hide()
                    MsgBox("Game added succesfully!")
                    if WinExist("Settings " version)
                        {
                            WinSetAlwaysOnTop(1, "Settings " version)
                            WinActivate("Settings " version)
                        }
                }
            else
                {
                    this.Hide()
                    MsgBox("Game added unsuccesfully :(")
                    if WinExist("Settings " version)
                        {
                            WinSetAlwaysOnTop(1, "Settings " version)
                            WinActivate("Settings " version)
                        }
                }
        }

        /**
         * Handles the logic behind the cancel button
         * @param {any} testButton is a default paramater
         * @param {any} unusedInfo is a default paramater
         */
        cancelButton_Click(testButton, unusedInfo) {
            if WinExist("Settings " version)
                {
                    WinSetAlwaysOnTop(1, "Settings " version)
                    WinActivate("Settings " version)
                }
            this.Hide()
        }
    }

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

    aimpPath := ptf.ProgFi32 "\AIMP3\AIMP.exe"
    foobarPath := ptf.ProgFi32 "\foobar2000\foobar2000.exe"
    wmpPath := ptf.ProgFi32 "\Windows Media Player\wmplayer.exe"
    vlcPath := ptf.ProgFi "\VideoLAN\VLC\vlc.exe"

    ;if there is no music player open, a custom GUI window will open asking which program you'd like to open
    MyGui := tomshiBasic(10, 600, "AlwaysOnTop -Resize +MinSize260x120 +MaxSize260x120", "Music to open?") ;creates our GUI window
    ;#now we define the elements of the GUI window
    ;defining AIMP
    aimplogo := MyGui.Add("Picture", "w25 h-1 Y9", ptf.guiIMG "\aimp.png")
    AIMP := MyGui.Add("Button", "X40 Y7", "AIMP")
    AIMP.OnEvent("Click", musicRun)
    ;defining Foobar
    foobarlogo := MyGui.Add("Picture", "w20 h-1 X14 Y40", ptf.guiIMG "\foobar.png")
    foobar := MyGui.Add("Button", "X40 Y40", "Foobar")
    foobar.OnEvent("Click", musicRun)
    ;defining Windows Media Player
    wmplogo := MyGui.Add("Picture", "w25 h-1 X140 Y9", ptf.guiIMG "\wmp.png")
    WMP := MyGui.Add("Button", "X170 Y7", "WMP")
    WMP.OnEvent("Click", musicRun)
    ;defining VLC
    vlclogo := MyGui.Add("Picture", "w28 h-1 X138 Y42", ptf.guiIMG "\vlc.png")
    VLC := MyGui.Add("Button", "X170 Y40", "VLC")
    VLC.OnEvent("Click", musicRun)
    ;defining music folder
    folderlogo := MyGui.Add("Picture", "w25 h-1  X14 Y86", ptf.guiIMG "\explorer.png")
    FOLDERGUI := MyGui.Add("Button", "X42 Y85", "MUSIC FOLDER")
    FOLDERGUI.OnEvent("Click", MUSICFOLDER)
    ;add an invisible button since removing the default off all the others did nothing
    removedefault := MyGui.Add("Button", "Default X0 Y0 W0 H0", "_")
    ;#finished with definitions

    if IniRead(ptf.files["settings"], "Settings", "dark mode") = "true"
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
        switch button.Text {
            case "AIMP":
                Run(aimpPath)
            case "Foobar":
                Run(foobarPath)
                text := "foobar2000"
            case "WMP":
                Run(wmpPath)
                text := "wmplayer"
            case "VLC":
                Run(vlcPath)
        }
        WinWait("ahk_exe " text ".exe")
        WinActivate("ahk_exe " text ".exe")
        MyGui.Destroy()
    }

    MUSICFOLDER(*) {
        if DirExist(ptf.musicDir)
            {
                Run(ptf.musicDir)
                WinWait("Music")
                WinActivate("Music")
            }
        else
            {
                scriptPath :=  A_LineFile ;this is taking the path given from A_LineFile
                scriptName := SplitPath(scriptPath, &name) ;and splitting it out into just the .ahk filename
                MsgBox("The requested music folder doesn't exist`n`nWritten dir: " ptf.musicDir "`nScript: " name "`nLine: " A_LineNumber-11)
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
    hotGUI := tomshiBasic(,, "-Resize AlwaysOnTop", "Handy Hotkeys - Tomshi Scripts")
	Title := hotGUI.Add("Text", "H30 X8 W300", "Handy Hotkeys!")
    Title.SetFont("S15 Bold")

    ;sizing GUI
    gui_Small := {x: 450, y: 281}
    gui_Big := {x: 590}
    guiText_y := [60, 80, 90] ;text y position
    ;sizing text
    widthSize := Map(
        "small", 240,
        "large", 380,
    )
    heightSize := Map(
        "small", 100,
        "large", 220,
    )
    ;defining hotkeys
    hotkeys := ["#F1", "#F2", "#F12", "#+r", "#+^r", "#h", "#c", "#f", "#+``", "^+c", "CapsLock & c"]

    ;add listbox
    selection := hotGUI.Add("ListBox", "r" hotkeys.Length -2 " Choose1", [hotkeys[1], hotkeys[2], hotkeys[3], hotkeys[4], hotkeys[5], hotkeys[6], hotkeys[7], hotkeys[8], hotkeys[9], hotkeys[10], hotkeys[11]])
    selection.OnEvent("Change", text)

    ;buttons
    ;close button
	closeButton := hotGUI.Add("Button", "X8 Y+10", "Close")
	closeButton.OnEvent("Click", close)
    ;remove the default
	noDefault := hotGUI.Add("Button", "X0 Y0 W0 H0", "")

    selectionText := hotGUI.Add("Text", "W240 X180 Y80 H100", "Pulls up the settings GUI window to adjust a few settings available to my scripts! This window can also be accessed by right clicking on ``My Scripts.ahk`` in the taskbar. Try it now!")
    text(*) {
        switch selection.Value {
            case 1:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "Pulls up the settings GUI window to adjust a few settings available to my scripts! This window can also be accessed by right clicking on ``My Scripts.ahk`` in the taskbar. Try it now!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 2:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "Pulls up an informational window regarding the currently active scripts, as well as a quick and easy way to close/open any of them. Try it now!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 3:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "A panic button that will loop through and force close all active* ahk scripts!`n`n*will not close ``checklist.ahk``"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 4:
                selectionText.Move(, guiText_y[1], widthSize["large"], heightSize["large"])
                selectionText.Text := "
                (
                    Will refresh all scripts! At anytime if you get stuck in a script press this hotkey to regain control.`n
                    (note: refreshing will not stop scripts run separately ie. from a streamdeck as they are their own process and not included in the refresh hotkey).
                    Alternatively you can also press ^!{del} (ctrl + alt + del) to access task manager, even if inputs are blocked.
                )"
                hotGUI.Move(,, gui_Big.x, gui_Small.y)
            case 5:
                selectionText.Move(, guiText_y[1], widthSize["large"], heightSize["large"])
                selectionText.Text := "
                (
                    Will rerun all active ahk scripts, effectively hard restarting them!. If at anytime a normal refresh isn't enough attempt this hotkey.`n
                    (note: refreshing will not stop scripts run separately ie. from a streamdeck as they are their own process and not included in the refresh hotkey).
                    Alternatively you can also press ^!{del} (ctrl + alt + del) to access task manager, even if inputs are blocked.
                )"
                hotGUI.Move(,, gui_Big.x, gui_Small.y)
            case 6:
                selectionText.Move(, guiText_y[3], widthSize["small"], heightSize["small"])
                selectionText.Text := "Will call this GUI so you can reference these hotkeys at any time!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 7:
                selectionText.Move(, guiText_y[3], widthSize["small"], heightSize["small"])
                selectionText.Text := "Will center the current active window in the middle the active display, or move the window to your main display if activated again!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 8:
                selectionText.Move(, guiText_y[3], widthSize["small"], heightSize["small"])
                selectionText.Text := "Will put the active window in fullscreen if it isn't already, or pull it out of fullscreen if it already is!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 9:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "
                (
                    (That's : win > SHIFT > ``, not the actual + key)
                    Will suspend the ``My Scripts.ahk`` script! - this is similar to using the ``#F2`` hotkey and unticking the same script!
                )"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 10:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "
                (
                    (That's : win > SHIFT > c, not the actual + key)
                    Will search google for whatever text you have highlighted!
                    This hotkey is set to not activate while Premiere Pro/After Effects is active!
                )"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 11:
                selectionText.Move(, guiText_y[3], widthSize["small"], heightSize["small"])
                selectionText.Text := "Will remove and then either capitilise or completely lowercase the highlighted text depending on which is less frequent!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
        }
    }

    ;what happens when you close the GUI
    hotGUI.OnEvent("Escape", close)
    hotGUI.OnEvent("Close", close)
    ;onEvent Functions
	close(*) => hotGUI.Destroy()

    if IniRead(ptf.files["settings"], "Settings", "dark mode") = "true"
        goDark()
    goDark()
    {
        titleBarDarkMode(hotGUI.Hwnd)
        buttonDarkMode(closeButton.Hwnd)
        buttonDarkMode(noDefault.Hwnd)
        buttonDarkMode(selection.Hwnd)
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
    todoGUI := tomshiBasic(,, "-Resize AlwaysOnTop", "What to Do - Tomshi Scripts")
	Title := todoGUI.Add("Text", "H30 X8 W300", "What to Do")
    Title.SetFont("S15")

    bodyText := todoGUI.Add("Text","X8 W550 Center", "
    (
        1. Once you've saved these scripts wherever you wish (the default value is ``E:\Github\ahk\`` if you want all the directory information to just line up without any editing) but if you wish to use a custom directory, my scripts should automatically adjust these variables when you run ``My Scripts.ahk`` (so if you're reading this, your directory should be ``
    )" A_WorkingDir "
    (
        ``) but if you wish to do a sanity check, check the ``location :=`` variable in ``KSA.ahk`` and if it lines up with your directory everything should work as intended.
             // do note; some ``Streamdeck AHK`` scripts still have other hard coded dir's as they are intended for my workflow and may error out if you try to run them. //

        2. Take a look at ``Keyboard Shortcuts.ini`` to set your own keyboard shortcuts for programs as well as define coordinates for a few remaining ImageSearches that cannot use variables for various reasons. These ``KSA`` values are used to allow for easy adjustments instead of needing to dig through scripts!

        3. Take a look at ``General.ahk`` in the class ``class ptf {`` to adjust all assigned filepaths!

        4. You can then edit and run any of the .ahk files to use to your liking!
    )")
    closeButton := todoGUI.Add("Button", "x+-90 y+10", "Close")
    closeButton.OnEvent("Click", close)

    todoGUI.OnEvent("Escape", close)
    todoGUI.OnEvent("Close", close)
    close(*) {
        todoGUI.Destroy()
    }

    if IniRead(ptf.files["settings"], "Settings", "dark mode") = "true"
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
    MyGui := tomshiBasic(,, "-Resize AlwaysOnTop", "Tomshi Scripts Release " MyRelease)
    ;nofocus
    ;add an invisible button since removing the default off all the others did nothing
    removedefault := MyGui.Add("Button", "Default X0 Y0 w0 h0", "_")
    ;active scripts
    text := MyGui.Add("Text", "X8 Y8 W300 H20", "Current active scripts are:")
    text.SetFont("S13 Bold")
    
    ;checkboxes
    my := MyGui.Add("CheckBox", "Checked0 Section", "My Scripts.ahk")
    my.ToolTip := "Clicking this checkbox will toggle suspend the script"
    my.OnEvent("Click", myClick)
    
    alt := MyGui.Add("CheckBox", "Checked0", "Alt_menu_acceleration_DISABLER.ahk")
    alt.ToolTip := "Clicking this checkbox will open/close the script"

    autodis := MyGui.Add("CheckBox", "Checked0", "autodismiss error.ahk")
    autodis.ToolTip := "Clicking this checkbox will open/close the script"

    autosave := MyGui.Add("CheckBox", "Checked0", "autosave.ahk")
    autosave.ToolTip := "Clicking this checkbox will open/close the script. Reopening it will restart the autosave timer"

    premFull := MyGui.Add("CheckBox", "Checked0", "adobe fullscreen check.ahk")
    premFull.ToolTip := "Clicking this checkbox will open/close the script"

    gameCheck := MyGui.Add("CheckBox", "Checked0", "gameCheck.ahk")
    gameCheck.ToolTip := "Clicking this checkbox will open/close the script"

    multiCheck := MyGui.Add("CheckBox", "Checked0", "Multi-Instance Close.ahk")
    multiCheck.ToolTip := "Clicking this checkbox will open/close the script"

    qmk := MyGui.Add("CheckBox", "Checked0", "QMK Keyboard.ahk")
    qmk.ToolTip := "Clicking this checkbox will open/close the script"

    resolve := MyGui.Add("CheckBox", "Checked0", "Resolve_Example.ahk")
    resolve.ToolTip := "Clicking this checkbox will open/close the script"

    ;set checkbox onevent.
    ;only works because only thing I've generated so far is checkboxes
    for hwnd, GuiCtrlObj in MyGui
        {
            if A_Index < 4 ;skips the invisible button, the title text, My Scripts.ahk and something else, probably the gui itself
                continue
            GuiCtrlObj.OnEvent("Click", scriptClick)
        }

    SetTimer(checkScripts, -100)
        
    ;images
    myImage := MyGui.Add("Picture", "w20 h-1 X275 Ys", ptf.Icons "\myscript.png")
    altImage := MyGui.Add("Picture", "w20 h-1 Y+5", ptf.Icons "\error.ico")
    autodisImage := MyGui.Add("Picture", "w20 h-1 Y+2", ptf.Icons "\dismiss.ico")
    autosaveImage := MyGui.Add("Picture", "w20 h-1 Y+5", ptf.Icons "\save.ico")
    premFullImage := MyGui.Add("Picture", "w20 h-1 Y+5", ptf.Icons "\fullscreen.ico")
    gameImage := MyGui.Add("Picture", "w20 h-1 Y+5", ptf.Icons "\game.png")
    multiImage := MyGui.Add("Picture", "w20 h-1 Y+5", ptf.Icons "\M-I_C.png")
    qmkImage := MyGui.Add("Picture", "w20 h-1 Y+5", ptf.Icons "\keyboard.ico")
    resolveImage := MyGui.Add("Picture", "w20 h-1 Y+2", ptf.Icons "\resolve.png")

    ;close button
    closeButton := MyGui.Add("Button", "X245", "Close")
    closeButton.OnEvent("Click", escape)

    if IniRead(ptf.files["settings"], "Settings", "dark mode") = "true"
        goDark()
    goDark()
    {
        titleBarDarkMode(MyGui.Hwnd)
        buttonDarkMode(closeButton.Hwnd)
    }

    ;the below code allows for the tooltips on hover
    ;code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
    OnMessage(0x0200, On_WM_MOUSEMOVE)
    
    ;below is all of the callback functions
    myClick(*) => Suspend(-1)

    scriptClick(script, *) {
        detect()
        val := script.Value
        if val != 1
            {
                WinClose(script.text " - AutoHotkey")
                return
            }
        if script.text = "QMK Keyboard.ahk" || script.text = "Resolve_Example.ahk"
            Run(A_WorkingDir "\" script.text)
        else
            Run(A_WorkingDir "\Timer Scripts\" script.text)
    }

    checkScripts(*)
    {
        detect()
        if WinExist("My Scripts.ahk is Suspended")
            WinWaitClose("My Scripts.ahk is Suspended")
     
        my.Value := (A_IsSuspended = 0) ? 1 : 0
        alt.Value := WinExist("Alt_menu_acceleration_DISABLER.ahk - AutoHotkey") ? 1 : 0
        autodis.Value := WinExist("autodismiss error.ahk - AutoHotkey") ? 1 : 0
        autosave.Value := WinExist("autosave.ahk - AutoHotkey") ? 1 : 0
        premFull.Value := WinExist("adobe fullscreen check.ahk - AutoHotkey") ? 1 : 0
        gameCheck.Value := WinExist("gameCheck.ahk - AutoHotkey") ? 1 : 0
        multiCheck.Value := WinExist("Multi-Instance Close.ahk - AutoHotkey") ? 1 : 0
        qmk.Value := WinExist("QMK Keyboard.ahk - AutoHotkey") ? 1 : 0
        resolve.Value := WinExist("Resolve_Example.ahk - AutoHotkey") ? 1 : 0

        SetTimer(, -100)
    }

    MyGui.OnEvent("Escape", escape)
    MyGui.OnEvent("Close", escape)
    escape(*) {
        SetTimer(checkScripts, 0)
        MyGui.Destroy()
    }

    MyGui.Show("Center AutoSize")
}