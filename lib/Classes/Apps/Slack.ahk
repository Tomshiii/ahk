/************************************************************************
 * @description Speed up interactions with slack.
 * @author tomshi
 * @date 2025/03/27
 * @version 1.0.2
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\keys>
#Include <Classes\obj>
#Include <Functions\delaySI>
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
     * A function to cut repeat code. Designed to search for an image and increase the search radius if the image is not found
     * @param {String} image the filename of the image you're searching for, including the file extension
     * @param {Object} coords an object containing the x1,y1,x2,y2 coordinates you wish to search
     * @param {Integer} increaseAmount the amount you want the search to increase (in both the top and bottom of the search area)
     */
    __expandingLoop(image, coords, increaseAmount) {
        loop {
            if A_Index = 1 {
                if ImageSearch(&x, &y, coords.x1, coords.y1, coords.x2, coords.y2, "*2 " ptf.Slack image)
                    return {x: x, y:y}
            }
            if A_Index > 5 {
                errorLog(TargetError("Unable to find the desired button", -1),, true)
                return false
            }
            if ImageSearch(&x, &y, coords.x1, coords.y1 - (increaseAmount*(A_Index-1)), coords.x2, coords.y2 + (increaseAmount*(A_Index-1)), "*2 " ptf.Slack image)
                return {x: x, y:y}
        }
    }

    /**
     * A function to reduce repeat code. Performs different actions depending on the state of the cursor.
     * @param {String} cursor the current cursor
     * @param {String} image the image you wish to search for
     * @param {Object} coords an object containing the x1,y1,x2,y2 coordinates you wish to search
     * @param {Integer} increaseAmount the amount you want the search to increase (in both the top and bottom of the search area)
     * @param {String} button the button you wish to be sent to perform the desired action
     * @param {Object} origMousePos an object containing the x/y values of the original mouse coordinates
     * @param {Boolean} doEscape whether you wish for the function to send a final <kbd>Escape</kbd> key at the end
     */
    __containsBoth(cursor, image, coords, increaseAmount, button, origMousePos, doEscape := true) {
        finalPress := doEscape = true ? "{Esc}" : ""
        switch cursor {
            case "IBeam", "Unknown":
                if !foundPos := this.__expandingLoop(image, coords, increaseAmount)
                    return false
                this.__moveReturn({x: foundPos.x, y: foundPos.y}, origMousePos)
                delaySI(50, button, finalPress)
                return
            case "Arrow":
                delaySI(50, "{RButton}", button, finalPress)
                return
        }
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
     * @param {String} button the desired button name you wish to click
     */
    static button(button) {
        coord.s()
        cursor := A_Cursor
        keys.allWait("second")
        origMousePos := obj.MousePos()
        if WinGetProcessName(origMousePos.win) != WinGetProcessName(this.winTitle)
            return
        winPos := obj.WinPos(this.exeTitle)
        yheight := 400

        switch button {
            case "reaction":
                if !foundPos := this().__expandingLoop("reaction.png", {x1: winPos.x, y1: origMousePos.y - 100, x2: winPos.x + winPos.width, y2: origMousePos.y + 100}, yheight)
                    return
                this().__moveReturn({x: foundPos.x, y: foundPos.y}, origMousePos)
            case "edit":
                if !this().__containsBoth(cursor, "threedot.png", {x1: winPos.x, y1: origMousePos.y - 100, x2: winPos.x + winPos.width, y2: origMousePos.y + 100}, yheight, "e", origMousePos)
                    return
            case "delete":
                if !this().__containsBoth(cursor, "threedot.png", {x1: winPos.x, y1: origMousePos.y - 100, x2: winPos.x + winPos.width, y2: origMousePos.y + 100}, yheight, "{Del}", origMousePos, false)
                    return
        }
    }
}