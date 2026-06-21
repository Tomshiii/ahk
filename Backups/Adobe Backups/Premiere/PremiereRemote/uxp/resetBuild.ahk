; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

keepWindow := false
hide := false
doHide := (hide = true) ? "Hide" : ""

cmd.run(,, keepWindow, 'node scripts/generate-api.js', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'xcopy /s /e /y static\. build\', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'xcopy /s /e /y static\. build\', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)
cmd.run(,, keepWindow, 'npx pnpm run bundle', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp', doHide)

cmd.run(,, keepWindow, 'docker compose down && docker compose up --build -d', 'C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp', doHide)

notifyExt.showIfNotExist('uxpRebuild',, "UXP Rebuild Complete...")
/**
cd C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp
node scripts/generate-api.js
xcopy /s /e /y static\. build\
npx pnpm run bundle

cd c:\
cd C:\Users\Tom\AppData\Roaming\Adobe\UXP\Plugins\External\PremiereRemote-uxp
docker compose down && docker compose up --build