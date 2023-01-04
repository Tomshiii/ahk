/************************************************************************
 * @description A class to contain often used blockinput functions for easier coding.
 * @author tomshi
 * @date 2023/01/04
 * @version 1.1.2
 ***********************************************************************/

; { \\ #Includes
#Include <Functions\errorLog>
; }

class block {
    inputs(args) {
        choices := ["send", "mouse", "sendandmouse", "default", "on", "mousemove", "mousemoveoff", "off"]
        if args = "on" || args = "off"
            {
                checkIni := IniRead(ptf["settings"], "Track", "block aware", "false")
                if checkIni = "false"
                    {
                        alert := MsgBox("
                        (
                            Using ``BlockInput("On")/BlockInput("Off")`` may not work as expected if you're using windows UAC and this script hasn't been run as admin. Consider using a different block mode for more usable code.

                            Would you like to be alerted of this again in the future?
                        )", "Block Mode Warning", "4 48 4096")
                        if alert = "No"
                            IniWrite("true", ptf["settings"], "Track", "block aware")
                    }
            }
        loop {
            if A_Index > choices.Length
                {
                    ;// throw
                    errorLog(ValueError("Incorrect value in parameter #1", -1, args),,, 1)
                }
            if args = choices[A_Index]
                break
        }
        BlockInput(args)
    }
    /**
     * By default this function will blocks all user inputs (`BlockInput("On")`).
     *
     * Otherwise pass `send`, `mouse`, `sendandmouse`, `default`, `on` or `mousemove`
     *
     * *[IF YOU GET STUCK IN A SCRIPT PRESS YOUR REFRESH HOTKEY (WIN + SHIFT + R BY DEFAULT) OR USE CTRL + ALT + DEL to open task manager and close AHK]*
     */
    static On(option?) {
        if !IsSet(option)
            {
                ;// don't use `BlockInput("On")` it can have issues with UAC if script not run as admin
                BlockInput("SendAndMouse"), BlockInput("MouseMove")
                return
            }
        else
            block().inputs(option)
    }

    /**
     * This function by default will unblock all user input
     */
    static Off(option?) {
        if !IsSet(option)
            {
                BlockInput("Default"), BlockInput("MouseMoveOff")
                return
            }
        block().inputs(option)
    }
}