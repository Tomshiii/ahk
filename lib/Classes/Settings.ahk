/************************************************************************
 * @description A class to create & interact with `settings.ini`
 * @author tomshi
 * @date 2025/01/01
 * @version 1.2.21
 ***********************************************************************/

class UserPref {
    __New() {
        if !FileExist(this.SettingsFile)
            {
                SplitPath(A_WorkingDir, &name)
                if (name = "classes" || name == "Release Assets")
                    {
                        SetWorkingDir("..\..\")
                        this.workingDir := A_WorkingDir
                        this.defaults["working_dir"] := A_WorkingDir
                    }
                this.__createIni()
                Run(A_ScriptFullPath)
            }
        ;// initialise settings variables
        this.__setSett()
        this.__setAdjust()
        this.__setTrack()
    }

    ;// defaults
    workingDir := A_WorkingDir
    defaults := Map(
        ;// [Settings]
        "update_check", "true", "beta_update_check", "false", "package_update_check", "true", "lib_update_check", "true", "ahk_update_check", "true", "update_adobe_verAHK", "true",
        "dark_mode", "",
        "run_at_startup", "false", "show_adobe_vers_startup", "true",
        "autosave_beep", "true", "autosave_check_checklist", "true", "autosave_save_override", "true", "autosave_check_mouse", "true",
        "autosave_always_save", "true", "autosave_restart_playback", "false",
        "checklist_hotkeys", "true", "checklist_tooltip", "true", "checklist_wait", "false",
        "prem_Focus_Icon", "false", "tooltip", "true", "disc_disable_autoreply", "true", "adobeExeOverride", "true",
        "Always Check UIA", "true", "Set UIA Limit Daily", "disabled",

        ;// [Adjust]
        "adobe_GB", 45, "adobe_FS", 2,
        "autosave_MIN",  5, "game_SEC",  2, "multi_SEC", 5,
        "prem_year", 2024, "ae_year", 2024, "ps_year", 2024,
        "premVer", "v24.4.1", "aeVer", "v24.4.1", "psVer", "25.5", "resolveVer", "v18.5",
        "premIsBeta", "false", "aeIsBeta", "false", "psIsBeta", "false",
        "premCache", A_AppData "\Adobe\Common", "aeCache", A_AppData "\Adobe\Common",

        ;// [Track]
        "adobe_temp", 0, "UIA_Daily_Limit_Day", 0, "working_dir", this.workingDir,
        "first_check", "false", "block_aware", "false",
        "version", "v2.0", "skipVersion", "v2.0",
        "monitor_alert", "0",
        "MainScriptName", "My Scripts"
    )
    ;// define settings location
    SettingsDir  => A_MyDocuments "\tomshi"
    SettingsFile => this.SettingsDir "\settings.ini"

    /**
     * A function to provide the default for each .ini value
     * @param {String} key the key name
     */
    __getDefault(key) {
        if InStr(key, A_Space)
            key := StrReplace(key, A_Space, "_")
        return(this.defaults.Has(key) ? this.defaults[key] : "false")
    }

    /**
     * Convert boolean strings to proper boolean values
     * @param {String} key "true" or "false"
     * @param {String} section the section name of the ini file currently being read from
     */
    __convertToBool(key, section) {
        default := this.__getDefault(key)
        getVal := IniRead(this.SettingsFile, section, key, default)
        switch getVal {
            case "true":              return true
            case "false":             return false
            case "disabled", "stop":  return getVal
            default:                  return default
        }
    }

    /**
     * Convert boolean values to boolean strings
     * @param {Boolean} bool 1 or 0 (true/false)
     */
    __convertToStr(bool) {
        switch bool {
            case 1:  return "true"
            case 0:  return "false"
        }
    }

    /**
     * Remove underscores from variable names to find its respective ini value
     * @param {String} var the variable name
     */
    __convertToKey(var) => StrReplace(var, "_", A_Space)

    /**
     * This function is what the class will do on exit
     * It will check the current settings stored in the object and will write that setting to file if it differs from the initial value
     * @param {Array} arr the array you wish to enum through
     * @param {String} section the corresponding section name in the settings ini file
     */
    __del(arr, section) {
        for v in arr {
            try {
                writeVal := ((this.%v% = 1 || this.%v% = 0) && (section != "Adjust") )? RTrim(this.__convertToStr(this.%v%), " ") : this.%v%
                ;// Don't want a default value here, if something errors out during the deletion of the class, we don't want it
                ;// returning back to the default value instead of leaving it how it currently is
                prior_value := IniRead(this.SettingsFile, section, this.__convertToKey(v))
                if this.%v% != prior_value
                    IniWrite(writeVal, this.SettingsFile, section, this.__convertToKey(v))
            }
        }
    }

    /**
     * This function reads an entire .ini section and pushes every key to the designated array
     * Any whitespace is converted to "_"
     * @param {String} section is the section you wish to be read from
     * @param {Array} arr is the desired array you wish to push to
     */
    __fillArr(section, arr) {
        allSettings   := IniRead(this.SettingsFile, section)
        splitSettings := StrSplit(allSettings, ["=", "`n", "`r"])
        for k, v in splitSettings {
            if Mod(k, 2) = 0
                continue
            arr.Push(StrReplace(v, A_Space, "_"))
        }
    }

    /**
     * Checks the current version value for an `alpha` or `beta` tag and ensures it's formatted correctly so `VerCompare` will work as expected
     */
    __checkPreReleaseTag(value) {
        if ((alpha := InStr(value, "alpha")) || (beta := InStr(value, "beta"))) {
            which := (alpha != 0) ? "alpha" : "beta"
            value := (SubStr(value, %which%-1, 1) != "-") ? SubStr(value, 1, %which%-1) "-" SubStr(value, %which%)
                                                          : value
            value := SubStr(value, pos := InStr(value, which)+StrLen(which)-1, 1) != "." ? SubStr(value, 1, pos) "." SubStr(value, pos+1)
                                                          : value
        }
    }

    ;// [Settings]
    Settings_ := []
    __setSett() {
        this.__fillArr("Settings", this.Settings_)
        ;// create variables
        for v in this.Settings_ {
            this.%v% := this.__convertToBool(this.__convertToKey(v), "Settings")
        }
    }
    ;// [Adjust]
    Adjust_ := []
    __setAdjust() {
        this.__fillArr("Adjust", this.Adjust_)
        ;// create variables
        for v in this.Adjust_ {
            defaultVal := this.__getDefault(v)
            this.%v% := IniRead(this.SettingsFile, "Adjust", this.__convertToKey(v), defaultVal)
        }
    }
    ;// [Track]
    Track_ := []
    __setTrack() {
        this.__fillArr("Track", this.Track_)
        ;// create variables
        for v in this.Track_ {
            switch v {
                case "first_check", "block_aware":
                    this.%v% := this.__convertToBool(this.__convertToKey(v), "Track")
                case "version":
                    defaultVal := this.__getDefault(v)
                    value := IniRead(this.SettingsFile, "Track", this.__convertToKey(v), defaultVal)
                    origVal := value
                    this.__checkPreReleaseTag(value)
                    this.%v% := (value != origVal) ? value : origVal
                default:
                    defaultVal := this.__getDefault(v)
                    this.%v% := IniRead(this.SettingsFile, "Track", this.__convertToKey(v), defaultVal)
            }
        }
    }

    __delAll() {
        this.__del(this.Settings_, "Settings")
        this.__del(this.Adjust_, "Adjust")
        this.__del(this.Track_, "Track")
    }

    /**
     * This function generates a baseline settings.ini file
     */
    __createIni(filelocation := this.SettingsFile) {
        /* if params.Length > this.defaults.Length
            throw (ValueError("Incorrect number of Parameters passed to function.", -1)) ;// don't add errorlog to this function, keep it no dependencies */
        if !DirExist(this.SettingsDir)
            DirCreate(this.SettingsDir)
        if FileExist(filelocation)
            FileDelete(filelocation)
        FileAppend("
                (
                    [Settings]
                    update check={}
                    beta update check={}
                    ahk update check={}
                    update adobe verAHK={}
                    package update check={}
                    lib update check={}
                    dark mode={}
                    run at startup={}
                    show adobe vers startup={}
                    autosave beep={}
                    autosave check checklist={}
                    autosave save override={}
                    autosave check mouse={}
                    autosave always save={}
                    autosave restart playback={}
                    tooltip={}
                    checklist hotkeys={}
                    checklist tooltip={}
                    checklist wait={}
                    prem Focus Icon={}
                    disc disable autoreply={}
                    adobeExeOverride={}
                    Always Check UIA={}
                    Set UIA Limit Daily={}

                    [Adjust]
                    adobe GB={}
                    adobe FS={}
                    autosave MIN={}
                    game SEC={}
                    multi SEC={}
                    prem year={}
                    ae year={}
                    ps year={}
                    premVer={}
                    premIsBeta={}
                    aeVer={}
                    aeIsBeta={}
                    psVer={}
                    psIsBeta={}
                    resolveVer={}
                    premCache={}
                    aeCache={}

                    [Track]
                    adobe temp={}
                    UIA Daily Limit Day={}
                    working dir={}
                    first check={}
                    block aware={}
                    monitor alert={}
                    skipVersion={}
                    MainScriptName={}
                    version={}
                )", filelocation)
                ;// replace {}
                workingFile := FileRead(filelocation)
                eachLine := StrSplit(workingFile, ["`n", "`r"])
                currentSection := ""
                for v in eachLine {
                    if v = ""
                        continue
                    if InStr(v, "[") && InStr(v, "]") {
                        currentSection := SubStr(v, 2, StrLen(v)-2)
                        continue
                    }
                    splitLine := StrSplit(v, "=")
                    IniWrite(this.__getDefault(splitLine[1]), filelocation, currentSection, splitLine[1])
                }
    }
}