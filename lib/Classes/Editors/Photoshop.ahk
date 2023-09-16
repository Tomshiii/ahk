/************************************************************************
 * @description A library of useful Photoshop functions to speed up common tasks
 * Last tested in v25.0 of Photoshop
 * @psVer 25.0
 * @author tomshi
 * @date 2023/08/14
 * @version 1.2.1.2
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\keys>
#Include <Classes\errorLog>
; }

class PS {

    static exeTitle := Editors.Photoshop.winTitle
    static winTitle := this.exeTitle
    static class := Editors.Photoshop.class
    static path := ptf["Photoshop"]

    /**
     * A function to warp to one of a photos values within Photoshop (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease.
     * @param {String} image is the png name of the image that imagesearch will use
     */
    static Prop(image)
    {
        coord.s()
        MouseGetPos(&xpos, &ypos)
        coord.w()
        block.On()
        if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " ptf.Photoshop "text2.png") ;checks to see if you're typing
            SendInput("^{Enter}")
        if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " ptf.Photoshop "text.png") ;checks to see if you're in the text tool
            SendInput(KSA.selectiontool) ;if you are, it'll press v to go to the selection tool
        if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " ptf.Photoshop "InTransform.png") && !ImageSearch(&x, &y, 60, 30, 744, 64, "*5 " ptf.Photoshop image) ;checks to see if you're already in the free transform window
            {
                block.Off()
                errorLog(Error("Was unable to find the value the user wished to adjust"),, 1)
                keys.allWait()
                return
            }
        else
            {
                SendInput(KSA.freeTransform) ;if you aren't in the free transform it'll simply press your hotkey to get you into it. check the ini file to adjust this hotkey
                ToolTip("we must wait for photoshop`nbecause it's slow as hell")
                sleep 300 ;photoshop is slow
                ToolTip("")
                if !ImageSearch(&x, &y, 111, 30, 744, 64, "*5 " ptf.Photoshop image)
                    {
                        MouseMove(xpos, ypos)
                        block.Off()
                        errorLog(Error("Was unable to find the value the user wished to adjust"),, 1)
                        keys.allWait()
                        return
                    }
            }
        MouseMove(x, y) ;moves to the position variable
        sleep 100 ;this sleep is necessary for the "tap" functionality below (in the 'else') to work
        SendInput("{Click Down}")
        if !GetKeyState(A_ThisHotkey, "P") ;since we're in photoshop here, we'll simply make the "tap" functionality have ahk hit enter twice so it exits out of the free transform
            {
                Click("{Click Up}")
                MouseMove(xpos, ypos)
                SendInput("{Enter 2}")
                block.Off()
                return
            }
        block.Off()
        keys.allWait()
        SendInput("{Click Up}")
        MouseMove(xpos, ypos)
    }

    /**
     * This function is to speed through the twitch emote saving process within photoshop. Doing this manually is incredibly tedious and annoying, so why do it manually?
     */
    static Save()
    ;This script will require the latest (or at least the version containing the "save as copy" window) version of photoshop to function
    ;PHOTOSHOP IS SLOW AS ALL HELL
    ;if things in this script don't work or get stuck, consider increasing the living hell out of the sleeps along the way
    {
        save(size)
        {
            WinActivate(editors.Photoshop.winTitle)
            block.On()
            SendInput(KSA.imageSize) ;check the keyboard shortcut ini file
            WinWait("Image Size")
            SendInput(size "{tab 2}" size "{Enter}")
            sleep 1000
            SendInput(KSA.saveasCopy) ;check the keyboard shortcut ini file
            WinWait("Save a Copy")
        }
        image()
        {
            sleep 500
            Send("{TAB}{RIGHT}")
            coord.w()
            sleep 1000
            if !ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " ptf.Photoshop "png.png")
                {
                    if !ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " ptf.Photoshop "png2.png")
                        {
                            MouseMove(0, 0)
                            block.Off()
                            errorLog(Error("Was unable to find the png option", -1),, 1)
                            return
                        }
                    MouseMove(xpng, ypng)
                    SendInput("{Click}")
                    sleep 50
                    MouseMove(0, 0)
                    SendInput("{Enter}")
                    return
                }
            MouseMove(0, 0)
            SendInput("{Enter 2}")
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
        block.Off()
    }

    /**
     * When you try and save a copy of something in photoshop, it defaults to psd, this is a function to instantly pick the actual filetype you want
     * @param {String} filetype is the name of the image you save to pick which filetype you want this function to click on
     */
    static Type(filetype)
    {
        MouseGetPos(&x, &y)
        Send("{TAB}{RIGHT}") ;make sure you don't click anywhere before using this function OR put the caret back in the filename box
        coord.w()
        sleep 200 ;photoshop is slow as hell, if you notice it missing the png drop down you may need to increase this delay
        if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " ptf.Photoshop filetype ".png")
            {
                SendInput("{Enter}")
                SendInput("+{Tab}")
            }
        else if ImageSearch(&xpng, &ypng, 0, 0, 1574, 1045, "*5 " ptf.Photoshop filetype "2.png")
            {
                MouseMove(xpng, ypng)
                SendInput("{Click}")
                SendInput("+{Tab}")
            }
        else
            {
                block.Off()
                errorLog(Error("Was unable to find the filetype option", -1),, 1)
                return
            }
        MouseMove(x, y)
    }
}
