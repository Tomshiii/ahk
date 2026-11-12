/**
 * returns the current system `Locale`. ie; `en_US`
 * @returns {String}
 */
getSystemLocale() {
    buf := Buffer(85 * 2)
    DllCall("GetSystemDefaultLocaleName", "Ptr", buf, "Int", 85)
    return StrReplace(StrGet(buf, "UTF-16"), "-", "_",,, 1)
}