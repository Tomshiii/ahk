; { \\ #Includes
#Include <Classes\explorer>
#Include <Functions\delaySI>
; }

;explorerbackHotkey;
F21::
{
    expl := explorer.cancelSearch()
    switch {
        case (expl == -1): return
        case (expl = false):
            __doBack() => (SendInput("!{Up}"), Exit())
            try currWin := WinGetTitle("A")
            catch {
                __doBack()
            }
            if !explorerEl := explorer.__createUIAelement(currWin, true)
                __doBack()
            if explorer.isPopupHost(explorerEl.uiaElement) {
                __doBack()
            }
            activeEl := explorer.__getUIAautoID(explorerEl)
            if activeEl != "FileExplorerSearchBox" {
                __doBack()
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