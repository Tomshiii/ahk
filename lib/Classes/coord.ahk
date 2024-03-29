/************************************************************************
 * @description A class to contain often used coordmode settings for easier coding.
 * @author tomshi
 * @date 2023/08/13
 * @version 1.2.6
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\Mip>
#Include <Classes\errorLog>
; }

class coord {
    /**
     * A function to do some basic error checking & cut repeat code. This function is designed to be internal to the class and isn't intended to be manually called.
     * @param {String} target is the passed in `target` parameter of `CoordMode`
     * @param {Boolean} mouse is the passed in boolean dictating if the user wants the function to adjust the mouse to screen as well
    */
    __errorChecks(target, mouse?) {
        targets := Mip("tooltip", 1, "pixel", 1, "mouse", 1, "caret", 1, "menu", 1)
        ;// checking that the passed parameter is a string
        if Type(target) != "string"
            {
                ;// throw
                errorLog(TypeError("Incorrect variable type in Parameter #1", -2, target),,, 1)
            }
        ;// checking that the passed string is one of the accepted types
        if !targets.Has(target) {
                ;// throw
                errorLog(ValueError("Incorrect value in Parameter #1", -2, target),,, 1)
            }
        ;// ensuring the passed parameter is a boolean value
        if IsSet(mouse) && (mouse != true && mouse != false) {
            ;// throw
            errorLog(ValueError("Incorrect value in Parameter #2", -2, mouse),,, 1)
        }
    }

    /**
     * A function to do some basic error checking & cut repeat code. This function is designed to be internal to the class and isn't intended to be manually called.
     * @param {String} relative is the passed in `relativeTo` parameter of `CoordMode`
    */
    __caretErrorCheck(relative) {
        relativeTo := Mip("screen", 1, "window", 1, "client", 1)
        ;// checking that the passed parameter is a string
        if Type(relative) != "string" {
                ;// throw
                errorLog(TypeError("Incorrect variable type in Parameter #1", -2, relative),,, 1)
            }
        ;// checking that the passed string is one of the accepted types
        if !relativeTo.Has(relative) {
            ;// throw
            errorLog(ValueError("Incorrect value in Parameter #1", -2, relative),,, 1)
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
        this().__errorChecks(target, mouse)
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
        this().__errorChecks(target, mouse)
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
        this().__errorChecks(target, mouse)
        CoordMode(target, "client")
        if mouse
            CoordMode("mouse", "client")
    }

    /**
     * Sets coordmode to "caret", "window" by default
     *
     * This function is mostly syntatic sugar, designed to quickly and easily change the coordmode of the caret
     *
     * But in saying that, these functions still offer the ability to change away from their defaults
     * @param {String} relative change the desired second parameter of Coormode that you want the caret to respond to
     */
     static c(relative := "window") {
        this().__caretErrorCheck(relative)
        ;// setting the coordmode
        CoordMode("caret", relative)
    }

    /**
     * Stores all current coordmode settings into an object
     * @returns {object}
     * ```
     * priorCoords := coord.store()
     * priorCoords.caret   ;// returns the original `A_CoordModeCaret`
     * priorCoords.menu    ;// returns the original `A_CoordModeMenu`
     * priorCoords.tooltip ;// returns the original `A_CoordModeToolTip`
     * priorCoords.mouse   ;// returns the original `A_CoordModeMouse`
     * priorCoords.pixel   ;// returns the original `A_CoordModePixel`
     * ```
     */
    static store() => {caret: A_CoordModeCaret, menu: A_CoordModeMenu, tooltip: A_CoordModeToolTip, mouse: A_CoordModeMouse, pixel: A_CoordModePixel}

    /**
     * Resets the values of passed in coordmodes
     * @param {Object} coordObj an object containing any coord modes you wish to reset
     * ```
     * coordObjs := coord.store()
     * ...
     * ...
     * coord.reset(coordObjs)
     * ```
     * ;// will only accept object params of;
     *
     * `caret`, `menu`, `tooltip`, `mouse`, `pixel`
     */
    static reset(coordObj) {
        A_CoordModeCaret   := coordObj.HasOwnProp("caret")   ? coordObj.caret   : A_CoordModeCaret
        A_CoordModeMenu    := coordObj.HasOwnProp("menu")    ? coordObj.menu    : A_CoordModeMenu
        A_CoordModeToolTip := coordObj.HasOwnProp("tooltip") ? coordObj.tooltip : A_CoordModeToolTip
        A_CoordModeMouse   := coordObj.HasOwnProp("mouse")   ? coordObj.mouse   : A_CoordModeMouse
        A_CoordModePixel   := coordObj.HasOwnProp("pixel")   ? coordObj.pixel   : A_CoordModePixel
    }
}