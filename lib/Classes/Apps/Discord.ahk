/************************************************************************
 * @description Speed up interactions with discord
 * @author tomshi
 * @date 2022/11/30
 * @version 1.0.1
 ***********************************************************************/

; { \\ #Includes
; #Include <\KSA\Keyboard Shortcut Adjustments>
#Include <\Classes\block>
#Include <\Classes\coord>
#Include <\Classes\ptf>
#Include <\Classes\tool>
#Include <\Functions\errorLog>
; }

class discord {

    ;position you keep it
    static x := -1080
    static y := -274
    static width := 1080
    static height := 1600

    ;other
    static exeTitle := "ahk_exe Discord.exe"
    static winTitle := this.exeTitle
    static class := "ahk_class Chrome_WidgetWin_1"
    static path := ptf.LocalAppData "\Discord\Update.exe --processStart Discord.exe"

    /**
     * This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \Support Files\ImageSearch\disc[button].png
     *
     * @param {String} button in the png name of a screenshot of the button you want the function to press
     */
    static button(button)
    ;NOTE THESE WILL ONLY WORK IF YOU USE THE SAME DISPLAY SETTINGS AS ME (otherwise you'll need your own screenshots.. tbh you'll probably need your own anyway). YOU WILL LIKELY NEED YOUR OWN SCREENSHOTS AS I HAVE DISCORD ON A VERTICAL SCREEN SO ALL MY SCALING IS WEIRD
    ;dark theme
    ;chat font scaling: 20px
    ;space between message groups: 16px
    ;zoom level: 100
    ;saturation; 70%
    ;ensure this function only fires if discord is active ( #HotIf WinActive("ahk_exe Discord.exe") ) - VERY IMPORTANT
    {
        yheight := 400
        getHotkeys(&first, &second)
        KeyWait(first) ;use A_PriorKey when you're using 2 buttons to activate a macro
        coord.w()
        MouseGetPos(&x, &y)
        WinGetPos(&nx, &ny, &width, &height, "A") ;gets the width and height to help this function work no matter how you have discord
        ;MsgBox("x " nx "`ny " ny "`nwidth " width "`nheight " height) ;testing
        block.On()
        click("right") ;this opens the right click context menu on the message you're hovering over
        sleep 50 ;sleep required so the right click context menu has time to open
        loop {
            if ImageSearch(&xpos, &ypos, x - "200", y -"400",  x + "200", y + yheight, "*2 " ptf.Discord button) ;searches for the button you've requested
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
                    block.Off()
                    tool.Cust("the requested button after " A_Index " attempts", 2000, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                    errorLog(, A_ThisFunc "()", "Was unable to find the requested button", A_LineFile, A_LineNumber)
                    return
                }
        }
        Click
        sleep 100
        if button != "DiscReply.png" || !ImageSearch(&x2, &y2, nx, ny/"3", width, height, "*2 " ptf.Discord "dm1.png")
            goto end  ;YOU MUST CALL YOUR REPLY IMAGESEARCH FILE "DiscReply.png" FOR THIS PART OF THE CODE TO WORK - ELSE CHANGE THIS VALUE TOO
        loop {
                if ImageSearch(&xdir, &ydir, 0, height/"2", width, height, "*2 " ptf.Discord "DiscDirReply.png") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. If you prefer to leave that on, remove from the above sleep 100, to the `end:` below. The coords here are to search the entire window (but only half the windows height) - (that's what the WinGetPos is for) for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish but it isn't really neccessary.
                    {
                        ;ToolTip("")
                        MouseMove(xdir, ydir) ;moves to the @ location
                        Click
                        break
                    }
                ;ToolTip(A_Index)
                if A_Index > 10
                    {
                        tool.Cust("the @ ping button",, 1) ;useful tooltip to help you debug when it can't find what it's looking for
                        errorLog(, A_ThisFunc "()", "Was unable to find the @ reply ping button", A_LineFile, A_LineNumber)
                        break
                    }
            }
        end:
        MouseMove(x, y) ;moves the mouse back to the original coords
        block.Off()
    }

    /**
     * This function will toggle the location of discord's window position
     */
    static location()
    {
        position0 := [4480, -123, 1081, 1537] ;we use position0 as a reference later to compare against another value.
        position1 := [-1080, 75, 1080, 1537] ;we use position1 as a reference later to compare against another value.
        disc0() { ;define your first (defult) position here
            WinMove(position0[1], position0[2], position0[3], position0[4], "ahk_exe Discord.exe")
        }
        disc1() { ;define your second position here
            WinMove(position1[1], position1[2], position1[3], position1[4], "ahk_exe Discord.exe")
        }
        try { ;this try is here as if you close a window, then immediately try to fire this function there is no "original" window
            original := WinGetID("A")
        } catch as e {
            tool.Cust("you tried to assign a closed`n window as the last active", 4000)
            errorLog(e, A_ThisFunc "()")
            SendInput("{Click}")
            return
        }
        static toggle := 0 ;this is what allows us to toggle discords position
        if !WinExist("ahk_exe Discord.exe")
            {
                run(ptf.LocalAppData "\Discord\Update.exe --processStart Discord.exe") ;this will run discord
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
                tool.Cust("stop spamming the function please`nthe functions value was too large/small")
                errorLog(, A_ThisFunc "()", "Function hit an unexpected toggle number", A_LineFile, A_LineNumber)
                return
            }
        try { ;this is here once again to ensure ahk doesn't crash if the original window doesn't actual exist anymore
            WinActivate(original)
        } catch as e {
            tool.Cust("couldn't find original window", 2000)
            errorLog(e, A_ThisFunc "()")
            return
        }
    }

    /**
     * This function will search for and automatically click on either unread servers or unread channels depending on which image you feed into the function
     *
     * @param {String} which is simply which image you want to feed into the function. I have it left blank for servers and `"2"` for channels
     */
    static Unread(which := "")
    {
        end(var := 20) {
            MouseMove(x + var, y, 2)
            SendInput("{Click}")
            MouseMove(xPos, yPos, 2)
            Exit()
        }
        switch which {
            default:
                x2 := 0
                y2 := 0
                message := "servers"
            case 2:
                x2 := 70
                y2 := 30
                message := "channels"
        }
        MouseGetPos(&xPos, &yPos)
        WinGetPos(,,, &height)
        if which = ""
            {
                if ImageSearch(&x, &y, 0 + x2, 0, 80, height, "*2 " ptf.Discord "\unread3.png")
                    end(-20)
            }
        if !ImageSearch(&x, &y, 0 + x2, 0, 50 + y2, height, "*2 " ptf.Discord "\unread" which ".png") || !IsSet(x)
            {
                tool.Cust("any unread " message,, 1)
                return
            }
        end()
    }
}