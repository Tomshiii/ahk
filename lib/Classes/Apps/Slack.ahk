/************************************************************************
 * @description Speed up interactions with slack.
 * @author tomshi
 * @date 2023/12/11
 * @version 0.0.1
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
; }

class Slack {
    static exeTitle := "ahk_exe slack.exe"
    static winTitle := this.exeTitle
    static class    := "ahk_class Chrome_WidgetWin_1"
    static path     := A_AppData "\..\Local\slack\slack.exe"

    static Unread(which) {
        coord.s()
        origPos := obj.MousePos()
        pos := obj.WinPos(this.exeTitle)
        __moveReturn(foundCoords, orig) {
            MouseMove(foundCoords.x, foundCoords.y, 2)
            SendInput("{Click}")
            MouseMove(orig.x, orig.y, 2)
        }
        switch which {
            case "dm":
                if !PixelSearch(&x, &y, pos.x, pos.y, pos.x + (pos.width * 0.85), pos.y + pos.height, 0xB41541)
                    return
                __moveReturn({x: x, y: y}, origPos)
            default:
                if !ImageSearch(&x, &y, pos.x, pos.y, pos.x + (pos.width/2), pos.y + pos.height, "*2 " ptf.Slack "unread.png")
                    return
                __moveReturn({x: x, y: y}, origPos)
        }
    }
}