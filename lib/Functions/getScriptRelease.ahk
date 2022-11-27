; { \\ #Includes
#Include <\Classes\tool>
#Include <\Functions\errorLog>
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
    try {
        main := ComObject("WinHttp.WinHttpRequest.5.1")
        main.Open("GET", "https://github.com/" user "/" repo "/releases.atom")
        main.Send()
        main.WaitForResponse()
        string := main.ResponseText
    }  catch as e {
        tool.Cust("Couldn't get version info`nYou may not be connected to the internet")
        errorLog(e, A_ThisFunc "()")
        return 0
    }
    loop {
        getrightURL := InStr(string, 'href="https://github.com/' user '/' repo '/releases/tag/', 1, 1, A_Index)
        foundpos := InStr(string, 'v2', 1, getrightURL, 1)
        endpos := InStr(string, '"', , foundpos, 1)
        ver := SubStr(string, foundpos, endpos - foundpos)
        if InStr(ver, A_Space,, 1, 1)
            ver := SubStr(ver, 1, InStr(ver, A_Space,, 1, 1))
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