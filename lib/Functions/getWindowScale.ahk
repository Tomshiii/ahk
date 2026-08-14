/**
 * returns the current windows scaling for the monitor the window resides within
 * @param {Integer} [hwnd] the hwnd of the desired window
 */
getWindowScale(hwnd) {
    dpi := DllCall("GetDpiForWindow", "ptr", hwnd, "uint")
    return (dpi / 96)  ; 96 DPI = 100% scaling baseline
}