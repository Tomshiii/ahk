#Include <Classes\ptf>

/**
 * This function retrieves the local version (or the string after a specified tag) and then returns it.
 *
 * This script will trim whitespace, tabs, newlines & carriage return
 * @param {any} varRead If this variable is populated, it will read from that string instead of filereading a new variable.
 * @param {string} script is the name of the script you wish to read (if in the root dir, otherwise the remaining filepath to it)
 * @param {string} searchTag is what you want the function to search for
 * @param {string} endField is what you want "InStr" to search for to be the end of your string
 * @returns {string}
 */
getLocalVer(varRead?, script := "My Scripts.ahk", searchTag := "@version", endField := "*") {
    if IsSet(varRead)
        read := varRead
    else
        read := FileRead(ptf.rootDir "\" script)
    ver := Trim(
        SubStr(read
              , verFind := InStr(read, searchTag,, 1, 1) + (StrLen(searchTag)+1)
              , InStr(read, endField,, verFind, 1)-verFind
            )
        , " `t`n`r"
    )
    return ver
}