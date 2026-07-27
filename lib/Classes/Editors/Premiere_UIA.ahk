/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2026/07/27
 * @version 3.0.25
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
        focusedEl := UIA.GetFocusedElement()
        try focusedPath := uiaEl.AdobeEl.GetUIAPath(focusedEl, true)
        return ((returnObj = false) ? focusedPath ?? "" : {uiaEl: uiaEl, Path: focusedPath ?? "", focusedEl: focusedEl})
    }

    /**
     * Determines if a given UIA element path is the current active UIA element
     * @param {String} [elementPath] the UIA element path you wish to check
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @returns {Trilean} returns `-1` if UIA object is unable to be set, else returns bool
     */
    static __isUiaElementActive(elementPath, UIAobj?) {
        focusedPath := this.__activeElementPath(true, (IsSet(UIAobj) ? UIAobj : ""))
        if !isObjHasProp(focusedPath, 'Path', -1) || focusedPath.Path = -1
            return -1
        return (IsSet(UIAobj) ? (InStr(focusedPath.Path, UIAobj.UIA_Path[elementPath]) = 1) : (InStr(focusedPath.Path, focusedPath.uiaEl.UIA_Path[elementPath]) = 1))
    }

    /**
     * Determines whether a given premiere tool is currently selected (using a UIA element)
     * @param {String} [tool] the name of the tool you wish to check. Tool names are listed below
     * @param {ComObj} [UIAobj=unset] paramater to pass in an already set prem UIA object. If not set `initialise()` will be called
     * @returns {Trilean} returns `-1` if UIA object is unable to be set, else returns bool
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
                    case "obj":  temp := this.AdobeEl.FindCachedElement({LocalizedType:"pane", Name:name})
                    case "path":
                        switch pathName {
                            case "timelineWindow":temp := this.AdobeEl.GetUIAPath(this.UIA_Objs[pathName], true), this.UIA_Hwnd[pathName] := this.UIA_Objs[pathName].Parent.NativeWindowHandle
                            default: temp := this.AdobeEl.GetUIAPath(this.UIA_Objs[pathName], true), this.UIA_Hwnd[pathName] := this.UIA_Objs[pathName].NativeWindowHandle
                        }

                    case "premObj": temp := this.AdobeEl.FindCachedElement({LocalizedType:"pane", LocalizedType:"tab item", Name:name})
                    case "projObj": temp := this.AdobeEl.FindCachedElement({LocalizedType:"pane", Name:name, matchmode:"Substring"})
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
            SendInput(ksa.shuttleStop)
            keys := ["effectControls", "effectsWindow", "programMonitor", "sourceMonitor", "toolsWindow", "projectsWindow", "timelineWindow"]
            for v in keys {
                SendInput(ksa.%v%)
                sleep 25
            }
            blocker.Off()
            premCacheRequest := UIA.CreateCacheRequest(["LocalizedType", "Type", "Name", "Value", "ClassName", "AutomationId", "BoundingRectangle"],, "Descendants") ;// all necessary for `GetUIAPath()`
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
                            try this.UIA_Objs[k] := this.AdobeEl.FindCachedElement({Type:"Button", LocalizedType:"button",  Name: v2, matchmode:"Substring"})
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
                            this.UIA_Objs[k] := this.AdobeEl.FindCachedElement({Type:"Button", LocalizedType:"button",  Name: v, matchmode:"Substring"})
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