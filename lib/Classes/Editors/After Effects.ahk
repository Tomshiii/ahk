/************************************************************************
 * @description A library of useful After Effects functions to speed up common tasks
 * Originally tested on and designed for v22.6 of After Effects. As of 2023/06/30 code is maintained for the version of After Effects listed below
 * Any code after that date is no longer guaranteed to function on previous versions of AE.
 * @aeVer 25.4
 * @author tomshi
 * @date 2024/09/06
 * @version 1.2.7
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\keys>
#Include <Classes\obj>
#Include <Classes\errorLog>
#Include <Functions\delaySI>
; }

;Although I have some scripts for AE, they aren't as kept up to date as their Premiere cousins - most of my work is in premiere and the work that I do within AE is usually the same from project to project so there isn't as much room for expansion/experimentation. After Effects is also a lot harder to script for as it is significantly more sluggish and is more difficult to tell when you're within certain parts of the program making it harder for ahk to know when it's supposed to move on outside of just coding in multiple seconds worth of sleeps until AE chooses to react. As a result of all of this, some of these scripts may, at anytime, stop functioning the way I originally coded them to as AE decides to be ever so slightly more sluggish than previously and breaks everything - this has generally caused me to not only shy away from creating scripts for AE, but has also caused me to stop using some of the ones I create as they tend to break far too often which at the end of the day just wastes more of my time than is worth it

class AE {

    static __New() {
        UserSettings := UserPref()
        this.currentSetVer := SubStr(UserSettings.aeVer, 2)
        UserSettings.__delAll()
        UserSettings := ""

        switch {
            case VerCompare(this.currentSetVer, this.spectrumUI_Version) >= 0: this.focusColour := 0x066CE7
			case VerCompare(this.currentSetVer, this.spectrumUI_Version) < 0:  this.focusColour := 0x2D8CEB
        }
    }

    static spectrumUI_Version := "25.0"

    static exeTitle := Editors.AE.winTitle
    static winTitle := this.exeTitle
    static class := Editors.AE.class
    static path := ptf["AE"]

    static focusColour := 0x2D8CEB
    static currentSetVer := ""

    /**
     * This function is to quickly begin keyframing the scale & position values.
     */
    static scaleAndPos()
    {
        keys.allWait()
        ;block.On()
        coord.s()
        MouseGetPos(&x, &y)
        colour := PixelGetColor(x, y) ;assigned the pixel colour at the mouse coords to the variable "colour"
        if colour != 0x9E9E9E ;0x9E9E9E is the colour of a selected track - != means "not equal to"
            {
                errorLog(Error("User not hovering over the right spot on the track")
                            , "Or not hovering over the right spot", 1)
                block.Off()
                return
            }
        try {
            effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
        } catch as e {
            tool.Cust("Couldn't find the ClassNN value")
            errorLog(e)
        }
        ;ToolTip(efx ", " efy) ;debugging
        SendInput(KSA.audioAE "s") ;we first bring focus to another window, then to the effects panel since after effects is all about "toggling" instead of highlighting. These values can be set within KSA.ini
        sleep 200
        xsize := 200
        ysize := 40
        loop {
            ToolTip(A_Index)
            if ImageSearch(&xscale, &yscale, x - xsize, y - ysize, x + xsize, y + ysize, "*2 " ptf.AE "scale.png")
                {
                    tool.Cust(A_Index)
                    break
                }
            sleep 10
            xsize += 200
            ysize += 5
            if A_Index > 10
                {
                    block.Off()
                    errorLog(IndexError("Couldn't find the Scale property", -1),, 1)
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
        block.Off()
    }

    /**
     * This function will open up the composition settings window within After Effects, navigate its way to the "advanced" tab, find "shuttle angle" and increase it to a value of 360
     */
    static motionBlur()
    {
        keys.allWait()
        coord.s()
        MouseGetPos(&x, &y) ;gets the coordinates of the mouse to return it at the end/after an error
        coord.w()
        start := 5
        loop { ;this loop will attempt to search for the blur icon and activate it on the top most track if it isn't already. It's probably possible to do this for any track but that's just not worth me trying to figure out when a large majority of my work is just on the top track as I precomp most things
            ToolTip(A_Index)
            if ImageSearch(&blurx, &blury, 0, A_ScreenHeight / start, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.AE "blur3.png") || ImageSearch(&blurx, &blury, 0, A_ScreenHeight / start, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.AE "blur4.png") ;checks if the blur icon is already activated
                break
            if ImageSearch(&blurx, &blury, 0, A_ScreenHeight / start, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.AE "blur.png") || ImageSearch(&blurx, &blury, 0, A_ScreenHeight / start, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.AE "blur2.png")
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
                    errorLog(IndexError("Couldn't find the blur button", -1),, 1)
                    break
                }
        }
        if WinExist("Composition Settings") ;if the menu is already open, this check will allow us to continue without running into any futher issues
            goto open
        block.On()
        SendInput(KSA.compSettings) ;opens the composition settings
        WinWait("Composition Settings") ;waits for composition settings to open
        open:
        MouseMove(0,0)
        loop { ;this loop will allow us to make multiple checks for the advanced tab - as adobe products can be quite laggy this loop will give us about 0.6s for AE to react. If your machine is too slow, or AE is just sluggish, consider increasing the amount of times the loop will continue before returning or increasing the sleep between each attempt
            if ImageSearch(&advX, &advY, 0, 0, 200, 200, "*2 " ptf.AE "advanced.png") || ImageSearch(&advX, &advY, 0, 0, 200, 200, "*2 " ptf.AE "advanced2.png") ;this imagesearch will check for both the non selected text & the selected text varient
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
                    coord.s()
                    MouseMove(x, y)
                    block.Off()
                    errorLog(IndexError("Couldn't find the advanced tab", -1),, 1)
                    return
                }
        }
        MouseMove(advX, advY) ;moves to the advanced tab
        SendInput("{Click}") ;clicks it
        loop { ;this loop will allow us to make multiple checks for the shutter angle - as adobe products can be quite laggy this loop will give us about 0.6s for AE to react. If your machine is too slow, or AE is just sluggish, consider increasing the amount of times the loop will continue before returning or increasing the sleep between each attempt
            if ImageSearch(&shutX, &shutY, 0, 0, 200, 300, "*2 " ptf.AE "shutterangle.png")
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
                    coord.s()
                    MouseMove(x, y)
                    block.Off()
                    errorLog(IndexError("Couldn't find the shutter angle", -1),, 1)
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
                    coord.s()
                    MouseMove(x, y)
                    block.Off()
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
                    coord.s()
                    MouseMove(x, y)
                    block.Off()
                    errorLog(IndexError("Couldn't find the shutter angle value", -1),, 1)
                    return
                }
        }
        ToolTip("")
    }

    /**
     * A weaker version of the Premiere_RightClick.ahk script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock). This function uses a few imagesearches to determine the position of the timeline - NOTE: The imagesearches are still somewhat reliant on the way I have AE setup (I divide some coord ranges to save time on first use), you may need to adjust these if your aetimeline is in a non standard place
     */
    static timeline()
    {
        coord.w()
        MouseGetPos(&xpos, &ypos)
        static graphX := unset
        static graphY := unset
        static end := unset
        static bottom := unset
        static set := unset

        /*
        A small function to get the coords of the graph icon, marker icon & mountain icon to determine the position of your timeline
        */
        getCoords(&graphX, &graphY, &end, &bottom)
        {
            activeWin := WinGetTitle("A")
            if !InStr(activeWin, "Adobe After Effects 20" ptf.AEYearVer " -") && !InStr(activeWin, "Adobe After Effects (Beta)")
                return
            tool.Cust(A_ThisFunc "() is grabbing the timeline coords")
            if ImageSearch(&x, &y, 0, 0, A_ScreenWidth / 2, A_ScreenHeight, "*2 " ptf.AE "graph.png") || ImageSearch(&x, &y, 0, 0, A_ScreenWidth / 2, A_ScreenHeight, "*2 " ptf.AE "graph2.png")
                {
                    graphX := x + 30
                    graphY := y + 8
                }
            if ImageSearch(&endX, &endY, A_ScreenWidth / 2, 200, A_ScreenWidth + 20, A_ScreenHeight, "*2 " ptf.AE "marker.png")
                end := endX - 12
            if ImageSearch(&mountX, &mountY, 0, A_ScreenHeight / 4, A_ScreenWidth / 1.5, A_ScreenWidth, "*2 " ptf.AE "mountain.png")
                bottom := mountY - 8
            set := true
        }
        if !IsSet(set)
            getCoords(&graphX, &graphY, &end, &bottom)
        if (!IsSet(graphX) || !IsSet(graphY) || !IsSet(end) || !IsSet(bottom)) || (!InStr(WinGetTitle("A"), "Adobe After Effects 20" ptf.AEYearVer " -") && !InStr(WinGetTitle("A"), "Adobe After Effects (Beta) -" ))
            {
                SendInput("{" A_ThisHotkey "}")
                tool.Wait()
                switch set ?? false {
                    case true: tool.Cust("The main window is not active")
                    default:
                        errorLog(UnsetError("A variable was not assigned a value", -1)
                                    , "Or the main window is not active", 1)
                }
                return
            }
        MouseGetPos(&newX, &newY)
        if(xpos > graphX and xpos < end) and (ypos > graphY and ypos < bottom)
            {
                block.On()
                if newX > graphX and newX < end
                    xpos := newX
                MouseMove(xpos, graphY) ;this will warp the mouse to the top part of your timeline defined by &timeline
                SendInput("{Click Down}")
                MouseMove(xpos, ypos)
                block.Off()
                keys.allWait()
                SendInput("{Click Up}")
            }
    }

    /**
     * This function will ensure you're in the right mode to adjust blend modes
     */
    static blendMode()
    {
        keys.allWait()
        coord.s()
        MouseGetPos(&x, &y) ;gets the coordinates of the mouse to return it at the end/after an error
        coord.w()
        if !ImageSearch(&modex, &modey, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.AE "mode.png")
            {
                if !ImageSearch(&togx, &togy, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.AE "toggle.png")
                    {
                        errorLog(Error("Couldn't toggle switches/modes", -1),, 1)
                        return
                    }
                MouseMove(togx, togy)
                SendInput("{Click}")
                sleep 250
            }
    }

    /**
     * This function is to quickly input a command into one of the properties of After Effects
     * @param {String} command The command you wish to input
     * @param {Boolean} delete Whether you need the function to delete an extra '(' or ']' that may get automatically generated by AE as the command is input
     */
    static wiggle(command, delete := true)
    {
        CaretGetPos(&findx)
        if findx = ""
            {
                tool.Cust("Couldn't find the caret which indicates you aren't ready to type something`nTo prevent any unintended inputs being sent to AE none will be sent", 3.0)
                errorLog(UnsetError("Couldn't determine the caret position.", -1, findx)
                            , "This indicates the user isn't ready to type anything.")
                return
            }
        SendInput("^a" "{BackSpace}")
        SendInput(command)
        sleep 500
        if delete
            SendInput("{Del}")
        SendInput("{NumpadEnter}")
    }

    /**
     * Trying to zoom in on the preview window can be really annoying when the hotkey only works while the window is focused
     * This function will ensure it happens regardless
     * @param {Object} coords the coordinates of your `tools` bar. requires {x: , x2: , y: , y2: }
     * @param {String} command the hotkey to send to after effects to zoom however you wish
     * @param {Integer} mousespeed the speed you wish for the mouse to move. Defaults to `2`
    */
    static zoomCompWindow(coords, command, mousespeed := 2) {
        __sendOrig() {
            if A_ThisHotkey != "" {
                hot := SubStr(A_ThisHotkey, 1, 1) = "$" ? SubStr(A_ThisHotkey, 2) : A_ThisHotkey
                SendInput(hot)
            }
        }
        if ImageSearch(&xx, &yy, coords.x, coords.y, coords.x2, coords.y2, "*2 " ptf.AE "text.png") {
            __sendOrig()
            return
        }
        mouse := obj.MousePos()
        if !PixelSearch(&colx, &coly, coords.x, coords.y, coords.x2, coords.y2, this.focusColour)
            return
        MouseMove(colx, coly, mousespeed)
        Click
        delaySI(50, KSA.switchCompTimeline, command)
        MouseMove(mouse.x, mouse.y, mousespeed)
    }
}
