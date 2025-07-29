; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\errorLog>
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
            errorLog(Error("Couldn't confirm a connection to the internet", -1),, 1)
            return false
        }
    if !html := getHTML("https://github.com/" user "/" repo "/releases.atom")
        return false
    loop {
        getrightURL := InStr(html, 'href="https://github.com/' user '/' repo '/releases/tag/', 1, 1, A_Index)
        if !getrightURL {
            errorLog(Error("No url determined in returned html - may be rate limited", -1), "html has been added to the clipboard for inspection", 1)
            A_Clipboard := html
            return false
        }
        foundpos := InStr(html, 'v2', 1, getrightURL, 1)
        endpos := InStr(html, '"', , foundpos, 1)
        ver := Trim(SubStr(html, foundpos, endpos - foundpos))
        switch {
            case (InStr(ver, "<",, 1, 1)):
                ver := SubStr(ver, 1, InStr(ver, "<",, 1, 1)-1)
            case (!InStr(ver, "pre") && !InStr(ver, "beta") && !InStr(ver, "alpha")):
                changeVer := "main"
                break
            case (beta = true):
            changeVer := "beta"
            break
        }
    }
    return ver
}