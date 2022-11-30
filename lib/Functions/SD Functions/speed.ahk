; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\tool>
; }

/**
 * This function opens up the speed menu and sets the clips speed to whatever is set
 * @param {Integer} amount is what speed you want your clip to be set to
 */
speed(amount)
{
    ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro"
    if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " ptf.Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
        SendInput(timelineWindow selectAtPlayhead)
    else
        {
            classNN := ControlGetClassNN(ControlGetFocus("A"))
            if classNN = "DroverLord - Window Class3"
                {
                    tool.Cust("gain macro couldn't figure`nout what to do")
                    return
                }
        }
    inputs:
    SendInput(speedMenu amount "{ENTER}")
}