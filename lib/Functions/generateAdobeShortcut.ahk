; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Classes\errorLog.ahk
#Include Other\Notify\Notify.ahk
#Include Functions\validateTypes.ahk
; }

/**
 * This function will attempt to generate a shortcut of either `Adobe Premiere Pro`, `Adobe After Effects` or `Adobe Photoshop` to the users `..\Support Files\shortcuts\` folder
 * @param {Object} userSettingsObj the object containing the user's instance of `UserPref()`
 * @param {String} adobeName the full name of the desired program. Either `Adobe Premiere Pro`, `Adobe After Effects` or `Adobe Photoshop`
 * @param {Integer} adobeYear the year value you wish to determine the logic for.
 * @returns {Boolean} returns `false` if the desired file directory does not exist else `true`
 */
generateAdobeShortcut(userSettingsObj, adobeName, adobeYear) {
    validateTypes([["UserPref", "ComObject"]], userSettingsObj)
    if adobeName != "Adobe Premiere Pro" && adobeName != "Adobe After Effects" && adobeName != "Adobe Photoshop" {
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
        case "Adobe Photoshop":
            ahkEXE     := InStr(adobeName, "Adobe ",, 1, 1) ? SubStr(adobeName, InStr(adobeName, A_Space,, 1, 1)+1) ".exe"        : adobeName ".exe"
            ahkEXEBeta := InStr(adobeName, "Adobe ",, 1, 1) ? SubStr(adobeName, InStr(adobeName, A_Space,, 1, 1)+1) " (Beta).exe" : adobeName "(Beta).exe"
            shortName  := "ps"
            /* ;// determining some variables
            ;// the location of the exe we're generating a shortcut for
            exeLocation := (userSettingsObj.%shortName%IsBeta = false || userSettingsObj.%shortName%IsBeta = "false") ? A_ProgramFiles "\Adobe\" adobeName A_Space adobeYear "\" ahkEXE
                                                                       : A_ProgramFiles "\Adobe\" adobeName A_Space "(Beta)\" ahkEXEBeta */
            ;// default to latest non beta instead of using usersettings
            full := false, beta := false
            years := Map()
            loop files A_ProgramFiles "\Adobe\*", "D" {
                if !InStr(A_LoopFileName, adobeName)
                    continue
                if InStr(A_LoopFileName, "(Beta)") {
                    beta := true
                    continue
                }
                years.Set(A_LoopFileName, true)
                full := true
            }
            switch {
                case (!full && !beta): return
                case (!full && beta) : exeLocation := A_ProgramFiles "\Adobe\" adobeName A_Space "(Beta)\" ahkEXEBeta
                default:
                    folder := ""
                    for v in years {
                        if A_Index != years.Count
                            continue
                        folder := v
                    }
                    exeLocation := A_ProgramFiles "\Adobe\" folder "\" ahkEXE
            }
        default: return
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