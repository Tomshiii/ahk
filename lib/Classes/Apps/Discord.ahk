/************************************************************************
 * @description Speed up interactions with discord. Use this class at your own risk! Automating discord is technically against TOS!!
 * @author tomshi
 * @date 2026/11/12
 * @version 1.8.2
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\block.ahk
#Include Classes\coord.ahk
#Include Classes\ptf.ahk
#Include Classes\tool.ahk
#Include Classes\clip.ahk
#Include Classes\keys.ahk
#Include Classes\errorLog.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\winGet.ahk
#Include Classes\notifyExt.ahk
#Include Classes\obj.ahk
#Include Classes\null.ahk
#Include Other\UIA\UIA.ahk
; }

/**
 * Please be aware that automating the discord client in any way is technically against TOS. While none of these scripts are likely to cause any issues, use this class at your own risk - I do not take any responsibility for anything that may happen to your account.
*/
class discord {

    ;// position you keep it
    static x := -1080
    static y := -115
    static width  := 1080
    static height := 1600

    static slackX := -1075
    static slackY := -114
    static slackWidth  := 1070
    static slackHeight := 953

    ;// other
    static exeTitle := "ahk_exe Discord.exe"
    static winTitle := this.exeTitle
    static class    := "ahk_class Chrome_WidgetWin_1"
    static path     := ptf.LocalAppData "\Discord\Update.exe --processStart Discord.exe"
    static ico      := ptf.LocalAppData "\Discord\app.ico"

    static surroundActive := false
    static checkingUnread := false
    static discordEl := false
    static discCacheRequest := false

    /**
     * This function uses UIA to look for buttons within the right click context menu and automatically clicks the one you're after, allowing the user to more quickly navigate the UI.
     * - This function automatically disables the `@ON` ping when replying to someone. This can be disabled by setting the class variable `disableAutoReplyPing` to `false` (or by adjusting the setting within `settingsGUI()`)
     * @param {String} button is the name of the button you want the function to press. Must be; `reply`, `edit`, `react`, `delete`, `report`
     */
    static button(button)
    {
        if !currentTitle := WinGet.Title()
            return
        coord.s()
        try mousePos := obj.mousePos()
        try proc := WinGetProcessName(mousePos.win)
        if !IsSet(proc) || proc != "Discord.exe"
            return
        blocker := block_ext()
        blocker.On()

        if !this.discordEl {
            try {
                notifyExt.showIfNotExist('discordGenCache',, "Generating Discord cache...`nThis may take a moment", this.ico,,, "DUR=4 POS=BL bdr=0x5764F0 show=Fade@250 hide=Fade@250 maxW=400")
                this.discCacheRequest := UIA.CreateCacheRequest(["Type", "LocalizedType", "AutomationId", "Name"],, 5)
                this.DiscordEl := UIA.ElementFromHandle(this.exeTitle, this.discCacheRequest, false)
            }
        }
        if !this.DiscordEl || !IsObject(this.DiscordEl) {
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            blocker.Off()
            notifyExt.deleteIfExist('discordGenCache')
            return
        }

        switch button {
            case "react":
                newel := this.__uiaMsgUnderCursor(mousePos)
                buttonBar := this.__getCurrentBar(newel, "Add Reaction")
                if buttonBar = null {
                    blocker.Off(), notifyExt.deleteIfExist('discordGenCache')
                    return
                }
                buttonBar.button.Invoke()
                blocker.Off(), notifyExt.deleteIfExist('discordGenCache')
                return
            case "delete":
                newel := this.__uiaMsgUnderCursor(mousePos)
                buttonBar := this.__getCurrentBar(newel, "Delete")
                if buttonBar = null
                    goto continueDefault
                SendInput("{Shift down}")
                buttonBar.button.ControlClick()
                SendInput("{Shift up}")
                blocker.Off(), notifyExt.deleteIfExist('discordGenCache')
                return
            case "edit":
                newel := this.__uiaMsgUnderCursor(mousePos)
                buttonBar := this.__getCurrentBar(newel, "Edit")
                if buttonBar = null {
                    blocker.Off(), notifyExt.deleteIfExist('discordGenCache')
                    return
                }
                buttonBar.button.Invoke()
                blocker.Off(), notifyExt.deleteIfExist('discordGenCache')
                return
            case "reply":
                disableAutoReplyPing := CLSID_Objs.loadProp("UserSettings", "disc_disable_autoreply")
                newel := this.__uiaMsgUnderCursor(mousePos)
                buttonBar := this.__getCurrentBar(newel, "Reply")
                if buttonBar = null
                    goto continueDefault
                buttonBar.button.Invoke()
                if disableAutoReplyPing = false || this.__isDM() = true {
                    blocker.Off(), notifyExt.deleteIfExist('discordGenCache')
                    return
                }
                try this.DiscordEl.WaitElement({Type:50000, Name:"Mention ON"}, 800).Toggle()
                blocker.Off(), notifyExt.deleteIfExist('discordGenCache')
                return
        }
        continueDefault:
        newel := this.__uiaMsgUnderCursor(mousePos)
        buttonBar := this.__getCurrentBar(newel, "More")
        if buttonBar = null {
            blocker.Off(), notifyExt.deleteIfExist('discordGenCache')
            return
        }
        buttonBar.button.Expand()
        msgActions := this.discordEl.WaitElement({Type: 50009, AutomationId:"message-actions"}, 1500)
        notifyExt.deleteIfExist('discordGenCache')

        switch button {
            case "reply":
                disableAutoReplyPing := CLSID_Objs.loadProp("UserSettings", "disc_disable_autoreply")
                if disableAutoReplyPing = false || this.__isDM() = true {
                    msgActions.FindElement({Type: 50011, AutomationId: "message-actions-reply"}).Invoke()
                    blocker.Off()
                    return
                }
                try findReply := msgActions.FindElement({Type: 50011, AutomationId: "message-actions-reply"})
                if !IsSet(findReply) || !IsObject(findReply) || !findReply {
                    blocker.Off()
                    return
                }
                try findReply.Invoke()
                catch {
                    blocker.Off()
                    return
                }
                try msgActions.WaitElement({Type:50000, Name:"Mention ON"}, 800).Toggle()
            case "report": try msgActions.FindElement({Type: 50011, AutomationId: "message-actions-report"}).Invoke()
            case "delete": try msgActions.FindElement({Type: 50011, AutomationId: "message-actions-delete"}).Invoke()
        }
        blocker.Off()
    }

    static __getCurrentBar(UIAunderCursor, btnName) {
        try {
            msgActions := UIAunderCursor.FindElement({Type: 50026, Name: "Message Actions"})
            btn := msgActions.FindElement({Type: 50000, Name: btnName})
        } catch {
            return null
        }
        return {msgActions: msgActions, button: btn}
    }

    static __isDM() {
        try {
            root := this.discordEl.FindCachedElement({Type: 50030, AutomationId:"RootWebArea"})
            if SubStr(root.name, 1, 1) = "@" ;// channels start with `#`
                return true
            return false
        } catch {
            try {
                groups := this.discordEl.FindCachedElements({Type: 50026, Name: ""})
                g := groups[4].Children
                return (g[1].name = "Direct Messages" ? true : false)
            } catch {
                return null
            }
        }
    }

    /**
     * This function will search for and automatically click on either unread servers or unread channels depending on parameter `which`. As this function currently relies of a `PixelSearch` to find unread message indicators, it may not function as intended in different themes.
     *
     * > #### [!Warning]
     * > As this function is reliant on `UIA` and discord is constantly updating their `UIA` tree, this function may be prone to randomly breaking.
     * @param {String} which whether you wish to search for unread `servers` or `channels`.
     */
    static Unread(which := "servers")
    {
        if !WinActive(this.winTitle)
            WinActivate(this.winTitle)
        coord.s()
        origMousePos := obj.MousePos(), currentTitle := WinGet.Title()
        if !origMousePos || !currentTitle
            return
        WinGetPos(&xpos, &ypos, &width, &height, this.winTitle)
        saveY := ypos
        if !this.DiscordEl
            try this.DiscordEl := UIA.ElementFromHandle(currentTitle A_Space this.exeTitle)
        if !this.DiscordEl || !IsObject(this.DiscordEl) {
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            return
        }
        try header  := this.DiscordEl.FindElement({Type:50026, Name: "Channel header", LocalizedType: "region"})
        try directM := header.FindElement({Type: 50020, Name: "Direct Messages"})
        try groupDM := header.FindElement({Type: 50020, Name: "Group DM"})
        headerText := ((IsSet(directM) && IsObject(directM)) || (IsSet(groupDM) && IsObject(groupDM))) ? true : false

        __findGrey(x, y, returnVals := false) {
            coord.s()
            if PixelSearch(&x2, &y2, x, y, x + 12, saveY + height - 60, 0xDCDCDF) {
                if returnVals = true
                    return {x: x2, y: y2}
                MouseMove(x2+20, y2+3, 2)
                SendInput("{Click}")
                MouseMove(origMousePos.x, origMousePos.y, 2)
                return true
            }
            return false
        }

        switch which {
            case "servers":
                getServerName := (headerText = true || !InStr(currentTitle, "|") && SubStr(currentTitle, 1, 1) = "@") ? "Direct Messages" : SubStr(currentTitle, start := InStr(currentTitle, "|", , -1) + 2, StrLen(currentTitle) - (start + 9))
                sideBar := this.discordEl.FindElement({Type: 50026, Name: "Servers sidebar"})
                try activeServer := sideBar.FindElement({ClassName:"selected__", matchmode:"Substring"}).Parent
                catch {
                    errorLog(TargetError("Failed to find active server.", -1, getServerName),,, true)
                    return
                }
                findFirstGrey := __findGrey(xpos, ypos, true)
                if !findFirstGrey
                    return
                serverY := (getServerName = "Direct Messages") ? activeServer.location.y + 1 : activeServer.location.y + 1
                if findFirstGrey.y != serverY {
                    __findGrey(xpos, ypos)
                    try this.DiscordEl.WaitElement({Name: "Mark as Read", Type: 50000}, 2000).Invoke()
                    return
                }
                ypos := activeServer.location.y + activeServer.location.h + 2
                __findGrey(xpos, ypos)
                try this.DiscordEl.WaitElement({Name: "Mark as Read", Type: 50000}, 2000).Invoke()
                return
            case "channels":
                if headerText = true {
                    errorLog(TargetError("You're currently in Direct Messages, Channels don't exist.", -1),, true)
                    return
                }
                getLoc := this.DiscordEl.FindElement({Type: 50026, AutomationId: "channels"})

                __findGrey(getLoc.location.x, getLoc.location.y, getLoc.location.h)
                try this.DiscordEl.WaitElement({Name: "Mark as Read", Type: 50000}, 2000).Invoke()
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
            SendInput(KSA.discord.highlightChat)
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

    static __uiaMsgUnderCursor(mousePos) {
        coord.s()
        try el := UIA.ElementFromPoint(mousePos.x, mousePos.y,, false)
        catch
            return false
        depth := 0
        while IsObject(el) && depth++ < 40 {
            try {
                if el.Type = 50026
                && el.LocalizedType = "Message"
                && el.ClassName ~= "(^|\s)message_"
                    return el
            } catch
                return false

            try el := el.Parent
            catch
                return false
        }
        return false
    }
}