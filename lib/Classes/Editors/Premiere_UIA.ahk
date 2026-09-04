/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2026/09/04
 * @version 3.0.29
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk
#Include Classes\switchTo.ahk
#Include Classes\block.ahk
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Functions\isObjHasProp.ahk
#Include Other\UIA\UIA.ahk
#Include Other\Notify\Notify.ahk
; }

class premUIA_Values {
    ;// current panels;
    ;// All below native panels require a hotkey set within Premiere to activate
        ;// timelineWindow  - Timeline Panel
        ;// effectControls  - Effect Controls Panel
        ;// effectsWindow   - Effects Panel
        ;// programMonitor  - Program Monitor
        ;// sourceMonitor   - Source Monitor
        ;// toolsWindow     - Tools Panel
        ;// projectsWindow  - Project Panel
        ;// premRemote      - PremiereRemote Extension
    static isRunning := false
    static beenSet   := false

    static UIA_Objs := Map()
    static UIA_Path := Map()
    static UIA_Hwnd := Map()
    static AdobeEl  := false
    static determineUIA_PID := false

    static KSA {
        get => CLSID_Objs.load("KSA")
    }
    static UserSettings {
        get => CLSID_Objs.load("UserSettings")
    }

    /**
     * Determine the UIA path of the active element
     * @param {Boolean} [returnObj=false] determines whether the function returns an object containing multiple useful elements or just the UIA path as a string
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @returns {String|Object|-1} if UIA element is unable to be set, will return `-1`. Else, depending on bool state of `returnObj` will either return a string containing just the UIA path string, or an object containing;
     * ```
     * obj := premUIA_Values(true)
     * obj.uiaEl     ; the uia object returned by `initialise()`
     * obj.Path      ; the UIA path of the active element
     * obj.focusedEl ; the UIA element object itself
     * ```
     */
    static __activeElementPath(returnObj := false, UIAobj?) {
        try n := WinGet.PremName()
        if !WinActive(prem.winTitle) && !WinActive(prem.class) && (IsSet(n) && isObjHasProp(n, 'wintitle', false) && n.wintitle != "") {
            return -1
        }
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl
            return -1
        try focusedEl := UIA.GetFocusedElement()
        panelName   := IsSet(focusedEl) ? this.getActivePanelName(uiaEl, focusedEl) : ""
        focusedPath := (panelName != "" && uiaEl.UIA_Path.Has(panelName)) ? uiaEl.UIA_Path[panelName] : ""

        return ((returnObj = false) ? focusedPath : {uiaEl: uiaEl, Path: focusedPath, focusedEl: focusedEl})
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
        Loop 20 {
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
        return ""
    }

    /**
     * Determines if a given UIA element path is the current active UIA element
     * @param {String} [elementPath] the UIA element path you wish to check. May also be a panel name that is tracked within this class.
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @returns {Trilean} returns `-1` if UIA object is unable to be set, else returns bool
     */
    static __isUiaElementActive(elementPath, UIAobj?) {
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl
            return -1
        if uiaEl.UIA_Hwnd.Has(elementPath) {
            try panel := this.__isPremPanelActive(elementPath, uiaEl)
            if IsSet(panel) && panel = true
                return true
        }
        focusedPath := this.__activeElementPath(true, (IsSet(UIAobj) ? UIAobj : ""))
        if !isObjHasProp(focusedPath, 'Path', -1) || focusedPath.Path = -1
            return -1
        return (IsSet(UIAobj) ? (InStr(focusedPath.Path, UIAobj.UIA_Path[elementPath]) = 1) : (InStr(focusedPath.Path, focusedPath.uiaEl.UIA_Path[elementPath]) = 1))
    }

    /**
     * Do a more basic check for premiere panel active status first to potentially return early by checking the `state` value. Generally a value of `4`/`1048580` mean a panel is active or `0`/`1048576` generally means it is inactive. This will not be comprehensive on its own as UIA elements are created/destroyed dynamically as the user interacts with the UI which may cause issues with accuracy of this function in some scenarios.
     * @param {String} [panel] the UIA element name you wish to check. Must be one of the elements tracked within this class.
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @returns {-1 | Boolean}
     */
    static __isPremPanelActive(panel, UIAobj?) {
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl || !uiaEl.UIA_Hwnd.Has(panel)
            return -1
        try element := UIA.ElementFromHandle(uiaEl.UIA_Hwnd[panel],, false)
        catch {
            return -1
        }
        UIA_PREM_INACTIVE := 1048576
        UIA_PREM_ACTIVE := 1048580
        return ((element.state = 4 || element.state = UIA_PREM_ACTIVE) ? true : false)
    }

    /**
     * Determines whether a given premiere tool is currently selected (using a UIA element)
     * @param {String} [tool] the name of the tool you wish to check. Tool names are listed below
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @returns {-1 | Boolean} returns `-1` when; Premiere window cannot be determined, Premiere window is not active, or UIA object is unable to be set, else returns `true`/`false`
     * ```
     * "selectionTool", "Selection Tool",
     * "trackForward", ["Track Select Forward Tool", "Track Select Backward Tool"],
     * "rippleEdit", ["Ripple Edit Tool", "Rolling Edit Tool", "Rate Stretch Tool", "Remix Tool"],
     * "razorTool", "Razor Tool",
     * "slipTool", ["Slip Tool", "Slide Tool"],
     * "penTool", "Pen Tool",
     * "rectangleTool", ["Rectangle Tool", "Ellipse Tool", "Polygon Tool"],
     * "handTool", ["Hand Tool", "Zoom Tool"],
     * "textTool", ["Type Tool", "Vertical Type Tool"]
     * ```
     */
    static isToolSelected(tool, UIAobj?) {
        try n := WinGet.PremName()
        if !WinActive(prem.winTitle) && !WinActive(prem.class) && (IsSet(n) && isObjHasProp(n, 'wintitle', false) && n.wintitle != "") {
            return -1
        }
        uiaEl := IsSet(UIAobj) ? UIAobj : this.initialise()
        if !uiaEl
            return -1
        try returnVal := (uiaEl.UIA_Objs[tool].value = "Selected" ? true : false)
        return (IsSet(returnVal) && (returnVal = true || returnVal = false) ? returnVal : -1)
    }

    /** sets UIA objects */
    static setObjs() {
        Critical('On')
        notifyExt.deleteIfExist("premUIAGenTree")
        notifyExt.deleteIfExist("premUIAGenTreeWarning")
        notifyExt.deleteIfExist("UIAretrieveComplete")
        notifyExt.deleteIfExist("determineUIAFailed")
        if !Notify.Exist("premUIAGenTree") {
            img := ptf.Icons "\prprj.ico"
            /* Notify.Show(, 'Premiere must remain as the active window during this process.', img,,, 'dur=0 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400 tag=premUIAGenTreeWarning') */
            Notify.Show(, 'Generating Premiere UIA tree... This may take a while.`nPremiere may appear unresponsive until this process has completed.', img,,, 'dur=0 bdr=Maroon show=Fade@150 hide=Fade@250 maxW=400 tag=premUIAGenTree')
        }

        try premName := WinGet.PremName()
        if (!isObjHasProp(premName, 'titleCheck', false) && isObjHasProp(premName, 'titleCheck', -1)) || premName.titleCheck != true {
            notifyExt.deleteIfExist("premUIAGenTree")
            notifyExt.deleteIfExist("premUIAGenTreeWarning")
            throw Error("Failed to retrieve Premiere title.")
        }
        premObj := CLSID_Objs.clone("prem")
        if premObj.remoteActiveCEP = "loading" {
            notifyExt.deleteIfExist("premUIAGenTree")
            notifyExt.deleteIfExist("premUIAGenTreeWarning")
            throw Error("Socket")
        }
        if !premObj.remoteActiveCEP {
            notifyExt.deleteIfExist("premUIAGenTree")
            notifyExt.deleteIfExist("premUIAGenTreeWarning")
            errorLog(Error("A socket connection could not be established", -1),, true)
            throw Error("Socket")
        }

        currentVer := prem.__remoteFunc('premVer', true)
        if !currentVer
            throw Error("Failed to return Premiere Version")
        if VerCompare(currentVer, prem.minVer) < 0 {
            notifyExt.deleteIfExist("premUIAGenTree")
            notifyExt.deleteIfExist("premUIAGenTreeWarning")
            throw MethodError("This version of Premiere is not supported.`nThe minimum supported version is: " prem.minVer "`nThe user has: " currentVer)
        }
        __TryCatchUIAobj(name, objOrPath, errorCode, pathName := "") {
            try {
                switch objOrPath {
                    case "obj":  temp := this.AdobeEl.FindCachedElement({Type:50033, Name:name})
                    case "path":
                        switch pathName {
                            case "timelineWindow":temp := this.AdobeEl.GetUIAPath(this.UIA_Objs[pathName], true), this.UIA_Hwnd[pathName] := this.UIA_Objs[pathName].Parent.NativeWindowHandle
                            default: temp := this.AdobeEl.GetUIAPath(this.UIA_Objs[pathName], true), this.UIA_Hwnd[pathName] := this.UIA_Objs[pathName].NativeWindowHandle
                        }

                    case "premObj": temp := this.AdobeEl.FindCachedElement({Type:50033, Type:50019, Name:name})
                    case "projObj": temp := this.AdobeEl.FindCachedElement({Type:50033, Name:name, matchmode:"Substring"})
                }
                return temp
            } catch {
                throw UnsetError("throw code:" errorCode,, errorCode)
            }
        }
        try {
            if !WinActive(prem.winTitle) && !WinActive(prem.class)
                switchTo.Premiere()
            blocker := block_ext()
            blocker.On()
            SendInput(ksa.prem.shuttleStop)
            keys := ["effectControls", "effectsWindow", "programMonitor", "sourceMonitor", "toolsWindow", "projectsWindow", "timelineWindow"]
            for v in keys {
                SendInput(ksa.prem.%v%)
                sleep 25
            }
            blocker.Off()
            premCacheRequest := UIA.CreateCacheRequest(["Type", "Name", "Value", "ClassName", "AutomationId", "BoundingRectangle"],, "Descendants") ;// all necessary for `GetUIAPath()`
            try {
                try n := winget.PremName()
                title := (IsSet(n) && isObjHasProp(n, 'wintitle', false) && n.wintitle != "") ? n.wintitle A_Space prem.winTitle : prem.winTitle
                this.AdobeEl := UIA.ElementFromHandle(title, premCacheRequest, false)
            } catch {
                throw UnsetError("throw code:701")
            }

            this.UIA_Objs["timelineWindow"]  := __TryCatchUIAobj("Timeline", "obj", "702")
            this.UIA_Path["timelineWindow"]  := __TryCatchUIAobj("Timeline", "path", "702", "timelineWindow")
            this.UIA_Objs["effectControls"]  := __TryCatchUIAobj("Effect Controls", "obj", "703")
            this.UIA_Path["effectControls"]  := __TryCatchUIAobj("Effect Controls", "path", "703", "effectControls")
            this.UIA_Objs["effectsWindow"]   := __TryCatchUIAobj("Effects", "obj", "704")
            this.UIA_Path["effectsWindow"]   := __TryCatchUIAobj("Effects", "path", "704", "effectsWindow")
            this.UIA_Objs["programMonitor"]  := __TryCatchUIAobj("Program Monitor", "obj", "705")
            this.UIA_Path["programMonitor"]  := __TryCatchUIAobj("Program Monitor", "path", "705", "programMonitor")
            this.UIA_Objs["sourceMonitor"]   := __TryCatchUIAobj("Source Monitor", "obj", "706")
            this.UIA_Path["sourceMonitor"]   := __TryCatchUIAobj("Source Monitor", "path", "706", "sourceMonitor")
            this.UIA_Objs["toolsWindow"]     := __TryCatchUIAobj("Tools", "obj", "707")
            this.UIA_Path["toolsWindow"]     := __TryCatchUIAobj("Tools", "path", "707", "toolsWindow")
            this.UIA_Objs["projectsWindow"]  := __TryCatchUIAobj("Project:", "projObj", "708")
            this.UIA_Path["projectsWindow"]  := __TryCatchUIAobj("Project:", "path", "708", "projectsWindow")
            this.UIA_Objs["premRemote"]      := __TryCatchUIAobj("PremiereRemote", "premObj", "709")
            this.UIA_Path["premRemote"]      := __TryCatchUIAobj("PremiereRemote", "path", "709", "premRemote")
            ; this.UIA_Objs["homeTab"]         := __TryCatchUIAobj("PremiereUnifiedHeaderTab", "obj", "719")
            ; this.UIA_Objs["homeTab"]         := __TryCatchUIAobj("PremiereUnifiedHeaderTab", "path", "719", "homeTab")
            ;// Tools
            tools := Map(
                "selectionTool", "Selection Tool",
                "trackForward", ["Track Select Forward Tool", "Track Select Backward Tool"],
                "rippleEdit", ["Ripple Edit Tool", "Rolling Edit Tool", "Rate Stretch Tool", "Remix Tool"],
                "razorTool", "Razor Tool",
                "slipTool", ["Slip Tool", "Slide Tool"],
                "penTool", "Pen Tool",
                "rectangleTool", ["Rectangle Tool", "Ellipse Tool", "Polygon Tool"],
                "handTool", ["Hand Tool", "Zoom Tool"],
                "textTool", ["Type Tool", "Vertical Type Tool"]
            )
            for k, v in tools {
                switch Type(v), false {
                    case "Array":
                        for v2 in v {
                            try this.UIA_Objs[k] := this.AdobeEl.FindCachedElement({Type:50000,  Name: v2, matchmode:"Substring"})
                            catch {
                                continue
                            }
                            try this.UIA_Path[k] := this.AdobeEl.GetUIAPath(this.UIA_Objs[k], true)
                            catch {
                                errorLog(UnsetError("Failed to find tool: " k))
                                throw(UnsetError("Failed to find tool: " k))
                            }
                        }
                    default:
                        try {
                            this.UIA_Objs[k] := this.AdobeEl.FindCachedElement({Type:50000,  Name: v, matchmode:"Substring"})
                            this.UIA_Path[k] := this.AdobeEl.GetUIAPath(this.UIA_Objs[k], true)
                        } catch {
                            errorLog(UnsetError("Failed to find tool: " k))
                            throw(UnsetError("Failed to find tool: " k))
                        }
                }
            }
        } catch as e {
            try errorLog(Error(e.Message, e.What, e.Extra))
            notifyExt.deleteIfExist("premUIAGenTree")
            notifyExt.deleteIfExist("premUIAGenTreeWarning")
            this.AdobeEl   := false
            this.UIA_Objs  := Map()
            this.UIA_Path  := Map()
            this.beenSet := false
            this.isRunning := false
            throw ValueError(e.Message,, e.Extra)
        }

        notifyExt.deleteIfExist("premUIAGenTree")
        notifyExt.deleteIfExist("premUIAGenTreeWarning")
        notifyExt.deleteIfExist("determiningUIA")
        notifyExt.showIfNotExist("UIAretrieveComplete",, "Retrieving UIA Coordinates is now complete.", img,,, 'dur=3 bdr=0x5B009F show=Fade@225 hide=Fade@250 maxW=400')
        return true
    }

    /**
     * Determines if `determineUIA.ahk` is open
     * @returns {Boolean}
     */
    static determineUIA_Exist() {
        try {
            ComObjActive(CLSID_Objs["determineUIA"])
            return true
        } catch {
            title := "determineUIA.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
            scriptTitle := winExt.TitleRegex(title,,,, true)
            if !scriptTitle
                return false
            if !winExt.ExistRegex(scriptTitle,,,, true)
                return false
            return true
        }
    }

    /**
     * Determines if UIA objects have been set and returns them if they have. If not, `determineUIA.ahk` will be run and this function will return early.
     * @returns {false|ComObject}
     */
    static initialise() {
        Critical('On')
        scriptLoc := ptf.SupportFiles "\determineUIA.ahk"
        determineUIAExist := this.determineUIA_Exist()

        if !determineUIAExist {
            Run(scriptLoc)
            Critical('Off')
            return false
        }

        try uiaObj := CLSID_Objs.load("determineUIA")
        catch {
            try {
                coreIsActive := CLSID_Objs.load("determineActive")
                if coreIsActive.isRunning = true
                    return false
            }
            errorLog(TargetError("Script could not interact with ``determineUIA.ahk``. Script will reload.", -1))
            try WM.Send_WM_COPYDATA("determineUIA_exitapp", "determineUIA.ahk")
            sleep 100
            if determineScript := winExt.ExistRegex("determineUIA.ahk ahk_class AutoHotkey",,,, true)
                try winExt.CloseRegex(determineScript,,,, true)
            sleep 500
            if determineScript := winExt.ExistRegex("determineUIA.ahk ahk_class AutoHotkey",,,, true)
                return false
            Run(ptf.SupportFiles "\determineUIA.ahk")
            return false
        }
        switch {
            case uiaObj.isRunning:
                notifyExt.showIfNotExist("determiningUIA",, "UIA Coordinates are currently waiting to be determined",,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
                Critical('Off')
                return false
            case uiaObj.beenSet && !uiaObj.isRunning:
                Critical('Off')
                return uiaObj
            default:
                ;// registered but not yet started - shouldn't normally happen
                Critical('Off')
                return false
        }
    }
}