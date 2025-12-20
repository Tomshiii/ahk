/************************************************************************
 * @description Speed up interactions with slack.
 * @author tomshi
 * @date 2025/12/20
 * @version 1.2.0
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

        static slackCacheRequest := UIA.CreateCacheRequest(["LocalizedType", "AutomationId", "Name"],, 5)

        try slackEl := UIA.ElementFromHandle(currentTitle A_Space this.exeTitle, slackCacheRequest)
        if !IsSet(slackEl) || !IsObject(slackEl) || !slackEl {
            errorLog(UnsetError("Failed to set UIA element", -1),, true)
            blocker.Off()
            return
        }

        pressButton(uiaObj, type, button) {
            if button = "Delete message… delete" || button = "Edit message E" {
                if !uiaObj.WaitElement({LocalizedType:"toggle button", Name: "Save for later"}, 2000) {
                    errorLog(UnsetError("Failed to find Save for later element", -1),, true)
                    blocker.Off()
                    return
                }
                findLocation := uiaObj.FindCachedElement({LocalizedType:"toggle button", Name: "Save for later"})
                for el in uiaObj.FindCachedElements({LocalizedType:"button", Name: "More actions"}) {
                    if el.location.y != findLocation.location.y
                        continue
                    el.ControlClick()
                }
                try uiaObj.WaitElement({LocalizedType: type, Name: button}, 2000,,,,, slackCacheRequest).ControlClick()
                return
            }

            ;// if a thread is open we need to hone our search to just the thread
            if button != "Reply in thread" && uiaObj.CachedElementExist({LocalizedType:"dialog", LocalizedType:"dialogue", Name: "Thread in channel", matchmode: "Substring"}) {
                findThread := uiaObj.WaitElement([{LocalizedType:"dialog", LocalizedType:"dialogue", Name:"Thread in channel", matchmode:"Substring"}], 2000,,,,, slackCacheRequest)
                findLocation := findThread.WaitElement([{LocalizedType:"group", Name:"Message actions"}], 2000,,,,, slackCacheRequest)

                moreActions := findThread.FindElements([{LocalizedType:"group", Name:"Message actions"}],,,, slackCacheRequest)
                for el in moreActions {
                    if el.location.y != findLocation.location.y && el.location.x != findLocation.location.x
                        continue
                    if button = "Add reaction…" {
                        el.FindCachedElement({LocalizedType: type, Name: button}).ControlClick()
                        return
                    }
                    el.FindCachedElement([{LocalizedType:"button", Name: "More actions"}]).ControlClick()
                }
                try uiaObj.WaitElement({LocalizedType: type, Name: button}, 2000,,,,, slackCacheRequest).ControlClick()
                return
            }
            ;// otherwise we just search for the button
            if button != "Reply in thread" {
                ;// limit to just the hover buttons (as the "add reaction" button appears under images and this script may attempt to interact with that)
                try msgAction := uiaObj.FindCachedElement([{LocalizedType:"group", Name:"Message actions"}])
                try msgAction.FindCachedElement({LocalizedType: type, Name: button}).ControlClick()
                return
            }
            try check := uiaObj.FindCachedElement({LocalizedType: type, Name: "i)(Reply (in|to) thread|View thread)", matchmode: "Regex"}).ControlClick()
            if IsSet(check) && replyInThread = true {
                try {
                    findThread := uiaObj.WaitElement([{LocalizedType:"dialog|dialogue", Name:"Thread in (channel|conversation)", matchmode:"Regex"}], 2000,,,,, slackCacheRequest, 100)
                    findBox    := uiaObj.WaitElement([{LocalizedType:"list item", Name: "i)(Also send (as|to))", matchmode:"Regex"}], 2000,,,,, slackCacheRequest, 100)
                    findBox.WaitElement([{LocalizedType:"i)(check box|checkbox)", AutomationId:"p-thread_footer__broadcast_checkbox", Name: "i)(Also send (as|to))", matchmode:"Regex"}], 2000,,,,, slackCacheRequest).ControlClick()
                }
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