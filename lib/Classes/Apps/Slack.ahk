/************************************************************************
 * @description Speed up interactions with slack.
 * @author tomshi
 * @date 2026/11/26
 * @version 1.3.2
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Classes\keys.ahk
#Include Classes\obj.ahk
#Include Classes\block.ahk
#Include Classes\winget.ahk
#Include Classes\errorLog.ahk
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
     * Closes the current thread if the user is within one, or cancels the current action (ie. editing a message), else does nothing.
     * @returns {Boolean}
     */
    static exitThread(sendHotkey := false) {
        if !currentTitle := WinGet.Title()
            return false
        try slackEl := UIA.ElementFromHandle(currentTitle A_Space this.exeTitle,, false)
        if !IsSet(slackEl) || !IsObject(slackEl) || !slackEl {
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            return false
        }
        try CloseArr := slackEl.FindElements([{Type: 50000, Name: "Close"}, {Type: 50000, Name: "Cancel"}])
        catch {
            return false
        }
        if !CloseArr.Length
            return false
        for el in CloseArr {
            if el.ClassName = "WinCaptionButton"
                continue
            if InStr(el.ClassName, "c-button-unstyled c-icon_button") || InStr(el.ClassName, "c-button c-button--outline") {
                try el.Invoke()
                return true
            }
        }
        return false
    }

    static __warm := false

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

        switch button {
            case "reaction":
                cond := {Type: 50000, Name: "Add reaction…"}
            case "reply":
                cond := {Type: 50000, Name: "i)^(Reply (in|to) thread|View thread)", matchmode: "RegEx"}
            case "delete", "edit":
                ;// these live in the "More actions" menu of the hovered message's bar
                cond := {Type: 50000, Name: "More actions"}
            default:
                blocker.Off()
                return
        }

        bar := this.__getBar(slackEl, origMousePos, cond, this.__warm ? 150 : 1500)
        if !bar {
            blocker.Off()
            errorLog(UnsetError("Failed to find message bar", -1),, true)
            return
        }
        this.__warm := true

        switch button {
            case "reaction": bar.button.Invoke()

            case "reply":
                bar.button.Invoke()
                if replyInThread != true {
                    blocker.Off()
                    return
                }
                try {
                    thread  := slackEl.WaitElement({Name: "Thread in (channel|conversation)", matchmode: "RegEx", or:[{Type: 50032}, {Type: 50026}]}, 2000,,,,,, 150)
                    findBox := thread.WaitElement({Type: 50007, Name: "i)(Also send (as|to))", matchmode: "RegEx"}, 2000)
                    findBox.WaitElement({Type: 50002, AutomationId: "p-thread_footer__broadcast_checkbox", Name: "i)(Also send (as|to))", matchmode: "RegEx"}, 2000).Toggle()
                } catch as e {
                    blocker.Off()
                    errorLog(e)
                    return
                }

            case "delete", "edit":
                bar.button.Expand()
                item := (button = "delete") ? "Delete message… delete" : "Edit message E"
                try slackEl.WaitElement({Type: 50011, Name: item}, 2000).Invoke()
        }
        blocker.Off()
    }

    /**
     * Finds the hover action bar closest to the cursor and a button within it.
     * Slack only renders the bar for the hovered message, so no walk up the tree is needed.
     * @param {UIA.IUIAutomationElement} slackEl the root Slack element
     * @param {Object} mousePos an object containing the x/y values of the mouse
     * @param {Object} btnCondition UIA condition for the button inside the bar
     * @param {Integer} retryMs how long to keep retrying before giving up
     * @returns {Object | false} `{msgActions, button}` or `false`
     */
    static __getBar(slackEl, mousePos, btnCondition, retryMs) {
        start := A_TickCount
        loop {
            try {
                best := false, bestDist := 1e9
                for g in slackEl.FindElements({ClassName: "c-message-actions--hover-actions", mm: 2}) {
                    loc := g.Location
                    dist := Abs((loc.y + loc.h // 2) - mousePos.y)
                    if dist < bestDist
                        best := g, bestDist := dist
                }
                if best
                    return {msgActions: best, button: best.FindElement(btnCondition, 2)}
            }
            if A_TickCount - start >= retryMs
                return false
            Sleep(75)
        }
    }
}