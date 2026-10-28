; { \\ #Includes
#Include funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\winext.ahk
#Include Other\UIA\UIA.ahk
#Include Functions\getCCXVersion.ahk
; }

#WinActivateForce

try isCCx := A_Args[1]
if !IsSet(isCCx)
    isCCx := getExtensionVersion()
keepWindow := false
hide := false
doHide := (hide = true) ? "Hide" : ""

InstalledDir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp"
__replaceCompose()

cmd.run(,, keepWindow, 'node scripts/generate-api.js', InstalledDir "\client", doHide)
cmd.run(,, keepWindow, 'xcopy /s /e /y static\. build\', InstalledDir "\client", doHide)
cmd.run(,, keepWindow, 'npx pnpm run bundle', InstalledDir "\client", doHide)

if isCCx {
    dest := "C:\Program Files\Common Files\Adobe\UXP\Plugins\External\de.sebinside.premiereremote_" Trim(isCCx) "\build"
    src  := InstalledDir "\client\build"
    c := Format('xcopy "{}\*" "{}\" /s /e /y /i /r /h /k', src, dest)
    cmd.run(true,, keepWindow, c)
    if WinExist(prem.winTitle)
        prem.__remoteUXP('common/reloadPanel')
}

cmd.run(,, keepWindow, 'docker compose down && docker compose up --build -d', InstalledDir, doHide)
sleep 1000