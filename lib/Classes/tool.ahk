/************************************************************************
 * @description A class to contain often used tooltip functions for easier coding.
 * @author tomshi
 * @date 2022/11/28
 * @version 1.0.1
 ***********************************************************************/

class tool {
    /**
     * This function is a part of the class `tool`
     *
     * Create a tooltip with any message. This tooltip will then follow the cursor and only redraw itself if the user has moved the cursor.
     *
     * If you wish for the tooltip to plant next to the mouse and not follow the cursor, similar to a normal tooltip, that can be achieved with something along the lines of;
     *
     * `tool.Cust("message",,, MouseGetPos(&x, &y) x + 15, y)`
     * @param {string} message is what you want the tooltip to say
     * @param {number} timeout is how many ms you want the tooltip to last. This value can be omitted and it will default to 1000. If you wish to type in seconds, use a floating point number, ie; `1.0`, `2.5`, etc
     * @param {boolean} find is whether you want this function to state "Couldn't find " at the beginning of it's tooltip. Simply add 1 (or true) for this variable if you do, or omit it if you don't
     * @param {number} xy the x & y coordinates you want the tooltip to appear. These values are unset by default and can be omitted
     * @param {integer} WhichToolTip omit this parameter if you don't need multiple tooltips to appear simultaneously. Otherwise, this is a number between 1 and 20 to indicate which tooltip window to operate upon. If unspecified or set larger than 20, that number is 1 (the first).
     */
    static Cust(message, timeout := 1000, find := false, x?, y?, WhichToolTip?)
    {
        CoordMode("ToolTip", "Screen") ;this ensures any custom coordinates passed by the user don't default to window mode
        if !IsInteger(timeout) && IsFloat(timeout) ;this allows the user to use something like 2.5 to mean 2.5 seconds instead of needing 2500
            timeout := timeout * 1000
        if IsSet(WhichToolTip)
            {
                if !IsInteger(WhichToolTip)
                    WhichToolTip := 1
                if WhichToolTip > 20 || WhichToolTip < 1
                    WhichToolTip := 1
            }
        MouseGetPos(&xpos, &ypos) ;log our starting mouse coords
        time := A_TickCount ;log our starting time
        messageFind := find = 1 ? "Couldn't find " : "" ;this is essentially saying: if find = 1 then messageFind := "Couldn't find " else messageFind := ""
        ToolTip(messageFind message, x?, y?, WhichToolTip?) ;produce the initial tooltip
        if !IsSet(x) && !IsSet(y) ;if a x/y value hasn't been passed then that means we want the tooltip to follow the cursor
            SetTimer(moveWithMouse, 15)
        else
            SetTimer(() => ToolTip("",,, WhichToolTip?), - timeout) ;otherwise we create a timer to remove the cursor after the timout period
        moveWithMouse() ;this timer is what allows the tooltip to follow the cursor
        {
            if (A_TickCount - time) >= timeout ;here we compare the current time, minus the original time and see if it's been longer than the timeout time
                {
                    SetTimer(, 0) ;if it has we kill the timer
                    ToolTip("",,, WhichToolTip?) ;and kill the tooltip
                    return ;then kill the function
                }
            MouseGetPos(&newX, &newY) ;here we're grabbing new mouse coords
            if newX != xpos || newY != ypos ;so we can compare them to the old coords
                {
                    MouseGetPos(&xpos, &ypos) ;if they're different we'll replace the original coords
                    ToolTip(messageFind message,,, WhichToolTip?) ;and produce a new tooltip
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
        detectVal := A_DetectHiddenWindows
        DetectHiddenWindows(0) ;we need to ensure detecthiddenwindows is disabled before proceeding or this function may never stop waiting
        if WinExist("ahk_class tooltips_class32")
            WinWaitClose("ahk_class tooltips_class32",, timeout?)
        DetectHiddenWindows(detectVal)
    }
}