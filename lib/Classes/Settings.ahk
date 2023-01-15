/************************************************************************
 * @description A class to create & interact with `settings.ini`
 * @author tomshi
 * @date 2023/01/15
 * @version 1.0.0b1
 ***********************************************************************/

; { \\ #Includes
#Include <Functions\createIni>
; }

class UserPref {
    __New() {
        SetWorkingDir(A_LineFile "\..\..\..\") ;// the root dir of the repo
        if !FileExist(this.SettingsFile)
            {
                createIni(this.SettingsDir, "true", "false", "", "false", "true", "true", "true", "false", 45, 5, 5, 2.5, 5, "2022", "2022", "v22.3.1", "v22.6", "v24.0.1", "v18.0.4", 0, A_WorkingDir, "false", "false", 0, 0)
                ;// if initially run from anything other than `My Scripts` we can simply reload
                ;// otherwise we need to completely rerun `My Scripts` to ensure all
                ;// `startup` functions fire
                if A_ScriptName != "My Scripts.ahk"
                    Reload()
                else
                    {
                        RunWait(A_ScriptFullPath)
                        return
                    }
            }
        ;// initialise settings variables
        this.__setSett()
        this.__setAdjust()
        this.__setTrack()
    }
    ;// define settings location
    SettingsDir => A_MyDocuments "\tomshi"
    SettingsFile => this.SettingsDir "\settings.ini"

    /**
     * A function to provide the default for each .ini value
     */
    __getDefault(key) {
        switch key {
            case "adobe_GB":              return 45
            case "adobe_FS":              return 2
            case "autosave_MIN":          return 5
            case "game_SEC":              return 2
            case "multi_SEC":             return 5
            case "prem_year", "ae_year":  return 2022
            case "version":               return 0
            case "premVer":               return "v22.3.1"
            case "aeVer":                 return "v22.6"
            case "psVer":                 return "v24.0.1"
            case "resolveVer":            return "v18.0.4"
            case "update check":          return "true"
            case "dark mode":             return ""
            case "autosave_check_checklist", "tooltip", "checklist_tooltip":
                return "true"
            case "beta_update_check", "run_at_startup", "checklist_wait", "first_check", "block_aware":
                return "false"
            default:
                return "false"
        }
    }

    /**
     * Convert boolean strings to proper boolean values
     * @param {String} key "true" or "false"
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
            writeVal := (this.%v% = 1 || this.%v% = 0) ? RTrim(this.__convertToStr(this.%v%), " ") : this.%v%
            ;//! add a default below here
            prior_value := IniRead(this.SettingsFile, section, this.__convertToKey(v))
            if this.%v% != prior_value
                IniWrite(writeVal, this.SettingsFile, section, this.__convertToKey(v))
        }
    }

    ;// [Settings]
    Settings_ := []
    __setSett() {
        ;// read the entire section within the ini file and push to array
        allSettings   := IniRead(this.SettingsFile, "Settings")
        splitSettings := StrSplit(allSettings, ["=", "`n", "`r"])
        for k, v in splitSettings {
            if Mod(k, 2) = 0
                continue
            this.Settings_.Push(StrReplace(v, A_Space, "_"))
        }
        ;// create variables
        for v in this.Settings_ {
            this.%v% := this.__convertToBool(this.__convertToKey(v), "Settings")
        }
    }
    ;// [Adjust]
    Adjust_ := []
    __setAdjust() {
        ;// read the entire section within the ini file and push to array
        allSettings   := IniRead(this.SettingsFile, "Adjust")
        splitSettings := StrSplit(allSettings, ["=", "`n", "`r"])
        for k, v in splitSettings {
            if Mod(k, 2) = 0
                continue
            this.Adjust_.Push(StrReplace(v, A_Space, "_"))
        }
        ;// create variables
        for v in this.Adjust_ {
            default := this.__getDefault(v)
            this.%v% := IniRead(this.SettingsFile, "Adjust", this.__convertToKey(v), default)
        }
    }
    ;// [Track]
    Track_ := []
    __setTrack() {
        ;// read the entire section within the ini file and push to array
        allSettings   := IniRead(this.SettingsFile, "Track")
        splitSettings := StrSplit(allSettings, ["=", "`n", "`r"])
        for k, v in splitSettings {
            if Mod(k, 2) = 0
                continue
            this.Track_.Push(StrReplace(v, A_Space, "_"))
        }
        ;// create variables
        for v in this.Track_ {
            switch v {
                case "first_check", "block_aware":
                    this.%v% := this.__convertToBool(this.__convertToKey(v), "Track")
                default:
                    ; default := this.__getDefault(v)
                    this.%v% := IniRead(this.SettingsFile, "Track", this.__convertToKey(v))
            }
        }
    }

    __Delete() {
        this.__del(this.Settings_, "Settings")
        this.__del(this.Adjust_, "Adjust")
        this.__del(this.Track_, "Track")
    }
}

UserSettings := UserPref()