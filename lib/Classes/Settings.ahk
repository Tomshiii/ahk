/************************************************************************
 * @description A class to create & interact with `settings.ini`
 * @author tomshi
 * @date 2026/10/02
 * @version 1.5.0
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Mip.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\errorLog.ahk
#Include Functions\formatPreReleaseTag.ahk
; }

class UserPref {
    /**
     * @param [override=false] for scripts other than `Core Functionality.ahk` if set to `true` will generate and return its own local settings instance
     * @param [checkVals=false] when set to `true` will sync the user's `settings.ini` against a fresh template in place (missing keys added with defaults, stale keys removed, existing values untouched). When `false` the file is used as-is. `Core Functionality.ahk` always syncs
     * @constructor
     */
    __New(override := false, checkVals := false) {
        if this.ignoreVersionWarningList.has(A_ScriptName) && !FileExist(this.installDir) || !FileExist(A_AppData "\tomshi\version") {
            if !DirExist(A_AppData "\tomshi")
                DirCreate(A_AppData "\tomshi")
            (!FileExist(A_AppData "\tomshi\version")) ? FileAppend("v2.18.0", A_AppData "\tomshi\version") : ""
            if !FileExist(this.installDir) {
                switch A_ScriptName {
                    case "Multi Download", "mult-dl.ahk": FileAppend(A_ScriptFullPath, this.installDir)
                }
            }
        }
        if !FileExist(this.installDir) {
            throw TargetError("lib files have not been installed.")
        }
        this._store := {}
        if !FileExist(this.SettingsFile) {
            this.__createIni()
            ; Run(A_ScriptFullPath)
        } else if checkVals = true || A_ScriptName = "Core Functionality.ahk" {
            this.__syncIni()
        }
        if A_ScriptName != "Core Functionality.ahk" {
            if override = false
                return
        }
        ;// initialise settings variables
        this.__setSett()
        this.__setAdjust()
        this.__setTrack()

        if A_ScriptName = "Core Functionality.ahk" {
            this.doValChecks()
        }
    }

    ;// defaults
    workingDir := A_WorkingDir
    defaults := Map(
        ;// [Settings]
        "update_check", "true", "beta_update_check", "false", "package_update_check", "true", "lib_update_check", "true", "ahk_update_check", "true", "update_adobe_vers", "true", "update_git", "false",
        "dark_mode", "false",
        "run_at_startup", "false", "show_adobe_vers_startup", "true",
        "autosave_beep", "true", "autosave_check_checklist", "true", "autosave_save_override", "true", "autosave_check_mouse", "true",
        "autosave_always_save", "true", "autosave_restart_playback", "false",
        "checklist_hotkeys", "true", "checklist_tooltip", "true", "checklist_wait", "false",
        "tooltip", "true", "disc_disable_autoreply", "true", "adobeExeOverride", "true",
        "Use_Thio_MButton", "false", "Use_MButton", "true",
        "Use_swapSequences", "true",
        "Set_UIA_on_reload", "true", "UIA_show_Icon", "true",

        ;// [Adjust]
        "adobe_GB", 100, "adobe_FS", 2,
        "autosave_MIN",  5, "game_SEC",  2, "multi_SEC", 5,
        "prem_year", 2026, "ae_year", 2026, "ps_year", 2026,
        "premVer", "v26.2", "aeVer", "v26.0", "psVer", "25.5", "resolveVer", "v18.5",
        "premIsBeta", "false", "aeIsBeta", "false", "psIsBeta", "false",
        "premCache", A_AppData "\Adobe\Common", "aeCache", A_AppData "\Adobe\Common",
        "premDefaultTheme", "Darkest", "premPrevSeqDelay", "1.5", "premSwapSequencesLimit", 3,
        "alternate_MButton_Key", "~F18",
        "toggleEnabled_ignore", "5",

        ;// [Track]
        "adobe_temp", 0,
        "first_check", "false", "block_aware", "false",
        "version", "v2.18.0", "skipVersion", "v2.0",
        "monitor_alert", "0"
    )
    ;// define settings location
    SettingsDir  => A_MyDocuments "\tomshi"
    SettingsFile => this.SettingsDir "\settings.ini"
    installDir => A_Appdata "\tomshi\installDir"
    ignoreVersionWarningList := Mip("Multi Download", true, "mult-dl.ahk", true)

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
     * @returns {Boolean|String} if the value is `"true"`/`"false"` returns `true`/`false`. If `"disabled"` or `"stop"`, returns those strings. Else returns the default value
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
     * @param {Boolean} bool 1 or 0
     * @returns {String} `"true"` or `"false"`
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
     * This function reads an entire .ini section and pushes every key to the designated array
     * Any whitespace is converted to "_"
     * @param {String} section is the section you wish to be read from
     * @param {Array} arr is the desired array you wish to push to
     * @param {String} [settingsFile=this.settingsFile] which settings file you wish to be used during the `IniRead`
     */
    __fillArr(section, arr, settingsFile := this.SettingsFile) {
        allSettings   := IniRead(settingsFile, section)
        splitSettings := StrSplit(allSettings, ["=", "`n", "`r"])
        for k, v in splitSettings {
            if Mod(k, 2) = 0
                continue
            arr.Push(StrReplace(v, A_Space, "_"))
        }
    }

    /** This function checks whether the user is on a late enough version of windows to use dark mode */
    __checkDark() {
        if (VerCompare(A_OSVersion, "10.0.17763") < 0) {
            this.dark_mode := "disabled"
            return "disabled"
        }
        return true
    }

    /** ensures the current version is set correctly formatted */
    __setVersion() {
        if !FileExist(A_AppData "\tomshi\version")
            throw TargetError("version file has been moved or deleted")
        ver := formatPreReleaseTag(FileRead(A_AppData "\tomshi\version"))
        currentSettingsVer := formatPreReleaseTag(IniRead(this.SettingsFile, "Track", "version", "v2.18.0"))
        if currentSettingsVer != ver {
            IniWrite(ver, this.SettingsFile, "Track", "version")
        }
        this.__defineProp("version", "Track", ver)
    }

    doValChecks() {
        this.__setVersion()
        this.__checkDark()
    }

    /**
     * Syncs the user's `settings.ini` with the current template **in place**.
     * - keys missing from the user's file are added with their default value
     * - keys/sections no longer in the template are removed
     * - every other value is left untouched, so the user's settings are preserved
     *
     * The file is never deleted, so a failure part way through can't wipe the user's settings.
     */
    __syncIni() {
        tempDir := A_Temp "\tomshi"
        if !DirExist(tempDir)
            DirCreate(tempDir)
        tmp := tempDir "\template.ini"
        this.__createIni(tmp)

        ;// read the fresh template into maps
        tmplSections := Map(), tmplSections.CaseSense := "Off"
        tmplKeys     := Map(), tmplKeys.CaseSense := "Off"
        for section in StrSplit(IniRead(tmp), "`n", "`r") {
            if section = ""
                continue
            tmplSections[section] := true
            for line in StrSplit(IniRead(tmp, section), "`n", "`r") {
                eq := InStr(line, "=")
                if !eq
                    continue
                tmplKeys[section "|" SubStr(line, 1, eq - 1)] := SubStr(line, eq + 1)
            }
        }
        FileDelete(tmp)

        ;// add any missing keys
        missing := "__tomshi_missing__"
        for id, default in tmplKeys {
            parts := StrSplit(id, "|")
            if IniRead(this.SettingsFile, parts[1], parts[2], missing) = missing
                IniWrite(default, this.SettingsFile, parts[1], parts[2])
        }

        ;// remove stale sections / keys
        for section in StrSplit(IniRead(this.SettingsFile), "`n", "`r") {
            if section = ""
                continue
            if !tmplSections.Has(section) {
                IniDelete(this.SettingsFile, section)
                continue
            }
            for line in StrSplit(IniRead(this.SettingsFile, section), "`n", "`r") {
                eq := InStr(line, "=")
                if !eq
                    continue
                key := SubStr(line, 1, eq - 1)
                if !tmplKeys.Has(section "|" key)
                    IniDelete(this.SettingsFile, section, key)
            }
        }
    }

    ;// [Settings]
    Settings_ := []
    __setSett(settingsFile := this.SettingsFile) {
        this.__fillArr("Settings", this.Settings_, settingsFile)
        ;// create variables
        for v in this.Settings_ {
            if !this.HasOwnProp(v) {
                if v = "dark_mode" {
                    dark := this.__checkDark()
                    this.__defineProp(v, "Settings", (dark = "disabled") ? "disabled" : this.__convertToBool(this.__convertToKey(v), "Settings"))
                }
                this.__defineProp(v, "Settings", this.__convertToBool(this.__convertToKey(v), "Settings"))
            }
        }
    }
    ;// [Adjust]
    Adjust_ := []
    __setAdjust(settingsFile := this.SettingsFile) {
        this.__fillArr("Adjust", this.Adjust_, settingsFile)
        for v in this.Adjust_ {
            if !this.HasOwnProp(v) {
                defaultVal := this.__getDefault(v)
                newVal := IniRead(settingsFile, "Adjust", this.__convertToKey(v), defaultVal)
                this.__defineProp(v, "Adjust", newVal)
            }
        }
    }
    ;// [Track]
    Track_ := []
    __setTrack(settingsFile := this.SettingsFile) {
        this.__fillArr("Track", this.Track_, settingsFile)
        for v in this.Track_ {
            if this.HasOwnProp(v)
                continue
            switch v {
                case "first_check", "block_aware":
                    this.__defineProp(v, "Track", this.__convertToBool(this.__convertToKey(v), "Track"))
                case "version": this.__setVersion()
                default:
                    defaultVal := this.__getDefault(v)
                    newVal := IniRead(settingsFile, "Track", this.__convertToKey(v), defaultVal)
                    this.__defineProp(v, "Track", newVal)
            }
        }
    }

    __defineProp(v, section, initialValue) {
        this._store.%v% := initialValue

        this.DefineProp(v, {
            Get: (self) => self._store.%v%,
            Set: (self, value) => (self._store.%v% := value, self.__writeVal(v, section))
        })
    }

    __writeVal(v, section) {
        try {
            writeVal := ((this.%v% = 1 || this.%v% = 0) && (section != "Adjust")) ? RTrim(this.__convertToStr(this.%v%), " ") : this.%v%
            ;// Don't want a default value here, if something errors out during the deletion of the class, we don't want it
            ;// returning back to the default value instead of leaving it how it currently is
            prior_value := IniRead(this.SettingsFile, section, this.__convertToKey(v))
            if writeVal != prior_value
                IniWrite(writeVal, this.SettingsFile, section, this.__convertToKey(v))
        } catch {
            errorLog(ValueError("Failed writing new settings value in section: " section, -1, v))
        }
    }

    settingsTemplate := "
    (
        [Settings]
        update check={}
        beta update check={}
        ahk update check={}
        update adobe vers={}
        update git={}
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
        disc disable autoreply={}
        adobeExeOverride={}
        Set UIA on reload={}
        UIA show Icon={}
        Use Thio MButton={}
        Use MButton={}
        Use swapSequences={}

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
        premSwapSequencesLimit={}
        aeVer={}
        aeIsBeta={}
        psVer={}
        psIsBeta={}
        resolveVer={}
        premCache={}
        aeCache={}
        premDefaultTheme={}
        alternate MButton Key={}
        premPrevSeqDelay={}
        toggleEnabled ignore={}

        [Track]
        adobe temp={}
        first check={}
        block aware={}
        monitor alert={}
        skipVersion={}
        version={}
    )"

    /**
     * This function generates a baseline settings.ini file
     * @param [filelocation=this.SettingsFile] the location of the settings file to create. Defaults to `this.SettingsFile`
     */
    __createIni(filelocation := this.SettingsFile) {
        if !DirExist(this.SettingsDir)
            DirCreate(this.SettingsDir)
        SplitPath(filelocation,, &setDir)
        if setDir != this.SettingsDir {
            if !DirExist(setDir)
                DirCreate(setDir)
        }
        if FileExist(filelocation)
            FileDelete(filelocation)
        FileAppend(this.settingsTemplate, filelocation)
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