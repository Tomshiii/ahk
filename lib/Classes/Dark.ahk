/************************************************************************
 * @description A class to contain often used functions to turn GUI elements to a dark mode.
 * @author tomshi, Lexikos, others
 * @date 2023/01/18
 * @version 1.0.2
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
     * This function will convert all buttons defined in the GUI to a dark/light theme.
     * @param {Object} guiObj is the gui object you're working on (ie. MyGui, settingsGUI, etc)
     * @param {String} DarkorLight is a toggle that allows you to call the inverse of this function and return the button to light mode. This parameter can be omitted otherwise pass "Light"
     * @param {Boolean/Object} changeBg gives the ability to modify button bg colours & gui bg colours. Defaults to false and will not adjust either
     * ```
     * allButtons(guiObj, DarkorLight, {changeBg (obj)}
     * default: true                    ;// sets 0xF0F0F0 for light mode && 0xd4d4d4 for darkmode. No other parameters are necessary if this is passed
     * LightColour/DarkColour: "xxxxxx" ;// This value is a hex code (WITHOUT 0x) - sets the bg colour for all buttons for the given colour mode
     * LightBG/DarkBG: "xxxxxx"         ;// This value is a hex code (WITHOUT 0x) - sets the gui bg colour when in the desired colour mode. If this value is not set, it will default to `LightColour/DarkColour`.
     * DarkBG/LightBG: false            ;// can be set if you do not wish to adjust the BG colour of a certain colour mode
     * ```
     */
    static allButtons(guiObj, DarkorLight := "Dark", changeBg := false) {
        for ctrl in guiObj
            {
                if Type(ctrl) != "Gui.Button"
                    continue
                try {
                    /**
                     * This function is to cut repeat code in the switch statement down below. It facilitates changing the bg colour of the GUI and the gui buttons
                     */
                    changeCol(guiObj, ctrl) {
                        ;// default values
                        defaultCol := (DarkorLight = "Dark") ? "d4d4d4" : "F0F0F0"
                        clrVar := DarkorLight
                        clr := clrVar 'Colour'
                        BG := clrVar 'BG'
                        ;// if the user passes 'default'
                        if changeBg.HasProp("default") && changeBG.default = true
                            {
                                ctrl.Opt("Background" defaultCol)
                                guiObj.BackColor := Format("{:#x}", "0x" defaultCol)
                            }
                        ;// if the user passes a 'DarkColour' or 'LightColour'
                        if changeBg.HasProp(DarkorLight "Colour")
                            {
                                bgColour := changeBg.HasProp(BG) ? changeBg.%BG% : changeBg.%clr%
                                guiObj.BackColor := Format("{:#x}", "0x" bgColour)
                                ctrl.Opt("Background" changeBg.%clr%)
                            }
                        ;// if the user passes 'DarkBG: false' or 'LightBG: false'
                        else if changeBg.HasProp(BG) && changeBg.%BG% = false
                            {
                                guiObj.BackColor := ""
                                ctrl.Opt("BackgroundDefault")
                                return
                            }
                    }
                    switch DarkorLight {
                        case "Light":
                            this.button(ctrl.Hwnd, "Light")
                            if !changeBg || !IsObject(changeBg)
                                return
                            changeCol(guiObj, ctrl)
                        default:
                            this.button(ctrl.Hwnd)
                            if !changeBg || !IsObject(changeBg)
                                return
                            changeCol(guiObj, ctrl)
                    }
                }
            }

    }

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