/************************************************************************
 * @description A class to contain often used blockinput functions for easier coding.
 * @author tomshi
 * @date 2023/01/01
 * @version 1.1.1
 ***********************************************************************/

; { \\ #Includes
#Include <Functions\errorLog>
; }

class block {
    inputs(args) {
        choices := ["send", "mouse", "sendandmouse", "default", "on", "mousemove", "mousemoveoff", "off"]
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
                BlockInput("On")
                return
            }
        block().inputs(option)
    }

    /**
     * This function by default will unblock all user input
     */
    static Off(option?) {
        if !IsSet(option)
            {
                BlockInput("Off")
                return
            }
        block().inputs(option)
    }
}