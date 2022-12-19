; { \\ #Includes
#Include <Functions\checkInternet>
#Include <Classes\tool>
#Include <Functions\errorLog>
; }

/**
 * This function will perform a COM winHttp request and return the value of the requested url as a string
 * @param {String} url is the url you wish to return
 * @returns {String}
 */
getHTML(url) {
    try {
        if !checkInternet()
            return 0
        main := ComObject("WinHttp.WinHttpRequest.5.1")
        main.Open("GET", url)
        main.Send()
        main.WaitForResponse()
        string := main.ResponseText
    }  catch as e {
        tool.Cust("Couldn't get version info`nYou may not be connected to the internet")
        errorLog(e, A_ThisFunc "()")
        return 0
    }
    return string
}