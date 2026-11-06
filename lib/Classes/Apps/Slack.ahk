/************************************************************************
 * @description Speed up interactions with slack.
 * @author tomshi
 * @date 2026/11/06
 * @version 1.3.0
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Classes\keys.ahk
#Include Classes\obj.ahk
#Include Classes\block.ahk
#Include Classes\winget.ahk
#Include Functions\delaySI.ahk
#Include Other\UIA\UIA.ahk
; }

class Slack {
    static exeTitle := "ahk_exe slack.exe"
    static winTitle := this.exeTitle
    static class    := "ahk_class Chrome_WidgetWin_1"
    static path     := A_AppData "\..\Local\slack\slack.exe"

    /**
     * An internal function to move the mouse to found coordinates, click the coordinates, then return to the original position
     * @param {Object} foundCoords an object containing the x/y values of the found coordinates
     * @param {Object} orig an object containing the x/y values of the original mouse coordinates
     */
    __moveReturn(foundCoords, orig) {
        MouseMove(foundCoords.x, foundCoords.y, 2)
        SendInput("{Click}")
        MouseMove(orig.x, orig.y, 2)
    }

    /**
     * A function designed to quickly click on any unread notifications
     * @param {String} which decide which type of notification you wish to action. Either pass `"dm"` or an empty string
     */
    static unread(which) {
        coord.s()
        origMousePos := obj.MousePos(), winPos := obj.WinPos(this.exeTitle)
        if !origMousePos || !winPos
            return
        switch which {
            case "dm":
                if !PixelSearch(&x, &y, winPos.x, winPos.y, winPos.x + (winPos.width * 0.85), winPos.y + winPos.height, 0xB41541)
                    return
                this().__moveReturn({x: x, y: y}, origMousePos)
            default:
                if !ImageSearch(&x, &y, winPos.x, winPos.y, winPos.x + (winPos.width/2), winPos.y + winPos.height, "*2 " ptf.Slack "unread.png")
                    return
                this().__moveReturn({x: x, y: y}, origMousePos)
        }
    }

    /**
     * A function designed to quickly access many features that often require a little fiddling to reach.
     * @param {String} button the desired button name you wish to click. Supported buttons are; `reaction`, `reply`, `edit`, `delete`
     * @param {Boolean} [replyInThread=false] determine whether `reply` will also enable the `Also send to...` checkbox when replying in a thread. Defaults to `false`
     */
    static button(button, replyInThread := false) {
        keys.allWait(2)
        origMousePos := obj.MousePos(), currentTitle := WinGet.Title()
        if !origMousePos || !currentTitle
            return
        if WinGetProcessName(origMousePos.win) != WinGetProcessName(this.winTitle)
            return
        blocker := block_ext()
        blocker.On()


        try slackEl := UIA.ElementFromHandle(currentTitle A_Space this.exeTitle,, false)
        if !IsSet(slackEl) || !IsObject(slackEl) || !slackEl {
            blocker.Off()
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            return
        }

        msgEl := this.__uiaMsgUnderCursor(origMousePos)
        A_Clipboard := msgEl.Dump()
        if !msgEl {
            errorLog(UnsetError("Failed to set message bar", -1),, true)
            blocker.Off()
            return
        }

        switch button {
            case "reaction":
                bar := this.__getCurrentBar(msgEl, {Type: 50000, Name:"Add reaction…"})
                if !bar {
                    blocker.Off()
                    return
                }
                bar.button.Invoke()

            case "reply":
                bar := this.__getCurrentBar(msgEl, {Type: 50000, Name: "i)^(Reply (in|to) thread|View thread)", matchmode: "RegEx"})
                if !bar {
                    blocker.Off()
                    return
                }
                bar.button.Invoke()
                if replyInThread != true {
                    blocker.Off()
                    return
                }
                try {
                    thread  := slackEl.WaitElement({Type: 50032, Name: "Thread in (channel|conversation)", matchmode: "RegEx"}, 2000,,,,,, 150)
                    findBox := thread.WaitElement({Type: 50007, Name: "i)(Also send (as|to))", matchmode: "RegEx"}, 2000)
                    findBox.WaitElement({Type: 50002, AutomationId: "p-thread_footer__broadcast_checkbox", Name: "i)(Also send (as|to))", matchmode: "RegEx"}, 2000).Toggle()
                }

            case "delete", "edit":
                ;// these live in the "More actions" menu of the hovered message's bar
                bar := this.__getCurrentBar(msgEl, {Type: 50000, Name: "More actions"})
                if !bar {
                    blocker.Off()
                    return
                }
                bar.button.Expand()
                item := (button = "delete") ? "Delete message… delete" : "Edit message E"
                try slackEl.WaitElement({Type: 50011, Name: item}, 2000).Invoke()
        }
        blocker.Off()
    }

    /**
     * Finds the hover action bar inside a message element and a button within it
     * @param {UIA.IUIAutomationElement} msgEl the message element
     * @param {Object} btnCondition UIA condition for the button inside the bar
     * @returns {Object | false} `{msgActions, button}` or `false`
     */
    static __getCurrentBar(msgEl, btnCondition) {
        try {
            msgActions := msgEl.FindElement({ClassName: "c-message-actions--hover-actions", mm: 2}, 4)
            btn := msgActions.FindElement(btnCondition, 2)
        } catch
            return false
        return {msgActions: msgActions, button: btn}
    }

    /**
     * Walks up from the element under the cursor to the first ancestor that contains a `Message actions` bar.
     * Slack only renders that bar for the hovered message, so this is the message under the cursor.
     */
    static __uiaMsgUnderCursor(mousePos) {
        coord.s()
        try el := UIA.ElementFromPoint(mousePos.x, mousePos.y,, false)
        catch
            return false

        depth := 0
        while IsObject(el) && depth++ < 40 {
            try {
                el.FindElement({ClassName: "c-message-actions--hover-actions", mm: 2}, 4)  ; throws TargetError if absent
                return el
            } catch TargetError {
                ; not in this one, go up
            } catch
                return false
            try el := el.Parent
            catch
                return false
        }
        return false
    }
}