/************************************************************************
 * @description Speed up interactions with discord. Use this class at your own risk! Automating discord is technically against TOS!!
 * @author tomshi
 * @date 2024/01/17
 * @version 1.4.9.2
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

/**
 * Please be aware that automating the discord client in any way is technically against TOS. While none of these scripts are likely to cause any issues, use this class at your own risk - I do not take any responsibility for anything that may happen to your account.
*/
class discord {

    static __New() {
        try {
            ;// attempt to grab user settings
            this.UserSettings := UserPref()
            this.disableAutoReplyPing := this.UserSettings.disc_disable_autoreply
            this.UserSettings := ""
        }
    }
    UserSettings := unset
    static logoCheck := false

    ;// set to false if you want discord to replies to leave the @ping enabled by default
    static disableAutoReplyPing := true

    ;// position you keep it
    static x := -1080
    static y := 34
    static width := 1080
    static height := 1600

    static slackX := -1068
    static slackY := 16
    static slackWidth := 1058
    static slackHeight := 840

    ;// other
    static exeTitle := "ahk_exe Discord.exe"
    static winTitle := this.exeTitle
    static class := "ahk_class Chrome_WidgetWin_1"
    static path := ptf.LocalAppData "\Discord\Update.exe --processStart Discord.exe"

    static surroundActive := false

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
     * This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in `..\Support Files\ImageSearch\disc[button].png` and automatically clicks the one you're after, allowing the user to more quickly navigate the UI.
     * - This function is **constantly** being broken as discord updates their logo/the text for words. When this happens you can try taking new screenshots to see if that fixes the issue.
     * - This function may encounter different behaviours depending on the orientation of the monitor that it's on/the resolution. It hasn't been tested on anything higher than a `1440p` monitor.
     * - This function automatically disables the `@ON` ping when replying to someone. This can be disabled by setting the class variable `disableAutoReplyPing` to `false` (or by adjusting the setting within `settingsGUI()`)
     * - ⚠️ *This function includes specific code for the reply button and requires the passed parameter to be `DiscReply.png`*
     * - ⚠️ *This function includes specific code for the delete button and requires the passed parameter to be `DiscDelete.png`*
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
            ;// searches for the button you've requested
            if ImageSearch(&xpos, &ypos, x-200, y-400,  x+200, y + yheight, "*2 " ptf.Discord button) {
                MouseMove(xpos, ypos)
                break
            }
            if (button == "DiscDelete.png" || button == "DiscEdit.png") && ImageSearch(&xpos, &ypos, x-200, y-400,  x+200, y + yheight, "*2 " ptf.Discord "report.png") {
                block.Off()
                errorLog(ValueError("User isn't hovering a message they sent.", -1),, 1)
                return
            }
            ;// if the button isn't found, we increase the search area
            sleep 50
            yheight += 100
            if A_Index > 4
                ToolTip(A_ThisFunc "() has attempted to find the desired button " A_Index " times")

            ;// after waiting over 0.5s the function will excecute the below
            if A_Index > 10 {
                ToolTip("")
                MouseMove(x, y) ;moves the mouse back to the original coords
                block.Off()
                errorLog(IndexError("Was unable to find the requested button", -1, button),, 1)
                return
            }
        }
        if (button == "DiscDelete.png") && (GetKeyState("Shift", "P")) || (button == "DiscReply.png" && this.disableAutoReplyPing = true) {
            ;// if the user is holding shift to indicate they want to immediately delete the message
            SendInput("{Shift Down}{Click}{Shift Up}")
            MouseMove(x, y)
            block.Off()
            return
        }
        SendInput("{Click}")
        sleep 100
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
     *
     * ⚠️ This function isn't perfect, dealing with the clipboard is sometimes incredibly slow and as such might cause noticeable delay at times, unintended characters appearing, or even just past clipboards being pasted instead of the intended text. I've done my best to avoid these issues as much as possible but at the end of the day windows is windows and there's only so much I can do about it. If I knew a way to detect if text is highlighted or not it might reduce some of these pitfalls, but at the current time I have yet to find a method that works with the discord client. ⚠️
     * - If the passed `char` variable is 2 characters long, the first character will be appended at the beginning of the highlighted text & the second character will be appended to the end of the highlighted text
     * - If the passed `char` variable is 2 characters long & you aren't highlighting anything OR it fails to wait for data, this function will attempt to highlight the chat window and send the hotkey that activated the function (by default)
     * @param {String} char the desired character(s) to wrap the text with. This parameter can be no more than 2 characters long
     * @param {String} onFailSend is the desired character you wish to be sent when `char` is 2 characters long and you aren't highlighting any text
     * @param {Object} timeWait is to set a custom time that each `ClipWait` will wait. Two values **MUST** be passed for this parameter to work correctly, they are; `{first: 0.05, second: 0.1}`. The `first` value is to determine how long the clipboard will wait while attempting to see if the user has anything highlighted. The `second` value is hhow long the clipboard will wait while attempting to add the user's highlighted text.
     */
    static surround(char, onFailSend := A_ThisHotkey, timeWait?)
    {
        if (!IsSet(timeWait) || Type(timeWait) != "object" ||
            !(timeWait.HasOwnProp("First") && timeWait.HasOwnProp("Second"))) {
                timeWait := {}
                timeWait.First := 0.1, timeWait.Second := 0.1
        }
        if Type(char) != "string" || Type(onFailSend) != "string" {
                ;// throw
                errorLog(TypeError("Incorrect Parameter Type passed to function", -1),,, 1)
            }
        __exit(returnClip) {
            block.Off()
            clip.returnClip(returnClip)
            this.surroundActive := false
        }
        ;// if the function is reactivated before the clipboard has been returned to normal
        ;// it will get confused and end up sending the clipboard, most likely when you don't want it to
        if this.surroundActive = true {
            loop {
                if A_Index > 40
                    return
                if this.surroundActive = false
                    break
                sleep 25
            }
        }
        this.surroundActive := true
        charLength := StrLen(char)
        if charLength > 2 {
                ;// throw
                errorLog(ValueError("Incorrect String Length in Parameter #1", -1, char),,, 1)
            }
        block.On("send")
        store := clip.clear()
        if !clip.copyWait(, timeWait.first, false) {
            SendInput(KSA.discHighlightChat)
            sendText := (charLength = 2 && A_ThisHotkey != "") ? onFailSend : char
            A_Clipboard := sendText
            if !ClipWait(timeWait.second) {
                __exit(store.storedClip)
                return
            }
            SendInput("{Ctrl Down}v{Ctrl Up}")
            SetTimer((*) => (clip.returnClip(store.storedClip), this.surroundActive := false), -25)
            block.Off()
            return
        }
        ;// clearing the clipboard again in an attempt to fix this function sometimes hanging and sending keys seemingly randomly
        middle := A_Clipboard
        clip.clear()
        A_Clipboard := (charLength = 2) ? SubStr(char, 1, 1) middle SubStr(char, 2, 1) : char middle char
        if !ClipWait(timeWait.second) {
            __exit(store.storedClip)
            return
        }
        SendInput("{ctrl down}v{ctrl up}")
        block.Off()
        SetTimer((*) => (clip.returnClip(store.storedClip), this.surroundActive := false), -25)
        return
    }
}