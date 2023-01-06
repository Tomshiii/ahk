#Include <Classes\ptf>

/**
 * This function checks for the users default dark mode setting and applies it to the checklist script
 */
checkDark() {
    if !FileExist(ptf["settings"])
        return 0
    location := IniRead(ptf["settings"], "Track", "working dir")
    darkSettings := IniRead(ptf["settings"], "Settings", "dark mode", "true")
    returnVar := darkSettings ? 1 : 0
    return returnVar
}

/**
 * This function checks for the users defaul checklist tooltips setting and applies it to the checklist script
 */
checkTooltips() {
    if !FileExist(ptf["settings"])
        return 0
    location := IniRead(ptf["settings"], "Track", "working dir")
    tooltipSettings := IniRead(ptf["settings"], "Settings", "checklist tooltip", "true")
    returnVar := tooltipSettings ? 1 : 0
    return returnVar
}