/************************************************************************
 * @description Speed up interactions with slack.
 * @author tomshi
 * @date 2025/04/30
 * @version 1.1.4
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\keys>
#Include <Classes\obj>
#Include <Classes\block>
#Include <Classes\winget>
#Include <Functions\delaySI>
#Include <Other\UIA\UIA>
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
        origMousePos := obj.MousePos()
        winPos := obj.WinPos(this.exeTitle)
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
        keys.allWait("second")
        origMousePos := obj.MousePos()
        if WinGetProcessName(origMousePos.win) != WinGetProcessName(this.winTitle)
            return
        blocker := block_ext()
        blocker.On()
        currentTitle := WinGet.Title()
        try slackEl := UIA.ElementFromHandle(currentTitle A_Space this.exeTitle)
        catch {
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            blocker.Off()
            return
        }

        pressButton(uiaObj, type, button) {
            if button = "Delete message… delete" || button = "Edit message E" {
                if !uiaObj.WaitElement({LocalizedType: "button", Name: "Save for later"}, 2000) {
                    errorLog(UnsetError("Failed to find Save for later element", -1),, true)
                    blocker.Off()
                    Exit()
                }
                findLocation := uiaObj.WaitElement({LocalizedType: "button", Name: "Save for later"}, 2000)
                for el in uiaObj.FindElements({LocalizedType: "menu item", Name: "More actions"}) {
                    if el.location.y != findLocation.location.y
                        continue
                    el.ControlClick()
                }
                try uiaObj.WaitElement({LocalizedType: type, Name: button}, 1500).ControlClick()
                return
            }

            ;// if a thread is open we need to hone our search to just the thread
            if uiaObj.ElementExist({LocalizedType: "dialog", Name: "Thread in channel", matchmode: "Substring"}) && button != "Reply in thread" {
                findLocation := uiaObj.WaitElement([{LocalizedType:"dialog", Name:"Thread in channel", matchmode:"Substring"}, {LocalizedType: "button", Name: "Save for later"}], 2000)
                for el in uiaObj.FindElements([{LocalizedType:"dialog", Name:"Thread in channel", matchmode:"Substring"}, {LocalizedType: "menu item", Name: "More actions"}]) {
                    if el.location.y != findLocation.location.y
                        continue
                    el.ControlClick()
                }
                try uiaObj.WaitElement({LocalizedType: type, Name: button}, 1500).ControlClick()
                return
            }
            ;// otherwise we just search for the button
            try uiaObj.WaitElement({LocalizedType: type, Name: button}, 1500).ControlClick()
            if replyInThread = true && button = "Reply in thread" {
                uiaObj.WaitElement({LocalizedType: "dialog", Name: "Thread in channel", matchmode: "Substring"}, 2000)
                try uiaObj.WaitElement({AutomationId:"p-thread_footer__broadcast_checkbox", matchmode: "Substring"}, 2000).ControlClick()
            }
        }

        switch button {
            case "reaction": pressButton(slackEl, "button", "Add reaction…")
            case "reply": pressButton(slackEl, "button", "Reply in thread")
            case "delete": pressButton(slackEl, "menu item", "Delete message… delete")
            case "edit": pressButton(slackEl, "menu item", "Edit message E")
        }
        blocker.Off()
    }
}