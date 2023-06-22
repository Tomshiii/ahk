; { \\ #Includes
#Include <Classes\keys>
; }

/**
 * This function is to help stop the Ctrl/Shift modifier from getting stuck which can sometimes happen while using this script.
 * This function is necessary because some of the hotkeys used in the main method may use the Ctrl(^)/Shift(+) modifiers - if the method is interupted, these modifier can get placed in a "stuck" state where it will remain "pressed"
 * You may be able to avoid needing this function by simply using hotkeys that do not use modifiers.
 */
checkStuck() {
    keys.check("XButton1")
    keys.check("XButton2")
    keys.check("Ctrl")
    keys.check("Shift")
}