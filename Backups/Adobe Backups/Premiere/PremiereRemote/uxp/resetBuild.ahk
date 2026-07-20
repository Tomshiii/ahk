; { \\ #Includes
#Include shared\funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\winext.ahk
#Include Other\UIA\UIA.ahk
; }

#WinActivateForce

keepWindow := false
hide := false
doHide := (hide = true) ? "Hide" : ""
openDebug := false

cmd.run(,, keepWindow, 'node scripts/generate-api.js', A_AppData '\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'xcopy /s /e /y static\. build\', A_AppData '\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'xcopy /s /e /y static\. build\', A_AppData '\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'npx pnpm run bundle', A_AppData '\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)

cmd.run(,, keepWindow, 'docker compose down && docker compose up --build -d', A_AppData '\Adobe\UXP\Plugins\External\PremiereRemote-uxp', doHide)
sleep 1000

;// reload premremote in devTools
devTools := "ahk_exe Adobe UXP Developer Tools.exe"

if !winExt.ExistRegex(devTools,,,, true) {
    notifyExt.showIfNotExist('uxpRebuildFailed',, "Failed to find UXP window")
    return
}

if !__startUXP(, &debugButt) {
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
            debugWin.FindElement({LocalizedType:"button", Name:"Clear console"}).invoke()
            if !openDebug
                winExt.MinimizeRegex(debugWindow)
        }
        if openDebug = true
            winExt.ActivateRegex(debugWindow)
}
notifyExt.showIfNotExist('uxpRebuild',, "UXP Rebuild Complete...")

/**
cd C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp
node scripts/generate-api.js
xcopy /s /e /y static\. build\
npx pnpm run bundle

cd c:\
cd C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp
docker compose down && docker compose up --build