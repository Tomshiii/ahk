/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2026/11/12
 * @version 3.2.2
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk
#Include Classes\block.ahk
#Include Classes\null.ahk
#Include Classes\winExt.ahk
#Include Classes\errorLog.ahk
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Functions\isObjHasProp.ahk
#Include Other\UIA\UIA.ahk
#Include Other\Notify\Notify.ahk
; }

class premUIA_Values {
    /**
     * Panels tracked by this class.
     * Map key = UIA element name to search for.
     * `key`       - the name used in `UIA_Hwnd`
     * `type`      - UIA control type to match (default 50033 / pane)
     * `matchmode` - optional, eg "Substring" when the full name isn't static
     * `useParent` - optional, take the hwnd from the element's parent
     */
    static panels := Map(
        "Timeline",                 {key: "timelineWindow", type: 50033, useParent: true},
        "Effect Controls",          {key: "effectControls", type: 50033},
        "Effects",                  {key: "effectsWindow",  type: 50033},
        "Program Monitor",          {key: "programMonitor", type: 50033},
        "Source Monitor",           {key: "sourceMonitor",  type: 50033},
        "Tools",                    {key: "toolsWindow",    type: 50033},
        "Project:",                 {key: "projectsWindow", type: 50033, matchmode: "Substring"},
        ; "PremiereRemote",           {key: "premRemote",     type: 50019},
        "PremiereUnifiedHeaderTab", {key: "homeTab",        type: 50033}
    )
    static isRunning := false
    static beenSet   := false

    static UIA_Hwnd := Map()
    static allPanes := Map()
    static AdobeEl  := false
    static determineUIA_PID := false
    static scriptTitle := "determineUIA.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
    /** callback set by `determineUIA.ahk` so a remote `resetUIA()` can trigger a rebuild inside that process */
    static onRebuild := ""
    static currentVer {
        get => prem.__remoteUXP('properties/getPremVer')
    }

    static UIA_PREM_INACTIVE := 1048576
    static UIA_PREM_ACTIVE := 1048580

    static determineIcon {
        get {
            try return ptf.Icons "\determineUIA.ico"
            return ""
        }
    }
    static premIcon {
        get {
            try return ptf.Icons "\prprj.ico"
            return ""
        }
    }

    static KSA {
        get => CLSID_Objs.load("KSA")
    }
    static UserSettings {
        get => CLSID_Objs.load("UserSettings")
    }

    /** ms to wait after a failed search before looking for a closed panel again. Focus-driven matches ignore it */
    static resolveCooldown := 5000
    static __lastResolveTry := Map()

    ;// Tools
    static tools := Map(
        "selectionTool", "Selection Tool",
        "trackForward", ["Track Select Forward Tool", "Track Select Backward Tool"],
        "rippleEditTool", ["Ripple Edit Tool", "Rolling Edit Tool", "Rate Stretch Tool", "Remix Tool"],
        "razorTool", "Razor Tool",
        "slipTool", ["Slip Tool", "Slide Tool"],
        "penTool", "Pen Tool",
        "rectangleTool", ["Rectangle Tool", "Ellipse Tool", "Polygon Tool"],
        "handTool", ["Hand Tool", "Zoom Tool"],
        "textTool", ["Type Tool", "Vertical Type Tool"],
        "genAITool", ["Generative Media Tool", "Generative Extend Tool"],

        ;// the object selection drop down pre 27.0 only contained `"Tools.ObjectSelectionLasso_18"`
        "maskTool", ["Tools.ObjectMask", "Tools.EllipseMask", "Tools.RectangleMask", "Tools.PenMask", "Tools.HSLMask", "Tools.LuminanceMask"]
    )

    /**
     * reverse lookup of `panels` by its `key` field.
     * @param {String} key the panel key, eg "projectsWindow"
     * @returns {Object | false} `{name, opts}`
     */
    static __panelInfo(key) {
        for name, opts in this.panels {
            if opts.key = key
                return {name: name, opts: opts}
        }
        return false
    }

    /**
     * Resolves a panel that wasn't present during generation (or whose hwnd went stale) by searching the live Premiere window, then stores its hwnd in the shared object.
     * @param {String} key the panel key, eg "projectsWindow"
     * @param {ComObj} [UIAobj=unset] an already set prem UIA object. If not set `initialise()` will be called
     * @param {Boolean} [force=false] skip the "already stored" shortcut (use when a stored hwnd is stale)
     * @param {Boolean} [ignoreCooldown=false] skip the failed-search cooldown (use when something already proved the panel exists)
     * @returns {Boolean} true if the panel is now stored on the shared object
     */
    static resolvePanel(key, UIAobj?, force := false, ignoreCooldown := false) {
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl
            return false
        if !force && uiaEl.UIA_Hwnd.Has(key)
            return true
        if !info := this.__panelInfo(key)
            return false
        ;// a closed panel fails every time and the search is slow, so back off after a failure
        if !ignoreCooldown && this.__lastResolveTry.Has(key) && (A_TickCount - this.__lastResolveTry[key]) < this.resolveCooldown
            return false

        opts := info.opts
        try {
            try n := WinGet.PremName()
            title := (IsSet(n) && isObjHasProp(n, 'wintitle', false) && n.wintitle != "") ? n.wintitle A_Space prem.winTitle : prem.winTitle
            win  := UIA.ElementFromHandle(title,, false)
            cond := {Type: opts.type, Name: info.name}
            if opts.HasOwnProp("matchmode")
                cond.matchmode := opts.matchmode
            el   := win.FindElement(cond)
            hwnd := (opts.HasOwnProp("useParent") && opts.useParent) ? el.Parent.NativeWindowHandle : el.NativeWindowHandle
        } catch {
            this.__lastResolveTry[key] := A_TickCount
            return false
        }
        try
            uiaEl.UIA_Hwnd[key] := hwnd
        catch {
            this.__lastResolveTry[key] := A_TickCount
            return false
        }
        if this.__lastResolveTry.Has(key)
            this.__lastResolveTry.Delete(key)
        return true
    }

    /**
     * Fallback for `getActivePanelName()` when no ancestor's hwnd matched a stored panel. That happens when a panel wasn't open during generation, or was closed and reopened with a new hwnd. Matches the ancestors by type + name, then re-resolves the panel.
     * @param {ComObj} uiaEl an already set prem UIA object
     * @param {Array} chain the focused element and its ancestors, focused element first
     * @returns {String} the panel key, or "" if none matched
     */
    static __matchPanelByName(uiaEl, chain) {
        for el in chain {
            try elType := el.Type
            catch
                continue
            elName := ""
            gotName := false
            for pName, opts in this.panels {
                if opts.type != elType
                    continue
                if !gotName {
                    try elName := el.Name
                    catch
                        break
                    gotName := true
                }
                isMatch := (opts.HasOwnProp("matchmode") && opts.matchmode = "Substring") ? InStr(elName, pName) : (elName = pName)
                if isMatch && this.resolvePanel(opts.key, uiaEl, true, true)
                    return opts.key
            }
        }
        return ""
    }

    /**
     * Determine which tracked panel currently has focus
     * @param {ComObj} [UIAobj=unset] an already set prem UIA object. If not set `initialise()` will be called
     * @returns {Object|null} `null` if Premiere isn't active or the UIA object can't be set. Else an object containing;
     * ```
     * obj.uiaEl     ; the uia object returned by `initialise()`
     * obj.panel     ; the panel key (eg "effectControls") or "" if none matched
     * obj.focusedEl ; the focused UIA element, or "" if it couldn't be read
     * ```
     */
    static __activeElement(UIAobj?) {
        try n := WinGet.PremName()
        if !WinActive(prem.winTitle) && !WinActive(prem.class) && (IsSet(n) && isObjHasProp(n, 'wintitle', false) && n.wintitle != "") {
            return null
        }
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl
            return null
        try focusedEl := UIA.GetFocusedElement()
        panelName := IsSet(focusedEl) ? this.getActivePanelName(uiaEl, focusedEl) : ""
        return {uiaEl: uiaEl, panel: panelName, focusedEl: focusedEl ?? ""}
    }

    /**
     * Determines which known Premiere panel currently has UIA keyboard focus,
     * by climbing from the focused element up through native-window-backed
     * ancestors and matching against the panel hwnd map built during setObjs().
     * This avoids searching the (potentially stale) cached AdobeEl tree, since
     * deep/lazily-generated elements (eg an edit box only created once clicked
     * into) will never exist there - but their host panel's hwnd is stable.
     * @param {ComObj} [uiaEl] paramater to pass in an already set prem UIA object.
     * @param {UIA.IUIAutomationElement} [focusedEl=unset] the currently focused UIA Element. If not set this function will attempt to determine it.
     * @returns {String} the panel key (eg "effectControls") or "" if none matched
     */
    static getActivePanelName(uiaEl, focusedEl?) {
        if !IsSet(focusedEl) || !focusedEl {
            try focusedEl := UIA.GetFocusedElement()
            if !IsSet(focusedEl) || !focusedEl
                return ""
        }
        el := focusedEl
        chain := []
        Loop 20 {
            chain.Push(el)
            try hwnd := el.NativeWindowHandle
            catch
                hwnd := 0

            if hwnd {
                for panelName, storedHwnd in uiaEl.UIA_Hwnd {
                    if storedHwnd = hwnd
                        return panelName
                }
            }
            try parent := el.Parent
            catch
                break
            if !parent
                break
            el := parent
        }
        return this.__matchPanelByName(uiaEl, chain)
    }

    /**
     * Determines if a tracked panel is the one currently holding focus
     * @param {String} panelKey the panel key you wish to check, eg "projectsWindow". Must be one of the keys in `panels`
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @returns {Boolean | null} `null` if the UIA object can't be set or the key isn't tracked, else bool
     */
        static __isUiaElementActive(panelKey, UIAobj?) {
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl
            return null
        if !uiaEl.UIA_Hwnd.Has(panelKey) {
            if !this.__panelInfo(panelKey) {
                errorLog(MethodError("premUIA doesn't track the following panel: " panelKey, -2, panelKey))
                return null
            }
            if !this.resolvePanel(panelKey, uiaEl)
                return false ;// a tracked panel that can't be found isn't open, so it can't be active
        }
        try panel := this.__isPremPanelActive(panelKey, uiaEl)
        if IsSet(panel) && (panel = true || panel == null)
            return (panel = true ? true : null)
        return (this.getActivePanelName(uiaEl) = panelKey)
    }

    /**
     * Do a more basic check for premiere panel active status first to potentially return early by checking the `state` value. Generally a value of `4`/`1048580` mean a panel is active or `0`/`1048576` generally means it is inactive. This will not be comprehensive on its own as UIA elements are created/destroyed dynamically as the user interacts with the UI which may cause issues with accuracy of this function in some scenarios.
     * @param {String} [panel] the UIA element name you wish to check. Must be one of the elements tracked within this class.
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @returns {null | Boolean}
     */
    static __isPremPanelActive(panel, UIAobj?) {
        if !element := this.getLivePanel(panel, UIAobj?)
            return null
        return ((element.state = 4 || element.state = this.UIA_PREM_ACTIVE) ? true : false)
    }

    /**
     * syntatic sugar for creating a live `UIA.IUIAutomationElement` for the desired hwnd panel.
     * @param {String} [panel] the UIA element name you wish to check. Must be one of the elements tracked within this class.
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @param {ComObj} [uiaEal] pass back the `determineUIA` `UIA` comObj
     * @returns {UIA.IUIAutomationElement | false}
     */
    static getLivePanel(panel, UIAobj?, &uiaEl?) {
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl {
            errorLog(MethodError("uiaObject hadn't been initialised yet", -2))
            return false
        }
        tracked := this.__panelInfo(panel)
        if !uiaEl.UIA_Hwnd.Has(panel) && !this.resolvePanel(panel, uiaEl) {
            if !tracked
                errorLog(MethodError("premUIA doesn't currently store the following panel: " panel, -2, panel))
            return false
        }
        try return UIA.ElementFromHandle(uiaEl.UIA_Hwnd[panel],, false)
        ;// stored hwnd is stale, try once more from scratch (respects the cooldown)
        if this.resolvePanel(panel, uiaEl, true) {
            try return UIA.ElementFromHandle(uiaEl.UIA_Hwnd[panel],, false)
        }
        if !tracked
            errorLog(MethodError("failed to generate live UIA panel for the following panel: " panel, -2, panel))
        return false
    }

    /** sets a class param with a map containing all open `pane` windows with their coords */
    static __setAllPanes() {
        el := this.AdobeEl.FindCachedElements({type: 50033}, 2)
        for i, v in el {
            this.allPanes.Set(v.NativeWindowHandle, {x: v.location.x, y: v.location.y, w: v.location.w, h: v.location.h})
        }
    }

    /** sets all UIA panels */
    static __setAllPanels() {
        notSet := ""
        for panel, opts in this.panels {
            try {
                cond := {Type: opts.type, Name: panel}
                if opts.HasOwnProp("matchmode")
                    cond.matchmode := opts.matchmode

                el := this.AdobeEl.FindCachedElement(cond)
                this.UIA_Hwnd[opts.key] := (opts.HasOwnProp("useParent") && opts.useParent)
                    ? el.Parent.NativeWindowHandle
                    : el.NativeWindowHandle
            } catch {
                errorLog(ValueError("Determining panel: " panel " failed. It may not be visible.", -1))
                notSet .= (notSet = "") ? panel : ", " panel
                continue
            }
        }
        if notSet != ""
            notifyExt.showIfNotExist('UIApanelsFailed',, "Determining the following panels failed: " notSet "`nThey may not be visible.`nYou *may* still be able to generate live references once you show the panel.", this.determineIcon,,, "pos=BC dur=8 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
    }

    /**
     * Returns a live tools panel element. Uses the stored hwnd if there is one (and it's still valid),
     * otherwise searches the live Premiere window for the panel and stores its hwnd, so a panel opened
     * after `setObjs()` ran (or reopened with a new hwnd) still works.
     * @param {ComObj} [UIAobj=unset] an already set prem UIA object. If not set `initialise()` will be called
     * @returns {UIA.IUIAutomationElement | false}
     */
    static getLiveToolsPanel(UIAobj?, &uiaEl?) {
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl
            return false

        if !uiaEl.UIA_Hwnd.Has("toolsWindow") && !this.resolvePanel("toolsWindow", uiaEl)
            return (errorLog(MethodError("Failed to find the Tools panel. It may not be visible.", -2)), false)
        try return UIA.ElementFromHandle(uiaEl.UIA_Hwnd["toolsWindow"],, false)
        if this.resolvePanel("toolsWindow", uiaEl, true) {
            try return UIA.ElementFromHandle(uiaEl.UIA_Hwnd["toolsWindow"],, false)
        }
        return false
    }

    /**
     * Creates a live `UIA.IUIAutomationElement` for a tool slot, so properties like `.value` are current.
     * @param {String} tool the tool slot name, eg "razorTool" (a key of `tools`)
     * @param {ComObj} [UIAobj=unset] an already set prem UIA object. If not set `initialise()` will be called
     * @returns {UIA.IUIAutomationElement | false}
     */
    static getLiveTool(tool, UIAobj?) {
        if !this.tools.Has(tool) {
            errorLog(MethodError("premUIA doesn't track the following tool: " tool, -2, tool))
            return false
        }
        if !toolsPanel := this.getLiveToolsPanel(UIAobj?, &uiaEl)
            return false

        names := this.tools[tool]
        ;// `setObjs()` adjusts `maskTool` on the shared object for pre 27.0. That's a plain string, which survives COM, unlike the arrays
        if tool = "maskTool" {
            try shared := uiaEl.tools["maskTool"]
            if IsSet(shared) && Type(shared) = "String"
                names := shared
        }

        ;// the group buttons rename themselves to the active sub-tool, so match any of the possible names (an array is built into an "or" condition by UIA)
        try return toolsPanel.FindElement({Type:50000, Name: names, matchmode:"Substring"})
        errorLog(MethodError("failed to generate live UIA tool for the following tool: " tool, -2, tool))
        return false
    }

    /**
     * Checks the currently open panels and their coordinates and checks them against the saved map to determine if they have been moved.
     * @param {ComObj} [determineObj=unset] paramater to pass in an already set `determineUIA` UIA object. If not set will be determined
     * @returns {null | boolean}
     */
    static __checkPanes(determineObj?) {
        __getDetermine() {
            try return CLSID_Objs.loadProp("determineUIA", "allPanes")
            catch {
                return null
            }
        }
        uiaEl := IsSet(determineObj) ? determineObj.allPanes : __getDetermine()
        if uiaEl == null || !uiaEl
            return null
        for k, v in uiaEl {
            try check := UIA.ElementFromHandle(k,, false)
            catch {
                if !WinExist(k)
                    return false
                return null ;// panel may be updating/busy
            }
            tempObj := {x: check.location.x, y: check.location.y, w: check.location.w, h: check.location.h}
            if !obj.isEqual(tempObj, v)
                return false
        }
        return true
    }

    static toolsMap := Map(
        "Selection Tool", {uia: "selectionTool", ksa: "selectionTool"},
        "Track Select Forward Tool", {uia: "trackForward", ksa: "trackForward"},
        "Track Select Backward Tool", {uia: "trackForward", ksa: "trackBackward"},
        "Ripple Edit Tool", {uia: "rippleEditTool", ksa: "rippleEditTool"},
        "Rolling Edit Tool", {uia: "rippleEditTool", ksa: "rollingEditTool"},
        "Rate Stretch Tool", {uia: "rippleEditTool", ksa: "rateStretchTool"},
        "Remix Tool", {uia: "rippleEditTool", ksa: "remixTool"},
        "Razor Tool", {uia: "razorTool", ksa: "razorTool"},
        "Slip Tool", {uia: "slipTool", ksa: "slipTool"},
        "Slide Tool", {uia: "slipTool", ksa: "slideTool"},
        "Pen Tool", {uia: "penTool", ksa: "penTool"},
        "Rectangle Tool", {uia: "rectangleTool", ksa: "rectangleTool"},
        "Ellipse Tool", {uia: "rectangleTool", ksa: "ellipseTool"},
        "Polygon Tool", {uia: "rectangleTool", ksa: "polygonTool"},
        "Tools.ObjectSelectionLasso_18", {uia: "maskTool", ksa: "objectMaskTool"},
        "Tools.ObjectMask", {uia: "maskTool", ksa: "objectMaskTool"},
        "Tools.EllipseMask", {uia: "maskTool", ksa: "ellipseMaskTool"},
        "Tools.RectangleMask", {uia: "maskTool", ksa: "rectangleMaskTool"},
        "Tools.PenMask", {uia: "maskTool", ksa: "penMaskTool"},
        "Tools.HSLMask", {uia: "maskTool", ksa: "hslMaskTool"},
        "Tools.LuminanceMask", {uia: "maskTool", ksa: "luminanceMaskTool"},
        "Hand Tool", {uia: "handTool", ksa: "handTool"},
        "Zoom Tool", {uia: "handTool", ksa: "zoomTool"},
        "Type Tool", {uia: "textTool", ksa: "textTool"},
        "Vertical Type Tool", {uia: "textTool", ksa: "vertTextTool"},
        "Generative Media Tool", {uia: "genAITool", ksa: "genAITool"},
        "Generative Extend Tool", {uia: "genAITool", ksa:"genExtendTool"}
    )

    /** clears the stored UIA elements/handles. Flags live on the shared object, see `__setShared()` */
    static wipe() {
        this.AdobeEl   := false
        this.UIA_Hwnd  := Map()
        this.allPanes  := Map()
    }

    /**
     * sets `isRunning`/`beenSet` on the shared (registered) object, which is what other scripts read.
     * Falls back to this class if the shared object can't be loaded.
     */
    static __setShared(isRunning, beenSet) {
        try {
            shared := CLSID_Objs.load("determineUIA")
            shared.isRunning := isRunning
            shared.beenSet   := beenSet
            return
        }
        this.isRunning := isRunning
        this.beenSet   := beenSet
    }

    /**
     * Remote entry point. Wipes the stale values, then schedules a rebuild and returns immediately, so the calling script isn't blocked (or RPC timed out) while `setObjs()` runs. Additionally attempts to reset `Premiere` timeline values.
     * @returns {Boolean} false if a build is already in progress, or there's nothing to run the rebuild
     */
    static resetUIA() {
        if !this.onRebuild
            return false
        try shared := CLSID_Objs.load("determineUIA")
        catch
            return false
        if shared.isRunning
            return false
        this.wipe()
        shared.beenSet   := false
        shared.isRunning := true
        try {
            active := CLSID_Objs.load("determineActive")
            active.isRunning := true
            active := ""
        }
        try {
            premObj := CLSID_Objs.load("prem")
            premObj.timelineVals := false
            premObj.__setTimelineValues()
        }
        SetTimer(this.onRebuild, -1)
        return true
    }

    /** call from any script. Falls back to relaunching `determineUIA.ahk` if its COM object is unreachable */
    static forceReset() {
        try return CLSID_Objs.load("determineUIA").resetUIA()
        try this.closeUIA()       ;// kills it if it's running
        ;// give the process time to fully exit, otherwise `initialise()` can still see the dying script and try to reload it
        endTime := A_TickCount + 3000
        while this.determineUIA_Exist() && A_TickCount < endTime
            Sleep 50
        return this.initialise()  ;// relaunches it (returns false while it builds)
    }

    /** sets UIA objects */
    static setObjs() {
        Critical('On')
        notifyExt.deleteIfExist("premUIAGenTree",, 0)
        notifyExt.deleteIfExist("premUIAGenTreeWarning",, 0)
        notifyExt.deleteIfExist("UIAretrieveComplete",, 0)
        notifyExt.deleteIfExist("UIApanelsFailed",, 0)
        if !Notify.Exist("premUIAGenTree") {
            Notify.Show(, 'Generating Premiere UIA tree... This may take a while.`nPremiere may appear unresponsive until this process has completed.', this.premIcon,,, 'dur=0 bdr=Maroon show=Fade@150 hide=Fade@250 maxW=400 tag=premUIAGenTree')
        }
        __DelNotify() => (notifyExt.deleteIfExist("premUIAGenTree",, 0), notifyExt.deleteIfExist("premUIAGenTreeWarning",, 0))
        try premName := WinGet.PremName()
        if (!isObjHasProp(premName, 'titleCheck', false) && isObjHasProp(premName, 'titleCheck', null)) || premName.titleCheck != true {
            __DelNotify()
            throw Error("Failed to retrieve Premiere title.")
        }
        remoteUXPState := CLSID_Objs.loadProp("prem", "remoteActiveUXP")
        if remoteUXPState = "loading" {
            __DelNotify()
            throw Error("Socket")
        }
        if !remoteUXPState {
            __DelNotify()
            errorLog(Error("A socket connection could not be established", -1),, true)
            throw Error("Socket")
        }

        currentVer := this.currentVer
        if currentVer == null {
            __DelNotify()
            throw Error("Socket")
        }
        if !currentVer {
            __DelNotify()
            throw Error("Failed to return Premiere Version")
        }
        if VerCompare(currentVer, prem.minVer) < 0 {
            __DelNotify()
            throw MethodError("This version of Premiere is not supported.`nThe minimum supported version is: " prem.minVer "`nThe user has: " currentVer)
        }
        switch {
            ;// in versions lower than 27.0 all items in the Object Mask dropdown were simply called `Tools.ObjectSelectionLasso_18`
            case VerCompare(currentVer, "v27.0") < 0: this.tools["maskTool"] := "Tools.ObjectSelectionLasso_18"
        }

        try {
            if !prem.isEditTabActive() {
                __DelNotify()
                throw UnsetError("throw code:719")
            }
            premCacheRequest := UIA.CreateCacheRequest(["Type", "Name", "BoundingRectangle"],, "Descendants")
            try {
                try n := winget.PremName()
                title := (IsSet(n) && isObjHasProp(n, 'wintitle', false) && n.wintitle != "") ? n.wintitle A_Space prem.winTitle : prem.winTitle
                this.AdobeEl := UIA.ElementFromHandle(title, premCacheRequest, false)
            } catch {
                __DelNotify()
                throw UnsetError("throw code:701")
            }
            this.__setAllPanes()
            this.__setAllPanels()
        } catch as e {
            try errorLog(Error(e.Message, e.What, e.Extra))
            __DelNotify()
            this.wipe()
            this.__setShared(false, false)
            throw ValueError(e.Message,, e.Extra)
        }

        __DelNotify()
        notifyExt.deleteIfExist("determiningUIA",, 0)
        notifyExt.showIfNotExist("UIAretrieveComplete",, "Retrieving UIA Coordinates is now complete.", this.premIcon,,, 'dur=3 bdr=0x5B009F show=Fade@225 hide=Fade@250 maxW=400')
        return true
    }

    /**
     * Determines if `determineUIA.ahk` is open
     * @returns {Boolean}
     */
    static determineUIA_Exist() {
        scriptTitle := winExt.TitleRegex(this.scriptTitle,,,, true)
        if !scriptTitle
            return false
        if !winExt.ExistRegex(this.scriptTitle,,,, true)
            return false
        return true
    }

    /** closes `determineUIA.ahk` */
    static closeUIA() {
        if !this.determineUIA_Exist()
            return true
        scriptTitle := winExt.TitleRegex(this.scriptTitle,,,, true)
        PID := winExt.PIDRegex(this.scriptTitle,,,, true)
        if PID {
            try ProcessClose(PID)
            ;// `ProcessWaitClose` returns the PID if the process still exists after the timeout, else 0
            if ProcessWaitClose(PID, 2)
                return false
        }
        if winExt.ExistRegex(scriptTitle,,,, true)
            return false
        return true
    }

    static scriptLoc := ptf.SupportFiles "\determineUIA.ahk"
    /**
     * Determines if UIA objects have been set and returns them if they have. If not, `determineUIA.ahk` will be run and this function will return early.
     * @returns {false|ComObject}
     */
    static initialise() {
        Critical('On')
        if !FileExist(this.scriptLoc) {
            errorLog(MethodError("Script location doesn't exist."))
            Critical('Off')
            return false
        }
        determineUIAExist := this.determineUIA_Exist()
        if !determineUIAExist {
            Run(this.scriptLoc)
            Critical('Off')
            return false
        }

        try uiaObj := CLSID_Objs.load("determineUIA")
        catch {
            try {
                isRunning := CLSID_Objs.loadProp("determineActive", "isRunning")
                if isRunning = true {
                    errorLog(MethodError("Initialising UIA Object is already in progress."))
                    return false
                }
            }
            errorLog(TargetError("Script could not interact with ``determineUIA.ahk``. Script will reload.", -1))
            if this.closeUIA()
                Run(ptf.SupportFiles "\determineUIA.ahk")
            return false
        }
        switch {
            case uiaObj.isRunning:
                notifyExt.showIfNotExist("determiningUIA",, "UIA Coordinates are currently waiting to be determined", this.determineIcon,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
                Critical('Off')
                return false
            case uiaObj.beenSet && !uiaObj.isRunning:
                Critical('Off')
                return uiaObj
            default:
                ;// registered but not yet started - shouldn't normally happen
                errorLog(MethodError("Initialising UIA Object seemingly failed."))
                Critical('Off')
                return false
        }
    }
}