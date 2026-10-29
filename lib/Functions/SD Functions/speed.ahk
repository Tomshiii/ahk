; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\ptf.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\tool.ahk
#Include Classes\block.ahk
#Include Classes\errorLog.ahk
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
    prem.__focusTimeline() ;focuses the timeline
    if !prem.isClipSelected() {
        block.Off()
        errorLog(Error("No clips are selected", -1),, 1)
        return
    }
    SendInput(KSA.prem.speedMenu amount "{ENTER}")
}