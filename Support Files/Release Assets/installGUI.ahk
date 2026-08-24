/************************************************************************
 * @description This script is the file that gets turned into the release.exe that is sent out as a release
 * @author tomshi
 * @date 2026/08/24
 * @version 1.1.26
 ***********************************************************************/
#Requires AutoHotkey v2
;// anything labelled as "yes.value" gets replaced during `generateUpdate.ahk`
;// setting up
SetWorkingDir(A_ScriptDir) ;! A_ScriptDir in this case is the users install location
A_ScriptName := "yes.value - Tomshi Installer"
;@Ahk2Exe-SetMainIcon E:\Github\ahk\Support Files\Icons\myscript.ico
;@Ahk2Exe-SetCompanyName Tomshi
;@Ahk2Exe-SetCopyright Copyright (C) 2025
;@Ahk2Exe-SetDescription Installer file for Tomshi's ahk github repo

;// setting version
;@Ahk2Exe-SetVersion yes.value

;// initiate GUI instance
instance := installGUI()
instance.Show('w' instance.TotalWidth " Center")


class installGUI extends Gui {
    __New() {
        this.ahkPath := this.__findAHK()
        if !this.ahkPath {
            throw MemberError("AHK is not installed.")
        }
        this.WorkDir := (StrLen(A_WorkingDir) = 3 && SubStr(A_WorkingDir, 2, 2) = ":\") ? SubStr(A_WorkingDir, 1, 1) ":" : A_WorkingDir
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
        try tryRead := (FileExist(this.prevInstall)) ? FileRead(this.prevInstall) : ""
        catch {
            tryRead := ""
        }
        opt := (FileExist(this.prevInstall) && (DirExist(tryRead))) ? "+Disabled" : ""
        if !opt && this.isPatcher = true {
            throw TargetError("Previous install not detected. Please try the full installer.")
        }
        this.AddEdit("-Wrap ReadOnly r1 vInstallDir w300 " opt, (!opt) ? this.InstallDir : tryRead)
        this.AddButton("x+10 yp-2 vChangeDir " opt, "Change Dir").OnEvent("Click", (*) => this.__changeDir())
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

        ahkPath       := false
        InstallDir    := (StrLen(A_WorkingDir) = 3 && SubStr(A_WorkingDir, 2, 2) = ":\") ? SubStr(A_WorkingDir, 1, 1) ":\Tomshi AHK\" : A_WorkingDir "\Tomshi AHK\"
        WorkDir       := ""
        progress      := 0
        isDetected    := false
        settingsDir   := A_MyDocuments "\tomshi\"
        libRootDir    := A_AppData "\tomshi\"
        prevVer       := false
        prevInstall   := this.libRootDir "\installDir"
        prevInstallLoc := ""
        isPatcher := false

        hasAttempted  := false

        tempLog := A_Temp "\tomshi\" A_YYYY "_" A_MM "_" A_DD "_log.txt"

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
            SplitPath(this.tempLog,, &tempdir)
            if !DirExist(tempdir)
                DirCreate(tempdir)
            FileAppend(beginning entry "`n", this.tempLog)
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
        __installDump(patch := false) {
            this.__addLogEntry(Format("extracting ``{}``", "yes.value.zip"))
            if patch = true {
                if !DirExist(A_Temp "\tomshi\yes.value")
                    DirCreate(A_Temp "\tomshi\yes.value")

                FileInstall("E:\Github\ahk\releases\release\yes.value.zip", A_Temp "\tomshi\yes.value.zip", 1)
                return
            }
            FileInstall("E:\Github\ahk\releases\release\yes.value.zip", this.WorkDir "\yes.value.zip", 1)
        }

        /** this function handles deleting the left over files from installation */
        __deleteInstallFiles() {
            __after(name) {
                this.__addLogEntry("deleting ``" name "``")
            }
            __after("yes.value.zip")
            if FileExist(this.WorkDir '\yes.value.zip')
                FileDelete(this.WorkDir '\yes.value.zip')
            __after("nodejs.msi")
            if FileExist(this.InstallDir '\nodejs.msi')
                FileDelete(this.InstallDir '\nodejs.msi')
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
            ; Ensure destination directory exists
            if !DirExist(unzippedPath)
                DirCreate(unzippedPath)

            ; Shell COM needs fully resolved, backslash paths and the dirs to already exist
            zipPath       := RTrim(zipPath, "\")
            unzippedPath  := RTrim(unzippedPath, "\")

            psh := ComObject("Shell.Application")

            zipFolder := psh.Namespace(zipPath)
            if !IsObject(zipFolder)
                throw TargetError("Shell could not open zip path: " zipPath, -1)

            destFolder := psh.Namespace(unzippedPath)
            if !IsObject(destFolder)
                throw TargetError("Shell could not open destination path: " unzippedPath, -1)

            destFolder.CopyHere(zipFolder.Items(), 4|16)

            ;// copyHere is async - wait for extraction to complete
            loop 60 {
                sleep 500
                if psh.Namespace(unzippedPath).Items().Count >= zipFolder.Items().Count
                    break
            }

            return true
        }

        __patchInstall() {
            try RunWait(this.prevInstallLoc "\Support Files\closeAll.ahk 1 " A_ScriptName)
            if !DirExist(A_Temp "\tomshi\yes.value")
                throw TargetError
            patchDir := A_Temp "\tomshi\yes.value"
            this.__addLogEntry("unzipping release contents")
            if this.__unzip(A_Temp "\tomshi\yes.value.zip", patchDir) != true {
                try DirDelete(A_Temp "\tomshi\yes.Value", true)
                try FileDelete(this.InstallDir "\yes.value.zip")
                this.__setProgress(100)
                this["Progress"].opt("CRed")
                throw(Error("Unable to Unzip install files. Please try the installation again.", -1))
            }
            this.__setProgress(40)
            if !this.nodeInstalled() && !FileExist(patchDir "\yes.value\nodejs.msi") {
                throw TargetError("Node is not installed and installer cannot be found. Try the full installer.")
            }
            if !this.nodeInstalled() && FileExist(patchDir "\yes.value\nodejs.msi") {
                this.__installNode(patchDir "\yes.value\nodejs.msi")
            }
            this.__setProgress(50)
            if FileExist(patchDir "\yes.value\nodejs.msi")
                FileDelete(patchDir "\yes.value\nodejs.msi")
            loop files patchDir "\*", "FD" {
                this.__addLogEntry("moving: " A_LoopFileName)
                if A_LoopFileName = "lib" {
                    if DirExist(A_Appdata "\tomshi\lib")
                        DirDelete(A_Appdata "\tomshi\lib", true)
                    DirMove(A_LoopFileFullPath, A_Appdata "\tomshi\lib", 2)
                    continue
                }
                SplitPath(A_LoopFileFullPath, &name, &dir)
                (InStr(A_LoopFileAttrib, "D")) ? DirMove(A_LoopFileFullPath, this.InstallDir "\" name, 2) : FileMove(A_LoopFileFullPath, this.InstallDir "\" name, true)
            }
            this.__setProgress(60)
            this.__baselineSettings()
            this.__setProgress(70)
            this.__runCoreFunc()
            this.__setProgress(80)
            if !this.__installPremRemote()
                this.__addLogEntry("Failed to install PremiereRemote")
            this.__setProgress(90)
            this.__adjustVersion()

            DirDelete(A_Temp "\tomshi", true)

            ;//! finished
            this.__setProgress(100)
            this["Progress"].opt("CLime")
            this.Destroy()
            return
        }

        /** this function handles the entire install sequence of the installer */
        __Install(*) {
            if DirExist(A_Temp "\tomshi")
                DirDelete(A_Temp "\tomshi", true)
            if !DirExist(A_AppData "\tomshi")
                DirCreate(A_AppData "\tomshi")
            if FileExist(A_Appdata "\tomshi\version") {
                readVer := FileRead(A_Appdata "\tomshi\version")
                switch {
                    case InStr(readVer, "beta"):  readVer := StrReplace(readVer, "beta", "-b.")
                    case InStr(readVer, "alpha"): readVer := StrReplace(readVer, "alpha", "-a.")
                    case InStr(readVer, "pre"):   readVer := StrReplace(readVer, "pre", "-p.")
                }
                this.prevVer := readVer
                compareVers := VerCompare(this.prevVer, "yes.value")
                switch {
                    case (compareVers > 0): ;// installed version is newer
                        throw PropertyError("Installed version is already newer.")
                    case (compareVers = 0):
                        throw PropertyError("This version is already installed.")
                }
                FileDelete(A_Appdata "\tomshi\version")
            }
            FileAppend("yes.value", A_Appdata "\tomshi\version")
            try this.prevInstallLoc := FileRead(this.prevInstall)
            catch {
                this.prevInstallLoc := ""
            }
            installDirExist := (DirExist(this.prevInstallLoc) = true) ? true : false
            if FileExist(A_Appdata "\tomshi\installDir") {
                FileDelete(A_Appdata "\tomshi\installDir")
            }
            installPathStr := (SubStr(this.InstallDir, -1, 1) = "\") ? SubStr(this.InstallDir, 1, StrLen(this.InstallDir)-1) : this.InstallDir
            FileAppend(installPathStr, A_Appdata "\tomshi\installDir")
            if !this.hasAttempted {
                this.__addLogEditBox()
            }
            this.hasAttempted := true
            this.__changeInstallButton(true)
            if !DirExist(this.InstallDir) {
                this.__addLogEntry("creating install directory")
                DirCreate(this.InstallDir)
            }
            sleep 300
            this.__setProgress(10)
            if (installDirExist && (this.prevVer != false && VerCompare(this.prevVer, "v2.18.0") > 0)) || (this.isPatcher = true) {
                this.__installDump(true)
                this.__patchInstall()
                return
            }
            this.__installDump()
            this.__setProgress(30)
            this.__addLogEntry("unzipping release contents")
            if this.__unzip(this.WorkDir "\yes.value.zip", this.InstallDir) != true {
                this.__setProgress(100)
                this["Progress"].opt("CRed")
                throw(Error("Unable to Unzip install files", -1))
            }
            this.__setProgress(40)
            ;// move lib folder
            this.__addLogEntry("moving lib files")
            DirMove(this.InstallDir "\lib", A_AppData "\tomshi\lib", 2)
            dirMoved := false
            loop 10 {
                if !DirExist(A_AppData "\tomshi\lib") {
                    sleep 500
                    continue
                }
                dirMoved := true
                break
            }
            this.__setProgress(50)
            if !dirMoved
                throw TargetError("Failed to move lib folder")
            this.__baselineSettings()
            this.__setProgress(60)
            if !this.nodeInstalled() {
                this.__installNode(this.InstallDir "\nodejs.msi")
            }
            this.__setProgress(70)
            this.__deleteInstallFiles()
            this.__runCoreFunc()
            this.__setProgress(80)
            if !this.__installPremRemote()
                this.__addLogEntry("Failed to install PremiereRemote")
            this.__setProgress(85)

            ;// set current adobe versions in settings.ini
            this.__addLogEntry("setting current adobe versions in settings.ini")
            try RunWait(this.InstallDir "\Support Files\Release Assets\Install Packages\InstallPremOverride.ahk")
            sleep 1000
            this.__setProgress(90)
            ;// creating initialise shortcut
            startupScript := this.InstallDir "\PC Startup\Initialise.ahk"
            ; FileCreateShortcut(startupScript, A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\Initialise.ahk - Shortcut.lnk")
            this.__adjustVersion()

            ;//! finished
            this.__setProgress(100)
            this["Progress"].opt("CLime")
            this.Destroy()
        }

        /** This function cuts repeat code for dealing with some first time settings */
        __runSettingsInstall(filename, catchText, workingDir := "") {
            try RunWait(filename, workingDir)
            catch
                this.__addLogEntry(catchText)
        }

        __baselineSettings() {
            this.__addLogEntry("handling settings.ini file")
            this.__runSettingsInstall(this.InstallDir "\Support Files\Release Assets\Install Packages\baseLineSettings.ahk", "failed to generate updated settings.ini file")
        }

        __adjustVersion() {
            if FileExist(A_MyDocuments "\toshi\settings.ini")
                IniWrite("yes.value", A_MyDocuments "\toshi\settings.ini", "Track", "version")
        }

        __installPremRemote() {
            if !FileExist(this.InstallDir "\Support Files\Release Assets\Install Packages\installPremRemote.ahk") {
                throw TargetError("Couldn't find installPremRemote.ahk")
            }
            this.__addLogEntry("installing PremiereRemote")
            extensionsPath := A_AppData "\Adobe\CEP\extensions"
            if !DirExist(extensionsPath) {
                try DirCreate(extensionsPath)
                catch {
                    return false
                }
            }
            if FileExist(this.InstallDir "\premExtract.zip") && DirExist(extensionsPath) {
                try FileMove(this.InstallDir "\premExtract.zip", extensionsPath "\premExtract.zip", true)
                catch {
                    return false
                }
            }
            if FileExist(this.InstallDir "\aeExtract.zip") && DirExist(extensionsPath) {
                try FileMove(this.InstallDir "\aeExtract.zip", extensionsPath "\aeExtract.zip", true)
                catch {
                    return false
                }
            }
            try RunWait(this.InstallDir "\Support Files\Release Assets\Install Packages\installPremRemote.ahk")
            catch {
                return false
            }
            sleep 1500
            return true
        }

        __installNode(path) {
            this.__addLogEntry("installing nodejs")
                RunWait('*RunAs msiexec.exe /i "' . path . '" /qn /norestart',, "Hide")
            sleep 100
        }

        __runCoreFunc() {
            this.__addLogEntry("running Core Functionality.ahk")
            ;// stops core func getting run as admin
            try Run(this.InstallDir "\Core Functionality.ahk")
            catch {
                throw TargetError("Failed to run Core Functionality.ahk")
            }
            sleep 1500
            try RunWait(this.InstallDir "\Support Files\Release Assets\Install Packages\waitCoreFunc.ahk")
        }

        __findAHK() {
            for _, path in [
                A_ProgramFiles "\AutoHotkey\v2\AutoHotkey64.exe",
                A_ProgramFiles "\AutoHotkey\AutoHotkey64.exe"
            ] {
                if FileExist(path) {
                    return path
                }
            }
            return false
        }

        nodeInstalled() => (RegRead("HKLM\SOFTWARE\Node.js", "Version", 0))
}