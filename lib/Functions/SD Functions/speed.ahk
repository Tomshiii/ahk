; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\Editors\Premiere>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\errorLog>
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
        effCtrlNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
        ControlGetPos(&classX, &classY, &width, &height, effCtrlNN) ;gets the x/y value and width/height value
    } catch as e {
        block.Off() ;just incase
        tool.Cust("Couldn't get the ClassNN of the desired panel")
        errorLog(e)
        return
    }
    prem.__focusTimeline() ;focuses the timeline
    if !prem.checkNoClips(effCtrlNN, &x, &y) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            return
        }
    SendInput(KSA.speedMenu amount "{ENTER}")
}