/************************************************************************
 * @description Speed up interactions with discord. Use this class at your own risk! Automating discord is technically against TOS!!
 * @author tomshi
 * @date 2023/08/04
 * @version 1.4.6
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\clip>
#Include <Classes\keys>
#Include <Classes\errorLog>
#Include <Functions\checkImg>
#Include <Functions\change_msgButton>
; }

class discord {

    static logoCheck := false

    ;// position you keep it
    static x := -1080
    static y := -209
    static width := 1080
    static height := 1600

    static slackX := -1068
    static slackY := -187
    static slackWidth := 1058
    static slackHeight := 840

    ;// other
    static exeTitle := "ahk_exe Discord.exe"
    static winTitle := this.exeTitle
    static class := "ahk_class Chrome_WidgetWin_1"
    static path := ptf.LocalAppData "\Discord\Update.exe --processStart Discord.exe"

    /**
     * This function is called by a few other User facing functions and is designed to alert the user when discord has gone and changed the logo button within the main UI. This logo changing breaks those functions in certain ways.
     * The discord logo may also appear slightly different on the system based off whether the user has discord on a landscape/portrait oriented monitor. I have taken screenshots of both and try to keep them updated but they may break at any time.
     */
    __logoCheck() {
        WinGetPos(&nx, &ny, &width, &height, discord.winTitle)
        if !obj.imgSrchMulti({x1: 0, y1: 0, x2: 100, y2: 100},,,
                                        , ptf.Discord "dm1.png", ptf.Discord "dm1_2.png"
                                        , ptf.Discord "dm2.png", ptf.Discord "dm2_2.png")
            {
                title := "Logo Match Not Found"
                SetTimer(change_msgButton.Bind(title, "OK", "Open Dir"), 25) ;// calls change_msgButton()
                alert := MsgBox(Format("
                (
                    Discord's logo button appears to have changed (very first button on the left of the UI to get to dms/friends). This logo is needed for a few scripts to function correctly.`n
                    Please take new screenshots and replace:
                    - {1}dm1.png
                        (portrait)
                    - {1}dm1_2.png
                        (landscape)
                    - {1}dm2.png
                        (portrait)
                    - {1}dm2_2.png
                        (landscape)

                    Then reload all scripts.
                )", ptf.Discord), title, "4 48 4096")
                if alert = "No" {
                    if WinExist(ptf.Discord)
                        {
                            WinActivate(ptf.Discord)
                            return
                        }
                    Run(ptf.Discord)
                }
                Exit()
            }
        discord.logoCheck := true
    }

    /**
     * move to coords and click
     */
    __move_click(x, y) {
        MouseMove(x, y)
        SendInput("{Click}")
    }

    /**
     * move to coords, unblock inputs and exit
     */
    __move_exit(x, y) {
        MouseMove(x, y) ;moves the mouse back to the original coords
        block.Off()
        Exit()
    }

    /**
     * potential blue colours for the `@ON` in discord when you reply to someone
     */
    colours := [0x259fcf, 0x3047a2, 0x2884a9, 0x30318a, 0x289AD5, 0x299AD5]

    /**
     * This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \Support Files\ImageSearch\disc[button].png
     *
     * This function is constantly being broken as discord updates their logo/the @ reply ping button. When this happens you can try taking new screenshots to see if that fixes the issue.
     *
     * This function may encounter different behaviours depending on the orientation of the monitor that it's on/the resolution. It hasn't been tested on anything higher than a `1440p` monitor.
     *
     * *This function includes specific code for the reply button and requires the passed parameter to be `DiscReply.png`*
     * *This function includes specific code for the delete button and requires the passed parameter to be `DiscDelete.png`*
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
        if !this.logoCheck
            this().__logoCheck()
        yheight := 400
        keys.allWait("second")
        MouseGetPos(&x, &y)
        WinGetPos(&nx, &ny, &width, &height, this.winTitle) ;gets the width and height to help this function work no matter how you have discord
        block.On()
        SendInput("{RButton}") ;this opens the right click context menu on the message you're hovering over
        sleep 50 ;sleep required so the right click context menu has time to open
        loop {
            if ImageSearch(&xpos, &ypos, x-200, y-400,  x+200, y + yheight, "*2 " ptf.Discord button) ;searches for the button you've requested
                {
                    MouseMove(xpos, ypos)
                    break
                }
            if (button == "DiscDelete.png" || button == "DiscEdit.png") && ImageSearch(&xpos, &ypos, x-200, y-400,  x+200, y + yheight, "*2 " ptf.Discord "report.png") ;searches for the button you've requested
                {
                    block.Off()
                    errorLog(ValueError("User isn't hovering a message they sent.", -1),, 1)
                    return
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
        if (button == "DiscDelete.png") && (GetKeyState("Shift", "P")) {
            ;// if the user is holding shift to indicate they want to immediately delete the message
            SendInput("{Shift Down}{Click}{Shift Up}")
            MouseMove(x, y)
            block.Off()
            return
        }
        SendInput("{Click}")
        sleep 100
        if button != "DiscReply.png" || (!ImageSearch(&x2, &y2, 0, 0, 100, 100, "*2 " ptf.Discord "dm1.png") && !ImageSearch(&x2, &y2, 0, 0, 100, 100, "*2 " ptf.Discord "dm1_2.png"))
            this().__move_exit(x, y)  ;YOU MUST CALL YOUR REPLY IMAGESEARCH FILE "DiscReply.png" FOR THIS PART OF THE CODE TO WORK - ELSE CHANGE THIS VALUE TOO
        loop {
                if ImageSearch(&xdir, &ydir, width/2, height-115, width, height, "*2 " ptf.Discord "DiscDirReply.png") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. If you prefer to leave that on, remove from the above sleep 100, to the `end:` below. The coords here are to search the entire window (but only half the windows height) - (that's what the WinGetPos is for) for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish but it isn't really neccessary.
                    {
                        this().__move_click(xdir, ydir)
                        break
                    }
                ;// if the loop hasn't found the image after 5 attempts, the function will fallback to searching for some of the blue pixel colours in the word itself as they aren't found anywhere else
                if A_Index > 5
                    {
                        found := false
                        block.Off()
                        loop this().colours.Length {
                            block.Off()
                            if PixelSearch(&colX, &colY, width/2, height-115, width, height, Format("{:#x}", this().colours[A_Index]), 2)
                                {
                                    this().__move_click(colX, colY)
                                    found := true
                                    break
                                }
                        }
                        if found = true
                            break
                    }
                if A_Index > 10
                    {
                        errorLog(IndexError("Was unable to find the @ reply ping button", -1, button),, 1)
                        break
                    }
            }
        this().__move_exit(x, y)
    }

    /**
     * This function will search for and automatically click on either unread servers or unread channels depending on which image you feed into the function
     *
     * @param {String} which is simply which image you want to feed into the function. I have it left blank for servers and `"2"` for channels
     */
    static Unread(which := "")
    {
        if !this.logoCheck
            this().__logoCheck()
        end(var := 20) {
            MouseMove(x + var, y, 2)
            SendInput("{Click}")
            if which = 2
                {
                    sleep 150
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
                    sleep 100
                    ;// sometimes if something hovers over the mouse before it can click the mark as read
                    ;// button, it can stop the mouse from focusing on the element
                    ;// so we jiggle it around in the hops to shake the hover element
                    MouseMove(x2+10, y2+4, 1)
                    sleep 500
                    MouseMove(50, 5, 2, "R")
                    sleep 150
                    MouseMove(-40, -5, 2, "R")
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
        if !obj.imgSrchMulti({x1:0 + x2, y1:0, x2:50 + y2, y2:height},, &x, &y, ptf.Discord "\unread" which "_1.png", ptf.Discord "\unread" which "_2.png", ptf.Discord "\unread" which "_3.png") {
                tool.Cust("Couldn't find any unread " message)
                return
            }
        end()
    }

    /**
     * This function clicks the logo button in discord to access your friends/messages
     */
    static DMs() {
        WinActivate(this.winTitle)
        block.On()
        MouseGetPos(&origx, &origy)
        MouseMove(34, 52, 2)
        SendInput("{Click}")
        MouseMove(origx, origy, 2)
        block.Off()
    }

    /**
     * This function allows the user to wrap the highlighted text with whatever characters they want (eg. ``, (), etc). I created this mostly because I got too use to VSCode offering this feature that I kept trying to do it in discord.
     * ```
     * ;// If the passed `char` variable is 2 characters long, the first character will be appended at the beginning of the highlighted text & the second character will be appended to the end of the highlighted text
     * ;// If the passed `char` variable is 2 characters long & you aren't highlighting anything OR it fails to wait for data, this function will attempt to highlight the chat window and send the hotkey that activated the function (by default)
     * ```
     * @param {String} char the desired character(s) to wrap the text with. This parameter can be no more than 2 characters long
     * @param {String} onFailSend is the desired character you wish to be sent when `char` is 2 characters long and you aren't highlighting any text
     * @param {Object} timeWait is to set a custom time that each `ClipWait` will wait. Two values **MUST** be passed for this parameter to work correctly, they are; `{first: 0.05, second: 0.1}`. The `first` value is to determine how long the clipboard will wait while attempting to see if the user has anything highlighted. The `second` value is hhow long the clipboard will wait while attempting to add the user's highlighted text.
     */
    static surround(char, onFailSend := A_ThisHotkey, timeWait?)
    {
        if (!IsSet(timeWait) || Type(timeWait) != "object" ||
            !(timeWait.HasOwnProp("First") && timeWait.HasOwnProp("Second"))) {
                timeWait := {}
                timeWait.First := 0.05, timeWait.Second := 0.1
        }
        if Type(char) != "string" || Type(onFailSend) != "string" {
                ;// throw
                errorLog(TypeError("Incorrect Parameter Type passed to function", -1),,, 1)
            }
        charLength := StrLen(char)
        if charLength > 2 {
                ;// throw
                errorLog(ValueError("Incorrect String Length in Parameter #1", -1, char),,, 1)
            }
        block.On("send")
        store := clip.clear()
        if !clip.copyWait(store.storedClip, timeWait.first, false)
            {
                SendInput(KSA.discHighlightChat)
                if charLength = 2 && A_ThisHotkey != ""
                    SendText(onFailSend)
                else
                    SendText(char)
                ; clip.delayReturn(store.storedClip)
                block.Off()
                return
            }
        ;// clearing the clipboard again in an attempt to fix this function sometimes hanging and sending keys seemingly randomly
        middle := A_Clipboard
        clip.clear()
        A_Clipboard := (charLength = 2) ? SubStr(char, 1, 1) middle SubStr(char, 2, 1) : char middle char
        if !ClipWait(timeWait.second)
            {
                block.Off()
                clip.delayReturn(store.storedClip)
                return
            }
        SendInput("^v")
        block.Off()
        clip.delayReturn(store.storedClip)
    }
}