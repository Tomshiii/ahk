; { \\ #Includes
#Include <Classes\tool>
#Include <Functions\errorLog>
#Include <Functions\getHTML>
#Include <Functions\checkInternet>
; }

/**
 * A function to return the most recent version of my scripts on github
 * @param {Boolean} beta A `true/false` to determine if you want this function to check for a full release, or a prerelease. Can be omitted
 * @param {VarRef} changeVer Determines which changelog to show in `updateChecker()` GUI
 * @param {String} user Determines which github user to check
 * @param {String} repo Determines which repo to check
 * @returns {number|string} returns a string containing the latest version number
 */
getScriptRelease(beta := false, &changeVer := "", user := "Tomshiii", repo := "ahk")
{
    if !checkInternet()
        {
            errorLog(, A_ThisFunc "()", "Couldn't connect to the internet", A_LineFile, A_LineNumber)
            return 0
        }
    if !html := getHTML("https://github.com/" user "/" repo "/releases.atom")
        return 0
    loop {
        getrightURL := InStr(html, 'href="https://github.com/' user '/' repo '/releases/tag/', 1, 1, A_Index)
        foundpos := InStr(html, 'v2', 1, getrightURL, 1)
        endpos := InStr(html, '"', , foundpos, 1)
        ver := Trim(SubStr(html, foundpos, endpos - foundpos))
        if InStr(ver, "<",, 1, 1)
            ver := SubStr(ver, 1, InStr(ver, "<",, 1, 1)-1)
        if !InStr(ver, "pre") && !InStr(ver, "beta")
            {
                changeVer := "main"
                break
            }
        else if beta = true
            {
                changeVer := "beta"
                break
            }
    }
    return ver
}