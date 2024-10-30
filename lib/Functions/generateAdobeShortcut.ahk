; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\errorLog>
#Include <Other\Notify>
; }

/**
 * This function will attempt to generate a shortcut of either Premiere or After Effects to the users `..\Support Files\shortcuts\` folder
 * @param {Object} userSettingsObj the object containing the user's instance of `UserPrefs()`. Often seen as `UserSettings := UserPrefs()`
 * @param {String} adobeName the full name of the desired program. Either `Adobe Premiere Pro`, `Adobe After Effects` or `Photoshop`
 * @param {Integer} adobeYear the year value you wish to determine the logic for.
 * @returns {Boolean} returns `false` if the desired file directory does not exist else `true`
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
    if !FileExist(exeLocation)
        return false
    try FileCreateShortcut(exeLocation, shortcutLocation)
    catch {
        Notify.Show("Unknown Error Occured", "An error occurred trying to generate the file shortcut", 'iconx', 'soundx',, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')
        errorLog(Error("An error occurred trying to generate the file shortcut", -1))
        return false
    }
    return true
}