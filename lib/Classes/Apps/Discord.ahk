/************************************************************************
 * @description Speed up interactions with discord
 * @author tomshi
 * @date 2023/01/10
 * @version 1.1.5
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\clip>
#Include <Functions\errorLog>
#Include <Functions\checkImg>
; }

class discord {

    ;position you keep it
    static x := -1080
    static y := -270
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
     * This function is constantly being broken as discord updates their logo/the @ reply ping button. When this happens you can try taking new screenshots to see if that fixes the issue.
     *
     * *This function includes specific code for the reply button and requires the passed parameter to be `DiscReply.png`*
     * @param {String} button is the png name of a screenshot of the button you want the function to press.
     * ```
     * ;NOTE this function may only work if you use the same display settings. Otherwise you may need your own screenshots.
     * ;dark theme
     * ;chat font scaling: 20px
     * ;space between message groups: 16px
     * ;zoom level: 100
     * ;saturation; 70%
     * ```
     */
    static button(button)
    {
        yheight := 400
        getHotkeys(&first, &second)
        KeyWait(first)
        MouseGetPos(&x, &y)
        WinGetPos(&nx, &ny, &width, &height, "A") ;gets the width and height to help this function work no matter how you have discord
        block.On()
        SendInput("{RButton}") ;this opens the right click context menu on the message you're hovering over
        sleep 50 ;sleep required so the right click context menu has time to open
        loop {
            if ImageSearch(&xpos, &ypos, x-200, y-400,  x+200, y + yheight, "*2 " ptf.Discord button) ;searches for the button you've requested
                {
                    MouseMove(xpos, ypos)
                    break
                }
            ;// if the button isn't found, we increase the search area
            sleep 50
            yheight += 100
            if A_Index > 4
                ToolTip(A_ThisFunc "() has attempted to find the desired button " A_Index " times")
            if A_Index > 10 ;after waiting over 0.5s the function will excecute the below
                {
                    ToolTip("")
                    MouseMove(x, y) ;moves the mouse back to the original coords
                    block.Off()
                    errorLog(IndexError("Was unable to find the requested button", -1, button),, 1)
                    return
                }
        }
        SendInput("{Click}")
        sleep 100
        if button != "DiscReply.png" || !ImageSearch(&x2, &y2, nx, ny/3, width, height, "*2 " ptf.Discord "dm1.png")
            goto end  ;YOU MUST CALL YOUR REPLY IMAGESEARCH FILE "DiscReply.png" FOR THIS PART OF THE CODE TO WORK - ELSE CHANGE THIS VALUE TOO
        move_click(x, y) {
            MouseMove(x, y)
            SendInput("{Click}")
        }
        loop {
                if ImageSearch(&xdir, &ydir, 0, height/2, width, height, "*2 " ptf.Discord "DiscDirReply.png") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. If you prefer to leave that on, remove from the above sleep 100, to the `end:` below. The coords here are to search the entire window (but only half the windows height) - (that's what the WinGetPos is for) for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish but it isn't really neccessary.
                    {
                        move_click(xdir, ydir)
                        break
                    }
                ;// if the loop hasn't found the image after 5 attempts, the function will fallback to searching for some of the blue pixel colours in the word itself as they aren't found anywhere else
                if A_Index > 5
                    {
                        colours := [0x259fcf, 0x3047a2, 0x2884a9, 0x30318a]
                        found := false
                        loop colours.Length {
                            if PixelSearch(&colX, &colY, width/2, ny/3, width, height, colours[A_Index], 2)
                                {
                                    move_click(colX, colY)
                                    found := true
                                    break
                                }
                        }
                        if found
                            break
                    }
                if A_Index > 10
                    {
                        errorLog(IndexError("Was unable to find the @ reply ping button", -1, button),, 1)
                        break
                    }
            }
        end:
        coord.w()
        MouseMove(x, y) ;moves the mouse back to the original coords
        block.Off()
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
            if which = 2
                {
                    loop { ;// this loop will attempt to mark the channel as read
                        if A_Index > 15 ;1.5s
                            {
                                MouseGetPos(&checkX, &checkY)
                                if (checkX = x + var) && (checkY = y)
                                    MouseMove(xPos, yPos, 2)
                                Exit()
                            }
                        sleep 100
                        if ImageSearch(&x2, &y2, 0, 0, width, height/3, "*2 " ptf.Discord "\markread.png")
                            break
                    }
                    MouseMove(x2, y2, 2)
                    SendInput("{Click}")
                }
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
        if !WinActive(this.winTitle)
            WinActivate(this.winTitle)
        MouseGetPos(&xPos, &yPos)
        WinGetPos(,, &width, &height, this.winTitle)
        if which = ""
            {
                if ImageSearch(&x, &y, 0 + x2, 0, 80, height, "*2 " ptf.Discord "\unread3.png")
                    end(-20)
            }
        if (
            (
                !checkImg(ptf.Discord "\unread" which "_1.png", &x, &y, 0 + x2, 0, 50 + y2, height) &&
                !checkImg(ptf.Discord "\unread" which "_2.png", &x, &y, 0 + x2, 0, 50 + y2, height)
            )
        )
            {
                tool.Cust("any unread " message,, 1)
                return
            }
        end()
    }

    /**
     * This function allows the user to wrap the highlighted text with whatever characters they want (eg. ``, (), etc). I created this mostly because I got too use to VSCode offering this feature that I kept trying to do it in discord.
     * ```
     * ;// If the passed `char` variable is 2 characters long, the first character will be appended at the beginning of the highlighted text & the second character will be appended to the end of the highlighted text
     * ;// If the passed `char` variable is 2 characters long & you aren't highlighting anything OR it fails to wait for data, this function will attempt to highlight the chat window and send the hotkey that activated the function (by default)
     * ```
     * @param {String} char the desired character(s) to wrap the text with. This parameter can be no more than 2 characters long
     * @param {String} onFailSend is the desired character you wish to be sent when `char` is 2 characters long and you aren't highlighting any text
     */
    static surround(char, onFailSend := A_ThisHotkey)
    {
        if Type(char) != "string" || Type(onFailSend) != "string" {
                ;// throw
                errorLog(TypeError("Incorrect Parameter Type passed to function", -1),,, 1)
            }
        charLength := StrLen(char)
        if charLength > 2 {
                ;// throw
                errorLog(ValueError("Incorrect String Length in Parameter #1", -1, char),,, 1)
            }
        char1 := (charLength = 2) ? SubStr(char, 1, 1) : char
        char2 := (charLength = 2) ? SubStr(char, 2, 1) : char
        store := clip.clear()
        if !clip.copyWait(store.storedClip, 0.05)
            {
                tool.Cust("") ;// attempts to suppress the tooltip generated by clip.copyWait()
                SendInput(discHighlightChat)
                if charLength = 2 && A_ThisHotkey != ""
                    SendInput(onFailSend)
                else
                    SendInput(char)
                return
            }
        A_Clipboard := char1 A_Clipboard char2
        SendInput("^v")
        clip.delayReturn(store.storedClip)
    }
}