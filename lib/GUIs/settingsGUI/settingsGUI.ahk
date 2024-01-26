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
#Include <Classes\reset>
#Include <Functions\refreshWin>
#Include <Functions\detect>
#Include <Functions\checkInternet>
#Include <Functions\generateAdobeShortcut>
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
    autosaveBeep := {
        Yes: "``autosave.ahk`` will beep to alert the user it is attempting to save",
        No: "``autosave.ahk`` will no longer beep to alert the user that it is attempting to save"
    }
    autosaveMouse := {
        Yes: "``autosave.ahk`` will check to ensure you haven't recently interacted with the mouse",
        No: "``autosave.ahk`` will no longer check to ensure you haven't recently interacted with the mouse"
    }
    autosaveOverride := {
        Yes: "Manually saving within Premiere/After Effects will reset ``autosave.ahk`` timer",
        No: "Manually saving within Premiere/After Effects will have no effect on ``autosave.ahk``"
    }
    checklistTooltip := {
        Yes: "``checklist.ahk`` will produce tooltips to remind you if you've paused the timer",
        No: "``checklist.ahk`` will no longer produce tooltips to remind you if you've paused the timer"
    }
    checklistWait := {
        Yes: "``checklist.ahk`` will always wait for you to open a premiere project before opening",
        No: "``checklist.ahk`` will prompt the user if you wish to wait or manually open a project"
    }
    checklistHotkeys := {
        Yes: "``checklist.ahk`` will create a hotkey to start/stop the timer. (Shift & Media_Play_Pause)",
        No: "``checklist.ahk`` will no longer create a hotkey to start/stop the timer."
    }
    discAutoReply := {
        Yes: "``discord.button(`"DiscReply.png`")`` will disable the @ ping automatically when replying",
        No: "``discord.button(`"DiscReply.png`")`` will not disable the @ ping when replying"
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
    settingsGUI.AddText("W100 H20 xs Y7", "Toggle").SetFont("S13 Bold")

    settingsGUI.AddText("W100 H20 x+125", "Adjust").SetFont("S13 Bold")

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
    settingsGUI.AddCheckbox("vdarkCheck Checked" UserSettings.dark_mode " Y+5", "Dark Mode").OnEvent("Click", darkToggle)
    switch UserSettings.dark_mode {
        case true:  settingsGUI["darkCheck"].ToolTip := toolT.dark.Yes
        case false: settingsGUI["darkCheck"].ToolTip := toolT.dark.No
        case "disabled":
            settingsGUI["darkCheck"].ToolTip := toolT.dark.disabled
            settingsGUI["darkCheck"].Opt("+Disabled")
    }
    darkToggle(*)
    {
        ToolTip("")
        darkToggleVal := settingsGUI["darkCheck"].Value
        UserSettings.dark_mode := (settingsGUI["darkCheck"].Value = 1) ? true : false
        settingsGUI["darkCheck"].ToolTip := (settingsGUI["darkCheck"].Value = 1) ? toolT.dark.Yes : toolT.dark.No
        if (settingsGUI["darkCheck"].Value = 1)
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
    StartupCheckTitle := "Run at Startup"
    settingsGUI.AddCheckbox("vStartupCheck Checked" UserSettings.run_at_startup " Y+5", StartupCheckTitle).OnEvent("Click", toggle.Bind("run at startup"))
    switch UserSettings.run_at_startup {
        case true:  settingsGUI["StartupCheck"].ToolTip := toolT.startup.Yes
        case false: settingsGUI["StartupCheck"].ToolTip := toolT.startup.No
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! script checkboxes

    ;// autosave check mouse
    ascheckMouseTitle := "``autosave.ahk`` check mouse"
    settingsGUI.AddCheckbox("vasmouseToggle Checked" UserSettings.autosave_check_mouse " Y+20", ascheckMouseTitle).OnEvent("Click", toggle.Bind("autosave check mouse", "autosave"))
    settingsGUI["asmouseToggle"].ToolTip := (UserSettings.autosave_check_mouse = true) ? toolT.autosaveMouse.Yes : toolT.autosaveMouse.No

    ;// autosave beep
    asBeepTitle := "``autosave.ahk`` beep"
    settingsGUI.AddCheckbox("vasbeepToggle Checked" UserSettings.autosave_beep " Y+5", asBeepTitle).OnEvent("Click", toggle.Bind("autosave beep", "autosave"))
    settingsGUI["asbeepToggle"].ToolTip := (UserSettings.autosave_beep = true) ? toolT.autosaveBeep.Yes : toolT.autosaveBeep.No

    ;// autosave save override
    asOverrideTitle := "``autosave.ahk`` save override"
    settingsGUI.AddCheckbox("vasOverride Checked" UserSettings.autosave_save_override " Y+5", asOverrideTitle).OnEvent("Click", toggle.Bind("autosave save override", "autosave"))
    settingsGUI["asOverride"].ToolTip := (UserSettings.autosave_save_override = true) ? toolT.autosaveOverride.Yes : toolT.autosaveOverride.No

    /**
     * This function handles the logic for a few checkboxes
     * @param {any} ini is the name of the ini `Key` you wish to be toggles
     * @param {any} script the name of the guiCtrl obj that gets auto fed into this function
     */
    toggle(ini, objName := "", script?, unneeded?)
    {
        detect()
        ToolTip("")
        ;// each switch here goes off the TITLE variable we created
        switch script.text {
            case ascheckMouseTitle:
                toolTrue := toolT.autosaveMouse.Yes
                toolFalse := toolT.autosaveMouse.No
            case StartupCheckTitle:
                toolTrue := toolT.startup.Yes
                toolFalse := toolT.startup.No
            case asBeepTitle:
                toolTrue := toolT.autosaveBeep.Yes
                toolFalse := toolT.autosaveBeep.No
            case asOverrideTitle:
                toolTrue := toolT.autosaveOverride.yes
                toolFalse := toolT.autosaveOverride.no
            case discAutoReply:
                toolTrue := toolT.discAutoReply.yes
                toolFalse := toolT.discAutoReply.no
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
        ;// changing requested value
        if InStr(script.text, "autosave") && WinExist("autosave.ahk - AutoHotkey")
            WM.Send_WM_COPYDATA(iniVar "," script.Value "," objName, "autosave.ahk")
    }

    ;// checklist create hotkeys
    checklistHotkeysTitle := "``checklist.ahk`` create hotkey"
    settingsGUI.AddCheckbox("vcheckHTool Checked" UserSettings.checklist_hotkeys " Y+5", checklistHotkeysTitle).OnEvent("Click", msgboxToggle.Bind("checklist hotkeys"))
    settingsGUI["checkHTool"].ToolTip := (UserSettings.checklist_hotkeys = true) ? toolT.checklistHotkeys.Yes : toolT.checklistHotkeys.No

    ;// checklist tooltip
    checklistTooltipTitle := "``checklist.ahk`` tooltips"
    settingsGUI.AddCheckbox("vcheckTool Checked" UserSettings.checklist_tooltip " Y+5", checklistTooltipTitle).OnEvent("Click", msgboxToggle.Bind("checklist tooltip"))
    settingsGUI["checkTool"].ToolTip := (UserSettings.checklist_tooltip = true) ? toolT.checklistTooltip.Yes : toolT.checklistTooltip.No

    ;// disc disable autoreply
    discAutoReply := "Disable Discord Reply Ping"
    settingsGUI.AddCheckbox("vdiscReply Checked" UserSettings.disc_disable_autoreply " Y+5", discAutoReply).OnEvent("Click", toggle.Bind("disc disable autoreply", ""))
    settingsGUI["discReply"].ToolTip := (UserSettings.disc_disable_autoreply = true) ? toolT.discAutoReply.Yes : toolT.discAutoReply.No

    /**
     * This function handles logic for checkboxes that need to pop up a msgbox to alert the user that they need to reload `checklist.ahk`
     * @param {any} ini is the name of the ini `Key` you wish to be toggles
     * @param {any} script the name of the guiCtrl obj that gets auto fed into this function
     */
    msgboxToggle(ini, script, other)
    {
        detect()
        ToolTip("")
        msgboxText := "Please stop any active checklist timers and restart ``checklist.ahk`` for this change to take effect"
        iniVar := StrReplace(ini, A_Space, "_")
        ;// setting values based on the state of the checkbox
        UserSettings.%iniVar% := (script.Value = 1) ? true : false
        settingsGUI["checkWait"].ToolTip := (script.Value = 1) ? toolT.checklistTooltip.Yes : toolT.checklistTooltip.No
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
                             set_Edit_Val.EditPos[A_Index] " r1 W50 -E0200 Number v" set_Edit_Val.control[A_Index])
        settingsGUI.Add("UpDown", set_Edit_Val.UpDownOpt[A_Index], initVal)
        settingsGUI.Add("Text",
                            set_Edit_Val.textPos[A_Index] " v" set_Edit_Val.textControl[A_Index],
                            set_Edit_Val.scriptText[A_Index])
        settingsGUI[set_Edit_Val.textControl[A_Index]].SetFont(set_Edit_Val.colour[A_Index])
        settingsGUI.Add("Text",
                            set_Edit_Val.otherTextPos[A_Index],
                            set_Edit_Val.otherText[A_Index])
        settingsGUI[set_Edit_Val.control[A_Index]].OnEvent("Change", editCtrl.Bind(set_Edit_Val.Bind[A_Index], set_Edit_Val.iniInput[A_Index], set_Edit_Val.objName[A_Index]))
    }

    editCtrl(script, ini, objName, ctrl, *)
    {
        detect()
        iniVar := StrReplace(ini, A_Space, "_")
        UserSettings.%iniVar% := ctrl.text
        if WinExist(script " - AutoHotkey") && script != "" {
            WM.Send_WM_COPYDATA(iniVar "," ctrl.text "," objName, script)
        }
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! BOTTOM TEXT
    resetText := settingsGUI.Add("Text", "Section W100 H20 X9 Y+120", "Reset")
    resetText.SetFont("S13 Bold")

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! BUTTON TOGGLES

    settingsGUI.Add("Button", "vadobeToggle w100 h30 Y+5", "adobeTemp()").OnEvent("Click", buttons.bind("adobe"))
    settingsGUI.Add("Button", "vfirstToggle w100 h30 X+15", "firstCheck()").OnEvent("Click", buttons.bind("first"))

    buttons(which, button, *)
    {
        buttonTitle := (which = "adobe") ? "adobeTemp()" : "firstCheck()"
        button.Text := (button.Text = buttonTitle) ? "undo?" : buttonTitle
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! STATUS BAR

    workDir := UserSettings.working_dir
    SB := settingsGUI.Add("StatusBar", "-Theme Background0xc0c0c0")
    SB.SetText("  Current working dir: " workDir,, 1)
    checkdir := SB.GetPos(,, &width)
    parts := SB.SetParts(width + 20 + (StrLen(workDir)*5))
    SetTimer(statecheck, -100)
    statecheck(*)
    {
        state := (A_IsSuspended = 0) ? "Active" : "Suspended"
        SB.SetText(A_Tab "Scripts " state, 2, 1)
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

    settingsGUI.AddGroupBox("W201 H58 xs+270 ys+5", "Exit")
    settingsGUI.AddButton("W85 H30 x+-190 y+-40", "Hard Reset").OnEvent("Click", close.bind("hard"))

    settingsGUI.AddButton("W85 H30 x+10", "Save && Exit").OnEvent("Click", close)

    settingsGUI.OnEvent("Escape", close)
    settingsGUI.OnEvent("Close", close)
    close(butt?, *)
    {
        SetTimer(statecheck, 0)
        SetTimer(iniWait, 0)
        ;check to see if the user wants to reset adobeTemp()
        if settingsGUI["adobeToggle"].Text = "undo?"
            UserSettings.adobe_temp := 0
        ;check to see if the user wants to reset firstCheck()
        if settingsGUI["firstToggle"].Text = "undo?"
            UserSettings.first_check := 0
        ;a check incase this settings gui was launched from firstCheck()
        if WinExist("Scripts Release " version)
            WinSetAlwaysOnTop(1, "Scripts Release " version)
        ToolTip("")
        tool.Tray({text: "Settings changes are being saved", title: "settingsGUI()", options: 20}, 2000)
        UserSettings.__delAll() ;// close the settings instance
        ToolTip("")
        if IsSet(butt) && butt = "hard"
            {
                reset.reset()
                return ;// this is necessary
            }
        ;before finally closing
        settingsGUI.Destroy()
    }

    ;the below code allows for the tooltips on hover
    ;code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
    OnMessage(0x0200, ObjBindMethod(WM(), "On_WM_MOUSEMOVE"))

    goDark(darkm := true, DarkorLight := "Dark")
    {
        dark.menu(darkm)
        dark.titleBar(settingsGUI.Hwnd, darkm)
        dark.allButtons(settingsGUI, DarkorLight, {LightColour: settingsGUI.LightColour, DarkColour: settingsGUI.DarkColour})
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
                shortcutNameBeta := "Adobe Premiere Pro (Beta).exe"
                adobeFullName := "Adobe Premiere Pro"
                title := program " Pro Settings"
                yearIniName := "prem_year"
                iniInitYear := UserSettings.prem_year
                verIniName := "premVer"
                genProg := program
                otherTitle := "After Effects Settings"
                static imageLoc := ptf.premIMGver
                path := A_ProgramFiles "\Adobe\" adobeFullName A_Space iniInitYear "\" shortcutName
            case "AE":
                short := "ae"
                shortcutName := "AfterFX.exe"
                shortcutNameBeta := "AfterFX (Beta).exe"
                adobeFullName := "Adobe After Effects"
                title := "After Effects Settings"
                yearIniName := "ae_year"
                iniInitYear := UserSettings.ae_year
                verIniName := "aeVer"
                genProg := "AE"
                otherTitle := "Premiere Pro Settings"
                static imageLoc := ptf.aeIMGver
                path := A_ProgramFiles "\Adobe\" adobeFullName A_Space iniInitYear "\Support Files\" shortcutName
        }
        if WinExist(title) {
            WinActivate(title)
            return
        }
        adobeGui := tomshiBasic(,, "+MinSize275x", title)
        ctrlX := 100

        ;// start defining the gui
        adobeGui.AddText("Section", "Year: ")
        __generateDropYear(genProg, &year, ctrlX)
        adobeGui.AddText("xs y+10", "Version: ")
        __generateDropVer(genProg, &ver, ctrlX)
        adobeGui.AddCheckbox("x+10 y+-20 vIsBeta Checked" UserSettings.%short%IsBeta, "Is Beta Version?").OnEvent("Click", (guiCtrl, *) => (UserSettings.%short%IsBeta := guiCtrl.value, __generateShortcut()))
        if program = "Premiere" {
            adobeGui.AddText("xs y+10 Section", "Focus Timeline Icon: ")
            timelineCheckbox := adobeGui.AddCheckbox("xs+135 ys+1 Checked" UserSettings.prem_Focus_Icon)
            timelineCheckbox.OnEvent("Click", timelineCheckbx)
            timelineCheckbx(guiobj, *) => UserSettings.prem_Focus_Icon := timelineCheckbox.value
        }
        adobeGui.AddText("xs y+12 Section", "Cache Dir: ")
        cacheInit := short "cache"
        cache := adobeGui.Add("Edit", "x" ctrlX " ys-3 r1 W150 ReadOnly", UserSettings.%cacheInit%)
        cacheSelect := adobeGui.Add("Button", "x+5 w60 h27", "select")
        cacheSelect.OnEvent("Click", __cacheslct.Bind(adobeFullName))

        ;// warning & save button
        adobeGui.AddText("xs+50 y+15", "*some settings will require`na full reload to take effect").SetFont("s9 italic")
        saveBut := adobeGui.Add("Button", "x+-10", "close")
        saveBut.OnEvent("Click", __saveVer)

        ;// show
        adobeGui.Show()
        ;// move gui
        add := 0
        ;// settingsgui
        WinGetPos(&x, &y,,, "Settings " version)
        if WinExist(otherTitle) {
            WinGetPos(,,, &yearHeight, otherTitle)
            add := yearHeight
        }
        adobeGui.GetPos(,, &width)
        adobeGui.Move(x-width+5, y+add)

        /**
         * This function handles the logic for saving the adobe version number
         */
        __editAdobeVer(ini, ctrl, *) {
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
         * This function handles the logic behind what happens when the user selects a new year value
         */
        __yearEventDropDown(*) {
            ver.Delete()
            new := []
            loop files ptf.ImgSearch "\" program "\*", "D" {
                if InStr(A_LoopFileName, "v" SubStr(year.Text, 3, 2))
                    new.Push(A_LoopFileName)
            }
            ver.Add(new)
            if !new.Has(1)
                return
            ver.Choose(new.Length)
            UserSettings.%yearIniName% := year.text
            __editAdobeVer(verIniName, ver) ;// call the func to reassign the settings values
        }

        __generateShortcut() => generateAdobeShortcut(UserSettings, adobeFullName, year.text)

        /**
         * This function generates the year dropdown selector
         */
        __generateDropYear(program, &year, ctrlX) {
            if (program != "AE" && program != "Premiere") {
                ;// throw
                errorLog(ValueError("Incorrect value in Parameter #1", -1, program),,, 1)
            }
            if !DirExist(ptf.ImgSearch "\" program "\") {
                ;// throw
                errorLog(ValueError("ImageSearch directory cannot be found", -1, ptf.ImgSearch "\" program),,, 1)
            }
            supportedVers := []
            foundYears := Map()
            loop files ptf.ImgSearch "\" program "\*", "D" {
                loopYear := SubStr(A_Year, 1, 2) SubStr(A_LoopFileName, 2, 2)
                if !foundYears.Has(loopYear) {
                    supportedVers.Push(loopYear)
                    foundYears.Set(loopYear, 1)
                }
            }
            for value in supportedVers {
                if value = iniInitYear
                    {
                        defaultIndex := A_Index
                        break
                    }
            }
            if !IsSet(defaultIndex)
                defaultIndex := 1
            year := adobeGui.AddDropDownList("x" ctrlX " y+-20 w100 Choose" defaultIndex, supportedVers)
            year.OnEvent("Change", __yearEventDropDown)
        }

        /**
         * This function generates the version dropdown selector
         */
        __generateDropVer(program, &ver, ctrlX) {
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
                if checkV := SubStr(A_LoopFileName, 1, 1) != "v"
                    continue
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

            ;// look idk using .bind wasn't calling the editCtrl function, I gave up, this is easier
            doChange() {
                editCtrl("", verIniName, "", ver)
                imageLoc := ver.Text
            }
            ver.OnEvent("Change", (*) => doChange())
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