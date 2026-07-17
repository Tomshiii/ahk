/************************************************************************
 * @author tomshi
 * @date 2026/06/12
 * @version 3.0.0
 ***********************************************************************/
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Settings.ahk
#Include GUIs\tomshiBasic.ahk
#Include GUIs\gameCheckGUI.ahk
#Include GUIs\settingsGUI\editValues.ahk
#Include Other\FluentApp.ahk
#Include Classes\dark.ahk
#Include Classes\tool.ahk
#Include Classes\ptf.ahk
#Include Classes\obj.ahk
#Include Classes\WM.ahk
#Include Classes\reset.ahk
#Include Classes\winget.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk
#Include Other\Notify\Notify.ahk
#Include Other\Array.ahk
#Include Functions\refreshWin.ahk
#Include Functions\detect.ahk
#Include Functions\checkInternet.ahk
#Include Functions\generateAdobeShortcut.ahk
;}

settingsGUI()
/**
 * A GUI window to allow the user to toggle settings contained within the `settings.ini` file.
 * Rendered with Fluent / Mica theming via SettingsApp (extends FluentApp).
 */
settingsGUI()
{
    detect()
    if Notify.Exist('settingsGUI') {
        loop 80 {
            if !Notify.Exist('settingsGUI')
                break
            sleep 25
        }
    }

    readSet      := FileRead(ptf.lib "\GUIs\settingsGUI\values.json")
    setJSON      := JSON.parse(readSet,, false)
    UserSettings := CLSID_Objs.load("UserSettings")

    try {
        winProcc := WinGetProcessName("A")
        winTitle := WinGet.Title()
    } catch {
        winProcc := ""
        winTitle := ""
    }

    version := UserSettings.version

    if WinExist("Settings " version)
        return

    SettingsApp(UserSettings, setJSON, version, winTitle, winProcc)
}

class SettingsApp extends FluentApp {
    ; ── Constructor ─────────────────────────────────────────────────────────
    __New(UserSettings, setJSON, version, winTitle, winProcc) {
        SettingsApp.Instance := this
        this.UserSettings    := UserSettings
        this.setJSON         := setJSON
        this.version         := version
        this.winTitle        := winTitle
        this.process         := winProcc
        ;// runtime refs populated on every (re)build
        this.NumRefs         := Map()          ;// ctrl-name → {Edit, UpDown}
        this.BetaToggle      := {State: false} ;// placeholder until BuildUpdatesPage runs
        this.AdobeCtrls      := Map()          ;// "AE"/"Premiere" → {YearDDL, VerDDL, BetaToggle, CacheEdit, ...}
        this.ThioCtrls       := ""             ;// {ThioToggle, MToggle, HotkeyEdit}
        this.AddGameCtrls    := ""             ;// {TitleEdit, ProcessEdit}
        ;// theme seed — FluentApp.__New reads this.IsDark before building
        this.IsDark          := true
        this.ActiveTab       := "General"
        this.ActiveSubPages  := Map()

        this.row1 := 200
        this.row2 := 540
        super.__New()
    }

    RebuildUI() {
        ;// FluentApp.__New() overwrites this.IsDark := true and this.ActiveTab := "Forms && Data"
        ;// before calling RebuildUI, so we re-anchor both from our own state here.
        this.IsDark := true

        if this.HasOwnProp("Gui") && this.Gui
            try this.Gui.Destroy()

        ;// Reset shared FluentApp state
        this.Pages         := Map()
        this.Hoverables    := Map()
        this.CursorZones   := Map()
        this.IBeamZones    := Map()
        this.SidebarTabs   := []
        this.Sliders       := []
        this.ActiveSlider  := ""
        this.FocusedSlider := ""
        this.ActiveClick   := 0
        this.ActiveDDL     := ""
        this.Pop           := ""
        ;// reset per-build refs
        this.NumRefs       := Map()
        this.BetaToggle    := {State: false}
        this.AdobeCtrls    := Map()
        this.ThioCtrls     := ""
        this.AddGameCtrls  := ""
        this.ScrollState   := Map()
        this.DetailPageOpen := false
        this.ActiveScrollDrag := ""

        ;// ── Colour palette ────────────────────────────────────────────────
        this.ThemeBg  := 000000
        this.C_Txt    := "White"
        this.C_SecTxt := "A0A0A0"
        this.C_Panel  := "333333"
        this.C_Inner  := "141414"
        this.C_Head   := "2A2A2A"
        this.C_List   := "1C1C1C"
        this.C_Hover  := "1A1A1A"
        this.C_Hover2 := "2A2A2A"
        this.C_Click  := "101010"

        ;// ── Create GUI ────────────────────────────────────────────────────
        this.Gui := Gui("-Resize", "Settings " this.version)
        this.Gui.OnEvent("Close",  (*) => this.OnClose())
        this.Gui.OnEvent("Escape", (*) => this.OnClose())
        this.Gui.BackColor := this.ThemeBg

        val := Buffer(4, 0)
        NumPut("Int", this.IsDark ? 1 : 0, val)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Gui.Hwnd, "Int", 20, "Ptr", val, "Int", 4)
        this.EnableBackdrop(this.Gui.Hwnd, 2)

        this.BuildUI()

        this.Gui.Show("Center w960 h640")
        ;// FluentApp.__New() always writes this.ActiveTab := "Forms && Data" after our
        ;// __New() runs but before RebuildUI() is called.  Guard against that here so
        ;// the first paint isn't blank because SwitchTab() finds no matching page.
        if !this.Pages.Has(this.ActiveTab)
            this.ActiveTab := "General"
        this.SwitchTab(this.ActiveTab)
    }

    ; ── AddToggle override ──────────────────────────────────────────────────
    ;// Identical to FluentApp's version but returns obj so callers can hold a ref.
    AddToggle(page, x, y, text, state, callback := "") {
        w := 42, h := 22
        track := this.Gui.Add("Text", "x" x " y" y " w" w " h" h " Background" (state ? "0078D4" : this.C_Panel))
        thumbW := 14
        thumb  := this.Gui.Add("Text",
            "x" (state ? x + w - thumbW - 4 : x + 4) " y" (y + 4) " w" thumbW " h" thumbW " BackgroundFFFFFF +E0x20")
        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        lbl := this.Gui.Add("Text", "x" (x + 56) " y" y " w260 h" h " 0x200 BackgroundTrans", text)
        obj := {State: state, Track: track, Thumb: thumb, X: x, W: w, TW: thumbW, Cb: callback}
        clickFn := this.OnToggleClick.Bind(this, obj)
        track.OnEvent("Click", clickFn)
        lbl.OnEvent("Click",   clickFn)
        this.CursorZones[track.Hwnd] := 32649
        this.CursorZones[lbl.Hwnd]   := 32649
        this.Pages[page].Push(track, thumb, lbl)
        return obj
    }

    ;// Programmatically flip a toggle's visual state without firing its callback
    SetToggleState(obj, newState) {
        if obj.State = newState
            return
        obj.State := newState
        obj.Track.Opt("Background" (obj.State ? "0078D4" : this.C_Panel))
        obj.Thumb.Move(obj.State ? (obj.X + obj.W - obj.TW - 4) : (obj.X + 4))
        obj.Track.Redraw()
        obj.Thumb.Redraw()
    }

    ;// Suppress the inherited "Refresh UI Framework" right-click menu
    OnContextMenu(guiObj, ctrlObj, eventInfo, isRightClick, x, y) {
        if (!isRightClick || (ctrlObj && ctrlObj.Type == "Edit"))
            return
    }

    ;// AddSlider override ────────────────────────────────────────────────────
    ;// Identical to FluentApp's version but returns obj — the base class builds it
    ;// then never hands it back, so callers have no way to reference the slider
    ;// afterwards (needed here for OnSliderChange's value readout + SetSliderEnabled).
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
        return obj
    }

    NavigateTo(fromPage, toPage) {
        this.ClosePopup()
        for ctrl in this.Pages[fromPage]
            ctrl.Opt("Hidden")
        for ctrl in this.Pages[toPage]
            ctrl.Opt("-Hidden")
        ;// track whether we're inside a "detail" page (Thio/AE/Premiere/AddGame) —
        ;// those aren't scrollable, so wheel events shouldn't try to scroll whatever
        ;// main tab is still nominally this.ActiveTab underneath them
        this.DetailPageOpen := !this.IsTopLevelPage(toPage)
        this.ReclipScroll(toPage)
        WinRedraw(this.Gui.Hwnd)
        try ControlFocus(this.Dummy)
    }

    IsTopLevelPage(page) => ["General", "Scripts", "Editors"].IndexOf(page) > 0

    ;// Wraps the inherited SwitchTab to (1) mark that we've left any detail page, and
    ;// (2) re-apply scroll clipping — SwitchTab's generic show/hide would otherwise
    ;// un-hide controls that were scrolled out of view before the tab was last left.
    SwitchTab(targetPage) {
        this.DetailPageOpen := false
        super.SwitchTab(targetPage)
        this.ReclipScroll(targetPage)
    }

    ;// Routes wheel events to page-scroll when appropriate, otherwise defers to the
    ;// inherited behaviour (popup-menu scrolling).
    OnMouseWheel(wParam, lParam, msg, hwnd) {
        if (this.HasOwnProp("Pop") && this.Pop && this.PopMaxScroll > 0)
            return super.OnMouseWheel(wParam, lParam, msg, hwnd)

        if !this.DetailPageOpen && this.HasOwnProp("ScrollState") && this.ScrollState.Has(this.ActiveTab) {
            delta := (wParam >> 16) & 0xFFFF
            if (delta > 0x7FFF)
                delta -= 0x10000
            dir := (delta > 0) ? -1 : 1
            this.ScrollPage(this.ActiveTab, dir)
            return 0
        }
    }

    ;// Click-drag on the scrollbar track/thumb. Checked first; falls through to the
    ;// inherited handler (sliders, toggles, dropdown popups, hover clicks, etc.) when
    ;// the click wasn't on an active scrollbar.
    OnLButtonDown(wParam, lParam, msg, hwnd) {
        if !this.DetailPageOpen && this.HasOwnProp("ScrollState") && this.ScrollState.Has(this.ActiveTab) {
            state := this.ScrollState[this.ActiveTab]
            if state.HasOwnProp("Thumb") && state.MaxScroll > 0 {
                DllCall("GetCursorPos", "Ptr", pt := Buffer(8))
                DllCall("ScreenToClient", "Ptr", this.Gui.Hwnd, "Ptr", pt)
                mX := NumGet(pt, 0, "Int"), mY := NumGet(pt, 4, "Int")
                state.Track.GetPos(&tX, &tY, &tW, &tH)
                if (mX >= tX - 6 && mX <= tX + tW + 6 && mY >= state.ViewTop && mY <= state.ViewBottom) {
                    state.Thumb.GetPos(,&thY,, &thH)
                    this.ActiveScrollDrag := {Page: this.ActiveTab, State: state, GrabOffset: mY - thY}
                    DllCall("SetCapture", "Ptr", this.Gui.Hwnd)
                    this.UpdateScrollDragFromMouse()
                    return
                }
            }
        }
        super.OnLButtonDown(wParam, lParam, msg, hwnd)
    }

    OnMouseMove(wParam, lParam, msg, hwnd) {
        if this.ActiveScrollDrag {
            this.UpdateScrollDragFromMouse()
            return
        }
        super.OnMouseMove(wParam, lParam, msg, hwnd)
    }

    OnLButtonUp(wParam, lParam, msg, hwnd) {
        if this.ActiveScrollDrag {
            this.ActiveScrollDrag := ""
            DllCall("ReleaseCapture")
            return
        }
        super.OnLButtonUp(wParam, lParam, msg, hwnd)
    }

    UpdateScrollDragFromMouse() {
        drag  := this.ActiveScrollDrag
        state := drag.State

        avail := (state.ViewBottom - state.ViewTop) - state.ThumbH
        if avail <= 0
            return

        DllCall("GetCursorPos", "Ptr", pt := Buffer(8))
        DllCall("ScreenToClient", "Ptr", this.Gui.Hwnd, "Ptr", pt)
        mY := NumGet(pt, 4, "Int")

        thumbY := Min(Max(state.ViewTop, mY - drag.GrabOffset), state.ViewTop + avail)
        pct := (thumbY - state.ViewTop) / avail
        newScrollY := Round(pct * state.MaxScroll)

        if newScrollY != state.ScrollY {
            state.ScrollY := newScrollY
            this.ReclipScroll(drag.Page)
        }
        state.Thumb.Move(, thumbY)
    }

    ; ════════════════════════════════════════════════════════════════════════
    ;!  VIRTUAL SCROLLING (single-window; see explanation in chat re: native
    ;!  ScrollableGui vs. this custom-drawn slider system)
    ; ════════════════════════════════════════════════════════════════════════

    ;// Captures the Y-position/height of every control pushed to this.Pages[page] from
    ;// index `fromIdx` (1-based) to the end of the array at call time, and sets up
    ;// vertical-scroll clipping for that range within [viewTop, viewBottom]. Also finds
    ;// any Fluent sliders among them so their cached hit-test Y can be kept in sync.
    ;// Call this once, after all of a page's scrollable content has been added.
    MakeScrollable(page, fromIdx, viewTop, viewBottom) {
        ctrls := this.Pages[page]
        entries := []
        maxBottom := viewTop
        loop ctrls.Length - fromIdx + 1 {
            idx := fromIdx + A_Index - 1
            ctrl := ctrls[idx]
            ctrl.GetPos(&cx, &cy, &cw, &ch)
            entries.Push({Ctrl: ctrl, BaseX: cx, BaseY: cy, W: cw, H: ch})
            if (cy + ch > maxBottom)
                maxBottom := cy + ch
        }

        ;// sliders need their obj.Y kept in sync separately — that's the field
        ;// OnLButtonDown/UpdateSliderFromMouse hit-test against, and it's cached on
        ;// the slider obj itself rather than re-read from the control each time.
        sliderRefs := []
        for obj in this.Sliders {
            if (obj.Y >= viewTop - 40 && obj.Y <= maxBottom + 40)
                sliderRefs.Push({Obj: obj, BaseY: obj.Y})
        }

        viewH     := viewBottom - viewTop
        contentH  := maxBottom - viewTop
        maxScroll := Max(0, contentH - viewH)

        state := {Entries: entries, SliderRefs: sliderRefs, ViewTop: viewTop, ViewBottom: viewBottom,
            MaxScroll: maxScroll, ScrollY: 0}

        if maxScroll > 0 {
            trackX := this.row2 + 340
            track := this.Gui.Add("Text", "x" trackX " y" viewTop " w4 h" viewH " Background" this.C_Head)
            thumbH := Max(24, viewH * (viewH / contentH))
            thumb := this.Gui.Add("Text", "x" trackX " y" viewTop " w4 h" thumbH " Background0078D4")
            state.Track  := track
            state.Thumb  := thumb
            state.ThumbH := thumbH
            this.Pages[page].Push(track, thumb)
        }

        if !this.HasOwnProp("ScrollState")
            this.ScrollState := Map()
        this.ScrollState[page] := state
    }

    ;// Scrolls `page` by `dir` (-1/+1) one step, re-clips its controls, and moves the thumb.
    ScrollPage(page, dir) {
        state := this.ScrollState[page]
        if state.MaxScroll <= 0
            return
        step := 40
        newY := Max(0, Min(state.MaxScroll, state.ScrollY + dir * step))
        if newY = state.ScrollY
            return
        state.ScrollY := newY
        this.ReclipScroll(page)
        if state.HasOwnProp("Thumb") {
            avail := (state.ViewBottom - state.ViewTop) - state.ThumbH
            state.Thumb.Move(, state.ViewTop + (avail * (state.ScrollY / state.MaxScroll)))
        }
    }

    ;// Re-applies the current scroll offset to `page`'s tracked controls. Uses
    ;// BeginDeferWindowPos/EndDeferWindowPos to move+show/hide everything in one
    ;// atomic batch (this combination — no per-pixel SetWindowRgn clipping, no raw
    ;// InvalidateRect — is the version that measured flicker-free; both attempts at
    ;// adding real clipping introduced new glitches I couldn't diagnose without
    ;// running this, so I'm not re-attempting it here). A control is only hidden
    ;// once it's entirely outside [ViewTop, ViewBottom]; BuildScriptsPage keeps the
    ;// fixed header topmost in z-order (BringToFront) so it can't be painted over.
    ;// Controls that just transitioned hidden→visible get an explicit .Redraw() —
    ;// AHK's own control method, the same one already used for sliders/toggles
    ;// elsewhere in this file — since DeferWindowPos's SHOWWINDOW flag alone wasn't
    ;// reliably forcing these plain Text controls to repaint their content.
    ;// Also re-syncs any sliders' cached hit-test Y. Safe to call on any page (no-op
    ;// if it isn't scrollable).
    ReclipScroll(page) {
        if !this.HasOwnProp("ScrollState") || !this.ScrollState.Has(page)
            return
        state := this.ScrollState[page]

        static SWP_NOSIZE := 0x0001, SWP_NOZORDER := 0x0004, SWP_NOACTIVATE := 0x0010
        static SWP_SHOWWINDOW := 0x0040, SWP_HIDEWINDOW := 0x0080

        hdwp := DllCall("BeginDeferWindowPos", "Int", state.Entries.Length, "Ptr")
        for entry in state.Entries {
            y := entry.BaseY - state.ScrollY
            visible := !((y + entry.H < state.ViewTop) || (y > state.ViewBottom))
            flags := SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE | (visible ? SWP_SHOWWINDOW : SWP_HIDEWINDOW)
            hdwp := DllCall("DeferWindowPos", "Ptr", hdwp, "Ptr", entry.Ctrl.Hwnd, "Ptr", 0,
                "Int", entry.BaseX, "Int", y, "Int", 0, "Int", 0, "UInt", flags, "Ptr")

            entry.NewlyVisible := visible && !(entry.HasOwnProp("WasVisible") && entry.WasVisible)
            entry.WasVisible := visible
        }
        DllCall("EndDeferWindowPos", "Ptr", hdwp)

        for entry in state.Entries
            if entry.NewlyVisible
                entry.Ctrl.Redraw()

        for ref in state.SliderRefs
            ref.Obj.Y := ref.BaseY - state.ScrollY
    }

    ;// Pulls "Range<low>-<high>" out of an UpDown options string (e.g. "vfoo Range0-500 w50").
    ;// Falls back to AutoHotkey's own UpDown default (0-100) when Range isn't specified.
    ParseUpDownRange(upOpt) {
        if RegExMatch(upOpt, "i)Range(-?\d+)-(-?\d+)", &m)
            return {Min: Integer(m[1]), Max: Integer(m[2])}
        return {Min: 0, Max: 100}
    }

    ;// Dims/undims a slider to indicate enabled state. NOTE: like the Fluent toggles
    ;// elsewhere in this file, this is visual only — the slider remains draggable even
    ;// while "disabled" (same caveat as the Thio toggles further down).
    SetSliderEnabled(obj, enabled) {
        color := enabled ? "0078D4" : this.C_Panel
        obj.Fill.Opt("Background" color)
        obj.Thumb.Opt("Background" color)
        obj.Fill.Redraw()
        obj.Thumb.Redraw()
    }

    ;// Slider-change handler — replaces the old OnEditCtrl() now that the numeric
    ;// Values fields are Fluent sliders instead of Edit+UpDown.
    OnSliderChange(script, ini, objName, valLbl, val) {
        valLbl.Text := val
        valLbl.Redraw()

        iniVar := StrReplace(ini, A_Space, "_")
        this.UserSettings.%iniVar% := val

        if ini = "premPrevSeqDelay" {
            if winExt.ExistRegex("Core Functionality.ahk",,,, true) {
                try {
                    activeObj := CLSID_Objs.load("prem")
                    activeObj.prevSeqDelay  := (val * 1000)
                    activeObj.resetSeqTimer := true
                    activeObj := ""
                } catch {
                    activeObj := ""
                    notifyExt.showIfNotExist("settingsGUIswapSeq", "settingsGUI()",
                        "Could not update ``prem.swapSequences()``. A reload may be required",
                        ptf.Icons "\myscript.ico", "Windows Pop-up Blocked",,
                        "POS=BR DUR=5 SHOW=Fade@250 bdr=0xF59F10 maxW=400 Hide=Fade@250")
                }
            }
            return
        }

        ignoreScripts := Mip("Multi-Instance Close.ahk", true, "gameCheck.ahk", true)
        if winExt.ExistRegex(script " - AutoHotkey",,,, true) && script != "" && !ignoreScripts.Has(script)
            WM.Send_WM_COPYDATA(iniVar "," val "," objName, script)
    }

    ;// Back-arrow + title combo for a detail page. Adds its controls to `page`.
    AddSubPageHeader(page, backTo, title) {
        this.Gui.SetFont("s10 w600 c0078D4", "Segoe UI")
        back := this.Gui.Add("Text", "x220 y30 w110 h24 0x200 BackgroundTrans +E0x20", "←  Back")
        back.OnEvent("Click", (*) => this.NavigateTo(page, backTo))
        this.Hoverables[back.Hwnd] := {Ctrl: back, Normal: this.ThemeBg, Hover: this.C_Hover, Click: this.C_Click, Hovered: false}
        this.CursorZones[back.Hwnd] := 32649

        this.Gui.SetFont("s22 w600 c" this.C_Txt, "Segoe UI Variable Display")
        ttl := this.Gui.Add("Text", "x220 y58 w500 h40 BackgroundTrans", title)

        this.Pages[page].Push(back, ttl)
    }

    BuildUI() {
        ;// ── Sidebar ────────────────────────────────────────────────────────
        this.Gui.SetFont("s15 w600 c" this.C_Txt, "Segoe UI Variable Display")
        this.Gui.Add("Text", "x16 y20 w148 BackgroundTrans", "Settings")
        this.Gui.Add("Text", "x180 y0 w1 h640 Background" this.C_Panel)   ;// vertical divider

        this.Indicator := this.Gui.Add("Text", "x2 y86 w4 h24 Background0078D4")

        ;// Settings tabs
        sep := 45
        startSep := 80
        this.AddSidebarTab(startSep,  "General",    "General")
        this.AddSidebarTab(startSep+(sep*1), "Scripts",    "Scripts")
        this.AddSidebarTab(startSep+(sep*2), "Editors",    "Editors")

        ;// ── Sidebar footer ─────────────────────────────────────────────────
        this.Gui.Add("Text", "x0 y486 w180 h1 Background" this.C_Panel)

        this.AddSidebarButton(510, "💾  Hard Reset", this.OnClose.Bind(this, "hard"))
        this.AddSidebarButton(543, "🔄  Reload",     this.OnClose.Bind(this, "reload"))
        this.AddSidebarButton(576, "✕   Close",      this.OnClose.Bind(this, ""))

        ;// ── Focus trap ────────────────────────────────────────────────────
        this.Dummy := this.Gui.Add("Button", "x-100 y-100 w1 h1 -TabStop Default", "")
        try ControlFocus(this.Dummy)

        ;// ── Pages ─────────────────────────────────────────────────────────
        this.BuildGeneralPage()
        this.BuildScriptsPage()
        this.BuildEditorsPage()
    }

    AddSidebarButton(y, text, callback) {
        bg  := this.Gui.Add("Text", "x10 y" y  " w160 h28 Background" this.C_Panel)
        btn := this.Gui.Add("Text", "x11 y" (y+1) " w158 h26 Center 0x200 Background" this.C_Inner " c" this.C_Txt " +E0x20", text)
        this.Hoverables[bg.Hwnd] := {Ctrl: btn, Normal: this.C_Inner, Hover: this.C_Hover, Click: this.C_Click, Hovered: false}
        bg.OnEvent("Click", callback)
        this.CursorZones[bg.Hwnd] := 32649
    }


    ; ════════════════════════════════════════════════════════════════════════
    ;!  PAGES — Settings
    ; ════════════════════════════════════════════════════════════════════════

    ; ── General ─────────────────────────────────────────────────────────────
    BuildGeneralPage() {
        this.InitPage("General")
        this.AddTitle("General", "General", "Startup and core behaviour settings.")

        ;// Startup & Behaviour group
        startY := 100
        this.AddGroupBox("General", this.row1, startY, 320, 238, "Startup && Behaviour")
        this.AddToggle("General", this.row1+20, startY+55, this.setJSON.startup.title,
            (this.UserSettings.run_at_startup = true),         this.MakeCb("run at startup", ""))
        this.AddToggle("General", this.row1+20, startY+97, this.setJSON.discAutoReply.title,
            (this.UserSettings.disc_disable_autoreply = true), this.MakeCb("disc disable autoreply", ""))
        this.AddToggle("General", this.row1+20, startY+139, this.setJSON.show_adobe_vers_startup.title,
            (this.UserSettings.show_adobe_vers_startup = true),this.MakeCb("show adobe vers startup", ""))
        this.AddToggle("General", this.row1+20, startY+181, this.setJSON.adobeExeOverride.title,
            (this.UserSettings.adobeExeOverride = true),       this.MakeCb("adobeExeOverride", ""))

        this.AddGroupBox("General", this.row2, startY, 330, 115, "Game Management")
        this.AddButton("General", this.row2+20, startY+52, 290, "Add Game to gameCheck.ahk", "Secondary",
            (*) => this.NavigateTo("General", "General_AddGame"))

        this.BuildAddGamePage("General_AddGame")

        ;// updaates
        updateStartX := this.row2
        updateStartY := startY+127
        this.AddGroupBox("General", updateStartX, updateStartY, 330, 358, "Update Checks")

        ;// updateCheck is 3-state — mapped to a dropdown (Active / Silent / Stopped)
        checkVal := this.UserSettings.update_check
        ddlIdx   := (checkVal = "stop") ? 3 : (checkVal = true) ? 1 : 2
        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        ucLbl := this.Gui.Add("Text", "x" updateStartX+20 " y" updateStartY+58 " w200 h22 0x200 BackgroundTrans", this.setJSON.updateCheck.title)
        this.Pages["General"].Push(ucLbl)
        this.UpdateCheckDDL := this.AddDropdown("General", updateStartX+150, updateStartY+51, 100,
            ["Active", "Silent", "Stopped"], ddlIdx, this.OnUpdateCheckChange.Bind(this))

        ;// Beta toggle — disabled when update_check = "stop"
        betaOK := (checkVal != "stop") && (this.UserSettings.beta_update_check = true)
        this.BetaToggle := this.AddToggle("General", updateStartX+20, updateStartY+102, "Check for Pre-Releases",
            betaOK, this.OnBetaToggle.Bind(this))

        this.AddToggle("General", updateStartX+20, updateStartY+140, this.setJSON.ahkUpdate.title,
            (this.UserSettings.ahk_update_check = true),     this.MakeCb("ahk update check", ""))
        this.AddToggle("General", updateStartX+20, updateStartY+182, this.setJSON.libUpdate.title,
            (this.UserSettings.lib_update_check = true),     this.MakeCb("lib update check", ""))
        this.AddToggle("General", updateStartX+20, updateStartY+224, this.setJSON.packageUpdate.title,
            (this.UserSettings.package_update_check = true), this.MakeCb("package update check", ""))
        this.AddToggle("General", updateStartX+20, updateStartY+266, this.setJSON.versUpdate.title,
            (this.UserSettings.update_adobe_vers = true),    this.MakeCb("update adobe vers", ""))
        this.AddToggle("General", updateStartX+20, updateStartY+305, this.setJSON.gitUpdate.title,
            (this.UserSettings.update_git = true),           this.MakeCb("update git", ""))
    }

    ; ── Scripts ─────────────────────────────────────────────────────────────
    BuildScriptsPage() {
        this.InitPage("Scripts")
        this.AddTitle("Scripts", "Scripts", "Per-script behaviour toggles && numeric values.")

        ;// everything from here down scrolls as one body — the header above stays fixed
        scrollStart := this.Pages["Scripts"].Length + 1

        startY := 100
        ;// autosave group
        this.AddGroupBox("Scripts", this.row1, startY, 320, 268, "autosave.ahk")
        this.AddToggle("Scripts", this.row1+20, startY+55, this.setJSON.autosaveAlwaysSave.title,
            (this.UserSettings.autosave_always_save = true),      this.MakeCb("autosave always save", "autosave"))
        this.AddToggle("Scripts", this.row1+20, startY+96, this.setJSON.autosaveBeep.title,
            (this.UserSettings.autosave_beep = true),             this.MakeCb("autosave beep", "autosave"))
        this.AddToggle("Scripts", this.row1+20, startY+137, this.setJSON.autosaveMouse.title,
            (this.UserSettings.autosave_check_mouse = true),      this.MakeCb("autosave check mouse", "autosave"))
        this.AddToggle("Scripts", this.row1+20, startY+178, this.setJSON.autosaveOverride.title,
            (this.UserSettings.autosave_save_override = true),    this.MakeCb("autosave save override", "autosave"))
        this.AddToggle("Scripts", this.row1+20, startY+219, this.setJSON.autosaveRestartPlayback.title,
            (this.UserSettings.autosave_restart_playback = true), this.MakeCb("autosave restart playback", "autosave"))

        ;// checklist group
        checkListY := startY+280
        this.AddGroupBox("Scripts", this.row1, checkListY, 320, 135, "checklist.ahk")
        this.AddToggle("Scripts", this.row1+20, checkListY+50, this.setJSON.checklistHotkeys.title,
            (this.UserSettings.checklist_hotkeys = true), this.MakeMsgboxCb("checklist hotkeys"))
        this.AddToggle("Scripts", this.row1+20, checkListY+98, this.setJSON.checklistTooltip.title,
            (this.UserSettings.checklist_tooltip = true), this.MakeMsgboxCb("checklist tooltip"))

        ;// UIA group
        this.AddGroupBox("Scripts", this.row2, startY, 330, 100, "UIA")
        this.AddToggle("Scripts", this.row2+20, startY+55, this.setJSON.UIAonReload.title,
            (this.UserSettings.Set_UIA_on_reload = true), this.MakeCb("Set_UIA_on_reload", ""))

        this.AddGroupBox("Scripts", this.row2, startY+120, 330, 115, "Scripts")
        ;// was: this.MenuThio.Bind(this) — now swaps to an in-window detail page
        this.AddButton("Scripts", this.row2+20, startY+180, 290, "Thio MButton Script", "Secondary",
            (*) => this.NavigateTo("Scripts", "Scripts_Thio"))

        this.BuildThioSubPage("Scripts_Thio")

        ;// ── Numeric Values (moved here from the old Values tab, UpDowns swapped for sliders) ──
        set_Edit_Val.init()
        itemCount := set_Edit_Val().objs.Length
        itemH     := 74
        groupTop  := checkListY + 135 + 15                    ;// 15px below the checklist group
        groupW    := (this.row2 + 330) - this.row1            ;// spans both columns above
        groupH    := 50 + (itemCount * itemH) + 10
        this.AddGroupBox("Scripts", this.row1, groupTop, groupW, groupH, "Numeric Values")

        Loop itemCount {
            iniK    := set_Edit_Val.iniInput[A_Index]
            iniVar  := StrReplace(iniK, A_Space, "_")
            initVal := this.UserSettings.%iniVar%
            sText   := set_Edit_Val.scriptText[A_Index]
            sOther  := set_Edit_Val.otherText[A_Index]
            colour  := set_Edit_Val.colour[A_Index]
            ctrl    := set_Edit_Val.control[A_Index]
            upOpt   := set_Edit_Val.UpDownOpt[A_Index]
            bindScr := set_Edit_Val.Bind[A_Index]
            objName := set_Edit_Val.objName[A_Index]
            range   := this.ParseUpDownRange(upOpt)

            yPos := groupTop + 50 + (A_Index - 1) * itemH

            ;// coloured script label + live numeric readout (mirrors the old lbl/edit pairing)
            this.Gui.SetFont("s10 w600 " colour, "Segoe UI")
            lbl := this.Gui.Add("Text", "x" (this.row1+20) " y" yPos " w" (groupW-160) " h20 BackgroundTrans", sText)
            this.Gui.SetFont("s10 w600 c" this.C_SecTxt, "Segoe UI")
            valLbl := this.Gui.Add("Text", "x" (this.row1+groupW-100) " y" yPos " w80 h20 Right BackgroundTrans", initVal)
            this.Pages["Scripts"].Push(lbl, valLbl)

            sliderObj := this.AddSlider("Scripts", this.row1+20, yPos+26, groupW-40, range.Min, range.Max, 1, initVal, "",
                this.OnSliderChange.Bind(this, bindScr, iniK, objName, valLbl))

            ;// grey suffix
            this.Gui.SetFont("s9 w400 c" this.C_SecTxt, "Segoe UI")
            sfx := this.Gui.Add("Text", "x" (this.row1+20) " y" (yPos+50) " w" (groupW-40) " h15 BackgroundTrans", sOther)
            this.Pages["Scripts"].Push(sfx)

            ;// premPrev depends on useSwapSequences
            if ctrl = "premPrev" && (this.UserSettings.use_swapSequences = false
                                  || this.UserSettings.use_swapSequences = "false")
                this.SetSliderEnabled(sliderObj, false)

            this.NumRefs[ctrl] := {Slider: sliderObj}
        }

        this.MakeScrollable("Scripts", scrollStart, 100, 630)

        ;// keep the fixed title/subtitle painted on top of the scrollable body always —
        ;// they were added first (so start out at the *back* of the z-order), and a
        ;// scrolled control's uncropped bounds can momentarily overlap their screen
        ;// position while straddling the view boundary. z-order beats clip math here.
        loop scrollStart - 1
            this.BringToFront(this.Pages["Scripts"][A_Index])
    }

    ;// Moves a control to the front of the z-order among its window's siblings.
    BringToFront(ctrl) {
        static SWP_NOMOVE := 0x0002, SWP_NOSIZE := 0x0001, SWP_NOACTIVATE := 0x0010
        DllCall("SetWindowPos", "Ptr", ctrl.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0,
            "UInt", SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE)
    }

    ; ── Editors ─────────────────────────────────────────────────────────────
    BuildEditorsPage() {
        this.InitPage("Editors")
        this.AddTitle("Editors", "Editors", "Configure Adobe application version settings.")

        this.AddGroupBox("Editors", this.row1, 100, 340, 165, "Adobe Applications")
        ;// was: this.MenuAdobe.Bind(this, "AE"/"Premiere") — now swaps to in-window detail pages
        this.AddButton("Editors", this.row1+20, 152, 300, "After Effects Settings", "Secondary",
            (*) => this.NavigateTo("Editors", "Editors_AE"))
        this.AddButton("Editors", this.row1+20, 196, 300, "Premiere Settings",      "Secondary",
            (*) => this.NavigateTo("Editors", "Editors_Premiere"))

        this.BuildAdobeSubPage("Editors_AE",       "AE")
        this.BuildAdobeSubPage("Editors_Premiere", "Premiere")
    }

    ; ── Thio MButton Script ─────────────────────────────────────────────────
    BuildThioSubPage(page) {
        this.InitPage(page)
        this.AddSubPageHeader(page, "Scripts", "Thio MButton Script Settings")

        this.AddGroupBox(page, this.row1, 130, 460, 190, "Thio MButton")

        useThio := (this.UserSettings.Use_Thio_MButton = true)
        thioToggle := this.AddToggle(page, this.row1+20, 176, this.setJSON.Use_Thio_MButton.title, useThio,
            this.OnThioMButtonToggle.Bind(this))

        ;// Use_MButton can never be physically true while Use_Thio_MButton is off — this
        ;// clamps the toggle's *visual/initial* state regardless of what the ini says, and
        ;// corrects the ini value itself if it was left in an inconsistent state.
        useM := useThio && (this.UserSettings.Use_MButton = true)
        if !useThio && this.UserSettings.Use_MButton != "disabled"
            this.UserSettings.Use_MButton := "disabled"
        mToggle := this.AddToggle(page, this.row1+20, 218, this.setJSON.Use_MButton.title, useM,
            this.OnThioUseMButtonToggle.Bind(this))

        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        hLbl  := this.Gui.Add("Text", "x" this.row1+20 " y268 w170 h22 0x200 BackgroundTrans", "Activation Hotkey")
        hEdit := this.AddInput(page, 400, 261, 140, "")
        hEdit.Text := this.UserSettings.alternate_MButton_Key
        if useM
            hEdit.Opt("+Disabled")
        hEdit.OnEvent("Change", (ctrl, *) => this.UserSettings.alternate_MButton_Key := ctrl.Text)
        this.Pages[page].Push(hLbl)

        this.ThioCtrls := {ThioToggle: thioToggle, MToggle: mToggle, HotkeyEdit: hEdit}
    }

    OnThioMButtonToggle(state) {
        this.UserSettings.Use_Thio_MButton := state
        if !state {
            ;// parent off → force child into its "disabled" ini state, matching original behaviour
            this.UserSettings.Use_MButton := "disabled"
            this.SetToggleState(this.ThioCtrls.MToggle, false)
            ;// MToggle is now guaranteed off, so the hotkey field is always usable here
            this.ThioCtrls.HotkeyEdit.Opt("-Disabled")
        } else {
            if this.UserSettings.Use_MButton = "disabled"
                this.UserSettings.Use_MButton := "false"
            ;// re-sync the hotkey field to whatever MToggle's current state actually is —
            ;// this was the bug: previously nothing re-checked this when Thio was re-enabled,
            ;// so the field stayed stuck until the user manually clicked Use MButton.
            this.ThioCtrls.HotkeyEdit.Opt(this.ThioCtrls.MToggle.State ? "+Disabled" : "-Disabled")
        }
    }

    OnThioUseMButtonToggle(state) {
        if !this.ThioCtrls.ThioToggle.State {
            ;// parent (Use_Thio_MButton) is off — ignore, mirrors the original's disabled checkbox
            this.SetToggleState(this.ThioCtrls.MToggle, false)
            return
        }
        this.UserSettings.Use_MButton := state
        this.ThioCtrls.HotkeyEdit.Opt(state ? "+Disabled" : "-Disabled")
    }

    ; ── After Effects / Premiere ────────────────────────────────────────────
    GetAdobeMeta(program) {
        switch program {
            case "Premiere":
                return {
                    Short:        "prem",
                    ShortcutName: "Adobe Premiere Pro",
                    YearIni:      "prem_year",
                    VerIni:       "premVer",
                    CacheIni:     "premcache",
                    BetaIni:      "premIsBeta"
                }
            case "AE":
                return {
                    Short:        "ae",
                    ShortcutName: "Adobe After Effects",
                    YearIni:      "ae_year",
                    VerIni:       "aeVer",
                    CacheIni:     "aecache",
                    BetaIni:      "aeIsBeta"
                }
        }
    }

    GetAdobeYears(short) {
        jsonFolder := ptf.SupportFiles "\Release Assets\Adobe SymVers\Vers\" short
        if !DirExist(jsonFolder "\")
            errorLog(ValueError("Adobe json directory cannot be found", -1, jsonFolder),,, 1)
        years := []
        loop files jsonFolder "\*", "F"
            years.Push(SubStr(A_Year, 1, 2) SubStr(A_LoopFileName, 2, 2))
        return years.Sort("C").Reverse()
    }

    GetAdobeVersions(short, year) {
        jsonFolder := ptf.SupportFiles "\Release Assets\Adobe SymVers\Vers\" short
        if !DirExist(jsonFolder "\")
            errorLog(ValueError("Adobe json directory cannot be found", -1, jsonFolder),,, 1)
        supportedVersMap := JSON.parse(FileRead(jsonFolder "\v" SubStr(year, 3, 2) ".json"))
        vers := []
        for v in supportedVersMap
            vers.Push(v)
        return vers.Sort("C").Reverse()
    }

    BuildAdobeSubPage(page, program) {
        meta := this.GetAdobeMeta(program)
        this.InitPage(page)
        this.AddSubPageHeader(page, "Editors", program = "AE" ? "After Effects Settings" : "Premiere Settings")

        boxH := (program = "Premiere") ? 325 : 250
        this.AddGroupBox(page, this.row1, 130, 460, boxH, "Version && Cache")

        years   := this.GetAdobeYears(meta.Short)
        yearVal := this.UserSettings.%meta.YearIni%
        yearIdx := years.IndexOf(yearVal)
        if !yearIdx
            yearIdx := 1

        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        yLbl := this.Gui.Add("Text", "x" this.row1+20 " y183 w100 h22 0x200 BackgroundTrans", "Year")
        this.Pages[page].Push(yLbl)
        yearDDL := this.AddDropdown(page, 340, 176, 200, years, yearIdx,
            this.OnAdobeYearChange.Bind(this, program))

        vers   := this.GetAdobeVersions(meta.Short, years[yearIdx])
        verVal := this.UserSettings.%meta.VerIni%
        verIdx := vers.IndexOf(verVal)
        if !verIdx
            verIdx := 1

        vLbl := this.Gui.Add("Text", "x" this.row1+20 " y228 w100 h22 0x200 BackgroundTrans", "Version")
        this.Pages[page].Push(vLbl)
        verDDL := this.AddDropdown(page, 340, 221, 200, vers, verIdx,
            this.OnAdobeVerChange.Bind(this, program))

        betaState  := this.UserSettings.__convertToBool(meta.BetaIni, "Adjust")
        betaToggle := this.AddToggle(page, 220, 271, "Is Beta Version?", betaState,
            this.OnAdobeBetaToggle.Bind(this, program))

        cacheVal := this.UserSettings.%meta.CacheIni%
        cLbl := this.Gui.Add("Text", "x" this.row1+20 " y318 w100 h22 0x200 BackgroundTrans", "Cache Dir")
        this.Pages[page].Push(cLbl)
        cacheEdit := this.AddInput(page, 340, 311, 200, "")
        cacheEdit.Text := cacheVal
        cacheEdit.Opt("+ReadOnly")
        this.AddButton(page, 550, 311, 90, "Select", "Secondary",
            this.OnAdobeCacheSelect.Bind(this, program))

        ctrls := {YearDDL: yearDDL, VerDDL: verDDL, BetaToggle: betaToggle, CacheEdit: cacheEdit}

        if program = "Premiere" {
            defaults := Map("Light", 1, "Dark", 2, "Darkest", 3)
            idx := defaults.Has(this.UserSettings.premDefaultTheme) ? defaults[this.UserSettings.premDefaultTheme] : 1
            tLbl := this.Gui.Add("Text", "x" this.row1+20 " y363 w100 h22 0x200 BackgroundTrans", "Theme Default")
            this.Pages[page].Push(tLbl)
            themeDDL := this.AddDropdown(page, 340, 356, 200, ["Light", "Dark", "Darkest"], idx,
                this.OnPremThemeChange.Bind(this))
            ctrls.ThemeDDL := themeDDL

            swapState  := (this.UserSettings.use_swapSequences = true)
            swapToggle := this.AddToggle(page, 220, 406, this.setJSON.useSwapSequences.title, swapState,
                (state) => this.OnToggleSetting("Use swapSequences", "", state))
            ctrls.SwapToggle := swapToggle
        }

        this.Gui.SetFont("s9 italic c" this.C_SecTxt, "Segoe UI")
        note := this.Gui.Add("Text", "x" this.row1+20 " y" (130 + boxH + 10) " w440 h20 BackgroundTrans",
            "*some settings will require a full reload to take effect")
        this.Pages[page].Push(note)

        this.AdobeCtrls[program] := ctrls
    }

    OnAdobeYearChange(program, val) {
        meta  := this.GetAdobeMeta(program)
        ctrls := this.AdobeCtrls[program]
        this.UserSettings.%meta.YearIni% := val

        vers := this.GetAdobeVersions(meta.Short, val)
        ctrls.VerDDL.Items := vers
        ctrls.VerDDL.Index := 1
        ctrls.VerDDL.Value := vers[1]
        ctrls.VerDDL.Lbl.Text := vers[1]
        ctrls.VerDDL.Lbl.Redraw()
        this.UserSettings.%meta.VerIni% := vers[1]

        createTitle := "createShortcuts.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
        ignore := browser.vscode.winTitle
        if winExt.ExistRegex(createTitle,, ignore,, true)
            winExt.WaitCloseRegex(createTitle,,, ignore,, true)
        Run(ptf.Shortcuts "\createShortcuts.ahk false")
    }

    OnAdobeVerChange(program, val) {
        meta := this.GetAdobeMeta(program)
        if InStr(val, "v") && InStr(val, ".")
            this.UserSettings.%meta.VerIni% := val
    }

    OnAdobeBetaToggle(program, state) {
        meta := this.GetAdobeMeta(program)
        this.UserSettings.%meta.BetaIni% := this.UserSettings.__convertToStr(state)
        generateAdobeShortcut(this.UserSettings, meta.ShortcutName, this.AdobeCtrls[program].YearDDL.Value)
    }

    OnAdobeCacheSelect(program, *) {
        meta     := this.GetAdobeMeta(program)
        progName := (program = "Premiere") ? editors.__determinePremName() : "Adobe After Effects"
        slct := FileSelect("D",, "Select " progName " Cache Folder")
        if slct = ""
            return
        this.UserSettings.%meta.CacheIni% := slct
        this.AdobeCtrls[program].CacheEdit.Text := slct
    }

    OnPremThemeChange(val) {
        this.UserSettings.premDefaultTheme := val
    }


    ; ════════════════════════════════════════════════════════════════════════
    ;!  CALLBACK FACTORIES
    ; ════════════════════════════════════════════════════════════════════════

    ;// Returns a closure that routes through OnToggleSetting
    MakeCb(iniKey, objName) => (state) => this.OnToggleSetting(iniKey, objName, state)

    ;// Returns a closure that routes through OnMsgboxToggle (checklist.ahk)
    MakeMsgboxCb(iniKey) => (state) => this.OnMsgboxToggle(iniKey, state)


    ; ════════════════════════════════════════════════════════════════════════
    ;!  EVENT HANDLERS
    ; ════════════════════════════════════════════════════════════════════════

    /**
     * Generic toggle handler — mirrors the original toggle() logic.
     * @param {string} iniKey   INI key with spaces (e.g. "run at startup")
     * @param {string} objName  For autosave WM_COPYDATA messages
     * @param {bool}   state    New toggle state
     */
    OnToggleSetting(iniKey, objName, state) {
        detect()
        iniVar := StrReplace(iniKey, A_Space, "_")
        this.UserSettings.%iniVar% := state

        switch iniKey {
            case "run at startup":
                if state
                    FileCreateShortcut(ptf.rootDir "\PC Startup\Initialise.ahk", ptf["scriptStartup"])
                else if FileExist(ptf["scriptStartup"])
                    FileDelete(ptf["scriptStartup"])
                return

            case "Use swapSequences":
                ;// sync the premPrev slider
                if this.NumRefs.Has("premPrev")
                    this.SetSliderEnabled(this.NumRefs["premPrev"].Slider, state)
                ;// notify live prem object if Core Functionality is running
                origDetect := detect()
                if WinExist("Core Functionality.ahk") {
                    try {
                        activeObj := CLSID_Objs.load("prem")
                        if state {
                            activeObj.useSwapSequences := true
                            SetTimer(activeObj.__setCurrSeq.Bind(activeObj), activeObj.prevSeqDelay)
                        } else {
                            activeObj.useSwapSequences := false
                            activeObj.resetSeqTimer    := true
                        }
                        activeObj := ""
                    } catch {
                        activeObj := ""
                        notifyExt.showIfNotExist("settingsGUIswapSeq", "settingsGUI()",
                            "Could not update ``prem.swapSequences()``. A reload may be required",
                            ptf.Icons "\myscript.ico", "Windows Pop-up Blocked",,
                            "POS=BR DUR=5 SHOW=Fade@250 bdr=0xF59F10 maxW=400 Hide=Fade@250")
                    }
                }
                resetOrigDetect(origDetect)
        }

        ;// Notify autosave.ahk over WM_COPYDATA if running
        if InStr(iniKey, "autosave") && WinExist("autosave.ahk - AutoHotkey")
            WM.Send_WM_COPYDATA(iniVar "," (state ? 1 : 0) "," objName, "autosave.ahk")
    }

    ;// checklist toggles need a reload reminder
    OnMsgboxToggle(iniKey, state) {
        detect()
        iniVar := StrReplace(iniKey, A_Space, "_")
        this.UserSettings.%iniVar% := state
        if WinExist("checklist.ahk - AutoHotkey")
            MsgBox("Please stop any active checklist timers and restart ``checklist.ahk`` for this change to take effect",, "48 4096")
    }

    ;// 3-state updateCheck dropdown handler
    OnUpdateCheckChange(val) {
        switch val {
            case "Active":
                this.UserSettings.update_check := true
                this.SetToggleState(this.BetaToggle, this.UserSettings.beta_update_check = true)
            case "Silent":
                this.UserSettings.update_check := false
                this.SetToggleState(this.BetaToggle, this.UserSettings.beta_update_check = true)
            case "Stopped":
                this.UserSettings.update_check := "stop"
                this.SetToggleState(this.BetaToggle, false)
        }
    }

    OnBetaToggle(state) {
        if this.UserSettings.update_check = "stop"
            return
        this.UserSettings.beta_update_check := state
    }



    ;// Hard Reset / Reload / Close
    OnClose(action := "", *) {
        if WinExist("Scripts Release " this.version)
        switch action {
            case "hard":
                this.Gui.Destroy()
                reset.reset()
                SettingsApp.Instance := ""
                return
            case "reload":
                this.Gui.Destroy()
                reset.ext_reload()
                SettingsApp.Instance := ""
                return
        }
        this.Gui.Destroy()
        SettingsApp.Instance := ""
    }


    ; ── Add Game to gameCheck.ahk ────────────────────────────────────────────
    BuildAddGamePage(page) {
        this.InitPage(page)
        this.AddSubPageHeader(page, "General", "Add Game to gameCheck.ahk")

        this.Gui.SetFont("s10 w500 c" this.C_Txt, "Segoe UI")
        info1 := this.Gui.Add("Text", "x220 y110 w440 BackgroundTrans",
            "Format: GameTitle ahk_exe game.exe`nExample: Minecraft ahk_exe javaw.exe")

        this.Gui.SetFont("s9 w500 c" this.C_SecTxt, "Segoe UI")
        info2 := this.Gui.Add("Text", "x220 y150 w440 h90 BackgroundTrans",
            "This attempts to grab the correct information from the active window before the settings GUI"
            " was opened, and prefills the boxes below. If it's correct hit Add, otherwise enter the"
            " correct information.`n`n*This info can also be found using WindowSpy, bundled with AHK.")

        this.Pages[page].Push(info1, info2)

        this.AddGroupBox(page, 200, 250, 460, 195, "Game Details")

        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        tLbl := this.Gui.Add("Text", "x220 y308 w110 h22 0x200 BackgroundTrans", "Game Title")
        this.Pages[page].Push(tLbl)
        titleEdit := this.AddInput(page, 340, 305, 300, "")
        titleEdit.Text := this.winTitle

        pLbl := this.Gui.Add("Text", "x220 y353 w110 h22 0x200 BackgroundTrans", "Process Name")
        this.Pages[page].Push(pLbl)
        procEdit := this.AddInput(page, 340, 346, 300, "")
        procEdit.Text := "ahk_exe " this.process

        this.AddButton(page, 470, 395, 170, "Add to gameCheck.ahk", "Primary", this.OnAddGameClick.Bind(this))
        ; this.AddButton(page, 495, 445, 145, "Cancel",               "Secondary", this.OnCancelGameClick.Bind(this))

        this.AddGameCtrls := {TitleEdit: titleEdit, ProcessEdit: procEdit}
    }

    ;// mirrors gameCheckGUI.__checkGameList()
    CheckGameList() {
        if !FileExist(ptf["Game List"]) {
            MsgBox("``Game List.ahk`` not found in the proper directory")
            return false
        }
        return true
    }

    ;// mirrors gameCheckGUI.__checkForInput() — true = safe to add, false = duplicate found
    CheckForInput(readGameCheck, listFormat) {
        return !InStr(readGameCheck, listFormat, 1,, 1)
    }

    ;// mirrors gameCheckGUI.__appendInput() — returns true on confirmed success
    AppendInput(listFormat) {
        detect()
        FileAppend(",`n" listFormat, ptf["Game List"])

        ;// reloading gameCheck.ahk if it's running
        if WinExist("gameCheck.ahk - AutoHotkey")
            PostMessage 0x0111, 65303,,, "gameCheck.ahk - AutoHotkey"

        ;// checking if it worked
        readAgain := FileRead(ptf["Game List"])
        return InStr(readAgain, listFormat, 1,, 1) ? true : false
    }

    ;// mirrors gameCheckGUI.__addButton_Click()
    OnAddGameClick(*) {
        titleVal := this.AddGameCtrls.TitleEdit.Text
        procVal  := this.AddGameCtrls.ProcessEdit.Text

        if !this.CheckGameList()
            return

        readGameCheck := FileRead(ptf["Game List"])
        listFormat    := Format('{} {}', titleVal, procVal)

        if !this.CheckForInput(readGameCheck, listFormat) {
            MsgBox("The desired window is already in the list!", "Game already added! - gameCheck")
            return
        }

        if !this.AppendInput(listFormat) {
            MsgBox("Game added unsuccesfully :(")
            return
        }

        MsgBox("Game added succesfully!")
        this.NavigateTo("General_AddGame", "General")
    }

    ;// mirrors gameCheckGUI.__cancelButton_Click()
    OnCancelGameClick(*) {
        this.NavigateTo("General_AddGame", "General")
    }
}
