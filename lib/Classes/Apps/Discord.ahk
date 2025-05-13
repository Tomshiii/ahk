/************************************************************************
 * @description Speed up interactions with discord. Use this class at your own risk! Automating discord is technically against TOS!!
 * @author tomshi
 * @date 2025/05/13
 * @version 1.6.5
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
#Include <Other\UIA\UIA>
#Include <Classes\winGet>
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

    ;// set to false if you want discord to replies to leave the @ping enabled by default
    static disableAutoReplyPing := true

    ;// position you keep it
    static x := -1080
    static y := 10
    static width  := 1080
    static height := 1600

    static slackX := -1068
    static slackY := 10
    static slackWidth  := 1058
    static slackHeight := 840

    ;// other
    static exeTitle := "ahk_exe Discord.exe"
    static winTitle := this.exeTitle
    static class    := "ahk_class Chrome_WidgetWin_1"
    static path     := ptf.LocalAppData "\Discord\Update.exe --processStart Discord.exe"

    static surroundActive := false

    static checkingUnread := false

    /**
     * This function uses UIA to look for buttons within the right click context menu and automatically clicks the one you're after, allowing the user to more quickly navigate the UI.
     * - This function automatically disables the `@ON` ping when replying to someone. This can be disabled by setting the class variable `disableAutoReplyPing` to `false` (or by adjusting the setting within `settingsGUI()`)
     * @param {String} button is the name of the button you want the function to press. Must be; `reply`, `edit`, `react`, `delete`, `report`
     */
    static button(button)
    {
        keys.allWait("second")
        MouseGetPos(&x, &y, &win)
        if WinGetProcessName(win) != WinGetProcessName(this.winTitle)
            return

        blocker := block_ext()
        blocker.On()
        SendInput("{RButton}") ;// this opens the right click context menu on the message you're hovering over
        currentTitle := WinGet.Title()
        dms := true
        if InStr(currentTitle, "|") ;// determines if we're in dm's or a server
            dms := false
        try DiscordEl := UIA.ElementFromHandle(currentTitle A_Space this.exeTitle)
        catch {
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            blocker.Off()
            return
        }
        if !IsObject(DiscordEl) {
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            blocker.Off()
            return
        }

        switch button {
            case "reply":
                if dms = true || this.disableAutoReplyPing != true {
                    try DiscordEl.WaitElement({LocalizedType: "menu item", A: "message-reply"}, 1500).ControlClick()
                    blocker.Off()
                    return
                }
                if !findReply := DiscordEl.WaitElement({LocalizedType: "menu item", A: "message-reply"}, 1500) {
                    blocker.Off()
                    return
                }
                try findReply.ControlClick()
            case "edit": DiscordEl.WaitElement({LocalizedType: "menu item", A: "message-edit"}, 1500).ControlClick()
            case "react": DiscordEl.WaitElement({LocalizedType: "menu item", A: "message-add-reaction"}, 1500).ControlClick()
            case "report": DiscordEl.WaitElement({LocalizedType: "menu item", A: "message-report"}, 1500).ControlClick()
            case "delete":
                shift := false
                if (GetKeyState("Shift", "P")) {
                    shift := true
                    SendInput("{Shift Down}")
                }
                DiscordEl.WaitElement({LocalizedType: "menu item", A: "message-delete"}, 1500).ControlClick()
                if shift = true
                    SendInput("{Shift Up}")
        }
        blocker.Off()
    }

    /**
     * This function will search for and automatically click on either unread servers or unread channels depending on which image you feed into the function
     *
     * @param {String} which whether you wish to search for unread `servers` or `channels`.
     */
    static Unread(which := "servers")
    {
        if !WinActive(this.winTitle)
            WinActivate(this.winTitle)
        coord.s()
        origMousePos := obj.MousePos()
        WinGetPos(&xpos, &ypos, &width, &height, this.winTitle)
        saveY := ypos
        currentTitle := WinGet.Title()
        try DiscordEl := UIA.ElementFromHandle(currentTitle A_Space this.exeTitle)
        catch {
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            return
        }
        header := DiscordEl.FindElement({Type: "50026 (Group)", Name: "Channel header", LocalizedType: "region"})
        try directM := header.FindElement({LocalizedType: "text", Name: "Direct Message"})
        try groupDM := header.FindElement({LocalizedType: "text", Name: "Group DM"})
        headerText := (IsSet(directM) || IsSet(groupDM)) ? true : false

        __findGrey(x, y, returnVals := false) {
            coord.s()
            if PixelSearch(&x, &y, x, y, x + 8, saveY + height - 60, 0xe3e3e6) {
                if returnVals = true
                    return {x: x, y: y}
                MouseMove(x+20, y+3, 2)
                SendInput("{Click}")
                MouseMove(origMousePos.x, origMousePos.y, 2)
            }
        }

        switch which {
            case "servers":
                getServerName := (headerText = true || !InStr(currentTitle, "|") && SubStr(currentTitle, 1, 1) = "@") ? "Direct Messages" : SubStr(currentTitle, start := InStr(currentTitle, "|", , -1) + 1, StrLen(currentTitle) - (start + 9))
                activeServer := DiscordEl.FindElement({LocalizedType: "tree item", Name: getServerName, matchmode:"Substring"})
                findFirstGrey := __findGrey(xpos, ypos, true)
                if !findFirstGrey
                    return
                serverY := (getServerName = "Direct Messages") ? activeServer.location.y + 3 : activeServer.location.y + 1
                if findFirstGrey.y != serverY {
                    __findGrey(xpos, ypos)
                    try DiscordEl.WaitElement({Name: "Mark as Read", LocalizedType: "button"}).ControlClick()
                    return
                }
                ypos := activeServer.location.y + activeServer.location.h + 2
                __findGrey(xpos, ypos, height)
                try DiscordEl.WaitElement({Name: "Mark as Read", LocalizedType: "button"}).ControlClick()
                return
            case "channels":
                if headerText = true {
                    errorLog(TargetError("You're currently in Direct Messages, Channels don't exist.", -1),, true)
                    return
                }
                getLoc := DiscordEl.FindElement({LocalizedType: "group", AutomationId: "channels"})

                __findGrey(getLoc.location.x, getLoc.location.y, getLoc.location.h)
                try DiscordEl.WaitElement({Name: "Mark as Read", LocalizedType: "button"}).ControlClick()
                return
        }
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
     * > ⚠️ This function isn't perfect, dealing with the clipboard is sometimes incredibly slow and as such might cause noticeable delay at times, unintended characters appearing, or even just past clipboards being pasted instead of the intended text. I've done my best to avoid these issues as much as possible but at the end of the day windows is windows and there's only so much I can do about it. If I knew a way to detect if text is highlighted or not it might reduce some of these pitfalls, but at the current time I have yet to find a method that works with the discord client. ⚠️
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
        if !clip.copyWait(unset, timeWait.first, false) {
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
        middle := clip.clear()
        A_Clipboard := (charLength = 2) ? SubStr(char, 1, 1) middle.storedClip SubStr(char, 2, 1) : char middle.storedClip char
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