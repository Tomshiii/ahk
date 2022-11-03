#Include General.ahk

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
            errorLog(A_ThisFunc "()", "Failed to get information on previously active window", A_LineFile, A_LineNumber)
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
 * A function that will check to see if you're holding the left mouse button, then move any window around however you like
 * 
 * If the activation hotkey is `Rbutton`, this function will minimise the current window.
 * @param {String} key is what key(s) you want the function to press to move a window around (etc. #Left/#Right)
 */
moveWin(key)
{
    if WinActive("ahk_class CabinetWClass") ;this if statement is to check whether windows explorer is active to ensure proper right click functionality is kept
        {
            if A_ThisHotkey = "RButton"
                {
                    if !GetKeyState("LButton", "P") ;checks to see if the Left mouse button is held down, if it isn't, the below code will fire. This is here so you can still right click and drag
                        {
                            SendInput("{RButton Down}")
                            KeyWait("RButton")
                            SendInput("{RButton Up}")
                            return
                        }
                }
        }
    if !GetKeyState("LButton", "P") ;checks for the left mouse button as without this check the function will continue to work until you click somewhere else
        {
            SendInput("{" A_ThisHotkey "}")
            return
        }
    try {
        window := WinGetTitle("A") ;grabs the title of the active window
        SendInput("{LButton Up}") ;releases the left mouse button to stop it from getting stuck
        if A_ThisHotkey = minimiseHotkey ;this must be set to the hotkey you choose to use to minimise the window
            WinMinimize(window)
        if A_ThisHotkey = maximiseHotkey ;this must be set to the hotkey you choose to use to maximise the window
            {
                isFullscreen(&title, &full, window)
                if full = 0
                    WinMaximize(window)
                else
                    WinRestore(window)
            }
        SendInput(key)
    } catch as e {
        tool.Cust("Failed to get information on current active window")
        errorLog(A_ThisFunc "()", "Failed to get information on current active window", A_LineFile, A_LineNumber)
    }
}

/**
 * This function allows you to move tabs within certain monitors in windows. I currently have this function set up to cycle between monitors 2 & 4.
 * 
 * This function will check for 2s if you have released the RButton, if you have, it will drop the tab and finish, if you haven't it will be up to the user to press the LButton when you're done moving the tab. This function has hardcoded checks for `XButton1` & `XButton2` and is activated by having the activation hotkey as just one of those two, but then right clicking on a tab and pressing one of those two.
 * 
 * As of firefox version 106, for this function to work it either requires you to follow the instructions in the link below to disable the tab search arrow, or it'll require you to make adjustments to the pixel values in this script.
 * https://www.askvg.com/tip-remove-tabs-search-arrow-button-from-firefox-title-bar/
 */
moveTab()
{
    /*
        The way my monitors are layed out in windows;

                            -------------
                            |    2      |
                            |           |
        -----               -------------
        |   | ------------- -------------
        | 3 | |    1      | |    4      |
        |   | |           | |           |
        |   | ------------- -------------
        -----
    */
    if GetKeyState("LButton", "P") && !GetKeyState("RButton", "P")
        {
            if A_ThisHotkey = "XButton2"
                moveWin("#{Left}")
            else
                moveWin("#{Right}")
            return
        }
    if !GetKeyState("RButton", "P")
        {
            SendInput("{" A_ThisHotkey "}")
            return
        }
    coord.s()
    MouseGetPos(&initx, &inity) ;this is here so we can move the mouse back to the starting position even if you call the function multiple times without it completing
    initMon := getMouseMonitor()
    start:
    MouseGetPos(&x, &y)
    getTitle(&title) ;getting the window title
    WinGetPos(&winX, &winY, &width,, title) ; getting the coords for the firefox window
    monitor := getMouseMonitor() ;checking which monitor the mouse is within
    if !IsObject(initMon) || !IsObject(monitor)
        {
            block.Off() ;to stop the user potentially getting stuck
			tool.Cust(A_ThisFunc " failed to get the monitor that the mouse is within")
            errorLog(A_ThisFunc "()", "failed to get the monitor that the mouse is within", A_LineFile, A_LineNumber)
			return
		}
    if x > 4260 ;because of the pixelsearch block down below, you can't just reactivate this function to move between monitors. Thankfully for me the two monitors I wish to cycle between are stacked on top of each other so I can make it so if my x coord is greater than a certain point, it should be assumed I'm simply trying to cycle monitors
        goto move
    if ImageSearch(&contX, &contY, x - 300, y - 300, x + 300, y + 300, "*2 " ptf.firefox "contextMenu.png") || ImageSearch(&contX, &contY, x - 300, y - 300, x + 300, y + 300, "*2 " ptf.firefox "contextMenu2.png") ;right clicking a tab in firefox will automatically pull up the right click context menu. This ImageSearch is checking to see if it's there and then getting rid of it if it is
        {
            SendInput("{Escape}")
            sleep 50
            if ImageSearch(&urlX, &urlY, winX, winY, winX + (width / 2), (winY + 200), "*2 " ptf.firefox "url.png") ;this checks to make sure the url bar isn't higlighted as it's the same colour as an active tab in firefox
                {
                    SendInput("{F6}")
                    sleep 50
                }
            block.On()
            ;The below block of text will go through a process of trying to find the tab you wish to move.
            ;0x42414D is the colour of the active tab
            ;0x35343A is the colour of a non active tab when you hover over it
            ;I use firefox in dark mode
            if PixelSearch(&colx, &coly, contX - 30, contY - 30, contX + 5, contY + 30, 0x42414D) ;this is checking to see if the tab you're clicked on is selected
                MouseMove(colx, coly)
            else ;if the tab isn't selected we will enter this else block
                {
                    MouseGetPos(&startX, &startY)
                    loop {
                        MouseMove(-5, 0,, "R") ;next we attempt to move the mouse over the tab to hover it and change it's colour
                        MouseGetPos(&searchX, &searchY)
                        if PixelGetColor(searchX, searchY) = 0x35343A ;then we check for the hover colour
                            break
                        if A_Index > 4 ;then we simply run through some different possible locations for the tab
                            {
                                MouseMove(startX - 20, startY - 10)
                                if PixelGetColor(searchX, searchY) = 0x35343A
                                    break
                            }
                        if A_Index > 5
                            {
                                MouseMove(startX - 20, startY + 10)
                                if PixelGetColor(searchX, searchY) = 0x35343A
                                    break
                            }
                        if A_Index > 6
                            {
                                tool.Cust("Couldn't find the active tab colour", 1500)
                                errorLog(A_ThisFunc "()", "couldn't find the active tab colour", A_LineFile, A_LineNumber)
                                block.Off()
                                return
                            }
                    }
                }
        }
    else
        {
            tool.Cust("You moved too far away from the right click context menu", 1500)
            errorLog(A_ThisFunc "()", "moved too far away from the right click context menu", A_LineFile, A_LineNumber)
            block.Off()
            return
        }
    if A_Cursor = "SizeNS" ;this checks to make sure you're not about to accidentally attempt to resize the window
        MouseMove(0, 10, 2, "R")
    SendInput("{LButton Down}")
    move:
    if monitor.monitor != 2 && monitor.monitor != 4 ;I only want this function to cycle between monitors 2 & 4
        monitor.monitor := 2 ;so I'll set the monitor number to one of the two I wish it to cycle between
    if monitor.monitor = 4
        MouseMove(4288, -911, 2) ;if the mouse is within monitor 4, it will move it to monitor 2
    if monitor.monitor = 2
        MouseMove(4288, 164, 2) ;if the mouse is within monitor 2, it will move it to monitor 4
    block.Off()
    KeyWait(A_ThisHotkey)
    thisHotkey := A_ThisHotkey ;determining which XButton the user is currently using to activate the function
    if thisHotkey = "XButton1"
        otherHotkey := "XButton2" ;so that we can then assign the other XButton to a variable
    else
        otherHotkey := "XButton1"
    loop 40 { ;this loop will check for 2s if the user has released the RButton, if they have, it will drop the tab and finish the function
        if !GetKeyState("RButton", "P")
            {
                SendInput("{LButton}")
                break
            }
        if GetKeyState(A_ThisHotkey, "P") ;these two getkeystates are to allow the user to reactivate the function without waiting the 2s
            goto start
        if GetKeyState(otherHotkey, "P")
            goto start
        sleep 50
    }
    block.On()
    if monitor.monitor = 4 || initMon.monitor = 1
        MouseMove(initx, inity, 2) ;move back to the original mouse coords. I only want to move the mouse back if I'm moving a tab from the bottom monitor, to the top or from the main montior
    if !WinActive(title) ;this codeblock will check to see if the originally active window is still active. This is useful as sometimes when you drag a tab that wasn't active, firefox will bring the tab next to it into focus, which might not really be what you want
        {
            MouseGetPos(&finalX, &finalY)
            getTitle(&currentActive)
            WinGetPos(&x2, &y2,,, currentActive)
            MouseMove(x2 + 30, y2 + 30, 2)
            check := getMouseMonitor()
            if check.monitor = monitor.monitor && currentActive != title
                {
                    switchToFirefox() ;activate the other firefox window
                    checkformon1() { ;a small check to make sure a sneaky window on the wrong monitor isn't causing issues
                        getTitle(&currentActive)
                        WinGetPos(&x2, &y2,,, currentActive)
                        MouseMove(x2 + 30, y2 + 30, 2)
                        check2 := getMouseMonitor()
                        if check2.monitor != 4 && check2.monitor != 2
                            switchToFirefox()
                    }
                    checkformon1()
                    if !WinActive(title) ;and see if that is the tab, if not;
                        {
                            switchToFirefox() ;swap back again and loop. Note: this might not work properly if you have more than two firefox windows open
                            checkformon1()
                            ;MsgBox("monitor = " monitor "`ncheck = " check "`nactive win = " currentActive "`noriginal active = " title) ;debugging
                            loop 20 {
                                SendInput("{Ctrl Down}{Tab}{Ctrl Up}")
                                sleep 50
                                if WinActive(title)
                                    break
                        }
                    }
                }
            MouseMove(finalX, finalY, 2)
        }
    block.Off()
    SetTimer(isfull, -1500)
    isfull() {
        try {
            isFullscreen(&title, &full, title)
            if full = 0
                WinMaximize(title)
        }
        SetTimer(, 0)
    }
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
		}
		catch {
            block.Off() ;to stop the user potentially getting stuck
			tool.Cust(A_ThisFunc " failed to get the monitor that the mouse is within")
            errorLog(A_ThisFunc "()", "failed to get the monitor that the mouse is within", A_LineFile, A_LineNumber)
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
			{
				tool.Cust("Couldn't determine the active window")
				errorLog(A_ThisHotkey "::", "Couldn't determine the active window", A_LineFile, A_LineNumber)
				Exit()
			}
        return title
	} catch as e {
		tool.Cust(A_ThisFunc "() couldn't determine the active window or you're attempting to interact with an ahk GUI")
		errorLog(A_ThisFunc, "Couldn't determine the active window or you're attempting to interact with an ahk GUI", A_LineFile, A_LineNumber)
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
		errorLog(A_ThisFunc "()", "Couldn't determine the active window", A_LineFile, A_LineNumber)
        block.Off()
		Exit
	}
    return
}


/**
 * A quick and dirty way to limit the axis your mouse can move
 
 * This function has specific code for XButton1/2 and must be activated with 2 hotkeys
 */
moveXorY()
{
    getHotkeys(&fr, &sc)
	MouseGetPos(&x, &y)
	start:
    oneAxis(sc)
    {
        while GetKeyState(sc, "P")
            {
                SetTimer(tools, 15)
                tools() {
                    MouseGetPos(&xx, &yy)
                    static toolx := xx
                    static tooly := yy
                    if A_TimeIdleMouse < 500
                        {
                            if sc = "XButton2"
                                ToolTip("Your mouse will now only move along the x axis")
                            else if sc = "XButton1"
                                ToolTip("Your mouse will now only move along the y axis")
                        }
                    if A_TimeIdleMouse > 500
                        {
                            MouseGetPos(&newX, &newY)
                            if sc = "XButton2"
                                {
                                    if newY = y && newX != toolx
                                        {
                                            ToolTip("Your mouse will now only move along the x axis`nYou are currently level on the y axis")
                                            toolx := newX
                                        }
                                }
                            else if sc = "XButton1"
                                {
                                    if newX = x && newY != tooly
                                        {
                                            ToolTip("Your mouse will now only move along the y axis`nYou are currently level on the x axis")
                                            tooly := newY
                                        }
                                }
                        }
                }
                MouseGetPos(&newX, &newY)
                if sc = "XButton2"
                    MouseMove(newX, y)
                else if sc = "XButton1"
                    MouseMove(x, newY)
            }
            SetTimer(tools, 0)
            ToolTip("")
    }
    oneAxis(sc)
    if sc != "XButton1" || sc != "XButton2"
        return
	if GetKeyState(fr, "P")
		goto start
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
 * This function will convert a windows title bar to a dark theme if possible.
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
 * This function will convert GUI buttons to a dark theme.
 * @param {String} ctrl_hwnd is the hwnd value of the control you wish to alter
 * @param {String} DarkorLight is a toggle that allows you to call the inverse of this function and return the button to light mode. This parameter can be omitted otherwise pass "Light" 
 * 
 * https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661
 */
buttonDarkMode(ctrl_hwnd, DarkorLight := "Dark") => DllCall("uxtheme\SetWindowTheme", "ptr", ctrl_hwnd, "str", DarkorLight "Mode_Explorer", "ptr", 0)

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
        if WinExist("ahk_exe Adobe Premiere Pro.exe")
            {
                premCheck := WinGetTitle("ahk_class Premiere Pro")
                titleCheck := InStr(premCheck, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
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
        errorLog(A_ThisFunc "()", "Couldn't determine the titles of Adobe programs", A_LineFile, A_LineNumber)
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
        if WinExist("ahk_exe AfterFX.exe")
            {
                aeCheck := WinGetTitle("ahk_exe AfterFX.exe")
                aeSaveCheck := SubStr(aeCheck, -1, 1) ;this variable will contain "*" if a save is required
            }
        else
            aeSaveCheck := ""
    } catch as e {
        block.Off()
        tool.Cust("Couldn't determine the titles of Adobe programs")
        errorLog(A_ThisFunc "()", "Couldn't determine the titles of Adobe programs", A_LineFile, A_LineNumber)
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
        errorLog(A_ThisFunc "()", "Couldn't define the active window", A_LineFile, A_LineNumber)
    }
}

; ===========================================================================================================================================
;
;		discord
;
; ===========================================================================================================================================
/**
 * This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \Support Files\ImageSearch\disc[button].png
 * @param {String} button in the png name of a screenshot of the button you want the function to press
 */
disc(button)
;NOTE THESE WILL ONLY WORK IF YOU USE THE SAME DISPLAY SETTINGS AS ME (otherwise you'll need your own screenshots.. tbh you'll probably need your own anyway). YOU WILL LIKELY NEED YOUR OWN SCREENSHOTS AS I HAVE DISCORD ON A VERTICAL SCREEN SO ALL MY SCALING IS WEIRD
;dark theme
;chat font scaling: 20px
;space between message groups: 16px
;zoom level: 100
;saturation; 70%
;ensure this function only fires if discord is active ( #HotIf WinActive("ahk_exe Discord.exe") ) - VERY IMPORTANT
{
    yheight := 400
    getHotkeys(&first, &second)
    KeyWait(first) ;use A_PriorKey when you're using 2 buttons to activate a macro
    coord.w()
    MouseGetPos(&x, &y)
    WinGetPos(&nx, &ny, &width, &height, "A") ;gets the width and height to help this function work no matter how you have discord
    ;MsgBox("x " nx "`ny " ny "`nwidth " width "`nheight " height) ;testing
    block.On()
    click("right") ;this opens the right click context menu on the message you're hovering over
    sleep 50 ;sleep required so the right click context menu has time to open
    loop {
        if ImageSearch(&xpos, &ypos, x - "200", y -"400",  x + "200", y + yheight, "*2 " ptf.Discord button) ;searches for the button you've requested
            {
                MouseMove(xpos, ypos)
                break
            }
        sleep 50
        yheight += 100
        if A_Index > 4
            ToolTip(A_ThisFunc "() has attempted to find the desired button " A_Index " times")
        if A_Index > 10 ;after waiting over 0.5s the function will excecute the below
            {
                ToolTip("")
                MouseMove(x, y) ;moves the mouse back to the original coords
                block.Off()
                tool.Cust("the requested button after " A_Index " attempts", 2000, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(A_ThisFunc "()", "Was unable to find the requested button", A_LineFile, A_LineNumber)
                return
            }
    }
    Click
    sleep 100
    if button != "DiscReply.png" || !ImageSearch(&x2, &y2, nx, ny/"3", width, height, "*2 " ptf.Discord "dm1.png")
        goto end  ;YOU MUST CALL YOUR REPLY IMAGESEARCH FILE "DiscReply.png" FOR THIS PART OF THE CODE TO WORK - ELSE CHANGE THIS VALUE TOO
    loop {
            if ImageSearch(&xdir, &ydir, 0, height/"2", width, height, "*2 " ptf.Discord "DiscDirReply.png") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. If you prefer to leave that on, remove from the above sleep 100, to the `end:` below. The coords here are to search the entire window (but only half the windows height) - (that's what the WinGetPos is for) for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish but it isn't really neccessary.
                {
                    ;ToolTip("")
                    MouseMove(xdir, ydir) ;moves to the @ location
                    Click
                    break
                }
            ;ToolTip(A_Index)
            if A_Index > 10
                {
                    tool.Cust("the @ ping button",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                    errorLog(A_ThisFunc "()", "Was unable to find the @ reply ping button", A_LineFile, A_LineNumber)
                    break
                }
        }
    end:
    MouseMove(x, y) ;moves the mouse back to the original coords
    block.Off()
}

/**
 * This function will toggle the location of discord's window position
 */
discLocation()
{
    position0 := [4480, -123, 1081, 1537] ;we use position0 as a reference later to compare against another value.
    position1 := [-1080, 75, 1080, 1537] ;we use position1 as a reference later to compare against another value.
    disc0() { ;define your first (defult) position here
        WinMove(position0[1], position0[2], position0[3], position0[4], "ahk_exe Discord.exe")
    }
    disc1() { ;define your second position here
        WinMove(position1[1], position1[2], position1[3], position1[4], "ahk_exe Discord.exe")
    }
    try { ;this try is here as if you close a window, then immediately try to fire this function there is no "original" window
        original := WinGetID("A")
    } catch as e {
        tool.Cust("you tried to assign a closed`n window as the last active", 4000)
        errorLog(A_ThisFunc "()", "Function tried to assign a closed window as the last active window and therefor couldn't switch back to it", A_LineFile, A_LineNumber)
        SendInput("{Click}")
        return
    }
    static toggle := 0 ;this is what allows us to toggle discords position
    if !WinExist("ahk_exe Discord.exe")
        {
            run(ptf.LocalAppData "\Discord\Update.exe --processStart Discord.exe") ;this will run discord
            WinWait("ahk_exe Discord.exe")
            sleep 1000
            WinActivate("ahk_exe Discord.exe")
            result := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord
            if result = position0 ;here we are comparing discords current position to one of the values we defined above
                {
                    toggle := 0
                    return
                }
            if result = position1 ;here we are comparing discords current position to one of the values we defined above
                {
                    toggle := 1
                    return
                }
            if !(result = position0 or result = position1) ;here we're saying if it isn't in EITHER position we defined above, move it into a position
                {
                    toggle := 0
                    disc0()
                    return
                }
            return
        }
    WinActivate("ahk_exe Discord.exe")
    startLocation := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord
    if toggle < 1
        {
            toggle += 1
            disc0()
            newPos := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord AGAIN
            if newPos = startLocation ;so we can compare and ensure it has moved
                disc1()
            return
        }
    if toggle = 1
        {
            toggle -= 1
            disc1()
            newPos := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord AGAIN
            if newPos = startLocation ;so we can compare and ensure it has moved
                disc0()
            return
        }
    if toggle > 1 or toggle < 0 ;this is here just incase the value ever ends up bigger/smaller than it's supposed to
        {
            toggle := 0
            tool.Cust("stop spamming the function please`nthe functions value was too large/small")
            errorLog(A_ThisFunc "()", "Function hit an unexpected toggle number", A_LineFile, A_LineNumber)
            return
        }
    try { ;this is here once again to ensure ahk doesn't crash if the original window doesn't actual exist anymore
        WinActivate(original)
    } catch as e {
        tool.Cust("couldn't find original window", 2000)
        errorLog(A_ThisFunc "()", "Function couldn't activate the original window", A_LineFile, A_LineNumber)
        return
    }
}

/**
 * This function will search for and automatically click on either unread servers or unread channels depending on which image you feed into the function
 * @param {String} which is simply which image you want to feed into the function. I have it left blank for servers and `"2"` for channels
 */
discUnread(which := "")
{
    x2 := 0
    y2 := 0
    message := "servers"
    if which = 2
        {
            x2 := 70
            y2 := 30
            message := "channels"
        }
	MouseGetPos(&xPos, &yPos)
	WinGetPos(,,, &height)
	if !ImageSearch(&x, &y, 0 + x2, 0, 50 + y2, height, "*2 " ptf.Discord "\unread" which ".png")
		{
            tool.Cust("any unread " message,, 1)
            return
        }
    MouseMove(x + 20, y, 2)
    SendInput("{Click}")
    MouseMove(xPos, yPos, 2)
}

; ===========================================================================================================================================
;
;		VSCode
;
; ===========================================================================================================================================
/**
  * A function to quickly naviate between my scripts. For this script to work [explorer.autoReveal] must be set to false in VSCode's settings (File->Preferences->Settings, search for "explorer" and set "explorer.autoReveal")
  * @param {Integer} script is the amount of down inputs the script needs to input to get to the required script. Will default to 0
 */
vscode(script := 0)
{
    getHotkeys(&first, &second)
    KeyWait(first)
    block.On()
    sleep 50
    SendInput(focusExplorerWin) ;highlight the explorer window
    sleep 50
    SendInput(focusWork)
    SendInput(collapseFold collapseFold) ;close all repos
    sleep 50
    SendInput("{Up 2}{Enter}") ;this highlights the top repo in the workspace
    if A_ThisHotkey = functionHotkey ;this opens my \functions folder
        {
            SendInput("{Down 4}{Enter}")
            sleep 50
            SendInput("{Down 2}{Enter}")
            sleep 50
            block.Off()
            tool.Wait()
            tool.Cust("The function folder has been expanded", 2.0)
            return
        }
    SendInput("{Down " script "}")
    sleep 25
    SendInput("{Enter}")
    SendInput(focusCode)
    block.Off()
    tool.Wait()
    tool.Cust("The proper file should now be focused", 2.0)
}