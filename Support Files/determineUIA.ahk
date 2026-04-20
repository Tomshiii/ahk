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
    return
}

try uiaObj.setObjs()
catch {
    notifyExt.showIfNotExist("determineUIAFailed",, 'Retrieving UIA Coordinates failed. Please try again', 'C:\Windows\System32\imageres.dll|icon94', 'Windows Critical Stop',, 'dur=4 bc=0x371112 bdr=Red iw=25 show=Fade@250 hide=Fade@250 maxW=400')
    try {
        uiaObj.beenSet   := false
        uiaObj.isRunning := false
        uiaObj := ""
    }
    ExitApp()
}

ExitApp()