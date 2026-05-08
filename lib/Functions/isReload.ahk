; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Functions\checkBool.ahk
; }

/**
 * This function checks to see if the current script was run via a reload
 * ```
 * if isReload()
 *     return
 * ;// if the script was reloaded, beyond this point will not fire
 * @param {Boolean} [arg=""]
 * ```
 */
isReload(arg := "") => (DllCall("GetCommandLine", "str") ~= "i) /r(estart)?(?!\S)" || (checkBool(arg) = true))