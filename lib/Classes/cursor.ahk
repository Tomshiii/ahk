/************************************************************************
 * @author tomshi
 * @date 2026/10/07
 * @version 1.0.1
 ***********************************************************************/
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\coord.ahk
#Include Classes\keys.ahk
#Include Functions\getHotkeys.ahk
; }

class cursor {

    static premMap := Map(
        "1C001C001C007F00FF807F001C001C001C000000000000000000000000000000_4,4", "grab playhead",
        "0380038001800D801F803F800D80058003800380000000000000000000000000_8,6", "left trim",
        "01C001C0018001A001F801F801B001A001C001C0000000000000000000000000_8,6", "right trim",
        "0380038001800D801F803F800D80058003800380000000000000000000000000_8,6", "left ripple",
        "01C001C0018001A001F801F801B001A001C001C0000000000000000000000000_8,6", "right ripple",
        "03000FC01FE01FF00FE007C00FC01FE01FF00FE007C000000000000000000000_7,6", "rolling edit",
        "8000C000E000F000F800FC00F000D00018000000000000000000000000000000_0,0", "arrow"
    )

    /** this function is ai slop */
    static GetCursorSignature(&bits := "") {
        static N := 16, R := 64          ; N = final grid, R = render size (R must be a multiple of N)

        ; --- current cursor handle ---
        ci := Buffer(A_PtrSize = 8 ? 24 : 20, 0)
        NumPut("UInt", ci.Size, ci, 0)
        DllCall("GetCursorInfo", "Ptr", ci)
        hCur := NumGet(ci, 8, "Ptr")
        if !hCur
            return "Hidden"

        ; --- hotspot + native size (only used as a ratio) ---
        ii := Buffer(A_PtrSize = 8 ? 32 : 20, 0)
        if !DllCall("GetIconInfo", "Ptr", hCur, "Ptr", ii)
            return "Unknown"
        xHot   := NumGet(ii, 4, "UInt")
        yHot   := NumGet(ii, 8, "UInt")
        hMask  := NumGet(ii, A_PtrSize = 8 ? 16 : 12, "Ptr")
        hColor := NumGet(ii, A_PtrSize = 8 ? 24 : 16, "Ptr")
        hBmp   := hColor ? hColor : hMask

        bm := Buffer(A_PtrSize = 8 ? 32 : 24, 0)
        DllCall("GetObjectW", "Ptr", hBmp, "Int", bm.Size, "Ptr", bm)
        w := NumGet(bm, 4, "Int")
        h := NumGet(bm, 8, "Int")
        if !hColor
            h //= 2                      ; monochrome cursors store AND+XOR masks stacked
        if hMask
            DllCall("DeleteObject", "Ptr", hMask)
        if hColor
            DllCall("DeleteObject", "Ptr", hColor)
        if (w < 1 || h < 1)
            return "Unknown"

        ; --- render at fixed size on black and on white; the difference gives coverage ---
        onBlack := this.RenderCursor(hCur, R, 0x00)
        onWhite := this.RenderCursor(hCur, R, 0xFF)

        ; --- reduce to NxN: a cell is "ink" if >50% covered ---
        blk := R // N
        bits := ""
        nib := 0, nibCount := 0, hex := ""
        loop N {
            gy := A_Index - 1
            loop N {
                gx := A_Index - 1
                cov := 0
                loop blk {
                    py := gy * blk + A_Index - 1
                    loop blk {
                        px  := gx * blk + A_Index - 1
                        off := (py * R + px) * 4 + 1          ; green channel
                        cov += 255 - (NumGet(onWhite, off, "UChar") - NumGet(onBlack, off, "UChar"))
                    }
                }
                bit := (cov / (blk * blk) > 127) ? 1 : 0
                bits .= bit
                nib := (nib << 1) | bit
                if (++nibCount = 4) {
                    hex .= Format("{:X}", nib)
                    nib := 0, nibCount := 0
                }
            }
        }

        hx := Round(xHot / w * N), hy := Round(yHot / h * N)
        return hex "_" hx "," hy
    }

    /** this function is ai slop */
    static RenderCursor(hCur, size, fill) {
        hdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        bi := Buffer(40, 0)
        NumPut("UInt", 40, "Int", size, "Int", -size, "UShort", 1, "UShort", 32, bi, 0)
        hbm := DllCall("CreateDIBSection", "Ptr", hdc, "Ptr", bi, "UInt", 0, "Ptr*", &pBits := 0, "Ptr", 0, "UInt", 0, "Ptr")
        old := DllCall("SelectObject", "Ptr", hdc, "Ptr", hbm, "Ptr")
        DllCall("RtlFillMemory", "Ptr", pBits, "UPtr", size * size * 4, "UChar", fill)
        DllCall("DrawIconEx", "Ptr", hdc, "Int", 0, "Int", 0, "Ptr", hCur
            , "Int", size, "Int", size, "UInt", 0, "Ptr", 0, "UInt", 3)   ; DI_NORMAL, scaled to size
        out := Buffer(size * size * 4)
        DllCall("RtlMoveMemory", "Ptr", out, "Ptr", pBits, "UPtr", out.Size)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
        DllCall("DeleteObject", "Ptr", hbm)
        DllCall("DeleteDC", "Ptr", hdc)
        return out
    }

    /** this function is ai slop */
    static MatchCursor(sig, table, &bestD := 0, maxDiff := 12) {
        static hexRe := "^[0-9A-Fa-f]+$"
        bestD := -1
        sHex := StrSplit(sig, "_")[1]
        if !RegExMatch(sHex, hexRe)
            return ""

        best := "", bestD := 1e9
        for known, name in table {
            kHex := StrSplit(known, "_")[1]
            if (StrLen(kHex) != StrLen(sHex) || !RegExMatch(kHex, hexRe))
                continue
            d := 0
            loop parse sHex {
                x := Integer("0x" A_LoopField) ^ Integer("0x" SubStr(kHex, A_Index, 1))
                d += (x & 1) + (x >> 1 & 1) + (x >> 2 & 1) + (x >> 3 & 1)
            }
            if (d < bestD)
                best := name, bestD := d
        }
        return bestD <= maxDiff ? best : ""
    }

    /**
     * A quick and dirty way to limit the axis your mouse can move
     *
     * This function has specific code for XButton1/2 and must be activated with 2 hotkeys
    */
    static XorY()
    {
        getHotkeys(&fr, &sc)
        if sc != "XButton1" && sc != "XButton2"
            return
        MouseGetPos(&x, &y)
        start:
        oneAxis(sc)
        {
            while GetKeyState(sc, "P")
                {
                    SetTimer(tools, 15)
                    tools() {
                        MouseGetPos(&xx, &yy)
                        static toolx := xx
                        static tooly := yy
                        if A_TimeIdleMouse < 500
                            {
                                switch sc {
                                    case "XButton2": ToolTip("Your mouse will now only move along the x axis")
                                    case "XButton1": ToolTip("Your mouse will now only move along the y axis")
                                }
                            }
                        else if A_TimeIdleMouse > 500
                            {
                                MouseGetPos(&newX, &newY)
                                switch sc {
                                    case "XButton2":
                                        if (newY = y) && (newX != toolx)
                                            {
                                                ToolTip("Your mouse will now only move along the x axis`nYou are currently level on the y axis")
                                                toolx := newX
                                            }
                                    case "XButton1":
                                        if (newX = x) && (newY != tooly)
                                            {
                                                ToolTip("Your mouse will now only move along the y axis`nYou are currently level on the x axis")
                                                tooly := newY
                                            }
                                }
                            }
                    }
                    MouseGetPos(&newX, &newY)
                    switch sc {
                        case "XButton2": MouseMove(newX, y)
                        case "XButton1": MouseMove(x, newY)
                    }
                }
                SetTimer(tools, 0)
                ToolTip("")
        }
        oneAxis(sc)
        if GetKeyState(fr, "P")
            goto start
    }

    /**
     * A function to lock mouse movement on a particular axis. Call `move.setMouseClip()` with no parameters, or set `keywait` to `true` to disable
     * @link https://old.reddit.com/r/AutoHotkey/comments/1g8uqes/need_help/lt42sh7/
     * @param {String} [axs] either "x", or "y"
     * @param {Boolean} [keywait=true] determine whether to end the function after `keys.allWait(2)` or whether you wish to handle resetting manually
     */
    static clipMouse(Axs, keywait := true){
        coord.s("mouse")
        MouseGetPos(&x,&y)
        if (Axs="X")
            this.setMouseClip(1,0,y,A_ScreenWidth,y+1)
        else
            this.setMouseClip(1,x,0,x+1,A_ScreenHeight)

        if keywait = true {
            try keys.allWait(2)
            this.setMouseClip()
            return
        }
    }

    /** helper function for `clipMouse`. call with no params to disable locked mouse movement */
    static setMouseClip(Conf := 0, x1 := 0, y1 := 0, x2 := 1, y2 := 1) {
        if !Conf {
            DllCall("ClipCursor", "Ptr", 0)
            return
        }

        pData := DllCall("GlobalAlloc", "UInt", 0, "UPtr", 16, "Ptr")
        NumPut("Int", x1, pData, 0), NumPut("Int", y1, pData, 4)
        NumPut("Int", x2, pData, 8), NumPut("Int", y2, pData, 12)
        Val := DllCall("ClipCursor", "Ptr", pData)
        DllCall("GlobalFree", "Ptr", pData)
        return Val
    }

    __Delete(*) {
        try OnExit((*) => cursor.setMouseClip())
    }
}