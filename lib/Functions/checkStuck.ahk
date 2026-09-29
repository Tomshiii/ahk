; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\keys.ahk
; }

/**
 * This function is to help stop the Ctrl/Shift modifier from getting stuck which can sometimes happen while using some scripts.
 * This function may be necessary when a scripts makes use of some of the hotkeys that use the Ctrl(^)/Shift(+) modifiers - if the script is interupted, these modifiers can get placed in a "stuck" state where they will remain "pressed"
 * You may be able to avoid needing this function by simply using hotkeys that do not use modifiers.
 * @param {Array} arr an array of buttons you wish to check. If no array is passed, it will default to checking `XButton1`, `XButton2`, `Ctrl` & `Shift`
 */
checkStuck(arr?) {
    arr := (IsSet(arr)) ? arr : ["XButton1", "XButton2", "Ctrl", "Shift"]
    for v in arr {
        keys.check(v)
    }
}