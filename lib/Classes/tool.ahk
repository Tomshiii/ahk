/************************************************************************
 * @description A class to contain often used tooltip/traytip functions for easier coding.
 * @author tomshi
 * @date 2024/03/20
 * @version 1.2.1
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\coord>
#Include <Classes\errorLog>
#Include <Other\SystemThemeAwareToolTip>
#Include <Functions\detect>
; }

class tool {
    /**
     * A function simply to store the previous A_ListLines value
     * @returns {Boolean} returns the original state of `A_ListLines`
     */
    __storeLines() => A_ListLines

    /**
     * A function simply to restore the previously saved A_ListLines value
     */
    __returnLines(priorLines) => ListLines(priorLines)

    /**
     * This function ensures any custom coordinates passed by the user don't default to the incorrect coordmode mode and ensures the initial tooltip generates in the correct position if cursor isn't on the main display
     */
    __setCoords() => (CoordMode("ToolTip", "Screen"), CoordMode("Mouse", "Screen"))

    /**
     * This function will return the coordmodes to their previous state
     * @param c_toolTip the previously stored CoordMode for the `ToolTip`
     * @param c_mouse the previously stored CoordMode for the `Mouse`
     * @param lines the previously stored boolean for `ListLines`
     */
    __returnCoords(c_toolTip, c_mouse, lines) => (A_CoordModeToolTip := c_toolTip, A_CoordModeMouse := c_mouse, this.__returnLines(lines))

    /**
     * This function does some type testing on the input variables to ensure they're correct
     * @param {Object} args the tooltip parameters
     */
    __inputs(args) {
        for k, v in args.OwnProps() {
            switch k {
                ;//throw
                case "message":
                    if Type(v) != "string" && Type(v) != "integer" && Type(v) != "float"
                        errorLog(TypeError("Incorrect Type in Parameter #1", -2),,, 1)
                case "timeout":
                    if (Type(v) != "integer" && Type(v) != "float")
                        errorLog(TypeError("Incorrect Type in Parameter #2", -2),,, 1)
                case "x", "y":
                    if ((Type(v) != "integer" && Type(v) != "float"))
                        errorLog(TypeError("Incorrect Type in Parameter #3 or #4", -2),,, 1)
                case "ttip":
                    if Type(v) != "integer"
                        errorLog(TypeError("Incorrect Type in Parameter #5", -2),,, 1)

            }
        }
    }

    /**
     * a function used within `cust()` to check whether the current `WhichToolTip` is already active
     * @returns {Boolean} if it's already active, returns true. else false
     */
    __checkIndex(classs, ttp) {
        try {
            if classs.%ttp% = true
                return true
        }
        return false
    }

    /**
     * Create a tooltip with any message. This tooltip will then follow the cursor and only redraw itself if the user has moved the cursor.
     *
     * If you wish for the tooltip to plant next to the mouse and not follow the cursor, similar to a normal tooltip, that can be achieved with something along the lines of;
     *```
     * tool.Cust("message",, MouseGetPos(&x, &y) x + 15, y)
     *```
     * - If you pass EITHER the `x` OR `y` value (but not both) this function will take that value and continuously `offset` it from the current cursor position.
     *
     * - If you wish to plant the cursor in an exact position BOTH `x & y` values must be passed
     *
     * If a second tooltip of the same `WhichToolTip` param is called, the first will be replaced with it
     * @param {String} message is what you want the tooltip to say
     * @param {Integer/Float} timeout is how many ms you want the tooltip to last. This value can be omitted and it will default to 1000. If you wish to type in seconds, use a floating point number, ie; `1.0`, `2.5`, etc. If 0 is passed, the tooltip that was called with the same `WhichToolTip` parameter will be stopped.
     * @param {Integer} xy the x & y coordinates you want the tooltip to appear. These values are unset by default and can be omitted
     * @param {Integer} WhichToolTip omit this parameter if you don't need multiple tooltips to appear simultaneously. Otherwise, this is a number between 1 and 20 to indicate which tooltip to operate upon. If unspecified or set larger than 20, that number is 1 (the first).
     * @param {Boolean} darkMode whether to set the tooltip as darkmode or lightmode. will default to the user's system theme. Brought to my attention by [Nikola](https://discord.com/channels/115993023636176902/1202471107211431986/1202471107211431986)
     */
    static Cust(message, timeout := 1000, x?, y?, WhichToolTip?, darkMode?)
    {
        this().__inputs({message: message, timeout: timeout, x: x?, y: y?, ttip: WhichToolTip?})
        ;// saving the previous ListLines value
        priorLines := this().__storeLines()
        ListLines(0) ;// disables line logging - this prevents the line log from getting flooded
        ;// store initial coord mode
        priorCoords := coord.store()
        ;// set coord mode
        this().__setCoords()

        ;// set darkmode
        static isDarkMode := !RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme", 1)


        ;// ensuring `WhichToolTip` never goes above 20 or below 1
        WhichToolTip := !IsSet(WhichToolTip) || (IsSet(WhichToolTip) && (WhichToolTip > 20 || WhichToolTip < 1)) ? 1 : WhichToolTip
        ;// if the user opts to kill the tooltip, or if a new tooltip is called to be replaced
        if timeout = 0 || this().__checkIndex(this, WhichToolTip) {
            ToolTip("",,, WhichToolTip)
            this.%WhichToolTip% := false
            sleep 100 ;// timer needs ample time to recognise the change
        }
        this.%WhichToolTip% := true
        ;// setting values to determine where to place the tooltip
        both := (IsSet(x) && IsSet(y)) ? true : false
        none := (!IsSet(x) && !IsSet(y)) ? true : false
        one := (none = false && both = false) ? true : false
        ;// default positions if user hasn't set
        x := !IsSet(x) ? 20 : x
        y := !IsSet(y) ? 1 : y

        ;// checking if user passed an integer or float
        timeout := (!IsInteger(timeout) && IsFloat(timeout)) ? timeout * 1000 : timeout

        ;// if necessary, log original mouse coords
        origMouse := (both = false || none = true) ? obj.MousePos() : {x: 0, y:0}
        time := A_TickCount ;log our starting time

        ;//! creating the tooltip
        ttw := ToolTip(message, origMouse.x + x, origMouse.y + y, WhichToolTip) ;// produce the initial tooltip
        if !(darkMode ?? isDarkMode)
            SystemThemeAwareToolTip.IsDarkMode := false
        else if (darkMode ?? isDarkMode)
            DllCall("uxtheme\SetWindowTheme", "ptr", ttw, "ptr", StrPtr("DarkMode_Explorer"), "ptr", 0)
        this.%WhichToolTip% := true ;// set tooltip var to true
        if both = false || none = true ;// if the user wants the tooltip to track the mouse
            SetTimer(moveWithMouse.Bind(x, y, WhichToolTip), 15)
        else ;// otherwise we create a timer to remove the tooltip after the timout period
            SetTimer(() => (ToolTip("",,, WhichToolTip), this.%WhichToolTip% := false), -timeout)

        ;//! finally return coordmode & listlines to their previous settings before returning
        this().__returnCoords(priorCoords.Tooltip, priorCoords.Mouse, priorLines)
        return ttw

        /**
         * This function is called by `SetTimer` and is what allows the tooltip to follow the cursor
         * @param {Integer} x the x value that the user passed into the function (else the default)
         * @param {Integer} y the y value that the user passed into the function (else the default)
         * @param {Integer} ttp the `WhickToolTip` value the user passed into the function
         */
        moveWithMouse(x, y, ttp)
        {
            ListLines(0) ;// as this is a nested function, we have to disable line logging again - this prevents the line log from getting flooded
            this().__setCoords()
            ;// compare the current time, minus the original time and see if it's been longer than the timeout time
            ;// or if the var has been set to false (ie. the user has called for the timer to be killed)
            if (A_TickCount - time) >= timeout || this.%ttp% = false
                {
                    this.%ttp% := false
                    ToolTip("",,, ttp)
                    this().__returnCoords(priorCoords.Tooltip, priorCoords.Mouse, priorLines)
                    SetTimer(, 0)
                    return
                }
            MouseGetPos(&newX, &newY) ;// here we're grabbing new mouse coords
            if newX != origMouse.x || newY != origMouse.y ;// so we can compare them to the old coords
                {
                    origMouse := obj.MousePos() ;// if they're different we'll replace the original coords and produce a new tooltip
                    ToolTip(message, newX + x, newY + y, ttp)
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
        priorLines := this().__storeLines()
        ListLines(0) ;disables line logging
        dct := detect(0) ;we need to ensure detecthiddenwindows is disabled before proceeding or this function may never stop waiting
        if WinExist("ahk_class tooltips_class32")
            WinWaitClose("ahk_class tooltips_class32",, timeout?, "⚠️ Startup functions running")
        DetectHiddenWindows(dct.Windows)
        this().__returnLines(priorLines)
    }

    /**
     * This function is simply a wrapper function to quickly and easily generate & deal with a traytip
     * @param {Object} TrayParams an object containing the paramaters you wish to pass to `TrayTip`. This includes `{text: "", title: "", options: ""}`
     * @param {Integer} timeout the time in `ms` you wish to wait before the traytip times out. Pass `0` to disable this function attempting a timeout.
     * ##### *note: this timeout may not work as intended due to windows/if your script is persistent*
```markdown
# TrayParams 'Options'
 |       Function        | Dec | Hex  | String |
 |       --------        | --- | ---  | ------ |
 |      Info Icon        |  1  | 0x1  | Iconi  |
 |     Warning Icon      |  2  | 0x2  | Icon!  |
 |      Error Icon       |  3  | 0x3  | Iconx  |
 |      Tray Icon        |  4  | 0x4  | N/A    |
 | no notification sound | 16  | 0x10 | Mute   |
 |     Use large icon    | 32  | 0x20 | N/A    |
 ```
     */
    static Tray(TrayParams?, timeout := 5000) {
        A_IconTip := "Tomshi AHK Scripts"
        if !A_IconFile && FileExist(ptf.Icons "\myscript.ico")
            TraySetIcon(ptf.Icons "\myscript.ico")
        def := {text: "", title: "", options: ""}
        for k, v in TrayParams.OwnProps() {
            def.%k% := v
        }
        TrayTip(def.text, def.title, def.options)
        if timeout = 0
            return
        SetTimer((*) => TrayTip(), -timeout)
    }
}