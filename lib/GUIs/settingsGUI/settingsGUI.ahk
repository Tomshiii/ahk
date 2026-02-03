/************************************************************************
 * @author tomshi
 * @date 2026/02/03
 * @version 2.4.5
 ***********************************************************************/
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Settings.ahk
#Include GUIs\tomshiBasic.ahk
#Include GUIs\gameCheckGUI.ahk
#Include GUIs\settingsGUI\editValues.ahk
#Include Classes\dark.ahk
#Include Classes\tool.ahk
#Include Classes\ptf.ahk
#Include Classes\obj.ahk
#Include Classes\WM.ahk
#Include Classes\reset.ahk
#Include Classes\winget.ahk
#Include Classes\CLSID_Objs.ahk
#Include Other\Notify\Notify.ahk
#Include Other\Array.ahk
#Include Functions\refreshWin.ahk
#Include Functions\detect.ahk
#Include Functions\checkInternet.ahk
#Include Functions\generateAdobeShortcut.ahk
#Include Functions\notifyIfNotExist.ahk
;}


/**
 * A GUI window to allow the user to toggle settings contained within the `settings.ini` file
*/
settingsGUI()
{
    ;this function is needed to reload some scripts
    detect()
    ;// stop script from opening if the notify window still exists to give it a chance to save previous changes
    if Notify.Exist('settingsGUI') {
        loop 80 {
            if !Notify.Exist('settingsGUI')
                break
            sleep 25
        }
    }

    readSet := FileRead(ptf.lib "\GUIs\settingsGUI\values.json")
    setJSON := JSON.parse(readSet,, false)
    UserSettings := CLSID_Objs.load("UserSettings")
    initialSettings := FileRead(UserSettings.SettingsFile)

    ;// menubar
    FileMenu := Menu()
    FileMenu.Add("&Add Game to ``gameCheck.ahk```tCtrl+A", menu_AddGame)
    openMenu := Menu()
    openMenu.Add("&settings.ini`tCtrl+i", menu_Openini)
    openMenu.Add("&Wiki", (*) => MsgBox("Not implemented"))
    openMenu.Disable("&Wiki")
    openMenu.Add("&Settings Cheat Sheet`tCtrl+S", openWiki.Bind("cheat"))
    openMenu.Add("&Wiki Dir`tCtrl+O", openWiki.Bind("local"))
    openMenu.Add("&Wiki Web`tCtrl+W", openWiki.Bind("web"))
    editorsMenu := Menu()
    editorsMenu.Add("&Adobe", (*) => MsgBox("Not implemented"))
    editorsMenu.Disable("&Adobe")
    editorsMenu.Add("&After Effects", menu_Adobe.bind("AE"))
    editorsMenu.Add("&Premiere", menu_Adobe.bind("Premiere"))
    ; editorsMenu.Add("&Photoshop", menu_Adobe.bind("Photoshop")) ;// call a different gui
    ; editorsMenu.Add("&Resolve", ) ;// call a different gui
    othersMenu := Menu()
    othersMenu.Add("&Thio MButton Script", menu_Thio.Bind())
    ;// define the entire menubar
    bar := MenuBar()
    bar.Add("&File", FileMenu)
    bar.Add("&Open", openMenu)
    bar.Add("&Editors", editorsMenu)
    bar.Add("&Other Settings", OthersMenu)

    openWiki(which, *) {
        openWikiPage(title, link) {
            checkInt := checkInternet()
            if !checkInt {
                tool.Cust("It doesn't appear like you have an active internet connection", 2.0)
                tool.Cust("The page will run just incase", 2.0,, 20, 2)
            }
            if WinExist(title)
                WinActivate(title)
            else
                Run(link)
        }
        switch which {
            case "local":
                if WinExist("Wiki explorer.exe")
                    WinActivate("Wiki explorer.exe")
                else {
                    if !DirExist(ptf.Wiki "\Latest")
                        return
                    Run(ptf.Wiki "\Latest")
                }
            case "web": openWikiPage("Home · Tomshiii/ahk Wiki", "https://github.com/Tomshiii/ahk/wiki")
            case "cheat": openWikiPage("settingsGUI() · Tomshiii/ahk Wiki", "https://github.com/Tomshiii/ahk/wiki/settingsGUI()")
        }
    }

    try { ;attempting to grab window information on the active window for `menu_AddGame()`
        winProcc := WinGetProcessName("A")
        winTitle := WinGet.Title()
    } catch {
        winProcc := ""
        winTitle := ""
    }

    darkMode := UserSettings.dark_mode
    version  := UserSettings.version

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
    settingsGUI.AddText("W100 H20 xs Y7", "✔️ Toggle").SetFont("S13 Bold")
    settingsGUI.AddText("W100 H20 x+361", "↩ Adjust").SetFont("S13 Bold")
    settingsGUI.AddButton("W23 H22 x+125", "❓").OnEvent("Click", (*) => (Run("https://github.com/Tomshiii/ahk/wiki/settingsGUI()")))

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! checkboxes

    ;// update check
    checkVal := UserSettings.update_check = "stop" ? "-1" : UserSettings.update_check
    updateCheckToggle := settingsGUI.Add("Checkbox", "Check3 Checked" checkVal " section xs+1 Y+5", setJSON.updateCheck.title)
    updateCheckToggle.ToolTip := (checkVal != true && checkVal != false)
            ? setJSON.updateCheck.tooltip.stop
            : (checkval = true) ?  setJSON.updateCheck.tooltip.true : setJSON.updateCheck.tooltip.false
    updateCheckToggle.OnEvent("Click", update)
    update(*)
    {
        ToolTip("")
        switch updateCheckToggle.Value {
            case 1: ;true
                UserSettings.update_check := true
                updateCheckToggle.ToolTip := setJSON.updateCheck.tooltip.true
                if UserSettings.beta_update_check = true
                    betaupdateCheckToggle.Value := 1
            case -1: ;false
                UserSettings.update_check := false
                updateCheckToggle.ToolTip := setJSON.updateCheck.tooltip.false
                if UserSettings.beta_update_check = true
                    betaupdateCheckToggle.Value := 1
            case 0: ;stop
                betaupdateCheckToggle.Value := 0
                UserSettings.update_check := "stop"
                updateCheckToggle.ToolTip := setJSON.updateCheck.tooltip.stop
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

    ;// lib update check
    settingsGUI.AddCheckbox("vahkCheck Checked" UserSettings.ahk_update_check " Y+5", setJSON.ahkUpdate.title).OnEvent("Click", toggle.Bind("ahk update check", "", ""))
    settingsGUI["ahkCheck"].ToolTip := (UserSettings.ahk_update_check = true) ? setJSON.ahkUpdate.tooltip.true : setJSON.ahkUpdate.tooltip.false

    ;// lib update check
    settingsGUI.AddCheckbox("vlibCheck Checked" UserSettings.lib_update_check " Y+5", setJSON.libUpdate.title).OnEvent("Click", toggle.Bind("lib update check", "", ""))
    settingsGUI["libCheck"].ToolTip := (UserSettings.lib_update_check = true) ? setJSON.libUpdate.tooltip.true : setJSON.libUpdate.tooltip.false

    ;// package update check
    settingsGUI.AddCheckbox("vpackageCheck Checked" UserSettings.package_update_check " Y+5", setJSON.packageUpdate.title).OnEvent("Click", toggle.Bind("package update check", "", ""))
    settingsGUI["packageCheck"].ToolTip := (UserSettings.package_update_check = true) ? setJSON.packageUpdate.tooltip.true : setJSON.packageUpdate.tooltip.false

    ;// adobe vers check
    settingsGUI.AddCheckbox("vVersCheck Checked" UserSettings.update_adobe_vers " Y+5", setJSON.versUpdate.title).OnEvent("Click", toggle.Bind("update adobe vers", "", ""))
    settingsGUI["VersCheck"].ToolTip := (UserSettings.update_adobe_vers = true) ? setJSON.versUpdate.tooltip.true : setJSON.versUpdate.tooltip.false

    ;// git update check
    settingsGUI.AddCheckbox("vgitCheck Checked" UserSettings.update_git " Y+5", setJSON.gitUpdate.title).OnEvent("Click", toggle.Bind("update git", "", ""))
    settingsGUI["gitCheck"].ToolTip := (UserSettings.update_git = true) ? setJSON.gitUpdate.tooltip.true : setJSON.gitUpdate.tooltip.false


    ;// adobe version override
    settingsGUI.AddCheckbox("vadobeExeOverride Checked" UserSettings.adobeExeOverride " Y+15", setJSON.adobeExeOverride.title).OnEvent("Click", toggle.Bind("adobeExeOverride", "", ""))
    settingsGUI["adobeExeOverride"].ToolTip := (UserSettings.adobeExeOverride = true) ? setJSON.adobeExeOverride.tooltip.true : setJSON.adobeExeOverride.tooltip.false

    ;// dark mode toggle
    settingsGUI.AddCheckbox("vdarkCheck Checked" UserSettings.dark_mode " Y+5", setJSON.dark.title).OnEvent("Click", darkToggle)
    switch UserSettings.dark_mode {
        case true:  settingsGUI["darkCheck"].ToolTip := setJSON.dark.tooltip.true
        case false: settingsGUI["darkCheck"].ToolTip := setJSON.dark.tooltip.false
        case "disabled":
            settingsGUI["darkCheck"].ToolTip := setJSON.dark.tooltip.disabled
            settingsGUI["darkCheck"].Opt("+Disabled")
    }
    darkToggle(*)
    {
        ToolTip("")
        darkToggleVal := settingsGUI["darkCheck"].Value
        UserSettings.dark_mode := (settingsGUI["darkCheck"].Value = 1) ? true : false
        settingsGUI["darkCheck"].ToolTip := (settingsGUI["darkCheck"].Value = 1) ? setJSON.dark.tooltip.true : setJSON.dark.tooltip.false
        if (settingsGUI["darkCheck"].Value = 1) {
            tool.Cust(setJSON.dark.tooltip.true, 2000)
            goDark()
            return
        }
        ;// dark mode is false
        tool.Cust(setJSON.dark.tooltip.false, 2000)
        goDark(false, "Light")
    }

    ;// disc disable autoreply
    settingsGUI.AddCheckbox("vdiscAutoReply Checked" UserSettings.disc_disable_autoreply " Y+5", setJSON.discAutoReply.title).OnEvent("Click", toggle.Bind("disc disable autoreply", "", ""))
    settingsGUI["discAutoReply"].ToolTip := (UserSettings.disc_disable_autoreply = true) ? setJSON.discAutoReply.tooltip.true : setJSON.discAutoReply.tooltip.false

    ;// run at startup
    settingsGUI.AddCheckbox("vstartup Checked" UserSettings.run_at_startup " Y+5", setJSON.startup.title).OnEvent("Click", toggle.Bind("run at startup", "", ""))
    settingsGUI["startup"].ToolTip := (UserSettings.run_at_startup = true) ? setJSON.startup.tooltip.true : setJSON.startup.tooltip.false

    ;// show adobe vers on startup
    settingsGUI.AddCheckbox("vadobeVersStartup Checked" UserSettings.show_adobe_vers_startup " Y+5", setJSON.show_adobe_vers_startup.title).OnEvent("Click", toggle.Bind("show adobe vers startup", "", ""))
    settingsGUI["adobeVersStartup"].ToolTip := (UserSettings.show_adobe_vers_startup = true) ? setJSON.show_adobe_vers_startup.tooltip.true : setJSON.show_adobe_vers_startup.tooltip.false

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! script checkboxes

    ;// autosave always save
    settingsGUI.AddCheckbox("vautosaveAlwaysSave Checked" UserSettings.autosave_always_save " xs+230 ys Section", setJSON.autosaveAlwaysSave.title).OnEvent("Click", toggle.Bind("autosave always save", "autosave", ""))
    settingsGUI["autosaveAlwaysSave"].ToolTip := (UserSettings.autosave_always_save = true) ? setJSON.autosaveAlwaysSave.tooltip.true : setJSON.autosaveAlwaysSave.tooltip.false

    ;// autosave beep
    settingsGUI.AddCheckbox("vautosaveBeep Checked" UserSettings.autosave_beep " Y+5", setJSON.autosaveBeep.title).OnEvent("Click", toggle.Bind("autosave beep", "autosave", ""))
    settingsGUI["autosaveBeep"].ToolTip := (UserSettings.autosave_beep = true) ? setJSON.autosaveBeep.tooltip.true : setJSON.autosaveBeep.tooltip.false

    ;// autosave check mouse
    settingsGUI.AddCheckbox("vautosaveMouse Checked" UserSettings.autosave_check_mouse " Y+5", setJSON.autosaveMouse.title).OnEvent("Click", toggle.Bind("autosave check mouse", "autosave", ""))
    settingsGUI["autosaveMouse"].ToolTip := (UserSettings.autosave_check_mouse = true) ? setJSON.autosaveMouse.tooltip.true : setJSON.autosaveMouse.tooltip.false

    ;// autosave restart playback
    settingsGUI.AddCheckbox("vautosaveRestartPlayback Checked" UserSettings.autosave_restart_playback " Y+5", setJSON.autosaveRestartPlayback.title).OnEvent("Click", toggle.Bind("autosave restart playback", "autosave", ""))
    settingsGUI["autosaveRestartPlayback"].ToolTip := (UserSettings.autosave_restart_playback = true) ? setJSON.autosaveRestartPlayback.tooltip.true : setJSON.autosaveRestartPlayback.tooltip.false

    ;// autosave save override
    settingsGUI.AddCheckbox("vautosaveOverride Checked" UserSettings.autosave_save_override " Y+5", setJSON.autosaveOverride.title).OnEvent("Click", toggle.Bind("autosave save override", "autosave", ""))
    settingsGUI["autosaveOverride"].ToolTip := (UserSettings.autosave_save_override = true) ? setJSON.autosaveOverride.tooltip.true : setJSON.autosaveOverride.tooltip.false

    /**
     * This function handles the logic for a few checkboxes
     * @param {any} ini is the name of the ini `Key` you wish to be toggles
     * @param {string} objName used for `autosave` settings. must be either "autosave" or passed as ""
     * @param {Gui} altGUI pass in an alternate GUI to operate on instead
     * @param {any} script the name of the guiCtrl obj that gets auto fed into this function
     */
    toggle(ini, objName := "", altGUI := unset, script?, *)
    {
        detect()
        ToolTip("")
        ;// each switch here goes off the TITLE variable we created
        try {
            replaceVal := UserSettings.__convertToStr(script.value)
            script.ToolTip := setJSON.%script.name%.tooltip.%replaceVal%
        }

        ;// toggling the checkboxes & setting values based off checkbox state
        iniVar := StrReplace(ini, A_Space, "_")
        UserSettings.%iniVar% := (script.Value = 1) ? true : false
        switch ini {
            case "run at startup":
                switch script.Value {
                    case 1:
                        startupScript := ptf.rootDir "\PC Startup\Initialise.ahk"
                        FileCreateShortcut(startupScript, ptf["scriptStartup"])
                    case 0:
                        if FileExist(ptf["scriptStartup"])
                            FileDelete(ptf["scriptStartup"])
                }
                return
            case "Always Check UIA":
                (script.Value = 0) ? (settingsGUI["setUIA_LimitDaily"].Opt("+Disabled"), UserSettings.Set_UIA_Limit_Daily := "disabled")
                                   : (settingsGUI["setUIA_LimitDaily"].Opt("-Disabled"), UserSettings.Set_UIA_Limit_Daily := "false")
            case "Use Thio MButton":
                (script.Value = 0) ? (altGUI["Use_MButton"].Opt("+Disabled"), UserSettings.Use_MButton := "disabled")
                                   : (altGUI["Use_MButton"].Opt("-Disabled"), UserSettings.Use_MButton := "false")
            case "Use MButton":
                (script.Value = 1) ? altGUI["thioHotkey"].Opt("+Disabled") : altGUI["thioHotkey"].Opt("-Disabled")
            case "Use swapSequences":
                (script.Value = 0) ? settingsGUI["premPrev"].Opt("+Disabled")
                                   : settingsGUI["premPrev"].Opt("-Disabled")
                origDetect := detect()
                if WinExist("Core Functionality.ahk") {
                    try {
                        activeObj := CLSID_Objs.load("prem")
                        switch script.Value {
                            case 0:
                                activeObj.useSwapSequences := false
                                activeObj.resetSeqTimer    := true
                            case 1:
                                activeObj.useSwapSequences := true
                                SetTimer(activeObj.__setCurrSeq.Bind(activeObj), activeObj.prevSeqDelay)
                        }
                        activeObj := ""
                    } catch {
                        activeObj := ""
                        notifyIfNotExist("settingsGUIswapSeq", "settingsGUI()", "Could not disable ``prem.swapSequences()``. A reload may be required", ptf.Icons "\myscript.ico", "Windows Pop-up Blocked",, "POS=BR DUR=5 SHOW=Fade@250 bdr=0xF59F10 maxW=400 Hide=Fade@250")
                    }
                }
                resetOrigDetect(origDetect)
        }
        ;// changing requested value
        if InStr(script.text, "autosave") && WinExist("autosave.ahk - AutoHotkey")
            WM.Send_WM_COPYDATA(iniVar "," script.Value "," objName, "autosave.ahk")
    }

    ;// checklist create hotkeys
    settingsGUI.AddCheckbox("vchecklistHotkeys Checked" UserSettings.checklist_hotkeys " Y+5", setJSON.checklistHotkeys.title).OnEvent("Click", msgboxToggle.Bind("checklist hotkeys"))
    settingsGUI["checklistHotkeys"].ToolTip := (UserSettings.checklist_hotkeys = true) ? setJSON.checklistHotkeys.tooltip.true : setJSON.checklistHotkeys.tooltip.false

    ;// checklist tooltip
    settingsGUI.AddCheckbox("vchecklistTooltip Checked" UserSettings.checklist_tooltip " Y+5", setJSON.checklistTooltip.title).OnEvent("Click", msgboxToggle.Bind("checklist tooltip"))
    settingsGUI["checklistTooltip"].ToolTip := (UserSettings.checklist_tooltip = true) ? setJSON.checklistTooltip.tooltip.true : setJSON.checklistTooltip.tooltip.false

    ;// getTimeline() - Always Check UIA
    settingsGUI.AddCheckbox("valwaysCheckUIA Checked" UserSettings.Always_Check_UIA " Y+5", setJSON.alwaysCheckUIA.title).OnEvent("Click", toggle.Bind("Always Check UIA", "", ""))
    settingsGUI["alwaysCheckUIA"].ToolTip := (UserSettings.Always_Check_UIA = true) ? setJSON.alwaysCheckUIA.tooltip.true : setJSON.alwaysCheckUIA.tooltip.false

    ;// Set_UIA_LimitDaily
    settingsGUI.AddCheckbox("vsetUIA_LimitDaily Checked" (UserSettings.Set_UIA_Limit_Daily != "disabled" ? UserSettings.Set_UIA_Limit_Daily : "0 +Disabled") " Y+5 xs+10", setJSON.setUIA_LimitDaily.title).OnEvent("Click", toggle.Bind("Set UIA Limit Daily", "", ""))
    settingsGUI["setUIA_LimitDaily"].ToolTip := (UserSettings.Set_UIA_Limit_Daily = true) ? setJSON.setUIA_LimitDaily.tooltip.true : setJSON.setUIA_LimitDaily.tooltip.false
    (settingsGUI["alwaysCheckUIA"].Value = 0) ? settingsGUI["setUIA_LimitDaily"].Opt("+Disabled") : settingsGUI["setUIA_LimitDaily"].Opt("-Disabled")

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
        script.ToolTip := (script.Value = 1) ? setJSON.%script.name%.tooltip.true : setJSON.%script.name%.tooltip.false
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
        settingsGUI.Add("Edit", set_Edit_Val.EditPos[A_Index] " r1 W50 -E0200 Number v" set_Edit_Val.control[A_Index])
        settingsGUI.Add("UpDown", set_Edit_Val.UpDownOpt[A_Index], initVal)
        switch set_Edit_Val.control[A_Index] {
            case "premPrev":
                (UserSettings.use_swapSequences = false || UserSettings.use_swapSequences = "false") ? settingsGUI[set_Edit_Val.control[A_Index]].Opt("+Disabled")
                                                                                                     : settingsGUI[set_Edit_Val.control[A_Index]].Opt("-Disabled")
        }
        settingsGUI.Add("Text", set_Edit_Val.textPos[A_Index] " v" set_Edit_Val.textControl[A_Index], set_Edit_Val.scriptText[A_Index])
        settingsGUI[set_Edit_Val.textControl[A_Index]].SetFont(set_Edit_Val.colour[A_Index])
        settingsGUI.Add("Text", set_Edit_Val.otherTextPos[A_Index], set_Edit_Val.otherText[A_Index])
        settingsGUI[set_Edit_Val.control[A_Index]].OnEvent("Change", editCtrl.Bind(set_Edit_Val.Bind[A_Index], set_Edit_Val.iniInput[A_Index], set_Edit_Val.objName[A_Index]))
    }

    editCtrl(script, ini, objName, ctrl, *)
    {
        iniVar := StrReplace(ini, A_Space, "_")
        UserSettings.%iniVar% := ctrl.text
        switch ini {
            case "premPrevSeqDelay":
                if winExt.ExistRegex("Core Functionality.ahk",,,, true) {
                    try {
                        activeObj := CLSID_Objs.load("prem")
                        activeObj.prevSeqDelay := (ctrl.text*1000)
                        activeObj.resetSeqTimer := true
                        activeObj := ""
                    } catch {
                        activeObj := ""
                        notifyIfNotExist("settingsGUIswapSeq", "settingsGUI()", "Could not disable ``prem.swapSequences()``. A reload may be required", ptf.Icons "\myscript.ico", "Windows Pop-up Blocked",, "POS=BR DUR=5 SHOW=Fade@250 bdr=0xF59F10 maxW=400 Hide=Fade@250")
                    }
                }
                return
        }
        if winExt.ExistRegex(script " - AutoHotkey",,,, true) && script != "" {
            WM.Send_WM_COPYDATA(iniVar "," ctrl.text "," objName, script)
        }
    }

    ;----------------------------------------------------------------------------------------------------------------------------------
    ;//! STATUS BAR

    workDir := FileRead(A_AppData "\tomshi\installDir")
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
    exitText := settingsGUI.Add("Text", "Section W150 H20 Xs Y+15", "💾 Save && Exit")
    exitText.SetFont("S13 Bold")
    settingsGUI.AddButton("w100 h30 Y+5", "Hard Reset").OnEvent("Click", close.bind("hard"))
    settingsGUI.AddButton("w100 h30 X+15", "Reload").OnEvent("Click", close.bind("reload"))
    settingsGUI.AddButton("w100 h30 Y+5", "Close").OnEvent("Click", close)

    settingsGUI.OnEvent("Escape", close)
    settingsGUI.OnEvent("Close", close)
    close(butt?, *)
    {
        SetTimer(statecheck, 0)
        SetTimer(iniWait, 0)
        ;a check incase this settings gui was launched from firstCheck()
        if WinExist("Scripts Release " version)
            WinSetAlwaysOnTop(1, "Scripts Release " version)
        ToolTip("")
        UserSettings.__delAll() ;// close the settings instance
        sleep 50
        newSettings := FileRead(UserSettings.SettingsFile)
        UserSettings := ""
        if newSettings != initialSettings
            notifyIfNotExist("settingsGUI", "settingsGUI()", "Settings changes are being saved`nGUI cannot be reopened until this window disappears...", ptf.Icons "\myscript.ico", "Windows Pop-up Blocked",, "POS=BR DUR=2 SHOW=Fade@250 bdr=0xF59F10 maxW=400 Hide=Fade@250")
        if IsSet(butt) {
            switch butt {
                case "hard":
                    settingsGUI.Destroy()
                    reset.reset()
                    return ;// this is necessary
                case "reload":
                    settingsGUI.Destroy()
                    if Notify.Exist('settingsGUI') {
                        loop 80 {
                            if !Notify.Exist('settingsGUI')
                                break
                            sleep 25
                        }
                    }
                    reset.ext_reload()
                    return ;// this is necessary
            }
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

    /** This function is called to generate the Thio MButton Script Settings */
    menu_Thio(*) {
        thioGUITitle := "Thio MButton Script Settings"
        if WinExist(thioGUITitle) {
            WinActivate(thioGUITitle)
            return
        }
        thioGUI := tomshiBasic(,, "AlwaysOnTop +MinSize275x Owner", thioGUITitle)
        ;// Use_Thio_MButton
        thioGUI.AddCheckbox("vUse_Thio_MButton Checked" UserSettings.Use_Thio_MButton " Y+5", setJSON.Use_Thio_MButton.title).OnEvent("Click", toggle.Bind("Use Thio MButton", "", thioGUI))
        thioGUI["Use_Thio_MButton"].ToolTip := (UserSettings.Use_Thio_MButton = true) ? setJSON.Use_Thio_MButton.tooltip.true : setJSON.Use_Thio_MButton.tooltip.false

        ;// Use_MButton
        thioGUI.AddCheckbox("vUse_MButton Checked" UserSettings.Use_MButton " Y+5", setJSON.Use_MButton.title).OnEvent("Click", toggle.Bind("Use MButton", "", thioGUI))
        thioGUI["Use_MButton"].ToolTip := (UserSettings.Use_MButton = true) ? setJSON.Use_MButton.tooltip.true : setJSON.Use_MButton.tooltip.false
        thioGUI['Use_MButton'].Opt(((UserSettings.Use_Thio_MButton = false) ? "Disabled" : ""))

        thioGUI.AddText(, "Change activation hotkey: ")
        thioGUI.AddEdit("vthioHotkey x+10 y+-20 w150", UserSettings.alternate_MButton_Key).OnEvent('Change', (guiObj, *) => (UserSettings.alternate_MButton_Key := guiObj.value))
        if thioGUI["Use_MButton"].value = true
            thioGUI["thioHotkey"].Opt("Disabled")

        thioGUI.AddButton("xp+98 y+10", "Close").OnEvent('Click', (*) => (WinClose(thioGUITitle)))


        thioGUI.Show()
        settingsGUI.Opt("Disabled")
        ;// settingsgui
        WinGetPos(&x, &y,,, "Settings " version)
        thioGUI.GetPos(,, &width)
        thioGUI.Move(x-width+5, y)
        WinWaitClose(thioGUITitle)
        settingsGUI.Opt("-Disabled")
    }

    /** This function is called to generate either the Premiere Pro or After Effects settings gui */
    menu_Adobe(program, *) {
        ;// setting values depending on which program settings the user wishes to change
        switch program {
            case "Premiere":
                short := "prem"
                static premIsBeta := unset
                shortcutName := "Adobe Premiere Pro.exe"
                shortcutNameBeta := editors.__determinePremName() " (Beta).exe"
                adobeFullName := editors.__determinePremName()
                title := program " Pro Settings"
                yearIniName := "prem_year"
                iniInitYear := UserSettings.prem_year
                verIniName := "premVer"
                initVer := UserSettings.premVer
                genProg := program
                otherTitle := "After Effects Settings"
                static imageLoc := ptf.premSETver
                path := A_ProgramFiles "\Adobe\" adobeFullName A_Space iniInitYear "\" shortcutName
            case "AE":
                short := "ae"
                static aeIsBeta := unset
                shortcutName := "AfterFX.exe"
                shortcutNameBeta := "AfterFX (Beta).exe"
                adobeFullName := "Adobe After Effects"
                title := "After Effects Settings"
                yearIniName := "ae_year"
                iniInitYear := UserSettings.ae_year
                verIniName := "aeVer"
                initVer := UserSettings.aeVer
                genProg := "AE"
                otherTitle := "Premiere Pro Settings"
                static imageLoc := ptf.aeSETver
                path := A_ProgramFiles "\Adobe\" adobeFullName A_Space iniInitYear "\Support Files\" shortcutName
            case "Photoshop":
                short := "ps"
                static psIsBeta := unset
                shortcutName := "Photoshop.exe"
                shortcutNameBeta := "ahk_exe Photoshop.exe (Beta).exe"
                adobeFullName := "Adobe Photoshop"
                title := program " Settings"
                yearIniName := "ps_year"
                iniInitYear := UserSettings.ps_year
                verIniName := "psVer"
                initVer := UserSettings.psVer
                genProg := program
                otherTitle := "Photoshop Settings"
                static imageLoc := ptf.psSETver
                path := A_ProgramFiles "\Adobe\" adobeFullName A_Space iniInitYear "\" shortcutName
        }
        if WinExist(title) {
            WinActivate(title)
            return
        }
        adobeGui := tomshiBasic(,, "+MinSize275x AlwaysOnTop Owner", title)
        ctrlX := 120

        ;// start defining the gui
        adobeGui.AddText("Section", "Year: ")
        __generateDropYear(genProg, &year, ctrlX)
        adobeGui.AddText("xs y+10", "Version: ")
        __generateDropVer(genProg, &ver, ctrlX)
        adobeGui.AddCheckbox("x+10 y+-20 vIsBeta Checked" (%short%IsBeta ?? UserSettings.__convertToBool(short "IsBeta", "Adjust")), "Is Beta Version?").OnEvent("Click", (guiCtrl, *) => (%short%IsBeta := guiCtrl.value, UserSettings.%short%IsBeta := UserSettings.__convertToStr(guiCtrl.value), __generateShortcut()))
        if program != "Photoshop" {
            adobeGui.AddText("xs y+12 Section", "Cache Dir: ")
            cacheInit := short "cache"
            cache := adobeGui.Add("Edit", "x" ctrlX " ys-3 r1 W150 ReadOnly", UserSettings.%cacheInit%)
            cacheSelect := adobeGui.Add("Button", "vcacheBut x+5 w60 h27", "select")
            cacheSelect.OnEvent("Click", __cacheslct.Bind(adobeFullName))
            adobeGui["cacheBut"].GetPos(&cacheButX)
        }
        if program = "Premiere" {
            ;// themes
            defaults := Map("Light", "1", "Dark", "2", "Darkest", "3")
            adobeGui.AddText("xs", "Theme Default: ")
            adobeGui.AddDropDownList("x" ctrlX " y+-20 w100 Choose" defaults.Get(UserSettings.premDefaultTheme) " vthemeDefaultPrem", ["Light", "Dark", "Darkest"])
            adobeGui['themeDefaultPrem'].OnEvent("change", (ctrl, *) => UserSettings.premDefaultTheme := ctrl.Text)

            ;// swapSequences()
            adobeGui.AddCheckbox("vuseSwapSequences Checked" UserSettings.use_swapSequences " xs Y+15", setJSON.useSwapSequences.title).OnEvent("Click", toggle.Bind("Use swapSequences", "", ""))
            adobeGui["useSwapSequences"].ToolTip := (UserSettings.use_swapSequences = true) ? setJSON.useSwapSequences.tooltip.true : setJSON.useSwapSequences.tooltip.false
        }

        ;// warning & save button
        adobeGui["IsBeta"].GetPos(&isBetaX)
        closeX := IsSet(cacheButX) ? cacheButX : isBetaX
        saveBut := adobeGui.Add("Button", "x" closeX, "close")
        adobeGui.AddText("x" closeX-175 " y+-30 Right BackgroundTrans", "*some settings will require`na full reload to take effect").SetFont("s9 italic")
        saveBut.OnEvent("Click", __saveVer)

        ;// show
        adobeGui.Show()
        settingsGUI.Opt("Disabled")
        ;// settingsgui
        WinGetPos(&x, &y,,, "Settings " version)
        if WinExist(otherTitle) {
            WinGetPos(,,, &yearHeight, otherTitle)
        }
        adobeGui.GetPos(,, &width)
        adobeGui.Move(x-width+5, y)
        WinWaitClose(title)
        settingsGUI.Opt("-Disabled")

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
            jsonFolder := ptf.SupportFiles "\Release Assets\Adobe SymVers\Vers\" short
            if !DirExist(jsonFolder "\") {
                ;// throw
                errorLog(ValueError("Adobe json directory cannot be found", -1, jsonFolder),,, 1)
            }
            supportedVersMap := json.parse(FileRead(jsonFolder "\v" SubStr(year.Text, 3, 2) ".json"))
            supportedVers := []
            for v in supportedVersMap
                supportedVers.Push(v)
            ver.add(supportedVers)
            if !supportedVers.Has(1)
                return
            ver.Choose(supportedVers.Length)
            UserSettings.%yearIniName% := year.text
            title := "createShortcuts.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
            ignore := browser.vscode.winTitle
            if winExt.ExistRegex(title,, ignore,, true)
                winExt.WaitCloseRegex(title,,, ignore,, true)
            Run(ptf.Shortcuts "\createShortcuts.ahk false")
            __editAdobeVer(verIniName, ver) ;// call the func to reassign the settings values
        }

        __generateShortcut() => generateAdobeShortcut(UserSettings, adobeFullName, year.text)

        /**
         * This function generates the year dropdown selector
         */
        __generateDropYear(program, &year, ctrlX) {
            if (program != "AE" && program != "Premiere" && program != "Photoshop") {
                ;// throw
                errorLog(ValueError("Incorrect value in Parameter #1", -1, program),,, 1)
            }
            jsonFolder := ptf.SupportFiles "\Release Assets\Adobe SymVers\Vers\" short
            if !DirExist(jsonFolder "\") {
                ;// throw
                errorLog(ValueError("Adobe json directory cannot be found", -1, jsonFolder),,, 1)
            }
            supportedYears := []
            loop files jsonFolder "\*", "F" {
                loopYear := SubStr(A_Year, 1, 2) SubStr(A_LoopFileName, 2, 2)
                supportedYears.Push(loopYear)
            }
            for value in supportedYears {
                if value = iniInitYear
                    {
                        defaultIndex := A_Index
                        break
                    }
            }
            supportedYears := supportedYears.Sort("C")
            supportedYears := supportedYears.Reverse()
            try defaultIndex := supportedYears.IndexOf(iniInitYear)
            if !IsSet(defaultIndex)
                defaultIndex := 1
            year := adobeGui.AddDropDownList("x" ctrlX " y+-20 w100 Choose" defaultIndex, supportedYears)
            year.OnEvent("Change", __yearEventDropDown)
        }

        /**
         * This function generates the version dropdown selector
         */
        __generateDropVer(program, &ver, ctrlX) {
            if (program != "AE" && program != "Premiere" && program != "Photoshop") {
                ;// throw
                errorLog(ValueError("Incorrect value in Parameter #1", -1, program),,, 1)
            }
            jsonFolder := ptf.SupportFiles "\Release Assets\Adobe SymVers\Vers\" short
            if !DirExist(jsonFolder "\") {
                ;// throw
                errorLog(ValueError("Adobe json directory cannot be found", -1, jsonFolder),,, 1)
            }
            supportedVersMap := JSON.parse(FileRead(jsonFolder "\v" SubStr(iniInitYear, 3, 2) ".json"))
            supportedVers := []
            for v in supportedVersMap
                supportedVers.Push(v)
            for value in supportedVers {
                if value = initVer
                    {
                        defaultIndex := A_Index
                        break
                    }
            }
            supportedVers := supportedVers.Sort("C")
            supportedVers := supportedVers.Reverse()
            try defaultIndex := supportedVers.IndexOf(initVer)
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