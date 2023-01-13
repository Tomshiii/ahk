/************************************************************************
 * @description A class to contain often used tooltip functions for easier coding.
 * @author tomshi
 * @date 2023/01/13
 * @version 1.0.7
 ***********************************************************************/

; { \\ #Includes
#Include <Functions\detect>
; }

class tool {
    /**
     * A function simply to store the previous listlines value
     */
    __storeLines() {
        ;// saving the previous ListLines value
        priorLines := A_ListLines, ListLines(0)
        return priorLines
    }

    /**
     * This function saves the previous coordmode states
     */
    __storeCoords() {
        return {Tooltip: A_CoordModeToolTip, Mouse: A_CoordModeMouse}
    }

    /**
     * This function ensures any custom coordinates passed by the user don't default to window mode and ensures the initial tooltip generates in the correct position if cursor isn't on the main display
     */
    __setCoords() => (CoordMode("ToolTip", "Screen"), CoordMode("Mouse", "Screen"))

    /**
     * This function will return the coordmodes to their previous state
     */
    __returnCoord(priorTooltip, priorMouse, priorLines) => (A_CoordModeToolTip := priorTooltip, A_CoordModeMouse := priorMouse, ListLines(priorLines))

    /**
     * Create a tooltip with any message. This tooltip will then follow the cursor and only redraw itself if the user has moved the cursor.
     *
     * If you wish for the tooltip to plant next to the mouse and not follow the cursor, similar to a normal tooltip, that can be achieved with something along the lines of;
     *
     * `tool.Cust("message",,, MouseGetPos(&x, &y) x + 15, y)`
     *
     * If you pass EITHER the x OR y value (but not both) this function will take that value and continuously `offset` it from the current cursor position. If you wish to plant the cursor in an exact position BOTH x & y values must be passed
     * @param {String} message is what you want the tooltip to say
     * @param {Number} timeout is how many ms you want the tooltip to last. This value can be omitted and it will default to 1000. If you wish to type in seconds, use a floating point number, ie; `1.0`, `2.5`, etc
     * @param {Boolean} find is whether you want this function to state "Couldn't find " at the beginning of it's tooltip. Simply add 1 (or true) for this variable if you do, or omit it if you don't
     * @param {Integer} xy the x & y coordinates you want the tooltip to appear. These values are unset by default and can be omitted
     * @param {Integer} WhichToolTip omit this parameter if you don't need multiple tooltips to appear simultaneously. Otherwise, this is a number between 1 and 20 to indicate which tooltip window to operate upon. If unspecified or set larger than 20, that number is 1 (the first).
     */
    static Cust(message, timeout := 1000, find := false, x?, y?, WhichToolTip?)
    {
        ;// saving the previous ListLines value
        priorLines := tool().__storeLines()
        ;// store initial coord mode
        priorCoords := tool().__storeCoords()
        ;// set coord mode
        tool().__setCoords()

        ;// doing some setup
        one  := false  ;this variable will be used to determine if only x or only y has been assigned a value
        both := false  ;this variable will be used to determine if both x and y have been assigned a value
        none := false  ;this variable will be used to determine if neither x or y have been assigned a value
        xDef := 20     ;the default value for x
        yDef := 1      ;the default value for y
        if (IsSet(x) || IsSet(y)) && !(IsSet(x) && IsSet(y)) ; checking if one value has been assigned but not both
            {
                one := true
                x := !IsSet(x) ? xDef : x
                y := !IsSet(y) ? yDef : y
            }
        else if (IsSet(x) && IsSet(y)) ;checking if both have been assigned
            both := true
        else ;otherwise none have been assigned
            {
                none := true
                x := xDef
                y := yDef
            }
        if !IsInteger(timeout) && IsFloat(timeout) ;this allows the user to use something like 2.5 to mean 2.5 seconds instead of needing 2500
            timeout := timeout * 1000
        if IsSet(WhichToolTip) ;doing some checks for the whichtooltip variable
            {
                if !IsInteger(WhichToolTip)
                    WhichToolTip := 1
                if WhichToolTip > 20 || WhichToolTip < 1
                    WhichToolTip := 1
            }

        ;// starting the tooltip logic
        MouseGetPos(&xpos, &ypos) ;log our starting mouse coords
        time := A_TickCount ;log our starting time
        messageFind := find = 1 ? "Couldn't find " : "" ;this is essentially saying: if find = 1 then messageFind := "Couldn't find " else messageFind := ""
        if both = false || none = true ;what happens when neither x or y has been assigned a value
            {
                ToolTip(messageFind message, xpos + x, ypos + y, WhichToolTip?) ;produce the initial tooltip
                SetTimer(moveWithMouse.Bind(x, y), 15)
                tool().__returnCoord(priorCoords.Tooltip, priorCoords.Mouse, priorLines)
                return
            }
        else ;what happens otherwise
            {
                ToolTip(messageFind message, x, y, WhichToolTip?) ;produce the initial tooltip
                SetTimer(() => ToolTip("",,, WhichToolTip?), - timeout) ;otherwise we create a timer to remove the cursor after the timout period
                tool().__returnCoord(priorCoords.Tooltip, priorCoords.Mouse, priorLines)
                return
            }

        ;// this timer is what allows the tooltip to follow the cursor
        moveWithMouse(x, y)
        {
            ListLines(0)
            tool().__setCoords()
            if (A_TickCount - time) >= timeout ;here we compare the current time, minus the original time and see if it's been longer than the timeout time
                {
                    SetTimer(, 0) ;if it has we kill the timer
                    ToolTip("",,, WhichToolTip?) ;and kill the tooltip
                    tool().__returnCoord(priorCoords.Tooltip, priorCoords.Mouse, priorLines)
                    return ;then kill the function
                }
            MouseGetPos(&newX, &newY) ;here we're grabbing new mouse coords
            if newX != xpos || newY != ypos ;so we can compare them to the old coords
                {
                    MouseGetPos(&xpos, &ypos) ;if they're different we'll replace the original coords
                    ToolTip(messageFind message, newX + x, newY + y, WhichToolTip?) ;and produce a new tooltip
                }
        }
    }

    /**
     * This function is a part of the class `tool`
     *
     * This function will check to see if any tooltips are active before continuing
     * @param {Integer} timeout allows you to pass in a time value (in seconds) that you want WinWaitClose to wait before timing out. This value can be omitted and does not need to be set
     */
    static Wait(timeout?)
    {
        priorLines := tool().__storeLines()
        dct := detect(0) ;we need to ensure detecthiddenwindows is disabled before proceeding or this function may never stop waiting
        if WinExist("ahk_class tooltips_class32")
            WinWaitClose("ahk_class tooltips_class32",, timeout?)
        DetectHiddenWindows(dct.Windows)
        ListLines(priorLines)
    }
}