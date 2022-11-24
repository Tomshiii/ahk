/************************************************************************
 * @description A class to contain a library of functions to interact with and move window elements.
 * @author tomshi
 * @date 2022/11/24
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Classes\block>
#Include <\Classes\coord>
#Include <\Classes\ptf>
#Include <\Classes\tool>
#Include <\Classes\winGet>
#Include <\Functions\errorLog>
; }

class Move {
    /**
     * A function that will check to see if you're holding the left mouse button, then move any window around however you like
     *
     * If the activation hotkey is `Rbutton`, this function will minimise the current window.
     * @param {String} key is what key(s) you want the function to press to move a window around (etc. #Left/#Right)
     */
    static Window(key)
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
                    winget.isFullscreen(&title, &full, window)
                    if full = 0
                        WinMaximize(window)
                    else
                        WinRestore(window)
                }
            SendInput(key)
        } catch as e {
            tool.Cust("Failed to get information on current active window")
            errorLog(e, A_ThisFunc "()")
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
    static Tab()
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
                    this.Window("#{Left}")
                else
                    this.Window("#{Right}")
                return
            }
        if !GetKeyState("RButton", "P")
            {
                SendInput("{" A_ThisHotkey "}")
                return
            }
        coord.s()
        MouseGetPos(&initx, &inity) ;this is here so we can move the mouse back to the starting position even if you call the function multiple times without it completing
        initMon := winget.MouseMonitor()
        start:
        MouseGetPos(&x, &y)
        winget.Title(&title) ;getting the window title
        WinGetPos(&winX, &winY, &width,, title) ; getting the coords for the firefox window
        monitor := winget.MouseMonitor() ;checking which monitor the mouse is within
        if !IsObject(initMon) || !IsObject(monitor)
            {
                block.Off() ;to stop the user potentially getting stuck
                tool.Cust(A_ThisFunc " failed to get the monitor that the mouse is within")
                errorLog(, A_ThisFunc "()", "failed to get the monitor that the mouse is within", A_LineFile, A_LineNumber)
                return
            }
        if x > 4260 ;because of the pixelsearch block down below, you can't just reactivate this function to move between monitors. Thankfully for me the two monitors I wish to cycle between are stacked on top of each other so I can make it so if my x coord is greater than a certain point, it should be assumed I'm simply trying to cycle monitors
            goto move
        if !ImageSearch(&contX, &contY, x - 300, y - 300, x + 300, y + 300, "*2 " ptf.firefox "contextMenu.png") && !ImageSearch(&contX, &contY, x - 300, y - 300, x + 300, y + 300, "*2 " ptf.firefox "contextMenu2.png") ;right clicking a tab in firefox will automatically pull up the right click context menu. This ImageSearch is checking to see if it's there and then getting rid of it if it is
            {
                tool.Cust("You moved too far away from the right click context menu", 1500)
                errorLog(, A_ThisFunc "()", "moved too far away from the right click context menu", A_LineFile, A_LineNumber)
                block.Off()
                return
            }
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
                            errorLog(, A_ThisFunc "()", "couldn't find the active tab colour", A_LineFile, A_LineNumber)
                            block.Off()
                            return
                        }
                }
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
                winget.Title(&currentActive)
                WinGetPos(&x2, &y2,,, currentActive)
                MouseMove(x2 + 30, y2 + 30, 2)
                check := winget.MouseMonitor()
                if check.monitor = monitor.monitor && currentActive != title
                    {
                        switchTo.Firefox() ;activate the other firefox window
                        checkformon1() { ;a small check to make sure a sneaky window on the wrong monitor isn't causing issues
                            winget.Title(&currentActive)
                            WinGetPos(&x2, &y2,,, currentActive)
                            MouseMove(x2 + 30, y2 + 30, 2)
                            check2 := winget.MouseMonitor()
                            if check2.monitor != 4 && check2.monitor != 2
                                switchTo.Firefox()
                        }
                        checkformon1()
                        if !WinActive(title) ;and see if that is the tab, if not;
                            {
                                switchTo.Firefox() ;swap back again and loop. Note: this might not work properly if you have more than two firefox windows open
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
                winget.isFullscreen(&title, &full, title)
                if full = 0
                    WinMaximize(title)
            }
            SetTimer(, 0)
        }
    }

    /**
     * A quick and dirty way to limit the axis your mouse can move
     *
     * This function has specific code for XButton1/2 and must be activated with 2 hotkeys
    */
    static XorY()
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
}