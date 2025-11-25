; { \\ #Includes
#Include <Classes\explorer>
#Include <Functions\delaySI>
; }

;explorerbackHotkey;
F21::
{
    if !actClass := WinGetClass("A")
        return
    if actClass = "ahk_class File Pilot" {
        SendInput("!{Up}")
        return
    }
    expl := explorer.cancelSearch()
    switch {
        case (expl == -1): return
        case (expl = false):
            try currWin := WinGetTitle("A")
            catch {
                SendInput("!{Up}")
                return
            }
            if !explorerEl := explorer.__createUIAelement(currWin, true) {
                SendInput("!{Up}")
                return
            }
            if explorer.isPopupHost(explorerEl.uiaElement) {
                SendInput("!{Up}")
                return
            }
            activeEl := explorer.__getUIAautoID(explorerEl)
            if activeEl != "FileExplorerSearchBox" {
                SendInput("!{Up}")
                return
            }
            SendInput("!{Up}") ;Moves back 1 folder in the tree in explorer
            explorerEl.uiaElement.FindElement({AutomationId:"FileExplorerSearchBox"}).SetFocus()
            return
        default:
            if !IsObject(expl)
                return
            if expl.activeAutoID != "FileExplorerSearchBox"
                return
            expl.uiaElement.FindElement({AutomationId:"FileExplorerSearchBox"}).Invoke()
    }
}
F23::explorer.cancelSearch()



#+F::delaySI(100, "{F11}", "{F11}")