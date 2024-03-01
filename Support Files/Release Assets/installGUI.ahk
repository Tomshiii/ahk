#requires AutoHotkey v2
;// This file is the file that gets turned into the release.exe that is sent out as a release

;// setting up
SetWorkingDir(A_ScriptDir) ;! A_ScriptDir in this case is the users install location
A_ScriptName := "yes.value"
;@Ahk2Exe-SetMainIcon E:\Github\ahk\Support Files\Icons\myscript.ico
;@Ahk2Exe-SetCompanyName Tomshi
;@Ahk2Exe-SetCopyright Copyright (C) 2024
;@Ahk2Exe-SetDescription Installer file for Tomshi's ahk github repo

;// setting version
;@Ahk2Exe-SetVersion yes.value

;// forces Admin perms
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

;// initiate GUI instance
instance := installGUI()
instance.Show('w' instance.TotalWidth)


class installGUI extends Gui {
    __New() {
        super.__New("+Resize +MinSize100x170 -MinimizeBox -MaximizeBox", "Install Tomshi AHK")
        SetTimer(() => this.Opt("-Resize"), -10)
        this.SetFont("S11")
        ;nofocus
        this.AddButton("Default X8 Y0 w0 h0", "_")

        ;from `C:\Program Files\AutoHotkey\UX\ui-setup.ahk`
        DllCall('uxtheme\SetWindowThemeAttribute', 'ptr', this.hwnd, 'int', 1 ; WTA_NONCLIENT
                    , 'int64*', 3 | (3<<32), 'int', 8) ; WTNCA_NODRAWCAPTION=1, WTNCA_NODRAWICON=2
        this.AddText('x0 y0 w' this.TotalWidth ' h60 ' this.TitleBack)
        this.Add("Text", "X105 y16 " this.TitleFore " " this.TitleBack " Section W250 H35 vTopText Center", "Install Tomshi's AHK Scripts.`nPlease select your installation directory.`n")
        this.AddText('x-4 y60 w' this.TotalWidth+4 ' h125 0x1000 -Background Section')

        ;// buttons for later - need to be after the BG section above or the buttons will be invisible after moving them until the user hovers over them
        this.AddButton("x0 y0 w0 h0 Hidden vInstallingButton", "Installing")
        this.AddButton("x0 y0 w0 h0 Hidden vEmptyDir", "Change Dir")
        ;// rest of GUI
        this.AddText("xs+25 ys+20 Section", "Choose Installation Directory:")
        this.AddEdit("-Wrap ReadOnly r1 vInstallDir w300", this.InstallDir)
        this.AddButton("x+10 yp-2 vChangeDir", "Change Dir").OnEvent("Click", (*) => this.__changeDir())
        this.AddButton("y+5 xp+21 w65 vInstallButton", "Install").OnEvent("Click", (*) => this.__Install())
        SendMessage(0x160C,, true, this["InstallButton"].hwnd, this) ; BCM_SETSHIELD := 0x160C
        this.AddProgress("Smooth xs yp+3 w300 vProgress Section")

        ;// moving temp buttons over current buttons for use later
        __changeMove("InstallButton", "InstallingButton")
        __changeMove("ChangeDir", "EmptyDir")
        __changeMove(whichPos, whichMove) {
            this[whichPos].GetPos(&x, &y, &width, &height)
            this[whichMove].Move(x, y, width, height)
        }
    }

        TitleBack  := 'BackgroundWhite'
        TitleFore  := 'c3F627F'
        TotalWidth := 450

        InstallDir    := A_WorkingDir
        InstallExist  := false
        progress      := 0
        isDetected    := false
        settingsDir   := A_MyDocuments "\tomshi\"
        settingsCheck := false
        hasAttempted  := false
        names := Map("Backups", 1, "changelog.md", 1, "checklist.ahk", 1, "lib", 1,
                    "LICENSE", 1, "Logs", 1, "My Scripts.ahk", 1, "PC Startup", 1,
                    "QMK Keyboard.ahk", 1, "README.md", 1, "releases", 1, "Resolve_Example.ahk", 1,
                    "Stream", 1, "Streamdeck AHK", 1, "Support Files", 1, "Timer Scripts", 1,
                )
        installFiles := Map(
            "CreateSymLink",        "{1}\Support Files\Release Assets\CreateSymLink.ahk",
            "generateAdobeSym",     "{1}\Support Files\Release Assets\Adobe SymVers\generateAdobeSym.ahk"
        )

        /** this function handles the user changing the chosen installation directory */
        __changeDir(*) {
            if !changeDir := FileSelect("D2", this.InstallDir, "Select Installation Directory")
                return
            this.InstallDir := changeDir
            this["InstallDir"].Text := changeDir
        }

        /** this function handles adding the edit box to display the logs as well as increasing the height of the gui */
        __addLogEditBox() {
            this.GetPos(&posX, &posY, &posWidth, &posHeight)
            this.Move(posX, posY, posWidth, posHeight+100)
            this.AddEdit("ReadOnly Multi BackgroundWhite -Wrap w400 h100 xs ys+48 vLogEdit")
        }

        /**
         * this function handles adding an entry to the log edit box.
         * @param {String} entry the text you wish to add to the top of the log edit box. Simply add your entry, do not include the beginning time or any "//"
         */
        __addLogEntry(entry) {
            beginning := A_Hour ":" A_Min ":" A_Sec " // "
            this["LogEdit"].value := (this["LogEdit"].value = "") ? beginning entry : beginning entry "`n" this["LogEdit"].value
        }

        /**
         * this function adds value to the progress bar over a set period of time using `SetTimer()`. it will add a value of `1` per `delay`
         * @param {Integer} amount the amount you wish to add in total to the progress bar
         * @param {Integer} delay the amount of delay between each addition to the progress bar
         */
        __slowAddProgress(amount, delay) {
            Critical
            SetTimer(addAmount.bind(this, amount, this["Progress"].value), delay)
            addAmount(guiObj, amount, original, *) {
                Critical
                if guiObj["Progress"].value < original + amount
                    guiObj["Progress"].value += 1
                else
                    SetTimer(, 0)
            }
        }

        /**
         * this function sets the value of the progress bar
         * @param {Integer} amount the number value you wish to set the progress bar to
         * @param {Boolean} [relative=false] determine whether you wish to relatively set the value or hard set it to your defined value
         */
        __setProgress(amount, relative := false) {
            this["Progress"].value := (relative = true) ? this["Progress"].value + amount  : amount
        }

        /** this function swaps the `Install` & `ChangeDir` buttons between ones that have `OnEvent` set and one that doesn't. Each subsequent call will swap them again */
        __changeInstallButton(which := true) {
            switch which {
                case false:
                    this["InstallingButton"].Opt("Hidden")
                    this["InstallButton"].Opt("-Hidden")

                    this["EmptyDir"].Opt("Hidden")
                    this["ChangeDir"].Opt("-Hidden")
                default:
                    this["InstallButton"].Opt("Hidden")
                    this["InstallingButton"].Opt("-Hidden")

                    this["ChangeDir"].Opt("Hidden")
                    this["EmptyDir"].Opt("-Hidden")
            }
            sleep 100
        }

        /** this function handles including the files in the .exe as well as extracting them when the user runs the installation process */
        __installDump() {
            __after(name) {
                this.__addLogEntry("extracting ``" name "``")
                this.__slowAddProgress(5, 100)
            }
            FileInstall("E:\Github\ahk\releases\release\yes.value.zip", A_WorkingDir "\yes.value.zip", 1)
            __after("yes.value.zip")
        }

        /** this function handles deleting the left over files from installation */
        __deleteInstallFiles() {
            __after(name) {
                this.__addLogEntry("deleting ``" name "``")
                this.__slowAddProgress(2, 100)
            }
            FileDelete(A_WorkingDir '\yes.value.zip')
            __after("yes.value.zip")
            sleep 100
        }

        /**
         * This function creates a comObject to unzip a folder.
         * @link Original function from @MiM in ahk discord: https://discord.com/channels/115993023636176902/1068688397947900084/1068710942327722045 (link may die)
         * @param {String} zipPath the path location of a zip folder you wish to unzip
         * @param {String} unzippedPath the path location you wish the contents of the zip folder to get extracted. If this directory does not already exist, it will be created.
         * @return {Boolean} On success this function will return `true`.
         */
        __unzip(zipPath, unzippedPath) {
            SplitPath(zipPath,,, &checkZipPathExt)
            if checkZipPathExt != "zip"
                throw TypeError("Requested folder is not a ZIP folder", -2, zipPath)
            SplitPath(unzippedPath,, &unzippedPathDir)
            if !DirExist(unzippedPathDir)
                DirCreate(unzippedPathDir)
            psh := ComObject("Shell.Application")
            psh.Namespace(unzippedPath).CopyHere(psh.Namespace(zipPath).items, 4|16)
            return true
        }

        /** this function handles the entire install sequence of the installer */
        __Install(*) {
            amount := 0
            this.hasAttempted := true
            if FileExist(A_MyDocuments "\tomshi\settings.ini")
                this.settingsCheck := true
            this.__changeInstallButton(true)
            if !this.hasAttempted {
                this.__addLogEditBox()
            }
            SplitPath(this.InstallDir, &FinalDir)
            if FinalDir !== "Tomshi AHK" {
                this.InstallDir := this.InstallDir "\Tomshi AHK"
                this.InstallExist := (DirExist(this.InstallDir)) ? true : false
                if !this.InstallExist {
                    this.__addLogEntry("creating install directory")
                    DirCreate(this.InstallDir)
                }
            }
            loop files this.InstallDir "\*", "FD" {
                if this.names.Has(A_LoopFileName) && this.settingsCheck = true && amount++ < 5
                    continue
                else if amount >= 5 {
                    if MsgBox("Current install of Tomshi's repo potentially detected. Attempting to install over the current installation may break your install or remove custom changes.`n`nDo you wish to continue?", "Incorrect Install Path", "4 48 4096") = "No" {
                        this.__changeInstallButton(false)
                        return
                    }
                    this.isDetected := true
                    break
                }
            }
            this.__slowAddProgress(10, 100)
            sleep 300
            if this.isDetected = true && FileExist(this.settingsDir "\settings.ini") {
                this.__addLogEntry("backing up previous install")
                oldVer := IniRead(this.settingsDir "\settings.ini", "Track", "version", A_MM "_" A_DD)
                if !DirExist(this.settingsDir "\Backups\") {
                    this.__addLogEntry("creating backup folder")
                    DirCreate(this.settingsDir "\Backups\")
                }
                this.__addLogEntry("backing up: " this.InstallDir)
                DirCopy(this.InstallDir, this.settingsDir "\Backups\" oldVer)
                this.__addLogEntry("backup complete: " this.settingsDir "\Backups\" oldVer)
                this.__setProgress(10)
            }
            if A_IsCompiled = 1
                this.__installDump()
            this.__setProgress(35) ;// hard setting to 35 here

            this.__slowAddProgress(30, 250)
            this.__addLogEntry("unzipping release contents")
            if this.__unzip(A_WorkingDir "\yes.value.zip", this.InstallDir) != true {
                this.__setProgress(100)
                this["Progress"].opt("CRed")
                throw(Error("Unable to Unzip install files", -1))
            }
            if this.settingsCheck = false && FileExist(this.InstallDir "\Support Files\Release Assets\baseLineSettings.ahk") {
                this.__slowAddProgress(5, 200)
                this.__addLogEntry("generating default ``settings.ini``")
                Run(this.InstallDir "\Support Files\Release Assets\baseLineSettings.ahk")
            }
            this.__deleteInstallFiles()
            this.__setProgress(70)
            if FileExist(Format(this.installFiles["CreateSymLink"], this.InstallDir)) {
                this.__addLogEntry("generating lib symLinks")
                try RunWait(Format(this.installFiles["CreateSymLink"], this.InstallDir))
                this.__setProgress(80)
            }
            if FileExist(Format(this.installFiles["generateAdobeSym"], this.InstallDir)) {
                this.__addLogEntry("generating adobe symlinks")
                try RunWait(Format(this.installFiles["generateAdobeSym"], this.InstallDir))
                this.__setProgress(90)
            }

            ;// if did a backup read ksa/options.ini from backup

            ;//! finished
            this.__setProgress(100)
            this["Progress"].opt("CLime")

            ;// run next GUI and destroy this one
            this.GetPos(&oldX, &oldY, &oldWidth, &oldHeight)
            Run(this.InstallDir "\Support Files\Release Assets\",,, &PID)
            try WinMove(oldX, oldY, oldWidth, oldHeight, "ahk_pid " PID)
            this.Destroy()
        }
}

;// steps

;// - check if any scripts already exist in the target directory
;//     - If they do, alert the user that attempting to override a previous install will probably break things
;// - Extract files from within exe
;// - Unzip any files
;// - Generate a settings.ini file if it doesn't exist
;// - Generate SymLinks & adobeVers
;// - If script noted an old install, Attempt to copy data from `ksa.ini` and streamdeck `options.ini` backups