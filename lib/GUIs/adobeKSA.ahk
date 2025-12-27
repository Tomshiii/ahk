/************************************************************************
 * @description a GUI designed to help the user easily replace their KSA.ini file
 * @author tomshi
 * @date 2025/12/27
 * @version 1.2.1
 ***********************************************************************/
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\settings.ahk
#Include Classes\ptf.ahk
#Include Classes\Mip.ahk
#Include Classes\tool.ahk
#Include Classes\adobeXML.ahk
#Include GUIs\tomshiBasic.ahk
; }

class adobeKSA extends tomshiBasic {
    __New(doGenerate := true) {
        if doGenerate = true {
            super.__New(,,, "Adjust adobe hotkeys")
            this.__generate()
            this.Opt("-resize")
        }
    }

    Xmargin := "x" 8
    Xclude := 500

    defaultPremiereFolder := A_MyDocuments "\Adobe\Premiere Pro\" ptf.PremYearVer ".0\Profile-" A_UserName "\Win"
    aeVerNum     := StrReplace(ptf.premSETver, "v", "")
    aeVerNumTrim := InStr(this.aeVerNum, ".",,, 2) ? SubStr(this.aeVerNum, 1, InStr(this.aeVerNum, ".",,, 2)-1) : this.aeVerNum
    defaultAEFolder := A_AppData "\Adobe\After Effects\" this.aeVerNumTrim "\aeks"

    KSADir => ptf.rootDir "\Support Files\KSA"
    KSA => this.KSADir "\Keyboard Shortcuts.ini"
    KSARead := ""

    PremiereExclude := 0
    AEExclude := 0

    PremiereDisable := 0
    AEDisable := 0

    PremErr := 0
    AEErr := 0

    /**
     * This function is called to generate the main section of the GUI
     */
    __generate() {
        this.AddText(this.Xmargin, "Please select the root directory locations for where each program keeps its keyboard shortcut file.")
        this.AddText(this.Xmargin " r1 w500", "Please include your version number && profile folder if applicible.").SetFont("bold")
        this.AddText(this.Xmargin, "example: " this.defaultPremiereFolder "\" ptf.PremYearVer ".0\Profile-Tom`n").SetFont("s8")

        this.__indivSection(this.defaultPremiereFolder, "Premiere")
        this.__indivSection(this.defaultAEFolder, "AE")
        this.AddButton("y+20", "Submit").OnEvent("Click", this.__submit.Bind(this))
    }

    /**
     * This function is designed to cut repeat code and is called to generate the two sections (premiere/ae)
     * @param {String} defaultFolder the default directory that adobe keeps the keyboard shortcut files
     * @param {String} which which program the iteration of the function is working on. It's important for this to be right as it passes it to following functions
     */
    __indivSection(defaultFolder, which) {
        this.AddText(this.Xmargin " r1 w120", which " Folder: ").SetFont("bold")
        this.%which%Folder := this.Add("Text", this.Xmargin " Section ", defaultFolder)
        this.AddCheckbox("x" this.Xclude " ys-25 Checked" this.%which%Exclude, "Exclude").OnEvent("Click", this.__exclude.Bind(this, which))
        this.AddButton("y+7", "Change").OnEvent("Click", this.__changePath.Bind(this, which, defaultFolder))
        if this.%which%Disable = 1 {
            this.%which%Folder.SetFont("strike")
            return
        }
    }

    /**
     * This function is called when the exclude checkboxes are clicked
     */
    __exclude(which, guiObj, *) {
        if this.%which%Disable = 1 {
            guiObj.Value := 1
            return
        }
        this.%which%Exclude := guiObj.Value
        switch guiObj.Value {
            case 1: this.%which%Folder.SetFont("strike")
            default: this.%which%Folder.SetFont("norm")
        }
    }
    /**
     * This function is called when the change buttons are clicked and handles reassigning variables used to determine the location of the keyboard shortcut file
     */
    __changePath(which, defaultFolder, *) {
        if this.%which%Disable = 1
            return
        which := InStr(defaultFolder, "Premiere Pro", 1, 1, 1) ? "Premiere" : "AE"
        defaultFolder := this.__checkDefaultDir(defaultFolder)
        changePath := FileSelect("D", defaultFolder, "Select " which " directory, including version.")
        if changePath = ""
            return
        this.default%which%Folder := changePath
        this.%which%Folder.Text := SubStr(changePath, InStr(changePath, "Adobe")-1)
    }

    /**
     * Is called before the user is prompted with a file select window, checks to see if the default folder exist, if it doesn't, it'll change itself to a path without a version
     * @param {String} dir the default dir you wish to check
     * @returns {String} the resulting dir path
     */
    __checkDefaultDir(dir) {
        if !DirExist(dir "\")
            return SubStr(dir, 1, InStr(dir, "\",,, -3))
        return dir
    }

    /**
     * Attempt to find the folder where the keyboard shortcut file is located
     * @param {String} startDir the directory the search begins at
     * @returns {String} the path that the keyboard shortcut folder is found in
     */
    __findFolder(startDir, name) {
        startDir := this.__checkDefaultDir(startDir)
        SplitPath(startDir, &dirname)
        if dirname = name
            return startDir
        loop files startDir "\*.*", "D R" {
            if A_LoopFileName != name
                continue
            return A_LoopFileFullPath
        }

        throw IndexError("Function could not determine the location of the ``" name "`` folder within the selected directory. Please provide the proper path and try again.", name, -1)
    }

    /**
     * Backs up the user's ksa file
     */
    __backupKSA() {
        if !DirExist(this.KSADir "\backup")
            DirCreate(this.KSADir "\backup")
        datetime := Format("{}_{}_{}", A_Hour, A_Min, A_Sec)
        FileCopy(this.KSA, this.KSADir "\backup\ksa_backup_" datetime ".ini")
    }

    /**
     * Attempts to find the respective keyboard shortcut file
     * @param {String} loopDir the directory to search through
     * @param {String} filetype the respective filetype of the keyboard shortcut file
     * @param {String} which the name of the parameter to update if something goes wrong
     * @returns {String} the filepath of the keyboard shortcut file
     */
    __findFile(loopDir, filetype, which) {
        amount := 0
        loop files loopDir "\*." filetype, "F" {
            amount++
            filepath := A_LoopFileFullPath
        }
        if amount = 1
            return filepath

        shortcutDir := FileSelect("3", filepath, "Select Your Keyboard Shortcut File", "*." filetype)
        if shortcutDir != ""
            return shortcutDir

        this.%which% := true
        return ""
    }

    __findPremiereShortcut() {
        foundPath := this.__findFolder(this.defaultPremiereFolder, "Win")
        return this.__findFile(foundPath, "kys", "Prem")
    }

    __findAEShortcut() {
        foundPath := this.__findFolder(this.defaultAEFolder, "aeks")
        return this.__findFile(foundPath, "txt", "AE")
    }

    /**
     * retrieves the xml command from the KSA file
     */
    __command(v) => SubStr(this.KSARead
                        , start := InStr(this.KSARead, ";[",, InStr(this.KSARead, v, 1,, 1), 1) +2
                        , InStr(this.KSARead, "]",, start, 1) - start
                    )

    /**
     * retrieves the xml context from the KSA file
     */
    __context(v) => SubStr(this.KSARead
                        , start := InStr(this.KSARead, ";{",, InStr(this.KSARead, v, 1,, 1), 1) +2
                        , InStr(this.KSARead, "}",, start, 1) - start
                    )

    /**
     * parse through the premiere keyboard shortcut file
     * @param {String} location the location of the file
     */
    __parsePrem(location) {
        premSection  := IniRead(this.KSA, "Premiere")

        splitSection := StrSplit(premSection, ["=", "`n", "`r"])
        for k, v in splitSection {
            if Mod(k, 2) = 0
                continue
            if InStr(v, "label", 1, 1, 1)
                continue

            commandName := this.__command(v)
            context     := this.__context(v)
            hotkeyVal   := adobeXML(location).__premBuildHotkey(context, commandName, false)
            if hotkeyVal = false
                continue
            IniWrite(Format('"{}"', hotkeyVal), this.KSA, "Premiere", v)
        }
    }

    /**
     * parse through the AE keyboard shortcut file
     * @param {String} location the location of the keyboard shortcut file
     */
    __parseAE(location) {
        aeSection    := IniRead(this.KSA, "After Effects")

        aesplitSection := StrSplit(aeSection, ["=", "`n", "`r"])
        for k, v in aesplitSection {
            if Mod(k, 2) = 0
                continue
            sectionName := this.__command(v)
            keyName     := this.__context(v)
            if InStr(keyName, "/PremiereData/")
                continue
            aeHotkeyIniVal := IniRead(location, sectionName, keyName, "")
            if aeHotkeyIniVal = ""
                continue
            buildHotkey := adobeXML(location).__aeBuildHotkey(aeHotkeyIniVal)
            IniWrite(Format('"{}"', buildHotkey), this.KSA, "After Effects", v)
        }
    }

    /**
     * This function handles the logic that occurs when the submit button is pressed
     */
    __submit(*) {
        if this.PremiereExclude = true && this.AEExclude = true
            ExitApp()
        this.__backupKSA()
        this.KSARead := FileRead(this.KSA)
        MsgBox("
        (
            Please be aware this process is not perfect. The way adobe store's their hotkey values is a mess and incredibly difficult to parse. Some values retrieved may either be incorrect or simply skipped all together.
            A backup of your current KSA.ini file will be generated.
            While this script is designed to speed up the process of starting with my scripts, I highly recommend NOT solely relying on this script and still double checking the values.

            Please report any issues/errors on github and be sure to provide as much detail as possible!
        )", "Warning", 0x30)
        PremiereShortcut := (this.PremiereExclude = 0) ? this.__findPremiereShortcut() : false
        AEShortcut       := (this.AEExclude = 0)       ? this.__findAEShortcut()       : false

        if this.PremErr = false && PremiereShortcut != "" && this.PremiereExclude = 0 {
            this.__parsePrem(PremiereShortcut)
        }
        if this.AEErr = false && AEShortcut != "" && this.AEExclude = 0 {
            this.__parseAE(AEShortcut)
        }
        tool.tray({text: "Attempting to replace KSA values complete!`nPlease double check these values as some may have been skipped or incorrectly interprated.", title: "Success!"})
        this.Destroy()
    }
}