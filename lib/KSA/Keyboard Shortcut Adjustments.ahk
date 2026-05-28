/************************************************************************
 * @description A class to generate variables based off the user's keyboard shortcuts
 * @author tomshi
 * @date 2026/05/28
 * @version 2.0.0
***********************************************************************/

;{ \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\CLSID_Objs.ahk
#Include Classes\adobeXML.ahk
#Include Functions\determineAdobeVer.ahk
#Include Functions\loadXML.ahk
#Include Other\JSON.ahk
; #Include Other\print.ahk
; }

;// ps defaults; C:\Program Files\Adobe\Adobe Photoshop 2026\Locales\en_US\Support Files\Shortcuts\Win
;// ps custom; C:\Users\Tom\AppData\Roaming\Adobe\Adobe Photoshop 2026\Presets\Keyboard Shortcuts

class KeyShortAdjust {
    __New() {
        if !DirExist(A_MyDocuments "\tomshi\KSA")
            DirCreate(A_MyDocuments "\tomshi\KSA")
        if !FileExist(A_MyDocuments "\tomshi\KSA\override.json")
            FileAppend("{`n`n}", A_MyDocuments "\tomshi\KSA\override.json")
        this.override := JSON.parse(FileRead(this.overrideLocation))
        this.setAdobeKeys("prem")
        this.setAdobeKeys("ae")
        this.setAdobeKeys("ps")
        this.setExcaliburKeys()
        this.setBasicKeys(this.resolveJSONFile)
        this.setBasicKeys(this.windowsJSONFile)
    }

    _unset := Map()      ; keys that failed because app not installed
    _undetermined := Map() ; keys user hasn't set in Premiere

    __Get(name, params) {
        ;// throw
        if this._unset.Has(name) {
            errorLog(UnsetError("This hotkey could not be used as it failed to be set during KSA. " this._unset[name] " may not be installed", -1, name),,, true)
            return
        }
        if this._undetermined.Has(name) {
            errorLog(UnsetError("This hotkey could not be used as the user does not currently have it set within " this._undetermined[name], -1, name),,, true)
            return
        }
    }

    overrideLocation => A_MyDocuments "\tomshi\KSA\override.json"
    override := ""
    jsonsDir => A_AppData "\tomshi\lib\KSA\json files"
    premJSONFile => this.jsonsDir "\prem hotkeys.json"
    aeJSONFile => this.jsonsDir "\ae hotkeys.json"
    psJSONFile => this.jsonsDir "\ps hotkeys.json"
    resolveJSONFile => this.jsonsDir "\resolve hotkeys.json"
    excaliburJSONFile => this.jsonsDir "\excalibur hotkeys.json"
    windowsJSONFile => this.jsonsDir "\windows hotkeys.json"

    doUnset(appJSON, program) {
        for k, v in appJSON {
            this._unset[k] := program
        }
        return
    }
    undeterminedMethod(hotkeyname, program, *) {
        throw UnsetError("This hotkey could not be used as the user does not currently have it set within " program, -1, hotkeyname)
    }

    setAdobeKeys(which) {
        isUnset := false
        appJSON := JSON.parse(FileRead(this.%which%JSONFile))
        switch which {
            case "prem": exeName := {baseName: "Adobe Premiere Pro.exe", beta:"Adobe Premiere Pro (Beta).exe"}, prog := "Premiere"
            case "ae": exeName := {baseName: "AfterFX.exe", beta: "AfterFX (Beta).exe"}, prog := "After Effects"
            case "ps": exeName := {baseName: "Photoshop.exe", beta: "Photoshop (Beta).exe"}, prog := "Photoshop"
        }

        if !appVers := determineAdobeVer(exeName) {
            errorLog(ValueError("Could not determine " prog " hotkeys for KSA", -1))
            this.doUnset(appJSON, prog)
            return
        }
        ;// need to determine if beta
        switch which {
            case "prem":
                premPrefsDir := A_MyDocuments "\Adobe\Premiere Pro\" SubStr(appVers.version, 1, 2) ".0\Profile-" A_UserName
                premPrefs := premPrefsDir "\Adobe Premiere Pro Prefs"
                if FileExist(premPrefs) {
                    try {
                        xml := loadXML(FileRead(premPrefs))
                        userShortcutName := xml.selectSingleNode('/PremiereData/Preferences/Properties/*[name()="FE.Prefs.Shortcuts.Filename"]').text
                        userShortcutFile := premPrefsDir "\Win\" userShortcutName
                    }
                }
                if !FileExist(premPrefs) || (IsSet(userShortcutFile) && !FileExist(userShortcutFile))
                    isUnset := true
                if isUnset = true {
                    errorLog(ValueError("Could not determine Premiere hotkeys for KSA", -1))
                    this.doUnset(appJSON, "Premiere")
                    return
                }

                xml := adobeXML(userShortcutFile)
                for k, v in appJSON {
                    if k ~= "^_*newSection$" ;// ignore any `____newSection`
                        continue
                    try xmlHotkey := xml.__premBuildHotkey(v["context"], v["command"])
                    if !IsSet(xmlHotkey) || (IsSet(xmlHotkey) && IsObject(xmlHotkey) && xmlHotkey.HasOwnProp('isSet') && xmlHotkey.isSet = false) {
                        errorLog(ValueError("Could not determine key for KSA", -1, k))
                        this._undetermined[k] := "Premiere"
                        continue
                    }
                    currentHotkey := (this.override.Has(k) ? this.override.%k%.v["hotkey"] : xmlHotkey)
                    this.%k% := currentHotkey
                }
            case "ae":
                dot := InStr(appVers.version, ".",,, 2)
                yearVer := SubStr(appVers.version, 1, (dot != 0 ? dot-1 : ""))
                aePrefsDir := A_AppData "\Adobe\After Effects\" yearVer
                aePrefs := aePrefsDir "\Adobe After Effects " yearVer " Prefs.txt"
                if FileExist(aePrefs) {
                    userShortcutName := IniRead(aePrefs, '"General Section"', '"Shortcut File Location"', "")
                    userShortcutFile := aePrefsDir "\aeks\" userShortcutName
                }
                if !FileExist(aePrefs) || (IsSet(userShortcutName) && userShortcutName = "") || (userShortcutName != "" && !FileExist(userShortcutFile))
                    isUnset := true
                if isUnset = true {
                    errorLog(ValueError("Could not determine After Effects hotkeys for KSA", -1))
                    this.doUnset(appJSON, "After Effects")
                    return
                }

                xml := adobeXML(userShortcutFile)
                for k, v in appJSON {
                    if k ~= "^_*newSection$" ;// ignore any `____newSection`
                        continue
                    aeHotkeyIniVal := IniRead(userShortcutFile, '"' v["context"] '"', '"' v["command"] '"', "")
                    try xmlHotkey := xml.__aeBuildHotkey(aeHotkeyIniVal)
                    if !this.override.Has(k) && (aeHotkeyIniVal = "" || !IsSet(xmlHotkey) || (IsSet(xmlHotkey) && xmlHotkey = false)) {
                        errorLog(ValueError("Could not determine key for KSA", -1, k))
                        this._undetermined[k] := "After Effects"
                        continue
                    }
                    buildHotkey := (this.override.Has(k)) ? this.override.%k%.v["hotkey"] : xmlHotkey
                    this.%k% := buildHotkey
                }
            case "ps":
                SplitPath(appVers.path,, &yearDir)
                year := SubStr(yearDir, -4)
                locale := this.__getLocale()
                psPrefsDir := A_AppData "\Adobe\Adobe Photoshop " year "\Adobe Photoshop " year " Settings"
                psDefaultShort := A_ProgramFiles "\Adobe\Adobe Photoshop " year "\Locales\" locale "\Support Files\Shortcuts\Win\Default Keyboard Shortcuts.kys"
                userShortcutFile := FileExist(psPrefsDir "\Keyboard Shortcuts Primary.psp") ? psPrefsDir "\Keyboard Shortcuts Primary.psp" : psDefaultShort
                if !FileExist(userShortcutFile) {
                    MsgBox(userShortcutFile)
                    isUnset := true
                }
                if isUnset = true {
                    errorLog(ValueError("Could not determine Photoshop hotkeys for KSA", -1))
                    this.doUnset(appJSON, "Photoshop")
                    return
                }

                xml := adobeXML(userShortcutFile)
                for k, v in appJSON {
                    if k ~= "^_*newSection$" ;// ignore any `____newSection`
                        continue
                    try xmlHotkey := xml.__psBuildHotkey(v["type"], v["name"])
                    if !this.override.Has(k) && (!IsSet(xmlHotkey) || (IsSet(xmlHotkey) && IsObject(xmlHotkey) && xmlHotkey.HasOwnProp('isSet') && xmlHotkey.isSet = false)) {
                        errorLog(ValueError("Could not determine key for KSA", -1, k))
                        this._undetermined[k] := "Photoshop"
                        continue
                    }
                    buildHotkey := (this.override.Has(k)) ? this.override.%k%.v["hotkey"] : xmlHotkey
                    this.%k% := buildHotkey
                }
        }
    }

    setExcaliburKeys() {
        appJSON := JSON.parse(FileRead(this.excaliburJSONFile))
        spellbookExcalFile := A_AppData "\SpellBook\knights_of_the_editing_table.excalibur.json"
        checkExcal  := prem.Excalibur.__isInstalled()
        checkSpell  := FileExist(spellbookExcalFile)
        if !checkExcal || !checkSpell {
            this.doUnset(appJSON, "Excalibur")
            return
        }
        readSpell := JSON.parse(FileRead(spellbookExcalFile))
        adobeReadXML := adobeXML(spellbookExcalFile)
        for k, v in appJSON {
            if k ~= "^_*newSection$" ;// ignore any `____newSection`
                continue

            try xmlHotkey := adobeReadXML.__excaliburBuildHotkey(readSpell["commands"][v["command"]]["shortcut"])
            if !this.override.Has(k) && (!IsSet(xmlHotkey) || (IsSet(xmlHotkey) && xmlHotkey = false)) {
                errorLog(ValueError("Could not determine key for KSA", -1, k))
                this._undetermined[k] := "Excalibur"
                continue
            }
            buildHotkey := (this.override.Has(k)) ? this.override.%k%.v["hotkey"] : xmlHotkey
            this.%k% := buildHotkey
        }
    }

    __getLocale() {
        buf := Buffer(85 * 2)
        DllCall("GetSystemDefaultLocaleName", "Ptr", buf, "Int", 85)
        return StrReplace(StrGet(buf, "UTF-16"), "-", "_",,, 1)
    }

    setBasicKeys(jsonFilepath) {
        jsonFile := JSON.parse(FileRead(jsonFilepath))
        for k, v in jsonFile {
            if k ~= "^_*newSection$" ;// ignore any `____newSection`
                continue
            this.%k% := v["hotkey"]
        }
    }
}

if A_ScriptName != "Core Functionality.ahk" && winExt.ExistRegex("Core Functionality.ahk ahk_class AutoHotkey",,,, true) {
    KSA := CLSID_Objs.clone("KSA")
}