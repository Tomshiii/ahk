/************************************************************************
 * @description a function designed to parse through AE and Premiere Pro keyboard shortcut files to automatically assign KSA.ini values
 * @author tomshi
 * @date 2023/09/28
 * @version 1.0.1
 ***********************************************************************/

#Warn VarUnset, StdOut

;// This script is designed to assist the user of my repo in getting their feet off the ground by parsing through their keyboard shortcut file and attempting to auto assign KSA.ini values based on it.
/*
This process is **NOT** perfect, some values may still be entered incorrectly or just outright skipped due to the nature of trying to convert the way adobe stores their values to the way ahk can read them.
It also doesn't help that Premiere & After Effects store their data differently making it even more prone to small errors.
**Please** report any issues with this process or any errors you come across, making sure to provide as much information as possible.
*/

; { \\ #Includes
#Include *i <Classes\settings>
#Include *i <Classes\ptf>
#Include *i <Classes\Mip>
#Include *i <Classes\tool>
#Include *i <GUIs\tomshiBasic>
; }

try {
    UserSettings := UserPref()
}

if !IsSet(UserSettings)
    {
        MsgBox("This script requires the user to properly generate a symlink using ``CreateSymLink.ahk```n`nPlease run ``CreateSymLink.ahk`` to do so and then try running this script again.", A_ScriptName ".ahk requires SymLink")
        return
    }

class adobeKSA extends tomshiBasic {
    __New() {
        super.__New(,,, "Adjust adobe hotkeys")
        this.__generate()
        this.Opt("-resize")
    }

    Xmargin := "x" 8
    Xclude := 500

    defaultPremiereFolder := A_MyDocuments "\Adobe\Premiere Pro\" ptf.PremYearVer ".0\Profile-" A_UserName "\Win"
    defaultAEFolder := A_AppData "\Adobe\After Effects\" LTrim(ptf.aeIMGver, "v") "\aeks"

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
        this.AddText(this.Xmargin, "example: " this.defaultPremiereFolder "\22.0\Profile-Tom`n").SetFont("s8")

        this.__indivSection(this.defaultPremiereFolder, "Premiere")
        this.__indivSection(this.defaultAEFolder, "AE")
        this.AddButton("y+20", "Submit").OnEvent("Click", this.__submit.Bind(this))
    }

    __isFKey(key) {
        if StrLen(key) <= 3 && SubStr(key, 1, 1) = "F"
            return "{" key "}"
        return key
    }

    knownKeys := Mip(
        "BackSpace",    1,
        "Del",      1,
        "Delete",       1,
        "Enter",    1,
        "Up",   1,
        "Down", 1,
        "Left", 1,
        "Right",    1,
        "Space",    1,
        "Tab",  1,
        "Esc",  1,
        "Escape",   1,
        "Insert",   1,
        "Home", 1,
        "End",  1,
        "PgUp", 1,
        "PgDown",   1
    )

    /**
     * Wraps any required keys in "{}" so ahk interprets them correctly
     * @param {String} key the hotkey string
     * @returns {String} the final hotkey
     */
    __wrapKey(key) {
        if checkF := this.__isFKey(key)
            return checkF
        if (
            (pad := InStr(key, "Pad") || numpad := InStr(key, "Numpad")) &&
            (IsNumber(SubStr(key, -1, 1)) || IsNumber(SubStr(key, -1, 2)))
        ) {
            if numpad
                return "{" key "}"
            if pad {
                if this.AEKeyMap.Has(key) {
                    return this.AEKeyMap.Get(key)
                }
            }
        }
        if this.knownKeys.Has(key)
            return "{" key "}"

        return key
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
        premShortcut := FileRead(location)

        splitSection := StrSplit(premSection, ["=", "`n", "`r"])
        for k, v in splitSection {
            if Mod(k, 2) = 0
                continue
            if InStr(v, "label", 1, 1, 1)
                continue

            commandName := this.__command(v)
            context     := this.__context(v)
            hotkeyVal := adobeXML(premShortcut).__buildHotkey(context, commandName)
            if hotkeyVal = false
                continue
            IniWrite(Format('"{}"', hotkeyVal), this.KSA, "Premiere", v)
        }
    }

    /**
     * A map of known replacements
     */
    AEKeyMap := Mip(
        "Comma",        ",",
        "LeftArrow",        "{Left}",
        "RightArrow",       "{Right}",
        "UpArrow",      "{Up}",
        "DownArrow",        "{Down}",
        "FwdDel",       "{BackSpace}",
        "SingleQuote",      "'",
        "Backslash",        "\",
        "PadClear",     "{NumpadClear}",
        "PadSlash",    "{NumpadDiv}",
        "PadMinus",    "{NumpadSub}",
        "PadPlus", "{NumpadAdd}",
        "PadInsert", "{Insert}",
        "PadDecimal",   "{NumpadDot}",
        "PadMultiply", "{NumpadMulti}",
        "PadHome",      "{NumpadHome}",
        "PadEnd",       "{NumpadEnd}",
        "PadPageUp",        "{NumpadPgUp}",
        "PadPageDown",      "{NumpadPgDn}",
        "PadDelete",        "{NumpadDel}",

    )

    /**
     * Clears any modifiers from the AE shortcut string
     * @param {String} key the hotkey string to be stripped
     */
    __clearHotkey(key) {
        key := StrReplace(key, "Shift+", "")
        key := StrReplace(key, "Ctrl+", "")
        key := StrReplace(key, "Alt+", "")
        return key
    }

    /**
     * Builds the AE hotkey
     * @param {String} hotkey turns the shortcut file hotkey into an AHK readable hotkey
     */
    __aeBuildHotkey(hotkey) {
        baseHotkey := SubStr(hotkey
                        , startpos := InStr(hotkey, "(",, 1, 1) + 1
                        , InStr(hotkey, ")",, 1, 1) - startpos
                    )
        builtHotkey := InStr(baseHotkey, "Ctrl",, 1, 1) ? "^" : ""
        builtHotkey := InStr(baseHotkey, "Alt",, 1, 1) ? builtHotkey "!" : builtHotkey
        builtHotkey := InStr(baseHotkey, "Shift",, 1, 1) ? builtHotkey "+" : builtHotkey

        baseHotkey := this.__clearHotkey(baseHotkey)
        loop {
            nextKey := (plus := InStr(baseHotkey, "+",, 1, 1)) ? SubStr(baseHotkey, 1, InStr(baseHotkey, "+",, 1, 1))
                                                     : SubStr(baseHotkey, 1)
            nextKey := (this.AEKeyMap.Has(nextKey)) ? this.AEKeyMap.Get(nextKey) : nextKey
            nextKey := this.__wrapKey(nextKey)
            if StrLen(nextKey) = 1
                nextKey := StrLower(nextKey)
            builtHotkey := builtHotkey nextKey
            if !plus
                break
        }
        return builtHotkey
    }

    /**
     * parse through the AE keyboard shortcut file
     * @param {String} location the location of the keyboard shortcut file
     */
    __parseAE(location) {
        aeSection    := IniRead(this.KSA, "After Effects")
        aeShortcut   := FileRead(location)

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
            buildHotkey := this.__aeBuildHotkey(aeHotkeyIniVal)
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


/**
 * @param file a filepath to the xml file you wish to parse
 * @returns {Object} returns an xml comobj to allow the user
 * Examples:
```
xml.selectSingleNode('/PremiereData/shortcuts/context.global/*[commandname="cmd.transport.shuttle.stop"]/virtualkey').text
xml.selectSingleNode('/PremiereData/shortcuts/context.global/*[commandname="cmd.transport.shuttle.stop"]').nodename
```
 */
class adobeXML {
    __New(file) {
        this.xml := this.__loadXML(file)
    }
    xml := ""

    /**
     * haven't quite figured out why some keys provide different values than most. until the day that the math adds up, here's a list of keys that provide a different result alongside their actual values (on my pc atleast, who knows with adobe)
     */
    knownKeys := Map(
        "2147483713",     "d",

        "14",             "{F8}",
        "42",             "{Left}",
        "43",             "{Right}",
        "44",             "{Up}",
        "45",             "{Down}",
    )

    /**
     * takes an xml formatted string and returns a comobject
     * @param {String} xml the fileread xml file (ie, premiere's keyboard shortcut file)
     * @returns {Object} returns a comobject
     */
    __loadXML(xml) {
        xmldoc := ComObject("MSXML2.DOMDocument.6.0")
        xmldoc.async := false
        xmldoc.loadXML(xml)
        return xmldoc
    }

    /**
     * takes premiere's virtual key value and returns they key
     * @param {Integer} virtualKey the virtual key value retrieved from the xml file
     * @returns {Boolean/String} returns `false` on failure or a string containing the name of the key
     */
    __convVirtToKey(virtualKey) {
        if this.knownKeys.Has(virtualKey)
            return this.knownKeys.Get(virtualKey)
        if StrLen(virtualKey) < 8
            return false
        val := SubStr((Format("{:x}", virtualKey)), -2)
        return StrLower(Chr(Integer("0x" . val)))
    }

    /**
     * retrieves the modifiers for the given hotkey
     * @param {String} path the xml path for the desired hotkey
     * @returns {String} returns a string containing the modifiers for the given hotkey or a blank string if none
     */
    __retriveModifiers(path) {
        ctrl  := (this.xml.selectSingleNode(path "/modifier.ctrl").text  = "true") ? "^" : ""
        alt   := (this.xml.selectSingleNode(path "/modifier.alt").text   = "true") ? "!" : ""
        shift := (this.xml.selectSingleNode(path "/modifier.shift").text = "true") ? "+" : ""
        return (ctrl alt shift)
    }

    /**
     * Builds the hotkey for the desired xml path
     * @param {String} start the xml path of the desired hotkey. eg. `'/PremiereData/shortcuts/context.global'`
     * @param {String} codename the xml `codename` for the desired hotkey. eg. `"cmd.clip.scaletoframesize"`
     * @returns {String} returns complete hotkey
     */
    __buildHotkey(start, codename) {
        if InStr(this.xml.text, codename,,, 2) || !InStr(this.xml.text, codename)
            return false
        firstPrompt := Format('{}/*[commandname="{}"]', start, codename)
        getItemNum := this.xml.selectSingleNode(firstPrompt).nodename
        secondPrompt := Format('{}[commandname="{}"]', start "/" getItemNum, codename)
        getModifiers := this.__retriveModifiers(secondPrompt)
        virtkey := this.__convVirtToKey(this.xml.selectSingleNode(secondPrompt "/virtualkey").text)
        getKey := (virtkey != false) ? virtkey : "false"
        if getKey == "false"
            return false
        getKey := adobeKSA().__wrapKey(getKey)
        return (getModifiers getKey)
    }
}

adobegui := adobeKSA()
adobegui.Show()