;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.13
#Include General.ahk

/**
 * A function to set the scale of a video within resolve
 * @param {Integer} value is the number you want to type into the text field (100% in reslove requires a 1 here for example)
 * @param {String} property is the property you want this function to type a value into (eg. zoom)
 * @param {Integer} plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
 */
Rscale(value, property, plus)
{
    KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
    coord.w()
    block.On()
    SendInput(resolveSelectPlayhead)
    MouseGetPos(&xpos, &ypos)
    if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
        {
            MouseMove(xi, yi)
            click ;this opens the inspector tab
        }
    if !ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png")
        {
            block.Off()
            MouseMove(xpos, ypos)
            tool.Cust("video tab",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the video tab", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xn, yn)
    click ;"2196 139" ;this highlights the video tab
    if !ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve property ".png") && !ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve property "2.png")
        {
            block.Off()
            tool.Cust("your desired property",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the desired property", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xz + plus, yz + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
    click
    SendInput(value)
    SendInput("{ENTER}")
    MouseMove(xpos, ypos)
    SendInput("{MButton}")
    block.Off()
}

/**
 * A function that gets nested in the resolve scale, x/y and rotation scripts
 * @param {String} data is what the script is typing in the text box to reset its value
 */
rfElse(data)
;this function, as you can probably tell, doesn't use an imagesearch. It absolutely SHOULD, but I don't use resolve and I guess I just never got around to coding in an imagesearch.
{
    SendInput("{Click Up}")
    sleep 10
    Send(data)
    ;MouseMove, x, y ;if you want to press the reset arrow, input the windowspy SCREEN coords here then comment out the above Send^
    ;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
    ;alternatively you could also run imagesearches like in the other resolve functions to ensure you always end up in the right place
    sleep 10
    Send("{Enter}")
}

/**
 * A function to apply any effect to the clip you're hovering over within Resolve.
 * @param {String} folder is the name of your screenshots of the drop down sidebar option (in the effects window) you WANT to be active - both activated and deactivated
 * @param {String} effect is the name of the effect you want this function to type into the search box
 */
REffect(folder, effect)
;This function will, in order;
;Check to see if the effects window is open on the left side of the screen
;Check to make sure the effects sidebar is expanded
;Ensure you're clicked on the appropriate drop down
;Open or close/reopen the search bar
;Search for your effect of choice, then drag back to the click you were hovering over originally
{
    KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
    coord.w()
    block.On()
    MouseGetPos(&xpos, &ypos)
    if !ImageSearch(&xe, &ye, effectx1, effecty1, effectx2, effecty2, "*1 " Resolve "effects.png") ;checks to see if the effects button is deactivated
        {
            block.Off()
            tool.Cust("the effects button",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the effects button", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xe, ye)
    SendInput("{Click}")
    if !ImageSearch(&xclosed, &yclosed, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve "closed.png") ;checks to see if the effects window sidebar is opened
        {
            block.Off()
            tool.Cust("open/close button",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the open/close button", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xclosed, yclosed)
    SendInput("{Click}")
    if !ImageSearch(&xfx, &yfx, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve folder "2.png") ;checks to see if the drop down option you want is activated
        {
            block.Off()
            tool.Cust("the fxfolder",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the fxfolder", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xfx, yfx)
    SendInput("{Click}")
    if ImageSearch(&xs, &ys, effectx1, effecty1 + "300", effectx2, effecty2, "*2 " Resolve "search2.png") ;checks to see if the search icon is deactivated
        {
            MouseMove(xs, ys)
            SendInput("{Click}")
            goto final
        }
    else if ImageSearch(&xs, &ys, 8, 8 + "300", effectx2, effecty2, "*2 " Resolve "search3.png") ;checks to see if the search icon is activated
        {
            MouseMove(xs, ys)
            SendInput("{Click 2}")
            goto final
        }
    else ;if everything fails, this else will trigger
        {
            block.Off()
            tool.Cust("search button",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the search button", A_LineFile, A_LineNumber)
            return
        }
    final:
    sleep 50
    SendInput(effect)
    MouseMove(-300, 130,, "R")
    SendInput("{Click Down}")
    MouseMove(xpos, ypos, 2) ;moves the mouse at a slower, more normal speed because resolve doesn't like it if the mouse warps instantly back to the clip
    SendInput("{Click Up}")
    block.Off()
    return
}

/**
 * A function to provide similar functionality within Resolve to my valuehold() function for premiere
 * @param {String} property refers to both of the screenshots (either active or not) for the property you wish to adjust
 * @param {Integer} plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
 * @param {String} rfelseval is the value you wish to pass to rfelse()
 */
rvalhold(property, plus, rfelseval)
{
    coord.w()
    block.On()
    SendInput(resolveSelectPlayhead)
    MouseGetPos(&xpos, &ypos)
    if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
        {
            MouseMove(xi, yi)
            click ;this opens the inspector tab
        }
    video:
    if !ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png")
        {
            block.Off()
            MouseMove(xpos, ypos)
            tool.Cust("video tab",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the video tab", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xn, yn)
    click ;"2196 139" ;this highlights the video tab
    if !ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve property ".png") && !ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve property "2.png")
        {
            block.Off()
            tool.Cust("your desired property",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the desired property", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xz + plus, yz + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
    sleep 100
    SendInput("{Click Down}")
    if !GetKeyState(A_ThisHotkey, "P")
        {
            rfElse(rfelseval) ;do note rfelse doesn't use any imagesearch information and just uses raw pixel values (not a great idea), so if you have any issues, do look into changing that
            MouseMove(xpos, ypos)
            SendInput("{MButton}")
            block.Off()
            return
        }
    block.Off()
    KeyWait(A_ThisHotkey)
    SendInput("{Click Up}")
    MouseMove(xpos, ypos)
}

/**
 * A function to search for and press the horizontal/vertical flip button within Resolve
 * @param {String} button is the png name of a screenshot of the button you wish to click (either activated or deactivated)
 */
rflip(button)
{
    coord.w()
    block.On()
    MouseGetPos(&xpos, &ypos)
    if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png") ;makes sure the video tab is selected
        {
            MouseMove(xn, yn)
            click
        }
    if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*5 " Resolve "inspector2.png")
        {
            MouseMove(xi, yi)
            click
        }
    if !ImageSearch(&xh, &yh, propx1, propy1, propx2, propy2, "*5 " Resolve button ".png") && !ImageSearch(&xh, &yh, propx1, propy1, propx2, propy2, "*5 " Resolve button "2.png")
        {
            block.Off()
            MouseMove(xpos, ypos)
            tool.Cust("desired button",, 1)
            errorLog(A_ThisFunc "()", "Was unable to find the desired button", A_LineFile, A_LineNumber)
        }
    MouseMove(xh, yh)
    click
    MouseMove(xpos, ypos)
    block.Off()
}

/**
 * A function that allows you to adjust the gain of the selected clip within Resolve similar to my gain macros in premiere. You can't pull this off quite as fast as you can in premiere, but it's still pretty useful
 * @param {Integer} value is how much you want the gain to be adjusted by
 */
rgain(value)
{
    coord.w()
    block.On()
    SendInput(resolveSelectPlayhead)
    MouseGetPos(&xpos, &ypos)
    if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
        {
            MouseMove(xi, yi)
            click ;this opens the inspector tab
        }
    if !ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "audio.png")
        {
            block.Off()
            MouseMove(xpos, ypos)
            tool.Cust("audio tab",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the audio tab", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xn, yn)
    click ;"2196 139" ;this highlights the video tab
    if !ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve "volume.png") && !ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve "volume2.png") ;searches for the volume property
        {
            block.Off()
            tool.Cust("your desired property",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Was unable to find the desired property", A_LineFile, A_LineNumber)
            return
        }
    MouseMove(xz + "215", yz + "5") ;moves the mouse to the value next to volume. This function assumes x/y are linked
    SendInput("{Click 2}")
    A_Clipboard := ""
    ;sleep 50
    SendInput("^c")
    ClipWait()
    gain := A_Clipboard + value
    SendInput(gain)
    SendInput("{Enter}")
    MouseMove(xpos, ypos)
    SendInput("{MButton}")
    block.Off()
}