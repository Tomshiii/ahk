/************************************************************************
 * @date 2026/11/13
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\errorLog.ahk
#Include Classes\winget.ahk
; }

class topBorder {
    static windows  := Map()      ; hwnd -> colour
    static hooked   := false
    static reapply  := ""         ; cached bound callback for SetTimer
    static colour   := 0x1195F5   ; COLORREF (0x00BBGGRR) = orange #F59511

    /**
     * Toggle always-on-top and a persistent border (win11 only) for a window.
     * @param {String} winTitle window to toggle. Defaults to the active window
     * @param {Integer} colour the border colour as a `COLORREF` (`0x00BBGGRR`). Only used if `winTitle` isn't `"A"`, otherwise `topBorder.colour` is used. Defaults to `topBorder.colour`
     */
    static toggle(winTitle := "A", colour?) {
        try {
            hwnd := WinExist(winTitle)
            if !hwnd
                return
            this.__ensureHook()

            ; only honour a custom colour when targeting a specific window
            useColour := (winTitle != "A" && IsSet(colour)) ? colour : this.colour

            wasOnTop := WinGetExStyle(hwnd) & 0x8   ; WS_EX_TOPMOST
            WinSetAlwaysOnTop(-1, hwnd)

            if wasOnTop {
                this.windows.Delete(hwnd)
                this.draw(hwnd, false)
            } else {
                this.windows[hwnd] := useColour
                this.draw(hwnd, true, useColour)
            }
        } catch as e {
            errorLog(e)
        }
    }

    static __ensureHook() {
        if this.hooked
            return
        this.reapply := this.__reapplyAll.Bind(this)
        DllCall("RegisterShellHookWindow", "ptr", A_ScriptHwnd)
        OnMessage(DllCall("RegisterWindowMessage", "str", "SHELLHOOK", "uint")
                , this.__onShell.Bind(this))
        this.hooked := true
    }

    static __onShell(wParam, lParam, *) {
        ; 4 = ACTIVATED, 0x8004 = RUDEAPPACTIVATE, 6 = REDRAW
        if (wParam = 4 || wParam = 0x8004 || wParam = 6)
            SetTimer(this.reapply, -30)   ; small delay so the frame repaint finishes first
    }

    static __reapplyAll() {
        for hwnd, colour in this.windows.Clone() {
            if !WinExist("ahk_id " hwnd) {
                this.windows.Delete(hwnd)
                continue
            }
            this.draw(hwnd, true, colour)
        }
    }


    /**
     * Applies (or removes) a coloured border on a window using `DwmSetWindowAttribute` (`DWMWA_BORDER_COLOR`). Does nothing on windows versions older than `10.0.22000` (win11).
     *
     * This only applies the border once. Windows may reset it when the window loses focus, so use `topBorder.Toggle()` if you need the border to persist.
     * @param {Integer} hwnd the hwnd of the window you wish to adjust
     * @param {Boolean} enable `true` to apply the border, `false` to remove it
     * @param {Integer} colour the colour of the border as a `COLORREF` (`0x00BBGGRR`). Defaults to `topBorder.colour`
     */
    static draw(hwnd, enable, colour := this.colour) {
        if VerCompare(A_OSVersion, "10.0.22000") < 0
            return
        ; 0xFFFFFFFE = DWMWA_COLOR_NONE (no border), 0xFFFFFFFF = system default
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", 34
              , "int*", enable ? colour : 0xFFFFFFFE, "int", 4)
    }
}