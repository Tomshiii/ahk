/************************************************************************
 * @description A script to facilitate retrieving and setting UIA values within `Core Functionality.ahk`
 * @author tomshi
 * @date 2026/04/28
 * @version 1.0.5
 ***********************************************************************/
#SingleInstance Ignore
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\Editors\Premiere.ahk
#Include Classes\Editors\Premiere_UIA.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk
#Include Functions\isReload.ahk
#Include Other\ObjRegisterActive.ahk
#Include Other\WinEvent.ahk
#NoTrayIcon

try getReload := A_Args.Get(1)
Persistent()
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

if !WinExist(prem.exeTitle)
    ExitApp()

premUIA := premUIA_Values
allRegister := [{obj: premUIA, name: "determineUIA"}]
for v in allRegister {
    ObjRegisterActive(v.obj, CLSID_Objs[v.name])
}

premUIAobj := CLSID_Objs.load("determineUIA")
premUIAobj.isRunning := true

try {
    if !premUIAobj.setObjs() {
        __deleteUIA()
        ExitApp()
    }
} catch as e {
    ;// error codes
    /**
     * 701 - initialising UIA element
     * 702 - Timeline
     * 703 - Effect Controls
     * 704 - Effects
     * 705 - Program Monitor
     * 706 - Source Monitor
     * 707 - Tools
     * 708 - Project
     * 709 - PremiereRemote
     * 710 - Selection Tool
     * 711 - Track Select Forward/Track Select Backward Tool
     * 712 - Ripple Edit/Rolling Edit/Rate Stretch/Remix Tool
     * 713 - Razor Tool
     * 714 - Slip/Slide Tool
     * 715 - Pen Tool
     * 716 - Shape Tool
     * 717 - Hand/Zoom Tool
     * 718 - Type Tool
     */

    Codes := Map("701", "Failed initialising UIA element", "702", "Failed determining the Timeline", "703", "Failed determining the Effect Controls Panel", "704", "Failed determining the Effects Panel", "705", "Failed determining the Program Monitor", "706", "Failed determining the Source Monitor", "707", "Failed determining the Tools Panel", "708", "Failed determining the Project", "709", "Couldn't find PremiereRemote", "710", "Selection Tool", "711", "Track Select Forward/Track Select Backward Tool", "712", "Ripple Edit/Rolling Edit/Rate Stretch/Remix Tool", "713", "Razor Tool", "714", "Slip/Slide Tool", "715", "Pen Tool", "716", "Shape Tool", "717", "Hand/Zoom Tool", "718", "Type Tool")
    switch {
        case InStr(e.Message, "This version of Premiere is not supported."):
            __deleteUIA()
            throw MethodError(e.Message)
        case InStr(e.Message, "Failed to return Premiere Version"):
            notifyExt.showIfNotExist("UIApremNotReady",, "Determining Premiere's version failed, causing UIA value retrieval to abort.",,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
            __deleteUIA()
            ExitApp()
        case InStr(e.Message, "Socket"):
            notifyExt.showIfNotExist("premSocketLoading",, "Socket connection still being established. Please wait.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
            __deleteUIA()
            ExitApp()
        case InStr(e.Message, "Failed to retrieve Premiere title."):
            notifyExt.showIfNotExist("UIApremTitleFailed",, "Determining Premiere's title failed, causing UIA value retrieval to abort.",,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
            __deleteUIA()
            ExitApp()
        case codePos := InStr(e.Message, "throw code:"):
            __deleteUIA()
            code := SubStr(e.Message, (codePos+StrLen("throw code:")))
            codeArr := StrSplit(code, ["`r", "`n"])
            throwString := (codes.Has(codeArr[1])) ? codes.Get(codeArr[1]) : "error code: " codeArr[1]
            throw ValueError(throwString)
        default:
            __deleteUIA()
            throw e
    }
}

premUIAobj.isRunning := false
premUIAobj.beenSet   := true
premUIAobj := ""
__deleteUIA()
SetTimer((*) => (__deleteUIA()), -2500)

didReload := isReload(getReload ?? false)
if WinExist(prem.winTitle) && !didReload {
    SetTimer((*) => (prem.__setTimelineValues(), prem.getTimeline(false)), -2500)
}

if !WinEvent.IsRegistered("Close", prem.exeTitle)
    WinEvent.Close((*) => __doubleCheckExit(), prem.exeTitle)

__doubleCheckExit(*) {
    ;// prem is really weird and I guess fires the 'close' winevent doing seemingly meaningless things
    ;// this check will stop it from exiting prematurely
    if !WinExist(prem.winTitle) && !WinExist(prem.class) {
        try {
            premObj := CLSID_Objs.load("prem")
            premObj.__resetTimelineVals()
            premObj.RClickIsActive := false
        }
        ExitApp()
    }
}
OnExit(_onExit.Bind(allRegister))
_onExit(*) {
    WinEvent.Stop("Close", prem.exeTitle)
    for v in allRegister {
        try ObjRegisterActive(v.obj, "")
    }
}


__deleteUIA() {
    notifyExt.deleteIfExist("premUIAGenTree")
    notifyExt.deleteIfExist("premUIAGenTreeWarning")
    notifyExt.deleteIfExist("determiningUIA")
}