#Include <Classes\ptf>

/**
 * This function retrieves the local version (or the string after a specified tag) and then returns it.
 *
 * This script will trim whitespace, tabs, newlines & carriage return
 * @param {any} varRead If this variable is populated, it will read from that string instead of filereading a new variable.
 * @param {string} [script="My Scripts.ahk"] is the name of the script you wish to read (if in the root dir, otherwise the remaining filepath to it)
 * @param {string} [searchTag="@version"] is what you want the function to search for
 * @param {string} [endField="*"] is what you want "InStr" to search for to be the end of your string
 * @param {boolean} [returnObj=false] determines whether to return just the version as a string or an object containing both the version number and the FileRead of the script
 * @returns {string|object}
 * ```
 * ;// example 1
 * ver := getLocalVer() ;// 2.14.6
 *
 * ;// example 2
 * ver := getLocalVer(script,,,, true)
 * ver.version ;// 2.14.6
 * ver.script ;// the entire contents of the script
 * ```
 */
getLocalVer(varRead?, script := "My Scripts.ahk", searchTag := "@version", endField := "*", returnObj := false) {
    if IsSet(varRead)
        read := varRead
    else
        read := FileRead(ptf.rootDir "\" script)
    getVerPos := InStr(read, searchTag)
    if !getVerPos ;if the lib doesn't have a @version tag, we'll pass back a blank script and do something else later
        return((returnObj = false) ? false : {version: "", script: read})
    ver := Trim(
        SubStr(read
              , verFind := InStr(read, searchTag,, 1, 1) + (StrLen(searchTag)+1)
              , InStr(read, endField,, verFind, 1)-verFind
            )
        , " `t`n`r"
    )
    return((returnObj = false) ? ver : {version: ver, script: read})
}