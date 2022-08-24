;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.12.2
#Include General.ahk

;Although I have some scripts for AE, they aren't as kept up to date as their Premiere cousins - most of my work is in premiere and the work that I do within AE is usually the same from project to project so there isn't as much room for expansion/experimentation. After Effects is also a lot harder to script for as it is significantly more sluggish and is more difficult to tell when you're within certain parts of the program making it harder for ahk to know when it's supposed to move on outside of just coding in multiple seconds worth of sleeps until AE chooses to react. As a result of all of this, some of these scripts may, at anytime, stop functioning the way I originally coded them to as AE decides to be ever so slightly more sluggish than previously and breaks everything - this has generally caused me to not only shy away from creating scripts for AE, but has also caused me to stop using some of the ones I create as they tend to break far too often which at the end of the day just wastes more of my time than is worth it

/* aevaluehold()
 A function to warp to one of a videos values within After Effects (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
 @param button is the hotkey within after effects that's used to open up the property you want to adjust
 @param property is the filename of just the property itself ie. "scale" not "scale.png" or "scale2"
 @param optional is for when you need the mouse to move extra coords over to avoid the first "blue" text for some properties
 */
aevaluehold(button, property, optional) ;this function is incredibly touchy and I need to revisit it one day to improve it so that it's actually usable, but for now I don't really use it, after effects is just too jank
{
    coordw()
    MouseGetPos(&x, &y)
    if(x > 550 and x < 2542) and (y > 1010) ;this ensures that this function only tries to activate if it's within the timeline of after effects
        {
            blockOn()
            MouseGetPos(&X, &Y)
            if ImageSearch(&selectX, &selectY, 8, 8, 299, 100, "*2 " AE "selection.png")
                {
                    MouseMove(selectX, selectY)
                    Click
                    MouseMove(X, Y)
                }
            Click()
            SendInput(anchorpointProp) ;swaps to a redundant value (in this case "anchor point" because I don't use it) ~ check the keyboard shortcut ini file to adjust hotkeys
            sleep 150
            SendInput(button) ;then swaps to your button of choice. We do this switch second to ensure it and it alone opens (if you already have scale open for example then you press "s" again, scale will hide)
            sleep 300 ;after effects is slow as hell so we have to give it time to swap over or the imagesearch's won't work
            if (
                ImageSearch(&propX, &propY, 0, y - "23", 550, y + "23", "*2 " AE property ".png") ||
                ImageSearch(&propX, &propY, 0, y - "23", 550, y + "23", "*2 " AE property "2.png") ||
                ImageSearch(&propX, &propY, 0, y - "23", 550, y + "23", "*2 " AE property "Key.png") ||
                ImageSearch(&propX, &propY, 0, y - "23", 550, y + "23", "*2 " AE property "Key2.png")
            )
                goto colour
            else
                {
                    blockOff()
                    toolCust("the property you're after",, 1)
                    errorLog(A_ThisFunc "()", "Couldn't find the property the user was after", A_LineFile, A_LineNumber)
                    KeyWait(A_ThisHotkey)
                    return
                }
            colour:
            if PixelSearch(&xcol, &ycol, propX, propY + "8", propX + "740", propY + "40", 0x288ccf, 3)
                MouseMove(xcol + optional, ycol)
            ;sleep 50
            if GetKeyState(A_ThisHotkey, "P")
                {
                    SendInput("{Click Down}")
                    blockOff()
                    KeyWait(A_ThisHotkey)
                    SendInput("{Click Up}")
                    MouseMove(x, y)
                }
            else ;if you tap, this function will then right click and menu to the "reset" option in the right click context menu
                {
                    Click("Right")
                    SendInput("{Up 6}" "{Enter}")
                    MouseMove(x, y)
                    blockOff()
                }
        }
    else
        {
            toolCust("you're not hovering a track")
            errorLog(A_ThisFunc "()", "User not hovering over a track", A_LineFile, A_LineNumber)
        }
}

/* aepreset()
 This function allows you to drag and drop effects onto a clip within After Effects at the press of a button
 @param preset is the name of your preset that you wish to drag onto your clip
 */
aePreset(preset)
{
    blockOn()
    coords()
    MouseGetPos(&x, &y)
    colour := PixelGetColor(x, y) ;assigned the pixel colour at the mouse coords to the variable "colour"
    if colour != 0x9E9E9E ;0x9E9E9E is the colour of a selected track - != means "not equal to"
        {
            toolCust("you haven't selected a clip`nor aren't hovering the right spot")
            errorLog(A_ThisFunc "()", "User not hovering over the right spot on the track", A_LineFile, A_LineNumber)
            blockOff()
            Exit
        }
    SendInput(audioAE effectsAE) ;we first bring focus to another window, then to the effects panel since after effects is all about "toggling" instead of highlighting. These values can be set within KSA.ini
    sleep 100
    try {
        effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
        ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
    } catch as e {
        toolCust("Couldn't find the ClassNN value")
        errorLog(A_ThisFunc "()", "Couldn't find the ClassNN value", A_LineFile, A_LineNumber)
    }
    if ImageSearch(&x2, &y2, efx, efy, efx + width, efy + height, "*2 " AE "findbox.png") || ImageSearch(&x2, &y2, efx, efy, efx + width, efy + height, "*2 " AE "findbox2.png")
        goto move
    else
        {
            blockOff()
            toolCust("couldn't find the magnifying glass")
            errorLog(A_ThisFunc "()", "Couldn't find the magnifying glass", A_LineFile, A_LineNumber)
            return
        }
    move:
    MouseMove(x2, y2)
    SendInput("{Click}")
    SendInput("^a" "+{BackSpace}")
    CaretGetPos(&find)
    if find = "" ;this loop is to make sure after effects finds the text field
        {
            loop 10 {
                sleep 30
                CaretGetPos(&find2x)
                if find2x != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                    break
                toolCust("The function attempted " A_Index " times`n for a total of " A_Index * 30 "ms", 2000)
                if A_Index > 10
                    {
                        blockOff()
                        toolCust("Couldn't determine the caret")
                        errorLog(A_ThisFunc "()","Function couldn't determine the caret position", A_LineFile, A_LineNumber)
                        return
                    }
            }
        }
    SendInput(preset)
    sleep 100
    MouseMove(59, 43, 2, "R") ;moves the mouse relative to the start position to ensure it always grabs the preset you want at mouse speed 2, this helps as after effects can be quite slow
    SendInput("{Click Down}")
    MouseMove(x, y, "2") ;drags the preset back to the starting position (your layer) at mouse speed 2, it's important to slow down the mouse here or after effects won't register you're dragging the preset
    sleep 100
    SendInput("{Click Up}")
    MouseMove(x2, y2)
    SendInput("{Click}")
    SendInput("^a" "+{BackSpace}" "{Enter}") ;deletes whatever was typed into the effects panel
    MouseMove(x, y)
    blockOff()
}

/* scaleAndPos()
 This function is to quickly begin keyframing the scale & position values.
 */
aeScaleAndPos()
{
    KeyWait(A_ThisHotkey)
    ;blockOn()
    coords()
    MouseGetPos(&x, &y)
    colour := PixelGetColor(x, y) ;assigned the pixel colour at the mouse coords to the variable "colour"
    if colour != 0x9E9E9E ;0x9E9E9E is the colour of a selected track - != means "not equal to"
        {
            toolCust("you haven't selected a clip`nor aren't hovering the right spot")
            errorLog(A_ThisFunc "()", "User not hovering over the right spot on the track", A_LineFile, A_LineNumber)
            blockOff()
            Exit
        }
    try {
        effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
        ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
    } catch as e {
        toolCust("Couldn't find the ClassNN value")
        errorLog(A_ThisFunc "()", "Couldn't find the ClassNN value", A_LineFile, A_LineNumber)
    }
    ;ToolTip(efx ", " efy) ;debugging
    SendInput(audioAE "s") ;we first bring focus to another window, then to the effects panel since after effects is all about "toggling" instead of highlighting. These values can be set within KSA.ini
    sleep 200
    xsize := 200
    ysize := 40
    loop {
        ToolTip(A_Index)
        if ImageSearch(&xscale, &yscale, x - xsize, y - ysize, x + xsize, y + ysize, "*2 " AE "scale.png")
            {
                toolCust(A_Index)
                break
            }
        sleep 10
        xsize += 200
        ysize += 5
        if A_Index > 10
            {
                blockOff()
                toolCust("The Scale property after " A_Index " attempts",, 1)
                errorLog(A_ThisFunc, "Couldn't find the Scale property", A_LineFile, A_LineNumber)
                return
            }
    }
    next:
    MouseMove(xscale, yscale)
    SendInput("{Click}")
    SendInput("p")
    Sleep 50
    SendInput("{Click}")
    Sleep 50
    SendInput("u" "u")
    MouseMove(x, y)
    blockOff()
}

/* motionBlur()
 This function will open up the composition settings window within After Effects, navigate its way to the "advanced" tab, find "shuttle angle" and increase it to a value of 360
 */
motionBlur()
{
    KeyWait(A_ThisHotkey)
    coords()
    MouseGetPos(&x, &y) ;gets the coordinates of the mouse to return it at the end/after an error
    coordw()
    start := 5
    loop { ;this loop will attempt to search for the blur icon and activate it on the top most track if it isn't already. It's probably possible to do this for any track but that's just not worth me trying to figure out when a large majority of my work is just on the top track as I precomp most things
        ToolTip(A_Index)
        if ImageSearch(&blurx, &blury, 0, A_ScreenHeight / start, A_ScreenWidth, A_ScreenHeight, "*2 " AE "blur3.png") || ImageSearch(&blurx, &blury, 0, A_ScreenHeight / start, A_ScreenWidth, A_ScreenHeight, "*2 " AE "blur4.png") ;checks if the blur icon is already activated
            break
        if ImageSearch(&blurx, &blury, 0, A_ScreenHeight / start, A_ScreenWidth, A_ScreenHeight, "*2 " AE "blur.png") || ImageSearch(&blurx, &blury, 0, A_ScreenHeight / start, A_ScreenWidth, A_ScreenHeight, "*2 " AE "blur2.png")
            {
                MouseMove(blurx + 3, blury + 20)
                SendInput("{Click}")
                ToolTip("")
                break
            }
        start -= 1
        MouseMove(-30, 0,, "R") ;move the mouse incase it's in the way
        if A_Index > 4
            {
                toolCust("Couldn't find blur button")
                errorLog(A_ThisFunc "()", "Couldn't find the blur button", A_LineFile, A_LineNumber)
                break
            }
    }
    if WinExist("Composition Settings") ;if the menu is already open, this check will allow us to continue without running into any futher issues
        goto open
    blockOn()
    SendInput(compSettings) ;opens the composition settings
    WinWait("Composition Settings") ;waits for composition settings to open
    open:
    MouseMove(0,0)
    loop { ;this loop will allow us to make multiple checks for the advanced tab - as adobe products can be quite laggy this loop will give us about 0.6s for AE to react. If your machine is too slow, or AE is just sluggish, consider increasing the amount of times the loop will continue before returning or increasing the sleep between each attempt
        if ImageSearch(&advX, &advY, 0, 0, 200, 200, "*2 " AE "advanced.png") || ImageSearch(&advX, &advY, 0, 0, 200, 200, "*2 " AE "advanced2.png") ;this imagesearch will check for both the non selected text & the selected text varient
            {
                ToolTip("")
                break
            }
        if A_Index > 0
            ToolTip(A_Index)
        sleep 50
        if WinExist("Composition Settings")
            WinActivate("Composition Settings")
        if A_Index > 10
            {
                ToolTip("")
                coords()
                MouseMove(x, y)
                blockOff()
                errorLog(A_ThisFunc "()", "Couldn't find the Advanced tab", A_LineFile, A_LineNumber)
                toolCust("the Advanced tab",, 1)
                return
            }
    }
    MouseMove(advX, advY) ;moves to the advanced tab
    SendInput("{Click}") ;clicks it
    loop { ;this loop will allow us to make multiple checks for the shutter angle - as adobe products can be quite laggy this loop will give us about 0.6s for AE to react. If your machine is too slow, or AE is just sluggish, consider increasing the amount of times the loop will continue before returning or increasing the sleep between each attempt
        if ImageSearch(&shutX, &shutY, 0, 0, 200, 300, "*2 " AE "shutterangle.png")
            {
                ToolTip("")
                break
            }
        if A_Index > 0
            ToolTip(A_Index)
        sleep 50
        if WinExist("Composition Settings")
            WinActivate("Composition Settings")
        if A_Index > 10
            {
                ToolTip("")
                coords()
                MouseMove(x, y)
                blockOff()
                errorLog(A_ThisFunc "()", "Couldn't find the Shutter Angle image", A_LineFile, A_LineNumber)
                toolCust("the Shutter Angle image",, 1)
                return
            }
    }
    loop { ;this loop will allow us to make multiple checks for the shutter angle value - as adobe products can be quite laggy this loop will give us about 0.6s for AE to react. If your machine is too slow, or AE is just sluggish, consider increasing the amount of times the loop will continue before returning or increasing the sleep between each attempt
        if PixelSearch(&xcol, &ycol, shutX, shutY, shutX + "150", shutY + "40", 0x234CB4, 2)
            {
                ToolTip("")
                MouseMove(xcol, ycol)
                SendInput("{Click}")
                SendInput("360" "{Enter}")
                coords()
                MouseMove(x, y)
                blockOff()
                break
            }
        if A_Index > 0
            ToolTip(A_Index)
        sleep 50
        if WinExist("Composition Settings")
            WinActivate("Composition Settings")
        if A_Index > 10
            {
                ToolTip("")
                coords()
                MouseMove(x, y)
                blockOff()
                errorLog(A_ThisFunc "()", "Couldn't find the Shutter Angle value", A_LineFile, A_LineNumber)
                toolCust("the Shutter Angle value",, 1)
                return
            }
    }
    ToolTip("")
}

/* timeline()
  A weaker version of the right click premiere script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock). This function uses a few imagesearches to determine the position of the timeline - NOTE: The imagesearches are still somewhat reliant on the way I have AE setup (I divide some coord ranges to save time on first use), you may need to adjust these if your aetimeline is in a non standard place
  */
aetimeline()
{
    coordw()
    MouseGetPos(&xpos, &ypos)

    static graphX := 0
    static graphY := 0
    static end := 0
    static bottom := 0

    /*
     A small function to get the coords of the graph icon, marker icon & mountain icon to determine the position of your timeline
     */
    getCoords(&graphX, &graphY, &end, &bottom)
    {
        if ImageSearch(&x, &y, 0, 0, A_ScreenWidth / 2, A_ScreenHeight, "*2 " AE "\graph.png") || ImageSearch(&graphX, &graphY, 0, 0, A_ScreenWidth / 2, A_ScreenHeight, "*2 " AE "\graph2.png")
            {
                graphX := x + 30
                graphY := y + 8
            }
        if ImageSearch(&endX, &endY, A_ScreenWidth / 2, 200, A_ScreenWidth + 20, A_ScreenHeight, "*2 " AE "\marker.png")
            end := endX - 12
        if ImageSearch(&mountX, &mountY, 0, A_ScreenHeight / 4, A_ScreenWidth / 1.5, A_ScreenWidth, "*2 " AE "\mountain.png")
            bottom := mountY - 8
    }
    if graphX = 0 && graphY = 0 && end = 0 && bottom = 0
        {
            toolCust(A_ThisFunc "() is grabbing the timeline coords", "2000")
            getCoords(&graphX, &graphY, &end, &bottom)
            if !IsSet(end) || !IsSet(graphX) || !IsSet(graphY) || !IsSet(bottom)
                {
                    toolCust("A variable was not assigned a value")
                    errorLog(A_ThisFunc "()", "A variable was not assigned a value", A_LineFile, A_LineNumber)
                    return
                }
        }
    MouseGetPos(&newX, &newY)
    if(xpos > graphX and xpos < end) and (ypos > graphY and ypos < bottom)
        {
            blockOn()
            if newX > graphX and newX < end
                xpos := newX
            MouseMove(xpos, graphY) ;this will warp the mouse to the top part of your timeline defined by &timeline
            SendInput("{Click Down}")
            MouseMove(xpos, ypos)
            blockOff()
            KeyWait(A_ThisHotkey)
            SendInput("{Click Up}")
        }
    else
        return
}