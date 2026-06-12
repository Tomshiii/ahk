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
#Include GUIs\FluentApp.ahk   ;// Fluent theming base — save the boilerplate there
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

    version   := UserSettings.version
    gameTitle := "Add game to gameCheck.ahk"
    gameCheckSettingGUI := gameCheckGUI(version, winTitle, winProcc)

    if WinExist("Settings " version)
        return

    SettingsApp(UserSettings, setJSON, version, gameCheckSettingGUI, gameTitle)
}


; ════════════════════════════════════════════════════════════════════════════
;   SettingsApp  –  extends FluentApp
;
;   Window : 880 × 640
;   Sidebar: 0–180  (9 tabs + footer buttons)
;   Content: 185–875
;
;   Sidebar tabs
;     General · Updates · Scripts · Values · Appearance
;     File · Open · Editors · Other
; ════════════════════════════════════════════════════════════════════════════
class SettingsApp extends FluentApp {
    ; ── Constructor ─────────────────────────────────────────────────────────
    __New(UserSettings, setJSON, version, gameCheckGUI, gameTitle) {
        SettingsApp.Instance := this
        this.UserSettings    := UserSettings
        this.setJSON         := setJSON
        this.version         := version
        this.gameCheckGUI    := gameCheckGUI
        this.gameTitle       := gameTitle
        ;// runtime refs populated on every (re)build
        this.NumRefs         := Map()          ;// ctrl-name → {Edit, UpDown}
        this.BetaToggle      := {State: false} ;// placeholder until BuildUpdatesPage runs
        ;// theme seed — FluentApp.__New reads this.IsDark before building
        this.IsDark          := true           ;// light mode is cooked. don't allow it
        this.CurrentBackdropType := 3          ;// Acrylic default
        this.ActiveTab       := "General"
        this.ActiveSubPages  := Map()
        super.__New()
    }

    ; ── RebuildUI override ──────────────────────────────────────────────────
    ;// Full override: custom title, +AlwaysOnTop, 880×640, no menu bar.
    RebuildUI() {
        ;// FluentApp.__New() overwrites this.IsDark := true and this.ActiveTab := "Forms && Data"
        ;// before calling RebuildUI, so we re-anchor both from our own state here.
        this.IsDark := (this.UserSettings.dark_mode = true)

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

        ;// ── Colour palette ────────────────────────────────────────────────
        this.ThemeBg  := (VerCompare(A_OSVersion, "10.0.22000") >= 0)
                            ? (this.IsDark ? "000000" : "FFFFFF")
                            : (this.IsDark ? "1E1E1E" : "F3F3F3")
        this.C_Txt    := this.IsDark ? "White"   : "000000"
        this.C_SecTxt := this.IsDark ? "A0A0A0"  : "5D5D5D"
        this.C_Panel  := this.IsDark ? "333333"  : "F3F3F3"
        this.C_Inner  := this.IsDark ? "141414"  : "FFFFFF"
        this.C_Head   := this.IsDark ? "2A2A2A"  : "EBEBEB"
        this.C_List   := this.IsDark ? "1C1C1C"  : "FFFFFF"
        this.C_Hover  := this.IsDark ? "1A1A1A"  : "E5E5E5"
        this.C_Hover2 := this.IsDark ? "2A2A2A"  : "DCDCDC"
        this.C_Click  := this.IsDark ? "101010"  : "D0D0D0"

        ;// ── Create GUI ────────────────────────────────────────────────────
        this.Gui := Gui("-Resize +AlwaysOnTop", "Settings " this.version)
        this.Gui.OnEvent("Close",  (*) => this.OnClose())
        this.Gui.OnEvent("Escape", (*) => this.OnClose())
        this.Gui.BackColor := this.ThemeBg

        val := Buffer(4, 0)
        NumPut("Int", this.IsDark ? 1 : 0, val)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Gui.Hwnd, "Int", 20, "Ptr", val, "Int", 4)
        this.EnableBackdrop(this.Gui.Hwnd, this.CurrentBackdropType)

        this.BuildUI()

        this.Gui.Show("Center w880 h640")
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


    ; ════════════════════════════════════════════════════════════════════════
    ;!  TOP-LEVEL UI LAYOUT
    ;
    ;  Sidebar tab y-positions (45 px intervals, 9 tabs):
    ;   80  General      260  Appearance
    ;   125 Updates      305  File
    ;   170 Scripts      350  Open
    ;   215 Values       395  Editors
    ;                    440  Other
    ;
    ;  Footer (below last tab at y=476):
    ;   y=486  separator   y=510  Hard Reset
    ;   y=492  work-dir    y=543  Reload
    ;                      y=576  Close
    ; ════════════════════════════════════════════════════════════════════════

    BuildUI() {
        ;// ── Sidebar ────────────────────────────────────────────────────────
        this.Gui.SetFont("s15 w600 c" this.C_Txt, "Segoe UI Variable Display")
        this.Gui.Add("Text", "x16 y20 w148 BackgroundTrans", "Settings")
        this.Gui.Add("Text", "x180 y0 w1 h640 Background" this.C_Panel)   ;// vertical divider

        this.Indicator := this.Gui.Add("Text", "x2 y86 w4 h24 Background0078D4")

        ;// Settings tabs
        this.AddSidebarTab(80,  "General",    "General")
        this.AddSidebarTab(125, "Updates",    "Updates")
        this.AddSidebarTab(170, "Scripts",    "Scripts")
        this.AddSidebarTab(215, "Values",     "Values")
        this.AddSidebarTab(260, "Appearance", "Appearance")
        ;// Former menu-bar sections
        this.AddSidebarTab(305, "File",       "File")
        this.AddSidebarTab(350, "Open",       "Open")
        this.AddSidebarTab(395, "Editors",    "Editors")
        this.AddSidebarTab(440, "Other",      "Other")

        ;// ── Sidebar footer ─────────────────────────────────────────────────
        this.Gui.Add("Text", "x0 y486 w180 h1 Background" this.C_Panel)

        workDir := FileRead(A_AppData "\tomshi\installDir")
        this.Gui.SetFont("s8 w400 c" this.C_SecTxt, "Segoe UI")
        this.Gui.Add("Text", "x8 y492 w165 h14 BackgroundTrans", "📁 " workDir)

        this.AddSidebarButton(510, "💾  Hard Reset", this.OnClose.Bind(this, "hard"))
        this.AddSidebarButton(543, "🔄  Reload",     this.OnClose.Bind(this, "reload"))
        this.AddSidebarButton(576, "✕   Close",      this.OnClose.Bind(this, ""))

        ;// ── Focus trap ────────────────────────────────────────────────────
        this.Dummy := this.Gui.Add("Button", "x-100 y-100 w1 h1 -TabStop Default", "")
        try ControlFocus(this.Dummy)

        ;// ── Pages ─────────────────────────────────────────────────────────
        this.BuildGeneralPage()
        this.BuildUpdatesPage()
        this.BuildScriptsPage()
        this.BuildValuesPage()
        this.BuildAppearancePage()
        this.BuildFilePage()
        this.BuildOpenPage()
        this.BuildEditorsPage()
        this.BuildOtherPage()
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

        ;// Startup & Behaviour group  (dark mode lives in Appearance)
        this.AddGroupBox("General", 200, 100, 335, 238, "Startup && Behaviour")
        this.AddToggle("General", 220, 155, this.setJSON.startup.title,
            (this.UserSettings.run_at_startup = true),         this.MakeCb("run at startup", ""))
        this.AddToggle("General", 220, 197, this.setJSON.discAutoReply.title,
            (this.UserSettings.disc_disable_autoreply = true), this.MakeCb("disc disable autoreply", ""))
        this.AddToggle("General", 220, 239, this.setJSON.show_adobe_vers_startup.title,
            (this.UserSettings.show_adobe_vers_startup = true),this.MakeCb("show adobe vers startup", ""))
        this.AddToggle("General", 220, 281, this.setJSON.adobeExeOverride.title,
            (this.UserSettings.adobeExeOverride = true),       this.MakeCb("adobeExeOverride", ""))

        ;// Premiere Pro group
        this.AddGroupBox("General", 545, 100, 315, 120, "Premiere Pro")
        this.AddToggle("General", 565, 155, this.setJSON.useSwapSequences.title,
            (this.UserSettings.use_swapSequences = true), this.MakeCb("Use swapSequences", ""))
    }

    ; ── Updates ─────────────────────────────────────────────────────────────
    BuildUpdatesPage() {
        this.InitPage("Updates")
        this.AddTitle("Updates", "Updates", "Control how and when scripts check for updates.")

        this.AddGroupBox("Updates", 200, 100, 660, 358, "Update Checks")

        ;// updateCheck is 3-state — mapped to a dropdown (Active / Silent / Stopped)
        checkVal := this.UserSettings.update_check
        ddlIdx   := (checkVal = "stop") ? 3 : (checkVal = true) ? 1 : 2
        this.Gui.SetFont("s10 w400 c" this.C_Txt, "Segoe UI")
        ucLbl := this.Gui.Add("Text", "x220 y153 w200 h22 0x200 BackgroundTrans", this.setJSON.updateCheck.title)
        this.Pages["Updates"].Push(ucLbl)
        this.UpdateCheckDDL := this.AddDropdown("Updates", 432, 146, 200,
            ["Active", "Silent", "Stopped"], ddlIdx, this.OnUpdateCheckChange.Bind(this))

        ;// Beta toggle — disabled when update_check = "stop"
        betaOK := (checkVal != "stop") && (this.UserSettings.beta_update_check = true)
        this.BetaToggle := this.AddToggle("Updates", 220, 198, "Check for Pre-Releases",
            betaOK, this.OnBetaToggle.Bind(this))

        this.AddToggle("Updates", 220, 240, this.setJSON.ahkUpdate.title,
            (this.UserSettings.ahk_update_check = true),     this.MakeCb("ahk update check", ""))
        this.AddToggle("Updates", 220, 282, this.setJSON.libUpdate.title,
            (this.UserSettings.lib_update_check = true),     this.MakeCb("lib update check", ""))
        this.AddToggle("Updates", 220, 324, this.setJSON.packageUpdate.title,
            (this.UserSettings.package_update_check = true), this.MakeCb("package update check", ""))
        this.AddToggle("Updates", 220, 366, this.setJSON.versUpdate.title,
            (this.UserSettings.update_adobe_vers = true),    this.MakeCb("update adobe vers", ""))
        this.AddToggle("Updates", 220, 408, this.setJSON.gitUpdate.title,
            (this.UserSettings.update_git = true),           this.MakeCb("update git", ""))
    }

    ; ── Scripts ─────────────────────────────────────────────────────────────
    BuildScriptsPage() {
        this.InitPage("Scripts")
        this.AddTitle("Scripts", "Scripts", "Per-script behaviour toggles.")

        ;// autosave group
        this.AddGroupBox("Scripts", 200, 100, 320, 268, "autosave.ahk")
        this.AddToggle("Scripts", 220, 155, this.setJSON.autosaveAlwaysSave.title,
            (this.UserSettings.autosave_always_save = true),      this.MakeCb("autosave always save", "autosave"))
        this.AddToggle("Scripts", 220, 196, this.setJSON.autosaveBeep.title,
            (this.UserSettings.autosave_beep = true),             this.MakeCb("autosave beep", "autosave"))
        this.AddToggle("Scripts", 220, 237, this.setJSON.autosaveMouse.title,
            (this.UserSettings.autosave_check_mouse = true),      this.MakeCb("autosave check mouse", "autosave"))
        this.AddToggle("Scripts", 220, 278, this.setJSON.autosaveOverride.title,
            (this.UserSettings.autosave_save_override = true),    this.MakeCb("autosave save override", "autosave"))
        this.AddToggle("Scripts", 220, 319, this.setJSON.autosaveRestartPlayback.title,
            (this.UserSettings.autosave_restart_playback = true), this.MakeCb("autosave restart playback", "autosave"))

        ;// checklist group
        this.AddGroupBox("Scripts", 200, 380, 320, 135, "checklist.ahk")
        this.AddToggle("Scripts", 220, 430, this.setJSON.checklistHotkeys.title,
            (this.UserSettings.checklist_hotkeys = true), this.MakeMsgboxCb("checklist hotkeys"))
        this.AddToggle("Scripts", 220, 472, this.setJSON.checklistTooltip.title,
            (this.UserSettings.checklist_tooltip = true), this.MakeMsgboxCb("checklist tooltip"))

        ;// UIA group
        this.AddGroupBox("Scripts", 530, 100, 330, 120, "UIA")
        this.AddToggle("Scripts", 550, 155, this.setJSON.UIAonReload.title,
            (this.UserSettings.Set_UIA_on_reload = true), this.MakeCb("Set_UIA_on_reload", ""))
    }

    ; ── Values ──────────────────────────────────────────────────────────────
    BuildValuesPage() {
        this.InitPage("Values")
        this.AddTitle("Values", "Numeric Values", "Adjust timing and rate settings for scripts.")

        this.AddGroupBox("Values", 200, 100, 660, 406, "Edit Values")

        set_Edit_Val.init()
        Loop set_Edit_Val().objs.Length {
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

            yPos  := 152 + (A_Index - 1) * 50
            xEdit := 598

            ;// coloured script label + grey suffix
            this.Gui.SetFont("s10 w600 " colour, "Segoe UI")
            lbl := this.Gui.Add("Text", "x220 y" yPos " w355 h20 BackgroundTrans", sText)
            this.Gui.SetFont("s9 w400 c" this.C_SecTxt, "Segoe UI")
            sfx := this.Gui.Add("Text", "x220 y" (yPos + 20) " w220 h15 BackgroundTrans", sOther)

            ;// styled border + Edit + UpDown
            bdr := this.Gui.Add("Text", "x" xEdit " y" (yPos - 1) " w66 h30 Background" this.C_Panel)
            edt := this.Gui.Add("Edit",
                "x" (xEdit + 1) " y" yPos " w50 h28 -E0200 Number v" ctrl " Background" this.C_Inner " c" this.C_Txt)
            DllCall("uxtheme\SetWindowTheme", "Ptr", edt.Hwnd,
                "Str", this.IsDark ? "DarkMode_Explorer" : "Explorer", "Ptr", 0)
            upd := this.Gui.Add("UpDown", upOpt, initVal)

            ;// premPrev depends on useSwapSequences
            if ctrl = "premPrev" && (this.UserSettings.use_swapSequences = false
                                  || this.UserSettings.use_swapSequences = "false")
                edt.Opt("+Disabled")

            edt.OnEvent("Change", this.OnEditCtrl.Bind(this, bindScr, iniK, objName))
            this.NumRefs[ctrl] := {Edit: edt, UpDown: upd}
            this.Pages["Values"].Push(lbl, sfx, bdr, edt, upd)
        }
    }


    ; ════════════════════════════════════════════════════════════════════════
    ;!  PAGES — Appearance  (ported from FluentApp boilerplate)
    ; ════════════════════════════════════════════════════════════════════════

    BuildAppearancePage() {
        this.InitPage("Appearance")
        this.AddTitle("Appearance", "Appearance", "Customise glass materials and colour theme in real-time.")

        ;// Backdrop Material Engine
        this.AddGroupBox("Appearance", 200, 100, 660, 140, "Backdrop Material Engine")
        materials := ["Mica (Standard)", "Acrylic (Frosted)", "Mica Alt (Tinted)", "System Theme"]
        matIdx    := (this.CurrentBackdropType = 3) ? 2 : (this.CurrentBackdropType = 4) ? 3 : 1
        this.AddDropdown("Appearance", 220, 150, 460, materials, matIdx, this.OnChangeBackdrop.Bind(this))

        ;// Theme Engine  (dark mode toggle moved here from General)
        this.AddGroupBox("Appearance", 200, 252, 660, 105, "Theme Engine")
        this.AddToggle("Appearance", 220, 303, this.setJSON.dark.title,
            (this.UserSettings.dark_mode = true), this.OnDarkToggle.Bind(this))
    }


    ; ════════════════════════════════════════════════════════════════════════
    ;!  PAGES — Former menu-bar sections
    ; ════════════════════════════════════════════════════════════════════════

    ; ── File ────────────────────────────────────────────────────────────────
    BuildFilePage() {
        this.InitPage("File")
        this.AddTitle("File", "File", "Script management actions.")

        this.AddGroupBox("File", 200, 100, 460, 115, "Game Management")
        this.AddButton("File", 220, 152, 300, "Add Game to gameCheck.ahk", "Secondary",
            this.MenuAddGame.Bind(this))
    }

    ; ── Open ────────────────────────────────────────────────────────────────
    BuildOpenPage() {
        this.InitPage("Open")
        this.AddTitle("Open", "Open", "Open files and documentation.")

        this.AddGroupBox("Open", 200, 100, 460, 232, "Files && Resources")
        this.AddButton("Open", 220, 152, 300, "Open settings.ini",      "Secondary", this.MenuOpenIni.Bind(this))
        this.AddButton("Open", 220, 196, 300, "Settings Cheat Sheet",   "Secondary", this.OpenWiki.Bind(this, "cheat"))
        this.AddButton("Open", 220, 240, 300, "Wiki Directory (Local)", "Secondary", this.OpenWiki.Bind(this, "local"))
        this.AddButton("Open", 220, 284, 300, "Wiki (Web)",             "Secondary", this.OpenWiki.Bind(this, "web"))
    }

    ; ── Editors ─────────────────────────────────────────────────────────────
    BuildEditorsPage() {
        this.InitPage("Editors")
        this.AddTitle("Editors", "Editors", "Configure Adobe application version settings.")

        this.AddGroupBox("Editors", 200, 100, 460, 165, "Adobe Applications")
        this.AddButton("Editors", 220, 152, 300, "After Effects Settings", "Secondary",
            this.MenuAdobe.Bind(this, "AE"))
        this.AddButton("Editors", 220, 196, 300, "Premiere Settings",      "Secondary",
            this.MenuAdobe.Bind(this, "Premiere"))
    }

    ; ── Other ───────────────────────────────────────────────────────────────
    BuildOtherPage() {
        this.InitPage("Other")
        this.AddTitle("Other", "Other Settings", "Additional script configuration.")

        this.AddGroupBox("Other", 200, 100, 460, 115, "Scripts")
        this.AddButton("Other", 220, 152, 300, "Thio MButton Script", "Secondary",
            this.MenuThio.Bind(this))
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

    OnDarkToggle(state) {
        this.UserSettings.dark_mode := state
        this.OnToggleTheme(state)   ;// inherited — sets IsDark, schedules RebuildUI in 10 ms
    }

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
                ;// sync the premPrev numeric edit
                if this.NumRefs.Has("premPrev")
                    this.NumRefs["premPrev"].Edit.Opt(state ? "-Disabled" : "+Disabled")
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

    ;// Numeric edit-box change — mirrors original editCtrl()
    OnEditCtrl(script, ini, objName, ctrl, *) {
        iniVar := StrReplace(ini, A_Space, "_")
        this.UserSettings.%iniVar% := ctrl.text

        if ini = "premPrevSeqDelay" {
            if winExt.ExistRegex("Core Functionality.ahk",,,, true) {
                try {
                    activeObj := CLSID_Objs.load("prem")
                    activeObj.prevSeqDelay  := (ctrl.text * 1000)
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
            WM.Send_WM_COPYDATA(iniVar "," ctrl.text "," objName, script)
    }

    ;// Hard Reset / Reload / Close
    OnClose(action := "", *) {
        if WinExist("Scripts Release " this.version)
            WinSetAlwaysOnTop(1, "Scripts Release " this.version)
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


    ; ════════════════════════════════════════════════════════════════════════
    ;!  ACTION FUNCTIONS  (called from page buttons)
    ; ════════════════════════════════════════════════════════════════════════

    OpenWiki(which, *) {
        openPage(title, link) {
            if !checkInternet() {
                tool.Cust("It doesn't appear like you have an active internet connection", 2.0)
                tool.Cust("The page will run just incase", 2.0,, 20, 2)
            }
            WinExist(title) ? WinActivate(title) : Run(link)
        }
        switch which {
            case "local":
                if WinExist("Wiki explorer.exe")
                    WinActivate("Wiki explorer.exe")
                else if DirExist(ptf.Wiki "\Latest")
                    Run(ptf.Wiki "\Latest")
            case "web":
                openPage("Home · Tomshiii/ahk Wiki",          "https://github.com/Tomshiii/ahk/wiki")
            case "cheat":
                openPage("settingsGUI() · Tomshiii/ahk Wiki", "https://github.com/Tomshiii/ahk/wiki/settingsGUI()")
        }
    }

    MenuAddGame(*) {
        closeEv(*) {
            if WinExist("Settings " this.version) {
                ExStyle := wingetExStyle("Settings " this.version)
                if ExStyle & !0x8
                    WinSetAlwaysOnTop(1, "Settings " this.version)
                if !WinActive("Settings " this.version)
                    WinActivate("Settings " this.version)
            }
            this.gameCheckGUI.Hide()
        }
        this.gameCheckGUI.Show("AutoSize")
        this.gameCheckGUI.OnEvent("Close", closeEv)
        WinSetAlwaysOnTop(0, "Settings " this.version)
        this.Gui.Opt("+Disabled")
        WinWaitClose(this.gameTitle)
        if WinExist("Settings " this.version)
            this.Gui.Opt("-Disabled")
    }

    MenuOpenIni(*) {
        this.Gui.GetPos(&x, &y, &width, &height)
        this.Gui.Opt("-AlwaysOnTop")
        iniTitle := "settings.ini"
        WinExist(iniTitle) ? refreshWin(iniTitle, this.UserSettings.SettingsFile)
                           : Run("Notepad.exe " this.UserSettings.SettingsFile)
        if !WinWait(iniTitle,, 3)
            return
        WinMove(x + width - 8, y, 322, height - 2, iniTitle)
        SetTimer(this.IniWait.Bind(this), 100)
    }

    IniWait() {
        if !WinExist("Settings " this.version) {
            SetTimer(, 0)
            return
        }
        if !WinExist("settings.ini") && WinExist("Settings " this.version) {
            this.Gui.Opt("+AlwaysOnTop")
            SetTimer(, 0)
        }
    }

    ; ── Thio MButton sub-GUI ────────────────────────────────────────────────
    MenuThio(*) {
        thioTitle := "Thio MButton Script Settings"
        if WinExist(thioTitle) {
            WinActivate(thioTitle)
            return
        }
        thioGUI := tomshiBasic(,, "AlwaysOnTop +MinSize275x Owner", thioTitle)

        thioGUI.AddCheckbox("vUse_Thio_MButton Checked" this.UserSettings.Use_Thio_MButton " Y+5",
            this.setJSON.Use_Thio_MButton.title)
            .OnEvent("Click", (ctrl, *) => (
                this.UserSettings.Use_Thio_MButton := (ctrl.value = 1),
                ctrl.value = 0
                    ? (thioGUI["Use_MButton"].Opt("+Disabled"), this.UserSettings.Use_MButton := "disabled")
                    : (thioGUI["Use_MButton"].Opt("-Disabled"), this.UserSettings.Use_MButton := "false")
            ))
        thioGUI["Use_Thio_MButton"].ToolTip := (this.UserSettings.Use_Thio_MButton = true)
            ? this.setJSON.Use_Thio_MButton.tooltip.true
            : this.setJSON.Use_Thio_MButton.tooltip.false

        thioGUI.AddCheckbox("vUse_MButton Checked" this.UserSettings.Use_MButton " Y+5",
            this.setJSON.Use_MButton.title)
            .OnEvent("Click", (ctrl, *) => (
                this.UserSettings.Use_MButton := (ctrl.value = 1),
                ctrl.value = 1
                    ? thioGUI["thioHotkey"].Opt("+Disabled")
                    : thioGUI["thioHotkey"].Opt("-Disabled")
            ))
        thioGUI["Use_MButton"].ToolTip := (this.UserSettings.Use_MButton = true)
            ? this.setJSON.Use_MButton.tooltip.true
            : this.setJSON.Use_MButton.tooltip.false
        thioGUI["Use_MButton"].Opt(this.UserSettings.Use_Thio_MButton = false ? "Disabled" : "")

        thioGUI.Add("Text",, "Change activation hotkey: ")
        thioGUI.Add("Edit", "vthioHotkey x+10 y+-20 w150", this.UserSettings.alternate_MButton_Key)
            .OnEvent("Change", (ctrl, *) => this.UserSettings.alternate_MButton_Key := ctrl.value)
        if thioGUI["Use_MButton"].value = true
            thioGUI["thioHotkey"].Opt("Disabled")

        thioGUI.Add("Button", "xp+98 y+10", "Close").OnEvent("Click", (*) => WinClose(thioTitle))

        thioGUI.Show()
        this.Gui.Opt("+Disabled")
        WinGetPos(&x, &y,,, "Settings " this.version)
        thioGUI.GetPos(,, &w)
        thioGUI.Move(x - w + 5, y)
        WinWaitClose(thioTitle)
        this.Gui.Opt("-Disabled")
    }

    ; ── Adobe version sub-GUI ───────────────────────────────────────────────
    MenuAdobe(program, *) {
        switch program {
            case "Premiere":
                short         := "prem"
                static premIsBeta := unset
                adobeFullName := editors.__determinePremName()
                shortcutName  := "Adobe Premiere Pro"
                title         := "Premiere Settings"
                yearIniName   := "prem_year"
                iniInitYear   := this.UserSettings.prem_year
                verIniName    := "premVer"
                initVer       := this.UserSettings.premVer
                genProg       := program
                otherTitle    := "After Effects Settings"
                static imageLoc := ptf.premSETver
                path := A_ProgramFiles "\Adobe\" adobeFullName " " iniInitYear "\" shortcutName
            case "AE":
                short         := "ae"
                static aeIsBeta := unset
                adobeFullName := "Adobe After Effects"
                shortcutName  := "Adobe After Effects"
                title         := "After Effects Settings"
                yearIniName   := "ae_year"
                iniInitYear   := this.UserSettings.ae_year
                verIniName    := "aeVer"
                initVer       := this.UserSettings.aeVer
                genProg       := "AE"
                otherTitle    := "Premiere Settings"
                static imageLoc := ptf.aeSETver
                path := A_ProgramFiles "\Adobe\" adobeFullName " " iniInitYear "\Support Files\" shortcutName
        }
        if WinExist(title) {
            WinActivate(title)
            return
        }
        adobeGui := tomshiBasic(,, "+MinSize275x AlwaysOnTop Owner", title)
        ctrlX := 120

        adobeGui.AddText("Section", "Year: ")
        __generateDropYear(genProg, &year, ctrlX)
        adobeGui.AddText("xs y+10", "Version: ")
        __generateDropVer(genProg, &ver, ctrlX)

        adobeGui.AddText("xs y+10 Section", "Is Beta: ")
        adobeGui.AddCheckbox("x+10 y+-20 vIsBeta Checked"
            (%short%IsBeta ?? this.UserSettings.__convertToBool(short "IsBeta", "Adjust")), "Is Beta Version?")
            .OnEvent("Click", (ctrl, *) => (
                %short%IsBeta := ctrl.value,
                this.UserSettings.%short%IsBeta := this.UserSettings.__convertToStr(ctrl.value),
                __generateShortcut()
            ))

        if program != "Photoshop" {
            adobeGui.AddText("xs y+12 Section", "Cache Dir: ")
            cacheInit := short "cache"
            cache := adobeGui.Add("Edit", "x" ctrlX " ys-3 r1 W150 ReadOnly", this.UserSettings.%cacheInit%)
            cacheSelect := adobeGui.Add("Button", "vcacheBut x+5 w60 h27", "select")
            cacheSelect.OnEvent("Click", __cacheslct.Bind(adobeFullName))
            adobeGui["cacheBut"].GetPos(&cacheButX)
        }
        if program = "Premiere" {
            defaults := Map("Light", "1", "Dark", "2", "Darkest", "3")
            adobeGui.AddText("xs", "Theme Default: ")
            adobeGui.AddDropDownList("x" ctrlX " y+-20 w100 Choose"
                defaults.Get(this.UserSettings.premDefaultTheme) " vthemeDefaultPrem", ["Light", "Dark", "Darkest"])
            adobeGui["themeDefaultPrem"].OnEvent("change", (ctrl, *) => this.UserSettings.premDefaultTheme := ctrl.Text)
            adobeGui.AddCheckbox("vuseSwapSequences Checked" this.UserSettings.use_swapSequences " xs Y+15",
                this.setJSON.useSwapSequences.title)
                .OnEvent("Click", (ctrl, *) => this.OnToggleSetting("Use swapSequences", "", ctrl.value = 1))
            adobeGui["useSwapSequences"].ToolTip := (this.UserSettings.use_swapSequences = true)
                ? this.setJSON.useSwapSequences.tooltip.true
                : this.setJSON.useSwapSequences.tooltip.false
        }

        adobeGui["IsBeta"].GetPos(&isBetaX)
        closeX := IsSet(cacheButX) ? cacheButX : isBetaX
        saveBut := adobeGui.Add("Button", "x" closeX, "close")
        adobeGui.AddText("x" closeX - 175 " y+-30 Right BackgroundTrans",
            "*some settings will require`na full reload to take effect").SetFont("s9 italic")
        saveBut.OnEvent("Click", (*) => adobeGui.Destroy())

        adobeGui.Show()
        this.Gui.Opt("+Disabled")
        WinGetPos(&x, &y,,, "Settings " this.version)
        if WinExist(otherTitle)
            WinGetPos(,,, &yearHeight, otherTitle)
        adobeGui.GetPos(,, &width)
        adobeGui.Move(x - width + 5, y)
        WinWaitClose(title)
        this.Gui.Opt("-Disabled")

        ; ── Nested helpers (closures capture `this`, `short`, `iniInitYear`, etc.) ──

        __editAdobeVer(ini, ctrl, *) {
            iniV := StrReplace(ini, A_Space, "_")
            if InStr(ctrl.Text, "v") && InStr(ctrl.Text, ".")
                this.UserSettings.%iniV% := ctrl.Text
        }

        __generateShortcut() => generateAdobeShortcut(this.UserSettings, shortcutName, year.text)

        __yearEventDropDown(*) {
            ver.Delete()
            jsonFolder := ptf.SupportFiles "\Release Assets\Adobe SymVers\Vers\" short
            if !DirExist(jsonFolder "\")
                errorLog(ValueError("Adobe json directory cannot be found", -1, jsonFolder),,, 1)
            supportedVersMap := json.parse(FileRead(jsonFolder "\v" SubStr(year.Text, 3, 2) ".json"))
            supportedVers := []
            for v in supportedVersMap
                supportedVers.Push(v)
            supportedVers := supportedVers.Sort("C").Reverse()
            ver.add(supportedVers)
            if !supportedVers.Has(1)
                return
            ver.Choose(1)
            this.UserSettings.%yearIniName% := year.text
            createTitle := "createShortcuts.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
            ignore := browser.vscode.winTitle
            if winExt.ExistRegex(createTitle,, ignore,, true)
                winExt.WaitCloseRegex(createTitle,,, ignore,, true)
            Run(ptf.Shortcuts "\createShortcuts.ahk false")
            __editAdobeVer(verIniName, ver)
        }

        __generateDropYear(program, &year, ctrlX) {
            if (program != "AE" && program != "Premiere" && program != "Photoshop")
                errorLog(ValueError("Incorrect value in Parameter #1", -1, program),,, 1)
            jsonFolder := ptf.SupportFiles "\Release Assets\Adobe SymVers\Vers\" short
            if !DirExist(jsonFolder "\")
                errorLog(ValueError("Adobe json directory cannot be found", -1, jsonFolder),,, 1)
            supportedYears := []
            loop files jsonFolder "\*", "F"
                supportedYears.Push(SubStr(A_Year, 1, 2) SubStr(A_LoopFileName, 2, 2))
            supportedYears := supportedYears.Sort("C").Reverse()
            try defaultIndex := supportedYears.IndexOf(iniInitYear)
            if !IsSet(defaultIndex) || defaultIndex = 0
                defaultIndex := 1
            year := adobeGui.AddDropDownList("x" ctrlX " y+-20 w100 Choose" defaultIndex, supportedYears)
            year.OnEvent("Change", __yearEventDropDown)
        }

        __generateDropVer(program, &ver, ctrlX) {
            if (program != "AE" && program != "Premiere" && program != "Photoshop")
                errorLog(ValueError("Incorrect value in Parameter #1", -1, program),,, 1)
            jsonFolder := ptf.SupportFiles "\Release Assets\Adobe SymVers\Vers\" short
            if !DirExist(jsonFolder "\")
                errorLog(ValueError("Adobe json directory cannot be found", -1, jsonFolder),,, 1)
            supportedVersMap := JSON.parse(FileRead(jsonFolder "\v" SubStr(iniInitYear, 3, 2) ".json"))
            supportedVers := []
            for v in supportedVersMap
                supportedVers.Push(v)
            supportedVers := supportedVers.Sort("C").Reverse()
            try defaultIndex := supportedVers.IndexOf(initVer)
            if !IsSet(defaultIndex) || defaultIndex = 0
                defaultIndex := 1
            ver := adobeGui.Add("DropDownList", "x" ctrlX " y+-20 w100 Choose" defaultIndex, supportedVers)
            doChange() {
                iniV := StrReplace(verIniName, A_Space, "_")
                if InStr(ver.Text, "v") && InStr(ver.Text, ".")
                    this.UserSettings.%iniV% := ver.Text
                imageLoc := ver.Text
            }
            ver.OnEvent("Change", (*) => doChange())
        }

        __cacheslct(progName, *) {
            WinSetAlwaysOnTop(0, "Settings " this.version)
            this.Gui.Opt("+Disabled")
            slct := FileSelect("D",, "Select " progName " Cache Folder")
            if slct = "" {
                if WinExist("Settings " this.version)
                    this.Gui.Opt("-Disabled")
                return
            }
            this.UserSettings.%cacheInit% := slct
            cache.Text := slct
            if WinExist("Settings " this.version)
                this.Gui.Opt("-Disabled")
        }
    }
}
