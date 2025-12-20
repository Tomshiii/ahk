; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Functions\isBool.ahk
#Include Classes\errorLog.ahk
; }

/**
 * checks whether the passed in value represets a boolean value (`true`/`false`/`"true"`/`"false"`) and returns the same corresponding boolean value
 * @param {Boolean|String} [bool] the value to check
 * @returns {Boolean}
 *
 * Example;
 * ```c#
 * checkVal := "true"
 * if checkBool(checkVal) = true {
 *     ... ;// this block will fire
 * }
 * ```
 */
checkBool(bool) {
    if !isBool(bool) {
        ;// throw
        errorLog(ValueError('Function requires a Boolean', -2, bool),,, true)
        return false
    }
    if bool = true || bool = "true"
        return true
    return false
}