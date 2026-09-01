/************************************************************************
 * @description A class to generate variables based off the user's keyboard shortcuts
 * @author tomshi
 * @date 2026/08/31
 * @version 2.2.1
***********************************************************************/

;{ \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\CLSID_Objs.ahk
#Include Classes\adobeXML.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\winExt.ahk
#Include Functions\determineAdobeVer.ahk
#Include Functions\loadXML.ahk
#Include Functions\checkBool.ahk
#Include Other\JSON.ahk
#Include Other\Array.ahk
; #Include Other\print.ahk
; }

;// ps defaults; C:\Program Files\Adobe\Adobe Photoshop 2026\Locales\en_US\Support Files\Shortcuts\Win
;// ps custom; C:\Users\Tom\AppData\Roaming\Adobe\Adobe Photoshop 2026\Presets\Keyboard Shortcuts

class KSA_Namespace {
    ;// a small holder class so each program's hotkeys (KSA.prem.x, KSA.ps.x etc) can
    ;// independently report "unset"/"undetermined" errors without colliding on name.
    ;// NOTE: this deliberately holds NO reference back to the parent KeyShortAdjust
    ;// instance - CLSID_Objs.deepClone has no cycle detection, and a parent<->child
    ;// back-reference here will send it into infinite recursion. Each namespace
    ;// instead owns its own isolated _unset/_undetermined maps.
    _unset := Map()
    _undetermined := Map()

    __Get(name, params) {
        if this._unset.Has(name) {
            errorLog(UnsetError("This hotkey could not be used as it failed to be set during KSA. " this._unset[name] " may not be installed", -1, name),,, true)
            return
        }
        if this._undetermined.Has(name) {
            errorLog(UnsetError("This hotkey could not be used as the user does not currently have it set within " this._undetermined[name], -1, name),,, true)
            return
        }
        throw PropertyError("`"" name "`" is not a recognised KSA hotkey (check it exists in the relevant json file).", -1, name)
    }
}

class KeyShortAdjust {
    __New() {
        if !DirExist(A_MyDocuments "\tomshi\KSA")
            DirCreate(A_MyDocuments "\tomshi\KSA")
        if !FileExist(A_MyDocuments "\tomshi\KSA\override.json")
            FileAppend("{`n`n}", A_MyDocuments "\tomshi\KSA\override.json")
        try this.override := JSON.parse(FileRead(this.overrideLocation))
        catch as e {
            if e.Message = "Malformed JSON - unrecognized character."
                throw ValueError("Malformed JSON in " this.overrideLocation, -1)
            throw e
        }
        this.setAdobeKeys("prem")
        this.setAdobeKeys("ae")
        this.setAdobeKeys("ps")
        this.setExcaliburKeys()
        this.setBasicKeys(this.resolveJSONFile)
        this.setBasicKeys(this.windowsJSONFile)
    }

    settingsINI => A_MyDocuments "\tomshi\settings.ini"
    overrideLocation => A_MyDocuments "\tomshi\KSA\override.json"
    override := ""
    jsonsDir => A_AppData "\tomshi\lib\KSA\json files"
    premJSONFile => this.jsonsDir "\prem hotkeys.json"
    aeJSONFile => this.jsonsDir "\ae hotkeys.json"
    psJSONFile => this.jsonsDir "\ps hotkeys.json"
    resolveJSONFile => this.jsonsDir "\resolve hotkeys.json"
    excaliburJSONFile => this.jsonsDir "\excalibur hotkeys.json"
    windowsJSONFile => this.jsonsDir "\windows hotkeys.json"

    UserSettings := unset

    /**
     * lazily create (or fetch) the KSA_Namespace instance for a given program name so KSA.<prog>.<hotkey> always resolves through KSA_Namespace's __Get, no matter how many programs end up nested inside the various json files
     * @param {String} [which] the name of the namespace to operate on, ie; `"prem"`
     */
    getNamespace(which) {
        if !this.HasOwnProp(which) || !(this.%which% is KSA_Namespace)
            this.%which% := KSA_Namespace()
        return this.%which%
    }

    /**
     * cut repeat code to determine whether an override hotkey is present for the desired program
     * @param {String} [which] the `Key` name of the JSON section you wish to check - the program name.
     * @param {String} [hotkeyName] the name of the hotkey to be checked for
     * @returns {String | false}
     */
    getOverride(which, hotkeyName) {
        if !(this.override is Map) || !this.override.Has(which)
            return false
        progOverride := this.override[which]
        if !(progOverride is Map) || !progOverride.Has(hotkeyName)
            return false
        entry := progOverride[hotkeyName]
        return (entry is Map) ? entry["hotkey"] : false
    }

    /**
     * determine unset programs
     * @param {Map} [appJSON] the `JSON.parse()` map for the desired program
     * @param {String} [program] the name of the program that is encountering the error, ie; `"Premiere"`
     * @param {Class} [ns] the `getNamespace()` class instance to operate on
     */
    doUnset(appJSON, program, ns) {
        for k, v in appJSON {
            ns._unset[k] := program
        }
        return
    }

    /**
     * Determines if the user has `IsBeta` set for the desired adobe program
     * @param {String} [which] the shorthand name of the desired adobe product, ie; `"prem"`
     */
    __isBeta(which) {
        try {
            if !IsSet(UserSettings) {
                try UserSettings := CLSID_Objs.clone("UserSettings")
                catch {
                    UserSettings := UserPref(true)
                }
            }
            isBeta := UserSettings.%which%IsBeta
            return checkBool(isBeta)
        } catch {
            return (checkBool(IniRead(this.settingsINI, "Adjust", which "IsBeta", "false")))
        }
    }

    /**
     * sets the hotkeys for the desired adobe program
     * @param {String} [which] the shorthand name of the desired adobe product, ie; `"prem"`
     */
    setAdobeKeys(which) {
        isUnset := false
        appJSON := JSON.parse(FileRead(this.%which%JSONFile))
        ns := this.getNamespace(which)
        switch which {
            case "prem": exeName := {baseName: "Adobe Premiere Pro.exe", beta:"Adobe Premiere Pro (Beta).exe"}, prog := "Premiere"
            case "ae": exeName := {baseName: "AfterFX.exe", beta: "AfterFX (Beta).exe"}, prog := "After Effects"
            case "ps": exeName := {baseName: "Photoshop.exe", beta: "Photoshop.exe"}, prog := "Photoshop"
        }

        if !appVers := determineAdobeVer(exeName) {
            errorLog(ValueError("Could not determine " prog " hotkeys for KSA", -1))
            this.doUnset(appJSON, prog, ns)
            return
        }
        switch which {
            case "prem":
                isBeta := this.__isBeta("prem")
                backupVer := IniRead(this.settingsINI, "Adjust", "premVer", "v" prem.minVer)
                try premVer := (IsSet(UserSettings)) ? UserSettings.premVer : backupVer
                catch {
                    premVer := backupVer
                }
                betaString := (isBeta=true) ? " (Beta)" : ""
                premPrefsDir := A_MyDocuments "\Adobe\Premiere Pro" betaString "\" SubStr(appVers.version, 1, 2) ".0\Profile-" A_UserName
                premPrefs := premPrefsDir "\Adobe Premiere Pro" betaString " Prefs"
                if FileExist(premPrefs) {
                    try {
                        readXML := loadXML(FileRead(premPrefs))
                        userShortcutName := readXML.selectSingleNode('/PremiereData/Preferences/Properties/*[name()="FE.Prefs.Shortcuts.Filename"]').text
                        userShortcutFile := premPrefsDir "\Win\" userShortcutName
                    }
                }
                if !FileExist(premPrefs) || (IsSet(userShortcutFile) && !FileExist(userShortcutFile)) {
                    errorLog(ValueError("Could not determine Premiere hotkeys for KSA", -1))
                    this.doUnset(appJSON, "Premiere", ns)
                    return
                }

                xml := adobeXML(userShortcutFile)
                for k, v in appJSON {
                    if k ~= "^_*newSection$" ;// ignore any `____newSection`
                        continue

                    switch {
                        ;//? in v27.0 of prem they added an extra tag in the xml, instead of just `/PremiereData/shortcuts/` there's now an additional `mode.X` to account for the new `Color` mode

                        ;//! v27.0+
                        case VerCompare(premVer, "27.0") >= 0: RegExReplace(v["context"], "shortcuts/(?!mode\.)", "shortcuts/mode.Edit/")

                        ;//! pre v27.0
                        ;// attempt to remove `mode.Edit` or `mode.Color` for slight backwards compat
                        ;// keep in mind that this won't work for any kbd shortcuts they add in the future or any contexts they change etc
                        case VerCompare(premVer, "27.0") < 0: v["context"] := RegExReplace(v["context"], "/mode\.(Edit|Color)")
                    }
                    try xmlHotkey := xml.__premBuildHotkey(v["context"], v["command"])
                    if !IsSet(xmlHotkey) || (IsSet(xmlHotkey) && IsObject(xmlHotkey) && xmlHotkey.HasOwnProp('isSet') && xmlHotkey.isSet = false) {
                        errorLog(ValueError("Could not determine key for KSA", -1, k))
                        ns._undetermined[k] := "Premiere"
                        continue
                    }
                    overrideVal := this.getOverride(which, k)
                    currentHotkey := overrideVal != false ? overrideVal : xmlHotkey
                    ns.%k% := currentHotkey
                }
            case "ae":
                dot := InStr(appVers.version, ".",,, 2)
                yearVer := SubStr(appVers.version, 1, ((dot != 0 && dot != "") ? dot-1 : StrLen(appVers.version)))
                isBeta := this.__isBeta("ae")
                betaString := ((isBeta=true) ? " (Beta)" : "")
                aePrefsDir := A_AppData "\Adobe\After Effects" betaString "\" yearVer
                aePrefs := aePrefsDir "\Adobe After Effects " yearVer " Prefs.txt"
                if FileExist(aePrefs) {
                    userShortcutName := IniRead(aePrefs, '"General Section"', '"Shortcut File Location"', "")
                    userShortcutFile := aePrefsDir "\aeks\" userShortcutName
                }
                if !FileExist(aePrefs) || (IsSet(userShortcutName) && userShortcutName = "") || (userShortcutName != "" && !FileExist(userShortcutFile)) {
                    errorLog(ValueError("Could not determine After Effects hotkeys for KSA", -1))
                    this.doUnset(appJSON, "After Effects", ns)
                    return
                }

                xml := adobeXML(userShortcutFile)
                for k, v in appJSON {
                    if k ~= "^_*newSection$" ;// ignore any `____newSection`
                        continue
                    aeHotkeyIniVal := IniRead(userShortcutFile, '"' v["context"] '"', '"' v["command"] '"', "")
                    try xmlHotkey := xml.__aeBuildHotkey(aeHotkeyIniVal)
                    overrideVal := this.getOverride(which, k)
                    if !overrideVal && (aeHotkeyIniVal = "" || !IsSet(xmlHotkey) || (IsSet(xmlHotkey) && xmlHotkey = false)) {
                        errorLog(ValueError("Could not determine key for KSA", -1, k))
                        ns._undetermined[k] := "After Effects"
                        continue
                    }
                    buildHotkey := overrideVal != false ? overrideVal : xmlHotkey
                    ns.%k% := buildHotkey
                }
            case "ps":
                SplitPath(appVers.path,, &yearDir)
                isBeta := this.__isBeta("ps")
                year := isBeta=true ? "(Beta)" : SubStr(yearDir, -4)
                locale := this.__getLocale()
                psPrefsDir := A_AppData "\Adobe\Adobe Photoshop " year "\Adobe Photoshop " year " Settings"
                psDefaultShort := A_ProgramFiles "\Adobe\Adobe Photoshop " year "\Locales\" locale "\Support Files\Shortcuts\Win\Default Keyboard Shortcuts.kys"
                userShortcutFile := FileExist(psPrefsDir "\Keyboard Shortcuts Primary.psp") ? psPrefsDir "\Keyboard Shortcuts Primary.psp" : psDefaultShort
                if !FileExist(userShortcutFile) {
                    errorLog(ValueError("Could not determine Photoshop hotkeys for KSA", -1))
                    this.doUnset(appJSON, "Photoshop", ns)
                    return
                }

                xml := adobeXML(userShortcutFile)
                for k, v in appJSON {
                    if k ~= "^_*newSection$" ;// ignore any `____newSection`
                        continue
                    try xmlHotkey := xml.__psBuildHotkey(v["type"], v["name"])
                    overrideVal := this.getOverride(which, k)
                    if !overrideVal && (!IsSet(xmlHotkey) || (IsSet(xmlHotkey) && IsObject(xmlHotkey) && xmlHotkey.HasOwnProp('isSet') && xmlHotkey.isSet = false)) {
                        errorLog(ValueError("Could not determine key for KSA", -1, k))
                        ns._undetermined[k] := "Photoshop"
                        continue
                    }
                    buildHotkey := overrideVal != false ? overrideVal : xmlHotkey
                    ns.%k% := buildHotkey
                }
        }
    }

    /** sets the hotkeys for the premiere plugin `Excalibur` */
    setExcaliburKeys() {
        appJSON := JSON.parse(FileRead(this.excaliburJSONFile))
        ns := this.getNamespace("excalibur")
        spellbookExcalFile := A_AppData "\SpellBook\knights_of_the_editing_table.excalibur.json"
        checkExcal  := prem.Excalibur.__isInstalled()
        checkSpell  := FileExist(spellbookExcalFile)
        if !checkExcal || !checkSpell {
            this.doUnset(appJSON, "Excalibur", ns)
            return
        }
        readSpell := JSON.parse(FileRead(spellbookExcalFile))
        adobeReadXML := adobeXML(spellbookExcalFile)
        for k, v in appJSON {
            if k ~= "^_*newSection$" ;// ignore any `____newSection`
                continue

            try xmlHotkey := adobeReadXML.__excaliburBuildHotkey(readSpell["commands"][v["command"]]["shortcut"])
            overrideVal := this.getOverride("excalibur", k)
            if !overrideVal && (!IsSet(xmlHotkey) || (IsSet(xmlHotkey) && xmlHotkey = false)) {
                errorLog(ValueError("Could not determine key for KSA", -1, k))
                ns._undetermined[k] := "Excalibur"
                continue
            }
            buildHotkey := overrideVal != false ? overrideVal : xmlHotkey
            ns.%k% := buildHotkey
        }
    }

    __getLocale() {
        buf := Buffer(85 * 2)
        DllCall("GetSystemDefaultLocaleName", "Ptr", buf, "Int", 85)
        return StrReplace(StrGet(buf, "UTF-16"), "-", "_",,, 1)
    }

    /**
     * handles json files structured as;
     * ```
     * {
     *     "program": {
     *         "hotkeyName": {
     *             "hotkey": "..."
     *           },
     *           ...
     *     },
     *     ...
     * }
     * ```
     * @param {String} [jsonFilepath] the full filepath to the desired json file
     */
    setBasicKeys(jsonFilepath) {
        if !FileExist(jsonFilepath) {
            ;// throw
            errorLog(TargetError("File does not exist", -2, jsonFilepath),,, true)
            return
        }
        try jsonFile := JSON.parse(FileRead(jsonFilepath))
        catch as e{
            throw e
        }
        for prog, obj in jsonFile {
            ns := this.getNamespace(prog)
            for k, v in obj {
                if k ~= "^_*newSection$" ;// ignore any `____newSection`
                    continue
                overrideVal := this.getOverride(prog, k)
                ns.%k% := overrideVal != false ? overrideVal : v["hotkey"]
            }
        }
    }
}

if A_ScriptName != "Core Functionality.ahk" && winExt.ExistRegex("Core Functionality.ahk ahk_class AutoHotkey",,,, true) {
    KSA := CLSID_Objs.clone("KSA")
}