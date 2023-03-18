; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\Dark>
#Include <Classes\winGet>
#Include <Classes\tool>
#Include <Classes\ptf>
#Include <GUIs\tomshiBasic>
#Include <Functions\getScriptRelease>
#Include <Functions\refreshWin>
; }

;// initialise settings instance
UserSettings := UserPref()
checklist_tooltip := UserSettings.checklist_tooltip
dark_mode := UserSettings.dark_mode
settingsFile := UserSettings.SettingsFile
scriptVersion := UserSettings.version
UserSettings := "" ;// closing settings instance

;define menu
;file menus
FileMenu := Menu()
newSub := Menu()
FileMenu.Add("&New", newSub)
newSub.Add("&New Project`tCtrl+N", fileNewandOpen)
newSub.Add("&Add Checkbox`tCtrl+A", addNew)
openSub := Menu()
FileMenu.Add("&Open", openSub)
openSub.Add("&Project`tCtrl+O", fileNewandOpen)
openSub.Add("&Current Project Folder`tCtrl+P", openProj)
openSub.Add("&Logs`tCtrl+L", openLog)
openSub.Add("&ini`tCtrl+I", openini)

FileMenu.Add("E&xit", close)
;settings menu
SettingsMenu := Menu()
SettingsMenu.Add("&Tooltips", menuTooltips.bind(&settingsToolTrack))
SettingsMenu.Add("&Dark Mode", goDark.bind(&darkToolTrack))
settingsToolTrack := 0
if IniRead(checklist, "Info", "tooltip") = "1"
    {
        SettingsMenu.Check("&Tooltips")
        if checklist_tooltip != 0
            settingsToolTrack := 1
        else
            settingsToolTrack := 0
    }
if checklist_tooltip = 0
    SettingsMenu.Disable("&Tooltips")
else
    SettingsMenu.Enable("&Tooltips")

darkToolTrack := 0
if IniRead(checklist, "Info", "dark") = "1"
{
    SettingsMenu.Check("&Dark Mode")
    if dark_mode != false
        darkToolTrack := 1
    else
        darkToolTrack := 0
}
if dark_mode = false
    SettingsMenu.Disable("&Dark Mode")
else
    SettingsMenu.Enable("&Dark Mode")

;help menu
HelpMenu := Menu()
HelpMenu.Add("&About", aboutBox)
updateSub := Menu()
HelpMenu.Add("&Check for Update", updateSub)
updateSub.Add("&Stable", updateCheck)
updateSub.Add("&Beta", updateCheck)
HelpMenu.Add("&Github", github)
HelpMenu.Add("&Hours Worked", hours)
;define the entire menubar
bar := MenuBar()
bar.Add("&File", FileMenu)
bar.Add("&Settings", SettingsMenu)
bar.Add("&Help", HelpMenu)



/**
 * A function for the menubar to work correctly. Is called when the menuTooltips setting is pressed
 */
menuTooltips(&settingsToolTrack, *)
{
    switch settingsToolTrack {
        case 1:
            settingsToolTrack := 0
            SettingsMenu.UnCheck("&Tooltips")
            IniWrite("0", checklist, "Info", "tooltip")
            restart()
        case 0:
            settingsToolTrack := 1
            SettingsMenu.Check("&Tooltips")
            IniWrite("1", checklist, "Info", "tooltip")
            restart()
    }

    restart()
    {
        forFile := Round(timer.Count / 3600, 3)
        IniWrite(timer.Count, checklist, "Info", "time")
        newDate(&today)
        FileAppend("\\ The checklist tooltip setting was changed : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after closing = " forFile " -- seconds at close = " timer.Count "`n", logs)
        timer.stop()
        timer.reminder.stop()
        MsgBox("checklist.ahk will need to be reloaded for changes to this setting to take effect", "Warning")
    }
}


/**
 * The function that is called when either the new or open menu options are pressed
 */
fileNewandOpen(*) => Reload()

/**
 * This function is for when the about menu option is pressed. It handles creating a new gui window to show some information about checklist.ahk. It also auto centers itself within the checklist.ahk gui
 */
aboutBox(*)
{
    checklistGUI.GetPos(&x, &y, &width, &height)
    aboutGUI := tomshiBasic(12, 400, "AlwaysOnTop +MinSize200x200", "About ©")
    aboutGUI.Opt("+Owner" checklistGUI.Hwnd)
    checklistGUI.Opt("+Disabled")

    aboutGUI.Add("Text", "W200 Center", "Tomshi's Checklist`r&&`rEditing Tracker Script")
    verstionText := aboutGUI.Add("Text", "Center W200", "⚙ " version "`n© Tomshi " A_Year)
    verstionText.SetFont("S10")

    aboutGUI.OnEvent("Close", aboutClose)
    aboutGUI.Show("AutoSize")
    aboutGUI.GetPos(,, &aboutwidth, &aboutheight)
    aboutGUI.Move(x - (aboutwidth/2) + (width/2), y - (aboutheight/2) + (height/2))

    if darkToolTrack = 1
        dark.titleBar(aboutGUI.Hwnd)
    else
        dark.titleBar(aboutGUI.Hwnd, false)

    aboutClose(*)
    {
        checklistGUI.Opt("-Disabled")
        aboutGUI.Destroy
    }
}


/**
 * The function that is called when the github menu option is pressed
 */
github(*)
{
    if !WinExist("Tomshiii/ahk")
        Run("https://github.com/Tomshiii/ahk/tree/dev")
    else
        WinActivate("Tomshiii/ahk")
}


/**
 * The function that is called when either of the update check menu options are pressed. It will what the latest version of checklist.ahk is on github and crossreference that with your local version
 * @param {guiObj} Item is the menu object name that we pass into the function so we can save code and know which option the user pressed
 */
updateCheck(Item, *)
{
    tree := ""
    if Item = "&Stable"
        tree := "main"
    if Item = "&Beta"
        tree := "dev"
    if !FileExist(settingsFile)
        {
            string := getHTML("https://raw.githubusercontent.com/Tomshiii/ahk/" tree "/checklist.ahk")
            if string = 0
                return
            startPos := InStr(string, "version := ", 1, 1, 1)
            endpos := InStr(string, '"',, startPos, 2)
            latestVer := SubStr(string, startpos + 12, endpos - (startPos + 12))
            if VerCompare(latestVer, version) > 0
                {
                    tool.Cust("There's a more up to date version!`nCurrent Version: " version "`nLatest Version: " latestVer, 5.0)
                    if WinExist("Tomshiii/ahk at " tree)
                        WinActive("Tomshiii/ahk at " tree)
                    else
                        {
                            Run("https://github.com/Tomshiii/ahk/tree/" tree)
                            WinWait("Tomshiii/ahk at " tree)
                            WinActivate("Tomshiii/ahk at " tree)
                        }
                }
            else if VerCompare(version, latestVer) > 0
                tool.Cust("You are on a more up to date version!")
            else
                tool.Cust("You are up to date!")
            return
        }
    if tree = "main"
        latestVer := getScriptRelease()
    if tree = "dev"
        latestVer := getScriptRelease(true)
    if latestVer = 0
        {
            tool.Cust("You are up to date!") ;if getScriptRelease fails, default to being up to date
            return
        }
    if VerCompare(latestVer, scriptVersion) > 0
        {
            Run("https://github.com/Tomshiii/ahk/releases")
            tool.Cust("There's a more up to date version!`nCurrent Release: " scriptVersion "`nLatest Release: " latestVer, 5.0)
        }
    if VerCompare(latestVer, scriptVersion) < 0
        tool.Cust("It appears you've travelled through time and put yourself on a newer version...`nor you're just on a beta release and comparing to main", 5.0)
    if VerCompare(latestVer, scriptVersion) = 0 && tree = "dev"
        { ;if the user is on the latest pre release but checks for an update on the beta channel
            try { ;we then compare the local ver of checklist.ahk to the local ver on github
                main := ComObject("WinHttp.WinHttpRequest.5.1")
                main.Open("GET", "https://raw.githubusercontent.com/Tomshiii/ahk/dev/checklist.ahk")
                main.Send()
                main.WaitForResponse()
                string := main.ResponseText
            }  catch as e {
                tool.Cust("You are up to date!") ;if the file can't be read, just fall back to this alert
                return
            }
            if !IsSet(string)
                return
            startPos := InStr(string, "version := ", 1, 1, 1)
            endpos := InStr(string, '"',, startPos, 2)
            latestLocalVer := SubStr(string, startpos + 12, endpos - (startPos + 12))
            if VerCompare(latestLocalVer, version) > 0
                {
                    if WinExist("Tomshiii/ahk at " tree)
                        WinActive("Tomshiii/ahk at " tree)
                    else
                        Run("https://github.com/Tomshiii/ahk/tree/" tree)
                    tool.Cust("You're on the latest release, but there are newer files relating to ``checklist.ahk`` available", 5.0)
                    return
                }
            else
                tool.Cust("You are up to date!")
        }
    if VerCompare(latestVer, scriptVersion) = 0
        tool.Cust("You are up to date!")
}


/**
 * This function is called when the Hours Worked menu option is pressed. It handles doing some math to find the amount of hours worked in the current day/the amount of days worked on the current project/the average hours worked per day on the current project. It does this by looping through the checklist_logs.txt file for certain things.
 *
 * It then handles generating a new gui to display this information. This newly generated gui is centered in the middle of the main checklist.ahk gui
 */
hours(*)
{
    readLog := FileRead(logs)
    findToday := InStr(readLog, A_YYYY "_" A_MM "_" A_DD,, 1, 1)
    findHours := InStr(readLog,  "Hours after opening =", 1, findToday, 1)
    endpos := InStr(readLog, "-",, findHours, 1)
    startHours := SubStr(readLog, findHours + 22, (endpos - 1) - (findHours + 22))

    currentHours := floorDecimal(timer.Count / 3600, 3)
    workedToday := floorDecimal(currentHours - startHours, 3)
    if workedToday <= 0
        workedToday := 0

    increment := 0
    StartVal := 0
    ;;
    loop {
        if !InStr(readLog, "{",,, A_Index)
            break
        startPos := InStr(readLog, "{",,, A_Index)
        finddash := InStr(readLog, "-",, startPos, 1)
        dateStart := SubStr(readLog, startPos + 2, (finddash-1)-(startPos+2))
        FindhoursEnd := InStr(readLog, "\",, finddash, 1)
        StartHours := SubStr(readLog, finddash + 2, (FindhoursEnd-1)-(finddash+2))
        LastDate := InStr(readLog, dateStart,,, -1)
        findEquals := InStr(readLog, "=",, LastDate, 1)
        lastHourEnd := InStr(readLog, "-",, findEquals, 1)
        lastHour := SubStr(readLog, findEquals + 2, (lastHourEnd-1)-(findEquals+2))

        if lastHour <= startHours
            goto ignore
        HoursWorkedForDate := lastHour-StartHours
        StartVal += HoursWorkedForDate
        increment += 1
        ignore:
    }
    if StartVal <= 0 || increment <= 0
        avg := "Not enough data"
    else
        avg := floorDecimal(StartVal/increment,3)

    checklistGUI.GetPos(&x, &y, &width, &height)
    hoursGUI := tomshiBasic(, 400, "AlwaysOnTop +MinSize200x200", "Hours Worked")
    hoursGUI.Opt("+Owner" checklistGUI.Hwnd)
    checklistGUI.Opt("+Disabled")

    hoursGUI.Add("Text", "W200 Center", "Hours worked today: " workedToday "`nDays worked: " increment "`nAvg Hours per day: " avg)

    hoursGUI.OnEvent("Close", hoursClose)
    hoursGUI.Show("AutoSize")
    hoursGUI.GetPos(,, &hourswidth, &hoursheight)
    hoursGUI.Move(x - (hourswidth/2) + (width/2), y - (hoursheight/2) + (height/2))

    if darkToolTrack = 1
        dark.titleBar(hoursGUI.Hwnd)

    hoursClose(*)
    {
        checklistGUI.Opt("-Disabled")
        hoursGUI.Destroy
    }
}

/**
 * This function is called when the darkmode toggle menu option is pressed and handles keeping track of what option the user wants. It then calls `which()` to actually make the switch
 */
goDark(&darkToolTrack, *)
{
    switch darkToolTrack {
        case 1:
            darkToolTrack := 0
            SettingsMenu.UnCheck("&Dark Mode")
            IniWrite("0", checklist, "Info", "dark")
            which(false, "Light", 0)
        case 0:
            darkToolTrack := 1
            SettingsMenu.Check("&Dark Mode")
            IniWrite("1", checklist, "Info", "dark")
            which()
    }
}

/**
 * This function is called by `goDark()` and handles toggling dark mode for checklist.ahk
 * @param {boolean} darkmode is a toggle that allows us to do the inverse and swap back to light mode. Pass false to do so
 * @param {string} DarkorLight is another toggle that allows us to do the inverse and swap back to light mode. Pass `"Light"` to do so
 * @param {boolean} menu defines whether to turn the menu bar darkmode
 */
which(darkmode := true, DarkorLight := "Dark", menu := 1)
{
    dark.menu(menu)
    dark.titleBar(checklistGUI.Hwnd, darkmode)
    dark.allbuttons(checklistGUI, DarkorLight, {default: true, DarkBG: false})
}

/**
 * This function is called when the Open Logs menu option is selected
 */
openLog(*)
{
    if !FileExist(logs)
        {
            tool.Cust("the log file", 2000, 1)
            return
        }
    if WinExist("checklist_logs.txt")
        refreshWin("checklist_logs.txt", logs)
    else
        Run(logs)
}

/**
 * This function is called when the Open Project Folder menu option is selected
 */
openProj(*)
{
    SplitPath(checklist,, &projDir)
    if !WinExist(editors.Premiere.winTitle) && !WinExist(Editors.AE.winTitle)
        {
            tool.Cust("Adobe project not open")
            return
        }
    if WinExist(editors.Premiere.winTitle)
        WinGet.PremName(&premCheck, &titleCheck, &saveCheck)
    else if WinExist(Editors.AE.winTitle)
        {
            WinGet.AEName(&aeCheck,, &aeSaveCheck)
            premCheck := aeCheck
        }
    if WinExist(projDir,, premCheck)
        WinActivate(projDir,, premCheck)
    else
        {
            Run("explore " projDir)
            if WinWait(projDir,, 2, premCheck)
                WinActivate(projDir,, premCheck)
        }
}

openini(*) {
    checklistGUI.GetPos(&x, &y, &width, &height)
    if WinExist("checklist.ini") ;if ini already open, get pos, close, and then reopen to refresh
        refreshWin("checklist.ini", checklist)
    else
        Run("Notepad.exe " checklist)
    WinWait("checklist.ini")
    WinMove(x-322, y, 322, height-2, "checklist.ini")
}

addNew(*)
{
    checklistGUI.GetPos(&x, &y, &width, &height)
    addGUI := tomshiBasic(, 400, "AlwaysOnTop +MinSize200x200", "Add Checkbox")
    addGUI.Opt("+Owner" checklistGUI.Hwnd)
    checklistGUI.Opt("+Disabled")

    addGUI.Add("Text", "Section W150", "Add New Checkbox:")
    addcheck := addGUI.Add("Edit", "r1 W150 xs y+10 Limit15")
    submitbut := addGUI.Add("Button", "Default", "add")
    submitbut.OnEvent("Click", addcheckbox)
    addGUI.AddButton("x+10", "cancel").OnEvent("Click", addClose)

    addGUI.OnEvent("Close", addClose)
    addGUI.Show("AutoSize")
    addGUI.GetPos(,, &addwidth, &addheight)
    addGUI.Move(x - (addwidth/2) + (width/2), y - (addheight/2) + (height/2))

    if darkToolTrack = 1
        dark.titleBar(addGUI.Hwnd)

    addcheckbox(*)
    {
        readini := IniRead(checklist, "Checkboxes")
        if InStr(readini, addcheck.value)
            {
                MsgBox("Checkbox already exists!")
                return
            }
        IniWrite("0", checklist, "Checkboxes", addcheck.Value)
        Run(ptf.Checklist "\destroy&open.ahk")
    }

    addClose(*)
    {
        checklistGUI.Opt("-Disabled")
        addGUI.Destroy
    }
}