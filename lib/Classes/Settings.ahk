/************************************************************************
 * @description A class to create & interact with `settings.ini`
 * @author tomshi
 * @date 2023/07/23
 * @version 1.2.7.1
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
    defaults := ["true", "false", "", "false", "true", "true", "true", "true", "true", "false", "false", 45, 2, 5, 2.5, 5, "2022", "2022", "v23.5", "v23.5", "v24.5", "v18.5", "F:\Adobe Cache\Prem", "F:\Adobe Cache\AE", 0, this.workingDir, "false", "false", 0, "v2.0"]
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
        switch key {
            case "adobe_GB":                          return 45
            case "adobe_FS":                          return 2
            case "autosave_MIN":                      return 5
            case "game_SEC":                          return 2
            case "multi_SEC":                         return 5
            case "prem_year", "ae_year":              return 2023
            case "version":                           return "v2.0"
            case "monitor_alert":                     return "0"
            case "premVer":                           return "v23.5"
            case "aeVer":                             return "v23.5"
            case "psVer":                             return "v24.5"
            case "resolveVer":                        return "v18.5"
            case "update_check":                      return "true"
            case "dark_mode":                         return ""
            case "autosave_check_checklist",
                 "tooltip", "checklist_tooltip",
                 "prem_Focus_Icon", "checklist_hotkeys",
                 "autosave_beep":
                                                      return "true"
            case "beta_update_check",
                 "run_at_startup", "checklist_wait",
                 "first_check", "block_aware":
                                                      return "false"
            default:                                  return "false"
        }
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
                    dark mode={}
                    run at startup={}
                    autosave beep={}
                    autosave check checklist={}
                    tooltip={}
                    checklist hotkeys={}
                    checklist tooltip={}
                    checklist wait={}
                    prem Focus Icon={}

                    [Adjust]
                    adobe GB={}
                    adobe FS={}
                    autosave MIN={}
                    game SEC={}
                    multi SEC={}
                    prem year={}
                    ae year={}
                    premVer={}
                    aeVer={}
                    psVer={}
                    resolveVer={}
                    premCache={}
                    aeCache={}

                    [Track]
                    adobe temp={}
                    working dir={}
                    first check={}
                    block aware={}
                    monitor alert={}
                    version={}
                )", filelocation)
                ;// replace {}
                workingFile := FileRead(filelocation)
                loop this.defaults.Length {
                    workingFile := StrReplace(workingFile, "{}", this.defaults[A_Index],,, 1)
                    if A_Index = this.defaults.Length
                        {
                            FileDelete(filelocation)
                            FileAppend(workingFile, filelocation)
                        }
                }
    }
}