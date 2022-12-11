; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\coord>
#Include <Classes\winGet>
#Include <Functions\errorLog>
#Include <Functions\getHotkeys>
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
        if GetKeyState(longSkip, "P") ;checks to see if you have a second key held down to see whether you want the function to skip 10s or 5s. If you hold down this second button, it will skip 10s
            SendInput(tenS)
        else
            SendInput(fiveS) ;otherwise it will send 5s
        try {
            WinActivate(lastactive) ;will reactivate the original window
        } catch as e {
            tool.Cust("Failed to get information on the previously active window")
            errorLog(e, A_ThisFunc "()")
        }
    }
}

/**
 * warp anywhere on your desktop
 */
monitorWarp(x, y)
{
    coord.s()
    MouseMove(x, y, 2) ;I need the 2 here as I have multiple monitors and things can be funky moving that far that fast. random ahk problems. Change this if you only have 1/2 monitors and see if it works fine for you
}

/**
 * This function is to allow the user to simply jump 10 characters in either direction. Useful when ^Left/^Right isn't getting you to where you want the cursor to be
 *
 * @param {Integer} amount is the amount of characters you want this function to jump, by default it is set to 10 and isn't required if you do not wish to override this value
 */
jumpChar(amount := 10)
{
    getHotkeys(&first, &second)
    side := "{" second " " amount "}"
    if GetKeyState("Shift", "P")
        {
            SendInput("{Shift Down}" side "{Shift Up}")
            return
        }
    SendInput(side)
}

/**
 * This function facilitates accelerated scrolling. If the window under the cursor isn't the active window when this function is called, it will activate it.
 *
 * *This function use to send 10 WheelUp/Down events but that just kept lagging everything out no matter what I tried to do to fix it, so now it sends PgUp/Dn*
 */
fastWheel()
{
	getHotkeys(&first, &second)
    if second = "WheelUp"
        type := "Up"
    else
        type := "Dn"
	MouseGetPos(,, &UnderCursor)
	orig := WinGetTitle(WinActive("A"))
	titleUnder := WinGetTitle("ahk_id " UnderCursor)
    classUnder := WinGetClass("ahk_id " UnderCursor)
	if orig != titleUnder && classUnder != "tooltips_class32"
		WinActivate(titleUnder)
    WinWaitActive(titleUnder)
    proc := WinGetProcessName(titleUnder)
    if ((InStr(titleUnder, "Visual Studio Code") && proc = "Code.exe") && !InStr(titleUnder, "Preview"))
        SendInput(focusCode)
	SendInput("{Pg" type "}")
	/* SendInput("{" second " 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
    */
}

/**
 * A function to close a window, then reopen it in an attempt to refresh its information (for example, a txt file)
 * @param {any} window is the title of the window you wish to target
 * @param {any} runTarget is the path of the file you wish to open
 */
refreshWin(window, runTarget)
{
    coord.s()
    if window = "A"
        {
            window := WinGetTitle("A")
            if WinGetProcessName(window) = "Notepad.exe"
                {
                    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name='notepad.exe'")
                        runTarget := process.CommandLine
                }
            if WinGetProcessName(window) = "explorer.exe"
                {
                    hwnd := WinExist(window)
                    path := winget.ExplorerPath(hwnd)
                    if !path
                        {
                            tool.Cust("Couldn't determine the path of the explorer window")
                            errorLog(, A_ThisFunc "()", "Couldn't determine the path of the explorer window", A_LineFile, A_LineNumber)
                            return
                        }
                    runTarget := path
                }
        }
    WinGetPos(&x, &y, &width, &height, window)
    WinClose(window)
    if !WinWaitClose(window,, 1.5)
        {
            tool.Cust("waiting for the window to close timed out")
            errorLog(, A_ThisFunc "()", "waiting for the window to close timed out", A_LineFile, A_LineNumber)
            return
        }
    sleep 250
    Run(runTarget)
    ; MsgBox(runTarget)
    if !WinWait(window,, 1.5)
        {
            try {
                sleep 100
                Run(runTarget)
                if !WinWait(window,, 1.5)
                    {
                        tool.Cust("waiting for the window to open timed out")
                        errorLog(, A_ThisFunc "()", "waiting for the window to open timed out", A_LineFile, A_LineNumber)
                        return
                    }
            }
        }
    WinActivate(window)
    prior := A_WinDelay
    A_WinDelay := 500
    WinMove(x, y, width, height, window)
    A_WinDelay := prior
}