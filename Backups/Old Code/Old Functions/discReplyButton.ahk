/**
     * potential blue colours for the `@ON` in discord when you reply to someone
     */
colours := [0x259fcf, 0x3047a2, 0x2884a9, 0x30318a, 0x289AD5, 0x299AD5]

/**
 * This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \Support Files\ImageSearch\disc[button].png
 *
 * This function is constantly being broken as discord updates their logo/the @ reply ping button. When this happens you can try taking new screenshots to see if that fixes the issue.
 *
 * This function may encounter different behaviours depending on the orientation of the monitor that it's on/the resolution. It hasn't been tested on anything higher than a `1440p` monitor.
 *
 * *This function includes specific code for the reply button and requires the passed parameter to be `DiscReply.png`*
 * *This function includes specific code for the delete button and requires the passed parameter to be `DiscDelete.png`*
 * @param {String} button is the png name of a screenshot of the button you want the function to press.
 * ```
 * ;NOTE this function may only work if you use the same display settings. Otherwise you may need your own screenshots.
 * ;dark theme
 * ;chat font scaling: 20px
 * ;space between message groups: 16px
 * ;zoom level: 100
 * ;saturation; 70%
 * ```
 */
button(button) {
    if !this.logoCheck
        this().__logoCheck()
    yheight := 400
    keys.allWait("second")
    MouseGetPos(&x, &y)
    WinGetPos(&nx, &ny, &width, &height, this.winTitle) ;gets the width and height to help this function work no matter how you have discord
    block.On()
    SendInput("{RButton}") ;this opens the right click context menu on the message you're hovering over
    sleep 50 ;sleep required so the right click context menu has time to open
    loop {
        if ImageSearch(&xpos, &ypos, x-200, y-400,  x+200, y + yheight, "*2 " ptf.Discord button) ;searches for the button you've requested
            {
                MouseMove(xpos, ypos)
                break
            }
        if (button == "DiscDelete.png" || button == "DiscEdit.png") && ImageSearch(&xpos, &ypos, x-200, y-400,  x+200, y + yheight, "*2 " ptf.Discord "report.png") ;searches for the button you've requested
            {
                block.Off()
                errorLog(ValueError("User isn't hovering a message they sent.", -1),, 1)
                return
            }
        ;// if the button isn't found, we increase the search area
        sleep 50
        yheight += 100
        if A_Index > 4
            ToolTip(A_ThisFunc "() has attempted to find the desired button " A_Index " times")
        if A_Index > 10 ;after waiting over 0.5s the function will excecute the below
            {
                ToolTip("")
                MouseMove(x, y) ;moves the mouse back to the original coords
                block.Off()
                errorLog(IndexError("Was unable to find the requested button", -1, button),, 1)
                return
            }
    }
    if (button == "DiscDelete.png") && (GetKeyState("Shift", "P")) {
        ;// if the user is holding shift to indicate they want to immediately delete the message
        SendInput("{Shift Down}{Click}{Shift Up}")
        MouseMove(x, y)
        block.Off()
        return
    }
    SendInput("{Click}")
    sleep 100
    if button != "DiscReply.png" || (!ImageSearch(&x2, &y2, 0, 0, 100, 100, "*2 " ptf.Discord "dm1.png") && !ImageSearch(&x2, &y2, 0, 0, 100, 100, "*2 " ptf.Discord "dm1_2.png"))
        this().__move_exit(x, y)  ;YOU MUST CALL YOUR REPLY IMAGESEARCH FILE "DiscReply.png" FOR THIS PART OF THE CODE TO WORK - ELSE CHANGE THIS VALUE TOO
    loop {
            if ImageSearch(&xdir, &ydir, width/2, height-115, width, height, "*2 " ptf.Discord "DiscDirReply.png") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. If you prefer to leave that on, remove from the above sleep 100, to the `end:` below. The coords here are to search the entire window (but only half the windows height) - (that's what the WinGetPos is for) for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish but it isn't really neccessary.
                {
                    this().__move_click(xdir, ydir)
                    break
                }
            ;// if the loop hasn't found the image after 5 attempts, the function will fallback to searching for some of the blue pixel colours in the word itself as they aren't found anywhere else
            if A_Index > 5
                {
                    found := false
                    block.Off()
                    loop this().colours.Length {
                        block.Off()
                        if PixelSearch(&colX, &colY, width/2, height-115, width, height, Format("{:#x}", this().colours[A_Index]), 2)
                            {
                                this().__move_click(colX, colY)
                                found := true
                                break
                            }
                    }
                    if found = true
                        break
                }
            if A_Index > 10
                {
                    errorLog(IndexError("Was unable to find the @ reply ping button", -1, button),, 1)
                    break
                }
        }
    this().__move_exit(x, y)
}