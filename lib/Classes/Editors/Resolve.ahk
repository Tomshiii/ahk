/************************************************************************
 * @description A library of useful Resolve functions to speed up common tasks
 * Tested on and designed for v18.0.4 of Resolve
 * @author tomshi
 * @date 2023/01/02
 * @version 1.2.1.1
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\winget>
#Include <Classes\clip>
#Include <Classes\obj>
#Include <Functions\errorLog>
#Include <Functions\getHotkeys>
; }

class Resolve {

    static exeTitle := Editors.Resolve.winTitle
    static winTitle := this.exeTitle
    static class := Editors.Resolve.class
    static path := ptf.ProgFi "\Blackmagic Design\DaVinci Resolve\Resolve.exe"

    /**
     * This nested class is simply to store coordinate ranges for imagesearches for certain UI elements of resolve. This makes it easier for another user to come along and adjust them if they don't quite line up with their setup
     */
    class open {
        ;// setting imagesearch coordinates

        ;// for the inspector button
        static inspect := {
            x1: A_ScreenWidth*0.8,   y1: 0,
            x2: A_ScreenWidth,       y2: A_ScreenHeight*0.08
        }
        ;// for the effects button
        static effects := {
            x1: 0,                   y1: 0,
            x2: A_ScreenWidth*0.2,   y2: this.inspect.y2
        }
        ;// for the video effects panel on the top right of the screen
        static vid := {
            x1: this.inspect.x1,   y1: this.inspect.y1,
            x2: this.inspect.x2,   y2: A_ScreenHeight*0.15
        }
        ;// for the properties in the video effects panel
        static prop := {
            x1: this.vid.x1,   y1: this.inspect.y1,
            x2: this.inspect.x2,   y2: A_ScreenHeight*0.53
        }
        ;// for the open/close button on the top left of the screen
        static opnCls := {
            x1: this.effects.x1,   y1: 300,
            x2: A_ScreenWidth/2,   y2: A_ScreenHeight
        }
        ;// for the fx
        static fx := {
            x1: this.effects.x1,   y1: this.opnCls.y1,
            x2: this.opnCls.x2,   y2: A_ScreenHeight
        }

        /**
         * This function cuts massive amounts of repeat code. It handles checking if a certain UI element is selected or not.
         * @param {Object} objCoords the object of coordinates you wish to pass into the function
         * @param {String} pngName1 the name of the first image
         * @param {String} pngName2 the name of the second image
         * @param {String} errorMsg the error message you wish for the tooltip to use
         * @returns {Boolean}
         */
        static open(objCoords, pngName1, pngName2, errorMsg := "") {
            try {
                ;// they NEED to be ordered this way so the values don't get overridden
                img1 := ImageSearch(&xi, &yi, objCoords.x1, objCoords.y1, objCoords.x2, objCoords.y2, "*2 " ptf.Resolve pngName1 ".png")
                img2 := ImageSearch(&xi, &yi, objCoords.x1, objCoords.y1, objCoords.x2, objCoords.y2, "*2 " ptf.Resolve pngName2 ".png")
                if !img1 && !img2
                    throw Error e
                if img1
                    return true
                MouseMove(xi, yi)
                SendInput("{Click}") ;this opens the inspector tab
                sleep 100
                return true
            } catch as e {
                block.Off() ;// just incase
                tool.Cust(errorMsg, 1,, 2)
                errorLog(e)
                Exit()
            }
        }

    }

    /**
     * A function to set the scale of a video within resolve
     * @param {Number} value is the number you want to type into the text field (100% in reslove requires a 1 here for example)
     * @param {String} property is the property you want this function to type a value into (eg. zoom)
     * @param {Integer} plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
     */
    static scale(value, property, plus := 0)
    {
        if (A_ThisHotkey != "") && (InStr(A_ThisHotkey, "&") || StrLen(A_ThisHotkey) = 2)
            {
                getHotkeys(&first, &second)
                KeyWait(second)
            }
        coord.w()
        block.On()
        SendInput(resolveSelectPlayhead)
        orig := obj.MousePos()
        ;// open the inspector tab
        this.open.open(this.open.inspect, "inspector", "inspector2", "inspector tab")
        ;// open the video tab
        this.open.open(this.open.vid, "video", "videoN", "video tab")
        if (!ImageSearch(&xz, &yz
                           , this.open.prop.x1, this.open.prop.y1
                           , this.open.prop.x2, this.open.prop.y2
                           , "*5 " ptf.Resolve property ".png")
           &&
           !ImageSearch(&xz, &yz
                           , this.open.prop.x1, this.open.prop.y1
                           , this.open.prop.x2, this.open.prop.y2
                           , "*5 " ptf.Resolve property "2.png"))
            {
                block.Off()
                errorLog(Error("Couldn't find the desired property.", -1, property),, 1)
                return
            }
        MouseMove(xz + plus, yz + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
        click
        SendInput(value)
        SendInput("{ENTER}")
        MouseMove(orig.x, orig.y)
        SendInput("{MButton}")
        block.Off()
    }

    /**
     * A function that gets nested in the resolve scale, x/y and rotation scripts
     * @param {Integer} data is what the script is typing in the text box to reset its value
     */
    static rfElse(data)
    ;this function, as you can probably tell, doesn't use an imagesearch. It absolutely SHOULD, but I don't use resolve and I guess I just never got around to coding in an imagesearch.
    {
        SendInput("{Click Up}")
        sleep 10
        Send(data)
        ;MouseMove, x, y ;if you want to press the reset arrow, input the windowspy SCREEN coords here then comment out the above Send^
        ;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
        ;alternatively you could also run imagesearches like in the other resolve functions to ensure you always end up in the right place
        sleep 10
        Send("{Enter}")
    }

    /**
     * A function to apply any effect to the clip you're hovering over within Resolve.
     * @param {String} folder is the name of your screenshots of the drop down sidebar option (in the effects window) you WANT to be active - both activated and deactivated
     * @param {String} effect is the name of the effect you want this function to type into the search box
     */
    static effect(folder, effect)
    ;This function will, in order;
    ;Check to see if the effects window is open on the left side of the screen
    ;Check to make sure the effects sidebar is expanded
    ;Ensure you're clicked on the appropriate drop down
    ;Open or close/reopen the search bar
    ;Search for your effect of choice, then drag back to the click you were hovering over originally
    {
        getHotkeys(&first, &second)
        KeyWait(second)
        if !winget.isFullscreen(&title, this.winTitle)
        {
            SplitPath(A_LineFile, &filename)
            tool.Cust("This function ``" A_ThisFunc "()`` may not work properly if the window isn't maximised`nFile: " filename "`nLine number: " A_LineNumber-14, 5.0)
            return
        }
        coord.w()
        block.On()
        orig := obj.MousePos()
        ;// open the effects panel
        this.open.open(this.open.effects, "effects2", "effects", "the effects button")
        ;// find the open/close button
        this.open.open(this.open.opnCls, "open", "closed", "the open/close button")
        ;// open the fx folder
        this.open.open(this.open.fx, folder, folder "2", "the fxfolder")
        ;// do a few imagesearches to figure out what to do next
        srch2 := ImageSearch(&xs, &ys, 8, 300, A_ScreenWidth/2, A_ScreenHeight, "*2 " ptf.Resolve "search2.png")
        srch3 := ImageSearch(&xs2, &ys2, 8, 300, A_ScreenWidth/2, A_ScreenHeight, "*2 " ptf.Resolve "search3.png")
        if !srch2 && !srch3
            {
                block.Off()
                errorLog(Error("Couldn't find the search button", -1),, 1)
                return
            }
        if srch2
            {
                MouseMove(xs, ys)
                SendInput("{Click}")
            }
        else
            {
                MouseMove(xs2, ys2)
                SendInput("{Click 2}")
            }
        sleep 50
        SendInput(effect)
        colError()
        {
            block.off
            errorLog(TargetError("Couldn't find the desired effect", -1, effect),, 1)
            return
        }
        colour := obj.MousePos()
        if !ImageSearch(&effx, &effy, colour.x - (A_ScreenWidth/3), colour.y, colour.x, colour.y + (A_ScreenHeight/3), "*2 " ptf.Resolve folder "3.png")
            colError()
        if !PixelSearch(&findx, &findy, effx + 5, effy, effx + 20, effy + 50, 0x000000)
            colError()
        MouseMove(findx, findy + 5, 2)
        SendInput("{Click Down}")
        MouseMove(orig.x, orig.y, 2) ;moves the mouse at a slower, more normal speed because resolve doesn't like it if the mouse warps instantly back to the clip
        SendInput("{Click Up}")
        block.Off()
        return
    }

    /**
     * A function to provide similar functionality within Resolve to my valuehold() function for premiere
     * @param {String} property refers to both of the screenshots (either active or not) for the property you wish to adjust
     * @param {Integer} plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
     * @param {Integer} rfelseval is the value you wish to pass to rfelse()
     */
    static valhold(property, plus, rfelseval)
    {
        coord.w()
        block.On()
        SendInput(resolveSelectPlayhead)
        orig := obj.MousePos()
        ;// open the inspector tab
        this.open.open(this.open.inspect, "inspector", "inspector2", "inspector tab")
        ;// open the video tab
        this.open.open(this.open.vid, "video", "videoN", "video tab")
        if (!ImageSearch(&xz, &yz
                           , this.open.prop.x1, this.open.prop.y1
                           , this.open.prop.x2, this.open.prop.y2
                           , "*5 " ptf.Resolve property ".png")
            &&
           !ImageSearch(&xz, &yz
                           , this.open.prop.x1, this.open.prop.y1
                           , this.open.prop.x2, this.open.prop.y2
                           , "*5 " ptf.Resolve property "2.png"))
            {
                block.Off()
                errorLog(Error("Couldn't find the desired property", -1, property),, 1)
                return
            }
        MouseMove(xz + plus, yz + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
        sleep 100
        SendInput("{Click Down}")
        if !GetKeyState(A_ThisHotkey, "P")
            {
                this.rfElse(rfelseval) ;do note rfelse doesn't use any imagesearch information and just uses raw pixel values (not a great idea), so if you have any issues, do look into changing that
                MouseMove(orig.x, orig.y)
                SendInput("{MButton}")
                block.Off()
                return
            }
        block.Off()
        KeyWait(A_ThisHotkey)
        SendInput("{Click Up}")
        MouseMove(orig.x, orig.y)
    }

    /**
     * A function to search for and press the horizontal/vertical flip button within Resolve
     * @param {String} button is the png name of a screenshot of the button you wish to click (either activated or deactivated)
     */
    static flip(button)
    {
        coord.w()
        block.On()
        orig := obj.MousePos()
        ;// open the inspector tab
        this.open.open(this.open.inspect, "inspector", "inspector2", "inspector tab")
        ;// open the video tab
        this.open.open(this.open.vid, "video", "videoN", "video tab")
        if (!ImageSearch(&xh, &yh
                           , this.open.prop.x1, this.open.prop.y1
                           , this.open.prop.x2, this.open.prop.y2
                           , "*5 " ptf.Resolve button ".png") &&
           !ImageSearch(&xh, &yh
                           , this.open.prop.x1, this.open.prop.y1
                           , this.open.prop.x2, this.open.prop.y2
                           , "*5 " ptf.Resolve button "2.png"))
            {
                block.Off()
                MouseMove(xpos, ypos)
                errorLog(Error("Couldn't find the desired button", -1, button),, 1)
            }
        MouseMove(xh, yh)
        SendInput("{Click}")
        MouseMove(orig.x, orig.y)
        block.Off()
    }

    /**
     * A function that allows you to adjust the gain of the selected clip within Resolve similar to my gain macros in premiere. You can't pull this off quite as fast as you can in premiere, but it's still pretty useful
     * @param {Integer} value is how much you want the gain to be adjusted by
     */
    static gain(value)
    {
        if !IsNumber(value)
            {
                ;// throw
                errorLog(TypeError("Invalid parameter type in Parameter #1", -1, amount),,, 1)
            }
        coord.w()
        block.On()
        SendInput(resolveSelectPlayhead)
        orig := obj.MousePos()
        ;// open the inspector tab
        this.open.open(this.open.inspect, "inspector", "inspector2", "inspector tab")
        ;// open the audio tab
        this.open.open(this.open.vid, "audio2", "audio", "audio tab")
        if (!ImageSearch(&xz, &yz
                            , this.open.prop.x1, this.open.prop.y1
                            , this.open.prop.x2, this.open.prop.y2
                            , "*5 " ptf.Resolve "volume.png") &&
            !ImageSearch(&xz, &yz
                            , this.open.prop.x1, this.open.prop.y1
                            , this.open.prop.x2, this.open.prop.y2
                            , "*5 " ptf.Resolve "volume2.png"))
            {
                block.Off()
                errorLog(Error("Couldn't find the desired property", -1),, 1)
                return
            }
        MouseMove(xz + 215, yz + 5) ;moves the mouse to the value next to volume. This function assumes x/y are linked
        SendInput("{Click 2}")
        orig := clip.clear()
        clip.copyWait()
        gain := A_Clipboard + value
        SendInput(gain)
        SendInput("{Enter}")
        MouseMove(orig.x, orig.y)
        SendInput("{MButton}")
        clip.returnClip(orig.storedClip)
        block.Off()
    }
}