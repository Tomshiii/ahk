/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2026/04/30
 * @version 3.0.11
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk
#Include Functions\isObjHasProp.ahk
#Include Other\UIA\UIA.ahk
#Include Other\Notify\Notify.ahk
; }

class premUIA_Values {
    static __New() {
        if A_ScriptName = "Core Functionality.ahk" {
            this.UserSettings := UserPref(true)
        } else {
            try this.UserSettings := CLSID_Objs.clone("UserSettings")
            catch {
                this.UserSettings := UserPref(true)
            }
        }
    }

    static isRunning := false
    static beenSet   := false

    static UIA_Objs := Map()
    static UIA_Path := Map()
    static AdobeEl  := false
    static determineUIA_PID := false

    static UserSettings := ""

    static __activeElementPath(returnObj := false) {
        if !WinActive(prem.winTitle) {
            return -1
        }
        if !uiaEl := this.initialise()
            return -1
        focusedEl := UIA.GetFocusedElement()
        try focusedPath := uiaEl.AdobeEl.GetUIAPath(focusedEl, true)
        return ((returnObj = false) ? focusedPath ?? "" : {uiaEl: uiaEl, Path: focusedPath, focusedEl: focusedEl})
    }

    static __isUiaElementActive(elementPath) {
        focusedPath := this.__activeElementPath(true)
        if !isObjHasProp(focusedPath, 'Path', -1) || focusedPath.Path = -1
            return -1
        return (focusedPath.uiaEl.UIA_Path[elementPath]=focusedPath)
    }

    static isToolSelected(element) {
        if !WinActive(prem.winTitle) {
            return -1
        }
        if !uiaEl := this.initialise()
            return -1
        return (uiaEl.UIA_Objs[element].value = "Selected" ? true : false)
    }

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
        if premObj.remoteActive = "loading" {
            notifyExt.deleteIfExist("premUIAGenTree")
            notifyExt.deleteIfExist("premUIAGenTreeWarning")
            throw Error("Socket")
        }
        if !premObj.remoteActive {
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
                    case "obj":  temp := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:name})
                    case "path": temp := this.AdobeEl.GetUIAPath(this.UIA_Objs[pathName], true)
                    case "premObj": temp := this.AdobeEl.FindCachedElement({Type:"Pane", Type:"TabItem", LocalizedType:"pane", LocalizedType:"tab item", Name:name})
                    case "projObj": temp := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:name, matchmode:"Substring"})
                }
                return temp
            } catch {
                throw UnsetError("throw code:" errorCode,, errorCode)
            }
        }
        try {
            premCacheRequest := UIA.CreateCacheRequest(["LocalizedType", "Type", "Name", "Value", "ClassName", "AutomationId", "BoundingRectangle"],, "Descendants") ;// all necessary for `GetUIAPath()`
            try {
                this.AdobeEl := UIA.ElementFromHandle(prem.winTitle, premCacheRequest, false)
            } catch {
                throw UnsetError("throw code:701")
            }

            this.UIA_Objs["timeline"]       := __TryCatchUIAobj("Timeline", "obj", "702")
            this.UIA_Path["timeline"]       := __TryCatchUIAobj("Timeline", "path", "702", "timeline")
            this.UIA_Objs["effectControls"] := __TryCatchUIAobj("Effect Controls", "obj", "703")
            this.UIA_Path["effectControls"] := __TryCatchUIAobj("Effect Controls", "path", "703", "effectControls")
            this.UIA_Objs["effectsPanel"]   := __TryCatchUIAobj("Effects", "obj", "704")
            this.UIA_Path["effectsPanel"]   := __TryCatchUIAobj("Effects", "path", "704", "effectsPanel")
            this.UIA_Objs["programMon"]     := __TryCatchUIAobj("Program Monitor", "obj", "705")
            this.UIA_Path["programMon"]     := __TryCatchUIAobj("Program Monitor", "path", "705", "programMon")
            this.UIA_Objs["sourceMon"]      := __TryCatchUIAobj("Source Monitor", "obj", "706")
            this.UIA_Path["sourceMon"]      := __TryCatchUIAobj("Source Monitor", "path", "706", "sourceMon")
            this.UIA_Objs["tools"]          := __TryCatchUIAobj("Tools", "obj", "707")
            this.UIA_Path["tools"]          := __TryCatchUIAobj("Tools", "path", "707", "tools")
            this.UIA_Objs["project"]        := __TryCatchUIAobj("Project:", "projObj", "708")
            this.UIA_Path["project"]        := __TryCatchUIAobj("Project:", "path", "708", "project")
            this.UIA_Objs["premRemote"]     := __TryCatchUIAobj("PremiereRemote", "premObj", "709")
            this.UIA_Path["premRemote"]     := __TryCatchUIAobj("PremiereRemote", "path", "709", "premRemote")

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

    static determineUIA_Exist() {
        try {
            ComObjActive(CLSID_Objs["determineUIA"])
            return true
        } catch {
            title := "determineUIA.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe"
            scriptExist := winExt.TitleRegex(title,,,, true)
            if !scriptExist
                return false
            return true
        }
    }

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
            errorLog(TargetError("Script could not interact with ``determineUIA.ahk``. Script will reload.", -1))
            try WM.Send_WM_COPYDATA("determineUIA_exitapp", "determineUIA.ahk")
            if determineScript := winExt.ExistRegex("determineUIA.ahk ahk_class AutoHotkey",,,, true)
                try winExt.CloseRegex(determineScript,,,, true)
            sleep 500
            Run(ptf.SupportFiles "\determineUIA.ahk")
            return false
        }
        switch {
            case uiaObj.isRunning:
                notifyExt.showIfNotExist("determiningUIA",, "UIA Coordinates are currently waiting to be determined",,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
                Critical('Off')
                return false
            case uiaObj.beenSet:
                Critical('Off')
                return uiaObj
            default:
                ;// registered but not yet started - shouldn't normally happen
                Critical('Off')
                return false
        }
    }
}