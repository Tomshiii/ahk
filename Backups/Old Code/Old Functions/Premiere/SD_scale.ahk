;// this is a more stripped down version of the scale script that did not borrow code from `prem.valuehold()`

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\tool>
; }

/**
 * This function finds the scale value, clicks on it, then makes your clip whatever value you want
 * @param {Integer} amount is what you want the scale to be set to
 */
scale(amount)
{
    coord.s()
    block.On()
    MouseGetPos &xpos, &ypos
    if ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " ptf.Premiere "scale.png") || ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " ptf.Premiere "scale2.png") ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
        {
            if !PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
                {
                    block.Off()
                    tool.Cust("the blue text",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                    return
                }
            MouseMove(xcol, ycol)
        }
    SendInput "{Click}"
    SendInput(amount)
    SendInput("{Enter}")
    MouseMove xpos, ypos
    Click("middle")
    block.Off()
}