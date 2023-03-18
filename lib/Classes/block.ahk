/************************************************************************
 * @description A class to contain often used blockinput functions for easier coding.
 * @author tomshi
 * @date 2023/03/19
 * @version 1.3.4
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\Mip>
#Include <Functions\errorLog>
; }


class block {
    choices := Mip("send", 1, "mouse", 1, "sendandmouse", 1, "default", 1, "on", 1, "mousemove", 1, "mousemoveoff", 1, "off", 1)

    UserSettings := UserPref()

    /**
     * This function is designed to be internal to the class and isn't intended to be manually called. It checks the users custom input settings to make sure they're a usable option. This function will also alert the user about the intricacies of using `BlockInput("On"/"Off")`
     * @param {String} args is the users passed in custom option
     */
    __inputs(args) {
        if !this.choices.Has(args) {
                ;// throw
                errorLog(ValueError("Incorrect value in parameter #1", -2, args),,, 1)
            }
        if args = "on" || args = "off"
            {
                checkIni := this().UserSettings.block_aware
                if checkIni = "false"
                    {
                        alert := MsgBox("
                        (
                            Using ``BlockInput("On")/BlockInput("Off")`` may not work as expected if you're using windows UAC and this script hasn't been run as admin. Consider using a different block mode for more usable & shareable code.

                            Would you like to be alerted of this again in the future?
                        )", "Block Mode Warning", "4 48 4096")
                        if alert = "No"
                            {
                                this().UserSettings.block_aware := true
                                this().UserSettings.__Delete()
                            }
                    }
            }
        BlockInput(args)
    }

    /**
     * By default this function will blocks all user inputs (`BlockInput("SendAndMouse") & BlockInput("MouseMove")`).
     *
     * Otherwise pass `send`, `mouse`, `sendandmouse`, `default`, `on` or `mousemove`
     *
     * *[IF YOU GET STUCK IN A SCRIPT PRESS YOUR REFRESH HOTKEY (WIN + SHIFT + R BY DEFAULT) OR USE CTRL + ALT + DEL to open task manager and close AHK]*
     * @param {String} option? is the desired block mode. If this parameter is omitted `BlockInput("SendAndMouse") & BlockInput("MouseMove")` will be enabled
     */
    static On(option?) {
        if !IsSet(option)
            {
                ;// don't use `BlockInput("On")` it can have issues with UAC if script not run as admin
                BlockInput("SendAndMouse"), BlockInput("MouseMove")
                return
            }
        this().__inputs(option)
    }

    /**
     * This function by default will unblock all user input (`BlockInput("Default") & BlockInput("MouseMoveOff")`).
     *
     * Otherwise pass `mousemoveoff`, `off`
     * @param {String} option? is the desired block mode the user wishes to disable. If this parameter is omitted `BlockInput("Default") & BlockInput("MouseMoveOff")` will be disabled
     */
    static Off(option?) {
        if !IsSet(option)
            {
                BlockInput("Default"), BlockInput("MouseMoveOff")
                return
            }
        this().__inputs(option)
    }
}