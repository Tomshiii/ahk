; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Functions\errorLog>
; }

/**
 * This function opens up the speed menu and sets the clips speed to whatever is set
 * @param {Integer} amount is what speed you want your clip to be set to
 */
speed(amount)
{
    if !IsNumber(amount)
        {
            ;// throw
            errorLog(TypeError("Invalid parameter type in Parameter #1", -1, amount),,, 1)
        }
    ;// first we make sure clips are selected
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
    SendInput(KSA.speedMenu amount "{ENTER}")
}