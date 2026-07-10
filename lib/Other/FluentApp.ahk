#Requires AutoHotkey v2.0
#SingleInstance Force

class FluentApp {
    __New() {
        ; Force AHK's native Context Menus into Windows 11 Dark Mode
        try DllCall("uxtheme\SetPreferredAppMode", "Int", 2)
        try DllCall("uxtheme\FlushMenuThemes")

        ; Win32 Physics & Event Hooks
        OnMessage(0x0200, this.OnMouseMove.Bind(this))
        OnMessage(0x02A3, this.OnMouseLeave.Bind(this))
        OnMessage(0x0201, this.OnLButtonDown.Bind(this))
        OnMessage(0x0202, this.OnLButtonUp.Bind(this))
        OnMessage(0x020A, this.OnMouseWheel.Bind(this))
        OnMessage(0x0020, this.OnSetCursor.Bind(this))
        OnMessage(0x0006, this.OnWM_ACTIVATE.Bind(this))
        OnMessage(0x0205, this.OnRButtonUp.Bind(this))
        OnMessage(0x0100, this.OnWM_KEYDOWN.Bind(this))  ; Keyboard Interaction Hook

        this.IsDark := true
        this.CurrentBackdropType := 2
        this.ActiveTab := "Forms && Data"
        this.ActiveSubPages := Map()

        this.RebuildUI()
    }

    RebuildUI() {
        if this.HasOwnProp("Gui") && this.Gui {
            try this.Gui.Destroy()
        }

        this.Pages := Map()
        this.Hoverables := Map()
        this.CursorZones := Map()
        this.IBeamZones := Map()
        this.SidebarTabs := []
        this.Sliders := []
        this.ActiveSlider := ""
        this.FocusedSlider := ""
        this.ActiveClick := 0
        this.ActiveDDL := ""
        this.Pop := ""

        ; Dynamic Theme Variables
        this.ThemeBg  := (VerCompare(A_OSVersion, "10.0.22000") >= 0) ? (this.IsDark ? "000000" : "FFFFFF") : (this.IsDark ? "1E1E1E" : "F3F3F3")
        this.C_Txt    := this.IsDark ? "White"   : "000000"
        this.C_SecTxt := this.IsDark ? "A0A0A0"  : "5D5D5D"
        this.C_Panel  := this.IsDark ? "333333"  : "F3F3F3"
        this.C_Inner  := this.IsDark ? "141414"  : "FFFFFF"
        this.C_Head   := this.IsDark ? "2A2A2A"  : "EBEBEB"
        this.C_List   := this.IsDark ? "1C1C1C"  : "FFFFFF"
        this.C_Hover  := this.IsDark ? "1A1A1A"  : "E5E5E5"
        this.C_Hover2 := this.IsDark ? "2A2A2A"  : "DCDCDC"
        this.C_Click  := this.IsDark ? "101010"  : "D0D0D0"

        this.Gui := Gui("-Resize", "Mica Demo")
        this.Gui.OnEvent("Close", (*) => ExitApp())
        this.Gui.BackColor := this.ThemeBg

        ; Apply Titlebar Dark/Light Mode
        val := Buffer(4, 0)
        NumPut("Int", this.IsDark ? 1 : 0, val)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Gui.Hwnd, "Int", 20, "Ptr", val, "Int", 4)

        this.EnableBackdrop(this.Gui.Hwnd, this.CurrentBackdropType)

        this.BuildUI()
        this.Gui.Show("w880 h640")

        this.SwitchTab(this.ActiveTab)
    }

    ; ==========================================
    ; USER INTERFACE LAYOUT
    ; ==========================================

    BuildUI() {
        ; --- SIDEBAR ---
        this.Gui.SetFont("s16 w600 c" this.C_Txt, "Segoe UI Variable Display")
        this.Gui.Add("Text", "x24 y24 w140 BackgroundTrans", "Framework")
        this.Gui.Add("Text", "x180 y0 w1 h640 Background" this.C_Panel)

        this.Indicator := this.Gui.Add("Text", "x2 y86 w4 h24 Background0078D4")

        this.AddSidebarTab(80, "Dashboard", "Dashboard")
        this.AddSidebarTab(125, "Forms && Data", "Forms && Data")
        this.AddSidebarTab(170, "Appearance", "Appearance")

        ; --- PAGE: DASHBOARD ---
        this.InitPage("Dashboard")
        this.AddTitle("Dashboard", "Dashboard", "System controls and behavior overview. (Right click anywhere!)")

        this.AddGroupBox("Dashboard", 220, 100, 620, 200, "System Actions")
        this.AddToggle("Dashboard", 240, 150, "Hardware Acceleration", true)
        this.AddToggle("Dashboard", 240, 190, "Launch on startup", false)
        this.AddCheckbox("Dashboard", 240, 235, "I agree to the telemetry terms and conditions.", true)

        this.AddGroupBox("Dashboard", 220, 320, 620, 100, "System Resources")
        this.AddProgressBar("Dashboard", 240, 365, 580, 65, "Storage Capacity (Local Disk C:)")

        ; --- PAGE: FORMS & DATA ---
        this.InitPage("Forms && Data")
        this.AddTitle("Forms && Data", "Components", "A massive library of sexy native Fluent controls.")

        ; 1. Horizontal Tabs
        hTabs := ["General Elements", "Advanced Properties", "Security"]
        subPages := ["Forms_Gen", "Forms_Adv", "Forms_Sec"]
        this.AddHorizontalTabs("Forms && Data", 220, 100, 620, hTabs, subPages, 1)

        this.InitPage("Forms_Gen")
        this.InitPage("Forms_Adv")
        this.InitPage("Forms_Sec")

        ; Sub-page: General Elements
        this.AddGroupBox("Forms_Gen", 220, 160, 280, 430, "Form Controls")
        this.InpUser := this.AddInput("Forms_Gen", 240, 210, 240, "Enter your username...")
        this.AddCheckbox("Forms_Gen", 240, 260, "Remember my credentials", true)
        this.AddCheckbox("Forms_Gen", 240, 295, "Accept terms && conditions", false)

        this.AddToggleButton("Forms_Gen", 240, 345, 240, "Enable Developer Mode", true)
        this.AddDropdownButton("Forms_Gen", 240, 395, 240, "Export Target...", ["JSON File", "CSV Data", "PDF Report"], (*) => MsgBox("Exported!"))

        this.AddSlider("Forms_Gen", 240, 445, 240, 0, 100, 5, 75, "Volume Level")

        this.AddButton("Forms_Gen", 240, 500, 240, "Submit Data", "Primary", (*) => MsgBox("Clicked!"))
        this.AddButton("Forms_Gen", 240, 545, 240, "Discard Draft", "Secondary", (*) => MsgBox("Discarded!"))

        this.AddGroupBox("Forms_Gen", 520, 160, 320, 430, "Extra Settings")
        this.AddToggle("Forms_Gen", 540, 210, "Sync across devices", true)
        this.AddToggle("Forms_Gen", 540, 250, "Background processing", false)

        this.Gui.SetFont("s10 w600 c" this.C_Txt, "Segoe UI")
        lbl := this.Gui.Add("Text", "x540 y295 w200 h20 BackgroundTrans", "Notification Style")
        this.Pages["Forms_Gen"].Push(lbl)
        this.AddRadioGroup("Forms_Gen", 540, 325, ["Toast Notifications", "Action Center Only", "Muted"], 1)

        ; Sub-page: Advanced Properties (Data Grid)
        this.AddGroupBox("Forms_Adv", 220, 160, 620, 430, "Sortable Data Grid")
        cols := ["ID", "Process Name", "Status"]
        rows := [[1, "AutoHotkey.exe", "Active"], [2, "Explorer.exe", "Idle"], [3, "DWM.exe", "Active"], [4, "Chrome.exe", "Sleeping"], [5, "Discord.exe", "Active"], [6, "Code.exe", "Active"], [7, "Spotify.exe", "Sleeping"]]
        this.AddListView("Forms_Adv", 235, 205, 590, 370, cols, rows)

        ; Sub-page: Security
        this.AddGroupBox("Forms_Sec", 220, 160, 620, 430, "Security Policies")
        this.AddCheckbox("Forms_Sec", 240, 210, "Require UAC elevation for system changes", true)
        this.AddCheckbox("Forms_Sec", 240, 250, "Enforce strictly typed inputs", true)
        this.AddCheckbox("Forms_Sec", 240, 290, "Enable biometric authentication", false)
        this.AddButton("Forms_Sec", 240, 340, 200, "Revoke All Keys", "Secondary", (*) => MsgBox("Revoked!"))

        ; --- PAGE: APPEARANCE ---
        this.InitPage("Appearance")
        this.AddTitle("Appearance", "Appearance", "Customize your glass materials in real-time.")

        this.AddGroupBox("Appearance", 220, 100, 620, 140, "Backdrop Material Engine")
        materials := ["Mica (Standard)", "Acrylic (Frosted)", "Mica Alt (Tinted)", "System Theme"]
        matIdx := (this.CurrentBackdropType == 3) ? 2 : (this.CurrentBackdropType == 4) ? 3 : 1
        this.AddDropdown("Appearance", 240, 150, 460, materials, matIdx, this.OnChangeBackdrop.Bind(this))

        this.AddGroupBox("Appearance", 220, 260, 620, 100, "Theme Engine")
        this.AddToggle("Appearance", 240, 310, "Dark Mode", this.IsDark, this.OnToggleTheme.Bind(this))

        ; Trap default startup focus
        this.Dummy := this.Gui.Add("Button", "x-100 y-100 w1 h1 -TabStop Default", "")
        try ControlFocus(this.Dummy)
    }

    ; ==========================================
    ; COMPONENT GENERATORS (OOP)
    ; ==========================================

    InitPage(name) => this.Pages[name] := []

    AddTitle(page, title, subtitle) {
        this.Gui.SetFont("s22 w600 c" this.C_Txt, "Segoe UI Variable Display")
        this.Pages[page].Push(this.Gui.Add("Text", "x220 y30 w500 h40 BackgroundTrans", title))
        this.Gui.SetFont("s10 w400 c" this.C_SecTxt, "Segoe UI")
        this.Pages[page].Push(this.Gui.Add("Text", "x220 y70 w500 h20 BackgroundTrans", subtitle))
    }

    AddGroupBox(page, x, y, w, h, title) {
        border := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Background" this.C_Panel)
        inner  := this.Gui.Add("Text", "x" (x+1) " y" (y+1) " w" (w-2) " h" (h-2) " Background" this.C_Inner)

        header := this.Gui.Add("Text", "x" x " y" y " w" w " h40 Background" this.C_Head)
        block  := this.Gui.Add("Text", "x" x " y" (y+20) " w" w " h20 Background" this.C_Head)
        this.Gui.SetFont("s11 w600 c" this.C_Txt, "Segoe UI")
        lbl := this.Gui.Add("Text", "x" (x+16) " y" (y+10) " w" (w-32) " h20 BackgroundTrans", title)

        this.Pages[page].Push(border, inner, header, block, lbl)
    }

    AddHorizontalTabs(page, x, y, w, tabs, subPages, defaultIdx) {
        tabW := w / tabs.Length
        h := 40

        bg := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " BackgroundTrans")

        if (!this.ActiveSubPages.Has(page))
            this.ActiveSubPages[page] := subPages[defaultIdx]

        obj := { TabW: tabW, X: x, Y: y, H: h, DefaultIdx: defaultIdx, Btns: [], ParentPage: page, SubPages: subPages }
        this.Gui.SetFont("s10 w600", "Segoe UI")

        For i, t in tabs {
            tX := x + (i-1)*tabW
            btnBg := this.Gui.Add("Text", "x" tX " y" y " w" tabW " h" h " Background" this.ThemeBg)
            lbl := this.Gui.Add("Text", "x" tX " y" y " w" tabW " h" h " 0x200 Center BackgroundTrans c" (i==defaultIdx ? this.C_Txt : this.C_SecTxt) " +E0x20", t)

            clickCb := this.OnHorzTabClick.Bind(this, obj, i)
            btnBg.OnEvent("Click", clickCb)

            this.Hoverables[btnBg.Hwnd] := { Ctrl: btnBg, Normal: this.ThemeBg, Hover: this.C_Hover, Click: this.C_Click, Hovered: false, Group: [lbl] }
            this.CursorZones[btnBg.Hwnd] := 32649
            obj.Btns.Push({ Bg: btnBg, Lbl: lbl })
            this.Pages[page].Push(btnBg, lbl)
        }

        ; Placed after buttons so the indicator renders visibly on top of the tab backgrounds
        indicator := this.Gui.Add("Text", "x" (x + (defaultIdx-1)*tabW + 16) " y" (y+h-3) " w" (tabW-32) " h3 Background0078D4")
        obj.Indicator := indicator

        this.Pages[page].Push(bg, indicator)
    }

    OnHorzTabClick(obj, idx, *) {
        if (obj.DefaultIdx == idx)
            return
        oldIdx := obj.DefaultIdx
        obj.DefaultIdx := idx

        For i, b in obj.Btns {
            b.Lbl.Opt("c" (i == idx ? this.C_Txt : this.C_SecTxt))
            b.Lbl.Redraw()
        }

        oldPage := obj.SubPages[oldIdx]
        newPage := obj.SubPages[idx]
        this.ActiveSubPages[obj.ParentPage] := newPage

        for ctrl in this.Pages[oldPage]
            ctrl.Opt("Hidden")
        for ctrl in this.Pages[newPage]
            ctrl.Opt("-Hidden")

        targetX := obj.X + (idx-1)*obj.TabW + 16
        obj.Indicator.Move(targetX)

        WinRedraw(this.Gui.Hwnd)
    }

    AddSlider(page, x, y, w, minVal, maxVal, step, defaultVal, text := "", callback := "") {
        yPos := y
        if (text != "") {
            this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
            lbl := this.Gui.Add("Text", "x" x " y" yPos " w" (w-40) " h20 BackgroundTrans", text)
            this.Gui.SetFont("s10 w600 c" this.C_SecTxt, "Segoe UI")
            valLbl := this.Gui.Add("Text", "x" (x+w-40) " y" yPos " w40 h20 Right BackgroundTrans", defaultVal)
            yPos += 24
            this.Pages[page].Push(lbl, valLbl)
        } else {
            valLbl := ""
        }

        trackY := yPos + 6
        track := this.Gui.Add("Text", "x" x " y" trackY " w" w " h6 Background" this.C_Head)

        pct := (defaultVal - minVal) / (maxVal - minVal)
        fillW := Integer(Max(1, w * pct))
        fill := this.Gui.Add("Text", "x" x " y" trackY " w" fillW " h6 Background0078D4")

        thumbX := Integer(x + fillW - 8)
        thumb := this.Gui.Add("Text", "x" thumbX " y" (trackY - 5) " w16 h16 Background0078D4")

        hitbox := this.Gui.Add("Text", "x" x " y" (trackY-10) " w" w " h26 BackgroundTrans")

        obj := { Min: minVal, Max: maxVal, Step: step, Val: defaultVal, X: x, Y: trackY, W: w, Track: track, Fill: fill, Thumb: thumb, ValLbl: valLbl, Cb: callback }

        this.Sliders.Push(obj)

        this.CursorZones[hitbox.Hwnd] := 32649
        this.CursorZones[track.Hwnd] := 32649
        this.CursorZones[fill.Hwnd] := 32649
        this.CursorZones[thumb.Hwnd] := 32649

        this.Pages[page].Push(track, fill, thumb, hitbox)
    }

    SetSliderValue(obj, finalVal) {
        finalVal := Min(Max(obj.Min, finalVal), obj.Max)
        if (finalVal != obj.Val) {
            obj.Val := finalVal
            if obj.ValLbl {
                if InStr(obj.Step, ".") {
                    decimals := StrLen(StrSplit(String(obj.Step), ".")[2])
                    obj.ValLbl.Text := Format("{:0." decimals "f}", finalVal)
                } else {
                    obj.ValLbl.Text := Integer(finalVal)
                }
            }

            pctAdjusted := (finalVal - obj.Min) / (obj.Max - obj.Min)
            fillW := Integer(Max(1, obj.W * pctAdjusted))

            if (!obj.HasOwnProp("LastFillW") || obj.LastFillW != fillW) {
                obj.LastFillW := fillW

                ; Target the old thumb position for background clearing
                obj.Thumb.GetPos(&oX, &oY, &oW, &oH)

                obj.Fill.Move(,, fillW)
                obj.Thumb.Move(Integer(obj.X + fillW - 8))

                ; Invalidate just the area where the thumb used to be to eliminate visual ghosts
                rect := Buffer(16, 0)
                NumPut("Int", oX, "Int", oY, "Int", oX + oW, "Int", oY + oH, rect)
                DllCall("InvalidateRect", "Ptr", this.Gui.Hwnd, "Ptr", rect, "Int", 1)

                obj.Track.Redraw()
                obj.Fill.Redraw()
                obj.Thumb.Redraw()
            }

            if (obj.HasOwnProp("Cb") && obj.Cb) {
                cb := obj.Cb
                cb(finalVal)
            }
        }
    }

    UpdateSliderFromMouse() {
        if (!this.HasOwnProp("ActiveSlider") || !this.ActiveSlider)
            return

        obj := this.ActiveSlider
        DllCall("GetCursorPos", "Ptr", pt := Buffer(8))
        DllCall("ScreenToClient", "Ptr", this.Gui.Hwnd, "Ptr", pt)
        mX := NumGet(pt, 0, "Int")

        relX := Min(Max(0, mX - obj.X), obj.W)
        pct := relX / obj.W

        rawVal := obj.Min + (pct * (obj.Max - obj.Min))
        steps := Round(rawVal / obj.Step)
        finalVal := steps * obj.Step

        this.SetSliderValue(obj, finalVal)
    }

    AddProgressBar(page, x, y, w, pct, text := "") {
        if (text != "") {
            this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
            lbl := this.Gui.Add("Text", "x" x " y" y " w" w " h20 BackgroundTrans", text)
            this.Pages[page].Push(lbl)
            y += 24
        }
        track := this.Gui.Add("Text", "x" x " y" y " w" w " h6 Background" this.C_Panel)
        fillW := w * (pct / 100)
        fill := this.Gui.Add("Text", "x" x " y" y " w" fillW " h6 Background0078D4")

        this.Pages[page].Push(track, fill)
        return {Track: track, Fill: fill, W: w}
    }

    AddRadioGroup(page, x, y, options, defaultIdx, callback := "") {
        obj := {Options: options, ActiveIdx: defaultIdx, Radios: [], Cb: callback}
        yPos := y
        For i, opt in options {
            box := this.Gui.Add("Text", "x" x " y" yPos " w20 h20 Background" this.C_Panel)
            dotColor := (i == defaultIdx) ? "0078D4" : this.C_Panel
            dot := this.Gui.Add("Text", "x" (x+6) " y" (yPos+6) " w8 h8 Background" dotColor)

            this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
            lbl := this.Gui.Add("Text", "x" (x+32) " y" yPos " w200 h20 0x200 BackgroundTrans", opt)

            rad := {Idx: i, Box: box, Dot: dot, Lbl: lbl, Parent: obj}
            clickFn := this.OnRadioClick.Bind(this, rad)
            box.OnEvent("Click", clickFn)
            lbl.OnEvent("Click", clickFn)

            this.CursorZones[box.Hwnd] := 32649
            this.CursorZones[lbl.Hwnd] := 32649
            this.Pages[page].Push(box, dot, lbl)
            obj.Radios.Push(rad)
            yPos += 30
        }
        return obj
    }

    OnRadioClick(rad, *) {
        obj := rad.Parent
        if (obj.ActiveIdx == rad.Idx)
            return

        oldRad := obj.Radios[obj.ActiveIdx]
        oldRad.Dot.Opt("Background" this.C_Panel)
        oldRad.Dot.Redraw()

        obj.ActiveIdx := rad.Idx
        rad.Dot.Opt("Background0078D4")
        rad.Dot.Redraw()

        if (obj.HasOwnProp("Cb") && obj.Cb) {
            cb := obj.Cb
            cb(rad.Idx, obj.Options[rad.Idx])
        }
    }

    AddListView(page, x, y, w, h, cols, rows) {
        lv := this.Gui.Add("ListView", "x" x " y" y " w" w " h" h " -E0x200 Background" this.C_List " c" this.C_Txt " +LV0x10000", cols)

        DllCall("uxtheme\SetWindowTheme", "Ptr", lv.Hwnd, "Str", this.IsDark ? "DarkMode_Explorer" : "Explorer", "Ptr", 0)

        val := Buffer(4, 0)
        NumPut("Int", this.IsDark ? 1 : 0, val)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", lv.Hwnd, "Int", 20, "Ptr", val, "Int", 4)

        for row in rows
            lv.Add("", row*)
        Loop cols.Length
            lv.ModifyCol(A_Index, "AutoHdr")

        this.Pages[page].Push(lv)
    }

    AddCheckbox(page, x, y, text, state) {
        box := this.Gui.Add("Text", "x" x " y" y " w20 h20 Background" (state ? "0078D4" : this.C_Panel))
        try
            this.Gui.SetFont("s11", "Segoe Fluent Icons")
        catch
            this.Gui.SetFont("s11", "Segoe MDL2 Assets")
        chk := this.Gui.Add("Text", "x" x " y" y " w20 h20 Center 0x200 BackgroundTrans cWhite +E0x20", state ? Chr(0xE73E) : "")

        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        lbl := this.Gui.Add("Text", "x" (x+32) " y" y " w300 h20 0x200 BackgroundTrans", text)

        obj := {State: state, Box: box, Chk: chk}
        clickFn := this.OnCheckboxClick.Bind(this, obj)
        box.OnEvent("Click", clickFn), lbl.OnEvent("Click", clickFn)

        this.CursorZones[box.Hwnd] := 32649, this.CursorZones[lbl.Hwnd] := 32649
        this.Pages[page].Push(box, chk, lbl)
    }

    OnCheckboxClick(obj, *) {
        obj.State := !obj.State
        obj.Box.Opt("Background" (obj.State ? "0078D4" : this.C_Panel))
        obj.Chk.Text := obj.State ? Chr(0xE73E) : ""
        obj.Box.Redraw()
    }

    AddToggleButton(page, x, y, w, text, state) {
        h := 36
        bg := state ? "0067C0" : this.C_Panel
        border := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Background" this.C_Panel)
        this.Gui.SetFont("s10 w600 c" this.C_Txt, "Segoe UI")

        btn := this.Gui.Add("Text", "x" (x+1) " y" (y+1) " w" (w-2) " h" (h-2) " Center 0x200 Background" bg " c" (state ? "White" : this.C_Txt) " +E0x20", text)

        obj := {State: state, Border: border, Btn: btn}
        this.Hoverables[border.Hwnd] := {Ctrl: btn, Normal: bg, Hover: (state ? "0078D4" : this.C_Hover), Click: (state ? "004A90" : this.C_Click), Hovered: false, IsToggle: obj}

        border.OnEvent("Click", this.OnToggleButtonClick.Bind(this, obj))
        this.CursorZones[border.Hwnd] := 32649
        this.Pages[page].Push(border, btn)
    }

    OnToggleButtonClick(obj, *) {
        obj.State := !obj.State
        bg := obj.State ? "0067C0" : this.C_Panel
        hoverData := this.Hoverables[obj.Border.Hwnd]
        hoverData.Normal := bg
        hoverData.Hover := obj.State ? "0078D4" : this.C_Hover
        hoverData.Click := obj.State ? "004A90" : this.C_Click
        obj.Btn.Opt("Background" (hoverData.Hovered ? hoverData.Hover : bg) " c" (obj.State ? "White" : this.C_Txt))
        obj.Btn.Redraw()
    }

    AddDropdownButton(page, x, y, w, text, items, callback) {
        h := 36
        border := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Background" this.C_Panel)
        btn := this.Gui.Add("Text", "x" (x+1) " y" (y+1) " w" (w-2) " h" (h-2) " Background" this.C_List)

        this.Gui.SetFont("s10 w600 c" this.C_Txt, "Segoe UI")
        lbl := this.Gui.Add("Text", "x" (x+12) " y" (y+1) " w" (w-40) " h" (h-2) " 0x200 BackgroundTrans c" this.C_Txt " +E0x20", text)

        try
            this.Gui.SetFont("s9", "Segoe Fluent Icons")
        catch
            this.Gui.SetFont("s9", "Segoe MDL2 Assets")
        chev := this.Gui.Add("Text", "x" (x+w-28) " y" (y+1) " w16 h" (h-2) " 0x200 Right BackgroundTrans c" this.C_SecTxt " +E0x20", Chr(0xE70D))

        this.Hoverables[border.Hwnd] := {Ctrl: btn, Normal: this.C_List, Hover: this.C_Hover2, Click: this.C_Click, Hovered: false, Group: [lbl, chev]}

        obj := {Border: border, Inner: btn, Lbl: lbl, Chev: chev, Items: items, Cb: callback, Value: "", Index: 0}

        border.OnEvent("Click", this.OnDropdownBtnClick.Bind(this, obj))
        btn.OnEvent("Click", this.OnDropdownBtnClick.Bind(this, obj))

        this.CursorZones[border.Hwnd] := 32649
        this.CursorZones[btn.Hwnd] := 32649
        this.Pages[page].Push(border, btn, lbl, chev)
    }

    OnDropdownBtnClick(obj, *) {
        if (IsObject(this.ActiveDDL) && this.ActiveDDL == obj) {
            this.ClosePopup()
            return
        }
        this.ClosePopup()
        this.ActiveDDL := obj

        obj.Border.GetPos(&cX, &cY, &cW, &cH)
        pt := Buffer(8, 0)
        NumPut("Int", cX, pt, 0)
        NumPut("Int", cY + cH + 4, pt, 4)
        DllCall("User32.dll\ClientToScreen", "Ptr", this.Gui.Hwnd, "Ptr", pt)
        sX := NumGet(pt, 0, "Int")
        sY := NumGet(pt, 4, "Int")

        this.ShowMenu(obj.Items, sX, sY, cW, obj.Value, this.OnDropdownSelect.Bind(this, obj), obj.Border.Hwnd)
    }

    ; ==========================================
    ; STANDARD FORMS & ROUTING
    ; ==========================================

    AddInput(page, x, y, w, placeholder, isPassword := false) {
        h := 36
        border := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Background" this.C_Panel)
        inner  := this.Gui.Add("Text", "x" (x+1) " y" (y+1) " w" (w-2) " h" (h-2) " Background" this.C_Inner)

        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        edit := this.Gui.Add("Edit", "x" (x+12) " w" (w-24) " -E0x200 Background" this.C_Inner " c" this.C_Txt " " (isPassword ? "Password" : ""))
        edit.GetPos(,, &eW, &eH)
        edit.Move(, y + (h - eH) // 2)

        DllCall("uxtheme\SetWindowTheme", "Ptr", edit.Hwnd, "Str", this.IsDark ? "DarkMode_Explorer" : "Explorer", "Ptr", 0)
        SendMessage(0x1501, 1, StrPtr(placeholder), edit.Hwnd)

        edit.OnEvent("Focus", (*) => (border.Opt("Background0078D4"), border.Redraw()))
        edit.OnEvent("LoseFocus", (*) => (border.Opt("Background" this.C_Panel), border.Redraw()))
        border.OnEvent("Click", (*) => edit.Focus())
        inner.OnEvent("Click", (*) => edit.Focus())

        this.IBeamZones[edit.Hwnd] := 32513
        this.IBeamZones[inner.Hwnd] := 32513
        this.IBeamZones[border.Hwnd] := 32513

        this.Pages[page].Push(border, inner, edit)
        return edit
    }

    AddToggle(page, x, y, text, state, callback := "") {
        w := 42, h := 22
        track := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Background" (state ? "0078D4" : this.C_Panel))
        thumbW := 14
        thumbX := state ? (x + w - thumbW - 4) : (x + 4)
        thumb := this.Gui.Add("Text", "x" thumbX " y" (y + 4) " w" thumbW " h" thumbW " BackgroundFFFFFF +E0x20")

        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        lbl := this.Gui.Add("Text", "x" (x + 56) " y" y " w260 h" h " 0x200 BackgroundTrans", text)

        obj := {State: state, Track: track, Thumb: thumb, X: x, W: w, TW: thumbW, Cb: callback}
        clickFn := this.OnToggleClick.Bind(this, obj)
        track.OnEvent("Click", clickFn)
        lbl.OnEvent("Click", clickFn)

        this.CursorZones[track.Hwnd] := 32649
        this.CursorZones[lbl.Hwnd] := 32649
        this.Pages[page].Push(track, thumb, lbl)
    }

    OnToggleClick(obj, *) {
        obj.State := !obj.State
        obj.Track.Opt("Background" (obj.State ? "0078D4" : this.C_Panel))
        newX := obj.State ? (obj.X + obj.W - obj.TW - 4) : (obj.X + 4)
        obj.Thumb.Move(newX)
        obj.Track.Redraw(), obj.Thumb.Redraw()
        if (obj.HasOwnProp("Cb") && obj.Cb) {
            cb := obj.Cb
            cb(obj.State)
        }
    }

    OnToggleTheme(state) {
        this.IsDark := state
        SetTimer(this.RebuildUI.Bind(this), -10)
    }

    AddButton(page, x, y, w, text, style, callback) {
        h := 36
        isPri := (style = "Primary")
        this.Gui.SetFont("s10 w600 c" (isPri ? "White" : this.C_Txt), "Segoe UI")
        if isPri {
            btn := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Center 0x200 Background0067C0", text)
            this.Hoverables[btn.Hwnd] := {Ctrl: btn, Normal: "0067C0", Hover: "0078D4", Click: "004A90", Hovered: false}
            btn.OnEvent("Click", callback)
            this.CursorZones[btn.Hwnd] := 32649
            this.Pages[page].Push(btn)
        } else {
            border := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Background" this.C_Panel)
            btn := this.Gui.Add("Text", "x" (x+1) " y" (y+1) " w" (w-2) " h" (h-2) " Center 0x200 Background" this.C_Inner " +E0x20", text)
            this.Hoverables[border.Hwnd] := {Ctrl: btn, Normal: this.C_Inner, Hover: this.C_Hover, Click: this.C_Click, Hovered: false}
            border.OnEvent("Click", (*) => callback())
            this.CursorZones[border.Hwnd] := 32649
            this.Pages[page].Push(border, btn)
        }
    }

    AddSidebarTab(y, text, targetPage) {
        bg := this.Gui.Add("Text", "x12 y" y " w154 h36 Background" this.ThemeBg)
        this.Gui.SetFont("s11 w400 c" this.C_SecTxt, "Segoe UI")
        btn := this.Gui.Add("Text", "x12 y" y " w154 h36 0x200 BackgroundTrans +E0x20", "   " text)

        this.Hoverables[bg.Hwnd] := {Ctrl: bg, Normal: this.ThemeBg, Hover: this.C_Hover, Click: this.C_Click, Hovered: false, Target: targetPage, Y: y, Group: [btn]}
        this.SidebarTabs.Push(bg)
        bg.OnEvent("Click", this.OnTabClick.Bind(this, targetPage, y))
        this.CursorZones[bg.Hwnd] := 32649
    }

    OnTabClick(targetPage, tabY, *) {
        if (this.ActiveTab == targetPage)
            return
        this.Indicator.Move(, tabY + 6)
        this.SwitchTab(targetPage)
    }

    SwitchTab(targetPage) {
        this.ClosePopup()
        SendMessage(0x000B, 0, 0, this.Gui.Hwnd)

        for bg in this.SidebarTabs {
            data := this.Hoverables[bg.Hwnd]
            isActive := (data.Target == targetPage)

            data.Group[1].Opt("c" (isActive ? this.C_Txt : this.C_SecTxt))

            data.Normal := isActive ? this.C_Hover2 : this.ThemeBg
            data.Hover := isActive ? (this.IsDark ? "353535" : "D0D0D0") : this.C_Hover
            this.SetHoverColor(data, data.Hovered ? data.Hover : data.Normal)
        }

        pagesToShow := Map(targetPage, true)
        if this.ActiveSubPages.Has(targetPage)
            pagesToShow[this.ActiveSubPages[targetPage]] := true

        for pageName, ctrls in this.Pages {
            isVisible := pagesToShow.Has(pageName)
            for ctrl in ctrls
                ctrl.Opt(isVisible ? "-Hidden" : "Hidden")
        }
        this.ActiveTab := targetPage
        SendMessage(0x000B, 1, 0, this.Gui.Hwnd)
        WinRedraw(this.Gui.Hwnd)
        try ControlFocus(this.Dummy)
    }

    ; ==========================================
    ; UNIVERSAL POPUP MENU ENGINE (Context & Dropdowns)
    ; ==========================================

    AddDropdown(page, x, y, w, items, defaultIdx, callback) {
        h := 36
        border := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Background" this.C_Panel)
        inner  := this.Gui.Add("Text", "x" (x+1) " y" (y+1) " w" (w-2) " h" (h-2) " Background" this.C_List)

        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        lbl := this.Gui.Add("Text", "x" (x+12) " y" (y+1) " w" (w-40) " h" (h-2) " 0x200 BackgroundTrans c" this.C_Txt " +E0x20", items[defaultIdx])

        try
            this.Gui.SetFont("s9", "Segoe Fluent Icons")
        catch
            this.Gui.SetFont("s9", "Segoe MDL2 Assets")
        chev := this.Gui.Add("Text", "x" (x+w-28) " y" (y+1) " w16 h" (h-2) " 0x200 Right BackgroundTrans c" this.C_SecTxt " +E0x20", Chr(0xE70D))

        obj := { Items: items, Index: defaultIdx, Value: items[defaultIdx], Lbl: lbl, Chev: chev, Border: border, Inner: inner, X: x, Y: y, W: w, H: h, Cb: callback }

        clickFn := this.OnDropdownClick.Bind(this, obj)
        inner.OnEvent("Click", clickFn)
        border.OnEvent("Click", (*) => clickFn())

        this.Hoverables[inner.Hwnd] := { Ctrl: inner, Normal: this.C_List, Hover: this.C_Hover2, Click: this.C_Click, Hovered: false, Group: [lbl, chev] }
        this.Hoverables[border.Hwnd] := this.Hoverables[inner.Hwnd]
        this.CursorZones[inner.Hwnd] := 32649
        this.CursorZones[border.Hwnd] := 32649

        this.Pages[page].Push(border, inner, lbl, chev)
        return obj
    }

    OnDropdownClick(obj, *) {
        if (IsObject(this.ActiveDDL) && this.ActiveDDL == obj) {
            this.ClosePopup()
            return
        }
        this.ClosePopup()

        this.ActiveDDL := obj
        obj.Border.Opt("Background0078D4")
        obj.Chev.Text := Chr(0xE70E)
        obj.Border.Redraw()
        obj.Chev.Redraw()

        obj.Border.GetPos(&cX, &cY, &cW, &cH)
        pt := Buffer(8, 0)
        NumPut("Int", cX, pt, 0)
        NumPut("Int", cY + cH + 4, pt, 4)
        DllCall("User32.dll\ClientToScreen", "Ptr", this.Gui.Hwnd, "Ptr", pt)
        sX := NumGet(pt, 0, "Int")
        sY := NumGet(pt, 4, "Int")

        this.ShowMenu(obj.Items, sX, sY, cW, obj.Value, this.OnDropdownSelect.Bind(this, obj), obj.Border.Hwnd)
    }

    OnDropdownSelect(obj, index, itemText) {
        if obj.HasOwnProp("Index")
            obj.Index := index
        obj.Value := itemText
        obj.Lbl.Text := itemText
        obj.Lbl.Redraw()

        if (obj.HasOwnProp("Cb") && obj.Cb) {
            cb := obj.Cb
            cb(itemText)
        }
    }

    OnRButtonUp(wParam, lParam, msg, hwnd) {
        this.OnContextMenu(this.Gui, "", 0, true, lParam & 0xFFFF, lParam >> 16)
    }

    OnContextMenu(guiObj, ctrlObj, eventInfo, isRightClick, x, y) {
        if (!isRightClick)
            return

        if (ctrlObj && ctrlObj.Type == "Edit")
            return

        m := Menu()
        m.Add("Refresh UI Framework", (*) => MsgBox("Refreshed!"))
        m.Add("Open Source Folder", (*) => Run(A_ScriptDir))
        m.Add()
        m.Add("Exit System", (*) => ExitApp())
        m.Show()
    }

    ShowMenu(items, x, y, w, selectedValue, callback, targetHwnd := 0) {
        this.ClosePopup()
        this.Pop := Gui("-Caption +ToolWindow +AlwaysOnTop +Owner" this.Gui.Hwnd)
        this.Pop.BackColor := this.ThemeBg

        val := Buffer(4, 0)
        NumPut("Int", 1, val)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Pop.Hwnd, "Int", 20, "Ptr", val, "Int", 4)
        this.EnableBackdrop(this.Pop.Hwnd, this.CurrentBackdropType)

        pad := 4
        itemH := 34
        maxVis := Min(items.Length, 8)
        popH := (pad * 2) + (maxVis * itemH) + 2

        if (y + popH > A_ScreenHeight - 40 && targetHwnd) {
            ControlGetPos(, , , &th, targetHwnd)
            y := y - popH - th - 8
        }

        ; Force GUI geometry calculation to ensure valid rects before clipping
        this.Pop.Show("x" x " y" y " w" w " h" popH " Hide")

        this.Pop.Add("Text", "x0 y0 w" w " h1 Background" this.C_Panel)
        this.Pop.Add("Text", "x0 y" (popH-1) " w" w " h1 Background" this.C_Panel)
        this.Pop.Add("Text", "x0 y0 w1 h" popH " Background" this.C_Panel)
        this.Pop.Add("Text", "x" (w-1) " y0 w1 h" popH " Background" this.C_Panel)

        this.PopHitZones := Map()
        this.PopItems := []
        this.PopScrollY := 0
        this.PopMaxScroll := Max(0, items.Length - maxVis)
        this.PopHoverIdx := this.ActiveDDL.HasOwnProp("Index") ? this.ActiveDDL.Index : 1

        txtW := (this.PopMaxScroll > 0) ? (w - 14) : (w - 10)

        For i, item in items {
            yPos := pad + 1 + (i-1) * itemH
            isActive := (i == this.PopHoverIdx)
            bgColor := isActive ? "Background" this.C_Hover : "BackgroundTrans"
            txtColor := isActive ? "c0078D4" : "c" this.C_Txt
            fWeight := isActive ? "w600" : "w400"

            this.Pop.SetFont("s10 " fWeight, "Segoe UI")
            itemCtrl := this.Pop.Add("Text", "x4 y" yPos " w" txtW " h" itemH " 0x200 " bgColor " " txtColor, "   " item)

            pItem := {Ctrl: itemCtrl, Y: yPos}

            pill := this.Pop.Add("Text", "x4 y" (yPos+10) " w3 h14 Background0078D4 " (isActive ? "" : "Hidden"))
            pItem.Pill := pill

            this.PopItems.Push(pItem)

            clickCb := this.OnMenuSelect.Bind(this, i, item, callback)
            itemCtrl.OnEvent("Click", clickCb)

            this.PopHitZones[itemCtrl.Hwnd] := i
            this.CursorZones[itemCtrl.Hwnd] := 32649
        }

        if (this.PopMaxScroll > 0) {
            this.PopContH := maxVis * itemH
            this.PopScrollTrack := this.Pop.Add("Text", "x" (w - 6) " y" (pad+1) " w2 h" this.PopContH " Background" this.C_Head)
            sbH := Max(16, this.PopContH * (maxVis / items.Length))
            this.PopScrollBar := this.Pop.Add("Text", "x" (w - 6) " y" (pad+1) " w2 h" sbH " Background" this.C_SecTxt)
            this.PopSBHeight := sbH
        }

        this.Pop.Show("NoActivate")
        this.EnsurePopVisible(this.PopHoverIdx)
    }

    OnMenuSelect(index, item, callback, *) {
        this.ClosePopup()
        if (callback)
            callback(index, item)
    }

    ClosePopup() {
        if (this.HasOwnProp("Pop") && this.Pop) {
            for hwnd in this.PopHitZones
                this.CursorZones.Delete(hwnd)
            this.PopHitZones := Map()
            this.PopItems := []
            this.PopHoverIdx := 0

            this.Pop.Destroy()
            this.Pop := ""

            if (IsObject(this.ActiveDDL)) {
                this.ActiveDDL.Border.Opt("Background" this.C_Panel)
                if this.ActiveDDL.HasOwnProp("Chev")
                    this.ActiveDDL.Chev.Text := Chr(0xE70D)
                this.ActiveDDL.Border.Redraw()
                if this.ActiveDDL.HasOwnProp("Chev")
                    this.ActiveDDL.Chev.Redraw()
                this.ActiveDDL := ""
            }
        }
    }

    OnChangeBackdrop(val) {
        this.CurrentBackdropType := (val == "Acrylic (Frosted)") ? 3 : (val == "Mica Alt (Tinted)") ? 4 : 2
        this.EnableBackdrop(this.Gui.Hwnd, this.CurrentBackdropType)
    }

    ; ==========================================
    ; WIN32 INTERACTIVE HOVER & KEYBOARD PHYSICS
    ; ==========================================

    OnWM_KEYDOWN(wParam, lParam, msg, hwnd) {
        if (this.HasOwnProp("FocusedSlider") && this.FocusedSlider) {
            if (wParam == 37 || wParam == 39) { ; Left / Right
                dir := (wParam == 37) ? -1 : 1
                this.SetSliderValue(this.FocusedSlider, this.FocusedSlider.Val + (dir * this.FocusedSlider.Step))
                return 0
            }
        }

        if (!this.HasOwnProp("Pop") || !this.Pop)
            return

        if (wParam == 27) { ; ESC
            this.ClosePopup()
            return 0
        }

        if (wParam == 32 || wParam == 13) { ; Space / Enter
            if (IsObject(this.ActiveDDL) && this.PopHoverIdx > 0)
                this.OnDropdownSelect(this.ActiveDDL, this.PopHoverIdx, this.ActiveDDL.Items[this.PopHoverIdx])
            return 0
        }

        if (wParam == 38 || wParam == 40) { ; Up / Down
            dir := (wParam == 38) ? -1 : 1
            newIdx := Max(1, Min(this.ActiveDDL.Items.Length, this.PopHoverIdx + dir))
            this.UpdatePopHighlight(newIdx)
            this.EnsurePopVisible(newIdx)
            return 0
        }
    }

    UpdatePopHighlight(newIdx) {
        if (newIdx == this.PopHoverIdx)
            return

        activeIdx := this.ActiveDDL.HasOwnProp("Index") ? this.ActiveDDL.Index : 0

        if (this.PopHoverIdx > 0 && this.PopHoverIdx <= this.PopItems.Length) {
            oldItem := this.PopItems[this.PopHoverIdx]
            oldBg := (this.PopHoverIdx == activeIdx) ? "Background" this.C_Hover2 : "BackgroundTrans"
            oldColor := (this.PopHoverIdx == activeIdx) ? "c0078D4" : "c" this.C_Txt
            oldItem.Ctrl.Opt(oldBg " " oldColor " w400")
            oldItem.Ctrl.Redraw()
        }

        this.PopHoverIdx := newIdx

        if (newIdx > 0 && newIdx <= this.PopItems.Length) {
            newItem := this.PopItems[newIdx]
            newColor := (newIdx == activeIdx) ? "c0078D4" : "c" this.C_Txt
            newItem.Ctrl.Opt("Background" this.C_Hover " " newColor " w600")
            newItem.Ctrl.Redraw()
        }
    }

    EnsurePopVisible(idx) {
        if (!this.HasOwnProp("PopMaxScroll") || this.PopMaxScroll <= 0)
            return

        itemH := 34
        itemTop := (idx - 1) * itemH
        itemBottom := itemTop + itemH

        viewTop := this.PopScrollY * itemH
        viewBottom := viewTop + (8 * itemH)

        if (itemTop < viewTop) {
            this.ScrollPopup((itemTop - viewTop) // itemH)
        } else if (itemBottom > viewBottom) {
            this.ScrollPopup((itemBottom - viewBottom) // itemH)
        }
    }

    ScrollPopup(amount) {
        if (!this.HasOwnProp("Pop") || !this.Pop || this.PopMaxScroll <= 0)
            return

        prev := this.PopScrollY
        this.PopScrollY := Max(0, Min(this.PopScrollY + amount, this.PopMaxScroll))

        if (prev != this.PopScrollY) {
            itemH := 34
            for i, pItem in this.PopItems {
                newY := 5 + ((i-1) * itemH) - (this.PopScrollY * itemH)
                pItem.Ctrl.Move(, newY)
                if pItem.HasOwnProp("Pill")
                    pItem.Pill.Move(, newY + 10)
            }
            if (this.HasOwnProp("PopScrollBar") && this.PopScrollBar) {
                avail := this.PopContH - this.PopSBHeight
                this.PopScrollBar.Move(, 5 + (avail * (this.PopScrollY / this.PopMaxScroll)))
            }
        }
    }

    SetHoverColor(ctrlData, color) {
        ctrlData.Ctrl.Opt("Background" color)
        ctrlData.Ctrl.Redraw()
        if ctrlData.HasOwnProp("Group") {
            for child in ctrlData.Group
                child.Redraw()
        }
    }

    OnMouseMove(wParam, lParam, msg, hwnd) {
        if (this.HasOwnProp("ActiveSlider") && this.ActiveSlider) {
            this.UpdateSliderFromMouse()
            return
        }

        if (this.HasOwnProp("PopHitZones") && this.PopHitZones.Has(hwnd)) {
            this.UpdatePopHighlight(this.PopHitZones[hwnd])
            return
        }

        map := this.Hoverables.Has(hwnd) ? this.Hoverables : ""
        if map {
            ctrlData := map[hwnd]
            if (!ctrlData.Hovered) {
                ctrlData.Hovered := true
                this.SetHoverColor(ctrlData, (this.ActiveClick == hwnd) ? ctrlData.Click : ctrlData.Hover)

                TME := Buffer(A_PtrSize == 8 ? 24 : 16, 0)
                NumPut("UInt", TME.Size, "UInt", 2, "Ptr", hwnd, "UInt", 0, TME)
                DllCall("User32\TrackMouseEvent", "Ptr", TME)
            }
        }
    }

    OnMouseLeave(wParam, lParam, msg, hwnd) {
        map := this.Hoverables.Has(hwnd) ? this.Hoverables : ""
        if map {
            ctrlData := map[hwnd]
            ctrlData.Hovered := false
            this.SetHoverColor(ctrlData, ctrlData.Normal)
        }
    }

    OnLButtonDown(wParam, lParam, msg, hwnd) {
        ; Retrieve explicit coordinates mapping to bypass transparent background fall-through bugs
        DllCall("GetCursorPos", "Ptr", pt := Buffer(8))
        DllCall("ScreenToClient", "Ptr", this.Gui.Hwnd, "Ptr", pt)
        mX := NumGet(pt, 0, "Int")
        mY := NumGet(pt, 4, "Int")

        for _, obj in this.Sliders {
            if (mX >= obj.X && mX <= (obj.X + obj.W) && mY >= (obj.Y - 10) && mY <= (obj.Y + 16)) {
                this.ActiveSlider := obj
                this.FocusedSlider := obj
                DllCall("SetCapture", "Ptr", this.Gui.Hwnd)
                this.UpdateSliderFromMouse()
                return
            }
        }

        this.FocusedSlider := ""

        if (this.HasOwnProp("Pop") && this.Pop) {
            isDropdownElement := false
            curr := hwnd
            hasChev := IsObject(this.ActiveDDL) && this.ActiveDDL.HasOwnProp("Chev")

            while (curr) {
                if (curr == this.Pop.Hwnd)
                    isDropdownElement := true
                if (IsObject(this.ActiveDDL) && (curr == this.ActiveDDL.Inner.Hwnd || curr == this.ActiveDDL.Border.Hwnd || curr == this.ActiveDDL.Lbl.Hwnd || (hasChev && curr == this.ActiveDDL.Chev.Hwnd)))
                    isDropdownElement := true
                try curr := DllCall("GetParent", "Ptr", curr, "Ptr")
                catch
                    break
            }
            if (!isDropdownElement)
                this.ClosePopup()
        }

        map := this.Hoverables.Has(hwnd) ? this.Hoverables : ""
        if map {
            this.ActiveClick := hwnd
            this.SetHoverColor(map[hwnd], map[hwnd].Click)
        } else if (hwnd == this.Gui.Hwnd) {
            try ControlFocus(this.Dummy)
        }
    }

    OnLButtonUp(wParam, lParam, msg, hwnd) {
        if (this.HasOwnProp("ActiveSlider") && this.ActiveSlider) {
            this.ActiveSlider := ""
            DllCall("ReleaseCapture")
        }

        if (this.ActiveClick) {
            map := this.Hoverables.Has(this.ActiveClick) ? this.Hoverables : ""
            if map
                this.SetHoverColor(map[this.ActiveClick], map[this.ActiveClick].Hovered ? map[this.ActiveClick].Hover : map[this.ActiveClick].Normal)
            this.ActiveClick := 0
        }
    }

    OnMouseWheel(wParam, lParam, msg, hwnd) {
        if (this.HasOwnProp("Pop") && this.Pop && this.PopMaxScroll > 0) {
            delta := (wParam >> 16) & 0xFFFF
            if (delta > 0x7FFF)
                delta -= 0x10000

            dir := (delta > 0) ? -1 : 1
            this.ScrollPopup(dir)
            return 0
        }
    }

    OnWM_ACTIVATE(wParam, lParam, msg, hwnd) {
        if (hwnd == this.Gui.Hwnd && (wParam & 0xFFFF) == 0) {
            if (this.HasOwnProp("Pop") && this.Pop)
                SetTimer(this.ClosePopup.Bind(this), -10)
        }
    }

    OnSetCursor(wParam, lParam, msg, hwnd) {
        if this.IBeamZones.Has(wParam) {
            DllCall("User32\SetCursor", "Ptr", DllCall("User32\LoadCursor", "Ptr", 0, "Int", 32513, "Ptr"))
            return 1
        }
        if this.Hoverables.Has(wParam) || this.CursorZones.Has(wParam) {
            DllCall("User32\SetCursor", "Ptr", DllCall("User32\LoadCursor", "Ptr", 0, "Int", 32649, "Ptr"))
            return 1
        }
    }

    ; ==========================================
    ; COMPOSITOR & HARDWARE DPI CLIPPING
    ; ==========================================

    EnableBackdrop(hwnd, type := 3) {
        val := Buffer(4, 0)
        NumPut("Int", 1, val)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", 20, "Ptr", val, "Int", 4)

        if (VerCompare(A_OSVersion, "10.0.22000") >= 0) {
            NumPut("Int", type, val)
            if (DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", 38, "Ptr", val, "Int", 4) != 0) {
                NumPut("Int", (type==2 ? 1 : 0), val)
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", 1029, "Ptr", val, "Int", 4)
            }

            NumPut("Int", 2, val)
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", 33, "Ptr", val, "Int", 4)

            margins := Buffer(16, 0)
            NumPut("Int", -1, "Int", -1, "Int", -1, "Int", -1, margins)
            DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", hwnd, "Ptr", margins)
        }
    }
}

; App := FluentApp()