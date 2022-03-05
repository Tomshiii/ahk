;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.9.2
#Include General.ahk

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
    if(%&x% > 550 and %&x% < 2542) and (%&y% > 1010) ;this ensures that this function only tries to activate if it's within the timeline of after effects
        {
            blockOn()
            MouseGetPos(&X, &Y)
            if ImageSearch(&selectX, &selectY, 8, 8, 299, 100, "*2 " AE "selection.png")
                {
                    MouseMove(%&selectX%, %&selectY%)
                    Click
                    MouseMove(%&X%, %&Y%)
                }
            Click()
            SendInput(anchorpointProp) ;swaps to a redundant value (in this case "anchor point" because I don't use it) ~ check the keyboard shortcut ini file to adjust hotkeys
            sleep 150
            SendInput(%&button%) ;then swaps to your button of choice. We do this switch second to ensure it and it alone opens (if you already have scale open for example then you press "s" again, scale will hide)
            sleep 300 ;after effects is slow as hell so we have to give it time to swap over or the imagesearch's won't work
            if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " AE %&property% ".png")
                goto colour
            else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " AE %&property% "2.png")
                goto colour
            else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " AE %&property% "Key.png")
                goto colour
            else if ImageSearch(&propX, &propY, 0, %&y% - "23", 550, %&y% + "23", "*2 " AE %&property% "Key2.png")
                goto colour
            else
                {
                    blockOff()
                    toolFind("the property you're after", "1000")
                    errorLog(A_ThisFunc, "Couldn't find the property the user was after", A_LineNumber)
                    KeyWait(A_ThisHotkey)
                    return
                }
            colour:
            if PixelSearch(&xcol, &ycol, %&propX%, %&propY% + "8", %&propX% + "740", %&propY% + "40", 0x288ccf, 3)
                MouseMove(%&xcol% + %&optional%, %&ycol%)
            ;sleep 50
            if GetKeyState(A_ThisHotkey, "P")
                {
                    SendInput("{Click Down}")
                    blockOff()
                    KeyWait(A_ThisHotkey)
                    SendInput("{Click Up}")
                    MouseMove(%&x%, %&y%)
                }
            else ;if you tap, this function will then right click and menu to the "reset" option in the right click context menu
                {
                    Click("Right")
                    SendInput("{Up 6}" "{Enter}")
                    MouseMove(%&x%, %&y%)
                    blockOff()
                }
        }
    else
        {
            toolCust("you're not hovering a track", "1000")
            errorLog(A_ThisFunc, "User not hovering over a track", A_LineNumber)
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
    colour := PixelGetColor(%&x%, %&y%) ;assigned the pixel colour at the mouse coords to the variable "colour"
    if colour != 0x9E9E9E ;0x9E9E9E is the colour of a selected track - != means "not equal to"
        {
            toolCust("you haven't selected a clip`nor aren't hovering the right spot", "1000")
            errorLog(A_ThisFunc, "User not hovering over the right spot on the track", A_LineNumber)
            blockOff()
            Exit
        }
    SendInput(audioAE effectsAE) ;we first bring focus to another window, then to the effects panel since after effects is all about "toggling" instead of highlighting. These values can be set within KSA.ini
    sleep 100
    effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
    ControlGetPos(&efx, &efy, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
    if ImageSearch(&x2, &y2, %&efx%, %&efy%, %&efx% + %&width%, %&efy% + %&height%, "*2 " AE "findbox.png")
        goto move
    else if ImageSearch(&x2, &y2, %&efx%, %&efy%, %&efx% + %&width%, %&efy% + %&height%, "*2 " AE "findbox2.png")
        goto move
    else
        {
            blockOff()
            toolCust("couldn't find the magnifying glass", "1000")
            errorLog(A_ThisFunc, "Couldn't find the magnifying glass", A_LineNumber)
            return
        }
    move:
    MouseMove(%&x2%, %&y2%)
    SendInput("{Click}")
    SendInput("^a" "+{BackSpace}")
    CaretGetPos(&find)
    if %&find% = "" ;this loop is to make sure after effects finds the text field
        {
            loop 10 {
                sleep 30
                CaretGetPos(&find2x)
                if %&find2x% != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                    break
                toolCust("The function attempted " A_Index " times`n for a total of " A_Index * 30 "ms", "2000")
                if A_Index > 10
                    {
                        blockOff()
                        toolCust("Couldn't determine the caret", "1000")
                        errorLog(A_ThisFunc,"Function couldn't determine the caret position", A_LineNumber)
                        return
                    }
            }
        }
    SendInput(%&preset%)
    sleep 100
    MouseMove(59, 43, 2, "R") ;moves the mouse relative to the start position to ensure it always grabs the preset you want at mouse speed 2, this helps as after effects can be quite slow
    SendInput("{Click Down}")
    MouseMove(%&x%, %&y%, "2") ;drags the preset back to the starting position (your layer) at mouse speed 2, it's important to slow down the mouse here or after effects won't register you're dragging the preset
    sleep 100
    SendInput("{Click Up}")
    MouseMove(%&x2%, %&y2%)
    SendInput("{Click}")
    SendInput("^a" "+{BackSpace}" "{Enter}") ;deletes whatever was typed into the effects panel
    MouseMove(%&x%, %&y%)
    blockOff()
}