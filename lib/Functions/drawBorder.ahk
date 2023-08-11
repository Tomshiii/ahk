/**
 * This function attempts to draw a border around the desired window. This function requires a windows version higher than `10.0.22000` (win11). This function may not toggle well in rapid succession.
 * @param {Integer} hwnd the hwnd of the window you desire to adjust
 * @param {Hexadecimal} colour the hex colour you wish the border to be. Formated like: `0x1195F5`
 * @param {Boolean} enable whether you wish to enable or disable the border
 */
drawBorder(hwnd, colour := 0xFFFFFFFF, enable := false) {
    if VerCompare(A_OSVersion, "10.0.22000") >= 0
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", 34, "int*", enable ? colour : 0xFFFFFFFF, "int", 4)
}