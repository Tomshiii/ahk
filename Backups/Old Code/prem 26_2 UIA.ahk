; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\Premiere.ahk
#Include Functions\notifyIfNotExist.ahk
#Include Other\UIA\UIA.ahk
; }
Persistent()

;// the current prem beta has a much more fleshed out UIA tree, which is great!!!.... except it's now SLOW as all hell to initialise

;// When this prem update drops and UIA gets much more fleshed out within the program, I will need to build this functionality into the current
;// core functionality flow.
;// once properly implemented this should mean that I no longer need to store the values in a .json file and can just use core func to share the objects around
;// I just don't know how fast/slow that's going to end up being (or how reliable, it may just end up with too many scenarios where `prem` is busy or something and throw an error. maybe needs to just be its own obj)

;// if ^ ends up being too slow, just fall back to the current way and store the values
class mockPrem {

    static __New() {
        if !this.premCacheRequest
            this.initUIA()
    }

    static UIA_Objs := Map()
    static premCacheRequest := false

    static initUIA() {
        try notify.Destroy("premUIAGenTree")
        try notify.Destroy("UIAretrieveComplete")
        ;// build a check similar to current UIA stuff so that it can only run once, even if called twice
        notifyIfNotExist("premUIAGenTree",, 'Generating Premiere UIA tree...`nThis may take a while', 'C:\Program Files\Adobe\Adobe Premiere Pro 2026\Adobe Premiere Pro.exe',,, 'dur=0 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400')
        start := A_TickCount
        this.premCacheRequest := UIA.CreateCacheRequest(["LocalizedType", "Type", "Name", "Value"],, "Descendants")
        static AdobeEl  := UIA.ElementFromHandle(prem.winTitle, this.premCacheRequest, false)
        two := A_TickCount

        this.UIA_Objs["timeline"]       := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Timeline"})
        this.UIA_Objs["effectControls"] := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Effect Controls"})
        this.UIA_Objs["effectsPanel"]   := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Effects"})
        this.UIA_Objs["tools"]          := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Tools"})
        this.UIA_Objs["sourceMon"]      := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Source Monitor"})
        this.UIA_Objs["project"]        := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Project:", matchmode:"Substring"})
        this.UIA_Objs["programMon"]     := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Program Monitor"})


        this.UIA_Objs["premRemote"]     := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"PremiereRemote"})
        this.UIA_Objs["razorTool"]      := AdobeEl.FindCachedElement({Type:"Button", LocalizedType:"button",  Name:"Razor Tool", matchmode:"Substring"})
        three := A_TickCount

        if Notify.Exist("premUIAGenTree")
            notify.Destroy("premUIAGenTree")
        notifyIfNotExist("UIAretrieveComplete",, "Retrieving UIA Coordinates is now complete.", 'C:\Program Files\Adobe\Adobe Premiere Pro 2026\Adobe Premiere Pro.exe',,, 'dur=3 bdr=Navy show=Fade@225 hide=Fade@250 maxW=400')

        ; MsgBox("init: " two-start "`nfind: " three-two "`ntotal: " three-start)
        ;init: 6984
        ;find: 94
        ;total: 7078

    }

    static doThings() {
        this.UIA_Objs["timeline"].SetFocus()
        sleep 100
        this.UIA_Objs["tools"].SetFocus()
        sleep 50
        this.UIA_Objs["razorTool"].Click()

        MsgBox(this.UIA_Objs["timeline"].location.x)
    }
}

F3::mockPrem.doThings()

