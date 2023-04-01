#Warn VarUnset, StdOut

;// This script is designed to assist the user of my repo in getting their feet off the ground by parsing through their keyboard shortcut file and attempting to auto assign KSA.ini values based on it.

; { \\ #Includes
#Include *i <Classes\settings>
#Include *i <Classes\ptf>
#Include *i <Classes\Dark>
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
        if UserSettings.dark_mode = true
            Dark.allButtons(this)
    }

    Xmargin := "x" 8
    Xclude := 500

    defaultPremiereFolder := A_MyDocuments "\Adobe\Premiere Pro\"
    defaultAEFolder := A_AppData "\Adobe\After Effects\"

    KSA => ptf.rootDir "\lib\KSA\Keyboard Shortcuts.ini"

    PremiereExclude := 0
    AEExclude := 1

    PremiereDisable := 0
    AEDisable := 1

    PremErr := 0
    AEErr := 0

    /**
     * This function is called to generate the main section of the GUI
     */
    __generate() {
        this.AddText(this.Xmargin, "Please select the root directory locations for where each program keeps its keyboard shortcut file.")
        this.AddText(this.Xmargin " r1 w500", "Please include your version number && profile folder if applicible.").SetFont("bold")
        this.AddText(this.Xmargin, "example: " this.defaultPremiereFolder "22.0\Profile-Tom`n").SetFont("s8")

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
     * This function is called when the change buttons are clicked
     */
    __changePath(which, defaultFolder, *) {
        if this.%which%Disable = 1
            return
        which := InStr(defaultFolder, "Premiere Pro", 1, 1, 1) ? "Premiere" : "AE"
        changePath := FileSelect("D", defaultFolder, "Select " which " directory, including version.")
        if changePath = ""
            return
        this.default%which%Folder := changePath
        this.%which%Folder.Text := SubStr(changePath, InStr(changePath, "Adobe")-1)
    }

    __findFolder(startDir, name) {
        loop files startDir "*.*", "D R" {
            if A_LoopFileName != name
                continue
            return A_LoopFileFullPath
        }

        throw IndexError("Function could not determine the location of the ``" name "`` folder within the selected directory. Please provide the proper path and try again.", name, -1)
    }

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

    __parsePrem(location) {
        premSection  := IniRead(this.KSA, "Premiere")
        KSARead      := FileRead(this.KSA)
        premShortcut := FileRead(location)

        splitSection := StrSplit(premSection, ["=", "`n", "`r"])
        for k, v in splitSection {
            if Mod(k, 2) = 0
                continue
            if InStr(v, "label", 1, 1, 1)
                continue
            commandName := SubStr(KSARead
                                , start := InStr(KSARead, ";[",
                                                , InStr(KSARead, v, 1,, 1)
                                                , 1) +2
                                , InStr(KSARead, "]",, start, 1) - start
                            )
            context     := SubStr(KSARead
                                , start := InStr(KSARead, ";{",
                                                , InStr(KSARead, v, 1,, 1)
                                                , 1) +2
                                , InStr(KSARead, "}",, start, 1) - start
                            )
            hotkeyVal := xml(premShortcut).__buildHotkey(context, commandName)
            if hotkeyVal = false
                continue
            msgbox commandName "`n" hotkeyVal
            ;//! write to .ini file from here:
        }
    }

    __parseAE() {

    }

    __submit(*) {
        PremiereShortcut := (this.PremiereExclude = 0) ? this.__findPremiereShortcut() : false
        AEShortcut       := (this.AEExclude = 0)       ? this.__findAEShortcut()       : false

        if this.PremErr = false && PremiereShortcut != "" && this.PremiereExclude = 0 {
            this.__parsePrem(PremiereShortcut)
        }
        if this.AEErr = false && AEShortcut != "" && this.AEExclude = 0 {
            this.__parseAE()
        }

    }

}


/**
 * Examples:
 * ```
 * xml.selectSingleNode('/PremiereData/shortcuts/context.global/*[commandname="cmd.transport.shuttle.stop"]/virtualkey').text
 * xml.selectSingleNode('/PremiereData/shortcuts/context.global/*[commandname="cmd.transport.shuttle.stop"]').nodename
```
 */
class xml {
    __New(file) {
        this.xml := this.__loadXML(file)
    }
    xml := ""

    /**
     * takes an xml formatted string and returns a comobject
     * @param {String} xml the fileread xml file (ie, premiere's keyboard shortcut file)
     * @return {Object} returns a comobject
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
     * @return {Boolean/String} returns `false` on failure or a string containing the name of the key
     */
    __convVirtToKey(virtualKey) {
        if StrLen(virtualKey) < 8
            return false
        val := Format("{:X}", virtualKey)
        return GetKeyName("vk" SubStr(val, -2))
    }

    /**
     * retrieves the modifiers for the given hotkey
     * @param {String} path the xml path for the desired hotkey
     * @return {String} returns a string containing the modifiers for the given hotkey or a blank string if none
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
     */
    __buildHotkey(start, codename) {
        if InStr(this.xml.text, codename,,, 2)
            return false
        firstPrompt := Format('{}/*[commandname="{}"]', start, codename)
        getItemNum := this.xml.selectSingleNode(firstPrompt).nodename
        secondPrompt := Format('{}[commandname="{}"]', start "/" getItemNum, codename)
        getModifiers := this.__retriveModifiers(secondPrompt)
        virtkey := this.__convVirtToKey(this.xml.selectSingleNode(secondPrompt "/virtualkey").text)
        getKey := (virtkey != false) ? virtkey : "false"
        if getKey == "false"
            return false
        return (getModifiers getKey)
    }
}

adobegui := adobeKSA()
adobegui.Show()