#Include <Other\JSON>

class UserSettings {
    __New() {
        if !FileExist(this.SettingsFile)
            {
                ;// use A_LineFile to get location of working dir
            }

        SplitPath(A_LineFile,, &dir)
        this.defaultINI := dir "\..\Settings\defaults.ini"

    }

    ;// define settings location
    SettingsDir  => A_MyDocuments "\tomshi"
    SettingsFile => this.SettingsDir "\settings - Copy.ini"

    /**
     * Parse a section of the settings file and return it as either a map or object
     * @param {String} section the section of the settings file you wish to generate
     * @param {Boolean} keepbooltype sending param to `JSON.parse` haven't figured out what exactly this does yet so just passing it to be safe
     * @param {Boolean} as_map whether you wish for the returned data to be an object or a map. Defaults to `true` (map)
     */
    generate(section, keepbooltype := false, as_map := true) => JSON.parse(IniRead(this.SettingsFile, section), keepbooltype, as_map)

    /**
     * Generates all sections of the settings file and returns an object
     * @returns {Object} containing all settings and their values
     * ```
     * settings := UserSettings().generateAll()
     * ;// all values will be layed out like so:
     * ;// var.[Section]_[Key]
     * settings.Track_blockAware
     * ```
     */
    generateAll() {
        sections := StrSplit(IniRead(this.SettingsFile), ["`n", "`r"])
        allSettings := {}
        for v in sections {
            generateSettings := this.generate(v)
            for k, v2 in generateSettings {
                allSettings.%v%_%k% := v2
            }
        }
        return allSettings
    }

    getDefault(section, key, keepbooltype := false) {
        section := JSON.parse(IniRead(this.defaultINI, section), keepbooltype)
        return section[key]
    }

    /**
     * Copy the default ini file to the desired location, renaming it `settings.ini`
     * @param {String} filelocation the location you wish for the file to be saved to
     */
    __createIni(filelocation := this.SettingsFile) {
        if !DirExist(this.SettingsDir)
            DirCreate(this.SettingsDir)
        if FileExist(filelocation)
            FileDelete(filelocation)
        try FileCopy(A_LineFile "\..\Settings\defaults.ini", filelocation)
    }
}