/************************************************************************
 * @description A collection of functions that run on `My Scripts.ahk` Startup
 * @file Startup.ahk
 * @author tomshi
 * @date 2024/03/20
 * @version 1.7.17
 ***********************************************************************/

; { \\ #Includes
#Include <GUIs\todoGUI>
#Include <GUIs\hotkeysGUI>
#Include <GUIs\settingsGUI\settingsGUI>
#Include <GUIs\activeScripts>
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\Dark>
#Include <Classes\winget>
#Include <Classes\keys>
#Include <Classes\Mip>
#Include <Classes\reset>
#Include <Classes\errorLog>
#Include <Other\SystemThemeAwareToolTip>
#Include <Functions\getScriptRelease>
#Include <Functions\getHTML>
#Include <Functions\isReload>
#Include <Functions\getLocalVer>
#Include <Functions\trayShortcut>
#Include <Functions\editScript>
#Include <Other\FileGetExtendedProp>
#Include <Other\print>
; }

class Startup {
    __New() {
        ;// alert that startup functions are running
        this.alertTimer := true
        this.__alertTooltip()
        ;// get release version of scripts
        this.MyRelease := this.__getMainRelease()
        ;// populate settings variables
        this.UserSettings := UserPref()
    }

    ;// see if you can create function that reads product version of adobe .exe files to get their version and set in settings.ini
    ;// also add settingsGUI() option to enable/disable this check

    MyRelease := 0
    UserSettings := ""

    startupTtpNum := 12

    alertTimer := false
    alertTtipNum := 20
    activeFunc := ""

    __alertTooltip() {
        SetTimer(alertttp, 1)
        OnExit(ext, -1)
        ext(*) {
            this.activeFunc := ""
            this.alertTimer := false
            SetTimer(alertttp, 0)
            tool.Cust("",,,, this.alertTtipNum)
        }
        alertttp() {
            if !this.alertTimer {
                this.activeFunc := ""
                tool.Cust("",,,, this.alertTtipNum)
                SetTimer(, 0)
                return
            }
            coord.s("Tooltip", false)
            static dotAmount := 1
            switch dotAmount {
                case 1: dot := "."
                case 2: dot := ".."
                case 3: dot := "..."
            }
            ToolTip("⚠️ Startup functions running" dot "`nCurrent function: " this.activeFunc, A_ScreenWidth, A_ScreenHeight, this.alertTtipNum)
            if ++dotAmount > 3
                dotAmount := 1
            sleep 750
        }
    }

    /**
     * This function retrieves the release version the user is currently running
     */
    __getMainRelease() => getLocalVer()

    /**
     * This function checks whether the user is on a late enough version of windows to use dark mode
     */
    __checkDark() {
        if this.UserSettings.dark_mode != ""
            return this.UserSettings.dark_mode
        if (VerCompare(A_OSVersion, "10.0.17763") < 0)
            {
                this.UserSettings.dark_mode := "disabled"
                this.UserSettings.__delAll()
                reset.reset()
                return "disabled"
            }
        this.UserSettings.dark_mode := true
        this.UserSettings.__delAll()
        return "true"
    }

    /**
     * This function handles checking `settings.ini` on a new release of the repo and ensures all values are present and set.
     * It will also automatically add new values to an existing settings file if it isn't currently present.
     */
    generate() {
        if isReload() ;checks if script was reloaded
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        ;// checking to see if the users OS version is high enough to support dark mode
        darkCheck := this.__checkDark()

        genNewMap() => newMap := Mip()
        ensureSpaces(inpString) => StrReplace(inpString, "_", A_Space)
        result(res) {
            switch res {
                case true: return "true"
                case false: return "false"
                default: return res
            }
        }

        allSettings := genNewMap(), allAdjust := genNewMap(), allTrack  := genNewMap()
        for v in StrSplit(IniRead(ptf["settings"]), "`n") {
            for k, v2 in valArr := StrSplit(IniRead(ptf["settings"], v), ["=", "`n", "`r"]) {
                if Mod(k, 2) = 0
                    continue
                all%v%.Set(ensureSpaces(v2), result(valArr.Get(k+1)))
            }
        }

        ;// checking to see if the settings folder location exists
        if FileExist(this.UserSettings.SettingsFile)
            {
                ;// this check ensures that the function will prematurely return if the release version in the settings.ini is the same as the current release AND
                ;// that the amount of settings all line up, otherwise the function will continue so that it may add missing settings values
                if (this.UserSettings.defaults.Length != (allSettings.Count + allAdjust.Count + allTrack.Count)) || (VerCompare(this.MyRelease, this.UserSettings.version) > 0) {
                    tempFile := A_MyDocuments "\tomshi\settings_temp.ini"
                    UserPref().__createIni(tempFile)
                    tempSettings := genNewMap(), tempAdjust := genNewMap(), tempTrack  := genNewMap()
                    for v in StrSplit(IniRead(tempFile), "`n") {
                        for k, v2 in valArr := StrSplit(IniRead(tempFile, v), ["=", "`n", "`r"]) {
                            if Mod(k, 2) = 0
                                continue
                            temp%v%.Set(ensureSpaces(v2), result(valArr.Get(k+1)))
                        }
                    }
                    FileDelete(tempFile)
                    setSection(tempSettings, allSettings, "Settings")
                    setSection(tempAdjust, allAdjust, "Adjust")
                    setSection(tempTrack, allTrack, "Track", true)
                    this.UserSettings.__delAll()
                    return
                }
            }

        ;// generate new settings
        ;// [settings]
        /**
         * This function is to cut reduce code
         * It enumerates through an array from `UserPref {` and compares it against an array created earlier
         * It handles adding new values to settings.ini if they're listed above but not present in settings.ini
         */
        setSection(userSettingsArr, startupArr, iniSection, track := false) {
            if (userSettingsArr.Count != startupArr.Count) {
                tempSett := userSettingsArr.Clone()
                for k, v in startupArr {
                    if tempSett.Has(k)
                        tempSett.Delete(k)
                }
                if tempSett.Count > 0
                    {
                        for k, v in tempSett {
                            IniWrite(userSettingsArr.Get(k), this.UserSettings.SettingsFile, iniSection, k)
                        }
                    }
            }
            switch track {
                case true:
                    for k, v in userSettingsArr {
                        ;// set version number
                        if k = "version"
                            {
                                this.UserSettings.%k% := this.MyRelease
                                continue
                            }
                        if k = "first_check" || k = "block_aware"
                            {
                                returnBool(input) {
                                    switch input {
                                        case "true":      return true
                                        case "false":     return false
                                        default:          return input
                                    }
                                }
                                this.UserSettings.%k% := returnBool(startupArr.Get(k))
                                continue
                            }
                        this.UserSettings.%k% := (startupArr.Has(k)) ? startupArr.Get(k) : userSettingsArr.Get(k)
                    }
                default:
                    for k, v in userSettingsArr {
                        this.UserSettings.%k% := (startupArr.Has(k)) ? startupArr.Get(k) : userSettingsArr.Get(k)
                    }
            }
        }
    }

    /**
     * determines whether to download the ahk exe or .zip folder
     * @param {Number} version the latest version of my ahk scripts
     * @returns On success returns a string containing either `exe` or `zip`. Else returns `false`
     */
    __exeOrzip(version) {
        __request(filetype, version) {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("GET", "https://github.com/Tomshiii/ahk/releases/download/" version "/" version "." filetype, true)
            whr.Send()
            ; Using 'true' above and the call below allows the script to remain responsive.
            whr.WaitForResponse()
            return whr.ResponseText
        }
        checkEXE := __request("exe", version)
        if checkEXE != "Not Found"
            return "exe"
        checkZip := __request("zip", version)
        if checkZip != "Not found"
            return "zip"
        ToolTip("")
        MsgBox("Couldn't find the latest release to download")
        return false
    }

    /**
     * This function will (on first startup, NOT a refresh of the script) check which version of the script you're running, cross reference that with the latest release on github and alert the user if there is a newer release available with a prompt to download as well as showing a changelog.
     *
     * Which branch the user wishes to check for (either beta, or main releases) can be determined by either right clicking on `My Scripts.ahk` in the task bar and clicking  `Settings`, or by accessing `settingsGUI()` (by default `#F1`)
     *
     * This script will also perform a backup of the users current instance of the "ahk" folder this script resides in and will place it in the `\Backups` folder.
     */
    updateChecker() {
        if isReload() ;checks if script was reloaded
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        ;checking to see if the user wishes to check for updates
        if this.UserSettings.update_check = "stop"
            return
        version := (this.UserSettings.beta_update_check = true) ? getScriptRelease(true, &changeVer) : getScriptRelease(, &changeVer)
        if version = 0
            return
        tool.Wait(1)
        if this.MyRelease != version
            tool.Cust("Current Installed Version = " this.MyRelease "`nCurrent Github Release = " version, 5000,,, this.startupTtpNum)
        else
            tool.Cust("You are currently up to date", 2000)
        switch this.UserSettings.update_check {
            default:
                errorLog(ValueError("Incorrect value input in ``settings.ini``", -1, this.UserSettings.update_check),, 1)
                return
            case false, "false":
                if VerCompare(this.MyRelease, version) < 0 {
                    errorLog(Error("User is using an outdated version of these scripts", -1, version),, {time: 3.0})
                    return
                }
                tool.Cust("This script will not prompt you with a download/changelog when a new version is available", 3.0,,, this.startupTtpNum)
                return
            case true, "true":
                if VerCompare(this.MyRelease, version) >= 0
                    return
                ;create gui
                MyGui := tomshiBasic(,, "-Resize +MaxSize600x400 AlwaysOnTop", "Scripts Release " version)
                ;set title
                Title := MyGui.Add("Text", "Section H40 W350", "New Scripts - Release " version)
                Title.SetFont("S15")
                ;set github button
                MyGui.AddButton("X+20 Y10 vgitButton", "GitHub").OnEvent("Click", githubButton)

                ;view changelog
                MyGui.AddButton("Section xs Y+20 h40 W100", "View Latest Changelog").OnEvent("Click", viewClick)
                viewClick(*) {
                    Run(ptf["updateCheckGUI"])
                    WinSetAlwaysOnTop(0, "Scripts Release " version)
                    if WinWait("Latest Update - " version,, 3)
                        {
                            WinActivate("Latest Update - ")
                            WinGetPos(&updx, &updy, &updwidth,, "Latest Update - " version)
                            MyGui.Move(updx+updwidth+10, updy)
                        }
                }

                ;set download button
                MyGui["gitButton"].GetPos(&x)
                MyGui.AddButton("Section X" x-85 " ys+13", "Download").OnEvent("Click", Down)
                ;set cancel button
                MyGui.AddButton("Default X+5", "Cancel").OnEvent("Click", closegui)
                ;set "don't prompt again" checkbox
                MyGui.AddCheckbox("xs-175 Ys-10", "Don't prompt again").OnEvent("Click", prompt.bind("prompt"))
                ;set beta checkbox
                betaCheck := (this.UserSettings.beta_update_check = true)
                           ? MyGui.Add("Checkbox", "Checked1 Y+5", "Check for Pre-Releases")
                           : MyGui.Add("Checkbox", "Checked0 Y+5", "Check for Pre-Releases")
                betaCheck.OnEvent("Click", prompt.bind("prerelease"))

                MyGui.Show()
                prompt(which, guiCtrl, *) {
                    switch which {
                        case "prompt": this.UserSettings.update_check := (guiCtrl.Value = 0) ? true : false
                        case "prerelease":
                            this.UserSettings.beta_update_check := (guiCtrl.value = 0) ? false : true
                            this.UserSettings.__delAll()
                            Run(A_ScriptFullPath)
                    }
                }
                githubButton(*) {
                    if !WinExist("Tomshiii/ahk") {
                        Run("https://github.com/tomshiii/ahk/releases")
                        return
                    }
                    WinActivate("Tomshiii/ahk")
                }
                down(*) {
                    this.UserSettings.__delAll()
                    MyGui.Opt("Disabled -AlwaysOnTop")
                    yousure := MsgBox("If you have modified your scripts, overidding them with this download will result in a loss of data.`nA backup will be performed after downloading and placed in the \Backups folder but it is recommended you do one for yourself as well.`n`nPress Cancel to abort this automatic backup.", "Backup your scripts!", "1 48")
                    if yousure = "Cancel"
                        {
                            MyGui.Opt("-Disabled")
                            return
                        }
                    MyGui.Destroy()
                    if !downloadLocation := FileSelect("D", , "Where do you wish to download Release " version)
                        return

                    if !type := this.__exeOrzip(version)
                        return

                    if FileExist(downloadLocation "\" version "." type) {
                        file := MsgBox("File already exists.`n`nDo you want to override it?", "File already exists", "4 32 4096")
                        if file = "No"
                            return
                        FileDelete(downloadLocation "\" version "." type)
                    }

                    tool.tray({text: "Updated scripts are downloading", title: "Downloading...", options: 17})
                    Download("https://github.com/Tomshiii/ahk/releases/download/" version "/" version "." type, downloadLocation "\" version "." type)
                    Run(downloadLocation "\")

                    if DirExist(A_Temp "\" this.MyRelease)
                        DirDelete(A_Temp "\" this.MyRelease, 1)
                    if DirExist(ptf.rootDir "\Backups\Script Backups\" this.MyRelease) {
                        newbackup := MsgBox("You already have a backup of Release " this.MyRelease "`nDo you wish to override it and make a new backup?", "Error! Backup already exists", "4 32 4096")
                        if newbackup != "Yes" {
                            ToolTip("")
                            TrayTip()
                            return
                        }
                        DirDelete(ptf.rootDir "\Backups\Script Backups\" this.MyRelease, 1)
                    }
                    try {
                        tool.tray({text: "Your current scripts are being backed up!", title: "Backing Up...", options: 17})
                        DirCopy(ptf.rootDir, A_Temp "\" this.MyRelease)
                        DirMove(A_Temp "\" this.MyRelease, ptf.rootDir "\Backups\Script Backups\" this.MyRelease, "1")
                        if DirExist(A_Temp "\" this.MyRelease)
                            DirDelete(A_Temp "\" this.MyRelease, 1)
                        tool.Cust("Your current scripts have successfully backed up to the '\Backups\Script Backups\" this.MyRelease "' folder", 3000,,, this.startupTtpNum)
                    } catch {
                        errorLog(Error("There was an error trying to backup your current scripts"),, {ttip: this.startupTtpNum})
                        return
                    }
                    return
                }
                closegui(*) {
                    this.UserSettings.__delAll()
                    MyGui.Destroy()
                    return
                }
        }
    }

    /**
     * This function checks to see if it is the first time the user is running this script. If so, they are then given some general information regarding the script as well as a prompt to check out some useful hotkeys.
     */
    firstCheck() {
        ;The variable names in this function are an absolute mess. I'm not going to pretend like they make any sense AT ALL. But it works so uh yeah.
        if isReload() ;checks if script was reloaded
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        if WinExist("Scripts Release ")
            WinWaitClose("Scripts Release ")
        if this.UserSettings.first_check != false ;how the function tracks whether this is the first time the user is running the script or not
            return
        firstCheckGUI := tomshiBasic(,, "-Resize AlwaysOnTop", "Scripts Release " this.MyRelease)
        ;set title
        titleText := "Welcome to Tomshi's AHK Scripts : Release " this.MyRelease
        titleWidth := 430 + ((StrLen(this.MyRelease)-4)*8)
        Title := firstCheckGUI.Add("Text", "X8 R1.5 W" titleWidth, titleText)
        Title.SetFont("S15")
        ;text
        bodyText := firstCheckGUI.Add("Text", "W550 X8 Center", "
        (
            Congratulations!
            You've gotten my main script to load without any runtime errors! (hopefully).
            You've taken the first step to really getting the most out of these scripts!

            This script alone isn't everything my repo of scripts has to offer, heading into ``Handy Hotkeys`` below and finding the hotkey for the current active scripts will show you some of the other scripts available to you!
            Beyond those scripts there is also everything in the ``
        )" A_WorkingDir "
        (
            \Streamdeck AHK\`` directory that provides even more functionality.

            The purpose of these scripts is to speed up both editing (mostly within the Adobe suite of programs) and random interactions with a computer. Listing off everything these scripts are capable of would take more screen real estate than you likely have and so all I can do is point you towards the comments for individual hotkeys/functions in the hopes that they explain everything for me.
            These scripts are heavily catered to my pc/setup and as a result may run into issues on other systems (for example I have no idea how they will perform on lower end systems). Feel free to create an issue on the github for any massive problems or even consider tweaking the code to be more universal and try a pull request. I make no guarantees I will merge any PR's as these scripts are still for my own setup at the end of the day but I do actively try to make my code as flexible as possible to accommodate as many outliers as I can.

            The below ``Handy Hotkeys`` outlines some hotkeys that are available to use anywhere within windows and are a great place to get started when trying to navigate the power of these scripts! (note: they still only scratch the surface, a large chunk of my scripts are specific to programs and will only activate if said program is the current active window)

            The below ``Settings`` GUI can be accessed at anytime by right clicking ``My Scripts.ahk`` on the taskbar or by pressing ``#F1`` (by default).
        )")
        ;buttons
        firstCheckGUI.AddButton("X200 Y+8", "Settings").OnEvent("Click", settings)
        todoButton := firstCheckGUI.AddButton("X+10", "What to Do").OnEvent("Click", (*) => todoGUI())
        firstCheckGUI.AddButton("X+10", "Handy Hotkeys").OnEvent("Click", (*) => hotkeysGUI())
        firstCheckGUI.AddButton("X+10", "Close").OnEvent("Click", close)

        firstCheckGUI.OnEvent("Escape", close)
        firstCheckGUI.OnEvent("Close", close)
        close(*) {
            this.UserSettings.first_check := true ;tracks the fact the first time screen has been closed. These scripts will now not prompt the user again
            this.UserSettings.__delAll()
            firstCheckGUI.Destroy()
            RunWait(A_ScriptFullPath)
            return
        }
        settings(*) {
            WinSetAlwaysOnTop(0, "Scripts Release " this.MyRelease)
            settingsGUI()
            WinWait("Settings " this.MyRelease)
            WinActivate("Settings " this.MyRelease)
            WinWaitClose("Settings " this.MyRelease)
            WinSetAlwaysOnTop(1, "Scripts Release " this.MyRelease)
        }

        firstCheckGUI.Show("AutoSize")

        ;centering the title
        title.GetPos(,, &width)
        firstCheckGUI.GetClientPos(,, &guiWidth)
        title.Move((guiWidth-width)/2)
    }

    /**
     * This function will (on first startup, NOT a refresh of the script) delete any `\.txt` files in any of the `..\Logs\` folders that are older than 30 days
     */
    oldLogs() {
        if isReload()
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        loop files, ptf.Logs "\*.txt", "R" {
            if DateDiff(A_LoopFileTimeCreated, A_now, "Days") < -30
                FileDelete(A_LoopFileFullPath)
        }
    }

    /**
     * This function will (on first startup, NOT a refresh of the script) delete any Adobe temp files when they're bigger than the specified amount (in GB). Adobe's "max" limits that you set within their programs is stupid and rarely chooses to work, this function acts as a sanity check.
     *
     * It should be noted I have created a custom location for all cache/temp folders and I do not keep them on my main drive. The default locations for media cache are within:
     * ```
     * A_AppData "\Adobe\Common\"
     * ```
     */
    adobeTemp() {
        if (isReload() || (WinExist(Editors.Premiere.winTitle) || WinExist(Editors.AE.winTitle)))
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        if WinExist("Scripts Release " this.MyRelease) ;checks to make sure firstCheck() isn't still running
            WinWaitClose("Scripts Release " this.MyRelease)
        if this.UserSettings.adobe_temp = A_YDay ;checks to see if the function has already run today
            return

        ;// SET HOW BIG YOU WANT IT TO WAIT FOR IN THE `settings.ini` FILE (IN GB) -- IT WILL DEFAULT TO 45GB
        largestSize := this.UserSettings.adobe_GB

        ;// first we set our counts to 0
        CacheSize := 0
        ;// the below filelocations are custom and will NOT work out of the box
        ;// can be set within settingGUI()
        cacheFolders := [
            this.UserSettings.premCache,
            this.UserSettings.aeCache,
            ;// add any more here
        ]
        allowedDirs := Mip(
            "Analyzer Cache Files", 1, "Media Cache", 1,
            "Media Cache Files",    1, "Peak Files", 1,
            "Team Projects Cache",  1
        )
        ;// map we use to determine directorys and not iterate on the same one multiple times
        usedDirs := Map()
        try {
            ;// adding up the total size of the above listed filepaths
            alerted := false
            for v, p in cacheFolders {
                if !DirExist(p) {
                    if alerted = false
                        {
                            errorLog(TargetError(A_ThisFunc "() could not find one or more of the specified folders, therefore making it unable to calculate the total cache size", -1), A_ScriptName "`nLine: " A_LineNumber, {time: 4.0})
                            alerted := true
                        }
                    continue
                }
                ;// do a check to make sure we aren't adding the same directory multiple times
                if usedDirs.Has(p)
                    continue
                usedDirs.Set(p, true)
                ;// add up cache locations
                CacheSize := CacheSize + winget.FolderSize(p, 2)
            }
            if CacheSize = 0 {
                tool.Cust("Total Adobe cache size - " CacheSize "/" largestSize "GB", 3.0,,, this.startupTtpNum)
                this.UserSettings.adobe_temp := A_YDay ;tracks the day so it will not run again today
                return
            }
            ;// `winget.FolderSize()` returns it's value in GB, we simply want to round it to 2dp
            tool.Cust("Total Adobe cache size - " Round(CacheSize, 2) "/" largestSize "GB", 3.0,,, this.startupTtpNum)

            ;// if the total is bigger than the set number, we loop those directories and delete all the files
            if CacheSize >= largestSize {
                tool.Cust(A_ThisFunc " is currently deleting temp files", 2.0,,, this.startupTtpNum)
                try {
                    for v, p in usedDirs {
                        loop files, p "\*.*", "R" {
                            if !allowedDirs.Has(A_LoopFileDir)
                                continue
                            FileDelete(A_LoopFileFullPath)
                        }
                    }
                }
            }
        }
        this.UserSettings.adobe_temp := A_YDay ;tracks the day so it will not run again today
    }

    /** This function will set the current prem/ae version based off the current .exe version (only if UserSettings.adobeExeOverride is set to `true`). This function still requires to user to manually set their Year variable. */
    adobeVerOverride() {
        if !this.UserSettings.adobeExeOverride
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        premFolder := (this.UserSettings.premIsBeta = true) ? "Adobe Premiere Pro (Beta)"  : "Adobe Premiere Pro " SubStr(A_YYYY, 1, 2) ptf.PremYearVer
        aeFolder   := (this.UserSettings.aeIsBeta = true)   ? "Adobe After Effects (Beta)" : "Adobe After Effects " SubStr(A_YYYY, 1, 2) ptf.aeYearVer
        premExeLocation := A_ProgramFiles "\Adobe\" premFolder "\Adobe Premiere Pro.exe"
        aeExeLocation   := A_ProgramFiles "\Adobe\" aeFolder "\Support Files\AfterFX.exe"

        premExeVer := FileExist(premExeLocation) ? FileGetExtendedProp(premExeLocation,, "Product version")["Product version"] : false
        aeExeVer   := FileExist(aeExeLocation)   ? FileGetExtendedProp(aeExeLocation,, "Product version")["Product version"]   : false

        ;// remove ".0"
        premExeVer := SubStr(premExeVer, premFinalDot := InStr(premExeVer, ".",, -1), 2) = ".0" ? SubStr(premExeVer, 1, premFinalDot-1) : premExeVer
        aeExeVer   := SubStr(aeExeVer, aeFinalDot     := InStr(aeExeVer, ".",, -1), 2)   = ".0" ? SubStr(aeExeVer, 1, aeFinalDot-1)     : aeExeVer

        if premExeVer = false && aeExeVer = false
            return

        if VerCompare(premExeVer, this.UserSettings.premVer) != 0 || VerCompare(aeExeVer, this.UserSettings.aeVer) != 0 {
            this.UserSettings.premVer := premExeVer != false ? "v" premExeVer : this.UserSettings.premVer
            this.UserSettings.aeVer   := aeExeVer != false   ? "v" aeExeVer   : this.UserSettings.aeVer
        }
    }

    /**
     * This function will add right click tray menu items to "My Scripts.ahk" to toggle checking for updates as well as accessing a GUI to modify script settings
     */
    trayMen() {
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        check := this.UserSettings.update_check
        shortcutLink := A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\" A_ScriptName " - Shortcut.lnk"
        startingVal := 4
        /** Cuts the need to adjust values everytime I want to shuffle something */
        __addAndIncrement(text, funcObj?) {
            A_TrayMenu.Insert(startingVal "&", text, funcObj?)
            startingVal++
        }
        A_TrayMenu.Delete("3&")
        __addAndIncrement("") ;adds a divider bar
        startingVal++
        __addAndIncrement("Reload All Scripts", (*) => reset.ext_reload())
        __addAndIncrement("Hard Reset All Scripts", (*) => reset.reset())
        ; A_TrayMenu.Insert("6&", "Reload All Scripts", (*) => reset.ext_reload())
        ; A_TrayMenu.Insert("7&", "Hard Reset All Scripts", (*) => reset.reset())
        __addAndIncrement("") ;adds a divider bar
        __addAndIncrement("Settings", (*) => settingsGUI())
        __addAndIncrement("keys.allUp()", (*) => keys.allUp())
        __addAndIncrement("Active Scripts", (*) => activeScripts())
        startupTray(11)
        startingVal++
        __addAndIncrement("Check for Updates", checkUp)
        __addAndIncrement("") ;adds a divider bar
        __addAndIncrement("Open All Scripts", (*) => Run(ptf.rootDir "\PC Startup\PC Startup.ahk"))
        __addAndIncrement("Close All Scripts", (*) => reset.ex_exit())
        __addAndIncrement("Open UIA Script", (*) => Run(ptf.rootDir "\lib\Other\UIA\UIA.ahk"))
        __addAndIncrement("Open Prem_UIA Values", (*) => editScript(ptf.rootDir "\Support Files\UIA\values.ini"))
        __addAndIncrement("Set Prem_UIA Values", (*) => WinExist(prem.winTitle) ? premUIA_Values(false).__setNewVal() : MsgBox("Premiere needs to be open for this option to function correctly!"))
        A_TrayMenu.Rename("&Help", "&Help/Documentation")
        ; A_TrayMenu.Delete("&Window Spy")
        A_TrayMenu.Delete("&Edit Script")
        if check =  true
            A_TrayMenu.Check("Check for Updates")
        checkUp(*)
        {
            check := this.UserSettings.update_check ;has to be checked everytime you wish to toggle
            switch check {
                case true:
                    this.UserSettings.update_check := false
                    A_TrayMenu.Uncheck("Check for Updates")
                case false:
                    this.UserSettings.update_check := true
                    A_TrayMenu.Check("Check for Updates")
            }
        }
    }

    /**
     * This class is a collection of information relating to external lib files used by my scripts.
     */
    class libs {
        __New() {
            this.__defControls()
        }

        __defControls() {
            for v in this.objs {
                for name, val in v.OwnProps() {
                    this.%name%.Push(val)
                }
            }
        }

        webView2 := {
            name: "WebView2",                        url: "https://raw.githubusercontent.com/thqby/ahk2_lib/master/WebView2/WebView2.ahk",
            scriptPos: ptf.lib "\Other\WebView2"
        }
        comVar := {
            name: "ComVar",                          url: "https://raw.githubusercontent.com/thqby/ahk2_lib/master/ComVar.ahk",
            scriptPos: ptf.lib "\Other"
        }
        JSON := {
            name: "JSON",                            url: "https://raw.githubusercontent.com/thqby/ahk2_lib/master/JSON.ahk",
            scriptPos: ptf.lib "\Other"
        }
        UIA := {
            name: "UIA",                             url: "https://raw.githubusercontent.com/Descolada/UIA-v2/main/Lib/UIA.ahk",
            scriptPos: ptf.lib "\Other\UIA"
        }
        UIA_Browser := {
            name: "UIA_Browser",                     url: "https://raw.githubusercontent.com/Descolada/UIA-v2/main/Lib/UIA_Browser.ahk",
            scriptPos: ptf.lib "\Other\UIA"
        }
        WinEvent := {
            name: "WinEvent",                        url: "https://raw.githubusercontent.com/Descolada/AHK-v2-libraries/main/Lib/WinEvent.ahk",
            scriptPos: ptf.lib "\Other"
        }

        objs := [this.webView2, this.comVar, this.JSON, this.UIA, this.UIA_Browser, this.WinEvent]
        name        := []
        url         := []
        scriptPos   := []
    }

    /**
     * This function will loop through `class libs {` and ensure that all libs are up to date. This function will not fire on a reload
     */
    libUpdateCheck() {
        if isReload()
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        if !checkInternet()
            return
        check := this.UserSettings.update_check
        if check = "stop"
            return
        allLibs := Startup.libs()
        /**
         * This function get's the local version of the requested lib
         * @param {any} path is the local path the lib is located
         * @returns {Obj} returns the local lib version number or the entire script in a string
         */
        localVer(path) {
            script := FileRead(path)
            getVerPos := InStr(script, "@version")
            if getVerPos = 0 ;if the lib doesn't have a @version tag, we'll pass back a blank script and do something else later
                return {version: "", script: script}
            endPos := InStr(script, "*",, getVerPos, 1) - 2
            localVerStr := Trim(SubStr(script, getVerPos + 9, endPos-(getVerPos + 9)), " `t`n`r")
            return {version: localVerStr, script: script}
        }
        /**
         * This function get's the latest version of the requested lib
         * @param {any} url is the url the function will check (raw.github links recommended)
         * @returns {string} returns the latest lib version number
         */
        getString(url) {
            string := getHTML(url)
            if string = -1 {
                tool.Tray({title: "libUpdateCheck() encountered an issue", text: "lib may have incorrect url:`n" url})
                errorLog(Error(A_ThisFunc " encountered an issue with the specified url", -1), url)
                return {version: 0}
            }
            if string = 0
                return {version: 0}
            if InStr(string, "﻿") ;removes zero width no-break space
                string := StrReplace(string, "﻿", "")
            getVerPos := InStr(string, "@version")
            if getVerPos = 0
                return {version: "", script: string}
            endPos := InStr(string, "*",, getVerPos, 1) - 2
            ver := Trim(SubStr(string, getVerPos + 9, endPos-(getVerPos + 9)), " `t`n`r")
            return {version: ver, script: string}
        }
        ;begin loop
        loop allLibs.name.Length {
            localVersion := localVer(allLibs.scriptPos[A_Index] "\" allLibs.name[A_Index] ".ahk")
            latestVer := getString(allLibs.url[A_Index])
            if latestVer.version = ""
                { ;if the lib doesn't have a @version tag, we'll instead compare the entire file against the local copy and override it if there are differences
                    if localVersion.script !== latestVer.script
                        {
                            Download(allLibs.url[A_Index], allLibs.scriptPos[A_Index] "\" allLibs.name[A_Index] ".ahk")
                            tool.Cust(allLibs.name[A_Index] ".ahk lib file updated",,,, this.startupTtpNum)
                        }
                    continue
                }
            if latestVer.version = 0
                continue
            if VerCompare(latestVer.version, localVersion.version) > 0
                {
                    Download(allLibs.url[A_Index], allLibs.scriptPos[A_Index] "\" allLibs.name[A_Index] ".ahk")
                    tool.Cust(allLibs.name[A_Index] ".ahk lib file updated to v" latestVer.version,,,, this.startupTtpNum)
                    continue
                }
        }
        tool.Cust("libs up to date",,,, this.startupTtpNum)
    }

    /**
     * This function will check for a new version of AHK by comparing the latest version to the users currently running version. If a newer version is available, it will prompt the user.
     */
    updateAHK() {
        if isReload() ;checks if script was reloaded
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        settingsCheck := this.UserSettings.update_check
        if settingsCheck = "stop"
            return
        /**
         * A wrapper function to retrieve the latest release of ahk
         * This was put in place instead of reading the .txt file of the ahk website because it started using ddos protection
         */
        __getahk() {
            response := getHTML("https://api.github.com/repos/AutoHotkey/AutoHotkey/releases/latest")
            if !response
                return false
            RegExMatch(response, "v\K[\d.]+", &match)
            return match[0]
        }
        if !latestVer := __getahk()
            return
        if VerCompare(latestVer, A_AhkVersion) <= 0 {
            tool.Cust("AHK up to date",,,, this.startupTtpNum)
            return
        }
        if settingsCheck = false {
            tool.Cust("A new version of AHK is available",,,, this.startupTtpNum)
            return
        }

        ;// define gui
        marg := 8
        mygui := tomshiBasic(,,, "AHK v" latestVer " available")
        mygui.AddText(, "A newer version of AHK (v" latestVer ") is available`nDo you wish to download it?")

        ;// run installer checkbox
        mygui.Add("Checkbox", "vrunafter Section y+10 x" marg, "Run after download?")
        ;// buttons
        mygui.AddButton("ys-10 x+25", "Yes").OnEvent("Click", downahk.Bind(latestVer))
        mygui.AddButton("x+5", "No").OnEvent("Click", (*) => mygui.Destroy())

        mygui.Show()
        downahk(ver, *) {
            if !downloadLocation := FileSelect("D", , "Where do you wish to download the latest AHK release")
                return
            if FileExist(downloadLocation "\ahk-v2.exe")
                {
                    file := MsgBox("File already exists.`n`nDo you want to override it?", "File already exists", "4 32 4096")
                    if file = "No"
                        return
                    FileDelete(downloadLocation "\ahk-v2.exe")
                }
            mygui.Hide()
            Download(Format("https://github.com/AutoHotkey/AutoHotkey/releases/download/v{1}/AutoHotkey_{1}_setup.exe", ver), downloadLocation "\ahk-v2.exe")

            switch mygui["runafter"].Value {
                case 1:  try Run(downloadLocation "\ahk-v2.exe")
                default: Run(downloadLocation)
            }
            mygui.Destroy()
        }
    }

    /**
     * This function alerts the user when their monitor layout has changed.
     * This is important as it can seriously mess up any scripts that contain hard coded pixel coords
     */
    monitorAlert() {
        if this.UserSettings.monitor_alert = A_YDay
            return
        this.activeFunc := StrReplace(A_ThisFunc, "Startup.Prototype.", "Startup.") "()"
        save := false

        ;// get initial values
        MonitorCount   := MonitorGetCount()
        MonitorPrimary := MonitorGetPrimary()
        /**
         * this function is to cut repeat code
         */
        write(WL, WT, WR, WB) {
            IniWrite(WL, ptf["monitorsINI"], A_Index, "Left")
            IniWrite(WT, ptf["monitorsINI"], A_Index, "Top")
            IniWrite(WR, ptf["monitorsINI"], A_Index, "Right")
            IniWrite(WB, ptf["monitorsINI"], A_Index, "Bottom")
        }
        ;// msgbox function
        alrtmsgbox() {
            ignoreToday() {
                if !WinExist("Monitor layout changed")
                    return
                SetTimer(, 0)
                WinActivate
                ControlSetText("&Yes", "Button1")
                ControlSetText("&No", "Button2")
                ControlSetText("&Mute Alert", "Button3")
            }
            SetTimer(ignoreToday, 16)
            check := MsgBox("
            (
                It appears like your monitor layout has changed, either by your own doing, or windows
                This may mess with any pixel coordinates you use for scripts.`n
                Do you want your current layout to be remembered instead?`n
                Alternatively you can mute this alert for today.
            )", "Monitor layout changed", "2 32 256 4096")
            switch check {
                case "Retry": return 0 ;// "No"
                case "Ignore": ;// "Mute Alert"
                    this.UserSettings.monitor_alert := A_YDay
                    return 0
                default:      return 1
            }
        }
        ;// what to do if the ini file doesn't yet exist
        if !FileExist(ptf["monitorsINI"])
            {
                IniWrite(MonitorCount, ptf["monitorsINI"], "Sys", "Count")
                IniWrite(MonitorPrimary, ptf["monitorsINI"], "Sys", "Primary")
                loop MonitorCount {
                    ;// log initial data
                    MonitorGetWorkArea(A_Index, &WL, &WT, &WR, &WB)
                    write(WL, WT, WR, WB)
                }
                return
            }
        ;// if the file does exist, we cross reference it
        readCount := IniRead(ptf["monitorsINI"], "Sys", "Count")
        readPrimary := IniRead(ptf["monitorsINI"], "Sys", "Primary")
        ;// if something has changed alert the user
        if (readCount != MonitorCount) || (readPrimary != MonitorPrimary)
            {
                if this.UserSettings.monitor_alert = A_YDay
                    return
                if !alrtmsgbox()
                    return
                save := true
                ;// log new values
                IniWrite(MonitorCount, ptf["monitorsINI"], "Sys", "Count")
                IniWrite(MonitorPrimary, ptf["monitorsINI"], "Sys", "Primary")
            }
        loop MonitorCount {
            ;// this loop is cross referencing the rest of the data
            MonitorGetWorkArea(A_Index, &WL, &WT, &WR, &WB)
            left   := IniRead(ptf["monitorsINI"], A_Index, "Left")
            top    := IniRead(ptf["monitorsINI"], A_Index, "Top")
            right  := IniRead(ptf["monitorsINI"], A_Index, "Right")
            bottom := IniRead(ptf["monitorsINI"], A_Index, "Bottom")
            if( ;// if nothing has changed, continue
                left   = WL &&
                top    = WT &&
                right  = WR &&
                bottom = WB )
                continue
            ;// if the user hasn't been alerted yet, they will be alerted now
            if !save {
                if this.UserSettings.monitor_alert = A_YDay
                    return
                if !alrtmsgbox()
                    return
                save := true
            }
            ;// log new values
            write(WL, WT, WR, WB)
        }
    }

    __Delete() {
        this.UserSettings.__delAll()
        this.alertTimer := false
        this.activeFunc := ""
        tool.Cust("",,,, this.alertTtipNum) ;// just incase
    }
}