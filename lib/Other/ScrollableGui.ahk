#Requires AutoHotkey v2.0.0+
;==============================================================
; ScrollableGui — Enables a window to scroll its contents with scrollbars, mouse wheel, and resize-aware behavior
;
; GitHub: https://github.com/SevenKeyboard/scrollable-gui
; Author: SevenKeyboard Ltd. (2024)
; License: MIT License
;==============================================================
class VersionManager_ScrollableGui
{
    static _ := this._init()
    static _init()    {
        global
        SCROLLABLEGUI_VERSION := "1.1.1"
    }
}
class ScrollableGui
{
    static init()    {
        this.registerWndProc(-1,-1)
    }
    static _coord:=map(), _opt:=map()
    ;--------------------------------------------------
    static register(hWnd_or_guiObj, innerScrollOnFocus:=true)    {
        static SIF_DISABLENOSCROLL  := 0x0008
            ,SIF_PAGE               := 0x0002
            ,SIF_POS                := 0x0004
            ,SIF_RANGE              := 0x0001
            ,SB_HORZ    := 0
            ,SB_VERT    := 1

            ,WS_HSCROLL := 0x00100000
            ,WS_VSCROLL := 0x00200000

        if (!this._isWindow(hWnd:=this._resolveHwnd(&hWnd_or_guiObj)))
            return false
        if (!this._coord.has(hWnd))    {
            this._coord[hWnd]:={border:{left:0,top:0,right:0,bottom:0}
                ,invisibility:{hscroll:true,vscroll:true}}
        }
        lpRect:=buffer(16,0)
        ,dllCall("User32.dll\GetClientRect", "Ptr",hWnd, "Ptr",lpRect.Ptr)
        ,client:={}
        ,client.left    := numGet(lpRect,0,"Int")
        ,client.top     := numGet(lpRect,4,"Int")
        ,client.right   := numGet(lpRect,8,"Int")
        ,client.bottom  := numGet(lpRect,12,"Int")
        ,style:=this._getWindowStyle(hWnd)
        if (this._coord[hWnd].invisibility.hscroll:=!(style&WS_HSCROLL))    {
            if (this._getVScrollBarInfo(hWnd, &objsbi))
                client.right+=objsbi.rcScrollBar.right-objsbi.rcScrollBar.left ;  vscrollBarWidth
        }
        if (this._coord[hWnd].invisibility.vscroll:=!(style&WS_VSCROLL))    {
            if (this._getHScrollBarInfo(hWnd, &objsbi))
                client.bottom+=objsbi.rcScrollBar.bottom-objsbi.rcScrollBar.top ;  hscrollBarHeight
        }
        for k,v in this._coord[hWnd].border.ownProps()
            this._coord[hWnd].border.%k%:=client.%k%
        border:=this._coord[hWnd].border
        ,invisibility:=this._coord[hWnd].invisibility
        ,this._opt[hWnd] := {innerScrollOnFocus:(!!innerScrollOnFocus)}
        ;-----------------------------------
        ,lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0), numPut("UInt",SIF_PAGE|SIF_POS|SIF_RANGE,lpsi,4)
        ,width:=border.right-border.left
        ,numPut("Int",0,lpsi,8)         ;  nMin
        ,numPut("Int",width-invisibility.vscroll,lpsi,12)  ;  nMax
        ,numPut("UInt",width,lpsi,16)   ;  The nPage member must specify a value from 0 to nMax - nMin +1
        ,dllCall("User32.dll\SetScrollInfo", "Ptr",hWnd, "Int",SB_HORZ, "Ptr",lpsi.Ptr, "Int",true, "Int")
        ;-----------------------------------
        ,lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0), numPut("UInt",SIF_PAGE|SIF_POS|SIF_RANGE,lpsi,4)
        ,height:=border.bottom-border.top      
        ,numPut("Int",0,lpsi,8)         ;  nMin
        ,numPut("Int",height-invisibility.hscroll,lpsi,12) ;  nMax
        ,numPut("UInt",height,lpsi,16)  ;  nPage
        ,dllCall("User32.dll\SetScrollInfo", "Ptr",hWnd, "Int",SB_VERT, "Ptr",lpsi.Ptr, "Int",true, "Int")
        return true
    }
    static unregister(hWnd_or_guiObj)    {
        if (this._coord.has(hWnd:=this._resolveHwnd(&hWnd_or_guiObj)))    {
            this._coord.delete(hWnd)
            ,this._opt.delete(hWnd)
            return true
        }
        return false
    }
    static enableInnerScrollOnFocus(hWnd_or_guiObj, onoff:=true)    {
        if (this._opt.has(hWnd:=this._resolveHwnd(&hWnd_or_guiObj)))
            this._opt[hWnd].innerScrollOnFocus := (!!onoff)
    }
    static isRegistered(hWnd_or_guiObj)    {
        return (this._coord.has(hWnd:=this._resolveHwnd(&hWnd_or_guiObj)))
    }
    static syncSize(hWnd_or_guiObj)    {
        if (!this._isWindow(hWnd:=this._resolveHwnd(&hWnd_or_guiObj)))
            return false
        if !(hContainerWnd:=this._findRegisteredContainer(hWnd))
            return false
        this._onSizing(hContainerWnd)
        return true
    }
    ;--------------------------------------------------
    static calculateInnerControlsSize(hWnd_or_guiObj, &left?, &top?, &right?, &bottom?, visibleControlsOnly:=true)    {
        if (!this._isWindow(hWnd:=this._resolveHwnd(&hWnd_or_guiObj)))
            return false
        left:= top:= right:= bottom:= 0
        ,prevDHW:=detectHiddenWindows(true)
        ,prevWD:=setWinDelay(-1)
        ,found:=false
        try  {
            if (hcntlList:=winGetControlsHwnd(hWnd), hcntlList.Length)    {
                left:= top:= 0x7FFFFFFFFFFFFFFF, right:= bottom:= 0
                for hCntl in hcntlList    {
                    if (visibleControlsOnly)    {
                        if (!controlGetVisible(hCntl))
                            continue
                    }
                    controlGetPos(&cntlX1, &cntlY1, &cntlW, &cntlH, hCntl), cntlX2:=cntlX1+cntlW, cntlY2:=cntlY1+cntlH
                    ,left  := min(left, cntlX1)
                    ,top   := min(top, cntlY1)
                    ,right := max(right, cntlX2)
                    ,bottom:= max(bottom, cntlY2)
                    ,found := true
                }
            }
        }  finally  {
            detectHiddenWindows(prevDHW)
            ,setWinDelay(prevWD)
        }
        if (!found)
            left:= top:= right:= bottom:= 0
        return true
    }
    ;--------------------------------------------------
    static getBoundary(hWnd_or_guiObj, &width?, &height?)    {
        width:= height:= ""
        if (boundarySize:=this._getRegisteredBoundarySize(hWnd:=this._resolveHwnd(&hWnd_or_guiObj)))    {
            width:=boundarySize.right - boundarySize.left
            ,height:=boundarySize.bottom - boundarySize.top
            return true
        }
        return false
    }
    static updateBoundary(hWnd_or_guiObj, newWidth?, newHeight?, setMaxSize:=true)    {
        hWnd:=this._resolveHwnd(&hWnd_or_guiObj)
        if (!this._coord.has(hWnd))
        || (!this._isWindow(hWnd))
        || !(guiObj:=guiFromHwnd(hWnd))
        || (!isSet(newWidth) && !isSet(newHeight))
            return false
        border:=this._coord[hWnd].border
        ,prevWidth:=border.right-border.left
        ,prevHeight:=border.bottom-border.top
        ,this._registerBoundarySize(hWnd,,, (isSet(newWidth) ? border.left + newWidth : unset), (isSet(newHeight) ? border.top + newHeight : unset))
        if (setMaxSize)    {
            showOptions:=""
            if (newWidth<prevWidth)
                showOptions.="w" newWidth
            if (newHeight<prevHeight)
                showOptions.=(showOptions==""?"":" ") "h" newHeight
            prevDHW:=detectHiddenWindows(true)
            ,prevWD:=setWinDelay(-1)
            ,guiObj.getPos(&guiX, &guiY, &guiW, &guiH), winGetPos(&winX, &winY, &winW, &winH, hWnd)
            switch (guiDpiScaled:=(guiW !== winW || guiH !== winH))
            {
                default:
                    guiObj.opt("+MaxSize" (newWidth??"") "x" (newHeight??""))
                    if (showOptions !== "")
                        guiObj.show(showOptions)
                case true:
                    prevIC:=critical("On")
                    ,guiObj.opt("-DPIScale")
                    ,guiObj.opt("+MaxSize" (newWidth??"") "x" (newHeight??""))
                    if (showOptions !== "")
                        guiObj.show(showOptions)
                    guiObj.opt("+DPIScale")
                    ,critical(prevIC)
            }
            detectHiddenWindows(prevDHW)
            ,setWinDelay(prevWD)
        }
        this.syncSize(hWnd)
        return true
    }
    static _getRegisteredBoundarySize(hWnd) => this._coord.has(hWnd)?this._coord[hWnd].border.clone():""
    static _registerBoundarySize(hWnd, left?, top?, right?, bottom?)    {
        if (!this._coord.has(hWnd))
            return false
        currBorder:=this._coord[hWnd].border
        ,newBorder:={left:left??currBorder.left
            ,top:top??currBorder.top
            ,right:right??currBorder.right
            ,bottom:bottom??currBorder.bottom}
        if (newBorder.right < newBorder.left || newBorder.bottom < newBorder.top)
            return false
        return (this._coord[hWnd].border:=newBorder, true)
    }
    /*
    static setOptions(hWnd, option?)    { ;  Not implemented yet.
    }
    */
    ;--------------------------------------------------
    static registerWndProc(Msg:=-1, maxThreads:=-1)    {
        static WM_DESTROY:=0x0002, WM_HSCROLL:=0x0114, WM_VSCROLL:=0x0115, WM_LBUTTONDOWN:=0x0201, WM_MOUSEWHEEL:=0x020A, WM_MOUSEHWHEEL:=0x020E, WM_SIZING:=0x0214, WM_EXITSIZEMOVE:=0x0232
        if (!this.hasProp("_objbmWndProc"))
            this._objbmWndProc:=objBindMethod(this,"wndProc")
        objbm:=this._objbmWndProc
        if (Msg!==-1)    {
            onMessage(Msg,objbm,maxThreads)
        }  else  {
            for _,Msg in [WM_DESTROY,WM_HSCROLL,WM_VSCROLL,WM_LBUTTONDOWN,WM_MOUSEWHEEL,WM_MOUSEHWHEEL,WM_SIZING,WM_EXITSIZEMOVE]
                onMessage(Msg,objbm,maxThreads)
        }
    }
    static wndProc(wParam, lParam, Msg, hWnd)    { ;  UPtr  Ptr  UInt  Ptr
        static WM_DESTROY:=0x0002, WM_HSCROLL:=0x0114, WM_VSCROLL:=0x0115, WM_LBUTTONDOWN:=0x0201, WM_MOUSEWHEEL:=0x020A, WM_MOUSEHWHEEL:=0x020E, WM_SIZING:=0x0214, WM_EXITSIZEMOVE:=0x0232
        if (Msg==WM_DESTROY)    {
            this.unregister(hWnd)
            return
        }
        prevIC:=critical("On")
        try  {
            if !(hContainerWnd:=this._findRegisteredContainer(hWnd))
                return
            switch (Msg)
            {
                ;  case WM_DESTROY:
                case WM_HSCROLL,WM_VSCROLL:         return this._onScroll(hContainerWnd, wParam, lParam, Msg, hWnd)
                case WM_LBUTTONDOWN:
                    if (hContainerWnd==hWnd)
                        dllCall("User32.dll\SetFocus", "Ptr",0, "Ptr")
                case WM_MOUSEWHEEL,WM_MOUSEHWHEEL:  return this._onMouseWheel(hContainerWnd, wParam, lParam, Msg, hWnd)
                case WM_SIZING:                     return this._onSizing(hContainerWnd, wParam, lParam, Msg, hWnd)
                case WM_EXITSIZEMOVE:               return this._onExitSizeMove(hContainerWnd, wParam, lParam, Msg, hWnd)
            }
        }  finally  {
            critical(prevIC)
        }
    }
    static _findRegisteredContainer(hWnd)    {
        static GA_PARENT:=1
        prevHwnd:=0
        ,hWnd&=0xffffffff
        while (hWnd)    {
            if (this.isRegistered(hWnd))
                return hWnd
            if (hWnd==prevHwnd)
                break
            prevHwnd:=hWnd
            ,hWnd:=dllCall("User32.dll\GetAncestor", "Ptr",hWnd, "UInt",GA_PARENT, "Ptr")&0xffffffff
        }
        return 0
    }
    ;--------------------------------------------------
    static CXVSCROLL    {
        get  {
            static SM_CXVSCROLL:=2
            return this._getSystemMetrics(SM_CXVSCROLL)
        }
    }
    static CYHSCROLL    {
        get  {
            static SM_CYHSCROLL:=3
            return this._getSystemMetrics(SM_CYHSCROLL)
        }
    }
    ;--------------------------------------------------
    static _onScroll(hContainerWnd, wParam, _, Msg, hWnd)    {
        static WM_HSCROLL       := 0x0114
            ,WM_VSCROLL         := 0x0115

            ,SB_CTL             := 2
            ,SB_HORZ            := 0
            ,SB_VERT            := 1

            ,SIF_ALL            := 0x0017 ;  (SIF_RANGE | SIF_PAGE | SIF_POS | SIF_TRACKPOS)
            ,SIF_DISABLENOSCROLL:= 0x0008
            ,SIF_PAGE           := 0x0002
            ,SIF_POS            := 0x0004
            ,SIF_RANGE          := 0x0001
            ,SIF_TRACKPOS       := 0x0010

            ,SB_ENDSCROLL       := 8 ;  Ends scroll.
            ,SB_LEFT            := 6 ;  Scrolls to the upper left.
            ,SB_RIGHT           := 7 ;  Scrolls to the lower right.
            ,SB_LINELEFT        := 0 ;  Scrolls left by one unit.
            ,SB_LINERIGHT       := 1 ;  Scrolls right by one unit.
            ,SB_PAGELEFT        := 2 ;  Scrolls left by the width of the window.
            ,SB_PAGERIGHT       := 3 ;  Scrolls right by the width of the window.
            ,SB_THUMBPOSITION   := 4 ;  The user has dragged the scroll box (thumb) and released the mouse button. The HIWORD indicates the position of the scroll box at the end of the drag operation.
            ,SB_THUMBTRACK      := 5 ;  The user is dragging the scroll box. This message is sent repeatedly until the user releases the mouse button. The HIWORD indicates the position that the scroll box has been dragged to.

            ,SW_ERASE           := 0x0004
            ,SW_INVALIDATE      := 0x0002
            ,SW_SCROLLCHILDREN  := 0x0001
            ,SW_SMOOTHSCROLL    := 0x0010

        if (hWnd!==hContainerWnd)
            return
        if (hFocusWnd:=dllCall("User32.dll\GetFocus", "Ptr"))    {
            if (this._getClassName(hFocusWnd)=="Edit" && this._isEditConnectedToUpDown(hFocusWnd))
                return
        }
        nBar:=(Msg==WM_HSCROLL?SB_HORZ:SB_VERT)
        ,lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0)       ;  cbSize
        ,numput("UInt",SIF_ALL,lpsi,4)  ;  fMask
        if (!dllCall("User32.dll\GetScrollInfo", "Ptr",hContainerWnd, "Int",nBar, "Ptr",lpsi.Ptr))
            return
        nMin    := numGet(lpsi,8,"Int")
        ,nMax   := numGet(lpsi,12,"Int")
        ,nPage  := numGet(lpsi,16,"Int")
        ,nPos   := numGet(lpsi,20,"Int"), nNewPos:= nPrevPos:= nPos
        ,nTrackPos:=numGet(lpsi,24,"Int")
        switch (this._LOWORD(wParam))
        {
            default:                                return ;  SB_ENDSCROLL
            case SB_LEFT:                           nNewPos:=nMin
            case SB_RIGHT:                          nNewPos:=nMax
            case SB_LINELEFT:                       nNewPos-=30
            case SB_LINERIGHT:                      nNewPos+=30
            case SB_PAGELEFT:
                lpRect:=buffer(16)
                ,dllCall("User32.dll\GetClientRect", "Ptr",hContainerWnd, "Ptr",lpRect.Ptr)
                ,clientW:=numGet(lpRect,8,"Int")-numGet(lpRect,0,"Int")
                ,clientH:=numGet(lpRect,12,"Int")-numGet(lpRect,4,"Int")
                switch (nBar)
                {
                    case SB_HORZ:       nNewPos-=clientW
                    default:            nNewPos-=clientH
                }
            case SB_PAGERIGHT:
                lpRect:=buffer(16)
                ,dllCall("User32.dll\GetClientRect", "Ptr",hContainerWnd, "Ptr",lpRect.Ptr)
                ,clientW:=numGet(lpRect,8,"Int")-numGet(lpRect,0,"Int")
                ,clientH:=numGet(lpRect,12,"Int")-numGet(lpRect,4,"Int")
                switch (nBar)
                {
                    case SB_HORZ:       nNewPos+=clientW
                    default:            nNewPos+=clientH
                }
            case SB_THUMBPOSITION,SB_THUMBTRACK:    nNewPos:=nTrackPos ;  Use nTrackPos from GetScrollInfo; HIWORD(wParam) is only 16-bit.
        }
        invisibility:=this._coord[hContainerWnd].invisibility
        switch (nBar)
        {
            case SB_HORZ:       i:=invisibility.hscroll
            default:            i:=invisibility.vscroll
        }
        nNewPos:=max(nMin,min(nNewPos,nMax-max(nPage-i,0))) ;  The nPos member must specify a value between nMin and nMax - max( nPage– 1, 0).
        ,dx:= dy:= 0
        switch (nBar)
        {
            case SB_HORZ:       dx:=nPrevPos-nNewPos
            default:            dy:=nPrevPos-nNewPos ;  SB_VERT
        }
        dllCall("User32.dll\ScrollWindowEx", "Ptr",hContainerWnd, "Int",dx, "Int",dy, "Ptr",0, "Ptr",0, "Ptr",0, "Ptr",0, "UInt",(SW_ERASE|SW_INVALIDATE|SW_SCROLLCHILDREN)&0xffff, "Int") ;  dllCall("User32.dll\ScrollWindow", "Ptr",hContainerWnd, "Int",dx, "Int",dy, "Ptr",0, "Ptr",0)
        ,numPut("Int",nNewPos,lpsi,20) ;  nPos
        ,dllCall("User32.dll\SetScrollInfo", "Ptr",hContainerWnd, "Int",nBar, "Ptr",lpsi.Ptr, "Int",true, "Int")
    }
    static _onMouseWheel(hContainerWnd, wParam, _, Msg, hWnd)    {
        static WHEEL_DELTA:=120

            ,MK_CONTROL := 0x0008
            ,MK_LBUTTON := 0x0001
            ,MK_MBUTTON := 0x0010
            ,MK_RBUTTON := 0x0002
            ,MK_SHIFT   := 0x0004
            ,MK_XBUTTON1:= 0x0020
            ,MK_XBUTTON2:= 0x0040

            ,WM_MOUSEWHEEL  := 0x020A
            ,WM_MOUSEHWHEEL := 0x020E
            ,WM_HSCROLL := 0x0114
            ,WM_VSCROLL := 0x0115
            ,WS_HSCROLL := 0x00100000
            ,WS_VSCROLL := 0x00200000

            ,SB_LINELEFT    := 0
            ,SB_LINERIGHT   := 1

            ,STATE_SYSTEM_INVISIBLE     := 0x00008000
            ,STATE_SYSTEM_OFFSCREEN     := 0x00010000
            ,STATE_SYSTEM_PRESSED       := 0x00000008
            ,STATE_SYSTEM_UNAVAILABLE   := 0x00000001
            
            ,UDM_SETPOS32   := (0x0400 + 113) ;  (WM_USER+113)
            ,UDM_GETPOS32   := (0x0400 + 114) ;  (WM_USER+114)

            ,CB_ERR         := -1
            ,CB_GETCOUNT    := 0x0146
            ,CB_GETCURSEL   := 0x0147
            ,CB_SETCURSEL   := 0x014E

        lpRect:=buffer(16,0)
        ,dllCall("User32.dll\GetClientRect", "Ptr",hContainerWnd, "Ptr",lpRect.Ptr)
        ,client:={}
        ,client.left    := numGet(lpRect,0,"Int")
        ,client.top     := numGet(lpRect,4,"Int")
        ,client.right   := numGet(lpRect,8,"Int")
        ,client.bottom  := numGet(lpRect,12,"Int")
        ,border:=this._coord[hContainerWnd].border
        ;-----------------------------------
        ,ret:=0
        ,pm:={}
        ,pm.hWnd:=hContainerWnd
        ,wheelCount:=abs((wheelDistance:=this._GET_WHEEL_DELTA_WPARAM(wParam))//WHEEL_DELTA)
        ,keyState:=this._GET_KEYSTATE_WPARAM(wParam)
        switch (Msg)
        {
            case WM_MOUSEWHEEL:     pm.Msg:=(!(keyState&MK_CONTROL)&&(keyState&MK_SHIFT))?WM_HSCROLL:WM_VSCROLL
            default:                pm.Msg:=WM_HSCROLL ;  WM_MOUSEHWHEEL
        }
        pm.wParam:=(wheelDistance<0?SB_LINERIGHT:SB_LINELEFT)
        ,pm.lParam:=0
        if !(border.left<client.left || border.top<client.top || client.right<border.right || client.bottom<border.bottom)    {
            if (pm.Msg==WM_HSCROLL)    {
                style:=this._getWindowStyle(hWnd)
                if (hasScroll:=style&WS_HSCROLL)    {
                    if (bRet:=this._getHScrollBarInfo(hWnd, &objsbi))    {
                        if !(objsbi.rgstate[0]&STATE_SYSTEM_UNAVAILABLE)    {
                            loop (wheelCount*3)
                                dllCall("User32.dll\PostMessage", "Ptr",hWnd, "UInt",pm.Msg, "UPtr",pm.wParam, "Ptr",pm.lParam)
                            return 0
                        }
                    }
                }
            }
            return
        }
        ;-----------------------------------
        switch (this._opt[hContainerWnd].innerScrollOnFocus)
        {
            case true:          hCntl:=dllCall("User32.dll\GetFocus", "Ptr")
            default:            hCntl:=hWnd
        }
        if (hCntl)    {
            style:=this._getWindowStyle(hCntl)
            switch (pm.Msg)
            {
                case WM_VSCROLL:
                    hasScroll:=style&WS_VSCROLL                  
                    if (!hasScroll && Msg==WM_MOUSEWHEEL)    {
                        if (hasScroll:=style&WS_HSCROLL)
                            pm.Msg:=WM_HSCROLL
                    }
                default: ;  WM_HSCROLL
                    hasScroll:=style&WS_HSCROLL
            }
            if (hasScroll)    {
                if (hCntl==hWnd && hCntl!==hContainerWnd)    {
                    switch (pm.Msg)
                    {
                        case WM_VSCROLL:        bRet:=this._getVScrollBarInfo(hCntl, &objsbi)
                        default:                bRet:=this._getHScrollBarInfo(hCntl, &objsbi) ;  WM_HSCROLL
                    }
                    if (bRet)    {
                        if !(objsbi.rgstate[0]&STATE_SYSTEM_UNAVAILABLE)    {
                            if (pm.Msg==WM_HSCROLL)    {
                                loop (wheelCount*3)
                                    dllCall("User32.dll\PostMessage", "Ptr",hCntl, "UInt",pm.Msg, "UPtr",pm.wParam, "Ptr",pm.lParam)
                                wheelCount:=0, ret:=0
                            }  else  {
                                wheelCount:=0, ret:=""
                            }
                        }
                    }
                }
            }  else  {
                hComboBoxWnd:=0
                switch (this._getClassName(hCntl))
                {
                    case "ComboBox":                hComboBoxWnd:=hCntl
                    case "Edit": ;  UpDown
                        if (hUpDownWnd:=this._isEditConnectedToUpDown(hCntl))    {
                            wheelCount:=0, ret:=0
                            ,pos32:=dllCall("User32.dll\SendMessage", "Ptr",hUpDownWnd, "UInt",UDM_GETPOS32, "UPtr",0, "Ptr",0)
                            ,dllCall("User32.dll\SendMessage", "Ptr",hUpDownWnd, "UInt",UDM_SETPOS32, "UPtr",0, "Ptr",pos32+wheelDistance//WHEEL_DELTA)
                            /*
                             About Up-Down Controls
                            https://learn.microsoft.com/en-us/windows/win32/controls/up-down-controls
                             Up-Down Control
                            https://learn.microsoft.com/en-us/windows/win32/controls/up-down-control-reference
                            */
                        }  else if (hComboBoxWnd:=this._isEditConnectedToComboBox(hCntl))    {
                            /*
                             ComboBox Control Messages
                            https://learn.microsoft.com/en-us/windows/win32/controls/bumper-combobox-control-reference-messages
                            */
                        }
                }
                if (hComboBoxWnd)    {
                    wheelCount:=0, ret:=0                           
                    ,count:=dllCall("User32.dll\SendMessage", "Ptr",hComboBoxWnd, "UInt",CB_GETCOUNT, "UPtr",0, "Ptr",0, "Int")
                    if (count!==CB_ERR && count!==0)    {
                        curSel:=dllCall("User32.dll\SendMessage", "Ptr",hComboBoxWnd, "UInt",CB_GETCURSEL, "UPtr",0, "Ptr",0, "Int")
                        ,newSel:=curSel==CB_ERR?0:max(0,min(count,curSel-wheelDistance//WHEEL_DELTA))
                        ,dllCall("User32.dll\SendMessage", "Ptr",hComboBoxWnd, "UInt",CB_SETCURSEL, "Int",newSel, "Ptr",0, "Ptr")
                    }
                }
            }
        }
        ;-----------------------------------
        loop (wheelCount)
            dllCall("User32.dll\PostMessage", "Ptr",pm.hWnd, "UInt",pm.Msg, "UPtr",pm.wParam, "Ptr",pm.lParam)
        return ret
    }
    static _onSizing(hContainerWnd, *)    {
        static SIF_DISABLENOSCROLL  := 0x0008
            ,SIF_PAGE               := 0x0002
            ,SIF_POS                := 0x0004
            ,SIF_RANGE              := 0x0001

            ,SB_HORZ                := 0
            ,SB_VERT                := 1

            ,RDW_ERASE              := 0x0004
            ,RDW_FRAME              := 0x0400
            ,RDW_INTERNALPAINT      := 0x0002
            ,RDW_INVALIDATE         := 0x0001
            ,RDW_NOERASE            := 0x0020
            ,RDW_NOFRAME            := 0x0800
            ,RDW_NOINTERNALPAINT    := 0x0010
            ,RDW_VALIDATE           := 0x0008
            ,RDW_ERASENOW           := 0x0200
            ,RDW_UPDATENOW          := 0x0100

            ,SW_ERASE           := 0x0004
            ,SW_INVALIDATE      := 0x0002
            ,SW_SCROLLCHILDREN  := 0x0001
            ,SW_SMOOTHSCROLL    := 0x0010

            ,RGN_AND                := 1
            ,RGN_COPY               := 5
            ,RGN_DIFF               := 4
            ,RGN_OR                 := 2
            ,RGN_XOR                := 3

        lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0)       ;  cbSize
        ,numPut("UInt",SIF_POS,lpsi,4)  ;  fMask
        ,dllCall("User32.dll\GetScrollInfo", "Ptr",hContainerWnd, "Int",SB_HORZ, "Ptr",lpsi.Ptr)
        ,nPosHorzPrev:=numGet(lpsi,20,"Int")
        ,lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0)       ;  cbSize
        ,numput("UInt",SIF_POS,lpsi,4)  ;  fMask
        ,dllCall("User32.dll\GetScrollInfo", "Ptr",hContainerWnd, "Int",SB_VERT, "Ptr",lpsi.Ptr)
        ,nPosVertPrev:=numGet(lpsi,20,"Int")
        ;-----------------------------------
        ,lpRect:=buffer(16,0)
        ,dllCall("User32.dll\GetClientRect", "Ptr",hContainerWnd, "Ptr",lpRect.Ptr)
        ,client:={}
        ,client.left    := numGet(lpRect,0,"Int")
        ,client.top     := numGet(lpRect,4,"Int")
        ,client.right   := numGet(lpRect,8,"Int")
        ,client.bottom  := numGet(lpRect,12,"Int")
        ,client.width   := client.right-client.left
        ,client.height  := client.bottom-client.top
        ,border:=this._coord[hContainerWnd].border
        ,invisibility:=this._coord[hContainerWnd].invisibility
        ;-----------------------------------
        ,lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0), numPut("UInt",SIF_PAGE|SIF_RANGE,lpsi,4)
        ,nPage:=client.height
        ,nMax:=border.bottom-border.top-invisibility.hscroll
        if (this._getHScrollBarInfo(hContainerWnd, &objsbi))    {
            hscrollBarHeight:=objsbi.rcScrollBar.bottom-objsbi.rcScrollBar.top
            if (!invisibility.hscroll)
                nPage-=hscrollBarHeight, nMax-=hscrollBarHeight
            else if (!this._scrollInvisibilityFromState(objsbi.rgstate[0]))
                nPage+=hscrollBarHeight
        }
        numPut("UInt",nPage,lpsi,16)    ;  nPage
        ,numPut("Int",nMax,lpsi,12)     ;  nMax
        ,dllCall("User32.dll\SetScrollInfo", "Ptr",hContainerWnd, "Int",SB_VERT, "Ptr",lpsi.Ptr, "Int",true)
        ;-----------------------------------
        ,lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0), numPut("UInt",SIF_PAGE|SIF_RANGE,lpsi,4)
        ,nPage:=client.width
        ,nMax:=border.right-border.left-invisibility.vscroll
        if (this._getVScrollBarInfo(hContainerWnd, &objsbi))    {
            vscrollBarWidth:=objsbi.rcScrollBar.right-objsbi.rcScrollBar.left
            if (!invisibility.vscroll)
                nPage-=vscrollBarWidth, nMax-=vscrollBarWidth
            else if (!this._scrollInvisibilityFromState(objsbi.rgstate[0]))
                nPage+=vscrollBarWidth
        }
        numPut("UInt",nPage,lpsi,16)    ;  nPage
        ,numPut("Int",nMax,lpsi,12)     ;  nMax
        ,dllCall("User32.dll\SetScrollInfo", "Ptr",hContainerWnd, "Int",SB_HORZ, "Ptr",lpsi.Ptr, "Int",true)
        ;-----------------------------------       
        ,lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0)       ;  cbSize
        ,numput("UInt",SIF_POS,lpsi,4)  ;  fMask
        ,dllCall("User32.dll\GetScrollInfo", "Ptr",hContainerWnd, "Int",SB_HORZ, "Ptr",lpsi.Ptr)
        ,nPosHorzCurr:=numGet(lpsi,20,"Int")
        ,lpsi:=buffer(28,0)
        ,numPut("UInt",28,lpsi,0)       ;  cbSize
        ,numput("UInt",SIF_POS,lpsi,4)  ;  fMask
        ,dllCall("User32.dll\GetScrollInfo", "Ptr",hContainerWnd, "Int",SB_VERT, "Ptr",lpsi.Ptr)
        ,nPosVertCurr:=numGet(lpsi,20,"Int")
        ,dx:=nPosHorzPrev-nPosHorzCurr
        ,dy:=nPosVertPrev-nPosVertCurr
        if (dx||dy)    {
            dllCall("User32.dll\ScrollWindowEx", "Ptr",hContainerWnd, "Int",dx, "Int",dy, "Ptr",0, "Ptr",0, "Ptr",0, "Ptr",0, "UInt",(SW_ERASE|SW_INVALIDATE|SW_SCROLLCHILDREN)&0xffff, "Int") ;  dllCall("User32.dll\ScrollWindow", "Ptr",hContainerWnd, "Int",dx, "Int",dy, "Ptr",0, "Ptr",0)
            ,hrgnDst:=dllCall("Gdi32.dll\CreateRectRgn", "Int",0, "Int",0, "Int",0, "Int",0, "Ptr")
            ,hrgnSrc1:=dllCall("Gdi32.dll\CreateRectRgn", "Int",0, "Int",0, "Int",dx, "Int",client.height, "Ptr")
            ,hrgnSrc2:=dllCall("Gdi32.dll\CreateRectRgn", "Int",0, "Int",0, "Int",client.width, "Int",dy, "Ptr")
            ,dllCall("Gdi32.dll\CombineRgn", "Ptr",hrgnDst, "Ptr",hrgnSrc1, "Ptr",hrgnSrc2, "Int",RGN_OR, "Int")
            ,dllCall("User32.dll\RedrawWindow", "Ptr",hContainerWnd, "Ptr",0, "Ptr",hrgnDst, "UInt",RDW_UPDATENOW) ;  dllCall("User32.dll\RedrawWindow", "Ptr",hContainerWnd, "Ptr",0, "Ptr",0, "UInt",RDW_INVALIDATE|RDW_ERASE|RDW_UPDATENOW)
            ,dllCall("Gdi32.dll\DeleteObject", "Ptr",hrgnDst)
            ,dllCall("Gdi32.dll\DeleteObject", "Ptr",hrgnSrc1)
            ,dllCall("Gdi32.dll\DeleteObject", "Ptr",hrgnSrc2)
        }
    }
    static _onExitSizeMove(hContainerWnd, _1, _2, _3, hWnd)    {
        if (hWnd==hContainerWnd)
            dllCall("User32.dll\SetFocus", "Ptr",0, "Ptr")
    }
    ;--------------------------------------------------
    static _getHScrollBarInfo(hWnd, &objsbi)    {
        static OBJID_HSCROLL:=0xFFFFFFFA
        return this._getScrollBarInfo(hWnd,OBJID_HSCROLL,&objsbi)
    }
    static _getVScrollBarInfo(hWnd, &objsbi)     {
        static OBJID_VSCROLL:=0xFFFFFFFB
        return this._getScrollBarInfo(hWnd,OBJID_VSCROLL,&objsbi)
    }
    static _scrollInvisibilityFromState(rgstate:=0)    {
        static STATE_SYSTEM_INVISIBLE:=0x00008000
        return !!(rgstate&STATE_SYSTEM_INVISIBLE)
    }
    static _getScrollBarInfo(hWnd, idObject, &objsbi)    {
        objsbi:={cbSize:"",rcScrollBar:{left:"",top:"",right:"",bottom:""},dxyLineButton:"",xyThumbTop:"",xyThumbBottom:"",reserved:"",rgstate:map(0,"", 1,"", 2,"", 3,"", 4,"", 5,"")}
        ,psbi:=buffer(60,0)
        ,numPut("UInt",60,psbi,0)
        if (bRet:=dllCall("User32.dll\GetScrollBarInfo", "Ptr",hWnd, "Int",idObject, "Ptr",psbi.Ptr))    {
             objsbi.cbSize:=numGet(psbi,0,"UInt")
            ,objsbi.rcScrollBar.left:=numGet(psbi,4,"Int")
            ,objsbi.rcScrollBar.top:=numGet(psbi,8,"Int")
            ,objsbi.rcScrollBar.right:=numGet(psbi,12,"Int")
            ,objsbi.rcScrollBar.bottom:=numGet(psbi,16,"Int")
            ,objsbi.dxyLineButton:=numGet(psbi,20,"Int")
            ,objsbi.xyThumbTop:=numGet(psbi,24,"Int")
            ,objsbi.xyThumbBottom:=numGet(psbi,28,"Int")
            ,objsbi.reserved:=numGet(psbi,32,"Int")
            loop 6
                objsbi.rgstate[A_Index-1]:=numGet(psbi,32+A_Index*4,"Int")
        }
        return bRet
    }
    static _resolveHwnd(&hWnd_or_guiObj) => (hWnd_or_guiObj is gui?hWnd_or_guiObj.Hwnd:integer(hWnd_or_guiObj))&0xffffffff
    static _isWindow(hWnd) => dllCall("User32.dll\IsWindow", "Ptr",hWnd, "Int")
    static _getWindowStyle(hWnd)    {
        static GWL_STYLE:=-16
        return dllCall("User32.dll\GetWindowLong" (A_PtrSize==8?"Ptr":""), "Ptr",hWnd, "Int",GWL_STYLE, (A_PtrSize==8?"Ptr":"Int"))
    }
    static _getClassName(hWnd, nMaxCount?)    {
        static MAX_CLASS_NAME:=1024
        if (!isSet(nMaxCount))
            nMaxCount:=MAX_CLASS_NAME
        lpClassName:=buffer(2*nMaxCount, 0)
        return (dllCall("User32.dll\GetClassName", "Ptr",hWnd, "Ptr",lpClassName.Ptr, "Int",nMaxCount, "Int"))
            ?strGet(lpClassName.Ptr)
            :""
    }
    static _isEditConnectedToUpDown(hWnd)    {
        static GW_HWNDNEXT  := 2
            ,UPDOWN_CLASS   := "msctls_updown32"
        return (this._getClassName(hNextWnd:=dllCall("User32.dll\GetWindow", "Ptr",hWnd, "UInt",GW_HWNDNEXT, "Ptr"))==UPDOWN_CLASS
            ?hNextWnd
            :0)
    }
    static _isEditConnectedToComboBox(hWnd)    {
        static GA_PARENT    := 1
            ,WC_COMBOBOX    := "ComboBox"
        return (this._getClassName(hParentWnd:=dllCall("User32.dll\GetAncestor", "Ptr",hWnd, "UInt",GA_PARENT, "Ptr"))==WC_COMBOBOX
            ?hParentWnd
            :0)
    }
    static _getSystemMetrics(nIndex) => dllCall("User32.dll\GetSystemMetrics", "Int",nIndex, "Int")
    ;--------------------------------------------------    
    static _HIWORD(l) => (l<<32>>>48)                               ;  C++ #define HIWORD(l) ((WORD)((((DWORD_PTR)(l)) >> 16) & 0xffff))
    static _LOWORD(l) => (l&0xffff) ;  (l<<48>>>48)                 ;  C++ #define LOWORD(l) ((WORD)(((DWORD_PTR)(l)) & 0xffff))
    static _GET_WHEEL_DELTA_WPARAM(wParam) => (wParam<<32>>48)      ;  C++ #define GET_WHEEL_DELTA_WPARAM(wParam) ((short)HIWORD(wParam))
    static _GET_KEYSTATE_WPARAM(wParam) => (wParam&0xffff)          ;  C++ #define GET_KEYSTATE_WPARAM(wParam) (LOWORD(wParam))
}
