; { \\ #Includes
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

cmd.run(,, keepWindow, 'node scripts/generate-api.js', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'xcopy /s /e /y static\. build\', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'xcopy /s /e /y static\. build\', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'npx pnpm run bundle', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)

cmd.run(,, keepWindow, 'docker compose down && docker compose up --build -d', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp', doHide)
sleep 1000

;// reload premremote in devTools
devTools := "ahk_exe Adobe UXP Developer Tools.exe"
if WinExist(devTools) {
    WinActivate("Adobe UXP Developer Tools" A_Space devTools)
    premRemote := UIA.ElementFromHandle("Adobe UXP Developer Tools" A_Space devTools,, false)
    premRow := premRemote.FindElement({LocalizedType:"row", Name:"Premiere Pro"})
    ; premRemote := premRemote.FindElement({LocalizedType:"item", Name:"de.sebinside.premiereremote"})
    children := premRow.Children

    index := 0
    offset := 3
    for i, child in children {
        if child.Name == "de.sebinside.premiereremote" {
            index := i
            break
        }
    }
    if index = 0
        return
    debugButtBar  := children[index+offset]
    if debugButtBar.name = "Load Load & Watch" {
        debugButtBar.FindElement({LocalizedType:"button", Name:"Load"}).invoke()
        sleep 500
    }
    try debugButt  := debugButtBar.FindElement({LocalizedType:"button", Name:"Debug"})
    reloadButt     := debugButtBar.FindElement({LocalizedType:"button", Name:"Reload"})
    reloadButt.click()
    sleep 500
    WinMinimize("Adobe UXP Developer Tools" A_Space devTools)

    if openDebug = true {
        debugWindow := "PremiereRemote - Premiere Pro v\d+\.\d+(\.\d+)? \(Debug\)"
        switch {
            case !winExt.ExistRegex(debugWindow) && IsSet(debugButt): debugButt.invoke()
            case (winExt.ExistRegex(debugWindow)): winExt.ActivateRegex(debugWindow)
        }
    }
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