;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.11
#Include General.ahk

; ===========================================================================================================================================
;
;		Windows Scripts \\ Last updated: v2.10.5
;
; ===========================================================================================================================================
/* youMouse()
 a function to skip in youtube
 @param tenS is the hotkey for 10s skip in your direction of choice
 @param fiveS is the hotkey for 5s skip in your direction of choice
 */
youMouse(tenS, fiveS)
{
    if A_PriorKey = "Mbutton" ;ensures the hotkey doesn't fire while you're trying to open a link in a new tab
        return
    if WinExist("YouTube")
    {
        try {
            lastactive := WinGetID("A") ;fills the variable [lastavtive] with the ID of the current window
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
            toolCust("Failed to get information on the previously active window", "1000")
            errorLog(A_ThisFunc "()", "Failed to get information on previously active window", A_LineFile, A_LineNumber)
        }

    }
}

/* monitorWarp()
 warp anywhere on your desktop
 */
monitorWarp(x, y)
{
    coords()
    MouseMove(x, y, 2) ;I need the 2 here as I have multiple monitors and things can be funky moving that far that fast. random ahk problems. Change this if you only have 1/2 monitors and see if it works fine for you
}

/* moveWin()
 A function that will check to see if you're holding the left mouse button, then move any window around however you like
 @param key is what key(s) you want the function to press to move a window around (etc. #Left/#Right)
 */
moveWin(key)
{
    if WinActive("ahk_class CabinetWClass") ;this if statement is to check whether windows explorer is active to ensure proper right click functionality is kept
        {
            if A_ThisHotkey = "RButton"
                {
                    if not GetKeyState("LButton", "P") ;checks to see if the Left mouse button is held down, if it isn't, the below code will fire. This is here so you can still right click and drag
                        {
                            SendInput("{RButton Down}")
                            KeyWait("RButton")
                            SendInput("{RButton Up}")
                            return
                        }
                }
        }
    if not GetKeyState("LButton", "P") ;checks for the left mouse button as without this check the function will continue to work until you click somewhere else
        {
            SendInput("{" A_ThisHotkey "}")
            return
        }
    else
        {
            try {
                window := WinGetTitle("A") ;grabs the title of the active window
                SendInput("{LButton Up}") ;releases the left mouse button to stop it from getting stuck
                if A_ThisHotkey = minimiseHotkey ;this must be set to the hotkey you choose to use to minimise the window
                    WinMinimize(window)
                if A_ThisHotkey = maximiseHotkey ;this must be set to the hotkey you choose to use to maximise the window
                    WinMaximize(window)
                SendInput(key)
            } catch as e {
                toolCust("Failed to get information on current active window", "1000")
                errorLog(A_ThisFunc "()", "Failed to get information on current active window", A_LineFile, A_LineNumber)
            }
        }
}
/*
 This function allows you to move tabs within certain monitors in windows. I currently have this function set up to cycle between monitors 2 & 4. This function requires you to press LButton when you have arrived at the window you wish to drop the tab
 */
moveTab()
{
    if not GetKeyState("RButton", "P")
        {
            SendInput("{" A_ThisHotkey "}")
            return
        }
    blockOff()
    coords()
    MouseGetPos(&x, &y)
    getTitle(&title)
    MouseMove(-10, 0,, "R")
    if ImageSearch(&contX, &contY, x, y, x + 50, y + 50, "*2 " Firefox "contextMenu.png") ;right clicking a tab in firefox will automatically pull up the right click context menu. This ImageSearch is checking to see if it's there and then getting rid of it if it is
        {
            SendInput("{Escape}")
            sleep 50
            MouseMove(x , y)
        }
    SendInput("{LButton Down}")
    monitor := getMouseMonitor()
    if monitor != 2 && monitor != 4
        {
            SendInput("{LButton Up}{RButton}")
            blockOff()
            return
        }
    ;the below, blocked out code was for when I wanted tabs to cycle between monitors 1, 2 & 4 and passed a variable `forwardOrback` into the function to define a direction.
    ;I have since stopped including monitor 1 as I rarely ever want a browser window moved onto my main display
    /* if forwardOrback = "forward"
        {
            if monitor = 2
                monitor += 1
            if monitor = 4
                monitor -= 4
            monitor += 1
        }
    if forwardOrback = "back"
        {
            if monitor = 4
                monitor -= 1
            if monitor = 1
                monitor += 4
            monitor -= 1
        } */
    ;as a result, I've simply changed the code to this instead. From here to `end:`
    if monitor = 2
        {
            monitor := 4
            goto end
        }
    if monitor = 4
        monitor := 2
    end:
    /* if monitor = 1
        MouseMove(2378, 25, 3) */
    if monitor = 2
        MouseMove(4256, -911, 3)
    if monitor = 4
        MouseMove(4281, 164, 3)
    blockOff()
    SetTimer(isfull, -1500)
    isfull() {
        try {
            isFullscreen(&title, &full)
            if full = 0
                WinMaximize(title)
        }
        SetTimer(, 0)
    }
}

/* getMouseMonitor()
 This function will grab the monitor that the mouse is currently within and return it. ie if your mouse is within monitor 1 having code `monitor := getMouseMonitor()` would make monitor = 1
 */
getMouseMonitor()
{
	coords()
	MouseGetPos(&x, &y)
	loop {
		try {
			MonitorGet(A_Index, &left, &Top, &Right, &Bottom)
			if x > left && x < Right
				{
					if y < Bottom && y > Top
                        ;MsgBox(x " " y "`n" left " " Right " " Bottom " " Top "`nwithin monitor " A_Index)
                        return A_Index
			    }
		}
		catch {
			toolCust(A_ThisFunc " failed to get the monitor that the mouse is within", "1000")
            errorLog(A_ThisFunc "()", "failed to get the monitor that the mouse is within", A_LineFile, A_LineNumber)
			break
		}
	}
}

/*
 This function gets and returns the title for the current active window, autopopulating the `title` variable
 */
getTitle(&title)
{
    try {
		title := WinGetTitle("A")
        return title
	} catch as e {
		toolCust(A_ThisFunc "() couldn't determine the active window", "1000")
		errorLog(A_ThisFunc, "Couldn't determine the active window", A_LineFile, A_LineNumber)
		return
	}
}

/*
 This function is designed to check what state the active window is in. If the window is maximised it will return 1, else it will return 0. It will also populate the `title` variable with the current active window
 @param title is the active window, this function will populate the `title` variable with the active window
 @param full is representing if the active window is fullscreen or not. If it is, it will return 1, else it will return 0
 */
isFullscreen(&title, &full)
{
    getTitle(&title)
    if title = "Program Manager" ;this is the desktop. You don't want the desktop trying to get fullscreened unless you want to replicate the classic windows xp lagscreen
        return
	try {
		if WinGetMinMax(title) = 1 ;a return value of 1 means it is maximised
			full := 1
		else
			full := 0
	} catch as e {
		toolCust(A_ThisFunc "() couldn't determine the active window", "1000")
		errorLog(A_ThisFunc, "Couldn't determine the active window", A_LineFile, A_LineNumber)
		Exit
	}
    return
}

; ===========================================================================================================================================
;
;		discord \\ Last updated: v2.10
;
; ===========================================================================================================================================
/* disc()
 This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \Support Files\ImageSearch\disc[button].png
 @param button in the png name of a screenshot of the button you want the function to press
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
    KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
    coordw()
    MouseGetPos(&x, &y)
    WinGetPos(&nx, &ny, &width, &height, "A") ;gets the width and height to help this function work no matter how you have discord
    ;MsgBox("x " nx "`ny " ny "`nwidth " width "`nheight " height) ;testing
    blockOn()
    click("right") ;this opens the right click context menu on the message you're hovering over
    sleep 50 ;sleep required so the right click context menu has time to open
    loop {
        if ImageSearch(&xpos, &ypos, x - "200", y -"400",  x + "200", y + yheight, "*2 " Discord button) ;searches for the button you've requested
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
                blockOff()
                toolFind("the requested button after " A_Index " attempts", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(A_ThisFunc "()", "Was unable to find the requested button", A_LineFile, A_LineNumber)
                return
            }
    }
    Click
    sleep 100
    if button = "DiscReply.png" ;YOU MUST CALL YOUR REPLY IMAGESEARCH FILE "DiscReply.png" FOR THIS PART OF THE CODE TO WORK - ELSE CHANGE THIS VALUE TOO
        {
            if ImageSearch(&x2, &y2, nx, ny/"3", width, height, "*2 " Discord "dm1.png")
                {
                    loop {
                            if ImageSearch(&xdir, &ydir, 0, height/"2", width, height, "*2 " Discord "DiscDirReply.png") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. if you prefer to leave that on, remove from the above sleep 100, to the last else below. The coords here are to search the entire window (but only half the windows height) - (that's what the WinGetPos is for) for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish but it isn't really neccessary.
                                {
                                    ;ToolTip("")
                                    MouseMove(xdir, ydir) ;moves to the @ location
                                    Click
                                    MouseMove(x, y) ;moves the mouse back to the original coords
                                    blockOff()
                                    return
                                }
                            ;ToolTip(A_Index)
                            if A_Index > 10
                                {
                                    toolFind("the @ ping button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
                                    errorLog(A_ThisFunc "()", "Was unable to find the @ reply ping button", A_LineFile, A_LineNumber)
                                    break
                                }
                        }
                    MouseMove(x, y) ;moves the mouse back to the original coords
                    blockOff()
                }
            else
                {
                    MouseMove(x, y) ;moves the mouse back to the original coords
                    blockOff()
                    return
                }
        }
    else
        {
            MouseMove(x, y) ;moves the mouse back to the original coords
            blockOff()
        }
}
 
/*
 This function will toggle the location of discord's window position
 */
discLocation()
{
    position0 := 4480, -123, 1081, 1537 ;we use position0 as a reference later to compare against another value. This is the same coordinates as disc0() down below, make sure you change THEM BOTH
    position1 := -1080, 75, 1080, 1537 ;we use position1 as a reference later to compare against another value. This is the same coordinates as disc1() down below, make sure you change THEM BOTH
    disc0() { ;define your first (defult) position here
        WinMove(4480, -123, 1081, 1537, "ahk_exe Discord.exe")
    }
    disc1() { ;define your second position here
        WinMove(-1080, 75, 1080, 1537, "ahk_exe Discord.exe")
    }
    try { ;this try is here as if you close a window, then immediately try to fire this function there is no "original" window
        original := WinGetID("A")
    } catch as e {
        toolCust("you tried to assign a closed`n window as the last active", "4000")
        errorLog(A_ThisFunc "()", "Function tried to assign a closed window as the last active window and therefor couldn't switch back to it", A_LineFile, A_LineNumber)
        SendInput("{Click}")
        return
    }
    static toggle := 0 ;this is what allows us to toggle discords position
    if not WinExist("ahk_exe Discord.exe")
        {
            run("C:\Users\" A_UserName "\AppData\Local\Discord\Update.exe --processStart Discord.exe") ;this will run discord
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
            toolCust("stop spamming the function please`nthe functions value was too large/small", "1000")
            errorLog(A_ThisFunc "()", "Function hit an unexpected toggle number", A_LineFile, A_LineNumber)
            return
        }
    try { ;this is here once again to ensure ahk doesn't crash if the original window doesn't actual exist anymore
        WinActivate(original)
    } catch as e {
        toolCust("couldn't find original window", "2000")
        errorLog(A_ThisFunc "()", "Function couldn't activate the original window", A_LineFile, A_LineNumber)
        return
    }
}

; ===========================================================================================================================================
;
;		VSCode \\ Last updated: v2.10
;
; ===========================================================================================================================================
/* vscode()
  A function to quickly naviate between my scripts. For this script to work [explorer.autoReveal] must be set to false in VSCode's settings (File->Preferences->Settings, search for "explorer" and set "explorer.autoReveal")
  It will also either work or not depending on what theme you have installed, I am currently using `one dark pro`
  It will also depend on how "zoomed in" you have vscode
  It also functions differently if you only have 1 repo cloned instead of multiple
  @param script is the amount of pixels down the mouse must move from the collapse button to open the script I want.
 */
vscode(script)
{
    KeyWait(A_PriorKey)
    coordw()
    blockOn()
    MouseGetPos(&x, &y)
    if ImageSearch(&xex, &yex, 0, 0, 460, 1390, "*2 " VSCodeImage "explorer.png") || ImageSearch(&xex, &yex, 0, 0, 460, 1390, "*2 " VSCodeImage "explorer2.png") ;this imagesearch is checking to ensure you're in the explorer tab
        {
            MouseMove(xex, yex)
            SendInput("{Click}")
            MouseMove(x, y)
            sleep 50
        }
    SendInput(focusWork) ;vscode hides the buttons now all of a sudden.. thanks vscode
    sleep 50
    if ImageSearch(&xex, &yex, 0, 0, 460, 1390, "*2 " VSCodeImage "collapse.png") ;this imagesearch finds the collapse folders button, presses it twice, then moves across and presses repo folder
        {
            MouseMove(xex, yex)
            SendInput("{Click 2}")
            MouseMove(-271, 40,, "R")
            SendInput("{Click}")
        }
    else
        {
            toolFind("the collapse folders button", "1000")
            errorLog(A_ThisFunc "()", "Couldn't find the `collapse folders` button", A_LineFile, A_LineNumber)
            blockOff()
            return
        }
    if A_ThisHotkey = functionHotkey ;this opens my \functions folder as well as opening my main functions script
        {
            MouseGetPos(&origx, &origy)
            MouseMove(0, 105,, "R")
            SendInput("{Click}")
            MouseMove(origx, origy + 180)
        }
    MouseMove(0, script,, "R")
    SendInput("{Click}")
    MouseMove(x, y)
    SendInput(focusCode)
    blockOff()
}