; { \\ #Includes
#Include <Classes\Settings>
#Include <GUIs\tomshiBasic>
#Include <GUIs\gameCheckGUI>
#Include <GUIs\settingsGUI\editValues>
#Include <Classes\dark>
#Include <Classes\tool>
#Include <Classes\ptf>
#Include <Classes\obj>
#Include <Classes\WM>
#Include <Functions\reload_reset_exit>
#Include <Functions\refreshWin>
#Include <Functions\detect>
#Include <Functions\checkInternet>
;}

class SettingsToolTips {
    updateCheck := {
        true: "Scripts will check for updates",
        false: "Scripts will still check for updates but will not present the user`nwith a GUI when an update is available",
        stop: "Scripts will NOT check for updates"
    }
    dark := {
        Yes: "A dark theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect",
        No: "A lighter theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect",
        disabled: "The users OS version is too low for this feature"
    }
    startup := {
        Yes: "My scripts will automatically run at PC startup",
        No: "My scripts will no longer run at PC startup"
    }
    autosaveCheck := {
        Yes: "``autosave.ahk`` will check to ensure you have ``checklist.ahk`` open",
        No: "``autosave.ahk`` will no longer check to ensure you have ``checklist.ahk`` open"
    }
    autosaveTooltip := {
        Yes: "``autosave.ahk`` will produce tooltips on the minute, in the last 4min to alert the user a save is coming up",
        No: "``autosave.ahk`` will no longer produce tooltips on the minute, in the last 4min to alert the user a save is coming up"
    }
    checklistTooltip := {
        Yes: "``checklist.ahk`` will produce tooltips to remind you if you've paused the timer",
        No: "``checklist.ahk`` will no longer produce tooltips to remind you if you've paused the timer"
    }
    checklistWait := {
        Yes: "``checklist.ahk`` will always wait for you to open a premiere project before opening",
        No: "``checklist.ahk`` will prompt the user if you wish to wait or manually open a project"
    }
}


/**
 * A GUI window to allow the user to toggle settings contained within the `settings.ini` file
*/
settingsGUI()
{
    ;this function is needed to reload some scripts
    detect()

    toolT := SettingsToolTips()
    UserSettings := UserPref()
    ;// menubar
    FileMenu := Menu()
    FileMenu.Add("&Add Game to ``gameCheck.ahk```tCtrl+A", menu_AddGame)
    openMenu := Menu()
    openMenu.Add("&settings.ini`tCtrl+S", menu_Openini)
    openMenu.Add("&Wiki", (*) => MsgBox("Not implemented"))
    openMenu.Disable("&Wiki")
    openMenu.Add("&Wiki Dir`tCtrl+O", openWiki.Bind("local"))
    openMenu.Add("&Wiki Web`tCtrl+W", openWiki.Bind("web"))
    editorsMenu := Menu()
    editorsMenu.Add("&Adobe", (*) => MsgBox("Not implemented"))
    editorsMenu.Disable("&Adobe")
    editorsMenu.Add("&After Effects", menu_Adobe.bind("AE"))
    ; editorsMenu.Add("&Photoshop", ) ;// call a different gui
    editorsMenu.Add("&Premiere", menu_Adobe.bind("Premiere"))
    ; editorsMenu.Add("&Resolve", ) ;// call a different gui
    ;// define the entire menubar
    bar := MenuBar()
    bar.Add("&File", FileMenu)
    bar.Add("&Open", openMenu)
    bar.Add("&Editors", editorsMenu)

    openWiki(which, *) {
        switch which {
            case "local":
                if WinExist("Wiki explorer.exe")
                    WinActivate("Wiki explorer.exe")
                else
                    Run(ptf.Wiki "\Latest")
            case "web":
                checkInt := checkInternet()
                if !checkInt
                    {
                        tool.Cust("It doesn't appear like you have an active internet connection", 2.0)
                        tool.Cust("The page will run just incase", 2.0,, 20, 2)
                    }
                if WinExist("Home · Tomshiii/ahk Wik")
                    WinActivate("Home · Tomshiii/ahk Wik")
                else
                    Run("https://github.com/Tomshiii/ahk/wiki")
        }
    }

    try { ;attempting to grab window information on the active window for `menu_AddGame()`
        winProcc := WinGetProcessName("A")
        winTitle := WinGetTitle("A")
    } catch {
        winProcc := ""
        winTitle := ""
    }

    darkMode := UserSettings.dark_mode
    version := UserSettings.version

    ;gameCheckGUI
    gameTitle := "Add game to gameCheck.ahk" ;// used in winwaits
    gameCheckSettingGUI := gameCheckGUI(version, winTitle, winProcc)
    if WinExist("Settings " version)
        return
    settingsGUI := tomshiBasic(,, "+Resize +MinSize250x AlwaysOnTop", "Settings " version)
    SetTimer(resize, -10)
    resize() => settingsGUI.Opt("-Resize")

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! Top Titles
   /*  titleText := settingsGUI.Add("Text", "section W100 H25 X9 Y7", "Settings")
    titleText.SetFont("S15 Bold Underline") */

    toggleText := settingsGUI.Add("Text", "W100 H20 xs Y7", "Toggle")
    toggleText.SetFont("S13 Bold")

    adjustText := settingsGUI.Add("Text", "W100 H20 x+125", "Adjust")
    adjustText.SetFont("S13 Bold")
    ; decimalText := settingsGUI.Add("Text", "W180 H20 x+-40 Y+-18", "(decimals adjustable in .ini)")


    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! checkboxes

    ;// update check
    checkVal := UserSettings.update_check
    switch checkVal {
        case true:
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked1 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip := toolT.updateCheck.true
        case false:
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked-1 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip :=toolT.updateCheck.false
        case "stop":
            updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked0 section xs+1 Y+5", "Check for Updates")
            updateCheckToggle.ToolTip :=toolT.updateCheck.stop
    }
    updateCheckToggle.OnEvent("Click", update)
    update(*)
    {
        ToolTip("")
        switch updateCheckToggle.Value {
            case 1: ;true
                UserSettings.update_check := true
                updateCheckToggle.ToolTip := toolT.updateCheck.true
                if UserSettings.beta_update_check = true
                    betaupdateCheckToggle.Value := 1
            case -1: ;false
                UserSettings.update_check := false
                updateCheckToggle.ToolTip := toolT.updateCheck.false
                if UserSettings.beta_update_check = true
                    betaupdateCheckToggle.Value := 1
            case 0: ;stop
                betaupdateCheckToggle.Value := 0
                UserSettings.update_check := "stop"
                updateCheckToggle.ToolTip := toolT.updateCheck.stop
        }
    }

    ;// check for PreReleases
    betaStart := false ;if the user enables the check for beta updates, we want my main script to reload on exit.
    betaupdateCheckToggle := (UserSettings.beta_update_check = true && updateCheckToggle.Value != 0)
                            ? settingsGUI.Add("Checkbox", "Checked1 xs Y+5", "Check for Pre-Releases")
                            : settingsGUI.Add("Checkbox", "Checked0 xs Y+5", "Check for Pre-Releases")
    betaupdateCheckToggle.OnEvent("Click", betaupdate)
    betaupdate(*)
    {
        switch betaupdateCheckToggle.Value {
            case 1 && (updateCheckToggle.Value != 0):
                betaStart := true
                UserSettings.beta_update_check := true
            default:
                betaupdateCheckToggle.Value := 0
                betaStart := false
                UserSettings.beta_update_check := false
        }
    }

    ;// dark mode toggle
    darkINI   := UserSettings.dark_mode
    darkCheck := settingsGUI.Add("Checkbox", "Checked" darkINI " Y+5", "Dark Mode")
    switch darkINI {
        case true:  darkCheck.ToolTip := toolT.dark.Yes
        case false: darkCheck.ToolTip := toolT.dark.No
        case "disabled":
            darkCheck.ToolTip := toolT.dark.disabled
            darkCheck.Opt("+Disabled")
    }
    darkCheck.OnEvent("Click", darkToggle)
    darkToggle(*)
    {
        ToolTip("")
        darkToggleVal := darkCheck.Value
        UserSettings.dark_mode := (darkCheck.Value = 1) ? true : false
        darkCheck.ToolTip := (darkCheck.Value = 1) ? toolT.dark.Yes : toolT.dark.No
        if (darkCheck.Value = 1)
            {
                tool.Cust(toolT.dark.Yes, 2000)
                goDark()
                return
            }
        ;// dark mode is false
        tool.Cust(toolT.dark.No, 2000)
        goDark(false, "Light")
    }

    ;// run at startup
    runStartupINI     := UserSettings.run_at_startup
    StartupCheckTitle := "Run at Startup"
    StartupCheck      := settingsGUI.Add("Checkbox", "Checked" runStartupINI " Y+5", StartupCheckTitle)
    switch runStartupINI {
        case true:  StartupCheck.ToolTip := toolT.startup.Yes
        case false: StartupCheck.ToolTip := toolT.startup.No
    }
    StartupCheck.OnEvent("Click", toggle.Bind("run at startup"))

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! script checkboxes

    ;// autosave check checklist
    ascheckCheck := UserSettings.autosave_check_checklist
    ascheckCheckTitle := "``autosave.ahk`` check for`n ``checklist.ahk``"
    ascheckToggle := settingsGUI.Add("Checkbox", "Checked" ascheckCheck " Y+20", ascheckCheckTitle)
    ascheckToggle.OnEvent("Click", toggle.Bind("autosave check checklist"))
    autosaveCheck := (ascheckCheck = true) ? toolT.autosaveCheck.Yes : toolT.autosaveCheck.No

    ;// autosave tooltips
    tooltipCheck := UserSettings.tooltip
    tooltipCheckTitle := "``autosave.ahk`` tooltips"
    toggleToggle := settingsGUI.Add("Checkbox", "Checked" tooltipCheck " Y+5", tooltipCheckTitle)
    toggleToggle.ToolTip := (tooltipCheck = true) ? toolT.autosaveTooltip.Yes : toolT.autosaveTooltip.No
    toggleToggle.OnEvent("Click", toggle.Bind("tooltip"))


    /**
     * This function handles the logic for a few checkboxes
     * @param {any} ini is the name of the ini `Key` you wish to be toggles
     * @param {any} script the name of the guiCtrl obj that gets auto fed into this function
     */
    toggle(ini, script, unneeded)
    {
        detect()
        ToolTip("")
        ;// each switch here goes off the TITLE variable we created
        switch script.text {
            case tooltipCheckTitle:
                toolTrue := toolT.autosaveTooltip.Yes
                toolFalse := toolT.autosaveTooltip.No
            case ascheckCheckTitle:
                toolTrue := toolT.autosaveCheck.Yes
                toolFalse := toolT.autosaveCheck.No
            case StartupCheckTitle:
                toolTrue := toolT.startup.Yes
                toolFalse := toolT.startup.No
        }

        ;// toggling the checkboxes & setting values based off checkbox state
        iniVar := StrReplace(ini, A_Space, "_")
        UserSettings.%iniVar% := (script.Value = 1) ? true : false
        script.ToolTip := (script.Value = 1) ? toolTrue : toolFalse
        ;// custom logic for the run at startup option
        if ini = "run at startup"
            {
                switch script.Value {
                    case 1:
                        startupScript := ptf.rootDir "\PC Startup\PC Startup.ahk"
                        FileCreateShortcut(startupScript, ptf["scriptStartup"])
                    case 0:
                        if FileExist(ptf["scriptStartup"])
                            FileDelete(ptf["scriptStartup"])
                }
                return
            }
        ;// reloading autosave & updating setting value
        if InStr(script.text, "autosave") && WinExist("autosave.ahk - AutoHotkey")
            WM.Send_WM_COPYDATA(iniVar "_" script.Value, "autosave.ahk")
    }

    ;// checklist tooltip
    checklistTooltip := UserSettings.checklist_tooltip
    checklistTooltipTitle := "``checklist.ahk`` tooltips"
    checkTool := settingsGUI.Add("Checkbox", "Checked" checklistTooltip " Y+5", checklistTooltipTitle)
    checkTool.ToolTip := (checklistTooltip = true) ? toolT.checklistTooltip.Yes : toolT.checklistTooltip.No
    checkTool.OnEvent("Click", msgboxToggle.Bind("checklist tooltip"))

    ;// checklist wait
    checklistWait := UserSettings.checklist_wait
    checklistWaitTitle := "``checklist.ahk`` always wait"
    checkWait := settingsGUI.Add("Checkbox", "Checked" checklistWait " Y+5", checklistWaitTitle)
    checkWait.ToolTip := (checklistWait = true) ? toolT.checklistWait.Yes : toolT.checklistWait.No
    checkWait.OnEvent("Click", msgboxToggle.Bind("checklist wait"))


    /**
     * This function handles logic for checkboxes that need to pop up a msgbox to alert the user that they need to reload `checklist.ahk`
     * @param {any} ini is the name of the ini `Key` you wish to be toggles
     * @param {any} script the name of the guiCtrl obj that gets auto fed into this function
     */
    msgboxToggle(ini, script, other)
    {
        detect()
        ToolTip("")
        toolTrue := (script.text == checklistWaitTitle) ? toolT.checklistWait.Yes : toolT.checklistTooltip.Yes
        toolFalse := (script.text == checklistWaitTitle) ? toolT.checklistWait.No : toolT.checklistTooltip.No
        msgboxText := "Please stop any active checklist timers and restart ``checklist.ahk`` for this change to take effect"
        iniVar := StrReplace(ini, A_Space, "_")
        ;// setting values based on the state of the checkbox
        UserSettings.%iniVar% := (script.Value = 1) ? true : false
        checkWait.ToolTip := (script.Value = 1) ? toolTrue : toolFalse
        if WinExist("checklist.ahk - AutoHotkey")
            MsgBox(msgboxtext,, "48 4096")
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! EDIT BOXES
    premInitYear := UserSettings.prem_year
    AEInitYear   := UserSettings.ae_year

    ;// this loop auto generates the edit boxes using "..\settingsGUI\editValues.ahk"
    set_Edit_Val.init()
    loop set_Edit_Val().objs.Length {
        initValVar := StrReplace(set_Edit_Val.iniInput[A_Index], A_Space, "_")
        initVal := UserSettings.%initValVar%
        settingsGUI.Add("Edit",
                             set_Edit_Val.EditPos[A_Index] " r1 W50 Number v" set_Edit_Val.control[A_Index])
        settingsGUI.Add("UpDown",, initVal)
        settingsGUI.Add("Text",
                            set_Edit_Val.textPos[A_Index] " v" set_Edit_Val.textControl[A_Index],
                            set_Edit_Val.scriptText[A_Index])
        settingsGUI[set_Edit_Val.textControl[A_Index]].SetFont(set_Edit_Val.colour[A_Index])
        settingsGUI.Add("Text",
                            set_Edit_Val.otherTextPos[A_Index],
                            set_Edit_Val.otherText[A_Index])
        settingsGUI[set_Edit_Val.control[A_Index]].OnEvent("Change", editCtrl.Bind(set_Edit_Val.Bind[A_Index],
                                                                                    set_Edit_Val.iniInput[A_Index]))
    }

    editCtrl(script, ini, ctrl, *)
    {
        detect()
        iniVar := StrReplace(ini, A_Space, "_")
        UserSettings.%iniVar% := ctrl.value
        if WinExist(script " - AutoHotkey") {
            WM.Send_WM_COPYDATA(iniVar "_" ctrl.Value, script)
        }
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! BOTTOM TEXT
    resetText := settingsGUI.Add("Text", "Section W100 H20 X9 Y+60", "Reset")
    resetText.SetFont("S13 Bold")

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! BUTTON TOGGLES

    adobeToggle := settingsGUI.Add("Button", "w100 h30 Y+5", "adobeTemp()")
    adobeToggle.OnEvent("Click", buttons.bind("adobe"))

    firstToggle := settingsGUI.Add("Button", "w100 h30 X+15", "firstCheck()")
    firstToggle.OnEvent("Click", buttons.bind("first"))

    buttons(which, button, *)
    {
        buttonTitle := (which = "adobe") ? "adobeTemp()" : "firstCheck()"
        button.Text := (button.Text = buttonTitle) ? "undo?" : buttonTitle
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! STATUS BAR

    workDir := UserSettings.working_dir
    SB := settingsGUI.Add("StatusBar")
    SB.SetText("  Current working dir: " workDir)
    checkdir := SB.GetPos(,, &width)
    parts := SB.SetParts(width + 20 + (StrLen(workDir)*5))
    SetTimer(statecheck, -100)
    statecheck(*)
    {
        state := (A_IsSuspended = 0) ? "Active" : "Suspended"
        SB.SetText(" Scripts " state, 2)
        SetTimer(, -1000)
    }
    SB.SetFont("S9")
    SB.OnEvent("Click", dir)
    dir(*)
    {
        dirName := obj.SplitPath(workDir)
        if WinExist("ahk_exe explorer.exe " dirName.NameNoExt)
            WinActivate("ahk_exe explorer.exe " dirName.NameNoExt)
        else
            Run(workDir)
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! GROUP EXIT BUTTONS

    group := settingsGUI.Add("GroupBox", "W201 H58 xs+270 ys+5", "Exit")
    hardResetVar := settingsGUI.Add("Button", "W85 H30 x+-190 y+-40", "Hard Reset")
    hardResetVar.OnEvent("Click", close.bind("hard"))

    saveAndClose := settingsGUI.Add("Button", "W85 H30 x+10", "Save && Exit")
    saveAndClose.OnEvent("Click", close)

    settingsGUI.OnEvent("Escape", close)
    settingsGUI.OnEvent("Close", close)
    close(butt?, *)
    {
        SetTimer(statecheck, 0)
        SetTimer(iniWait, 0)
        ;check to see if the user wants to reset adobeTemp()
        if adobeToggle.Text = "undo?"
            UserSettings.adobe_temp := 0
        ;check to see if the user wants to reset firstCheck()
        if firstToggle.Text = "undo?"
            UserSettings.first_check := 0
        ;a check incase this settings gui was launched from firstCheck()
        if WinExist("Scripts Release " version)
            WinSetAlwaysOnTop(1, "Scripts Release " version)
        UserSettings.__delAll() ;// close the settings instance
        if IsSet(butt) && butt = "hard"
            {
                reload_reset_exit("reset")
                return ;// this is necessary
            }
        ;before finally closing
        settingsGUI.Destroy()
    }

    ;the below code allows for the tooltips on hover
    ;code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
    OnMessage(0x0200, ObjBindMethod(WM(), "On_WM_MOUSEMOVE"))

    ;this variable gets defined at the top of the script
    if darkMode = true
        goDark()

    goDark(darkm := true, DarkorLight := "Dark")
    {
        dark.menu(darkm)
        dark.titleBar(settingsGUI.Hwnd, darkm)
        dark.allButtons(settingsGUI, DarkorLight, {LightColour: "F0F0F0", DarkColour: "d4d4d4"})
    }

    settingsGUI.Show("Center AutoSize")
    settingsGUI.MenuBar := bar
    ;// we have to increase the size of the gui to compensate for the menubar
    settingsGUI.GetPos(,,, &height)
    settingsGUI.Move(,,, height +20)

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! MENU BAR FUNCS

    menu_AddGame(*)
    {
        gameCheckSettingGUI.Show("AutoSize")
        gameCheckSettingGUI.OnEvent("Close", Gui_Close)
        Gui_Close(*) {
            if WinExist("Settings " version)
                {
                    ExStyle := wingetExStyle("Settings " version)
			        if(ExStyle & !0x8) ; 0x8 is WS_EX_TOPMOST.
                        WinSetAlwaysOnTop(1, "Settings " version)
                    if !WinActive("Settings " version)
                        WinActivate("Settings " version)
                }
            gameCheckSettingGUI.Hide()
        }
        WinSetAlwaysOnTop(0, "Settings " version)
        settingsGUI.Opt("+Disabled")
        WinWaitClose(gameTitle)
        if WinExist("Settings " version)
            settingsGUI.Opt("-Disabled")
    }

    menu_Openini(*)
    {
        settingsGUI.GetPos(&x, &y, &width, &height)
        settingsGUI.Opt("-AlwaysOnTop")
        if WinExist("settings.ini") ;if ini already open, get pos, close, and then reopen to refresh
            refreshWin("settings.ini", UserSettings.SettingsFile)
        else
            Run("Notepad.exe " UserSettings.SettingsFile)
        if !WinWait("settings.ini",, 3)
            return
        WinMove(x+width-8, y, 322, height-2, "settings.ini")
        SetTimer(iniWait, 100)
    }
    iniWait()
    {
        if !WinExist("Settings " version)
            {
                SetTimer(, 0)
                return
            }
        if !WinExist("settings.ini") && WinExist("Settings " version)
            {
                settingsGUI.Opt("+AlwaysOnTop")
                SetTimer(, 0)
            }
    }

    /**
     * This function is called to generate either the Premiere Pro or After Effects settings gui
     */
    menu_Adobe(program, *) {
        ;// setting values depending on which program settings the user wishes to change
        switch program {
            case "Premiere":
                short := "prem"
                shortcutName := "Adobe Premiere Pro.exe"
                adobeFullName := "Adobe Premiere Pro"
                title := program " Pro Settings"
                yearIniName := "prem_year"
                iniInitYear := UserSettings.prem_year
                verIniName := "premVer"
                genProg := program
                otherTitle := "After Effects Settings"
                imageLoc := ptf.premIMGver
                path := A_ProgramFiles "\Adobe\" adobeFullName A_Space iniInitYear "\" shortcutName
            case "AE":
                short := "ae"
                shortcutName := "AfterFX.exe"
                adobeFullName := "Adobe After Effects"
                title := "After Effects Settings"
                yearIniName := "ae_year"
                iniInitYear := UserSettings.ae_year
                verIniName := "aeVer"
                genProg := "AE"
                otherTitle := "Premiere Pro Settings"
                imageLoc := ptf.aeIMGver
                path := A_ProgramFiles "\Adobe\" adobeFullName A_Space iniInitYear "\Support Files\" shortcutName
        }
        if WinExist(title)
            {
                WinActivate(title)
                return
            }
        adobeGui := tomshiBasic(,, "+MinSize275x", title)
        ctrlX := 100

        ;// start defining the gui
        adobeGui.AddText("Section", "Year: ")
        year := adobeGui.Add("Edit", "x" ctrlX " ys r1 W100 Number Limit4", iniInitYear)
        year.OnEvent("Change", __yearEvent)
        adobeGui.AddText("xs y+10", "Version: ")
        __generateDrop(genProg, &ver, ctrlX)
        adobeGui.AddText("xs y+10 Section", "Cache Dir: ")
        cacheInit := short "cache"
        cache := adobeGui.Add("Edit", "x" ctrlX " ys-5 r1 W150 ReadOnly", UserSettings.%cacheInit%)
        cacheSelect := adobeGui.Add("Button", "x+5 w60 h27", "select")
        cacheSelect.OnEvent("Click", __cacheslct.Bind(adobeFullName))

        ;// warning & save button
        adobeGui.AddText("xs+50 y+15", "*some settings will require`na full reload to take effect").SetFont("s9 italic")
        saveBut := adobeGui.Add("Button", "x+-10", "save")
        saveBut.OnEvent("Click", __saveVer)

        ;// show
        adobeGui.Show()
        ;// move gui
        add := 0
        ;// settingsgui
        WinGetPos(&x, &y,,, "Settings " version)
        if WinExist(otherTitle)
            {
                WinGetPos(,,, &yearHeight, otherTitle)
                add := yearHeight
            }
        adobeGui.GetPos(,, &width)
        adobeGui.Move(x-width+5, y+add)

        /**
         * This function handles the logic for saving the adobe version number
         */
        __editAdobeVer(ini, ctrl, *)
        {
            iniVar := StrReplace(ini, A_Space, "_")
            ;// we don't want the version ini value to change unless it's actually a new version number
            ;// (not blank) so we do a quick check beforehand
            if InStr(ctrl.Text, "v") && InStr(ctrl.Text, ".")
                UserSettings.%iniVar% := ctrl.Text
        }

        /**
         * This function handles the logic for what happens when the adobeGui save button is checked
         * It is currently reserved for future use and has no current function besides destroying the gui
         */
        __saveVer(*) => adobeGui.Destroy()

        /**
         * This function handles the logic behind what happens when the user types in a new year value
         */
        __yearEvent(*) {
            if StrLen(year.Value) != 4
                return
            if (year.Value > A_Year + 1 || year.Value < 2013) {
                ver.Delete()
                return
            }
            if SubStr(ver.value, 3, 2) != SubStr(year.Value, 3, 2)
                ver.Delete()
            new := []
            loop files ptf.ImgSearch "\" program "\*", "D" {
                if InStr(A_LoopFileName, "v" SubStr(year.Value, 3, 2))
                    new.Push(A_LoopFileName)
            }
            ver.Add(new)
            if new.Has(1)
                ver.Choose(1)
            UserSettings.%yearIniName% := year.value
            __editAdobeVer(verIniName, ver) ;// call the func to reassign the settings values
            switch adobeFullName {
                case "Adobe Premiere Pro":
                    FileCreateShortcut(A_ProgramFiles "\Adobe\" adobeFullName A_Space year.Value "\" shortcutName, ptf.SupportFiles "\shortcuts\" shortcutName ".lnk")
                case "Adobe After Effects":
                    FileCreateShortcut(A_ProgramFiles "\Adobe\" adobeFullName A_Space year.Value "\Support Files\" shortcutName, ptf.SupportFiles "\shortcuts\" shortcutName ".lnk")
            }
        }

        /**
         * This function generates the version dropdown selector
         */
        __generateDrop(program, &ver, ctrlX) {
            if (program != "AE" && program != "Premiere") {
                ;// throw
                errorLog(ValueError("Incorrect value in Parameter #1", -1, program),,, 1)
            }
            if !DirExist(ptf.ImgSearch "\" program "\") {
                ;// throw
                errorLog(ValueError("ImageSearch directory cannot be found", -1, ptf.ImgSearch "\" program),,, 1)
            }
            supportedVers := []
            loop files ptf.ImgSearch "\" program "\*", "D" {
                if InStr(A_LoopFileName, "v" SubStr(iniInitYear, 3, 2))
                    supportedVers.Push(A_LoopFileName)
            }

            for value in supportedVers {
                if value = imageLoc
                    {
                        defaultIndex := A_Index
                        break
                    }
            }
            if !IsSet(defaultIndex)
                defaultIndex := 1
            ver := adobeGui.Add("DropDownList", "x" ctrlX " y+-20 w100 Choose" defaultIndex, supportedVers)
            ver.OnEvent("Change", editCtrl.bind("", verIniName))
        }

        __cacheslct(progName, *) {
            WinSetAlwaysOnTop(0, "Settings " version)
            settingsGUI.Opt("+Disabled")
            slct := FileSelect("D",, "Select " progName " Cache Folder")
            if slct = ""
                {
                    if WinExist("Settings " version)
                        settingsGUI.Opt("-Disabled")
                    return
                }
            UserSettings.%cacheInit% := slct
            cache.Text := slct
            if WinExist("Settings " version)
                settingsGUI.Opt("-Disabled")
        }
    }
}