; { \\ #Includes
#Include <\Functions\General>
#Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Functions\ptf>
; }

; ===========================================================================================================================================
;
;		Windows Scripts
;
; ===========================================================================================================================================
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
 * This function will grab the monitor that the mouse is currently within and return it as well as coordinate information in the form of a function object. ie if your mouse is within monitor 1 having code `monitor := getMouseMonitor()` would make `monitor.monitor` = 1
 * @returns {object} containing the monitor number, the left/right/top/bottom pixel coordinate
 */
getMouseMonitor()
{
	coord.s()
	MouseGetPos(&x, &y)
    numberofMonitors := SysGet(80)
	loop numberofMonitors {
		try {
			MonitorGet(A_Index, &left, &Top, &Right, &Bottom)
			if x > left && x < Right
				{
					if y < Bottom && y > Top
                        ;MsgBox(x " " y "`n" left " " Right " " Bottom " " Top "`nwithin monitor " A_Index)
                        return {monitor: A_Index, left: left, right: right, top: top, bottom: bottom}
			    }
            if A_Index >= numberofMonitors
                throw TargetError("Couldn't find the monitor", A_ThisFunc "()")
		}
		catch TargetError as e {
            block.Off() ;to stop the user potentially getting stuck
			tool.Cust(A_ThisFunc "() failed to get the monitor that the mouse is within", 2.0)
            errorLog(e, A_ThisFunc "()")
			Exit()
		}
	}
}

/**
 * This function gets and returns the title for the current active window, autopopulating the `title` variable
 * @param {VarRef} title populates with the active window
 */
getTitle(&title)
{
    try {
        check := WinGetProcessName("A")
        if check = "AutoHotkey64.exe"
            ignore := WinGetTitle(check)
        else
            ignore := ""
		title := WinGetTitle("A",, ignore)
        if !IsSet(title) || title = "" || title = "Program Manager"
            throw Error e
        return title
	} catch as e {
		tool.Cust(A_ThisFunc "() couldn't determine the active window or you're attempting to interact with an ahk GUI")
        errorLog(e, A_ThisFunc "()")
        block.Off()
		Exit()
	}
}

/**
 * This function is designed to check what state the active window is in. If the window is maximised it will return 1, else it will return 0. It will also populate the `title` variable with the current active window
 * @param {var} title is the active window, this function will populate the `title` variable with the active window
 * @param {var} full is representing if the active window is fullscreen or not. If it is, it will return 1, else it will return 0
 * @param {String} window is if you wish to provide the function with the window instead of relying it to try and find it based off the active window, this paramater can be omitted
 */
isFullscreen(&title, &full, window := false)
{
    if window != false
        {
            title := window
            goto skip
        }
    getTitle(&title)
    skip:
    if title = "Program Manager" ;this is the desktop. You don't want the desktop trying to get fullscreened unless you want to replicate the classic windows xp lagscreen
        title := ""
	try {
		if WinGetMinMax(title,, "Editing Checklist -") = 1 ;a return value of 1 means it is maximised
			full := 1
		else
			full := 0
	} catch as e {
		tool.Cust(A_ThisFunc "() couldn't determine the active window")
		errorLog(e, A_ThisFunc "()")
        block.Off()
		Exit
	}
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
 * This function will convert a windows title bar to a dark/light theme if possible.
 * @param {String} hwnd is the hwnd value of the window you wish to alter
 * @param {boolean} dark is a toggle that allows you to call the inverse of this function and return the title bar to light mode. This parameter can be omitted otherwise pass false
 *
 * https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661
 */
titleBarDarkMode(hwnd, dark := true)
{
    if VerCompare(A_OSVersion, "10.0.17763") >= 0 {
        attr := 19
        if VerCompare(A_OSVersion, "10.0.18985") >= 0 {
            attr := 20
        }
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", dark, "int", 4)
    }
}

/**
 * This function will convert GUI buttons to a dark/light theme.
 * @param {String} ctrl_hwnd is the hwnd value of the control you wish to alter
 * @param {String} DarkorLight is a toggle that allows you to call the inverse of this function and return the button to light mode. This parameter can be omitted otherwise pass "Light"
 *
 * https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661
 */
buttonDarkMode(ctrl_hwnd, DarkorLight := "Dark") => DllCall("uxtheme\SetWindowTheme", "ptr", ctrl_hwnd, "str", DarkorLight "Mode_Explorer", "ptr", 0)

/**
 * This function will convert GUI menus to dark mode/light mode
 *
 * https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661
 * @param {any} DarkorLight is whether you want dark or light mode. Pass 1 for dark or 0 for light
 */
menuDarkMode(DarkorLight := 1)
{
    if !IsSet(uxtheme)
        {
            static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
            static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
            static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
        }
    DllCall(SetPreferredAppMode, "int", DarkorLight) ; Dark
    DllCall(FlushMenuThemes)
}

/**
 * This function facilitates accelerated scrolling. If the window under the cursor isn't the active window when this function is called, it will activate it
 */
fastWheel()
{
	getHotkeys(&first, &second)
	MouseGetPos(,, &UnderCursor)
	orig := WinGetTitle(WinActive("A"))
	titleUnder := WinGetTitle("ahk_id " UnderCursor)
    classUnder := WinGetClass("ahk_id " UnderCursor)
	if orig != titleUnder && classUnder != "tooltips_class32"
		WinActivate(titleUnder)
	SendInput("{" second " 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
}

/**
 * This function will grab the title of premiere if it exists and check to see if a save is necessary
 * @param {var} premCheck is the title of premiere, we want to pass this value back to the script
 * @param {var} titleCheck is checking to see if the premiere window is available to save, we want to pass this value back to the script
 * @param {var} saveCheck is checking for an * in the title to say a save is necessary, we want to pass this value back to the script
 */
getPremName(&premCheck, &titleCheck, &saveCheck)
{
    try {
        if WinExist(editors.winTitle["premiere"])
            {
                premCheck := WinGetTitle(editors.class["premiere"])
                titleCheck := InStr(premCheck, "Adobe Premiere Pro " ptf.PremYear " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
                saveCheck := SubStr(premCheck, -1, 1) ;this variable will contain "*" if a save is required
            }
        else
            {
                titleCheck := ""
                saveCheck := ""
            }
    } catch as e {
        block.Off()
        tool.Cust("Couldn't determine the titles of Adobe programs")
        errorLog(e, A_ThisFunc "()")
        return
    }
}

/**
  * This function will grab the title of after effects if it exists and check to see if a save is necessary
  * @param {var} aeCheck is the title of after effects, we want to pass this value back to the script
  * @param {var} aeSaveCheck is checking for an * in the title to say a save is necessary, we want to pass this value back to the script
  */
getAEName(&aeCheck, &aeSaveCheck)
{
    try {
        if WinExist(editors.winTitle["ae"])
            {
                aeCheck := WinGetTitle(editors.winTitle["ae"])
                aeSaveCheck := SubStr(aeCheck, -1, 1) ;this variable will contain "*" if a save is required
            }
        else
            aeSaveCheck := ""
    } catch as e {
        block.Off()
        tool.Cust("Couldn't determine the titles of Adobe programs")
        errorLog(e, A_ThisFunc "()")
        return
    }
}

/**
 * This function will grab the initial active window
 * @param {var} id is the processname of the active window, we want to pass this value back to the script
 */
getID(&id)
{
    try {
        id := WinGetProcessName("A")
        if WinActive("ahk_exe explorer.exe")
            id := "ahk_class CabinetWClass"
    } catch as e {
        tool.Cust("couldn't grab active window")
        errorLog(e, A_ThisFunc "()")
    }
}

/**
 * A function that returns the path of an open explorer window
 *
 * Original code found here: https://www.autohotkey.com/boards/viewtopic.php?p=422751#p387113
 * @param {number} hwnd You can pass in the hwnd of the window you wish to focus, else this parameter can be omitted and it will use the active window
 * @returns {String} the directory path of the explorer window
 */
GetExplorerPath(hwnd := 0)
{
    if(hwnd==0){
        explorerHwnd := WinActive("ahk_class CabinetWClass")
        if(explorerHwnd==0)
            explorerHwnd := WinExist("ahk_class CabinetWClass")
    }
    else
        explorerHwnd := WinExist("ahk_class CabinetWClass ahk_id " . hwnd)

    if (explorerHwnd){
        for window in ComObject("Shell.Application").Windows{
            try{
                if (window && window.hwnd && window.hwnd==explorerHwnd)
                    return window.Document.Folder.Self.Path
            }
        }
    }
    return false
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
                    path := GetExplorerPath(hwnd)
                    if !path
                        {
                            tool.Cust("Couldn't determine the path of the explorer window")
                            errorLog(, A_ThisFunc "()", "Couldn't determine the path of the explorer window", A_LineFile, A_LineNumber)
                            return
                        }
                    runTarget := path
                }
        }
    getpos := WinGetPos(&x, &y, &width, &height, window)
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