/************************************************************************
 * @description A class to contain often used coordmode settings for easier coding.
 * @author tomshi
 * @date 2023/01/01
 * @version 1.1.1
 ***********************************************************************/

; { \\ #Includes
#Include <Functions\errorLog>
; }

class coord {
    /**
     * A function to do some basic error checking & cut repeat code. This function is designed to be internal to the class and isn't intended to be manually called.
     * @param {String} target is the passed in `target` parameter of `CoordMode`
     * @param {Boolean} mouse is the passed in boolean dictating if the user wants the function to adjust the mouse to screen as well
    */
   errorChecks(target, mouse?) {
        targets := ["tooltip", "pixel", "mouse", "caret", "menu"]
        ;// checking that the passed parameter is a string
        if Type(target) != "string"
            {
                ;// throw
                errorLog(TypeError("Incorrect variable type in Parameter #1", -1, target),,, 1)
            }
        ;// checking that the passed string is one of the accepted types
        loop {
            if A_Index > targets.Length
                {
                    ;// throw
                    errorLog(ValueError("Incorrect value in Parameter #1", -1, target),,, 1)
                }
            if targets[A_Index] = target
                break
        }
        ;// ensuring the passed parameter is a boolean value
        if IsSet(mouse) {
            if mouse != true && mouse != false
                {
                    errorLog(ValueError("Incorrect value in Parameter #2", -1, mouse),,, 1)
                }
        }
    }

    /**
     * Sets coordmode to "pixel", "screen" by default
     *
     * This function is mostly syntatic sugar, designed to quickly and easily change coordmode types to those that I use frequently within my own scripts
     *
     * But in saying that, these functions still offer the ability to change away from their defaults
     * @param {String} target what you would like coordmode to target and change the mode for
     * @param {Boolean} mouse whether you want this function to adjust the mouse to screen coordmode as well
    */
    static s(target := "pixel", mouse := true) {
        coord().errorChecks(target, mouse)
        CoordMode(target, "screen")
        if mouse
            CoordMode("mouse", "screen")
    }

    /**
     * Sets coordmode to "pixel", "window" by default
     *
     * This function is mostly syntatic sugar, designed to quickly and easily change coordmode types to those that I use frequently within my own scripts
     *
     * But in saying that, these functions still offer the ability to change away from their defaults
     * @param {String} target what you would like coordmode to target and change the mode for
     * @param {Boolean} mouse whether you want this function to adjust the mouse to window coordmode as well
     */
     static w(target := "pixel", mouse := true) {
        coord().errorChecks(target, mouse)
        CoordMode(target, "window")
        if mouse
            CoordMode("mouse", "window")
    }

    /**
     * Sets coordmode to "pixel", "client" by default
     *
     * This function is mostly syntatic sugar, designed to quickly and easily change coordmode types to those that I use frequently within my own scripts
     *
     * But in saying that, these functions still offer the ability to change away from their defaults
     * @param {String} target what you would like coordmode to target and change the mode for
     * @param {Boolean} mouse whether you want this function to adjust the mouse to client coordmode as well
    */
    static client(target := "pixel", mouse := true) {
        coord().errorChecks(target, mouse)
        CoordMode(target, "client")
        if mouse
            CoordMode("mouse", "client")
    }

    /**
     * Sets coordmode to "caret", "window" by default
     *
     * This function is mostly syntatic sugar, designed to quickly and easily change coordmode types to those that I use frequently within my own scripts
     *
     * But in saying that, these functions still offer the ability to change away from their defaults
     * @param {String} relative change the desired second parameter of Coormode that you want the caret to respond to
     */
     static c(relative := "window") {
        relativeTo := ["screen", "window", "client"]
        ;// checking that the passed parameter is a string
        if Type(relative) != "string"
            {
                ;// throw
                errorLog(TypeError("Incorrect variable type in Parameter #1", -1, relative),,, 1)
            }
        ;// checking that the passed string is one of the accepted types
        loop {
            if A_Index > relativeTo.Length
                {
                    ;// throw
                    errorLog(ValueError("Incorrect value in Parameter #1", -1, relative),,, 1)
                }
            if relativeTo[A_Index] = relative
                break
        }
        ;// setting the coordmode
        CoordMode("caret", relative)
    }
}