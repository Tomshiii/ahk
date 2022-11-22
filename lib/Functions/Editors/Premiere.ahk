; { \\ #Includes
#Include <\Functions\General>
; }

class Prem {
    /**
     * This function will drag and drop any previously saved preset onto the clip you're hovering over. Your saved preset MUST be in a folder for this function to work.
     * @param {String} item in this function defines what it will type into the search box (the name of your preset within premiere)
     */
    static preset(item)
    {
        KeyWait(A_ThisHotkey)
        ToolTip("Your Preset is being dragged")
        coord.s()
        block.On()
        MouseGetPos(&xpos, &ypos)
        SendInput(effectControls) ;highlights the effect controls panel
        SendInput(effectControls) ;premiere is dumb, focus things twice
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e, A_ThisFunc "()")
            return
        }
        if item = "loremipsum" ;YOUR PRESET MUST BE CALLED "loremipsum" FOR THIS TO WORK - IF YOU WANT TO RENAME YOUR PRESET, CHANGE THIS VALUE TOO - this if statement is code specific to text presets
            {
                sleep 100
                SendInput(timelineWindow) ;focuses the timeline
                SendInput(newText) ;creates a new text layer, check the keyboard shortcuts ini file to change this
                sleep 100
                if !ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "graphics.png") ;checks for the graphics panel that opens when you select a text layer
                    {
                        block.Off()
                        tool.Cust("the graphics tab",, 1)
                        errorLog(, A_ThisFunc "()", "Couldn't find the graphics tab", A_LineFile, A_LineNumber)
                        return
                    }
                if !ImageSearch(&xeye, &yeye, x2, y2, x2 + "200", y2 + "100", "*2 " ptf.Premiere "eye.png") ;searches for the eye icon for the original text
                    {
                        block.Off()
                        tool.Cust("the eye icon",, 1)
                        errorLog(, A_ThisFunc "()", "Couldn't find the eye icon", A_LineFile, A_LineNumber)
                        return
                    }
                MouseMove(xeye, yeye)
                SendInput("{Click}")
                MouseGetPos(&eyeX, &eyeY)
                sleep 50
            }
        effectbox() ;this is simply to cut needing to repeat this code below
        {
            SendInput(effectsWindow) ;adjust this in the ini file
            SendInput(findBox) ;adjust this in the ini file
            tool.Cust("if you hear windows, blame premiere")
            CaretGetPos(&findx)
            if findx = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
                {
                    loop {
                            if A_Index > 5
                                {
                                    SendInput(findBox) ;adjust this in the ini file
                                    tool.Cust("if you hear windows, blame premiere", 2000)
                                    errorLog(, A_ThisFunc "()", "If you're looking here because you heard windows beep, it's because this function loops trying to find the search box in premiere but sometimes premiere is dumb and doesn't find it when it's supposed to, then when you send the hotkey again windows complains. Thanks Adobe.", A_LineFile, A_LineNumber)
                                }
                            sleep 30
                            CaretGetPos(&findx)
                            if A_Index > 20 ;if this loop fires 20 times and premiere still hasn't caught up, the function will cancel itself
                                {
                                    block.Off()
                                    tool.Cust("Premiere was dumb and`ncouldn't find the findbox. Try again", 3000)
                                    errorLog(, A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                    return
                                }
                        } until findx != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                }
            SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
            SendInput("^a" "+{BackSpace}")
            SetTimer(delete, -250)
            delete() ;this function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job
            {
                if WinExist("Delete Item")
                    {
                        SendInput("{Esc}")
                        sleep 100
                        SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
                        SendInput(findBox)
                        tool.Cust("if you hear windows, blame premiere", 2000)
                        CaretGetPos(&find2x)
                        if find2x = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
                            {
                                loop {
                                        sleep 30
                                        SendInput(findBox)
                                        tool.Cust("if you hear windows, blame premiere", 2000)
                                        CaretGetPos(&find2x)
                                        if A_Index > 20 ;if this loop fires 20 times and premiere still hasn't caught up, the function will cancel itself
                                            {
                                                block.Off()
                                                tool.Cust("Premiere was dumb and`ncouldn't find the findbox. Try again", 3000)
                                                errorLog(, A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                                return
                                            }
                                    } until find2x != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                            }
                        SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
                        SendInput("^a" "+{BackSpace}")
                        sleep 60
                        if WinExist("Delete Item")
                            {
                                SendInput("{Esc}")
                                sleep 50
                                tool.Cust("it tried to delete your preset", 2000)
                                errorLog(, A_ThisFunc "()", "The function attempted to delete the users preset and was aborted", A_LineFile, A_LineNumber)
                            }
                    }
            }
        }
        effectbox()
        coord.c() ;change caret coord mode to window
        CaretGetPos(&carx, &cary) ;get the position of the caret (blinking line where you type stuff)
        MouseMove carx, cary ;move to the caret (instead of defined pixel coords) to make it less prone to breaking
        SendInput item ;create a preset of any effect, must be in a folder as well
        sleep 50
        MouseMove 0, 60,, "R" ;move down to the saved preset (must be in an additional folder)
        SendInput("{Click Down}")
        if item = "loremipsum" ;set this hotkey within the Keyboard Shortcut Adjustments.ini file
            {
                MouseMove(eyeX, eyeY - "5")
                SendInput("{Click Up}")
                effectbox()
                SendInput(timelineWindow)
                MouseMove(xpos, ypos)
                block.Off()
                return
            }
        MouseMove(xpos, ypos) ;in some scenarios if the mouse moves too fast a video editing software won't realise you're dragging. if this happens to you, add ', "2" ' to the end of this mouse move
        SendInput("{Click Up}")
        effectbox() ;this will delete whatever preset it had typed into the find box
        SendInput(timelineWindow) ;this will rehighlight the timeline after deleting the text from the find box
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
        SendInput(effectsWindow)
        SendInput(effectsWindow) ;adjust this in the ini file
        SendInput(findBox) ;adjust this in the ini file
        CaretGetPos(&findx)
        if findx = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
            {
                loop 40 {
                        sleep 30
                        CaretGetPos(&findx)
                        if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
                            {
                                block.Off()
                                tool.Cust("Premiere was dumb and`ncouldn't find the findbox. Try again", 3000)
                                errorLog(, A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                return
                            }
                    } until findx != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
            }
        SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
        SendInput("^a" "+{BackSpace}")
        SetTimer(delete, -250)
        delete() ;this function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job
        {
            if WinExist("Delete Item")
                {
                    SendInput("{Esc}")
                    sleep 100
                    SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
                    SendInput(findBox)
                    CaretGetPos(&find2x)
                    if find2x = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
                        {
                            loop 40 {
                                    sleep 30
                                    CaretGetPos(&find2x)
                                    if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
                                        {
                                            block.Off()
                                            tool.Cust("Premiere was dumb and`ncouldn't find the findbox. Try again", 3000)
                                            errorLog(, A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                            return
                                        }
                                } until find2x != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                        }
                    SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
                    SendInput("^a" "+{BackSpace}")
                    sleep 60
                    if WinExist("Delete Item")
                        {
                            SendInput("{Esc}")
                            sleep 50
                            tool.Cust("it tried to delete your preset", 2000)
                            errorLog(, A_ThisFunc "()", "The function attempted to delete the users preset and was aborted", A_LineFile, A_LineNumber)
                        }
                }
        }
        block.Off()
    }

    /**
     * This function is to simply cut down repeated code on my numpad punch in scripts. it punches the video into my preset values for highlight videos
     * @param {Integer} xval is the pixel value you want this function to paste into the X coord text field in premiere
     * @param {Integer} yval is the pixel value you want this function to paste into the y coord text field in premiere
     * @param {Integer} scale is the scale value you want this function to paste into the scale text field in premiere
     */
    static num(xval, yval, scale)
    {
        KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
        MouseGetPos(&xpos, &ypos)
        coord.s()
        block.On()
        SendInput(effectControls)
        SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e, A_ThisFunc "()")
            return
        }
        SendInput(timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        tool.Cust("The wrong clips are selected")
                        errorLog(, A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                        block.Off()
                        return
                    }
            }
        SendInput(timelineWindow) ;adjust this in the ini file
        SendInput(labelRed) ;changes the track colour so I know that the clip has been zoomed in
        if !ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "video.png") ;moves to the "video" section of the effects control window tab
            {
                MouseMove(xpos, ypos)
                block.Off()
                tool.Cust("the video section",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(, A_ThisFunc "()", "Couldn't find the video section", A_LineFile, A_LineNumber)
                return
            }
        if !ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "motion2.png") && !ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "motion3.png") ;moves to the motion tab
            {
                MouseMove(xpos, ypos) ;moves back to the original coords
                block.Off()
                tool.Cust("the motion tab",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(, A_ThisFunc "()", "Couldn't find the motion tab", A_LineFile, A_LineNumber)
                return
            }
        MouseMove(x2 + "10", y2 + "10")
        SendInput("{Click}")
        SendInput("{Tab 2}" xval "{Tab}" yval "{Tab}" scale "{ENTER}")
        SendInput("{Enter}")
        MouseMove(xpos, ypos)
        block.Off()
    }

    /**
     * This function on first run will ask you to select a clip with the exact zoom you wish to use for the current session. Any subsequent activations of the script will simply zoom the current clip to that zoom amount. You can reset this zoom by refreshing the script.
     *
     * If a specified client name is in the title of the window (usually in the url project path) this function will set predefined zooms
     */
    static zoom()
    {
        reset() { ;this function is for a timer we activate anytime a clients zoom has a toggle
            tool.Cust("zoom toggles reset",,, A_ScreenWidth*0.945, A_ScreenHeight*0.3575, 2) ;this just puts the tooltip in a certain empty spot on my screen, feel free to adjust
            alexTog := 0
            chloeTog := 0
        }

        ;we'll put all our values at the top so they can be easily changed. First value is your X coord, second value is your Y coord, third value is your Scale value
        ;alex
        alexXYS := [2064, -26, 215]
        alexZoomXYS := [3467, 339, 390]

        ;d0yle ;orig => [-57, -37, 210]
        d0yleXYS := [-78, -53, 210]

        ;chloe
        chloeXYS := [-426, -238, 267]
        chloeZoomXYS := [-1679, -854, 486]
        chloetemp := [632, 278, 292]

        ;then we'll define the values that will allow us to change things depending on the project
        static x := 0
        static y := 0
        static scale := 0
        static alexTog := 0
        static chloeTog := 0

        KeyWait(A_ThisHotkey)
        coord.s()
        MouseGetPos(&xpos, &ypos)
        block.On()
        WinActivate(editors.winTitle["premiere"])
        sleep 50
        SendInput(effectControls)
        SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
        sleep 50
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e, A_ThisFunc "()")
            return
        }
        ;get title
        premCheck := WinGetTitle(editors.class["premiere"])

        ;any zooms with NO toggle
        d0yle := InStr(premCheck, "d0yle")
        if d0yle != 0
            {
                x := d0yleXYS[1]
                y := d0yleXYS[2]
                scale := d0yleXYS[3]
            }

        ;any zooms WITH a toggle
        chloe := InStr(premCheck, "chloe")
        if chloe != 0
            {
                SetTimer(reset, -10000) ;reset toggle values after x seconds
                tool.Cust("zoom " chloeTog+1 "/3")
                if chloeTog = 0
                    {
                        x := chloeXYS[1]
                        y := chloeXYS[2]
                        scale := chloeXYS[3]
                    }
                if chloeTog = 1
                    {
                        x := chloeZoomXYS[1]
                        y := chloeZoomXYS[2]
                        scale := chloeZoomXYS[3]
                    }
                if chloeTog = 2
                    {
                        x := chloetemp[1]
                        y := chloetemp[2]
                        scale := chloetemp[3]
                    }
                chloeTog += 1
                if chloeTog > 2
                    chloeTog := 0
                goto endPeople
            }
        alex := InStr(premCheck, "alex")
        if alex != 0
            {
                SetTimer(reset, -10000) ;reset toggle values after x seconds
                tool.Cust("zoom " alexTog+1 "/2")
                if alexTog = 0
                    {
                        x := alexXYS[1]
                        y := alexXYS[2]
                        scale := alexXYS[3]
                    }
                if alexTog = 1
                    {
                        x := alexZoomXYS[1]
                        y := alexZoomXYS[2]
                        scale := alexZoomXYS[3]
                    }
                alexTog += 1
                if alexTog > 1
                    alexTog := 0
                goto endPeople
            }
        /* dangers := InStr(premCheck, "dangers") ;dangers is a video by video basis
        if dangers != 0
            {
                x := 1
                y := 1
                scale := 1
            } */
        endPeople:
        if scale = 0
            {
                block.Off()
                setValue := MsgBox("You haven't set the zoom amount/position for this session yet.`nIs the current track your desired zoom?", "Set Zoom", "4 32 4096")
                if setValue = "No"
                    return
            }
        SendInput(timelineWindow)
        if ImageSearch(&clipX, &clipY, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&clipX, &clipY, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        tool.Cust("The wrong clips are selected")
                        errorLog(, A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                        block.Off()
                        return
                    }
            }
        if !ImageSearch(&motionX, &motionY, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "motion2.png") && !ImageSearch(&motionX, &motionY, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "motion3.png")
            {
                MouseMove(xpos, ypos)
                block.Off()
                tool.Cust("the video section",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(, A_ThisFunc "()", "Couldn't find the video section", A_LineFile, A_LineNumber)
                return
            }
        MouseMove(motionX + "10", motionY + "10")
        SendInput("{Click}")
        MouseMove(xpos, ypos)
        SendInput("{Tab 2}")
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
                block.Off()
                SendInput("{Enter}")
                tool.Cust("Setting up your zoom has completed")
                return
            }
        else
            {
                SendInput(x)
                SendInput("{Tab}")
                SendInput(y)
                SendInput("{Tab}")
                SendInput(scale)
                SendInput("{Enter}")
                block.Off()
                return
            }
    }

    /**
     * A function to warp to one of a videos values (scale , x/y, rotation, etc) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
     * @param {String} filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
     * @param {Integer} optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
     */
    static valuehold(filepath, optional := 0)
    {
        ;This function will only operate correctly if the space between the x value and y value is about 210 pixels away from the left most edge of the "timer" (the icon left of the value name)
        ;I use to have it try to function irrespective of the size of your panel but it proved to be inconsistent and too unreliable.
        ;You can plug your own x distance in by changing the value below
        xdist := 210
        coord.s()
        MouseGetPos(&xpos, &ypos)
        ;tool.Cust("x " xpos "`ny " ypos) ;testing stuff
        block.On()
        SendInput(effectControls)
        SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e, A_ThisFunc "()")
            return
        }
        SendInput(timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            { ;any imagesearches on the effect controls window includes a division variable (ECDivide) as I have my effect controls quite wide and there's no point in searching the entire width as it slows down the script
                SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        tool.Cust("The wrong clips are selected")
                        errorLog(, A_ThisFunc "()", "The wrong clips are selected", A_LineFile, A_LineNumber)
                        block.Off()
                        return
                    }
            }
        if filepath = "levels" ;THIS IS FOR ADJUSTING THE "LEVEL" PROPERTY, YOUR PNG MUST BE CALLED "levels.png"
            { ;don't add WheelDown's, they suck in hotkeys, idk why, they lag everything out and stop Click's from working
                if ImageSearch(&vidx, &vidy, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "video.png")
                    {
                        tool.Cust("you aren't scrolled down")
                        errorLog(, A_ThisFunc "()", "The user wasn't scrolled down", A_LineFile, A_LineNumber)
                        block.Off()
                        KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                        return
                    }
            }
        loop {
            if A_Index > 1
                {
                    ToolTip(A_Index)
                    SendInput(effectControls)
                    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
                    try {
                        ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
                        ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
                    } catch as e {
                        tool.Cust("Couldn't get the ClassNN of the Effects Controls panel")
                        errorLog(e, A_ThisFunc "()")
                        MouseMove(xpos, ypos)
                        return
                    }
                }
            if ( ;finds the value you want to adjust, then finds the value adjustment to the right of it
                    ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath ".png") ||
                    ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath "2.png") ||
                    ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath "3.png") ||
                    ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath "4.png")
            )
                break
            if A_Index > 3
                {
                    block.Off()
                    tool.Cust("the image after " A_Index " attempts`nx " classX "`ny " classY "`nwidth " width "`nheight " height, 5000, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                    errorLog(, A_ThisFunc "()", "Failed to find the appropiate image after " A_Index " attempts ~~ x " classX " ~~ y " classY " ~~ width " width " ~~ height " height, A_LineFile, A_LineNumber)
                    KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                    MouseMove(xpos, ypos)
                    return
                }
            sleep 50
        }
        colour:
        if !PixelSearch(&xcol, &ycol, x, y, x + xdist, y + "40", 0x205cce, 2)
            {
                block.Off()
                tool.Cust("the blue text",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(, A_ThisFunc "()", "Failed to find the blue 'value' text", A_LineFile, A_LineNumber)
                KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
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
                KeyWait(A_ThisHotkey)
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
                        tool.Cust("the reset button",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                        errorLog(, A_ThisFunc "()", "Failed to find reset button", A_LineFile, A_LineNumber)
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
        SendInput(effectControls)
        SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e, A_ThisFunc "()")
            return
        }
        SendInput(timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        tool.Cust("The wrong clips are selected")
                        errorLog(, A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                        block.Off()
                        return
                    }
            }
        if !ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath "2.png") && !ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath "4.png")
            {
                tool.Cust("you're already keyframing")
                errorLog(, A_ThisFunc "()", "The user was already keyframing", A_LineFile, A_LineNumber)
                block.Off()
                ;KeyWait(A_PriorHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
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
        SendInput(effectControls)
        SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e, A_ThisFunc "()")
            return
        }
        SendInput(timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        tool.Cust("The wrong clips are selected")
                        errorLog(, A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                        block.Off()
                        return
                    }
            }
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath "2.png") || ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath "4.png")
                goto next
        else if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath ".png") || ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere filepath "3.png")
            {
                MouseMove(x + "5", y + "5")
                Click()
                goto end
            }
        else
            {
                tool.Cust("Couldn't find the desired value")
                errorLog(, A_ThisFunc "()", "Couldn't find the desired value", A_LineFile, A_LineNumber)
                block.Off()
                return
            }
        next:
        if ImageSearch(&keyx, &keyy, x, y, x + "500", y + "20", "*2 " ptf.Premiere "keyframeButton.png") || ImageSearch(&keyx, &keyy, x, y, x + "500", y + "20", "*2 " ptf.Premiere "keyframeButton2.png")
            MouseMove(keyx + "3", keyy)
        Click()
        end:
        SendInput(timelineWindow) ;focuses the timeline
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
        ;I wanted to use a method similar to other premiere functions above, that grabs the classNN value of the panel to do all imagesearches that way instead of needing to define coords, but because I'm using a separate bin which is essentially just a second project window, things get messy, premiere gets slow, and the performance of this function dropped drastically so for this one we're going to stick with coords defined in KSA.ini/ahk
        coord.s()
        SendInput(selectionPrem)
        if !ImageSearch(&sfxxx, &sfxyy, 3021, 664, 3589, 1261, "*2 " ptf.Premiere "binsfx.png") ;checks to make sure you have the sfx bin open as a separate project window
            {
                tool.Cust("you haven't opened the bin", 2000)
                errorLog(, A_ThisFunc "()", "User hasn't opened the required bin", A_LineFile, A_LineNumber)
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
            SendInput(projectsWindow) ;highlights the project window ~ check the keyboard shortcut ini file to adjust hotkeys
            SendInput(projectsWindow) ;highlights the sfx bin that I have ~ check the keyboard shortcut ini file to adjust hotkeys
            ;KeyWait(A_PriorKey) ;I have this set to remapped mouse buttons which instantly "fire" when pressed so can cause errors
            SendInput(findBox)
            CaretGetPos(&findx)
            if findx = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
                {
                    loop 40 {
                            sleep 30
                            CaretGetPos(&findx)
                            if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
                                {
                                    block.Off()
                                    tool.Cust("Premiere was dumb and`ncouldn't find the findbox. Try again", 3000)
                                    errorLog(, A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                    return
                                }
                        } until findx != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                }
            SendInput("^a" "+{BackSpace}")
            SendInput(sfxName)
            sleep 250 ;the project search is pretty slow so you might need to adjust this
            coord.w()
            if !ImageSearch(&vlx, &vly, sfxX1, sfxY1, sfxX2, sfxY2, "*2 " ptf.Premiere "audio.png") && !ImageSearch(&vlx, &vly, sfxX1, sfxY1, sfxX2, sfxY2, "*2 " ptf.Premiere "audio2.png") ;searches for the audio image next to an audio file
                {
                    block.Off()
                    tool.Cust("audio image", 2000, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                    errorLog(, A_ThisFunc "()", "Couldn't find the audio image", A_LineFile, A_LineNumber)
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
            SendInput(timelineWindow)
            ;MouseMove(30,0,, "R")
            sleep 50
            ;MouseGetPos(&colourX, &colourY)
            colour := PixelGetColor(xpos + 10, ypos)
            if (
                colour = 0x156B4C || colour = 0x1B8D64 || colour = 0x1c7d5a|| colour = 0x1D7E5B || colour = 0x1D986C || colour = 0x1E7F5C || colour = 0x1F805D || colour = 0x1FA072 || colour = 0x1FA373 || colour = 0x20815E || colour = 0x21825F || colour = 0x23AB83 || colour = 0x248562 || colour = 0x258663 || colour = 0x268764 || colour = 0x298A67 || colour = 0x29D698 || colour = 0x2A8B68 || colour = 0x2A8D87 || colour = 0x2B8C69 || colour = 0x3A9B78 || colour = 0x3DFFE4 || colour = 0x44A582 || colour = 0x457855 || colour = 0x47A582 || colour = 0x4AAB88 || colour = 0x5C67F9 || colour = 0x5D68FB || colour = 0x5D68FC || colour = 0xD0E1DB || colour = 0xD4F7EA || colour = 0xFDFDFD || colour = 0xFEFEFE || colour = 0xFFFFFF  || colour - 0x3AAA59 ||
                ;there needs to be a trailing || for any block that isn't the final

                colour = 0xE40000 || colour = 0xEEE1E1  || ;colours for the red box

                colour = 0x292929 || colour = 0x2D2D2D || colour = 0x3B3B3B || colour = 0x404040 || colour = 0x454545 || colour = 0x4A4A4A || colour = 0x585858 || colour = 0x606060 || colour = 0x646464 || colour = 0xA7ADAB || colour = 0xB1B1B1 || colour = 0xCCCCCC|| colour = 0xD2D2D2 || colour = 0xEFEFEF  ;colours for the fx symbol box
            )
                break
            errorLog(, A_ThisFunc "()", "Couldn't drag the file to the timeline because colour was " colour " A_Index was: " A_Index, A_LineFile, A_LineNumber)
            if A_Index > 2
                {
                    block.Off()
                    tool.Cust("Couldn't drag the file to the timeline`ncolour was " colour)
                    return
                }
        }
        block.Off()
        if sfxName = "bleep"
            {
                sleep 50
                SendInput(selectionPrem)
                MouseGetPos(&delx, &dely)
                MouseMove(10, 0,, "R")
                sleep 50
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
                SendInput("{Click}")
                sleep 50
                SendInput(gainAdjust)
                SendInput("-20")
                SendInput("{Enter}")
                WinWaitClose("Audio Gain")
                MouseMove(xpos, ypos)
                trackNumber := 2
                sleep 100
                SendInput(cutPrem)
                start := A_TickCount
                sec := 0
                loop {
                    ;check to see if the user wants the bleep on a track between 1-9
                    getlastHotkey := A_PriorKey
                    if getlastHotkey = ""
                        goto skip
                    if IsDigit(getlastHotkey) ;checks to see if the last pressed key is a number between 1-9
                        trackNumber := getlastHotkey
                    skip:
                    sleep 50
                    if A_Index > 160 ;built in timeout
                        {
                            block.Off()
                            tool.Cust(A_ThisFunc " timed out due to no user interaction", 2000)
                            errorLog(, A_ThisFunc "()", "timed out due to no user interaction", A_LineFile, A_LineNumber)
                            return
                        }
                    if ((A_TickCount - start) >= 1000)
                        {
                            start += 1000
                            sec += 1
                        }
                    secRemain := 8 - sec
                    ToolTip("This function will attempt to drag your bleep to:`n" A_Tab A_Tab "Track " trackNumber "`n`nPress another number key to move to a different track`nThe function will continue once you've cut the track`n" secRemain "s remaining")
                } until GetKeyState("LButton", "P")
                ToolTip("")
                block.On()
                sleep 50
                SendInput(selectionPrem)
                MouseGetPos(&delx, &dely)
                MouseMove(xpos + 10, ypos)
                sleep 500
                SendInput("{Click Down}")
                MouseGetPos(&refx, &refy)
                if !ImageSearch(&trackX, &trackY, 0, 0, 200, A_ScreenHeight, "*2 " ptf.Premiere "track " trackNumber "_1.png") && !ImageSearch(&trackX, &trackY, 0, 0, 200, A_ScreenHeight, "*2 " ptf.Premiere "track " trackNumber "_2.png")
                    {
                        block.Off()
                        tool.Cust("Couldn't determine the Y value of desired track")
                        errorLog(, A_ThisFunc "()", "Couldn't determine the Y value of desired track", A_LineFile, A_LineNumber)
                        return
                    }
                MouseMove(refx, trackY, 2)
                SendInput("{Click Up}")
                sleep 50
                MouseMove(delx + 10, dely, 2)
                sleep 200
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
                SendInput("{Click}")
                SendInput("{BackSpace}")
                MouseMove(xpos + 10, ypos)
                Sleep(25)
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
        SendInput(timelineWindow) ;focuses the timeline
        SendInput(direction) ;Set these shortcuts in the keyboards shortcut ini file
        KeyWait(A_ThisHotkey) ;prevents hotkey spam
    }

    /**
     * This function is to adjust the framing of a video within the preview window in premiere pro. Let go of this hotkey to confirm, simply tap this hotkey to reset values
     */
    static movepreview()
    {
        coord.s()
        block.On()
        MouseGetPos(&xpos, &ypos)
        SendInput(effectControls)
        SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            tool.Cust("Couldn't find the ClassNN value")
            errorLog(e, A_ThisFunc "()")
        }
        SendInput(timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        tool.Cust("The wrong clips are selected")
                        errorLog(, A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                        block.Off()
                        return
                    }
            }
        loop {
            if A_Index > 1
                {
                    ToolTip(A_Index)
                    SendInput(effectControls)
                    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
                    try {
                        ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
                        ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
                    } catch as e {
                        tool.Cust("Couldn't get the ClassNN of the Effects Controls panel")
                        errorLog(e, A_ThisFunc "()")
                        MouseMove(xpos, ypos)
                        return
                    }
                }
            if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "motion.png") ;moves to the motion tab
                    {
                        MouseMove(x + "25", y)
                        break
                    }
            if A_Index > 3
                {
                    block.Off()
                    tool.Cust("the image after " A_Index " attempts`nx " classX "`ny " classY "`nwidth " width "`nheight " height, 5000, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                    errorLog(, A_ThisFunc "()", "Failed to find the appropiate image after " A_Index " attempts ~~ x " classX " ~~ y " classY " ~~ width " width " ~~ height " height, A_LineFile, A_LineNumber)
                    KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                    MouseMove(xpos, ypos)
                    return
                }
            sleep 50
        }
        sleep 50
        if GetKeyState(A_ThisHotkey, "P") ;gets the state of the hotkey, enough time now has passed that if I just press the button, I can assume I want to reset the paramater instead of edit it
            { ;you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable to move the preview window
                Click
                MouseMove(moveX, moveY) ;move to the preview window
                loop {
                    MouseGetPos(&colX, &colY)
                    if PixelGetColor(colX, colY) != 0x000000
                        break
                    if A_Index = 1
                        MouseMove(moveX + 100, moveY + 200)
                    if A_Index = 2
                        MouseMove(moveX - 200, moveY + 200)
                    if A_Index = 3
                        MouseMove(moveX - 200, moveY - 50)
                    if A_Index = 4
                        MouseMove(moveX + 100, moveY - 50)
                    if A_Index > 4
                        {
                            MouseMove(moveX, moveY)
                            block.Off()
                            tool.Cust(A_ThisFunc " couldn't find your video or it kept finding pure black at each coordinate", 2000)
                            errorLog(, A_ThisFunc "()", "Couldn't find your video or it kept finding pure black at each coordinate", A_LineFile, A_LineNumber)
                            break
                        }
                }
                SendInput("{Click Down}")
                sleep 50
                block.Off()
                KeyWait(A_ThisHotkey)
                SendInput("{Click Up}")
                ;MouseMove(xpos, ypos) ; // moving the mouse position back to origin after doing this is incredibly disorienting
            }
        else
            {
                if !ImageSearch(&xcol, &ycol, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "reset.png")
                    {
                        block.Off()
                        MouseMove(xpos, ypos)
                        tool.Cust("the reset button",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                        errorLog(, A_ThisFunc "()", "Couldn't find the reset button", A_LineFile, A_LineNumber)
                        return
                    }
                MouseMove(xcol, ycol)
                Click
                sleep 50
                MouseMove(xpos, ypos)
                block.Off()
            }
        ToolTip("")
    }

    /**
     * This function moves the cursor to the reset button to reset the "motion" effects
     */
    static reset()
    {
        KeyWait(A_ThisHotkey)
        coord.s()
        block.On()
        SendInput(effectControls)
        SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e, A_ThisFunc "()")
            return
        }
        SendInput(timelineWindow) ;focuses the timeline
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        tool.Cust("The wrong clips are selected")
                        errorLog(, A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                        block.Off()
                        return
                    }
            }
        MouseGetPos(&xpos, &ypos)
        loop {
            if ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "motion2.png") || ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "motion3.png") ;checks if the "motion" value is in view
                break
            if A_Index > 5
                {
                    block.Off()
                    tool.Cust("the motion value",, 1)
                    errorLog(, A_ThisFunc "()", "Couldn't find the motion image", A_LineFile, A_LineNumber)
                    return
                }
        }
        SendInput(timelineWindow) ;~ check the keyboard shortcut ini file to adjust hotkeys
        if ImageSearch(&xcol, &ycol, x2, y2 - "20", x2 + "700", y2 + "20", "*2 " ptf.Premiere "reset.png") ;this will look for the reset button directly next to the "motion" value
            MouseMove(xcol, ycol)
        click
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
        SendInput(effectControls)
        SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
        try {
            ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
            ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
        } catch as e {
            block.Off() ;just incase
            tool.Cust("Couldn't get the ClassNN of the desired panel")
            errorLog(e, A_ThisFunc "()")
            return
        }
        SendInput(timelineWindow)
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        tool.Cust("The wrong clips are selected")
                        errorLog(, A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                        block.Off()
                        return
                    }
            }
        if ( ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
            !ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere property ".png") &&
            !ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere property "2.png") &&
            !ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere property "3.png") &&
            !ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere property "4.png")
        )
            {
                block.Off()
                tool.Cust("the property you wish to adjust",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(, A_ThisFunc "()", "Couldn't find the users requested property", A_LineFile, A_LineNumber)
                return
            }
        if !PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x205cce, 2) ;searches for the blue text to the right of the scale value
            {
                block.Off()
                tool.Cust("the blue text",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(, A_ThisFunc "()", "Failed to find the blue 'value' text", A_LineFile, A_LineNumber)
                return
            }
        MouseMove(xcol + optional, ycol)
        keywait(waitHotkey)
        SendInput("{Click}")
        ToolTip("manInput() is waiting for the " "'" manInputEnd "'" "`nkey to be pressed")
        KeyWait(manInputEnd, "D") ;waits until the final hotkey is pressed before continuing
        ToolTip("")
        SendInput("{Enter}")
        MouseMove(xpos, ypos)
        Click("middle")
        block.Off()
    }

    /**
     * This function is to increase/decrease gain within premiere pro. This function will check to ensure the timeline is in focus and a clip is selected
     * @param {Integer} amount is the value you want the gain to adjust (eg. -2, 6, etc)
     */
    static gain(amount)
    {
        if !IsNumber(amount)
            {
                tool.Cust("You have put a non numeric value as this function's parameter", 2.0)
                errorLog(, A_ThisFunc "()", "User put a non numeric value in function's parameter", A_LineFile, A_LineNumber)
                return
            }
        KeyWait(A_ThisHotkey)
        Critical
        ToolTip("Adjusting Gain")
        BlockInput(1)
        coord.s()
        ClassNN := ""
        start:
        try {
            loop {
                SendInput(effectControls)
                SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
                getTitle(&check)
                if check = "Audio Gain"
                    {
                        SendInput(amount "{Enter}")
                        ToolTip("")
                        block.Off()
                        return
                    }
                try {
                    ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
                    ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
                } catch as e {
                    block.Off() ;just incase
                    tool.Cust("Couldn't get the ClassNN of the desired panel")
                    errorLog(e, A_ThisFunc "()")
                    return
                }
                if ClassNN != "DroverLord - Window Class3" || ClassNN != "DroverLord - Window Class1"
                    break
                sleep 30
            }
        }
        if ClassNN = ""
            goto start
        /* if ClassNN = "DroverLord - Window Class3"
            goto start */
            SendInput(timelineWindow)
            try {
                if ImageSearch(&x3, &y3, classX, classY, classX + (width/ECDivide), classY + height, "*2 " ptf.Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
                    {
                        SendInput(timelineWindow selectAtPlayhead) ;~ check the keyboard shortcut ini file to adjust hotkeys
                        goto inputs
                    }
                /* else
                    {
                    classNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
                        if classNN = "DroverLord - Window Class3"
                            goto inputs
                        else
                            {
                                block.Off()
                                tool.Cust("gain macro couldn't figure`nout what to do")
                                errorLog(, A_ThisFunc "()", "Function was unable to determine how to proceed", A_LineFile, A_LineNumber)
                                return
                            }
                    }*/
            } catch as e {
                ToolTip("")
                block.Off()
                tool.Cust("ClassNN wasn't given a value")
                errorLog(e, A_ThisFunc "()")
                return
            }
            inputs:
            SendInput("g")
            WinWait("Audio Gain")
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
        MouseGetPos(&x, &y) ;from here down to the begining of again() is checking for the width of your timeline and then ensuring this function doesn't fire if your mouse position is beyond that, this is to stop the function from firing while you're hoving over other elements of premiere causing you to drag them across your screen
        static xValue := 0
        static yValue := 0
        static xControl := 0
        static yControl := 0
        if xValue = 0 || yValue = 0 || xControl = 0 || yControl = 0
            {
                try {
                    SendInput(timelineWindow)
                    effClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
                    ControlGetPos(&xpos, &ypos, &width, &height, effClassNN) ;gets the x/y value and width/height of the active panel
                    static xValue := width - 22 ;accounting for the scroll bars on the right side of the timeline
                    static yValue := ypos + 46 ;accounting for the area at the top of the timeline that you can drag to move the playhead
                    static xControl := xpos + 238 ;accounting for the column to the left of the timeline
                    static yControl := height + 40 ;accounting for the scroll bars at the bottom of the timeline
                    tool.Wait()
                    tool.Cust(A_ThisFunc "() found the coordinates of the timeline.`nThis function will not check coordinates again until a script refresh")
                } catch as e {
                    tool.Wait()
                    tool.Cust("Couldn't find the ClassNN value")
                    errorLog(e, A_ThisFunc "()")
                    goto skip
                }
            }
        if x > xValue || x < xControl || y < yValue || y > yControl ;this line of code ensures that the function does not fire if the mouse is outside the bounds of the timeline. This code should work regardless of where you have the timeline (if you make you're timeline comically small you may encounter issues)
            return
        skip:
        again()
        {
            if A_ThisHotkey = DragKeywait ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
                {
                    if !GetKeyState(A_ThisHotkey, "P") ;this is here so it doesn't reactivate if you quickly let go before the timer comes back around
                        return
                }
            else if !GetKeyState(DragKeywait, "P")
                return
            click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
            SendInput(premtool "{LButton Down}")
            if A_ThisHotkey = DragKeywait ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
                KeyWait(A_ThisHotkey)
            else
                KeyWait(DragKeywait) ;A_ThisHotkey won't work here as the assumption is that LAlt & Xbutton2 will be pressed and ahk hates that
            SendInput("{LButton Up}")
            SendInput(toolorig)
        }
        SetTimer(again, -400)
        again()
    }
}