;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.9.1
#Include General.ahk

/* psProp()
 A function to warp to one of a photos values within Photoshop (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease.
 @param image is the png name of the image that imagesearch will use
 */
psProp(image)
{
    coords()
    MouseGetPos(&xpos, &ypos)
    coordw()
    blockOn()
    if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " Photoshop "text2.png") ;checks to see if you're typing
        SendInput("^{Enter}")
    if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " Photoshop "text.png") ;checks to see if you're in the text tool
        SendInput("v") ;if you are, it'll press v to go to the selection tool
    if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " Photoshop "InTransform.png") ;checks to see if you're already in the free transform window
        {
            if ImageSearch(&x, &y, 60, 30, 744, 64, "*5 " Photoshop %&image%) ;if you are, it'll then search for your button of choice and move to it
                MouseMove(%&x%, %&y%)
            else ;if everything fails, this else will trigger
                {
                    blockOff()
                    toolFind("the value you wish`nto adjust_1", "1000")
                    errorLog("psProp()", "Was unable to find the value the user wished to adjust")
                    return
                }
        }
    else
        {
            SendInput(freeTransform) ;if you aren't in the free transform it'll simply press your hotkey to get you into it. check the ini file to adjust this hotkey
            ToolTip("we must wait for photoshop`nbecause it's slow as hell")
            sleep 300 ;photoshop is slow
            ToolTip("")
            if ImageSearch(&x, &y, 111, 30, 744, 64, "*5 " Photoshop %&image%) ;moves to the position variable
                MouseMove(%&x%, %&y%)
            else ;if everything fails, this else will trigger
                {
                    MouseMove(%&xpos%, %&ypos%)
                    blockOff()
                    toolFind("the value you wish`nto adjust_2", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
                    errorLog("psProp()", "Was unable to find the value the user wished to adjust")
                    return
                }
        }
    sleep 100 ;this sleep is necessary for the "tap" functionality below (in the 'else') to work
    SendInput("{Click Down}")
    if GetKeyState(A_ThisHotkey, "P")
        {
            blockOff()
            KeyWait(A_ThisHotkey)
            SendInput("{Click Up}")
            MouseMove(%&xpos%, %&ypos%)
        }
    else ;since we're in photoshop here, we'll simply make the "tap" functionality have ahk hit enter twice so it exits out of the free transform
        {
            Click("{Click Up}")
            ;fElse(%&data%) ;check the various Functions scripts for the code to this preset
            MouseMove(%&xpos%, %&ypos%)
            SendInput("{Enter 2}")
            blockOff()
            return
        }
}
 
/* psSave()
 This function is to speed through the twitch emote saving process within photoshop. Doing this manually is incredibly tedious and annoying, so why do it manually?
 */
psSave()
;This script will require the latest (or at least the version containing the "save as copy" window) version of photoshop to function
;PHOTOSHOP IS SLOW AS ALL HELL
;if things in this script don't work or get stuck, consider increasing the living hell out of the sleeps along the way
{
    save(size)
    {
        WinActivate("ahk_exe Photoshop.exe")
        blockOn()
        SendInput(imageSize) ;check the keyboard shortcut ini file
        WinWait("Image Size")
        SendInput(%&size% "{tab 2}" %&size% "{Enter}")
        sleep 1000
        SendInput(saveasCopy) ;check the keyboard shortcut ini file
        WinWait("Save a Copy")
    }
    image()
    {
        sleep 500
        Send("{TAB}{RIGHT}")
        coordw()
        sleep 1000
        if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " Photoshop "png.png")
            {
                MouseMove(0, 0)
                SendInput("{Enter 2}")
            }
        else
            {
                if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " Photoshop "png2.png")
                    {
                        MouseMove(%&xpng%, %&ypng%)
                        SendInput("{Click}")
                        sleep 50
                        MouseMove(0, 0)
                        SendInput("{Enter}")
                    }
                else
                    {
                        MouseMove(0, 0)
                        blockOff()
                        toolFind("png", "1000")
                        errorLog("psSave()", "Was unable to find the png option")
                        return
                    }
            }
    }

    Emote := InputBox("Please enter an Emote Name.", "Emote Name", "w100 h100")
        if Emote.Result = "Cancel"
            return
        else
            goto dir
    dir:
    dir := DirSelect("*::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", 3, "Pick the destination folder you wish everything to save to.")
        if dir = ""
            return
    next:
    ;=============================112x112
    save("112")
    sleep 1000
    SendInput("{F4}" "^a")
    SendInput(Dir "{Enter}")
    sleep 1000
    SendInput("+{Tab 9}")
    sleep 100
    SendInput(Emote.Value "_112")
    image()
    WinWait("PNG Format Options")
    SendInput("{Enter}")
    ;=============================56x56
    save("56")
    SendInput("{F4}" "^a")
    SendInput(Dir "{Enter}")
    sleep 1000
    SendInput("+{Tab 9}")
    SendInput(Emote.Value "_56")
    image()
    WinWait("PNG Format Options")
    SendInput("{Enter}")
    ;=============================28x28
    save("28")
    SendInput("{F4}" "^a")
    SendInput(Dir "{Enter}")
    sleep 1000
    SendInput("+{Tab 9}")
    SendInput(Emote.Value "_28")
    image()
    WinWait("PNG Format Options")
    SendInput("{Enter}")
    blockOff()
}
 
/* psType()
 When you try and save a copy of something in photoshop, it defaults to psd, this is a function to instantly pick the actual filetype you want
 @param filetype is the name of the image you save to pick which filetype you want this function to click on
 */
psType(filetype)
{
    MouseGetPos(&x, &y)
    Send("{TAB}{RIGHT}") ;make sure you don't click anywhere before using this function OR put the caret back in the filename box
    coordw()
    sleep 200 ;photoshop is slow as hell, if you notice it missing the png drop down you may need to increase this delay
    if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " Photoshop %&filetype% ".png")
        {
            SendInput("{Enter}")
            SendInput("+{Tab}")
        }

    else if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " Photoshop %&filetype% "2.png")
        {
            MouseMove(%&xpng%, %&ypng%)
            SendInput("{Click}")
            SendInput("+{Tab}")
        }
    else
        {
            blockOff()
            toolFind("png drop down", "1000")
            errorLog("psType()", "Was unable to find the filetype option")
            return
        }
    MouseMove(%&x%, %&y%)
}
 