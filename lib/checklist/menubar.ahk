;define menu
;file menus
FileMenu := Menu()
FileMenu.Add("&New`tCtrl+N", fileNewandOpen)
FileMenu.Add("&Open`tCtrl+O", fileNewandOpen)
FileMenu.Add("E&xit", close)
;settings menu
SettingsMenu := Menu()
SettingsMenu.Add("&Tooltips", menuTooltips)
SettingsMenu.Add("&Dark Mode", goDark)
settingsToolTrack := 0
if IniRead(checklist, "Info", "tooltip") = "1"
    {
        SettingsMenu.Check("&Tooltips")
        if globalCheckTool != 0
            global settingsToolTrack := 1
        else
            global settingsToolTrack := 0
    }
if globalCheckTool = 0
    SettingsMenu.Disable("&Tooltips")
else
    SettingsMenu.Enable("&Tooltips")

darkToolTrack := 0
if IniRead(checklist, "Info", "dark") = "1"
{
    SettingsMenu.Check("&Dark Mode")
    if globalDarkTool != 0
        global darkToolTrack := 1
    else
        global darkToolTrack := 0
}
if globalDarkTool = 0
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
HelpMenu.Add("&Open Logs", openLog)
;define the entire menubar
bar := MenuBar()
bar.Add("&File", FileMenu)
bar.Add("&Settings", SettingsMenu)
bar.Add("&Help", HelpMenu)

;define GUI
MyGui := Gui("AlwaysOnTop", "Editing Checklist - " name ".proj")
MyGui.BackColor := 0xF0F0F0
MyGui.SetFont("S12") ;Sets the size of the font
MyGui.SetFont("W500") ;Sets the weight of the font (thickness)
MyGui.Opt("+MinSize300x300")
MyGui.MenuBar := bar
noDefault := MyGui.Add("Button", "Default W0 H0", "_")




/**
 * A function for the menubar to work correctly. Is called when the menuTooltips setting is pressed
 */
menuTooltips(*)
{
    if settingsToolTrack = 1
        {
            global settingsToolTrack := 0
            SettingsMenu.UnCheck("&Tooltips")
            IniWrite("0", checklist, "Info", "tooltip")
            restart()
        }
    else if settingsToolTrack = 0
        {
            global settingsToolTrack := 1
            SettingsMenu.Check("&Tooltips")
            IniWrite("1", checklist, "Info", "tooltip")
            restart()
        }

    restart()
    {
        forFile := Round(ElapsedTime / 3600, 3)
        IniWrite(ElapsedTime, checklist, "Info", "time")
        newDate(&today)
        FileAppend("\\ The checklist tooltip setting was changed : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after closing = " forFile " -- seconds at close = " ElapsedTime "`n", logs)
        SetTimer(StopWatch, 0)
        SetTimer(reminder, 0)
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
    MyGui.GetPos(&x, &y, &width, &height)
    aboutGUI := Gui("AlwaysOnTop", "About ©")
    aboutGUI.Opt("+Owner" MyGui.Hwnd)
    aboutGUI.Opt("+MinSize200x200")
    aboutGUI.SetFont("S12")
    aboutGUI.SetFont("W400")
    aboutGUI.BackColor := 0xF0F0F0
    MyGui.Opt("+Disabled")

    aboutGUI.Add("Text", "W200 Center", "Tomshi's Checklist`r&&`rEditing Tracker Script")
    verstionText := aboutGUI.Add("Text", "Center W200", "⚙ " version "`n© Tomshi " A_Year)
    verstionText.SetFont("S10")

    aboutGUI.OnEvent("Close", aboutClose)
    aboutGUI.Show("AutoSize")
    aboutGUI.GetPos(,, &aboutwidth, &aboutheight)
    aboutGUI.Move(x - (aboutwidth/2) + (width/2), y - (aboutheight/2) + (height/2))

    aboutClose(*)
    {
        MyGui.Opt("-Disabled")
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
 * @param {any} Item is the menu object name that we pass into the function so we can save code and know which option the user pressed
 */
updateCheck(Item, *)
{
    tree := ""
    if Item = "&Stable"
        tree := "main"
    if Item = "&Beta"
        tree := "dev"
    if !FileExist(A_MyDocuments "\tomshi\settings.ini")
        {
            try {
                main := ComObject("WinHttp.WinHttpRequest.5.1")
                main.Open("GET", "https://raw.githubusercontent.com/Tomshiii/ahk/" tree "/checklist.ahk")
                main.Send()
                main.WaitForResponse()
                string := main.ResponseText
            }  catch as e {
                tool.Cust("Couldn't get version info`nYou may not be connected to the internet")
                return
            }
            if !IsSet(string)
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
    currentVer := IniRead(A_MyDocuments "\tomshi\settings.ini", "Track", "version")
    if tree = "main"
        latestVer := getScriptRelease()
    if tree = "dev"
        latestVer := getScriptRelease(true)
    if VerCompare(latestVer, currentVer) > 0
        {
            Run("https://github.com/Tomshiii/ahk/releases")
            tool.Cust("There's a more up to date version!`nCurrent Release: " currentVer "`nLatest Release: " latestVer, 5.0)
        }
    if VerCompare(latestVer, currentVer) < 0
        tool.Cust("It appears you've travelled through time and put yourself on a newer version...`nor you're just on a beta release and comparing to main", 5.0)
    if VerCompare(latestVer, currentVer) = 0
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

    currentHours := floorDecimal(ElapsedTime / 3600, 3)
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

    MyGui.GetPos(&x, &y, &width, &height)
    hoursGUI := Gui("AlwaysOnTop", "Hours Worked")
    hoursGUI.Opt("+Owner" MyGui.Hwnd)
    hoursGUI.Opt("+MinSize200x200")
    hoursGUI.SetFont("S11")
    hoursGUI.SetFont("W400")
    hoursGUI.BackColor := 0xF0F0F0
    MyGui.Opt("+Disabled")

    hoursGUI.Add("Text", "W200 Center", "Hours worked today: " workedToday "`nDays worked: " increment "`nAvg Hours per day: " avg)

    hoursGUI.OnEvent("Close", hoursClose)
    hoursGUI.Show("AutoSize")
    hoursGUI.GetPos(,, &hourswidth, &hoursheight)
    hoursGUI.Move(x - (hourswidth/2) + (width/2), y - (hoursheight/2) + (height/2))

    hoursClose(*)
    {
        MyGui.Opt("-Disabled")
        hoursGUI.Destroy
    }
}

/**
 * This function is called when the darkmode toggle menu option is pressed and handles keeping track of what option the user wants. It then calls `which()` to actually make the switch
 */
goDark(*)
{
    if darkToolTrack = 1
        {
            global darkToolTrack := 0
            SettingsMenu.UnCheck("&Dark Mode")
            IniWrite("0", checklist, "Info", "dark")
            which(false, "Light", 0)
        }
    else if darkToolTrack = 0
        {
            global darkToolTrack := 1
            SettingsMenu.Check("&Dark Mode")
            IniWrite("1", checklist, "Info", "dark")
            which()
        }
}


/**
 * This function is called by `goDark()` and handles toggling dark mode for checklist.ahk
 * @param {boolean} dark is a toggle that allows us to do the inverse and swap back to light mode. Pass false to do so
 * @param {string} DarkorLight is another toggle that allows us to do the inverse and swap back to light mode. Pass `"Light"` to do so
 */
which(dark := true, DarkorLight := "Dark", menu := 1)
{
    ;https://stackoverflow.com/a/58547831/894589 ;this section handles menus
    if !IsSet(uxtheme)
        {
            static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
            static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
            static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
        }
    DllCall(SetPreferredAppMode, "int", menu) ; Dark
    DllCall(FlushMenuThemes)

    titleBarDarkMode(MyGui.Hwnd, dark)
    buttonDarkMode(startButton.Hwnd, DarkorLight)
    buttonDarkMode(stopButton.Hwnd, DarkorLight)
    buttonDarkMode(minusButton.Hwnd, DarkorLight)
    buttonDarkMode(plusButton.Hwnd, DarkorLight)

    titleBarDarkMode(hwnd, dark := true)
    {
        if VerCompare(A_OSVersion, "10.0.17763") >= 0 {
            attr := 19
            if VerCompare(A_OSVersion, "10.0.18985") >= 0 {
                attr := 20
            }
            DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", dark, "int", 4)
        }
    }

    buttonDarkMode(ctrl_hwnd, DarkorLight := "Dark")
    {
        DllCall("uxtheme\SetWindowTheme", "ptr", ctrl_hwnd, "str", DarkorLight "Mode_Explorer", "ptr", 0)
    }
}

/**
 * This function is called when the Open Logs menu option is selected
 */
openLog(*)
{
    if FileExist(logs)
        Run(logs)
    else
        tool.Cust("the log file", 2000, 1)
}