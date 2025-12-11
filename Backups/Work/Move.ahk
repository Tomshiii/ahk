/************************************************************************
 * @description A class to contain a library of functions to interact with and move window elements.
 * @author tomshi
 * @date 2025/12/11
 * @version 1.2.15.1
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\winGet>
#Include <Classes\errorLog>
#Include <Classes\switchTo>
#Include <Classes\keys>
#Include <Functions\getHotkeys>
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
        ;// I have a habit of reloading my scripts then instantly trying to interact with premiere before ahk has caught up
        ;// which causes this function to throw because it hasn't actually set KSA yet
        if !IsSet(KSA)
            return
        if !IsSet(key) && (A_ThisHotkey != KSA.minimiseHotkey && A_ThisHotkey != KSA.maximiseHotkey) {
            ;// throw
            errorLog(ValueError("Incorrect hotkey has been used for function.`nDouble check KSA values.", -1),,, 1)
        }
        ignore := [prem.exeTitle]
        for v in ignore {
            GroupAdd("ignore", v)
        }
        if WinActive("ahk_group ignore")
            return
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
        if !window := winGet.Title()
            return
        SendInput("{LButton Up}") ;releases the left mouse button to stop it from getting stuck
        switch A_ThisHotkey,  "Off" {
            case KSA.minimiseHotkey: try WinMinimize(window)
            case KSA.maximiseHotkey:
                switch winget.isFullscreen(&title, window) {
                    case false: WinMaximize(window)
                    case true: WinRestore(window)
                    default: return
                }
            default:
                SendInput(key)
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
     * A function to lock mouse movement on a particular axis. function can be called a second time to disable
     * @link https://old.reddit.com/r/AutoHotkey/comments/1g8uqes/need_help/lt42sh7/
     * @param {String} [axs] either "x", or "y"
     * @param {Boolean} [keywait=true] determine whether to end the function after `keys.allWait(2)` or whether you wish to handle resetting manually
     */
    static clipMouse(Axs, keywait := true){
        coord.s("mouse")
        if (Clipped() = Axs) {
            this.setMouseClip()
            Clipped("-")
        } else {
            MouseGetPos(&x,&y)
            if (Axs="X")
                this.setMouseClip(1,0,y,A_ScreenWidth,y+1)
            else
                this.setMouseClip(1,x,0,x+1,A_ScreenHeight)
            Clipped(Axs)
        }

        Clipped(Val:="") {
            static Res:=""
            Res:=Val?Val:Res
            return Res
        }
        if keywait = true {
            keys.allWait(2)
            this.setMouseClip()
        }
    }

    /** helper function for `clipMouse`. call with no params to disable locked mouse movement */
    static setMouseClip(Conf:=0, x1:=0, y1:=0, x2:=1, y2:=1) {
        pData := DllCall("GlobalAlloc","UInt",0,"UPtr",16,"Ptr")
        NumPut("UPtr",x1,pData+0), NumPut("UPtr",y1,pData+4)
        NumPut("UPtr",x2,pData+8), NumPut("UPtr",y2,pData+12)
        Val := Conf ? DllCall("ClipCursor","Ptr",pData) : DllCall("ClipCursor")
        DllCall("GlobalFree","Ptr",pData)
        Return Val
    }

    /**
     * This function allows the minorly adjust the width/height & x/y values of the active window
     * @param {String} xORy determining which axis you wish to adjust
     * @param {String} window the title of the window you wish to adjust
     */
    static Adjust(xORy := "x", window := "A") {
        keys.allWait(2)
        WinGetPos(&x, &y, &w, &h, title := (window = "A") ? winGet.Title() : title)
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
     * This function is a poor mans version of `winCenter()` mainly designed to center a window "fullscreen" on your main monitor (but with ultrawides in mind)
     * @param {Number} modifier a number value that the user wishes for their windows width to conform to (in comparason to the total width of their display). Best to pick a number between 0 & 1
     */
    static winCenterWide(modifier := 0.75) {
        mainMon := MonitorGetPrimary()
        monPos  := MonitorGet(mainMon, &left, &top, &right, &bottom)
        win     := WinGet.Title()
        width   := right*modifier
        height  := bottom
        try {
            if winget.isFullscreen(, win) ;checking if the window is fullscreen
                WinRestore(win,, "Editing Checklist -") ;winrestore will unmaximise it
            WinMove((left+((right-width)/2)), top, width, height, win,, "Editing Checklist -")
        }
    }

    /**
     * This function will on first activation, center the active window in the middle of the active monitor. If activated again it will move the window to the center of the main monitor instead.
     * ##### This function has specific code for vlc & youtube windows
     * ##### The math for this function can act a bit funky with vertical monitors. Especially with programs like discord that have a minimum width
     * @param {Number} adjustHeight a number value to allow you to modify the general height of a centred window. This value is used as a multiplication step to increase the height. Eg. `1.25` increases the height by 25%. Depending on the resolution of your monitor a perfectly centred window may look a little strange (ultrawides in particular)
     * @param {Number} adjustWidth a number value to allow you to modify the general width of a centred window. This value is used as a multiplication step to increase the width. Eg. `1.25` increases the width by 25%. Depending on the resolution of your monitor a perfectly centred window may look a little strange (ultrawides in particular)
     */
    static winCenter(adjustHeight := 1, adjustWidth := 1) {
        mainMon := MonitorGetPrimary()
        title := ""
        static win := "" ;a variable we'll hold the title of the window in
        static toggle := 1 ;a variable to determine whether to centre on the current display or move to the main one
        winget.Title(&title)
        if !title
            return
        monitor := WinGet.WinMonitor(title) ;now we run the above function we created.
        if !monitor || !IsObject(monitor)
            return
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

                newWidth := (width / 1.6)*adjustWidth ;determining our new width
                newHeight := ((height / 1.6)*adjustHeight) ;determining our new height
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

        ;// My main monitor is 1440p so I want my youtube window to be a little bigger if I centre it
        if InStr(title, "YouTube") && IsSet(newHeight) && monitor.monitor = mainMon {
            newHeight := newHeight * 1.1
            newY := newY / 2.10
        }
        ;// I want vlc to be a size for 16:9 video to get rid of any letterboxing
        if InStr(title, "VLC media player") && IsSet(newHeight) && monitor.monitor = mainMon {
            IsWav := (InStr(title, ".wav") || InStr(title, ".mp3")) ? true : false
            ;// honestly this is probably all resolution dependent but I cbf figuring out how to adjust the math for individual resolutions
            switch IsWav {
                case true:
                    newHeight := newHeight/4, newY := newY*3.5
                    newWidth  := newWidth/4, newX := newX*2
                case false:
                    newHeight := newHeight/1.5 , newY := newY*2
                    newWidth  := newWidth/1.5, newX := newX*1.5
            }
        }
        try{
            WinMove(newX, newY, newWidth, newHeight, title,, "Editing Checklist -") ;then we attempt to move the window
        }
    }

    __Delete(*) {
        try OnExit(this.setMouseClip())
    }
}