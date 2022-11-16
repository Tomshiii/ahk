#Include <\Functions\General>

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

#Include <\settingsGUI\gameCheckGUI>
#Include <\settingsGUI\editValues>
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
    premInitYear := IniRead(ptf.files["settings"], "Adjust", "prem year")
    AEInitYear := IniRead(ptf.files["settings"], "Adjust", "ae year")
    ;this loop auto generates the edit boxes using "..\settingsGUI\maps.ahk"
    loop set_Edit_Val.Length {
        if A_Index < set_Edit_Val.Length - 2
            {
                initVal := IniRead(ptf.files["settings"], "Adjust", set_Edit_Val.iniInput[A_Index])
                settingsGUI.Add("Edit", set_Edit_Val.EditPos[A_Index] " r1 W50 Number v" set_Edit_Val.control[A_Index])
                settingsGUI.Add("UpDown",, initVal)
                settingsGUI.Add("Text", set_Edit_Val.textPos[A_Index] " v" set_Edit_Val.textControl[A_Index], set_Edit_Val.scriptText[A_Index])
                settingsGUI[set_Edit_Val.textControl[A_Index]].SetFont(set_Edit_Val.colour[A_Index])
                settingsGUI.Add("Text", set_Edit_Val.otherTextPos[A_Index], set_Edit_Val.otherText[A_Index])
                settingsGUI[set_Edit_Val.control[A_Index]].OnEvent("Change", editCtrl.Bind(set_Edit_Val.Bind[A_Index], set_Edit_Val.iniInput[A_Index]))
            }
        if A_Index > set_Edit_Val.Length - 2
            {
                initVal := IniRead(ptf.files["settings"], "Adjust", set_Edit_Val.iniInput[A_Index])
                settingsGUI.Add("Edit", set_Edit_Val.EditPos[A_Index] " r1 W50 Number Limit4 v" set_Edit_Val.control[A_Index], initVal)
                settingsGUI.Add("Text", set_Edit_Val.textPos[A_Index] " v" set_Edit_Val.textControl[A_Index], set_Edit_Val.scriptText[A_Index])
                settingsGUI[set_Edit_Val.textControl[A_Index]].SetFont(set_Edit_Val.colour[A_Index])
                settingsGUI[set_Edit_Val.control[A_Index]].OnEvent("Change", editCtrl.Bind(set_Edit_Val.Bind[A_Index], set_Edit_Val.iniInput[A_Index]))
            }
    }

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
        if WinExist("Settings " version)
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
        dirName := SplitPathObj(workDir)
        if WinExist("ahk_exe explorer.exe " dirName.NameNoExt)
            WinActivate("ahk_exe explorer.exe " dirName.NameNoExt)
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
        if settingsGUI[set_Edit_Val.control[set_Edit_Val.num[6]]].Value != premInitYear || settingsGUI[set_Edit_Val.control[set_Edit_Val.num[7]]].Value != AEInitYear
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
                script := SplitPathObj(scriptPath) ;and splitting it out into just the .ahk filename
                MsgBox("The requested music folder doesn't exist`n`nWritten dir: " ptf.musicDir "`nScript: " script.Name "`nLine: " A_LineNumber-11)
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
    
    scripts := ["myscript", "error", "dismiss", "save", "fullscreen", "game", "M-I_C", "keyboard", "resolve"]
    names := Map(
        scripts[1],      "My Scripts.ahk",
        scripts[2],      "Alt_menu_acceleration_DISABLER.ahk",
        scripts[3],      "autodismiss error.ahk",
        scripts[4],      "autosave.ahk",
        scripts[5],      "adobe fullscreen check.ahk",
        scripts[6],      "gameCheck.ahk",
        scripts[7],      "Multi-Instance Close.ahk",
        scripts[8],      "QMK Keyboard.ahk",
        scripts[9],      "Resolve_Example.ahk",
    )
    tooltiptext := Map(
        scripts[1],      "Clicking this checkbox will toggle suspend the script",
        scripts[2],      "Clicking this checkbox will open/close the script",
    )

    createCheck()
    {
        loop scripts.Length {
            if A_Index = 1
                {
                    MyGui.Add("CheckBox", "Section Checked0 v" scripts[A_Index], names[scripts[A_Index]])
                    MyGui[scripts[1]].OnEvent("Click", myClick)
                    MyGui[scripts[1]].ToolTip := tooltiptext[scripts[1]]
                }
            else
                {
                    MyGui.Add("CheckBox", "xs Checked0 v" scripts[A_Index], names[scripts[A_Index]])
                    MyGui[scripts[A_Index]].OnEvent("Click", scriptClick)
                    MyGui[scripts[A_Index]].ToolTip := tooltiptext[scripts[2]]
                }
        }
        loop scripts.Length {
            if A_Index = 1
                MyGui.Add("Picture", "w20 h-1 X275 Ys", ptf.Icons "\" scripts[A_Index] ".png")
            else
                {
                    switch scripts[A_Index] {
                        case "game":
                            type := ".png"
                        case "dismiss" :
                            y := "+2"
                        case "M-I_C" :
                            type := ".png"
                        case "resolve":
                            type := ".png"
                            y := "+2"
                        default:
                            type := ".ico"
                            y := "+5"
                    }
                    MyGui.Add("Picture", "w20 h-1 Y" y, ptf.Icons "\" scripts[A_Index] type)
                }
        }
    }
    createCheck()

    SetTimer(checkScripts, -100)

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
            Run(ptf.rootDir "\" script.text)
        else
            Run(ptf.rootDir "\Timer Scripts\" script.text)
    }

    checkScripts(*)
    {
        detect()
        if WinExist("My Scripts.ahk is Suspended")
            WinWaitClose("My Scripts.ahk is Suspended")

        MyGui[scripts[1]].Value := (A_IsSuspended = 0) ? 1 : 0
        loop scripts.Length - 1 {
            MyGui[scripts[A_Index + 1]].Value := WinExist(names[scripts[A_Index + 1]] " - AutoHotkey") ? 1 : 0
        }
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