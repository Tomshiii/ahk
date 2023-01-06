/************************************************************************
 * @description A class to contain often used functions to turn GUI elements to a dark mode.
 * @author tomshi, Lexikos, others
 * @date 2022/11/24
 * @version 1.0.0
 ***********************************************************************/

class Dark {
    /**
     * This function will convert GUI buttons to a dark/light theme.
     * @param {Integer} ctrl_hwnd is the hwnd value of the control you wish to alter
     * @param {String} DarkorLight is a toggle that allows you to call the inverse of this function and return the button to light mode. This parameter can be omitted otherwise pass "Light"
     *
     * https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661
     */
    static button(ctrl_hwnd, DarkorLight := "Dark") => DllCall("uxtheme\SetWindowTheme", "ptr", ctrl_hwnd, "str", DarkorLight "Mode_Explorer", "ptr", 0)

    /**
     * This function will convert GUI menus to dark mode/light mode
     *
     * https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661
     * @param {Boolean} DarkorLight is whether you want dark or light mode. Pass 1 for dark or 0 for light
     */
    static menu(DarkorLight := 1)
    {
        if !IsSet(uxtheme)
            {
                static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
                static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
                static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
            }
        DllCall(SetPreferredAppMode, "int", DarkorLight) ; Dark
        DllCall(FlushMenuThemes)
    }

    /**
     * This function will convert a windows title bar to a dark/light theme if possible.
     * @param {Integer} hwnd is the hwnd value of the window you wish to alter
     * @param {Boolean} dark is a toggle that allows you to call the inverse of this function and return the title bar to light mode. This parameter can be omitted otherwise pass false
     *
     * https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661
     */
    static titleBar(hwnd, dark := true)
    {
        if VerCompare(A_OSVersion, "10.0.17763") >= 0 {
            attr := 19
            if VerCompare(A_OSVersion, "10.0.18985") >= 0 {
                attr := 20
            }
            DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", dark, "int", 4)
        }
    }
}