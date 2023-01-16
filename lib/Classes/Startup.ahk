/************************************************************************
 * @description A collection of functions that run on `My Scripts.ahk` Startup
 * @file Startup.ahk
 * @author tomshi
 * @date 2023/01/16
 * @version 1.3.1
 ***********************************************************************/

; { \\ #Includes
#Include <GUIs\todoGUI>
#Include <GUIs\hotkeysGUI>
#Include <GUIs\settingsGUI\settingsGUI>
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\Dark>
#Include <Classes\winget>
#Include <Functions\errorLog>
#Include <Functions\getScriptRelease>
#Include <Functions\getHTML>
#Include <Functions\isReload>
#Include <Functions\getLocalVer>
#Include <Other\print>
; // libs
#Include <Other\_DLFile>
; }

class Startup {
    /**
     * This function retrieves the release version the user is currently running
     */
    __getMainRelease() => getLocalVer()

    __checkDark() {
        switch UserSettings.dark_mode {
            case "":
                if (VerCompare(A_OSVersion, "10.0.17763") < 0)
                    {
                        UserSettings.dark_mode := "disabled"
                        reload_reset_exit("reset")
                    }
                UserSettings.dark_mode := true
                reload_reset_exit("reset")
                return
        }
        return UserSettings.dark_mode
    }

    /**
     * This function will generate the settings.ini file if it doesn't already exist as well as regenerating it every new release to ensure any new .ini values are added without breaking anything.
     *
     * Do note if you're pulling commits from the `dev` branch of this repo and I add something to this `settings.ini` file & you pull the commit before a new release, this function will not generate a new file for you and you may encounter errors. You can get around this by manually lowering the "version" number in the `settings.ini` file and then running `My Scripts.ahk`
     */
    static generate() {
        if isReload() ;checks if script was reloaded
            return
        MyRelease := this().__getMainRelease()

        ;// checking to see if the settings folder location exists & if not, creates it
        if FileExist(UserSettings.SettingsFile)
            {
                ver := IniRead(UserSettings.SettingsFile, "Track", "version")
                ;//! do note if you're pulling commits from the `dev` branch of this repo and I add something to the `settings.ini` file & you pull the commit before a new release, this function will not generate a new file for you and you may encounter errors. You can get around this by manually lowering the "version" number in the `settings.ini` file and then running `My Scripts.ahk`
                if !VerCompare(MyRelease, ver) > 0
                    return

                ;WARNING THE USER OF SETTINGS CHANGES
                if VerCompare(MyRelease, "v2.5.1") > 0 && VerCompare(MyRelease, "v2.5.2") <= 0 ; v2.5.2 brought changes to settings.ini and will reset some values to default
                    tool.Cust("This version (" MyRelease ") may reset some settings back to default`nas there were changes to ``settings.ini``", "3000")
            }
        ;// checking to see if the users OS version is high enough to support dark mode
        darkCheck := this().__checkDark()

        UPDATE          := IniRead(ptf["settings"], "Settings", "update check"             , "true")
        BETAUPDATE      := IniRead(ptf["settings"], "Settings", "beta update check"        , "false")
        DARK            := IniRead(ptf["settings"], "Settings", "dark mode"                , darkCheck)
        RUNSTARTUP      := IniRead(ptf["settings"], "Settings", "run at startup"           , "true")
        CHECKCHECK      := IniRead(ptf["settings"], "Settings", "autosave check checklist" , "true")
        TOOLS           := IniRead(ptf["settings"], "Settings", "tooltip"                  , "true")
        CHECKTOOL       := IniRead(ptf["settings"], "Settings", "checklist tooltip"        , "true")
        WAIT            := IniRead(ptf["settings"], "Settings", "checklist wait"           , "false")
        ADOBE_GB        := IniRead(ptf["settings"], "Adjust",   "adobe GB"                 , 45)
        ADOBE_FS        := IniRead(ptf["settings"], "Adjust",   "adobe FS"                 , 5)
        AUTOMIN         := IniRead(ptf["settings"], "Adjust",   "autosave MIN"             , 5)
        GAMESEC         := IniRead(ptf["settings"], "Adjust",   "game SEC"                 , 2.5)
        MULTI           := IniRead(ptf["settings"], "Adjust",   "multi SEC"                , 5)
        PREMYEARVER     := IniRead(ptf["settings"], "Adjust",   "prem year"                , "2022")
        AEYEARVER       := IniRead(ptf["settings"], "Adjust",   "ae year"                  , "2022")
        premVer         := IniRead(ptf["settings"], "Adjust",   "premVer"                  , "v22.3.1")
        aeVer           := IniRead(ptf["settings"], "Adjust",   "aeVer"                    , "v22.6")
        psVer           := IniRead(ptf["settings"], "Adjust",   "psVer"                    , "v24.0.1")
        resolveVer      := IniRead(ptf["settings"], "Adjust",   "resolveVer"               , "v18.0.4")
        ADOBE           := IniRead(ptf["settings"], "Track",    "adobe temp"               , "")
        WORK            := IniRead(ptf["settings"], "Track",    "working dir"              , "E:\Github\ahk")
        FC              := IniRead(ptf["settings"], "Track",    "first check"              , "false")
        BLOCKAWARE      := IniRead(ptf["settings"], "Track",    "block aware"              , "false")
        MONITORALERT    := IniRead(ptf["settings"], "Track",    "monitor alert"            , 0)
        ;// generate new ini file
        UserPref().__createIni(UserSettings.SettingsDir, UPDATE, BETAUPDATE, DARK, RUNSTARTUP, CHECKCHECK, TOOLS, CHECKTOOL, WAIT, ADOBE_GB, ADOBE_FS, AUTOMIN, GAMESEC, MULTI, PREMYEARVER, AEYEARVER, premVer, aeVer, psVer, resolveVer, ADOBE, WORK, FC, BLOCKAWARE, MONITORALERT, MyRelease)
    }

    /**
     * This function will (on first startup, NOT a refresh of the script) check which version of the script you're running, cross reference that with the latest release on github and alert the user if there is a newer release available with a prompt to download as well as showing a changelog.
     *
     * Which branch the user wishes to check for (either beta, or main releases) can be determined by either right clicking on `My Scripts.ahk` in the task bar and clicking  `Settings`, or by accessing `settingsGUI()` (by default `#F1`)
     *
     * This script will also perform a backup of the users current instance of the "ahk" folder this script resides in and will place it in the `\Backups` folder.
     */
    static updateChecker() {
        if isReload() ;checks if script was reloaded
            return
        MyRelease := this().__getMainRelease()
        ;checking to see if the user wishes to check for updates
        check := UserSettings.update_check
        if check = "stop"
            return
        betaprep := 0
        if UserSettings.beta_update_check = true
            { ;if the user wants to check for beta updates instead, this block will fire
                version := getScriptRelease(true, &changeVer)
                betaprep := 1
            }
        else
            version := getScriptRelease(, &changeVer) ;getting non beta latest release
        if version = 0
            return
        tool.Wait()
        if MyRelease != version
            tool.Cust("Current Installed Version = " MyRelease "`nCurrent Github Release = " version, 5000)
        else
            tool.Cust("You are currently up to date", 2000)
        switch check {
            default:
                errorLog(ValueError("Incorrect value input in ``settings.ini``", -1, check),, 1)
                return
            case false:
                tool.Wait()
                if VerCompare(MyRelease, version) < 0
                    {
                        errorLog(Error("User is using an outdated version of these scripts", -1, version),, {time: 3.0})
                        return
                    }
                tool.Cust("This script will not prompt you with a download/changelog when a new version is available", 3.0)
                return
            case true:
                if VerCompare(MyRelease, version) >= 0
                    return
                ;create gui
                MyGui := tomshiBasic(,, "-Resize +MaxSize600x400 AlwaysOnTop", "Scripts Release " version)
                ;set title
                Title := MyGui.Add("Text", "Section H40 W350", "New Scripts - Release " version)
                Title.SetFont("S15")
                ;set github button
                gitButton := MyGui.Add("Button", "X+20 Y10", "GitHub")
                gitButton.OnEvent("Click", githubButton)

                ;view changelog
                view := MyGui.Add("Button", "Section xs Y+20 h40 W100", "View Latest Changelog")
                view.OnEvent("Click", viewClick)
                viewClick(*)
                {
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
                gitButton.GetPos(&x)
                downloadbutt := MyGui.Add("Button", "Section X" x-85 " ys+13", "Download")
                downloadbutt.OnEvent("Click", Down)
                ;set cancel button
                cancelbutt := MyGui.Add("Button", "Default X+5", "Cancel")
                cancelbutt.OnEvent("Click", closegui)
                ;set "don't prompt again" checkbox
                noprompt := MyGui.Add("Checkbox", "xs-175 Ys-10", "Don't prompt again")
                noprompt.OnEvent("Click", prompt)
                ;set beta checkbox
                betaCheck := (UserSettings.beta_update_check = true)
                           ? MyGui.Add("Checkbox", "Checked1 Y+5", "Check for Beta Updates")
                           : MyGui.Add("Checkbox", "Checked0 Y+5", "Check for Beta Updates")
                betaCheck.OnEvent("Click", prompt)

                if UserSettings.dark_mode = true
                    goDark()
                goDark()
                {
                    dark.titleBar(MyGui.Hwnd)
                    dark.allButtons(MyGui)
                }

                MyGui.Show()
                prompt(guiCtrl, RowNumber) {
                    if InStr(guiCtrl.Text, "prompt")
                        {
                            switch guiCtrl.Value {
                                case 0: UserSettings.update_check := true
                                case 1: UserSettings.update_check := false
                            }
                        }
                    if InStr(guiCtrl.Text, "beta")
                        {
                            switch guiCtrl.Value {
                                case 1: UserSettings.beta_update_check := true
                                case 0: UserSettings.beta_update_check := false
                            }
                            Run(A_ScriptFullPath)
                        }
                }
                githubButton(*) {
                    if WinExist("Tomshiii/ahk")
                        {
                            WinActivate("Tomshiii/ahk")
                            return
                        }
                    Run("https://github.com/tomshiii/ahk/releases")
                }
                down(*) {
                    MyGui.Opt("Disabled -AlwaysOnTop")
                    yousure := MsgBox("If you have modified your scripts, overidding them with this download will result in a loss of data.`nA backup will be performed after downloading and placed in the \Backups folder but it is recommended you do one for yourself as well.`n`nPress Cancel to abort this automatic backup.", "Backup your scripts!", "1 48")
                    if yousure = "Cancel"
                        {
                            MyGui.Opt("-Disabled")
                            return
                        }
                    MyGui.Destroy()
                    downloadLocation := FileSelect("D", , "Where do you wish to download Release " version)
                    if downloadLocation = ""
                        return
                    ;ToolTip("Updated scripts are downloading")
                    TrayTip("Updated scripts are downloading", "Downloading...", 17)
                    SetTimer(HideTrayTip, -5000)
                    HideTrayTip() {
                        TrayTip()
                    }
                    type := ""
                    exeOrzip(filetype, &found)
                    {
                        whr := ComObject("WinHttp.WinHttpRequest.5.1")
                        whr.Open("GET", "https://github.com/Tomshiii/ahk/releases/download/" version "/" version "." filetype, true)
                        whr.Send()
                        ; Using 'true' above and the call below allows the script to remain responsive.
                        whr.WaitForResponse()
                        found := whr.ResponseText
                    }
                    exeOrzip("exe", &found)
                    if found = "Not found"
                        {
                            exeOrzip("zip", &found)
                            if found = "Not found"
                                {
                                    ToolTip("")
                                    MsgBox("Couldn't find the latest release to download")
                                    return
                                }
                            type := "zip"
                        }
                    else
                        type := "exe"

                    if FileExist(downloadLocation "\" version "." type)
                        {
                            file := MsgBox("File already exists.`n`nDo you want to override it?", "File already exists", "4 32 4096")
                            if file = "No"
                                return
                            FileDelete(downloadLocation "\" version "." type)
                        }

                    ; #Start DLFile
                    url := "https://github.com/Tomshiii/ahk/releases/download/" version "/" version "." type
                    dest := downloadLocation "\"

                    DL := DLFile(url,dest,callback)

                    g := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "Download Progress")
                    g.OnEvent("close",(*)=>g.Hide())
                    g.OnEvent("escape",(*)=>g.Hide())
                    g.SetFont(,"Consolas")
                    g.Add("Text","w300 vText1 -Wrap")
                    g.Add("Progress","w300 vProg",0)
                    g.Add("Text","w300 vText2 -Wrap")
                    g.Add("Button","x255 w75 vCancel","Cancel").OnEvent("click",events)
                    g.Add("Button","x255 yp w75 vResume Hidden","Resume").OnEvent("click",events)
                    g.Show()

                    DL.Start()

                    events(ctl,info) {
                        if (ctl.name = "Cancel") {
                            if ctl.text = "Exit" {
                                g.Hide()
                            } else {
                                DL.cancel := true
                                g["Text2"].Text := "Download Cancelled! / Percent: " DL.perc "% / Exit = ESC"
                                g["Resume"].Visible := true
                                g["Cancel"].Visible := false
                            }
                        } else if (ctl.name = "Resume") {
                            g["Resume"].Visible := false
                            g["Cancel"].Visible := true
                            DL.Start() ; note that execution stops here until download is finished or DL.cancel is set to TRUE.
                        }
                    }

                    callback(o:="") { ; g is global in this case
                        g["Text1"].Text := o.file
                        g["Text2"].Text := Round(o.bps/1024) " KBps   /   Percent: " o.perc "%"
                        g["Prog"].Value := o.perc

                        If o.perc = 100
                            {
                                g["Cancel"].Text := "Exit"
                                Run(dest)
                                g.Hide()
                            }
                    }
                    ; #end DLFile

                    if DirExist(A_Temp "\" MyRelease)
                        DirDelete(A_Temp "\" MyRelease, 1)
                    if DirExist(ptf.rootDir "\Backups\Script Backups\" MyRelease)
                        {
                            newbackup := MsgBox("You already have a backup of Release " MyRelease "`nDo you wish to override it and make a new backup?", "Error! Backup already exists", "4 32 4096")
                            if newbackup = "Yes"
                                DirDelete(ptf.rootDir "\Backups\Script Backups\" MyRelease, 1)
                            else
                                {
                                    ToolTip("")
                                    TrayTip()
                                    return
                                }
                        }
                    try {
                        TrayTip("Your current scripts are being backed up!", "Backing Up...", 17)
                        SetTimer(HideTrayTip, -5000)
                        DirCopy(ptf.rootDir, A_Temp "\" MyRelease)
                        DirMove(A_Temp "\" MyRelease, ptf.rootDir "\Backups\Script Backups\" MyRelease, "1")
                        if DirExist(A_Temp "\" MyRelease)
                            DirDelete(A_Temp "\" MyRelease, 1)
                        tool.Cust("Your current scripts have successfully backed up to the '\Backups\Script Backups\" MyRelease "' folder", 3000)
                        if WinExist("Download Progress") && g["Cancel"].Text := "Exit"
                            g.Destroy()
                    } catch as e {
                        tool.Cust("There was an error trying to backup your current scripts", 2000)
                        errorLog(e)
                    }
                    return
                }
                closegui(*) {
                    MyGui.Destroy()
                    return
                }
        }
    }

    /**
     * This function checks to see if it is the first time the user is running this script. If so, they are then given some general information regarding the script as well as a prompt to check out some useful hotkeys.
     */
    static firstCheck() {
        ;The variable names in this function are an absolute mess. I'm not going to pretend like they make any sense AT ALL. But it works so uh yeah.
        if isReload() ;checks if script was reloaded
            return
        MyRelease := this().__getMainRelease()
        if WinExist("Scripts Release ")
            WinWaitClose("Scripts Release ")
        check := UserSettings.first_check
        if check != false ;how the function tracks whether this is the first time the user is running the script or not
            return
        firstCheckGUI := tomshiBasic(,, "-Resize AlwaysOnTop", "Scripts Release " MyRelease)
        ;set title
        MyRelease := MyRelease
        titleText := "Welcome to Tomshi's AHK Scripts : Release " MyRelease
        titleWidth := 430 + ((StrLen(MyRelease)-4)*8)
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
        settingsButton := firstCheckGUI.Add("Button", "X200 Y+8", "Settings")
        settingsButton.OnEvent("Click", settings)
        todoButton := firstCheckGUI.Add("Button", "X+10", "What to Do")
        todoButton.OnEvent("Click", todoPage)
        hotkeysButton := firstCheckGUI.Add("Button", "X+10", "Handy Hotkeys")
        hotkeysButton.OnEvent("Click", hotkeysPage)
        closeButton := firstCheckGUI.Add("Button", "X+10", "Close")
        closeButton.OnEvent("Click", close)

        firstCheckGUI.OnEvent("Escape", close)
        firstCheckGUI.OnEvent("Close", close)
        close(*) {
            UserSettings.first_check := true ;tracks the fact the first time screen has been closed. These scripts will now not prompt the user again
            firstCheckGUI.Destroy()
            RunWait(A_ScriptFullPath)
            return
        }
        todoPage(*) {
            todoGUI()
        }
        hotkeysPage(*) {
            hotkeysGUI()
        }
        settings(*) {
            firstCheckGUI.Opt("Disabled")
            WinSetAlwaysOnTop(0, "Scripts Release " MyRelease)
            settingsGUI()
            WinWait("Settings " MyRelease)
            WinActivate("Settings " MyRelease)
            WinWaitClose("Settings " MyRelease)
            firstCheckGUI.Opt("-Disabled")
        }

        if UserSettings.dark_mode = true
            goDark()
        goDark()
        {
            dark.titleBar(firstCheckGUI.Hwnd)
            dark.allButtons(firstCheckGUI)
        }

        firstCheckGUI.Show("AutoSize")

        ;centering the title
        title.GetPos(,, &width)
        firstCheckGUI.GetClientPos(,, &guiWidth)
        title.Move((guiWidth-width)/2)
    }

    /**
     * This function will (on first startup, NOT a refresh of the script) delete any `\ErrorLog` files older than 30 days
     */
    static oldError() {
        if isReload()
            return
        loop files, ptf.ErrorLog "\*.txt"
        if DateDiff(A_LoopFileTimeCreated, A_now, "Days") < -30
            FileDelete(A_LoopFileFullPath)
    }

    /**
     * This function will (on first startup, NOT a refresh of the script) delete any Adobe temp files when they're bigger than the specified amount (in GB). Adobe's "max" limits that you set within their programs is stupid and rarely chooses to work, this function acts as a sanity check.
     *
     * It should be noted I have created a custom location for `After Effects'` temp files to go to so that they're in the same folder as `Premiere's` just to keep things in one place. You will either have to change this folder directory to the actual default or set it to a similar place
     */
    static adobeTemp() {
        if isReload()
            return
        MyRelease := this().__getMainRelease()
        tool.Wait()
        if WinExist("Scripts Release " MyRelease) ;checks to make sure firstCheck() isn't still running
            WinWaitClose("Scripts Release " MyRelease)
        day := UserSettings.adobe_temp
        if day = A_YDay ;checks to see if the function has already run today
            return

        ;SET HOW BIG YOU WANT IT TO WAIT FOR IN THE `settings.ini` FILE (IN GB) -- IT WILL DEFAULT TO 45GB
        largestSize := UserSettings.adobe_GB

        ;first we set our counts to 0
        CacheSize := 0
        ;then we define some filepaths, MediaCache & PeakFiles are Adobe defaults, AEFiles has to be set within after effects' cache settings
        cacheFolders := Map(
            "MediaCache", A_AppData "\Adobe\Common\Media Cache Files",
            "PeakFiles", A_AppData "\Adobe\Common\Peak Files",
            "AEFiles", A_AppData "\Adobe\Common\AE", ;AGAIN ~~ THIS AE folder to exist you have to set it WITHIN THE AE CACHE SETTINGS, it IS NOT THE DEFAULT
        )
        try {
            ;// adding up the total size of the above listed filepaths
            alerted := false
            for v, p in cacheFolders
                {
                    if !DirExist(p) && alerted = false
                        {
                            errorLog(TargetError(A_ThisFunc "() could not find one or more of the specified folders, therefor making it unable to calculate the total cache size", -1), A_ScriptName "`nLine: " A_LineNumber, {time: 4.0})
                            alerted := true
                            tool.Wait()
                            continue
                        }
                    CacheSize := CacheSize + winget.FolderSize(p, 2)
                }
            if CacheSize = 0
                {
                    tool.Cust("Total Adobe cache size - " CacheSize "/" largestSize "GB", 3.0)
                    goto end
                }
            ;// `winget.FolderSize()` returns it's value in GB, we simply want to round it to 2dp
            tool.Cust("Total Adobe cache size - " Round(CacheSize, 2) "/" largestSize "GB", 3.0)

            ;// if the total is bigger than the set number, we loop those directories and delete all the files
            if CacheSize >= largestSize
                {
                    tool.Cust(A_ThisFunc " is currently deleting temp files", 2.0)
                    try {
                        for v, p in cacheFolders
                            {
                                loop files, p "\*.*", "R"
                                    FileDelete(A_LoopFileFullPath)
                            }
                    }
                }
            end:
        }
        UserSettings.adobe_temp := A_YDay ;tracks the day so it will not run again today
    }

    /**
     * Within my scripts I have a few hard coded references to the directory location I have these scripts. That however would be useless to another user who places them in another location.
     *
     * To combat this scenario, this function on script startup will check the working directory and change all instances of MY hard coded dir to the users current working directory.
     *
     * This script will take note of the users A_WorkingDir and store it in `A_MyDocuments \tomshi\settings.ini` and will check it every launch to ensure location variables are always updated and accurate
    */
    static locationReplace() {
        if isReload()
            return
        tool.Wait()
        checkDir := UserSettings.working_dir
        if checkDir = A_WorkingDir
            return

        funcTray := "'" A_ThisFunc "()" "'" A_Space
        found := false
        tomshiOrUser := "t"
        loop files, A_WorkingDir "\*.ahk", "R"
            {
                if A_LoopFileName = "switchTo.ahk" || A_LoopFileName = "GUIs.ahk" || A_LoopFileName = "Startup.ahk"
                    continue
                read := FileRead(A_LoopFileFullPath)
                if InStr(read, "E:\Github\ahk", 1)
                    {
                        found := true
                        break
                    }
            }
        if found = false
            {
                loop files, A_WorkingDir "\*.ahk", "R"
                    {
                        if A_LoopFileName = "switchTo.ahk" || A_LoopFileName = "GUIs.ahk" || A_LoopFileName = "Startup.ahk"
                            continue
                        read := FileRead(A_LoopFileFullPath)
                        if InStr(read, checkDir, 1)
                            {
                                found := true
                                tomshiOrUser := "u"
                                break
                            }
                    }
            }
        if found = false
            return
        TrayTip(funcTray "is attempting to replace references to installation directory with user installation directory:`n" A_WorkingDir,, 17)
        SetTimer(end, -2000)
        if tomshiOrUser = "t"
            dir := "E:\Github\ahk"
        else if tomshiOrUser = "u"
            dir := checkDir
        loop files, A_WorkingDir "\*.ahk", "R"
            {
                if A_LoopFileName = "switchTo.ahk" || A_LoopFileName = "GUIs.ahk" || A_LoopFileName = "Startup.ahk"
                    continue
                read := FileRead(A_LoopFileFullPath)
                if InStr(read, dir, 1)
                    {
                        read2 := StrReplace(read, dir, A_WorkingDir)
                        FileDelete(A_LoopFileFullPath)
                        FileAppend(read2, A_LoopFileFullPath)
                    }
            }
        end() {
            TrayTip(funcTray "has finished attempting to replace references to the installation directory.`nDouble check " "'" "location :=" "'" " variables to sanity check",, 1)
        }
        UserSettings.working_dir := A_WorkingDir
        RunWait(A_ScriptFullPath)
    }

    /**
     * This function will add right click tray menu items to "My Scripts.ahk" to toggle checking for updates as well as accessing a GUI to modify script settings
     */
    static trayMen() {
        check := UserSettings.update_check
        A_TrayMenu.Insert("7&") ;adds a divider bar
        A_TrayMenu.Insert("8&", "Settings", (*) => settingsGUI())
        A_TrayMenu.Insert("9&", "Active Scripts", (*) => activeScripts())
        A_TrayMenu.Insert("10&", "Check for Updates", checkUp)
        if check =  true
            A_TrayMenu.Check("Check for Updates")
        checkUp(*)
        {
            check := UserSettings.update_check ;has to be checked everytime you wish to toggle
            switch check {
                case true:
                    UserSettings.update_check := false
                    A_TrayMenu.Uncheck("Check for Updates")
                case false:
                    UserSettings.update_check := true
                    A_TrayMenu.Check("Check for Updates")
            }
        }
    }

    /**
     * This class is a collection of information relating to external lib files used by my scripts.
     */
    class libs {
        static init() => this().__defControls(this)
        __defControls(cls) {
            for v in this.objs {
                for name, val in v.OwnProps() {
                    cls.%name%.Push(val)
                }
            }
        }
        webView2 := {
            name: "WebView2",                                   url: "https://raw.githubusercontent.com/thqby/ahk2_lib/master/WebView2/WebView2.ahk",
            scriptPos: ptf.lib "\Other\WebView2"
        }
        comVar := {
            name: "ComVar",                                     url: "https://raw.githubusercontent.com/thqby/ahk2_lib/master/ComVar.ahk",
            scriptPos: ptf.lib "\Other"
        }
        SevenZip := {
            name: "SevenZip",                                   url: "https://raw.githubusercontent.com/thqby/ahk2_lib/master/7Zip/SevenZip.ahk",
            scriptPos: ptf.lib "\Other\7zip"
        }
        JSON := {
            name: "JSON",                                       url: "https://raw.githubusercontent.com/thqby/ahk2_lib/master/JSON.ahk",
            scriptPos: ptf.lib "\Other"
        }

        objs := [this.webView2, this.comVar, this.SevenZip, this.JSON]
        static name        := []
        static url         := []
        static scriptPos   := []
    }

    /**
     * This function will loop through `class libs {` and ensure that all libs are up to date. This function will not fire on a reload
     */
    static libUpdateCheck() {
        if isReload()
            return
        if !checkInternet()
            return
        check := UserSettings.update_check
        if check = "stop"
            return
        this.libs.init()
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
        loop this.libs.name.Length {
            localVersion := localVer(this.libs.scriptPos[A_Index] "\" this.libs.name[A_Index] ".ahk")
            latestVer := getString(this.libs.url[A_Index])
            if latestVer.version = ""
                { ;if the lib doesn't have a @version tag, we'll instead compare the entire file against the local copy and override it if there are differences
                    if localVersion.script !== latestVer.script
                        {
                            tool.Wait()
                            Download(this.libs.url[A_Index], this.libs.scriptPos[A_Index] "\" this.libs.name[A_Index] ".ahk")
                            tool.Cust(this.libs.name[A_Index] ".ahk lib file updated")
                        }
                    continue
                }
            if latestVer.version = 0
                continue
            if VerCompare(latestVer.version, localVersion.version) > 0
                {
                    tool.Wait()
                    Download(this.libs.url[A_Index], this.libs.scriptPos[A_Index] "\" this.libs.name[A_Index] ".ahk")
                    tool.Cust(this.libs.name[A_Index] ".ahk lib file updated to v" latestVer.version)
                    continue
                }
        }
        tool.Wait()
        tool.Cust("libs up to date")
    }

    /**
     * This function will check for a new version of AHK by comparing the latest version to the users currently running version. If a newer version is available, it will prompt the user.
     */
    static updateAHK() {
        if isReload() ;checks if script was reloaded
            return
        settingsCheck := UserSettings.update_check
        if settingsCheck = "stop"
            return
        latestVer := getHTML("https://www.autohotkey.com/download/2.0/version.txt")
        if latestVer = 0
            return
        if VerCompare(latestVer, A_AhkVersion) <= 0
            {
                tool.Wait()
                tool.Cust("AHK up to date")
                return
            }
        if settingsCheck = false
            {
                tool.Wait()
                tool.Cust("A new version of AHK is available")
                return
            }
        marg := 8
        ;// define gui
        mygui := tomshiBasic(,,, "AHK v" latestVer " available")
        mygui.AddText(, "A newer version of AHK (v" latestVer ") is available`nDo you wish to download it?")

        ;// run installer checkbox
        runafter := mygui.Add("Checkbox", "Section y+10 x" marg, "Run after download?")
        checkboxValue := 0
        runafter.OnEvent("Click", checkVal)
        ;// buttons
        yesButt := mygui.Add("Button", "ys-10 x+25", "Yes")
        yesButt.OnEvent("Click", downahk)
        nobutt := mygui.Add("Button", "x+5", "No")
        nobutt.OnEvent("Click", noclick)

        mygui.Show()
        noclick(*) => mygui.Destroy()
        checkVal(*) => checkboxValue := runafter.Value
        downahk(*) {
            downloadLocation := FileSelect("D", , "Where do you wish to download the latest AHK release")
            if downloadLocation = ""
                return
            if FileExist(downloadLocation "\ahk-v2.exe")
                {
                    file := MsgBox("File already exists.`n`nDo you want to override it?", "File already exists", "4 32 4096")
                    if file = "No"
                        return
                    FileDelete(downloadLocation "\ahk-v2.exe")
                }
            mygui.Destroy()
            ; #Start DLFile
            url := "https://www.autohotkey.com/download/ahk-v2.exe"
            dest := downloadLocation "\"

            DL := DLFile(url,dest,callback)

            g := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "Download Progress")
            g.OnEvent("close",(*)=>g.Hide())
            g.OnEvent("escape",(*)=>g.Hide())
            g.SetFont(,"Consolas")
            g.Add("Text","w300 vText1 -Wrap")
            g.Add("Progress","w300 vProg",0)
            g.Add("Text","w300 vText2 -Wrap")
            g.Add("Button","x255 w75 vCancel","Cancel").OnEvent("click",events)
            g.Add("Button","x255 yp w75 vResume Hidden","Resume").OnEvent("click",events)
            g.Show()

            DL.Start()

            events(ctl,info) {
                if (ctl.name = "Cancel") {
                    if ctl.text = "Exit" {
                        g.Hide()
                    } else {
                        DL.cancel := true
                        g["Text2"].Text := "Download Cancelled! / Percent: " DL.perc "% / Exit = ESC"
                        g["Resume"].Visible := true
                        g["Cancel"].Visible := false
                    }
                } else if (ctl.name = "Resume") {
                    g["Resume"].Visible := false
                    g["Cancel"].Visible := true
                    DL.Start() ; note that execution stops here until download is finished or DL.cancel is set to TRUE.
                }
            }

            callback(o:="") { ; g is global in this case
                g["Text1"].Text := o.file
                g["Text2"].Text := Round(o.bps/1024) " KBps   /   Percent: " o.perc "%"
                g["Prog"].Value := o.perc

                If o.perc = 100
                    {
                        g["Cancel"].Text := "Exit"
                        g.Hide()
                    }
            }
            ; #end DLFile

            switch checkboxValue {
                case 1:  Run(downloadLocation "\ahk-v2.exe")
                default: Run(downloadLocation)
            }
        }
    }

    /**
     * This function alerts the user when their monitor layout has changed.
     * This is important as it can seriously mess up any scripts that contain hard coded pixel coords
     */
    static monitorAlert() {
        save := false

        ;// get initial values
        MonitorCount := MonitorGetCount()
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
                    UserSettings.monitor_alert := A_YDay
                    return 0
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
                if UserSettings.monitor_alert = A_YDay
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
            left := IniRead(ptf["monitorsINI"], A_Index, "Left")
            top := IniRead(ptf["monitorsINI"], A_Index, "Top")
            right := IniRead(ptf["monitorsINI"], A_Index, "Right")
            bottom := IniRead(ptf["monitorsINI"], A_Index, "Bottom")
            if( ;// if nothing has changed, continue
                left = WL &&
                top = WT &&
                right = WR &&
                bottom = WB )
                continue
            ;// if the user hasn't been alerted yet, they will be alerted now
            if !save {
                if !alrtmsgbox()
                    return
                save := true
            }
            ;// log new values
            write(WL, WT, WR, WB)
        }
    }
}