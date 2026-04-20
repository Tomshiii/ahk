/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2026/04/20
 * @version 3.0.2
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk
#Include Other\UIA\UIA.ahk
#Include Other\Notify\Notify.ahk
; }

class premUIA_Values {
    static __New() {
        if A_ScriptName = "Core Functionality.ahk" {
            this.UserSettings := UserPref(true)
        } else {
            try this.UserSettings := CLSID_Objs.load("UserSettings")
            catch {
                this.UserSettings := UserPref(true)
            }
        }
    }

    static isRunning := false
    static beenSet   := false

    static UIA_Objs := Map()
    static UIA_Path := Map()
    static AdobeEl  := {}
    static premCacheRequest := false

    static UserSettings := ""

    static setObjs() {
        try notify.Destroy("premUIAGenTree")
        try notify.Destroy("UIAretrieveComplete")
        if !Notify.Exist("premUIAGenTree") {
            premExe := 'C:\Program Files\Adobe\Adobe Premiere Pro ' this.UserSettings.prem_year '\Adobe Premiere Pro.exe'
            img := FileExist(premExe) ? premExe : 'C:\Windows\System32\imageres.dll|icon80'
            notify.Show(, 'Generating Premiere UIA tree...`nThis may take a while', img,,, 'dur=0 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400 tag=premUIAGenTree')
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
            this.UIA_Objs["razorTool"]      := this.AdobeEl.FindCachedElement({Type:"Button", LocalizedType:"button",  Name:"Razor Tool", matchmode:"Substring"}), this.UIA_Path["razorTool"] := this.AdobeEl.GetUIAPath(this.UIA_Objs["razorTool"], true)
        } catch {
            notifyExt.showIfNotExist("determineUIAFailed",, 'Retrieving UIA Coordinates failed. Please try again', 'C:\Windows\System32\imageres.dll|icon94', 'Windows Critical Stop',, 'dur=4 bc=0x371112 bdr=Red iw=25 show=Fade@250 hide=Fade@250 maxW=400')
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
                this.beenSet := true
                this.isRunning := false
            }
            return false
        }

        if A_ScriptName != "Core Functionality.ahk" {
            uiaObj := CLSID_Objs.load("premUIA_Values")
            uiaObj.AdobeEl   := this.AdobeEl
            uiaObj.UIA_Objs  := this.UIA_Objs
            uiaObj.UIA_Path  := this.UIA_Path
            uiaObj.beenSet   := true
            uiaObj.isRunning := false
            uiaObj := ""
        } else {
            this.beenSet := true
            this.isRunning := false
        }

        if Notify.Exist("premUIAGenTree")
            notify.Destroy("premUIAGenTree")
        notifyExt.showIfNotExist("UIAretrieveComplete",, "Retrieving UIA Coordinates is now complete.", img,,, 'dur=3 bdr=0x5B009F show=Fade@225 hide=Fade@250 maxW=400')
    }

    static initialise() {
        uiaObj := CLSID_Objs.load("premUIA_Values")
        if uiaObj.beenSet = true && uiaObj.isRunning = false && isObjHasProp(uiaObj, "AdobeEl", false) && isObjHasProp(uiaObj, "UIA_Objs", false) {
            return uiaObj
        }
        if winExt.ExistRegex("determineUIA.ahk",,,, true) {
            notifyExt.showIfNotExist("determiningUIA",, "UIA Coordinates are currently waiting to be determined",,,, "POS=BR DUR=4")
            return false
        }
        uiaObj.isRunning := true
        Run(ptf.SupportFiles "\determineUIA.ahk")
        return false
    }
}