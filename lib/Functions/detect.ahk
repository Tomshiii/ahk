/**
 * A function to cut repeat code and set some values required to detect ahk scripts
 * @param {Boolean} windows is what hidden window mode you wish for the script to take. This value `defaults to true`
 * @param {Integer/String} title is what title match mode you wish for the script to take. This value `defaults to 2`
 * @return {Object} returns the original `A_DetectHiddenWindows` & `A_TitleMatchMode` states
 * ```
 * dct := detect()
 * dct.Windows      ;// returns the original `A_DetectHiddenWindows` value
 * dct.Title        ;// returns the original `A_TitleMatchMode` value
 * ```
 */
detect(windows := true, title := 2) {
    origWindows := A_DetectHiddenWindows, origTitle := A_TitleMatchMode
    DetectHiddenWindows(windows), SetTitleMatchMode(title)
    return {Windows: origWindows, Title: origTitle}
}