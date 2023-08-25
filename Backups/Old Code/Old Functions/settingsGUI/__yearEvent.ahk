/**
 * This function handled the logic when the year input was an edit control instead of a dropdownlist
 */
__yearEvent(*) {
    if StrLen(year.Value) != 4
        return
    if (year.Value > A_Year + 1 || year.Value < 2013) {
        ver.Delete()
        return
    }
    if SubStr(ver.value, 3, 2) != SubStr(year.Value, 3, 2)
        ver.Delete()
    new := []
    loop files ptf.ImgSearch "\" program "\*", "D" {
        if InStr(A_LoopFileName, "v" SubStr(year.Value, 3, 2))
            new.Push(A_LoopFileName)
    }
    ver.Add(new)
    if !new.Has(1)
        return
    ver.Choose(new.Length)
    UserSettings.%yearIniName% := year.value
    __editAdobeVer(verIniName, ver) ;// call the func to reassign the settings values
    switch adobeFullName {
        case "Adobe Premiere Pro":
            FileCreateShortcut(A_ProgramFiles "\Adobe\" adobeFullName A_Space year.Value "\" shortcutName, ptf.SupportFiles "\shortcuts\" shortcutName ".lnk")
        case "Adobe After Effects":
            FileCreateShortcut(A_ProgramFiles "\Adobe\" adobeFullName A_Space year.Value "\Support Files\" shortcutName, ptf.SupportFiles "\shortcuts\" shortcutName ".lnk")
    }
}