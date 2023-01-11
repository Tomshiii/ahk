
; { \\ #Includes
#Include <Functions\getHotkeys>
#Include <Functions\errorLog>
; }

/**
 * This function is designed to remove the hassle that can sometimes occur by using `KeyWait`. If a function is launched via something like a streamdeck `A_ThisHotkey` will be blank, if you design a function to only be activated with one button but then another user tries to launch it from two an error will be thrown. This function will automatically determine what's required and stop errors occuring
 * @param {String} which determines which hotkey should be waited for in the event that the user tries to activate with two hotkeys
 * @returns {Object} this function can return the two hotkeys as an object the same way that `getHotkeys()` would
 * ```
 * RAlt & p::
 * {
 *    hotkeys := getHotkeys()
 *    MsgBox(hotkeys.first)  ; returns "RAlt"
 *    MsgBox(hotkeys.second) ; returns "p"
 * }
 *
 * !p::
 * {
 *    getHotkeys(&first, &second)
 *    MsgBox(first)  ; returns "vk12"
 *    MsgBox(second) ; returns "p"
 * }
 * ```
 */
allKeyWait(which := "both") {
    if Type(which) != "string" {
        ;// throw
        errorLog(TypeError("Incorrect Type in Parameter #1", -1, which),,, 1)
    }
    if (which != "both" || which != "first" || which != "second") {
        ;// throw
        errorLog(ValueError("Incorrect Value in Parameter #1", -1, which),,, 1)
    }
    if (A_ThisHotkey != "" && !InStr(A_ThisHotkey, "&"))
        KeyWait(A_ThisHotkey)
    else if A_ThisHotkey != ""
        {
            keys := getHotkeys()
            switch which {
                case "first":
                    KeyWait(keys.first)
                case "second":
                    KeyWait(keys.second)
                default:
                    KeyWait(keys.second)
                    KeyWait(keys.first)
            }
            return {first: keys.first, second: keys.second}
        }
}