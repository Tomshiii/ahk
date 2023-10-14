; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\errorLog>
#Include <Classes\Mip>
#Include <Functions\checkInternet>
; }

/**
 * This function will perform a COM winHttp request and return the value of the requested url as a string
 * @param {String} url is the url you wish to return
 * @returns {String/Integer} If successful, returns a `string` containing the html. If unsuccessful, will either return `false` if a connection cannot be determined or `-1` if the webpage runs into a predetermined error (This will not catch everything).
 */
getHTML(url) {
    errors := Mip("404: Not Found", 1)
    ;// type checking
    if Type(url) != "string" {
        ;// throw
        errorLog(TypeError("Function expected a string but recieved a " Type(url), -1, url),,, 1)
    }
    ;// attempting to get url
    try {
        if !checkInternet()
            return false
        main := ComObject("WinHttp.WinHttpRequest.5.1")
        main.Open("GET", url)
        main.Send()
        main.WaitForResponse()
        string := main.ResponseText

        ;// check for connection errors
        if errors.Has(string)
            return -1
    }  catch as e {
        tool.Cust("Couldn't get version info`nYou may not be connected to the internet")
        errorLog(e)
        return false
    }
    return string
}