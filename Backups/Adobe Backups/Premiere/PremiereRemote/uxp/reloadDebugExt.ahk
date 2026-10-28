; { \\ #Includes
#Include funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\winext.ahk
#Include Classes\notifyExt.ahk
#Include Other\UIA\UIA.ahk
; }

devTools := "ahk_exe Adobe UXP Developer Tools.exe"
openDebug := false

if !winExt.ExistRegex(devTools,,,, true) {
    notifyExt.showIfNotExist('uxpRebuildFailed',, "Failed to find UXP window")
    return
}

if !__startUXP() {
    notifyExt.showIfNotExist('uxpRebuildFailed',, "Failed to find UXP window")
    return
}

debugWindow := "PremiereRemote - Premiere Pro v\d+\.\d+(\.\d+)? \(Debug\)"
switch {
    case !winExt.ExistRegex(debugWindow) && openDebug = true && IsSet(debugButt): debugButt.invoke()
    case (winExt.ExistRegex(debugWindow)):
        try {
            winExt.ActivateRegex(debugWindow)
            if !winExt.WaitActiveRegex(debugWindow,, 2) {
                return
            }
            debugTitle := winExt.TitleRegex(debugWindow)
            debugWin := UIA.ElementFromHandle(debugTitle,, false)
            debugWin.FindElement({Type:50000, Name:"Clear console"}).invoke()
            if !openDebug
                winExt.MinimizeRegex(debugWindow)
        }
        if openDebug = true
            winExt.ActivateRegex(debugWindow)
}
notifyExt.showIfNotExist('uxpRebuild',, "UXP Rebuild Complete...")