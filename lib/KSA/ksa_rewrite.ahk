/************************************************************************
 * @description A class to generate variables based off the user's keyboard shortcuts
 * @author tomshi
 * @date 2026/05/26
 * @version 2.0.0
***********************************************************************/

;{ \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Mip.ahk
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
        this.setPremKeys()
    }

    overrideLocation => A_MyDocuments "\tomshi\KSA\override.json"
    override := ""
    jsonsDir => A_AppData "\tomshi\lib\KSA\json files"

    unsetMethod(hotkeyname, program) {
        throw UnsetError("This hotkey could not be used as it failed to be set during KSA. " program " may not be installed", -1, hotkeyname)
    }
    undeterminedMethod(hotkeyname, program) {
        throw UnsetError("This hotkey could not be used as the user does not currently have it set within " program, -1, hotkeyname)
    }

    setPremKeys() {
        premUnset := false
        premJSONFile := this.jsonsDir "\prem hotkeys.json"
        premJSON := JSON.parse(FileRead(premJSONFile))

        if !premVers := determineAdobeVer({baseName: "Adobe Premiere Pro.exe", beta:"Adobe Premiere Pro (Beta).exe"})
            premUnset := true
        SplitPath(premVers.path,, &premYear)
        yearVer := SubStr(premYear, -2)
        ;// need to determine if beta
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
            premUnset := true
        if premUnset = true {
            for k, v in premJSON {
                this.%k% := this.unsetMethod(k, "Premiere")
            }
            return
        }

        xml := adobeXML(userShortcutFile)
        for k, v in premJSON {
            try xmlHotkey := xml.__premBuildHotkey(v["context"], v["command"])
            catch {
                xmlHotkey := this.undeterminedMethod(k, "Premiere")
            }
            currentHotkey := (this.override.Has(k) ? this.override.%k%.v["hotkey"] : xmlHotkey)
            this.%k% := currentHotkey
        }
    }
}