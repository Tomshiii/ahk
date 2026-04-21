#SingleInstance Ignore
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\Editors\Premiere.ahk
#Include Classes\Editors\Premiere_UIA.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk

if !WinExist(prem.exeTitle)
    return

;// need to ensure a project is actually open
uiaObj := CLSID_Objs.load("premUIA_Values")
if uiaObj.beenSet = true {
    ExitApp()
}

try {
    if !uiaObj.setObjs()
        ExitApp()
} catch as e {
    switch {
        case InStr(e.Message, "This version of Premiere is not supported."):
            throw MethodError(e.Message)
        case InStr(e.Message, "Failed to return Premiere Version"):
            notifyExt.showIfNotExist("UIApremNotReady",, "Determining Premiere's version failed, causing UIA value retrieval to abort.",,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
            ExitApp()
        case InStr(e.Message, "Socket"):
            notifyExt.showIfNotExist("premSocketLoading",, "Socket connection still being established. Please wait.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
            ExitApp()
        case InStr(e.Message, "Failed to retrieve Premiere title."):
            notifyExt.showIfNotExist("UIApremTitleFailed",, "Determining Premiere's title failed, causing UIA value retrieval to abort.",,,, "dur=4 bdr=Maroon show=Fade@225 hide=Fade@250 maxW=400")
            ExitApp()
        case InStr(e.Message, "Setting UIA objs failed"):
            notifyExt.showIfNotExist("determineUIAFailed",, 'Retrieving UIA Coordinates failed. Please try again', 'C:\Windows\System32\imageres.dll|icon94', 'Windows Critical Stop',, 'dur=4 bc=0x371112 bdr=Red iw=25 show=Fade@250 hide=Fade@250 maxW=400')
            try {
                uiaObj.beenSet   := false
                uiaObj.isRunning := false
                uiaObj := ""
            }
            ExitApp()
    }
}

prem.__setTimelineValues()
ExitApp()