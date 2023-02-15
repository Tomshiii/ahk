; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\tool>
#Include <Functions\errorLog>
#Include <Classes\keys>
; }

/**
 * This function finds the scale value, clicks on it, then makes your clip whatever value you want
 * @param {Integer} amount is what you want the scale to be set to
 */
scale(amount)
{
    ;// This function borrows code from `prem.valuehold()`
    if !IsNumber(amount)
        {
            ;// throw
            errorLog(TypeError("Invalid parameter type in Parameter #1", -1, amount),,, 1)
        }
    ;This function will only operate correctly if the space between the x value and y value is about 210 pixels away from the left most edge of the "timer" (the icon left of the value name)
    ;I use to have it try to function irrespective of the size of your panel but it proved to be inconsistent and too unreliable.
    ;You can plug your own x distance in by changing the value below
    xdist := 210
    coord.s()
    MouseGetPos(&xpos, &ypos)
    block.On()
    SendInput(KSA.effectControls)
    SendInput(KSA.effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    try {
        ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
        ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
    } catch as e {
        block.Off() ;just incase
        tool.Cust("Couldn't get the ClassNN of the desired panel")
        errorLog(e)
        return
    }
    SendInput(KSA.timelineWindow) ;focuses the timeline
    if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
        { ;any imagesearches on the effect controls window includes a division variable (KSA.ECDivide) as I have my effect controls quite wide and there's no point in searching the entire width as it slows down the script
            SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    block.Off()
                    errorLog(Error("No clips are selected", -1),, 1)
                    return
                }
        }
    loop {
        if A_Index > 1
            {
                ToolTip(A_Index)
                SendInput(KSA.effectControls)
                SendInput(KSA.effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
                try {
                    ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
                    ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
                } catch as e {
                    tool.Cust("Couldn't get the ClassNN of the Effects Controls panel")
                    errorLog(e)
                    MouseMove(xpos, ypos)
                    return
                }
            }
        if ( ;finds the value you want to adjust, then finds the value adjustment to the right of it
                ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "scale.png") ||
                ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "scale2.png") ||
                ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "scale3.png") ||
                ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "scale4.png")
        )
            break
        if A_Index > 3
            {
                block.Off()
                errorLog(IndexError("Couldn't find the desired property", -1),, 1)
                keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                MouseMove(xpos, ypos)
                return
            }
        sleep 50
    }
    colour:
    if !PixelSearch(&xcol, &ycol, x, y, x + xdist, y + "40", 0x205cce, 2)
        {
            block.Off()
            errorLog(Error("Couldn't find the blue 'value' text", -1),, 1)
            keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
            MouseMove(xpos, ypos)
            return
        }
    MouseMove(xcol, ycol)
    SendInput "{Click}"
    SendInput(amount)
    SendInput("{Enter}")
    MouseMove xpos, ypos
    SendInput(KSA.timelineWindow)
    block.Off()
}