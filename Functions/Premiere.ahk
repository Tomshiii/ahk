;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.13.3
#Include General.ahk

/* preset()
 This function will drag and drop any previously saved preset onto the clip you're hovering over. Your saved preset MUST be in a folder for this function to work.
 @param item in this function defines what it will type into the search box (the name of your preset within premiere)
 */
preset(item)
{
    KeyWait(A_ThisHotkey)
    ToolTip("Your Preset is being dragged")
    coords()
    blockOn()
    MouseGetPos(&xpos, &ypos)
    SendInput(effectControls) ;highlights the effect controls panel
    SendInput(effectControls) ;premiere is dumb, focus things twice
    getClassNN(&ClassNN, &classX, &classY, &width, &height)
    if item = "loremipsum" ;YOUR PRESET MUST BE CALLED "loremipsum" FOR THIS TO WORK - IF YOU WANT TO RENAME YOUR PRESET, CHANGE THIS VALUE TOO - this if statement is code specific to text presets
        {
            sleep 100
            SendInput(timelineWindow) ;focuses the timeline
            SendInput(newText) ;creates a new text layer, check the keyboard shortcuts ini file to change this
            sleep 100
            if ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "graphics.png") ;checks for the graphics panel that opens when you select a text layer
                {
                    if ImageSearch(&xeye, &yeye, x2, y2, x2 + "200", y2 + "100", "*2 " Premiere "eye.png") ;searches for the eye icon for the original text
                        {
                            MouseMove(xeye, yeye)
                            SendInput("{Click}")
                            MouseGetPos(&eyeX, &eyeY)
                            sleep 50
                        }
                    else
                        {
                            blockOff()
                            toolFind("the eye icon", "1000")
                            errorLog(A_ThisFunc "()", "Couldn't find the eye icon", A_LineFile, A_LineNumber)
                            return
                        }
                }
            else
                {
                    blockOff()
                    toolFind("the graphics tab", "1000")
                    errorLog(A_ThisFunc "()", "Couldn't find the graphics tab", A_LineFile, A_LineNumber)
                    return
                }
        }
    effectbox() ;this is simply to cut needing to repeat this code below
    {
        SendInput(effectsWindow) ;adjust this in the ini file
        SendInput(findBox) ;adjust this in the ini file
        toolCust("if you hear windows, blame premiere", "1000")
        CaretGetPos(&findx)
        if findx = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
            {
                Loop {
                        if A_Index > 5
                            {
                                SendInput(findBox) ;adjust this in the ini file
                                toolCust("if you hear windows, blame premiere", "2000")
                                errorLog(A_ThisFunc "()", "If you're looking here because you heard windows beep, it's because this function loops trying to find the search box in premiere but sometimes premiere is dumb and doesn't find it when it's supposed to, then when you send the hotkey again windows complains. Thanks Adobe.", A_LineFile, A_LineNumber)
                            }
                        sleep 30
                        CaretGetPos(&findx)
                        if findx != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                            break
                        if A_Index > 20 ;if this loop fires 20 times and premiere still hasn't caught up, the function will cancel itself
                            {
                                blockOff()
                                toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
                                errorLog(A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                return
                            }
                    }
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
                    toolCust("if you hear windows, blame premiere", "2000")
                    CaretGetPos(&find2x)
                    if find2x = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
                        {
                            Loop {
                                    sleep 30
                                    SendInput(findBox)
                                    toolCust("if you hear windows, blame premiere", "2000")
                                    CaretGetPos(&find2x)
                                    if find2x != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                                        break
                                    if A_Index > 20 ;if this loop fires 20 times and premiere still hasn't caught up, the function will cancel itself
                                        {
                                            blockOff()
                                            toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
                                            errorLog(A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                            return
                                        }
                                }
                        }
                    SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
                    SendInput("^a" "+{BackSpace}")
                    sleep 60
                    if WinExist("Delete Item")
                        {
                            SendInput("{Esc}")
                            sleep 50
                            toolCust("it tried to delete your preset", "2000")
                            errorLog(A_ThisFunc "()", "The function attempted to delete the users preset and was aborted", A_LineFile, A_LineNumber)
                        }
                }
        }
    }
    effectbox()
    coordc() ;change caret coord mode to window
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
            blockOff()
            return
        }
    MouseMove(xpos, ypos) ;in some scenarios if the mouse moves too fast a video editing software won't realise you're dragging. if this happens to you, add ', "2" ' to the end of this mouse move
    SendInput("{Click Up}")
    effectbox() ;this will delete whatever preset it had typed into the find box
    SendInput(timelineWindow) ;this will rehighlight the timeline after deleting the text from the find box
    blockOff()
    ToolTip("")
}

/*
 This function is to move to the effects window and highlight the search box to allow manual typing
 */
fxSearch()
{
    coords()
    blockOn()
    SendInput(effectsWindow)
    SendInput(effectsWindow) ;adjust this in the ini file
    SendInput(findBox) ;adjust this in the ini file
    CaretGetPos(&findx)
    if findx = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
        {
            Loop 40
                {
                    sleep 30
                    CaretGetPos(&findx)
                    if findx != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                        break
                    if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
                        {
                            blockOff()
                            toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
                            errorLog(A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                            return
                        }
                }
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
                        Loop 40
                            {
                                sleep 30
                                CaretGetPos(&find2x)
                                if find2x != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                                    break
                                if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
                                    {
                                        blockOff()
                                        toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
                                        errorLog(A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                        return
                                    }
                            }
                    }
                SendInput(effectsWindow) ;adjust this in the ini file ;second attempt to stop ahk deleting all clips on the timeline
                SendInput("^a" "+{BackSpace}")
                sleep 60
                if WinExist("Delete Item")
                    {
                        SendInput("{Esc}")
                        sleep 50
                        toolCust("it tried to delete your preset", "2000")
                        errorLog(A_ThisFunc "()", "The function attempted to delete the users preset and was aborted", A_LineFile, A_LineNumber)
                    }
            }
    }
    blockOff()
}

/* num()
 this function is to simply cut down repeated code on my numpad punch in scripts. it punches the video into my preset values for highlight videos
 @param xval is the pixel value you want this function to paste into the X coord text field in premiere
 @param yval is the pixel value you want this function to paste into the y coord text field in premiere
 @param scale is the scale value you want this function to paste into the scale text field in premiere
 */
num(xval, yval, scale)
{
    KeyWait(A_PriorHotkey) ;you can use A_PriorHotKey when you're using 1 button to activate a macro
    MouseGetPos(&xpos, &ypos)
    coords()
    blockOn()
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    getClassNN(&ClassNN, &classX, &classY, &width, &height)
    SendInput(timelineWindow) ;focuses the timeline
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
        {
            SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    toolCust("The wrong clips are selected", "1000")
                    errorLog(A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                    blockOff()
                    return
                }
        }
    SendInput(timelineWindow) ;adjust this in the ini file
    SendInput(labelRed) ;changes the track colour so I know that the clip has been zoomed in
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "video.png") ;moves to the "video" section of the effects control window tab
        goto next
    else
        {
            MouseMove(xpos, ypos)
            blockOff()
            toolFind("the video section", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Couldn't find the video section", A_LineFile, A_LineNumber)
            return
        }
    next:
    if ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "motion2.png") || (&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "motion3.png") ;moves to the motion tab
        MouseMove(x2 + "10", y2 + "10")
    else ;if everything fails, this else will trigger
        {
            MouseMove(xpos, ypos) ;moves back to the original coords
            blockOff()
            toolFind("the motion tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Couldn't find the motion tab", A_LineFile, A_LineNumber)
            return
        }
    SendInput("{Click}")
    SendInput("{Tab 2}" xval "{Tab}" yval "{Tab}" scale "{ENTER}")
    SendInput("{Enter}")
    MouseMove(xpos, ypos)
    blockOff()
}

/*
 This function on first run will ask you to select a clip with the exact zoom you wish to use for the current session. Any subsequent activations of the script will simply zoom the current clip to that zoom amount. You can reset this zoom by refreshing the script
 */
zoom()
{
    static x := 0
    static y := 0
    static scale := 0
    static alexTog := 0
    KeyWait(A_ThisHotkey)
    coords()
    MouseGetPos(&xpos, &ypos)
    blockOn()
    WinActivate("ahk_exe Adobe Premiere Pro.exe")
    sleep 50
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    sleep 50
    getClassNN(&ClassNN, &classX, &classY, &width, &height)

    premCheck := WinGetTitle("ahk_class Premiere Pro")
    d0yle := InStr(premCheck, "d0yle")
    if d0yle != 0
        {
            x := -57
            y := -37
            scale := 210
        }
    alex := InStr(premCheck, "alex")
    if alex != 0
        {
            if alexTog = 0
                {
                    x := 3467
                    y := 339
                    scale := 390
                    alexTog += 1
                    goto endPeople
                }
            if alexTog = 1
                {
                    x := 2037
                    y := 430
                    scale := 215
                    alexTog -= 1
                    goto endPeople
                }
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
            blockOff()
            setValue := MsgBox("You haven't set the zoom amount/position for this session yet.`nIs the current track your desired zoom?", "Set Zoom", "4 32 4096")
            if setValue = "No"
                return
        }     
    SendInput(timelineWindow)
    if ImageSearch(&clipX, &clipY, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
        {
            SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&clipX, &clipY, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    toolCust("The wrong clips are selected", "1000")
                    errorLog(A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                    blockOff()
                    return
                }
        }
    if ImageSearch(&motionX, &motionY, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "motion2.png") || ImageSearch(&motionX, &motionY, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "\motion3.png") ;moves to the "video" section of the effects control window tab
        goto next
    else
        {
            MouseMove(xpos, ypos)
            blockOff()
            toolFind("the video section", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Couldn't find the video section", A_LineFile, A_LineNumber)
            return
        }
    next:
    MouseMove(motionX + "10", motionY + "10")
    SendInput("{Click}")
    MouseMove(xpos, ypos)
    SendInput("{Tab 2}")
    if x = 0
        {
            previousClipboard := A_Clipboard
            A_Clipboard := ""
            SendInput("^c")
            ClipWait()
            x := A_Clipboard
            SendInput("{Tab}")
            A_Clipboard := ""
            SendInput("^c")
            ClipWait()
            y := A_Clipboard
            SendInput("{Tab}")
            A_Clipboard := ""
            SendInput("^c")
            ClipWait()
            scale := A_Clipboard
            blockOff()
            SendInput("{Enter}")
            toolCust("Setting up your zoom has completed", "1000")
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
            blockOff()
            return
        }
}

/* valuehold()
 a preset to warp to one of a videos values (scale , x/y, rotation, etc) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
 @param filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
 @param optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
 */
valuehold(filepath, optional)
{
    ;This function will only operate correctly if the space between the x value and y value is about 210 pixels away from the left most edge of the "timer" (the icon left of the value name)
    ;I use to have it try to function irrespective of the size of your panel but it proved to be inconsistent and too unreliable.
    ;You can plug your own x distance in by changing the value below
    xdist := 210
    coords()
    MouseGetPos(&xpos, &ypos)
    ;toolCust("x " xpos "`ny " ypos, "1000") ;testing stuff
    blockOn()
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    getClassNN(&ClassNN, &classX, &classY, &width, &height)
    SendInput(timelineWindow) ;focuses the timeline
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
        { ;any imagesearches on the effect controls window includes a division variable (ECDivide) as I have my effect controls quite wide and there's no point in searching the entire width as it slows down the script
            SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    toolCust("The wrong clips are selected", "1000")
                    errorLog(A_ThisFunc "()", "The wrong clips are selected", A_LineFile, A_LineNumber)
                    blockOff()
                    return
                }
        }
    if filepath = "levels" ;THIS IS FOR ADJUSTING THE "LEVEL" PROPERTY, YOUR PNG MUST BE CALLED "levels.png"
        { ;don't add WheelDown's, they suck in hotkeys, idk why, they lag everything out and stop Click's from working
            if ImageSearch(&vidx, &vidy, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "video.png")
                {
                    toolCust("you aren't scrolled down", "1000")
                    errorLog(A_ThisFunc "()", "The user wasn't scrolled down", A_LineFile, A_LineNumber)
                    blockOff()
                    KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                    return
                }
            else
                goto next
        }
    next:
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
                    toolCust("Couldn't get the ClassNN of the Effects Controls panel", "1000")
                    errorLog(A_ThisFunc "()", "Function couldn't determine the ClassNN of the Effects Controls panel", A_LineFile, A_LineNumber)
                    MouseMove(xpos, ypos)
                    return
                }
            }
        if ( ;finds the value you want to adjust, then finds the value adjustment to the right of it
                ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath ".png") ||
                ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath "2.png") ||
                ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath "3.png") ||
                ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath "4.png")
        ) 
            break
        if A_Index > 3
            {
                blockOff()
                toolFind("the image after " A_Index " attempts`nx " classX "`ny " classY "`nwidth " width "`nheight " height, "5000") ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(A_ThisFunc "()", "Failed to find the appropiate image after " A_Index " attempts ~~ x " classX " ~~ y " classY " ~~ width " width " ~~ height " height, A_LineFile, A_LineNumber)
                KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                MouseMove(xpos, ypos)
                return
            }
        sleep 50
    }
    colour:
    if PixelSearch(&xcol, &ycol, x, y, x + xdist, y + "40", 0x205cce, 2)
        MouseMove(xcol + optional, ycol)
    else
        {
            blockOff()
            toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Failed to find the blue 'value' text", A_LineFile, A_LineNumber)
            KeyWait(A_ThisHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
            MouseMove(xpos, ypos)
            return
        }
    sleep 50 ;required, otherwise it can't know if you're trying to tap to reset
    ;I tried messing around with "if A_TimeSincePriorHotkey < 100" instead of a sleep here but premiere would get stuck in a state of "clicking" on the field if I pressed a macro, then let go quickly but after the 100ms. Maybe there's a smarter way to make that work, but honestly just kicking this sleep down to 50 from 100 works fine enough for me and honestly isn't even really noticable.
    if GetKeyState(A_ThisHotkey, "P")
        {
            SendInput("{Click Down}")
            blockOff()
            KeyWait(A_ThisHotkey)
            SendInput("{Click Up}" "{Enter}")
            sleep 200 ;was experiencing times where ahk would just fail to excecute the below mousemove. no idea why. This sleep seems to stop that from happening and is practically unnoticable
            MouseMove(xpos, ypos)
            /* MouseGetPos(&testx, &testy) ;testing stuff
            MsgBox("og x " xpos "`nog y " ypos "`ncurrent x " testx "`ncurrent y " testy) */
        }
    else
        {
            if ImageSearch(&x2, &y2, x, y - "10", x + "1500", y + "20", "*2 " Premiere "reset.png") ;searches for the reset button to the right of the value you want to adjust
                {
                    MouseMove(x2, y2)
                    SendInput("{Click}")
                }
            else ;if everything fails, this else will trigger
                {
                    if filepath = "levels" ;THIS IS FOR ADJUSTING THE "LEVEL" PROPERTY, CHANGE IN THE KEYBOARD SHORTCUTS.INI FILE
                        {
                            SendInput("{Click}" "0" "{Enter}")
                            MouseMove(xpos, ypos)
                            blockOff()
                            return
                        }
                    MouseMove(xpos, ypos)
                    blockOff()
                    toolFind("the reset button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
                    errorLog(A_ThisFunc "()", "Failed to find reset button", A_LineFile, A_LineNumber)
                    return
                }
            MouseMove(xpos, ypos)
            blockOff()
        }
    ToolTip("")
}

/* keyreset()
 this function is to turn off keyframing for a given property within premiere pro
 @param filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
 */
keyreset(filepath) ;I think this function is broken atm, I need to do something about it... soon
{
    MouseGetPos(&xpos, &ypos)
    coords()
    blockOn()
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    getClassNN(&ClassNN, &classX, &classY, &width, &height)
    SendInput(timelineWindow) ;focuses the timeline
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
        {
            SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    toolCust("The wrong clips are selected", "1000")
                    errorLog(A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                    blockOff()
                    return
                }
        }
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath "2.png") || ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath "4.png")
        goto click
    else
        {
            toolCust("you're already keyframing", "1000")
            errorLog(A_ThisFunc "()", "The user was already keyframing", A_LineFile, A_LineNumber)
            blockOff()
            ;KeyWait(A_PriorHotkey) ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
            return
        }
    click:
    MouseMove(x + "7", y + "4")
    click
    blockOff()
    MouseMove(xpos, ypos)
}

/* keyframe()
 this function is to either turn on keyframing, or create a new keyframe at the cursor for a given property within premiere pro
 @param filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
 */
keyframe(filepath)
{
    MouseGetPos(&xpos, &ypos)
    coords()
    blockOn()
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    getClassNN(&ClassNN, &classX, &classY, &width, &height)
    SendInput(timelineWindow) ;focuses the timeline
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
        {
            SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    toolCust("The wrong clips are selected", "1000")
                    errorLog(A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                    blockOff()
                    return
                }
        }
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath "2.png") || ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath "4.png")
            goto next
    else if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath ".png") || ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere filepath "3.png")
        {
            MouseMove(x + "5", y + "5")
            Click()
            goto end
        }
    else
        {
            toolCust("Couldn't find the desired value", "1000")
            errorLog(A_ThisFunc "()", "Couldn't find the desired value", A_LineFile, A_LineNumber)
            blockOff()
            return
        }
    next:
    if ImageSearch(&keyx, &keyy, x, y, x + "500", y + "20", "*2 " Premiere "keyframeButton.png") || ImageSearch(&keyx, &keyy, x, y, x + "500", y + "20", "*2 " Premiere "keyframeButton2.png")
        MouseMove(keyx + "3", keyy)
    Click()
    end:
    SendInput(timelineWindow) ;focuses the timeline
    MouseMove(xpos, ypos)
    blockOff()
}

/* audioDrag()
 This function pulls an audio file out of a separate bin from the project window and back to the cursor (premiere pro)
 If `sfxName` is "bleep" there is extra code that automatically moves it to your track of choice
 @param sfxName is the name of whatever sound you want the function to pull onto the timeline
 */
audioDrag(sfxName)
{
    ;I wanted to use a method similar to other premiere functions above, that grabs the classNN value of the panel to do all imagesearches that way instead of needing to define coords, but because I'm using a separate bin which is essentially just a second project window, things get messy, premiere gets slow, and the performance of this function dropped drastically so for this one we're going to stick with coords defined in KSA.ini/ahk
    coords()
    if ImageSearch(&sfxxx, &sfxyy, 3021, 664, 3589, 1261, "*2 " Premiere "binsfx.png") ;checks to make sure you have the sfx bin open as a separate project window
        {
            blockOn()
            coords()
            MouseGetPos(&xpos, &ypos)
            if ImageSearch(&listx, &listy, 3082, 664, 3591, 1265, "*2 " Premiere "list view.png") ;checks to make sure you're in the list view
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
                        Loop 40
                            {
                                sleep 30
                                CaretGetPos(&findx)
                                if findx != "" ;!= means "not-equal" so as soon as premiere has found the find box, this will populate and break the loop
                                    break
                                if A_Index > 40 ;if this loop fires 40 times and premiere still hasn't caught up, the function will cancel itself
                                    {
                                        blockOff()
                                        toolCust("Premiere was dumb and`ncouldn't find the findbox. Try again", "3000")
                                        errorLog(A_ThisFunc "()", "Premiere couldn't find the findbox", A_LineFile, A_LineNumber)
                                        return
                                    }
                            }
                    }
                SendInput("^a" "+{BackSpace}")
                SendInput(sfxName)
                sleep 250 ;the project search is pretty slow so you might need to adjust this
                coordw()
                if ImageSearch(&vlx, &vly, sfxX1, sfxY1, sfxX2, sfxY2, "*2 " Premiere "audio.png") || ImageSearch(&vlx, &vly, sfxX1, sfxY1, sfxX2, sfxY2, "*2 " Premiere "audio2.png") ;searches for the audio image next to an audio file
                    {
                        MouseMove(vlx, vly)
                        sleep 50
                        SendInput("{Click Down}")
                        sleep 50
                    }
                else
                    {
                        blockOff()
                        toolFind("audio image", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
                        errorLog(A_ThisFunc "()", "Couldn't find the audio image", A_LineFile, A_LineNumber)
                        coords()
                        MouseMove(xpos, ypos)
                        return
                    }
                coords()
                MouseMove(xpos, ypos)
                SendInput("{Click Up}")
                SendInput(timelineWindow)
                MouseMove(30,0,, "R")
                sleep 50
                MouseGetPos(&colourX, &colourY)
                colour := PixelGetColor(colourX, colourY)
                if colour = 0xCCCCCC || colour = 0x156B4C || colour = 0x29D698
                    break
                if A_Index > 2
                    {
                        blockOff()
                        toolCust("Couldn't drag the file to the timeline", "1000")
                        errorLog(A_ThisFunc "()", "Couldn't drag the file to the timeline", A_LineFile, A_LineNumber)
                        return
                    }
            }
            MouseMove(-30,0,, "R")
            blockOff()
            if sfxName = "bleep"
                {
                    skip := 0
                    trackNumber:= 2
                    sleep 100
                    SendInput(cutPrem)
                    ToolTip(A_ThisFunc " is waiting for you to cut the bleep sfx`nPress c again if you do not wish for this funtion to drag the cut to Track 1")
                    loop {
                        if GetKeyState("c", "P")
                            skip := 1
                        ;check to see if the user wants the bleep on a track between 1-9
                        if GetKeyState("1", "P")
                            trackNumber := "1"
                        if GetKeyState("2", "P")
                            trackNumber := "2"
                        if GetKeyState("3", "P")
                            trackNumber := "3"
                        if GetKeyState("4", "P")
                            trackNumber := "4"
                        if GetKeyState("5", "P")
                            trackNumber := "5"
                        if GetKeyState("6", "P")
                            trackNumber := "6"
                        if GetKeyState("7", "P")
                            trackNumber := "7"
                        if GetKeyState("8", "P")
                            trackNumber := "8"
                        if GetKeyState("9", "P")
                            trackNumber := "9"
                        if GetKeyState("LButton", "P") ;checking for the user cutting the bleep sfx
                            break
                        sleep 50
                        if A_Index > 160 ;built in timeout
                            {
                                blockOff()
                                toolCust(A_ThisFunc " timed out due to no user interaction", "2000")
                                errorLog(A_ThisFunc "()", "timed out due to no user interaction", A_LineFile, A_LineNumber)
                                return
                            }
                    }
                    ToolTip("")
                    blockOn()
                    sleep 50
                    SendInput(selectionPrem)
                    MouseGetPos(&delx, &dely)
                    MouseMove(-10, 0,, "R")
                    sleep 50
                    if A_Cursor != "Arrow"
                        loop 12 {
                            MouseMove(-5, 0, 2, "R")
                            if A_Cursor = "Arrow"
                                {
                                    MouseMove(-5, 0, 2, "R")
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
                    sleep 500
                    SendInput("{Click Down}")
                    MouseGetPos(&refx, &refy)
                    if skip = 1
                        goto skip
                    else if ImageSearch(&trackX, &trackY, 0, 0, 200, A_ScreenHeight, "*2 " Premiere "\track " trackNumber "_1.png") || ImageSearch(&trackX, &trackY, 0, 0, 200, A_ScreenHeight, "*2 " Premiere "\track " trackNumber "_2.png")
                        {
                            MouseMove(refx, trackY, 2)
                            goto skip
                        }
                    else
                        {
                            blockOff()
                            toolCust("Couldn't determine the Y value of desired track", "1000")
                            errorLog(A_ThisFunc "()", "Couldn't determine the Y value of desired track", A_LineFile, A_LineNumber)
                            return
                        }
                    skip:
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
                    blockOff()
                    ToolTip("")
                    return
                }
        }
    else
        {
            toolCust("you haven't opened the bin", "2000")
            errorLog(A_ThisFunc "()", "User hasn't opened the required bin", A_LineFile, A_LineNumber)
        }
}

/*
audioDrag(folder, sfxName) (old | uses media browser instead of a project bin)
{
    SendInput(mediaBrowser) ;highlights the media browser ~ check the keyboard shortcut ini file to adjust hotkeys
    ;KeyWait(A_PriorKey) ;I have this set to remapped mouse buttons which instantly "fire" when pressed so can cause errors
    blockOn()
    coords()
    MouseGetPos(&xpos, &ypos)
    SendInput(mediaBrowser) ;highlights the media browser ~ check the keyboard shortcut ini file to adjust hotkeys
    sleep 10
    if ImageSearch(&sfx, &sfy, mbX1, mbY1, mbX2, mbY2, "*2 " Premiere folder ".png") ;searches for my sfx folder in the media browser to see if it's already selected or not
        {
            MouseMove(sfx, sfy) ;if it isn't selected, this will move to it then click it
            SendInput("{Click}")
            MouseMove(xpos, ypos)
            sleep 100
            goto next
        }
    else if ImageSearch(&sfx, &sfy, mbX1, mbY1, mbX2, mbY2, "*2 " Premiere folder "2.png") ;if it is selected, this will see it, then move on
        goto next
    else ;if everything fails, this else will trigger
        {
            blockOff()
            toolFind("sfx folder", "1000")
            MouseMove(xpos, ypos)
            return
        }
    next:
    SendInput(findBox) ;adjust this in the keyboard shortcuts ini file
    coordc()
    SendInput("^a" "+{BackSpace}") ;deletes anything that might be in the search box
    SendInput(sfxName)
    sleep 150
    if ImageSearch(&vlx, &vly, mbX1, mbY1, mbX2, mbY2, "*2 " Premiere "vlc.png") ;searches for the vlc icon to grab the track
        {
            MouseMove(vlx, vly)
            SendInput("{Click Down}")
        }
    else
        {
            blockOff()
            toolFind("vlc image", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
            MouseMove(xpos, ypos)
            return
        }
    MouseMove(xpos, ypos)
    SendInput("{Click Up}")
    SendInput(mediaBrowser)
    SendInput(findBox)
    SendInput("^a" "+{BackSpace}" "{Enter}")
    sleep 50
    SendInput(timelineWindow)
    blockOff()
}
*/

/* wheelEditPoint()
 move back and forth between edit points from anywhere in premiere
 @param direction is the hotkey within premiere for the direction you want it to go in relation to "edit points"
 */
wheelEditPoint(direction)
{
    SendInput(timelineWindow) ;focuses the timeline
    SendInput(direction) ;Set these shortcuts in the keyboards shortcut ini file
    KeyWait(A_ThisHotkey) ;prevents hotkey spam
}

/* movepreview()
 This function is to adjust the framing of a video within the preview window in premiere pro. Let go of this hotkey to confirm, simply tap this hotkey to reset values
 */
movepreview()
{
    coords()
    blockOn()
    MouseGetPos(&xpos, &ypos)
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    try {
        ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel (effect controls)
        ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
    } catch as e {
        toolCust("Couldn't find the ClassNN value", "1000")
        errorLog(A_ThisFunc "()", "Couldn't find the ClassNN value", A_LineFile, A_LineNumber)
    }
    SendInput(timelineWindow) ;focuses the timeline
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
        {
            SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    toolCust("The wrong clips are selected", "1000")
                    errorLog(A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                    blockOff()
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
                    toolCust("Couldn't get the ClassNN of the Effects Controls panel", "1000")
                    errorLog(A_ThisFunc "()", "Function couldn't determine the ClassNN of the Effects Controls panel", A_LineFile, A_LineNumber)
                    MouseMove(xpos, ypos)
                    return
                }
            }
        if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "motion.png") ;moves to the motion tab
                {
                    MouseMove(x + "25", y)
                    break
                }
        if A_Index > 3
            {
                blockOff()
                toolFind("the image after " A_Index " attempts`nx " classX "`ny " classY "`nwidth " width "`nheight " height, "5000") ;useful tooltip to help you debug when it can't find what it's looking for
                errorLog(A_ThisFunc "()", "Failed to find the appropiate image after " A_Index " attempts ~~ x " classX " ~~ y " classY " ~~ width " width " ~~ height " height, A_LineFile, A_LineNumber)
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
                        blockOff()
                        toolCust(A_ThisFunc " couldn't find your video or it kept finding pure black at each coordinate", "2000")
                        errorLog(A_ThisFunc "()", "Couldn't find your video or it kept finding pure black at each coordinate", A_LineFile, A_LineNumber)
                        break
                    }
            }
            SendInput("{Click Down}")
            blockOff()
            KeyWait A_ThisHotkey
            SendInput("{Click Up}")
            ;MouseMove(xpos, ypos) ; // moving the mouse position back to origin after doing this is incredibly disorienting
        }
    else
        {
            if ImageSearch(&xcol, &ycol, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "reset.png") ;these coords are set higher than they should but for whatever reason it only works if I do that????????
                    MouseMove(xcol, ycol)
            else ;if everything fails, this else will trigger
                {
                    blockOff()
                    MouseMove(xpos, ypos)
                    toolFind("the reset button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
                    errorLog(A_ThisFunc "()", "Couldn't find the reset button", A_LineFile, A_LineNumber)
                    return
                }
            Click
            sleep 50
            MouseMove(xpos, ypos)
            blockOff()
        }
    ToolTip("")
}

/* reset()
 This script moves the cursor to the reset button to reset the "motion" effects
 */
reset()
{
    KeyWait(A_ThisHotkey)
    coords()
    blockOn()
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    getClassNN(&ClassNN, &classX, &classY, &width, &height)
    SendInput(timelineWindow) ;focuses the timeline
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
        {
            SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    toolCust("The wrong clips are selected", "1000")
                    errorLog(A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                    blockOff()
                    return
                }
        }
    MouseGetPos(&xpos, &ypos)
    loop 5 {
        if ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "motion2.png") || ImageSearch(&x2, &y2, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "motion3.png") ;checks if the "motion" value is in view
            break
        else
            {
                blockOff()
                toolFind("the motion value", "1000")
                errorLog(A_ThisFunc "()", "Couldn't find the motion image", A_LineFile, A_LineNumber)
                return
            }
    }
    SendInput(timelineWindow) ;~ check the keyboard shortcut ini file to adjust hotkeys
    ;SendInput(labelIris) ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
    if ImageSearch(&xcol, &ycol, x2, y2 - "20", x2 + "700", y2 + "20", "*2 " Premiere "reset.png") ;this will look for the reset button directly next to the "motion" value
        MouseMove(xcol, ycol)
    ;SendInput, {WheelUp 10} ;not necessary as we use imagesearch to check for the motion value
    click
    MouseMove(xpos, ypos)
    blockOff()
}

/* hotkeyDeactivate()
 this allowed the old version of manInput to work
 */
hotkeyDeactivate()
{
    Hotkey("~Numpad0", "r", "On") ;all of these "hotkeys" allow me to use my numpad to input numbers instead of having to take my hand off my mouse to press the numpad on my actual keyboard
    Hotkey("~Numpad1", "r", "On") ;I have it call on "r" because, well, r isn't a key that exists on my numpad. if I put this value at something that's already defined, then the original macros will fire
    ;Hotkey("~SC05C & Numpad1", "Numpad1", "On")
    Hotkey("~Numpad2", "r", "On")
    Hotkey("~Numpad3", "r", "On")
    Hotkey("~Numpad4", "r", "On")
    Hotkey("~Numpad5", "r", "On")
    Hotkey("~Numpad6", "r", "On")
    Hotkey("~Numpad7", "r", "On")
    Hotkey("~Numpad8", "r", "On")
    Hotkey("~Numpad9", "r", "On")
    Hotkey("NumpadDot", "e", "On")
    Hotkey("~NumpadEnter", "r", "On")
}

/* hotkeyReactivate()
 this allowed the old version of manInput to work
 */
hotkeyReactivate()
{
    Hotkey("Numpad0", "Numpad0")
    Hotkey("Numpad1", "Numpad1")
    Hotkey("Numpad2", "Numpad2")
    Hotkey("Numpad3", "Numpad3")
    Hotkey("Numpad4", "Numpad4")
    Hotkey("Numpad5", "Numpad5")
    Hotkey("Numpad6", "Numpad6")
    Hotkey("Numpad7", "Numpad7")
    Hotkey("Numpad8", "Numpad8")
    Hotkey("Numpad9", "Numpad9")
    Hotkey("NumpadDot", "NumpadDot")
    Hotkey("NumpadEnter", "NumpadEnter")
}

/* manInput()
 This function will warp to and press any value in premiere to manually input a number
 @param property is the value you want to adjust
 @param optional is the optional pixels to move the mouse to grab the Y axis value instead of the X axis
 */
manInput(property, optional)
{
    waitHotkey := getSecondHotkey()
    MouseGetPos(&xpos, &ypos)
    coords()
    blockOn()
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    getClassNN(&ClassNN, &classX, &classY, &width, &height)
    SendInput(timelineWindow)
    if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;searches to check if no clips are selected
        {
            SendInput(selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    toolCust("The wrong clips are selected", "1000")
                    errorLog(A_ThisFunc "()", "No clips were selected", A_LineFile, A_LineNumber)
                    blockOff()
                    return
                }
        }
    if ( ;finds the scale value you want to adjust, then finds the value adjustment to the right of it
        ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere property ".png") ||
        ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere property "2.png") ||
        ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere property "3.png") ||
        ImageSearch(&x, &y, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere property "4.png")
    )
        goto colour
    else ;if everything fails, this else will trigger
        {
            blockOff()
            toolFind("the property you wish to adjust", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Couldn't find the users requested property", A_LineFile, A_LineNumber)
            return
        }
    colour:
    if PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x288ccf, 3) ;searches for the blue text to the right of the scale value
        MouseMove(xcol + optional, ycol)
    else
        {
            blockOff()
            toolFind("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
            errorLog(A_ThisFunc "()", "Failed to find the blue 'value' text", A_LineFile, A_LineNumber)
            return
        }
    keywait(waitHotkey)
    SendInput("{Click}")
    ToolTip("manInput() is waiting for the " "'" manInputEnd "'" "`nkey to be pressed")
    KeyWait(manInputEnd, "D") ;waits until the final hotkey is pressed before continuing
    ToolTip("")
    SendInput("{Enter}")
    MouseMove(xpos, ypos)
    Click("middle")
    blockOff()
}

/* gain()
 This function is to increase/decrease gain within premiere pro. This function will check to ensure the timeline is in focus and a clip is selected
 @param amount is the value you want the gain to adjust (eg. -2, 6, etc)
 */
gain(amount)
{
    KeyWait(A_ThisHotkey)
    Critical
    ToolTip("Adjusting Gain")
    BlockInput(1)
    coords()
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
                    blockOff()
                    return
                }
            getClassNN(&ClassNN, &classX, &classY, &width, &height)
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
            if ImageSearch(&x3, &y3, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
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
                            blockOff()
                            toolCust("gain macro couldn't figure`nout what to do", "1000")
                            errorLog(A_ThisFunc "()", "Function was unable to determine how to proceed", A_LineFile, A_LineNumber)
                            return
                        }
                }*/
        } catch as e {
            ToolTip("")
            blockOff()
            toolCust("ClassNN wasn't given a value", "1000")
            errorLog(A_ThisFunc "()", "attempted an ImageSearch without a variable value", A_LineFile, A_LineNumber)
            return
        }
        inputs:
        SendInput("g")
        WinWait("Audio Gain")
        SendInput("+{Tab}{UP 3}{DOWN}{TAB}" amount "{ENTER}")
        WinWaitClose("Audio Gain")
        blockOff()
        ToolTip("")
}

/* gainSecondary()
 This function opens up the gain menu within premiere pro so I can input it with my secondary keyboard. This function will also check to ensure the timeline is in focus and a clip is selected. I don't really use this anymore
 @param keyend is whatever key you want the function to wait for before finishing
 */
gainSecondary(keyend)
{
    waitKey := getSecondHotkey()
    SendInput(effectControls)
    SendInput(effectControls) ;focus it twice because premiere is dumb and you need to do it twice to ensure it actually gets focused
    getClassNN(&ClassNN, &classX, &classY, &width, &height)
    SendInput(timelineWindow)
    if ImageSearch(&x3, &y3, classX, classY, classX + (width/ECDivide), classY + height, "*2 " Premiere "noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
        {
            SendInput(timelineWindow selectAtPlayhead) ;~ check the keyboard shortcut ini file to adjust hotkeys
            goto inputs
        }
    else
        {
            classNN := ControlGetClassNN(ControlGetFocus("A"))
            if "DroverLord - Window Class3"
                goto inputs
            else
                {
                    toolCust("gain macro couldn't figure`nout what to do", "1000")
                    errorLog(A_ThisFunc "()", "Function was unable to determine how to proceed", A_LineFile, A_LineNumber)
                    return
                }
        }
    inputs:
    KeyWait(waitKey) ;waits for you to let go of hotkey
    hotkeyDeactivate()
    SendInput(gainAdjust) ;~ check the keyboard shortcut ini file to adjust hotkeys
    KeyWait(keyend, "D") ;waits until the final hotkey is pressed before continuing
    hotkeyReactivate()
}

/* openChecklist()
 This function is here to cut repeat code across a few scripts, its purpose is to find the `checklist.ahk` file for the open Premiere/After Effects project. It's used in QMK.ahk and autosave.ahk
 */
openChecklist()
{
    if WinExist("ahk_class tooltips_class32") ;checking to see if any tooltips are active before beginning
		WinWaitClose("ahk_class tooltips_class32")
    try {
        if WinExist("Adobe Premiere Pro")
            {
                Name := WinGetTitle("Adobe Premiere Pro")
                titlecheck := InStr(Name, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
                if titlecheck = ""
                    {
                        blockOff()
                        toolCust("``titlecheck`` variable wasn't assigned a value", "1000")
                        errorLog(A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                        return
                    }
            }
        else if WinExist("Adobe After Effects")
            {
                Name := WinGetTitle("Adobe After Effects")
                titlecheck := InStr(Name, "Adobe After Effects " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe After Effects [Year]"
                if titlecheck = ""
                    {
                        blockOff()
                        toolCust("``afterFXTitle`` variable wasn't assigned a value", "1000")
                        errorLog(A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                        return
                    }
            }
        dashLocation := InStr(Name, "-")
        length := StrLen(Name) - dashLocation
    }
    if not IsSet(titlecheck) || IsSet(afterFXTitle)
        {
            blockOff()
            toolCust("``titlecheck/afterFXTitle`` variable wasn't assigned a value", "1000")
            errorLog(A_ThisFunc "()", "``titlecheck/afterFXTitle`` variable wasn't assigned a value", A_LineFile, A_LineNumber)
            return
        }
    if not titlecheck
        {
            toolCust("You're on a part of Premiere that won't contain the project path", "2000")
            return
        }
    entirePath := SubStr(name, dashLocation + "2", length)
    pathlength := StrLen(entirePath)
    finalSlash := InStr(entirePath, "\",, -1)
    path := SubStr(entirePath, 1, finalSlash - "1")
    SplitPath path, &name
    if WinExist("Checklist - " name)
        {
            WinMove(-371, -233,,, "Checklist - " name) ;move it back into place incase I've moved it
            toolCust("You already have this checklist open", "1000")
            errorLog(A_ThisHotkey, "You already have this checklist open", A_LineFile, A_LineNumber)
            return
        }
    if FileExist(path "\checklist.ahk")
        Run(path "\checklist.ahk")
    else
        {
            try {
                FileCopy(location "\checklist.ahk", path)
                Run(path "\checklist.ahk")
            } catch as e {
                toolCust("File not found", "1000")
            }
        }
}

/*
 This function gets the classNN value and subsequent variables from the active window class.
 */
getClassNN(&ClassNN, &classX, &classY, &width, &height)
{
    try {
        ClassNN := ControlGetClassNN(ControlGetFocus("A")) ;gets the ClassNN value of the active panel
        ControlGetPos(&classX, &classY, &width, &height, ClassNN) ;gets the x/y value and width/height value
    } catch as e {
        blockOff() ;just incase
        toolCust("Couldn't get the ClassNN of the desired panel", "1000")
        errorLog(A_ThisFunc "()", "Function couldn't determine the ClassNN of the desired panel", A_LineFile, A_LineNumber)
        return
    }
}
; ===========================================================================================================================================
; Old
; ===========================================================================================================================================
/*
gain() ;old gain code (v2.3.14)to use imagesearch instead of the ClassNN information
/*
if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " A_WorkingDir "\Support Files\ImageSearch\Premiere\motion2.png")
    goto inputs
else
    {
        if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " A_WorkingDir "\Support Files\ImageSearch\Premiere\motion3.png") ;checks to see if the "motion" tab is highlighted as if it is, you'll start inputting values in that tab instead of adjusting the gain
            {
                SendInput("^+9") ;selects the timeline
                goto inputs
            }
        else
            {
                if ImageSearch(&x3, &y3, 1, 965, 624, 1352, "*2 " A_WorkingDir "\Support Files\ImageSearch\Premiere\noclips.png") ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
                    {
                        SendInput("^+9" "d")
                        goto inputs
                    }
                else
                    {
                        toolCust("gain macro couldn't figure`nout what to do", "1000")
                        return
                    }
            }
    } */