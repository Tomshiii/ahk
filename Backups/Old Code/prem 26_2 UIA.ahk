; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\Premiere.ahk
#Include Other\UIA\UIA.ahk
; }
Persistent()

;// the current prem beta has a much more fleshed out UIA tree, which is great!!!.... except it's now SLOW as all hell to initialise

;// When this prem update drops and UIA gets much more fleshed out within the program, I will need to build this functionality into the current
;// core functionality flow.
;// once properly implemented this should mean that I no longer need to store the values in a .json file and can just use core func to share the objects around
;// I just don't know how fast/slow that's going to end up being

;// if ^ ends up being too slow, just fall back to the current way and store the values
doThings() {
    ; premName := WinGet.PremName()
    static premCacheRequest := UIA.CreateCacheRequest(["LocalizedType", "Type", "Name", "Value"],, "Descendants")
    static AdobeEl  := UIA.ElementFromHandle(prem.winTitle, premCacheRequest, false)

    static timelineObj    := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Timeline"})
    static EffControlsObj := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Effect Controls"})
    static EffectsObj     := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Effects"})
    static toolsObj       := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Tools"})
    static sourceMonObj   := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Source Monitor"})
    static projectObj     := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Project:", matchmode:"Substring"})
    static progMonObj     := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"Program Monitor"})


    static premRemoteObj := AdobeEl.FindCachedElement({Type:"Pane", LocalizedType:"pane", Name:"PremiereRemote"})


    static razorToolObj := AdobeEl.FindCachedElement({Type:"Button", LocalizedType:"button", Name:"Razor Tool", matchmode:"Substring"})

    timelineObj.SetFocus()
    sleep 100
    toolsObj.SetFocus()
    sleep 50
    razorToolObj.Click()

    MsgBox(timelineObj.location.x)
}

F3::doThings()

