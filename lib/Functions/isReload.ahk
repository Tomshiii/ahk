/**
 * This function checks to see if the current script was run via a reload
 * ```
 * if isReload()
 *     return
 * ;// if the script was reloaded, beyond this point will not fire
 * ```
 */
isReload() => DllCall("GetCommandLine", "str") ~= "i) /r(estart)?(?!\S)"