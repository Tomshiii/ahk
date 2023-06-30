/************************************************************************
 * @description A class to contain a library of functions to interact with and move window elements.
 * @author tomshi
 * @date 2023/06/30
 * @version 1.2.4.1
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\winGet>
#Include <Classes\errorLog>
; }

class Move {
    /**
     * A function that will check to see if you're holding the left mouse button, then move any window around however you like
     *
     * If the activation hotkey is `Rbutton`, this function will minimise the current window.
     * @param {String} key is what key(s) you want the function to press to move a window around (etc. #Left/#Right)
     */
    static Window(key?)
    {
        if !IsSet(key) && (A_ThisHotkey != KSA.minimiseHotkey && A_ThisHotkey != KSA.maximiseHotkey) {
            ;// throw
            errorLog(ValueError("Incorrect hotkey has been used for function.`nDouble check KSA values.", -1),,, 1)
        }
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
        ;// checks for the left mouse button as without this check the function will continue to work until you click somewhere else
        ;//! this block HAS to be below the explorer check, otherwise right click dragging won't work
        if !GetKeyState("LButton", "P")
            {
                SendInput("{" A_ThisHotkey "}")
                return
            }
        window := winGet.Title()
        SendInput("{LButton Up}") ;releases the left mouse button to stop it from getting stuck
        switch A_ThisHotkey,  "Off" {
            case KSA.minimiseHotkey: WinMinimize(window)
            case KSA.maximiseHotkey:
                if !winget.isFullscreen(&title, window)
                    WinMaximize(window)
                else
                    WinRestore(window)
            default:
                SendInput(key)
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
                errorLog(UnsetError("Failed to get the monitor that the mouse is within", -1, monitor),, 1)
                return
            }
        if x > 4260 ;because of the pixelsearch block down below, you can't just reactivate this function to move between monitors. Thankfully for me the two monitors I wish to cycle between are stacked on top of each other so I can make it so if my x coord is greater than a certain point, it should be assumed I'm simply trying to cycle monitors
            goto move
        if !ImageSearch(&contX, &contY, x - 300, y - 300, x + 300, y + 300, "*2 " ptf.firefox "contextMenu.png") && !ImageSearch(&contX, &contY, x - 300, y - 300, x + 300, y + 300, "*2 " ptf.firefox "contextMenu2.png") ;right clicking a tab in firefox will automatically pull up the right click context menu. This ImageSearch is checking to see if it's there and then getting rid of it if it is
            {
                block.Off()
                errorLog(Error("Moved too far away from the right click context menu", -1),, 1)
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
        ;! I use firefox in dark mode
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
                        MouseMove(startX - 20, startY - 10)
                    if A_Index > 5
                        MouseMove(startX - 20, startY + 10)
                    if A_Index > 6
                        {
                            errorLog(TargetError("Culdn't find the active tab colour", -1),, 1)
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
                if !winget.isFullscreen(&title, title)
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
        if sc != "XButton1" && sc != "XButton2"
            return
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
                                switch sc {
                                    case "XButton2": ToolTip("Your mouse will now only move along the x axis")
                                    case "XButton1": ToolTip("Your mouse will now only move along the y axis")
                                }
                            }
                        else if A_TimeIdleMouse > 500
                            {
                                MouseGetPos(&newX, &newY)
                                switch sc {
                                    case "XButton2":
                                        if (newY = y) && (newX != toolx)
                                            {
                                                ToolTip("Your mouse will now only move along the x axis`nYou are currently level on the y axis")
                                                toolx := newX
                                            }
                                    case "XButton1":
                                        if (newX = x) && (newY != tooly)
                                            {
                                                ToolTip("Your mouse will now only move along the y axis`nYou are currently level on the x axis")
                                                tooly := newY
                                            }
                                }
                            }
                    }
                    MouseGetPos(&newX, &newY)
                    switch sc {
                        case "XButton2": MouseMove(newX, y)
                        case "XButton1": MouseMove(x, newY)
                    }
                }
                SetTimer(tools, 0)
                ToolTip("")
        }
        oneAxis(sc)
        if GetKeyState(fr, "P")
            goto start
    }

    /**
     * This function allows the minorly adjust the width/height & x/y values of the active window
     * @param {String} xORy determining which axis you wish to adjust
     * @param {String} window the title of the window you wish to adjust
     */
    static Adjust(xORy := "x", window := "A") {
        keys.allWait("second")
        WinGetPos(&x, &y, &w, &h, title := (window = "A") ? WinGetTitle(window) : title)
        hotkeys := getHotkeys()
        switch xORy {
            case "y":
                switch hotkeys.second {
                    case "-":    WinMove(,,, h -50, title)
                    case "=":    WinMove(,,, h +50, title)
                    case "Up":   WinMove(, y-50,,, title)
                    case "Down": WinMove(, y+50,,, title)
                }
            case "x":
                switch hotkeys.second {
                    case "-":     WinMove(,, w -50,, title)
                    case "=":     WinMove(,, w +50,, title)
                    case "Left":  WinMove(x -50,,,, title)
                    case "Right": WinMove(x +50,,,, title)
                }
            default:
                if !hotkeys.second || hotkeys.second = ""
                    SendInput(A_ThisHotkey)
                else
                    MsgBox("Unexpected activation hotkey")
        }
    }

    /**
     * This function will on first activation, center the active window in the middle of the active monitor. If activated again it will move the window to the center of the main monitor instead.
     * ##### This function has specific code for vlc & youtube windows
     * ##### The math for this function can act a bit funky with vertical monitors. Especially with programs like discord that have a minimum width
     */
    static winCenter() {
        mainMon := 1 ;set which monitor your main monitor is (usually 1, but can check in windows display settings)
        title := ""
        static win := "" ;a variable we'll hold the title of the window in
        static toggle := 1 ;a variable to determine whether to centre on the current display or move to the main one
        winget.Title(&title)
        monitor := WinGet.WinMonitor(title) ;now we run the above function we created
        if win = "" || win != title ;if our win variable doesn't have a title yet, or if it doesn't match the active window we run this code block to reset values
            {
                win := title
                toggle := 1
            }
        start:
        switch toggle {
            case 1: ;first toggle
                width := monitor.right - monitor.left ;determining the width of the current monitor
                height := monitor.bottom - monitor.top ;determining the height of the current monitor
                if winget.isFullscreen(&title2, title) ;checking if the window is fullscreen
                    WinRestore(title2,, "Editing Checklist -") ;winrestore will unmaximise it

                newWidth := width / 1.6 ;determining our new width
                newHeight := height / 1.6 ;determining our new height
                newX := (monitor.left + (width - newWidth)/2) ;using math to centre our newly created window
                newY := (monitor.bottom - (height + newHeight)/2) ;using math to centre our newly created window
                ;MsgBox("monitor = " monitor "`nwidth = " width "`nheight = " height "`nnewWidth = " newWidth "`nnewHeight = " newHeight "`nnewX = " newX "`nnewY = " newY "`nx = " x2 "`ny = " y2 "`nleft = " monitor.left "`nright = " right2 "`ntop = " top2 "`nbottom = " monitor.bottom) ;debugging
                if monitor != mainMon ;if the current monitor isn't our main monitor we will increment the toggle variable
                    toggle += 1
                else ;otherwise we reset the win variable
                    win := ""
            case 2: ;second toggle
                MonitorGet(mainMon, &left, &top, &right, &bottom) ;this will reset our variables with information for the main monitor
                monitor.monitor := mainMon ;then we set the monitor value to the main monitor
                monitor.left := left
                monitor.top := top
                monitor.right := right
                monitor.bottom := bottom
                toggle := 1 ;reset our toggle
                win := "" ;reset our win variable
                goto start ;and go back to the beginning
        }
        if InStr(title, "YouTube") && IsSet(newHeight) && monitor.monitor = mainMon ;My main monitor is 1440p so I want my youtube window to be a little bigger if I centre it
            {
                newHeight := newHeight * 1.3
                newY := newY / 2.25
            }
        if InStr(title, "VLC media player") && IsSet(newHeight) && monitor.monitor = mainMon ;I want vlc to be a size for 16:9 video to get rid of any letterboxing
            {
                newHeight := 900
                newWidth := 1416
            }
        try{
            WinMove(newX, newY, newWidth, newHeight, title,, "Editing Checklist -") ;then we attempt to move the window
        }
    }
}