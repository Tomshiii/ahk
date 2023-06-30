; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\tool>
#Include <Classes\errorLog>
; }

/**
 * A function to skip in youtube

 * @param {String} tenS is the hotkey for 10s skip in your direction of choice
 * @param {String} fiveS is the hotkey for 5s skip in your direction of choice
 */
youMouse(tenS, fiveS)
{
    if A_PriorKey = "Mbutton" ;ensures the hotkey doesn't fire while you're trying to open a link in a new tab
        return
    if WinExist("YouTube")
    {
        try {
            lastactive := WinGetID("A") ;fills the variable [lastactive] with the ID of the current window
        }
        WinActivate() ;activates Youtube if there is a window of it open
        sleep 25 ;sometimes the window won't activate fast enough
        if GetKeyState(KSA.longSkip, "P") ;checks to see if you have a second key held down to see whether you want the function to skip 10s or 5s. If you hold down this second button, it will skip 10s
            SendInput(tenS)
        else
            SendInput(fiveS) ;otherwise it will send 5s
        try {
            WinActivate(lastactive) ;will reactivate the original window
        } catch as e {
            tool.Cust("Failed to get information on the previously active window")
            errorLog(e)
        }
    }
}