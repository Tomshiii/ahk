/**
 * Checks if the user has an internet connection.
 * @returns {Boolean} returns 1 for true, 0 for false
 */
checkInternet(flag := 0x40) => DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag, "Int", 0)