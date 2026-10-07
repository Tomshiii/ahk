/************************************************************************
 * @description a class designed to place a little icon on the screen and alternatively bind it to a window's position
 * @author tomshi
 * @ai_disclosure vibecoded with claude, I'm not super familiar with dll's
 * @date 2026/10/02
 * @version 1.1.0
 ***********************************************************************/

; =====================================================================
; StatusIcon: per-pixel-alpha overlay icon (GDI+ + UpdateLayeredWindow)
; Click-through by default, optionally clickable via a callback.
; Self-contained, no globals, no third-party library.
;
;   icon := StatusIcon(path, x, y, size, keepOnTop, onClick)
;   icon.SetIcon(newPath)                 ; swap the image
;   icon.Move(x, y)                       ; absolute screen coordinates
;   icon.Follow(winTitle, dx, dy)         ; pin to a spot inside another window
;   icon.StopFollowing()
;   icon.SetOnClick(fn)                   ; set/clear the click callback, fn(icon)
;   icon.Destroy()                        ; optional, also runs automatically on exit
;
; All x/y values are absolute screen pixels (top-left of the icon).
; =====================================================================

class statusIcon {
    ; Pointers/handles owned by this instance
    gdiToken := 0
    bitmap := 0
    graphics := 0
    hdc := 0
    hbm := 0
    oldBm := 0

    ; Window and layout
    gui := ""
    shown := true
    posX := 0
    posY := 0
    size := 32
    w := 0
    h := 0

    ; Callbacks kept so they can be unregistered later
    keepOnTopFn := ""
    followFn := ""
    exitFn := ""
    onClick := ""
    clickMsgFn := ""

    /**
     * @param {String} path the filepath of the icon image
     * @param {Integer} [x=0] absolute screen x
     * @param {Integer} [y=0] absolute screen y
     * @param {Integer} [size=32] width and height in pixels. 0 uses the image's native size.
     * @param {Boolean} [keepOnTop=true] periodically re-assert always-on-top
     * @param {Func} [onClick] called on left click, as onClick(icon) if it accepts a parameter, otherwise onClick(). If omitted the icon is click-through.
     */
    __New(path, x := 0, y := 0, size := 32, keepOnTop := true, onClick := "") {
        this.posX := x
        this.posY := y
        this.size := size
        this.onClick := onClick          ; set before SetIcon so the window is created correctly

        DllCall("LoadLibrary", "Str", "gdiplus")
        si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
        NumPut("UInt", 1, si)                       ; GdiplusVersion = 1
        token := 0
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", si, "Ptr", 0)
        this.gdiToken := token

        this.exitFn := (*) => this.Destroy()
        OnExit(this.exitFn)

        try this.SetIcon(path)
        catch as err {
            this.Destroy()
            throw err
        }

        if keepOnTop {
            ; Re-assert topmost in case other topmost windows push us down
            this.keepOnTopFn := () => this.gui ? WinSetAlwaysOnTop(1, this.gui) : 0
            SetTimer(this.keepOnTopFn, 2000)
        }
    }

    /**
     * Replace the displayed image. The previous icon stays if loading fails.
     * @param {String} [path] the filepath of the desired icon.
     */
    SetIcon(path) {
        if !FileExist(path)
            throw Error("Icon file not found: " path)

        pBitmap := 0
        DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", path, "Ptr*", &pBitmap)
        if !pBitmap
            throw Error("GDI+ could not load: " path)

        nw := 0, nh := 0
        DllCall("gdiplus\GdipGetImageWidth",  "Ptr", pBitmap, "UInt*", &nw)
        DllCall("gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", &nh)
        this.w := this.size ? this.size : nw
        this.h := this.size ? this.size : nh

        this.FreeBuffers()
        this.bitmap := pBitmap

        ; 32-bit DIB to draw into
        this.hdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        bi := Buffer(40, 0)
        NumPut("UInt",   40, bi, 0)   ; biSize
        NumPut("Int", this.w, bi, 4)  ; biWidth
        NumPut("Int", this.h, bi, 8)  ; biHeight
        NumPut("UShort",  1, bi, 12)  ; biPlanes
        NumPut("UShort", 32, bi, 14)  ; biBitCount
        bits := 0
        this.hbm := DllCall("CreateDIBSection", "Ptr", this.hdc, "Ptr", bi, "UInt", 0
                          , "Ptr*", &bits, "Ptr", 0, "UInt", 0, "Ptr")
        this.oldBm := DllCall("SelectObject", "Ptr", this.hdc, "Ptr", this.hbm, "Ptr")

        ; Draw smoothly scaled image
        pGraphics := 0
        DllCall("gdiplus\GdipCreateFromHDC", "Ptr", this.hdc, "Ptr*", &pGraphics)
        this.graphics := pGraphics
        DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", pGraphics, "Int", 7)  ; high-quality bicubic
        DllCall("gdiplus\GdipDrawImageRectI", "Ptr", pGraphics, "Ptr", pBitmap
              , "Int", 0, "Int", 0, "Int", this.w, "Int", this.h)

        ; Create the window once; later calls just re-push pixels
        if !this.gui {
            ; E0x80000   WS_EX_LAYERED     (required for UpdateLayeredWindow)
            ; E0x8000000 WS_EX_NOACTIVATE  (never takes focus)
            ; E0x20      WS_EX_TRANSPARENT (clicks pass through) only when there is no callback
            opts := "-Caption +ToolWindow +AlwaysOnTop +E0x80000 +E0x08000000"
            if !this.onClick
                opts .= " +E0x20"
            this.gui := Gui(opts)
            ; Gui objects have no OnMessage method, so use the global OnMessage and filter by hwnd
            this.clickMsgFn := this.ClickMsg.Bind(this)
            OnMessage(0x201, this.clickMsgFn)                                  ; WM_LBUTTONDOWN
            this.gui.Show("NA x0 y0 w" this.w " h" this.h)
        }

        this.Push()
    }

    /**
     * Set or clear the click callback at any time.
     * @param {Func} [fn] called as fn(icon) on left click. Pass "" to make the icon click-through again.
     */
    SetOnClick(fn := "") {
        this.onClick := fn
        if !this.gui
            return
        hwnd := this.gui.Hwnd
        getFn := A_PtrSize = 8 ? "GetWindowLongPtr" : "GetWindowLong"
        setFn := A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong"
        ex := DllCall(getFn, "Ptr", hwnd, "Int", -20, "Ptr")        ; GWL_EXSTYLE
        ex := fn ? (ex & ~0x20) : (ex | 0x20)                       ; toggle WS_EX_TRANSPARENT
        DllCall(setFn, "Ptr", hwnd, "Int", -20, "Ptr", ex, "Ptr")
        if this.hdc
            this.Push()
    }

    ; Global WM_LBUTTONDOWN handler: only reacts to clicks on this icon's window
    ClickMsg(wParam, lParam, msg, hwnd) {
        if this.gui && hwnd = this.gui.Hwnd {
            this.HandleClick()
            return 0
        }
    }

    HandleClick() {
        fn := this.onClick
        if !fn
            return
        ; Try passing the icon; if the callback takes no parameters, call it without.
        ; (MaxParams isn't reliable for bound functions, so don't inspect it.)
        ; The "too many parameters" error is raised before the callback body runs, so nothing runs twice.
        try
            fn(this)
        catch Error as e {
            if InStr(e.Message, "Too many parameters")
                fn()
            else
                throw e
        }
    }

    ; Move the icon to absolute screen coordinates.
    Move(x, y) {
        this.posX := x
        this.posY := y
        this.Push()
    }

    /**
     * Pin the icon to a spot inside another window.
     * @param {String} [winTitle] any AHK WinTitle ("ahk_exe notepad.exe", "ahk_class Foo", ...)
     * @param {Integer} [dx]  x value, offset from the target window's CLIENT-area top-left corner
     * @param {Integer} [dy]  y value, offset from the target window's CLIENT-area top-left corner
     * @param {Boolean} [activeOnly=true] only show the icon while the target window is the active window. The icon is hidden when the window doesn't exist or is minimized.
     * @param {Integer} [interval=50] the interval passed to `SetTimer`. How frequently the position will be checked
     */
    Follow(winTitle, dx := 0, dy := 0, activeOnly := true, interval := 50) {
        this.StopFollowing()
        this.followFn := this.UpdateFollow.Bind(this, winTitle, dx, dy, activeOnly)
        SetTimer(this.followFn, interval)
        this.UpdateFollow(winTitle, dx, dy, activeOnly)
    }

    StopFollowing() {
        if this.followFn {
            SetTimer(this.followFn, 0)
            this.followFn := ""
        }
    }

    UpdateFollow(winTitle, dx, dy, activeOnly) {
        if !this.gui
            return
        hwnd := WinExist(winTitle)
        target := "ahk_id " hwnd
        visible := hwnd
            && WinGetMinMax(target) != -1
            && (!activeOnly || WinActive(target))
        if visible {
            WinGetClientPos(&cx, &cy, , , target)   ; client area origin, in screen coordinates
            nx := cx + dx, ny := cy + dy
            if nx != this.posX || ny != this.posY
                this.Move(nx, ny)
        }
        this.SetVisible(!!visible)
    }

    SetVisible(show) {
        if show = this.shown || !this.gui
            return
        this.shown := show
        if show
            this.gui.Show("NA")
        else
            this.gui.Hide()
    }

    /** Send the current bitmap to the screen at the current position. */
    Push() {
        ptDst := Buffer(8), NumPut("Int", this.posX, "Int", this.posY, ptDst)
        sz    := Buffer(8), NumPut("Int", this.w, "Int", this.h, sz)
        ptSrc := Buffer(8, 0)
        blend := 0x01FF0000                         ; AC_SRC_OVER, alpha 255, AC_SRC_ALPHA
        DllCall("UpdateLayeredWindow", "Ptr", this.gui.Hwnd, "Ptr", 0
              , "Ptr", ptDst, "Ptr", sz, "Ptr", this.hdc, "Ptr", ptSrc
              , "UInt", 0, "UInt*", blend, "UInt", 2)   ; ULW_ALPHA
    }

    /** Release everything. Safe to call more than once. */
    Destroy() {
        this.StopFollowing()
        if this.keepOnTopFn {
            SetTimer(this.keepOnTopFn, 0)
            this.keepOnTopFn := ""
        }
        if this.exitFn {
            OnExit(this.exitFn, 0)
            this.exitFn := ""
        }
        this.onClick := ""
        if this.clickMsgFn {
            OnMessage(0x201, this.clickMsgFn, 0)
            this.clickMsgFn := ""
        }
        if this.gui {
            this.gui.Destroy()
            this.gui := ""
        }
        this.FreeBuffers()
        if this.gdiToken {
            DllCall("gdiplus\GdiplusShutdown", "Ptr", this.gdiToken)
            this.gdiToken := 0
        }
    }

    FreeBuffers() {
        if this.graphics {
            DllCall("gdiplus\GdipDeleteGraphics", "Ptr", this.graphics)
            this.graphics := 0
        }
        if this.bitmap {
            DllCall("gdiplus\GdipDisposeImage", "Ptr", this.bitmap)
            this.bitmap := 0
        }
        if this.hdc {
            if this.oldBm
                DllCall("SelectObject", "Ptr", this.hdc, "Ptr", this.oldBm)
            if this.hbm
                DllCall("DeleteObject", "Ptr", this.hbm)
            DllCall("DeleteDC", "Ptr", this.hdc)
            this.oldBm := 0, this.hbm := 0, this.hdc := 0
        }
    }

    __Delete() {
        try SetTimer(this.keepOnTopFn, 0)
        try SetTimer(this.followFn, 0)
        try this.Destroy()
    }
}
