/************************************************************************
 * @description A library of useful Premiere functions to speed up common tasks
 * Tested on and designed for v22.3.1 of Premiere. Believed to mostly work within v23.1
 * @author tomshi
 * @date 2023/03/09
 * @version 1.5.1
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\winget>
#Include <Classes\obj>
#Include <Classes\keys>
#Include <Functions\errorLog>
#Include <Functions\getHotkeys>
#Include <Functions\delaySI>
; }

class Prem {

    static exeTitle := Editors.Premiere.winTitle
    static winTitle := this.exeTitle
    static class := Editors.Premiere.class
    static path := ptf["Premiere"]

    ;// variables used in functions
    static timer := false
    static isWaiting := true
    static presses := 0
    static zoomToggle := 0
    static zToolX := 0
    static zToolY := 0

    ;// variables for `getTimeline()`
    static timelineXValue := 0
    static timelineYValue := 0
    static timelineXControl := 0
    static timelineYControl := 0

    class ClientInfo {
        ;//! these values are numbered so that the automatic toggles in `zoom()` enumerate in the proper order (as it goes alphabetically)

        alex := {
            1: [2064, -26, 215],
            2: [3467, 339, 390]
        }
        d0yle := {
            1: [-78, -53, 210],
            2: [-833, -462, 288]
            ;// sm64
            /* 1: [2013, 1128, 210],
            2: [2759, 1547, 288] */
            ;// polar bowler
            /* 1: [1677, 933, 175],
            3: [2013, 1128, 210],
            2: [615, 369, 150] */
        }
        chloe := {
            ;// below contains temp changes, orig; [-426, -238, 267], [-1679, -854, 486]
            1: [1727, 304, 267],
            2: [3070, 139, 486],
            3: [632, 278, 292]
        }
        emerldd := {
            1: [1913, 67, 200],
            2: [2873, -436, 300]
        }
    }

    /**
     * This variable contains a map of all relevant colour values for audioDrag() to work correctly
     */
    static dragColour := Map(
        ;// colours for a green audio track
        0x156B4C, 1, 0x1B8D64, 1, 0x1c7d5a, 1, 0x1D7E5B, 1, 0x1D986C, 1, 0x1E7F5C, 1, 0x1F805D, 1, 0x1FA072, 1, 0x1FA373, 1, 0x20815E, 1, 0x21825F, 1, 0x23AB83, 1, 0x248562, 1, 0x258663, 1, 0x268764, 1,  0x298A67, 1, 0x29D698, 1, 0x2A8B68, 1, 0x2A8D87, 1, 0x2B8C69, 1, 0x3A9B78, 1, 0x3DFFE4, 1, 0x44A582, 1, 0x457855, 1, 0x47A582, 1, 0x4AAB88, 1, 0x5C67F9, 1, 0x5D68FB, 1, 0x5D68FC, 1, 0xD0E1DB, 1, 0xD4F7EA, 1, 0xFDFDFD, 1, 0xFEFEFE, 1, 0xFFFFFF, 1, 0x3AAA59, 1,
        ;// colours for the red box
        0xE40000, 1, 0xEEE1E1, 1,
        ;// colours for the fx symbol box
        0x292929, 1, 0x2D2D2D, 1, 0x3B3B3B, 1, 0x404040, 1, 0x454545, 1, 0x4A4A4A, 1, 0x585858, 1, 0x606060, 1, 0x646464, 1, 0xA7ADAB, 1, 0xB1B1B1, 1, 0xCCCCCC, 1, 0xD2D2D2, 1, 0xEFEFEF, 1
    )

    __fxPanel() => (SendInput(KSA.effectControls), SendInput(KSA.effectControls))

    /**
     * This function cuts repeat code. It activates the findbox and waits for the carot to appear.
     */
    __findBox() {
        SendInput(KSA.findBox)
        tool.Cust("if you hear windows, blame premiere")
        CaretGetPos(&findx)
        if findx = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
            {
                loop {
                        if A_Index > 5
                            {
                                SendInput(KSA.findBox) ;adjust this in the ini file
                                tool.Cust("if you hear windows, blame adobe", 2000)
                            }
                        sleep 30
                        CaretGetPos(&findx)
                        if A_Index > 20 ;if this loop fires 20 times and premiere still hasn't caught up, the function will cancel itself
                            {
                                block.Off()
                                errorLog(IndexError("Couldn't find the findbox", -1),, 1)
                                return false
                            }
                    } until findx != "" ; as soon as premiere has found the find box, this will populate and break the loop
            }
        return findx
    }

    /**
     * This function will drag and drop any previously saved preset onto the clip you're hovering over. Your saved preset MUST be in a folder for this function to work.
     * @param {String} item in this function defines what it will type into the search box (the name of your preset within premiere)
     */
    static preset(item)
    {
        if Type(item) != "string" {
            ;// throw
            errorLog(TypeError("Incorrect value type in Parameter #1", -1, item),,, 1)
        }
        keys.allWait()
        ToolTip("Your Preset is being dragged")
        coord.s()
        block.On()
        MouseGetPos(&xpos, &ypos)
        this().__fxPanel()
        try {
            loop {
                if (A_Index > 3 && (!IsSet(classX) || width = 0))
                    throw
                ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
                try {
                    ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
                } catch as f {
                    ControlGetPos(&classX, &classY, &width, &height, ControlGetFocus("A")) ;gets the x/y value and width/height value
                }
                if IsSet(width) && width != 0
                    break
            }
        } catch as e {
            block.Off() ;just incase
            errorLog(UnsetError("Couldn't get the ClassNN of the desired panel", -1),, 1)
            return
        }
        if item = "loremipsum" ;YOUR PRESET MUST BE CALLED "loremipsum" FOR THIS TO WORK - IF YOU WANT TO RENAME YOUR PRESET, CHANGE THIS VALUE TOO - this if statement is code specific to text presets
            {
                sleep 100
                delaySI(150, KSA.timelineWindow, KSA.timelineWindow, KSA.newText)
                sleep 150
                ;// premiere can slow down depending on the size of your project so it's best
                ;// to build in multiple checks for most things
                loop {
                    if A_Index > 30 { ;// 3s
                        block.Off()
                        errorLog(Error("Couldn't find the graphics tab", -1),, 1)
                        return
                    }
                    if ImageSearch(&x2, &y2, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "graphics.png") ;checks for the graphics panel that opens when you select a text layer
                        break
                    sleep 100
                }
                loop {
                    if A_Index > 30 { ;// 3s
                        block.Off()
                        errorLog(Error("Couldn't find the eye icon", -1),, 1)
                        return
                    }
                    if ImageSearch(&xeye, &yeye, x2, y2, x2 + "200", y2 + "100", "*2 " ptf.Premiere "eye.png") ;searches for the eye icon for the original text
                        break
                    sleep 100
                }
                MouseMove(xeye, yeye)
                SendInput("{Click}")
                MouseGetPos(&eyeX, &eyeY)
                sleep 50
            }
        effectbox() ;this is simply to cut needing to repeat this code below
        {
            delaySI(50, KSA.effectsWindow, KSA.effectsWindow)
            if !this().__findBox()
                return
            SendInput(KSA.effectsWindow)
            SendInput("^a" "+{BackSpace}")
            SetTimer(delete, -250)
            delete() ;this function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job
            {
                if WinExist("Delete Item")
                    {
                        SendInput("{Esc}")
                        sleep 100
                        SendInput(KSA.effectsWindow)
                        if !this().__findBox()
                            return
                        SendInput(KSA.effectsWindow)
                        SendInput("^a" "+{BackSpace}")
                        sleep 60
                        if WinExist("Delete Item")
                            {
                                SendInput("{Esc}")
                                sleep 50
                            }
                    }
            }
        }
        effectbox()
        coord.c() ;change caret coord mode to window
        CaretGetPos(&carx, &cary) ;get the position of the caret (blinking line where you type stuff)
        MouseMove(carx, cary) ;move to the caret (instead of defined pixel coords) to make it less prone to breaking
        SendInput(item) ;create a preset of any effect, must be in a folder as well
        sleep 50
        MouseMove(0, 60,, "R") ;move down to the saved preset (must be in an additional folder)
        SendInput("{Click Down}")
        if item = "loremipsum" ;set this hotkey within the Keyboard Shortcut Adjustments.ini file
            {
                MouseMove(eyeX, eyeY - "5")
                SendInput("{Click Up}")
                effectbox()
                SendInput(KSA.timelineWindow)
                MouseMove(xpos, ypos)
                block.Off()
                return
            }
        MouseMove(xpos, ypos) ;in some scenarios if the mouse moves too fast a video editing software won't realise you're dragging. if this happens to you, add ', "2" ' to the end of this mouse move
        SendInput("{Click Up}")
        effectbox() ;this will delete whatever preset it had typed into the find box
        SendInput(KSA.timelineWindow) ;this will rehighlight the timeline after deleting the text from the find box
        block.Off()
        ToolTip("")
    }

    /**
     * This function is to move to the effects window and highlight the search box to allow manual typing
     */
    static fxSearch()
    {
        coord.s()
        block.On()
        this().__fxPanel()
        if !this().__findBox()
            return
        this().__fxPanel()
        SendInput("^a" "+{BackSpace}")
        SetTimer(delete, -250)
        delete() ;this function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job
        {
            if WinExist("Delete Item")
                {
                    SendInput("{Esc}")
                    sleep 100
                    this().__fxPanel()
                    if !this().__findBox()
                        return
                    this().__fxPanel()
                    SendInput("^a" "+{BackSpace}")
                    sleep 60
                    if WinExist("Delete Item")
                        {
                            SendInput("{Esc}")
                            sleep 50
                        }
                }
        }
        block.Off()
    }

    /**
     * This function on first run will ask you to select a clip with the exact zoom you wish to use for the current session. Any subsequent activations of the script will simply zoom the current clip to that zoom amount. You can reset this zoom by refreshing the script.
     *
     * If a specified client name is in the title of the window (usually in the url project path) this function will set predefined zooms. These clients can be defined within the neseted class `Prem.ClientInfo`
     */
    static zoom()
    {
        keys.allWait()
        ;// get coordinates for a tooltip that appears to alert the user that toggles have reset
        if this.zToolX = 0 || this.zToolY = 0
            {
                tool.Cust("Retrieving tooltip location",,,-40, 20, 4)
                SendInput(KSA.programMonitor)
                SendInput(KSA.programMonitor)
                try {
                    if !classNN := obj.ctrlPos()
                        return
                }
                this.zToolX := (classNN.x+15)
                this.zToolY := (classNN.y+classNN.height) - (classNN.height/5)
                ToolTip("",,, 4)
                tool.Cust("Some tooltips for this function will appear here",,, this.zToolX, this.zToolY, 4)
            }

        ;// start bulk of function
        this.presses++

        ;// giving the user 250ms to increment the zoom
        waitms := 250
        startTime := A_TickCount
        SetTimer(waitTimer.Bind(startTime), 16)
        waitTimer(time) {
            if A_ThisHotkey != "" {
                if GetKeyState(A_ThisHotkey, "P")
                    {
                        ToolTip("")
                        SetTimer(, 0)
                        return
                    }
            }
            ToolTip("Presses: " this.presses "`nWill reset in: " waitms - (A_TickCount - time) "ms")
            if (A_TickCount - time) < waitms
                return
            this.isWaiting := false
            ToolTip("")
            SetTimer(, 0)
        }

        resetTime := 5 * 1000 ;convert ms to s
        /**
         * This function is for a timer we activate anytime a client's zoom has a toggle
         * @param {Integer} time the current tick count that gets passed in as `A_TickCount`
         */
        reset(time) {
            ListLines(0)
            ;// if the user activates this function before the timer finishes, due to some code below
            ;// this variable will be set to false. The timer will then see this change and cancel
            ;// itself so it can be later reset
            if !this.timer
                {
                    SetTimer(, 0)
                    return
                }
            if ((A_TickCount - time) >= resetTime) || GetKeyState("F5", "P")
                {
                    tool.Cust("zoom toggle reset",,, this.zToolX, this.zToolY, 2)
                    this.timer := false, this.presses := 0, this.zoomToggle := 0
                    Tog := 1
                    SetTimer(, 0)
                    return
                }
        }

        ;// assign the nested class to an object
        clientList := this.ClientInfo()
        ;// then we'll define the values that will allow us to change things depending on the project
        static x := 0, y := 0, scale := 0

        coord.s()
        if !WinActive(this.winTitle) {
            block.Off()
            errorLog(Error("Premiere is not the active window", -1),, 1)
            return
        }
        sleep 50
        this().__fxPanel()
        sleep 50
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e)
            return
        }

        ;//get client name
        ClientName := WinGet.ProjClient()
        if !ClientName
            {
                block.Off()
                tool.Wait()
                tool.Cust("Couldn't get the client name")
                return
            }
        ;// check to see if the clientlist contains the current client name
        if clientList.HasOwnProp(ClientName) {
            block.On()
            MouseGetPos(&xpos, &ypos)
            loop {
                if A_ThisHotkey != "" {
                    if GetKeyState(A_ThisHotkey, "P") {
                        block.Off()
                        return
                    }
                }
                if this.isWaiting = false
                    break
            }
            this.isWaiting := true

            ;// debug func
            /* check(block, other := "") {
                MsgBox(Format("
                (
                    block: {}
                    orig: {}
                    tog {}
                    count: {}
                    presses: {}
                    math: {}
                )", block, origtog, tog, count, this.presses, other)
                )
            } */
            count := ObjOwnPropCount(clientList.%ClientName%)

            ;// logic for the toggle using a class variable
            loop this.presses {
                this.zoomToggle++
                if this.zoomToggle > count
                    this.zoomToggle := 1
            }

            this.presses := 0
            if clientList.%ClientName%.HasOwnProp("1") && count = 1
                {
                    x     := clientList.%ClientName%.punchIn[1]
                    y     := clientList.%ClientName%.punchIn[2]
                    scale := clientList.%ClientName%.punchIn[3]
                }
            else if count > 1
                {
                    if !this.timer
                        {
                            this.timer := true
                            SetTimer(reset.bind(A_TickCount), 15) ;reset toggle values after x seconds
                        }
                    else
                        {
                            ;// if the timer is already active, we first have to stop it before restarting it
                            ;// since the timer checks the state of `this.timer` which is a variable at the top of this class, we simply set that variable to false
                            ;// sleep for a fraction of a second so the timer has time to notice the change
                            ;// then reset the value and reset the timer
                            ;// otherwise you end up with multiple tooltip stating that toggles have been reset
                            this.timer := false
                            sleep 50
                            this.timer := true
                            SetTimer(reset.bind(A_TickCount), 15) ;reset toggle values after x seconds
                        }
                    tool.Cust("zoom " this.zoomToggle "/" count, 2.0)
                    ;// this for loop stops the need to hard code each potential toggle
                    ;// as long as the object contains '1' & more than 1 property, this will function correctly
                    for Name in clientList.%ClientName%.OwnProps() {
                        if A_Index != this.zoomToggle
                            continue
                        x := clientList.%ClientName%.%Name%[1]
                        y := clientList.%ClientName%.%Name%[2]
                        scale := clientList.%ClientName%.%Name%[3]
                    }
                }
        }
        if scale = 0
            {
                setValue := MsgBox("You haven't set the zoom amount/position for this session yet.`nIs the current track your desired zoom?", "Set Zoom", "4 32 4096")
                if setValue = "No"
                    {
                        block.Off()
                        return
                    }
            }
        block.On()
        MouseGetPos(&xpos, &ypos)
        SendInput(KSA.timelineWindow)
        if ImageSearch(&clipX, &clipY, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&clipX, &clipY, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        errorLog(Error("No clips were selected", -1),, 1)
                        block.Off()
                        return
                    }
            }
        if (!ImageSearch(&motionX, &motionY, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "motion2.png") &&
            !ImageSearch(&motionX, &motionY, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "motion3.png"))
            {
                MouseMove(xpos, ypos)
                block.Off()
                errorLog(Error("Couldn't find the video section", -1),, 1)
                return
            }
        MouseMove(motionX + 10, motionY + 10)
        SendInput("{Click}")
        MouseMove(xpos, ypos)
        SendInput("{Tab 2}")
        ;// the user hasn't set a zoom for the current client
        if x = 0
            {
                cleanCopy()
                {
                    A_Clipboard := ""
                    SendInput("^c")
                    ClipWait()
                }
                previousClipboard := A_Clipboard
                cleanCopy()
                x := A_Clipboard
                SendInput("{Tab}")
                cleanCopy()
                y := A_Clipboard
                SendInput("{Tab}")
                cleanCopy()
                scale := A_Clipboard
                SendInput("{Enter}")
                block.Off()
                tool.Cust("Setting up your zoom has completed")
                return
            }
        ;// the user HAS set up zooms for the current client
        delaySI(0, x, "{Tab}", y, "{Tab}", scale, "{Enter}")
        block.Off()
    }

    /**
     * A function to warp to one of a videos values (scale , x/y, rotation, etc) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
     * @param {String} filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
     * @param {Integer} optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
     */
    static valuehold(filepath, optional := 0, blendMode := "")
    {
        ;This function will only operate correctly if the space between the x value and y value is about 210 pixels away from the left most edge of the "timer" (the icon left of the value name)
        ;I use to have it try to function irrespective of the size of your panel but it proved to be inconsistent and too unreliable.
        ;You can plug your own x distance in by changing the value below
        xdist := 210
        coord.s()
        MouseGetPos(&xpos, &ypos)
        ;tool.Cust("x " xpos "`ny " ypos) ;testing stuff
        block.On()
        this().__fxPanel()
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e)
            return
        }
        SendInput(KSA.timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            { ;any imagesearches on the effect controls window includes a division variable (KSA.ECDivide) as I have my effect controls quite wide and there's no point in searching the entire width as it slows down the script
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips are selected", -1),, 1)
                        return
                    }
            }
        if filepath = "levels" ;THIS IS FOR ADJUSTING THE "LEVEL" PROPERTY, YOUR PNG MUST BE CALLED "levels.png"
            { ;don't add WheelDown's, they suck in hotkeys, idk why, they lag everything out and stop Click's from working
                if ImageSearch(&vidx, &vidy, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "video.png")
                    {
                        block.Off()
                        errorLog(Error("The user wasn't scrolled down", -1),, 1)
                        keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                        return
                    }
            }
        loop {
            if A_Index > 1
                {
                    ToolTip(A_Index)
                    this().__fxPanel()
                    try {
                        ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
                        ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
                    } catch as e {
                        tool.Cust("Couldn't get the ClassNN of the Effects Controls panel")
                        errorLog(e)
                        MouseMove(xpos, ypos)
                        block.Off()
                        return
                    }
                }
            checkImg(checkfilepath) {
                blendheight := (filepath = "blend\blendmode") ? 50 : 0
                if FileExist(checkfilepath) && ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height + blendheight, "*2 " checkfilepath)
                    return true
                return false
            }
            if ( ;finds the value you want to adjust, then finds the value adjustment to the right of it
                checkImg(ptf.Premiere filepath ".png") ||
                checkImg(ptf.Premiere filepath "2.png") ||
                checkImg(ptf.Premiere filepath "3.png") ||
                checkImg(ptf.Premiere filepath "4.png")
            )
                break
            if A_Index > 3
                {
                    block.Off()
                    errorLog(IndexError("Failed to find the requested property", -1, filepath),, 1)
                    keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                    MouseMove(xpos, ypos)
                    block.Off()
                    return
                }
            sleep 50
        }
        if filepath = "blend\blendmode"
            {
                if !ImageSearch(&arrX, &arrY, x, y, x+400, y+40, "*2 " ptf.Premiere filepath "arrow.png")
                    {
                        errorLog(Error("Couldn't find the arrow to open the blend mode menu", -1),, 1)
                        MouseMove(xpos, ypos)
                        block.Off()
                        return
                    }
                MouseMove(arrx, arrY)
                SendInput("{Click}")
                sleep 500
                if !ImageSearch(&modeX, &modeY, arrx-400, arrY-700, arrx, arrY, "*2 " ptf.Premiere "blend\" blendmode ".png") && !ImageSearch(&modeX, &modeY,  arrx-400, arrY-700, arrx, arrY, "*2 " ptf.Premiere "blend\" blendmode "2.png")
                    {
                        errorLog(Error("Couldn't find the desired blend mode", -1),, 1)
                        MouseMove(xpos, ypos)
                        block.Off()
                        return
                    }
                MouseMove(modeX, modeY)
                SendInput("{Click}")
                MouseMove(xpos, ypos)
                block.Off()
                return
            }
        colour:
        if !PixelSearch(&xcol, &ycol, x, y, x + xdist, y + "40", 0x205cce, 2)
            {
                block.Off()
                tool.Cust("the blue text",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(Error("Couldn't find the blue 'value' text", -1),, 1)
                keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                MouseMove(xpos, ypos)
                return
            }
        MouseMove(xcol + optional, ycol)
        sleep 50 ;required, otherwise it can't know if you're trying to tap to reset
        ;I tried messing around with "if A_TimeSincePriorHotkey < 100" instead of a sleep here but premiere would get stuck in a state of "clicking" on the field if I pressed a macro, then let go quickly but after the 100ms. Maybe there's a smarter way to make that work, but honestly just kicking this sleep down to 50 from 100 works fine enough for me and honestly isn't even really noticable.
        if GetKeyState(A_ThisHotkey, "P")
            {
                SendInput("{Click Down}")
                block.Off()
                keys.allWait()
                SendInput("{Click Up}" "{Enter}")
                sleep 200 ;was experiencing times where ahk would just fail to excecute the below mousemove. no idea why. This sleep seems to stop that from happening and is practically unnoticable
                MouseMove(xpos, ypos)
                /* MouseGetPos(&testx, &testy) ;testing stuff
                MsgBox("og x " xpos "`nog y " ypos "`ncurrent x " testx "`ncurrent y " testy) */
            }
        else
            {
                if !ImageSearch(&x2, &y2, x, y - "10", x + "1500", y + "20", "*2 " ptf.Premiere "reset.png") ;searches for the reset button to the right of the value you want to adjust. if it can't find it, the below block will happen
                    {
                        if filepath = "levels" ;THIS IS FOR ADJUSTING THE "LEVEL" PROPERTY, CHANGE IN THE KEYBOARD SHORTCUTS.INI FILE
                            {
                                SendInput("{Click}" "0" "{Enter}")
                                MouseMove(xpos, ypos)
                                block.Off()
                                return
                            }
                        MouseMove(xpos, ypos)
                        block.Off()
                        errorLog(Error("Couldn't find the reset button", -1),, 1)
                        return
                    }
                MouseMove(x2, y2)
                SendInput("{Click}")
                MouseMove(xpos, ypos)
                block.Off()
            }
        ToolTip("")
    }

    /**
     * This function is to turn off keyframing for a given property within premiere pro
     * @param {String} filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
     */
    static keyreset(filepath) ;I think this function is broken atm, I need to do something about it... soon
    {
        MouseGetPos(&xpos, &ypos)
        coord.s()
        block.On()
        this().__fxPanel()
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e)
            return
        }
        SendInput(KSA.timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        errorLog(Error("No clips were selected", -1),, 1)
                        block.Off()
                        return
                    }
            }
        if !ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere filepath "2.png") && !ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere filepath "4.png")
            {
                errorLog(Error("The user was already keyframing", -1),, 1)
                block.Off()
                return
            }
        MouseMove(x + "7", y + "4")
        click
        block.Off()
        MouseMove(xpos, ypos)
    }

    /**
     * This function is to either turn on keyframing, or create a new keyframe at the cursor for a given property within premiere pro
     * @param {String} filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
     */
    static keyframe(filepath)
    {
        MouseGetPos(&xpos, &ypos)
        coord.s()
        block.On()
        this().__fxPanel()
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e)
            return
        }
        SendInput(KSA.timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips were selected", -1),, 1)
                        return
                    }
            }
        if (
            !checkImg(ptf.Premiere filepath ".png", &x, &y, {x1: classX, y1: classY, x2: classX + (width/KSA.ECDivide), y2: classY + height}) &&
            !checkImg(ptf.Premiere filepath "2.png", &x, &y, {x1: classX, y1: classY, x2: classX + (width/KSA.ECDivide), y2: classY + height}) &&
            !checkImg(ptf.Premiere filepath "3.png", &x, &y, {x1: classX, y1: classY, x2: classX + (width/KSA.ECDivide), y2: classY + height}) &&
            !checkImg(ptf.Premiere filepath "4.png", &x, &y, {x1: classX, y1: classY, x2: classX + (width/KSA.ECDivide), y2: classY + height})
        )
            {
                block.Off()
                errorLog(Error("Couldn't find the desired value", -1),, 1)
                return
            }
        if ImageSearch(&keyx, &keyy, x, y, x + 500, y + 20, "*2 " ptf.Premiere "keyframeButton.png") || ImageSearch(&keyx, &keyy, x, y, x + 500, y + 20, "*2 " ptf.Premiere "keyframeButton2.png")
            MouseMove(keyx + 3, keyy)
       else
            MouseMove(x + 5, y + 5)
        SendInput("{Click}")
        SendInput(KSA.timelineWindow) ;focuses the timeline
        MouseMove(xpos, ypos)
        block.Off()
    }

    /**
     * This function pulls an audio file out of a separate bin from the project window and back to the cursor (premiere pro)
     *
     * If `sfxName` is "bleep" there is extra code that automatically moves it to your track of choice
     * @param {String} sfxName is the name of whatever sound you want the function to pull onto the timeline
     */
    static audioDrag(sfxName)
    {
        ;I wanted to use a method similar to other premiere functions above, that grabs the classNN value of the panel to do all imagesearches that way instead of needing to define coords, but because I'm using a separate bin which is essentially just a second project window, things get messy, premiere gets slow, and the performance of this function dropped drastically so for this one we're going to stick with coords defined in KSA.ini/ahk & additional hard coded values

        /**
         * A function to cut repeat code. Checks the state of the cursor
         */
        cursorCheck() {
            if A_Cursor != "Arrow"
                loop 12 {
                    MouseMove(5, 0, 2, "R")
                    if A_Cursor = "Arrow"
                        {
                            MouseMove(5, 0, 2, "R")
                            sleep 25
                            break
                        }
                    sleep 50
                }
        }
        coord.s()
        SendInput(KSA.selectionPrem)
        if !ImageSearch(&sfxxx, &sfxyy, 3021, 664, 3589, 1261, "*2 " ptf.Premiere "binsfx.png") ;checks to make sure you have the sfx bin open as a separate project window
            {
                errorLog(Error("User hasn't opened the required bin", -1),, 1)
                return
            }
        block.On()
        coord.s()
        MouseGetPos(&xpos, &ypos)
        if ImageSearch(&listx, &listy, 3082, 664, 3591, 1265, "*2 " ptf.Premiere "list view.png") ;checks to make sure you're in the list view
            {
                MouseMove(listx, listy)
                SendInput("{Click}")
                sleep 100
            }
        loop {
            SendInput(KSA.projectsWindow) ;highlights the project window ~ check the keyboard shortcut ini file to adjust hotkeys
            SendInput(KSA.projectsWindow) ;highlights the sfx bin that I have ~ check the keyboard shortcut ini file to adjust hotkeys
            ;keys.allWait() ;I have this set to remapped mouse buttons which instantly "fire" when pressed so can cause errors
            if !this().__findBox()
                return
            SendInput("^a" "+{BackSpace}")
            SendInput(sfxName)
            sleep 250 ;the project search is pretty slow so you might need to adjust this
            coord.w()
            if !ImageSearch(&vlx, &vly, KSA.sfxX1, KSA.sfxY1, KSA.sfxX2, KSA.sfxY2, "*2 " ptf.Premiere "audio.png") && !ImageSearch(&vlx, &vly, KSA.sfxX1, KSA.sfxY1, KSA.sfxX2, KSA.sfxY2, "*2 " ptf.Premiere "audio2.png") ;searches for the audio image next to an audio file
                {
                    block.Off()
                    errorLog(Error("Couldn't find the audio image", -1),, 1)
                    coord.s()
                    MouseMove(xpos, ypos)
                    return
                }
            MouseMove(vlx, vly)
            sleep 100
            SendInput("{Click Down}")
            sleep 100
            coord.s()
            MouseMove(xpos, ypos)
            SendInput("{Click Up}")
            SendInput(KSA.timelineWindow)
            sleep 50
            colour := PixelGetColor(xpos + 10, ypos)
            if !this.dragColour.Has(colour)
                break
            if A_Index > 2
                {
                    block.Off()
                    errorLog(IndexError("Couldn't drag the file to the timeline because colour was " colour " A_Index was: " A_Index, -1),, 1)
                    return
                }
        }
        ;// out of loop
        block.Off()
        if sfxName = "bleep"
            {
                sleep 50
                SendInput(KSA.selectionPrem)
                MouseGetPos(&delx, &dely)
                MouseMove(10, 0,, "R")
                sleep 50
                cursorCheck()
                SendInput("{Click}")
                sleep 50
                SendInput(KSA.gainAdjust)
                SendInput("-20")
                SendInput("{Enter}")
                WinWaitClose("Audio Gain")
                MouseMove(xpos, ypos)
                trackNumber := 2
                sleep 100
                SendInput(KSA.cutPrem)
                start := A_TickCount
                sec := 0
                clear() {
                    ToolTip("")
                    ToolTip("",,, 2)
                    ToolTip("",,, 3)
                }
                loop {
                    ;check to see if the user wants the bleep on a track between 1-9
                    getlastHotkey := A_PriorKey
                    if getlastHotkey = ""
                        goto skip
                    if IsDigit(getlastHotkey) ;checks to see if the last pressed key is a number between 1-9
                        trackNumber := getlastHotkey
                    if GetKeyState("Esc", "P") || getlastHotkey = "Escape"
                        {
                            clear()
                            return
                        }
                    skip:
                    sleep 50
                    if A_Index > 160 ;built in timeout
                        {
                            block.Off()
                            clear()
                            errorLog(IndexError(A_ThisFunc "() timed out due to no user interaction", -1),, 1)
                            return
                        }
                    if ((A_TickCount - start) >= 1000)
                        {
                            start += 1000
                            sec += 1
                        }
                    secRemain := 8 - sec
                    mousegetpos(, &ypos)
                    ToolTip("This function will attempt to drag your bleep to:`n" A_Tab A_Tab "Track " trackNumber)
                    ToolTip("Press another number key to move to a different track`nThe function will continue once you've cut the track`n" secRemain "s remaining",, ypos+15, 2)
                    ToolTip("Cancel with: Esc",, ypos-50, 3)
                } until GetKeyState("LButton", "P")
                ;// out of loop
                clear()
                block.On()
                sleep 50
                SendInput(KSA.selectionPrem)
                MouseGetPos(&delx, &dely)
                MouseMove(xpos + 10, ypos)
                sleep 500
                SendInput("{Click Down}")
                MouseGetPos(&refx, &refy)
                if !ImageSearch(&trackX, &trackY, 0, 0, 200, A_ScreenHeight, "*2 " ptf.Premiere "track " trackNumber "_1.png") && !ImageSearch(&trackX, &trackY, 0, 0, 200, A_ScreenHeight, "*2 " ptf.Premiere "track " trackNumber "_2.png")
                    {
                        block.Off()
                        errorLog(Error("Couldn't determine the Y value of desired track", -1, trackNumber),, 1)
                        return
                    }
                MouseMove(refx, trackY, 2)
                SendInput("{Click Up}")
                sleep 50
                MouseMove(delx + 10, dely, 2)
                sleep 200
                cursorCheck()
                SendInput("{Click}")
                SendInput("{BackSpace}")
                MouseMove(xpos + 10, ypos)
                Sleep(25)
                cursorCheck()
                block.Off()
                ToolTip("")
                return
            }
    }

    /**
     * Move back and forth between edit points from anywhere in premiere
     * @param {String} direction is the hotkey within premiere for the direction you want it to go in relation to "edit points"
     */
    static wheelEditPoint(direction)
    {
        SendInput(KSA.timelineWindow) ;focuses the timeline
        SendInput(direction)
        keys.allWait() ;prevents hotkey spam
    }

    /**
     * This function is to adjust the framing of a video within the preview window in premiere pro. Let go of this hotkey to confirm, simply tap this hotkey to reset values
     */
    static movepreview()
    {
        coord.s()
        block.On()
        MouseGetPos(&xpos, &ypos)
        delaySI(25, KSA.effectControls, KSA.effectControls)
        effectCtrl := obj.ctrlPos()
        SendInput(KSA.timelineWindow) ;focuses the timeline
        sleep 25
        if ImageSearch(&x, &y, effectCtrl.x, effectCtrl.y, effectCtrl.x + (effectCtrl.width/KSA.ECDivide), effectCtrl.y + effectCtrl.height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, effectCtrl.x, effectCtrl.y, effectCtrl.x + (effectCtrl.width/KSA.ECDivide), effectCtrl.y + effectCtrl.height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips were selected", -1),, 1)
                        return
                    }
            }
        loop {
            if ImageSearch(&x, &y, effectCtrl.x, effectCtrl.y, effectCtrl.x + (effectCtrl.width/KSA.ECDivide), effectCtrl.y + effectCtrl.height, "*2 " ptf.Premiere "motion.png") ;moves to the motion tab
                    {
                        MouseMove(x + "25", y)
                        SendInput("{Click}")
                        break
                    }
            if A_Index > 3
                {
                    block.Off()
                    errorLog(IndexError("Couldn't find the requested property.", -1),, {ttip: 2, y:30})
                    keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                    MouseMove(xpos, ypos)
                    return
                }
            sleep 50
        }
        sleep 50
        ToolTip("")
        ;// gets the state of the hotkey, enough time now has passed that if the user just presses the button, you can assume they want to reset the paramater instead of edit it
        if !GetKeyState(A_ThisHotkey, "P")
            {
                if !ImageSearch(&xcol, &ycol, effectCtrl.x, effectCtrl.y, effectCtrl.x + (effectCtrl.width/KSA.ECDivide), effectCtrl.y + effectCtrl.height, "*2 " ptf.Premiere "reset.png")
                    {
                        block.Off()
                        MouseMove(xpos, ypos)
                        errorLog(Error("Couldn't find the reset button", -1)
                                    ,, 1)
                        return
                    }
                MouseMove(xcol, ycol)
                SendInput("{Click}")
                sleep 50
                MouseMove(xpos, ypos)
                block.Off()
                return
            }
        ;//* you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable to move the preview window
        /**
         * This codeblock is potentially used below if the first loop fails
         */
        fallback() {
            tool.Cust("fallback")
            origX := previewWin.x + 10, origY := previewWin.height
            previewWin.y += 30
            previewWin.x += 15
            loop {
                previewWin.x += 5, previewWin.y += 10
                if previewWin.x > previewWin.x + previewWin.width
                    previewWin.x := origX
                if previewWin.y > origY
                    {
                        MouseMove(xpos, ypos)
                        block.Off()
                        keys.allWait()
                        return false
                    }
                check := PixelGetColor(previewWin.x, previewWin.y)
                ;// debugging
                /* FileAppend(Format("
                (
                    Index: {}
                    x: {}
                    y: {}
                    width: {}
                    height: {}
                    origX: {}
                    origY: {}
                    ________________

                )", A_Index, previewWin.x, previewWin.y, previewWin.width, previewWin.height, origX, origY), "test.txt") */
                if check != 0x232323 && check != 0x000000
                    {
                        MouseMove(previewWin.x, previewWin.y)
                        break
                    }
            }
            return true
        }
        /**
         * Save repeat code
         * @return return an object of the currently in focus control
         */
        projMon() {
            delaySI(25, KSA.programMonitor, KSA.programMonitor)
            sleep 50
            return obj.CtrlPos()
        }
        previewWin := projMon()
        if !IsObject(previewWin)
            return
        ;// check to see if the classNN value of the current object is the same as earlier in the function
        ;// if it is, it indicates that the function may have moved too fast so this block will try again
        if previewWin.ctrl == effectCtrl.ctrl
            {
                previewWin := projMon()
                if previewWin.ctrl == effectCtrl.ctrl
                    {
                        errorLog(TargetError("Function couldn't determine the difference between the Effect Controls window and the Program Monitor", 1), "This may be due to Premiere assigning them the same ClassNN value", 1)
                        return
                    }
            }
        startX := (previewWin.x + (previewWin.width/2)) - 20
        startY := (previewWin.y + (previewWin.height/2)) - 10
        MouseMove(startX, startY) ;move to the preview window
        loop {
            MouseGetPos(&colX, &colY)
            if PixelGetColor(colX, colY) != 0x000000
                break
            if A_Index > 4
                {
                    if !fallback()
                        {
                            errorLog(IndexError("Couldn't find the video in the Program Monitor.", -1)
                                        , "Or the function kept finding pure black at each checking coordinate", 1)
                        }
                    break
                }
            switch A_Index {
                case 1: MouseMove(startX + 150, startY + 100)
                case 2: MouseMove(startX - 150, startY + 100)
                case 3: MouseMove(startX - 150, startY - 100)
                case 4: MouseMove(startX + 150, startY - 100)
            }
        }
        SendInput("{Click Down}")
        sleep 50
        block.Off()
        keys.allWait()
        SendInput("{Click Up}")
        ;!MouseMove(xpos, ypos) ; // moving the mouse position back to origin after doing this is incredibly disorienting
    }

    /**
     * This function moves the cursor to the reset button to reset the "motion" effects
     */
    static reset()
    {
        keys.allWait()
        coord.s()
        block.On()
        this().__fxPanel()
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e)
            return
        }
        SendInput(KSA.timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips were selected", -1),, 1)
                        return
                    }
            }
        MouseGetPos(&xpos, &ypos)
        loop {
            if ImageSearch(&x2, &y2, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "motion2.png") || ImageSearch(&x2, &y2, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "motion3.png") ;checks if the "motion" value is in view
                break
            if A_Index > 5
                {
                    block.Off()
                    errorLog(IndexError("Couldn't find the motion image", -1),, 1)
                    return
                }
        }
        SendInput(KSA.timelineWindow) ;~ check the keyboard shortcut ini file to adjust hotkeys
        if ImageSearch(&xcol, &ycol, x2, y2 - "20", x2 + "700", y2 + "20", "*2 " ptf.Premiere "reset.png") ;this will look for the reset button directly next to the "motion" value
            MouseMove(xcol, ycol)
        SendInput("{Click}")
        MouseMove(xpos, ypos)
        block.Off()
    }

    /**
     * This function will warp to and press any value in premiere to manually input a number
     * @param {String} property is the value you want to adjust. ie "scale"
     * @param {Integer} optional is the optional pixels to move the mouse to grab the Y axis value instead of the X axis
     */
    static manInput(property, optional := 0)
    {
        getHotkeys(&first, &waitHotkey)
        MouseGetPos(&xpos, &ypos)
        coord.s()
        block.On()
        this().__fxPanel()
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e)
            return
        }
        SendInput(KSA.timelineWindow)
        if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips were selected", -1),, 1)
                        return
                    }
            }
        if ( ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
            !ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere property ".png") &&
            !ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere property "2.png") &&
            !ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere property "3.png") &&
            !ImageSearch(&x, &y, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere property "4.png")
        )
            {
                block.Off()
                errorLog(Error("Couldn't find the property requested.", -1, property),, 1)
                return
            }
        if !PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x205cce, 2) ;searches for the blue text to the right of the scale value
            {
                block.Off()
                errorLog(Error("Couldn't find the blue 'value' text", -1),, 1)
                return
            }
        MouseMove(xcol + optional, ycol)
        keywait(waitHotkey)
        SendInput("{Click}")
        ToolTip("manInput() is waiting for the " "'" KSA.manInputEnd "'" "`nkey to be pressed")
        KeyWait(KSA.manInputEnd, "D") ;waits until the final hotkey is pressed before continuing
        ToolTip("")
        SendInput("{Enter}")
        MouseMove(xpos, ypos)
        SendInput("{MButton}")
        block.Off()
    }

    /**
     * This function is to increase/decrease gain within premiere pro. This function will check to ensure the timeline is in focus and a clip is selected
     * @param {Integer} amount is the value you want the gain to adjust (eg. -2, 6, etc)
     */
    static gain(amount)
    {
        if !IsNumber(amount) {
                ;// throw
                errorLog(TypeError("Invalid parameter type in Parameter #1", -1, amount),,, 1)
            }
        keys.allWait()
        Critical
        ToolTip("Adjusting Gain")
        block.On()
        coord.s()
        ClassNN := getClass(&classX, &classY, &width, &height)
        getClass(&classX, &classY, &width, &height) {
            try {
                loop {
                    this().__fxPanel()
                    check := winget.Title()
                    if check = "Audio Gain"
                        {
                            SendInput(amount "{Enter}")
                            ToolTip("")
                            block.Off()
                            return -1
                        }
                    try {
                        ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
                        ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
                    } catch as e {
                        block.Off() ;just incase
                        tool.Cust("Couldn't get the ClassNN of the desired panel")
                        errorLog(e)
                        return false
                    }
                    if ClassNN != "DroverLord - Window Class3" || ClassNN != "DroverLord - Window Class1"
                        break
                    sleep 30
                    if A_Index != 100
                        {
                            tool.Cust("Waiting for gain window timed out")
                            block.Off()
                            return false
                        }
                }
            }
        }
        if ClassNN = -1 || !IsSet(ClassNN)
            return
        SendInput(KSA.timelineWindow)
        try {
            if ImageSearch(&x3, &y3, classX, classY, classX + (width/KSA.ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
                {
                    SendInput(KSA.timelineWindow KSA.selectAtPlayhead) ;~ check the keyboard shortcut ini file to adjust hotkeys
                    goto inputs
                }
        } catch as e {
            ToolTip("")
            block.Off()
            tool.Cust("ClassNN wasn't given a value")
            errorLog(e)
            return
        }
        inputs:
        SendInput(KSA.gainAdjust)
        if !WinWait("Audio Gain",, 3)
            {
                tool.Cust("Waiting for gain window timed out")
                block.Off()
                return
            }
        SendInput("+{Tab}{UP 3}{DOWN}{TAB}" amount "{ENTER}")
        WinWaitClose("Audio Gain")
        block.Off()
        ToolTip("")
    }

    /**
     * Press a button(ideally a mouse button), this function then changes to the "hand tool" and clicks so you can drag and easily move along the timeline, then it will swap back to the tool of your choice (selection tool for example).

     * This function will (on first use) check the coordinates of the timeline and store them, then on subsequent uses ensures the mouse position is within the bounds of the timeline before firing - this is useful to ensure you don't end up accidentally dragging around UI elements of Premiere.

     * This version is specifically for Premiere Pro
     * @param {String} tool is the hotkey you want the script to input to swap TO (ie, hand tool, zoom tool, etc). (consider using KSA values)
     * @param {String} toolorig is the hotkey you want the script to input to bring you back to your tool of choice (consider using KSA values)
    */
    static mousedrag(premtool, toolorig)
    {
        if GetKeyState("RButton", "P") ;this check is to allow some code in `right click premiere.ahk` to work
            return
        SetTimer(rdisable, -1)
        rdisable() {
            if GetKeyState("RButton", "P") ;this check is to allow some code in `right click premiere.ahk` to work
                {
                    SetTimer(rdisable, 0)
                    return
                }
            SetTimer(rdisable, -50)
        }
        MouseGetPos(&x, &y) ;from here down to the begining of again() is checking for the width of your timeline and then ensuring this function doesn't fire if your mouse position is beyond that, this is to stop the function from firing while you're hoving over other elements of premiere causing you to drag them across your screen
        if this.timelineXValue = 0 || this.timelineYValue = 0 || this.timelineXControl = 0 || this.timelineYControl = 0
            {
                if !this.getTimeline()
                    goto skip
            }
        if x > this.timelineXValue || x < this.timelineXControl || y < this.timelineYValue || y > this.timelineYControl ;this line of code ensures that the function does not fire if the mouse is outside the bounds of the timeline. This code should work regardless of where you have the timeline (if you make you're timeline comically small you may encounter issues)
            {
                SetTimer(rdisable, 0)
                return
            }
        skip:
        again()
        {
            if A_ThisHotkey = KSA.DragKeywait ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
                {
                    if !GetKeyState(A_ThisHotkey, "P") ;this is here so it doesn't reactivate if you quickly let go before the timer comes back around
                        {
                            SetTimer(rdisable, 0)
                            return
                        }
                }
            else if !GetKeyState(KSA.DragKeywait, "P")
                {
                    SetTimer(again, 0)
                    SetTimer(rdisable, 0)
                    Exit()
                }
            ; click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
            SendInput(KSA.timelineWindow) ;don't use middle click, it causes lag and keys to get stuck
            SendInput(premtool "{LButton Down}")
            if A_ThisHotkey = KSA.DragKeywait && GetKeyState(KSA.DragKeywait, "P") ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
                KeyWait(A_ThisHotkey, "T5")
            else if A_ThisHotkey != KSA.DragKeywait && GetKeyState(KSA.DragKeywait, "P")
                KeyWait(KSA.DragKeywait, "T5") ;A_ThisHotkey won't work here as the assumption is that LAlt & Xbutton2 will be pressed and ahk hates that
            SendInput("{LButton Up}")
            SendInput(toolorig)
            SetTimer(rdisable, 0)
        }
        SetTimer(again, -400)
        again()
    }

    /**
     * A function to retrieve the coordinates of the Premiere timeline. These coordinates are then stored within the `Prem {` class.
     */
    static getTimeline() {
        try {
            SendInput(KSA.timelineWindow)
            effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&x, &y, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
            this.timelineXValue := width - 22 ;accounting for the scroll bars on the right side of the timeline
            this.timelineYValue := y + 46 ;accounting for the area at the top of the timeline that you can drag to move the playhead
            this.timelineXControl := x + 238 ;accounting for the column to the left of the timeline
            this.timelineYControl := y + height + 40 ;accounting for the scroll bars at the bottom of the timeline
            SetTimer(tools, -100)
            return true
            tools() {
                tool.Wait()
                script := obj.SplitPath(A_LineFile)
                tool.Cust("prem.getTimeline() found the coordinates of the timeline.", 2.0)
                tool.Cust("This function will not check coordinates again until a script refresh.`nIf this script grabbed the wrong coordinates, refresh and try again!", 3.0,,, 30, 2)
            }
        } catch as e {
            tool.Wait()
            tool.Cust("Couldn't find the ClassNN value")
            errorLog(e)
            return false
        }
    }
}