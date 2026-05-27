/************************************************************************
 * @description A class to generate variables based off the user's keyboard shortcuts
 * @author tomshi
 * @date 2026/05/27
 * @version 2.0.0alpha2
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

class KeyShortAdjust2 {
    __New() {
        if !DirExist(A_MyDocuments "\tomshi\KSA")
            DirCreate(A_MyDocuments "\tomshi\KSA")
        if !FileExist(A_MyDocuments "\tomshi\KSA\override.json")
            FileAppend("{`n`n}", A_MyDocuments "\tomshi\KSA\override.json")
        this.override := JSON.parse(FileRead(this.overrideLocation))
        this.setAdobeKeys("prem")
        this.setAdobeKeys("ae")
        this.setBasicKeys(this.psJSONFile)
        this.setBasicKeys(this.resolveJSONFile)
        this.setBasicKeys(this.windowsJSONFile)
    }

    overrideLocation => A_MyDocuments "\tomshi\KSA\override.json"
    override := ""
    jsonsDir => A_AppData "\tomshi\lib\KSA\json files"
    premJSONFile => this.jsonsDir "\prem hotkeys.json"
    aeJSONFile => this.jsonsDir "\ae hotkeys.json"
    psJSONFile => this.jsonsDir "\ps hotkeys.json"
    resolveJSONFile => this.jsonsDir "\resolve hotkeys.json"
    windowsJSONFile => this.jsonsDir "\windows hotkeys.json"

    unsetMethod(hotkeyname, program) {
        throw UnsetError("This hotkey could not be used as it failed to be set during KSA. " program " may not be installed", -1, hotkeyname)
    }
    undeterminedMethod(hotkeyname, program) {
        throw UnsetError("This hotkey could not be used as the user does not currently have it set within " program, -1, hotkeyname)
    }

    setAdobeKeys(which) {
        isUnset := false
        appJSON := JSON.parse(FileRead(this.%which%JSONFile))
        exeName := (which = "prem") ? {baseName: "Adobe Premiere Pro.exe", beta:"Adobe Premiere Pro (Beta).exe"} : {baseName: "AfterFX.exe", beta: "AfterFX (Beta).exe"} ;// idk if ae is right here

        if !appVers := determineAdobeVer(exeName)
            isUnset := true
        ;// check that ae also has year in path
        SplitPath(appVers.path,, &appYear)
        yearVer := SubStr(appYear, -2)
        ;// need to determine if beta
        switch which {
            case "prem":
                premPrefsDir := A_MyDocuments "\Adobe\Premiere Pro\" yearVer ".0\Profile-" A_UserName
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
                    for k, v in appJSON {
                        this.%k% := this.unsetMethod(k, "Premiere")
                    }
                    return
                }

                xml := adobeXML(userShortcutFile)
                for k, v in appJSON {
                    try xmlHotkey := xml.__premBuildHotkey(v["context"], v["command"])
                    catch {
                        xmlHotkey := this.undeterminedMethod(k, "Premiere")
                    }
                    currentHotkey := (this.override.Has(k) ? this.override.%k%.v["hotkey"] : xmlHotkey)
                    this.%k% := currentHotkey
                }
            case "ae":
                ;// figure out ae hotkey filepath stuff
                ;// in mac;
                ;'/Users/tom/Library/Preferences/Adobe/After Effects/26.2/Adobe After Effects 26.2 Prefs.txt'
                ;["General Section"]
                ;"Shortcut File Location" = "custom.txt"
                ;so; /Users/tom/Library/Preferences/Adobe/After Effects/26.2/aeks/custom.txt
                if !FileExist(aePrefs) || (IsSet(userShortcutFile) && !FileExist(userShortcutFile))
                    isUnset := true
                if isUnset = true {
                    for k, v in appJSON {
                        this.%k% := this.unsetMethod(k, "After Effects")
                    }
                    return
                }

                for k, v in appJSON {
                    aeHotkeyIniVal := IniRead(userShortcutFile, v["context"], v["command"], "")
                    if aeHotkeyIniVal = "" && !this.override.Has(k)
                        xmlHotkey := this.undeterminedMethod(k, "Premiere")
                    buildHotkey := (this.override.Has(k)) ? this.override.%k%.v["hotkey"] : adobeXML(userShortcutFile).__aeBuildHotkey(aeHotkeyIniVal)
                    this.%k% := buildHotkey
                }
        }
    }

    setBasicKeys(jsonFilepath) {
        jsonFile := JSON.parse(FileRead(jsonFilepath))
        for k, v in jsonFile {
            this.%k% := v["hotkey"]
        }
    }
}