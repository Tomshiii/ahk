#Include <Classes\Settings>
#Include <Classes\ptf>

/**
 * This function checks for the users default dark mode setting and applies it to the checklist script
 */
checkDark() {
    if !FileExist(UserSettings.SettingsFile)
        return 0
    location := UserSettings.working_dir
    darkSettings := UserSettings.dark_mode
    returnVar := darkSettings ? 1 : 0
    return returnVar
}

/**
 * This function checks for the users defaul checklist tooltips setting and applies it to the checklist script
 */
checkTooltips() {
    if !FileExist(UserSettings.SettingsFile)
        return 0
    location := UserSettings.working_dir
    tooltipSettings := UserSettings.checklist_tooltip
    returnVar := tooltipSettings ? 1 : 0
    return returnVar
}