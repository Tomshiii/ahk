#Include <Classes\ptf>
#Include <Classes\errorLog>

/**
 * This function will attempt to generate a shortcut of either Premiere or After Effects to the users `..\Support Files\shortcuts\` folder
 * @param {Object} userSettingsObj the object containing the user's instance of `UserPrefs()`. Often seen as `UserSettings := UserPrefs()`
 * @param {String} adobeName the full name of the desired program. Either `Adobe Premiere Pro`, `Adobe After Effects` or `Photoshop`
 * @param {Integer} adobeYear the year value you wish to determine the logic for.
 */
generateAdobeShortcut(userSettingsObj, adobeName, adobeYear) {
    if Type(userSettingsObj) != "UserPref" {
        ;// throw
        errorLog(ValueError("Incorrect Value type passed in Parameter #1`nNeeds to be UserPref", -1),,, 1)
    }
    if adobeName != "Adobe Premiere Pro" && adobeName != "Adobe After Effects" && adobeName != "Photoshop" {
        ;// throw
        errorLog(ValueError("Incorrect Value set in Parameter #2", -1, adobeName),,, 1)
    }
    switch adobeName {
        case "Adobe Premiere Pro", "Adobe After Effects":
            ;// determining some variables
            ahkEXE     := (adobeName = "Adobe Premiere Pro") ? adobeName ".exe" : "AfterFX.exe"
            ahkEXEBeta := (adobeName = "Adobe Premiere Pro") ? adobeName " (Beta).exe" : "AfterFX (Beta).exe"
            shortName  := (adobeName = "Adobe Premiere Pro") ? "prem" : "ae"
            ;// determining if we need to include an additional folder for AE
            aeFolder := (adobeName = "Adobe After Effects") ? "Support Files\" : ""
            ;// the location of the exe we're generating a shortcut for
            exeLocation := (userSettingsObj.%shortName%IsBeta = false || userSettingsObj.%shortName%IsBeta = "false") ? A_ProgramFiles "\Adobe\" adobeName A_Space adobeYear "\" aeFolder ahkEXE
                                                                       : A_ProgramFiles "\Adobe\" adobeName A_Space "(Beta)\" aeFolder ahkEXEBeta
        case "Photoshop":
            ;// determining some variables
            ahkEXE     := adobeName ".exe"
            ahkEXEBeta := adobeName " (Beta).exe"
            shortName  := "ps"
            ;// the location of the exe we're generating a shortcut for
            exeLocation := (userSettingsObj.%shortName%IsBeta = false || userSettingsObj.%shortName%IsBeta = "false") ? A_ProgramFiles "\Adobe\Adobe " adobeName A_Space adobeYear "\" ahkEXE
                                                                       : A_ProgramFiles "\Adobe\Adobe " adobeName A_Space "(Beta)\" ahkEXEBeta
    }
    ;// where the shortcut will be generated+name
    shortcutLocation := ptf.SupportFiles "\shortcuts\" ahkEXE ".lnk"
    try FileCreateShortcut(exeLocation, shortcutLocation)
}