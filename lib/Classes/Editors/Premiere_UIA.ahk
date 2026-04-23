/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2026/04/23
 * @version 3.0.6
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
            premExe := 'C:\Program Files\Adobe\Adobe Premiere Pro ' this.UserSettings.prem_year '\Adobe Premiere Pro.exe'
            img := FileExist(premExe) ? premExe : 'C:\Windows\System32\imageres.dll|icon80'
            /* Notify.Show(, 'Premiere must remain as the active window during this process.', img,,, 'dur=0 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400 tag=premUIAGenTreeWarning') */
            Notify.Show(, 'Generating Premiere UIA tree... This may take a while.`nPremiere && other AHK scripts may appear unresponsive until this process has completed.', img,,, 'dur=0 bdr=Maroon show=Fade@150 hide=Fade@250 maxW=400 tag=premUIAGenTree')
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
        try {
            premCacheRequest := UIA.CreateCacheRequest(["LocalizedType", "Type", "Name", "Value", "ClassName", "AutomationId", "BoundingRectangle"],, "Descendants") ;// all necessary for `GetUIAPath()`
            this.AdobeEl     := UIA.ElementFromHandle(prem.winTitle, premCacheRequest, false)
            this.UIA_Objs["timeline"]       := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Timeline"}), this.UIA_Path["timeline"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["timeline"], true)
            this.UIA_Objs["effectControls"] := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Effect Controls"}), this.UIA_Path["effectControls"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["effectControls"], true)
            this.UIA_Objs["effectsPanel"]   := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Effects"}), this.UIA_Path["effectsPanel"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["effectsPanel"], true)
            this.UIA_Objs["programMon"]     := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Program Monitor"}), this.UIA_Path["programMon"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["programMon"], true)
            this.UIA_Objs["sourceMon"]      := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Source Monitor"}), this.UIA_Path["sourceMon"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["sourceMon"], true)
            this.UIA_Objs["tools"]          := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Tools"}), this.UIA_Path["tools"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["tools"], true)
            this.UIA_Objs["project"]        := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Project:", matchmode:"Substring"}), this.UIA_Path["project"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["project"], true)

            this.UIA_Objs["premRemote"]     := this.AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"PremiereRemote"}), this.UIA_Path["premRemote"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["premRemote"], true)

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
                            this.UIA_Path[k] := this.AdobeEl.GetUIAPath(this.UIA_Objs[k], true)
                        }
                    default: this.UIA_Objs[k] := this.AdobeEl.FindCachedElement({Type:"Button", LocalizedType:"button",  Name: v, matchmode:"Substring"}), this.UIA_Path[k] := this.AdobeEl.GetUIAPath(this.UIA_Objs[k], true)
                }
            }
        } catch as e {
            try errorLog(Error(e.Message, e.What, e.Extra))
            notifyExt.deleteIfExist("premUIAGenTree")
            notifyExt.deleteIfExist("premUIAGenTreeWarning")
            if A_ScriptName != "Core Functionality.ahk" {
                uiaObj := CLSID_Objs.load("premUIA_Values")
                uiaObj.AdobeEl   := {}
                uiaObj.UIA_Objs  := Map()
                uiaObj.UIA_Path  := Map()
                uiaObj.beenSet   := false
                uiaObj.isRunning := false
                uiaObj := ""
            } else {
                this.AdobeEl   := {}
                this.UIA_Objs  := Map()
                this.UIA_Path  := Map()
                this.beenSet := false
                this.isRunning := false
            }
            throw Error("Setting UIA objs failed")
        }

        if A_ScriptName != "Core Functionality.ahk" {
            uiaObj := CLSID_Objs.load("premUIA_Values")
            uiaObj.AdobeEl          := this.AdobeEl
            uiaObj.UIA_Objs         := this.UIA_Objs
            uiaObj.UIA_Path         := this.UIA_Path
            uiaObj.beenSet          := true
            uiaObj.isRunning        := false
            uiaObj := ""
        } else {
            this.beenSet := true
            this.isRunning := false
        }

        notifyExt.deleteIfExist("premUIAGenTree")
        notifyExt.deleteIfExist("premUIAGenTreeWarning")
        notifyExt.deleteIfExist("determiningUIA")
        notifyExt.showIfNotExist("UIAretrieveComplete",, "Retrieving UIA Coordinates is now complete.", img,,, 'dur=3 bdr=0x5B009F show=Fade@225 hide=Fade@250 maxW=400')
        return true
    }

    static initialise() {
        Critical('On')
        uiaObj := CLSID_Objs.clone("premUIA_Values")
        if winExt.ExistRegex("determineUIA.ahk ahk_class AutoHotkey ahk_exe AutoHotkey64.exe",,,, true) && uiaObj.isRunning = true {
            ;// would need to decouple notify from Core Func and move somewhere else
            ; if !notify.Exist("determiningUIA")
                ; try Notify.Show(, "UIA Coordinates are currently waiting to be determined",,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400 tag=determiningUIA")
            ; notifyExt.showIfNotExist("determiningUIA",, "UIA Coordinates are currently waiting to be determined",,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
            Critical('Off')
            return false
        }
        if uiaObj.beenSet = true && uiaObj.isRunning = false && isObjHasProp(uiaObj, "AdobeEl", false) {
            return uiaObj
        }
        switch (A_ScriptName = "Core Functionality.ahk") {
            case true:
                this.isRunning := true
            case false:
                uiaObj := ""
                uiaObj := CLSID_Objs.load("premUIA_Values")
                uiaObj.isRunning := true
                uiaObj := ""
        }
        scriptLoc := ptf.SupportFiles "\determineUIA.ahk"
        Run(scriptLoc)
        Critical('Off')
        return false
    }
}