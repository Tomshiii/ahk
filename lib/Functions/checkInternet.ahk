/**
 * Checks if the user has an internet connection.
 * @returns {Boolean} returns 1 for true, 0 for false
 */
checkInternet(url := "https://www.google.com") {
    ;// check to see if the user is connected to a network at all
    if !DllCall("Wininet.dll\InternetGetConnectedState", "Str", "0x40", "Int", 0)
        return 0
    ;// will then ping a website to see if a response is returned
    try {
        main := ComObject("WinHttp.WinHttpRequest.5.1")
        main.Open("GET", url)
        main.Send()
        main.WaitForResponse()
    }  catch {
        return 0
    }
    return 1
}