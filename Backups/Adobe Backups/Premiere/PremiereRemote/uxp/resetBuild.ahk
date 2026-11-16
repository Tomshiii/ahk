; { \\ #Includes
#Include funcs.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\winext.ahk
#Include Classes\ptf.ahk
#Include Classes\constants.ahk
#Include Other\UIA\UIA.ahk
#Include Functions\getCCXVersion.ahk
; }

#WinActivateForce

try isCCx := A_Args[1]
if !IsSet(isCCx)
    isCCx := getExtensionVersion()
keepWindow := false
hide := true
doHide := (hide = true) ? "Hide" : ""
try premIcon := ptf.Icons "\prprj.ico"

InstalledDir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp"
__replaceCompose()

if !Notify.Exist("uxpRebuild")
    uxpProg := Notify.Show("Rebuilding PremiereRemote UXP extension.", "...", premIcon ?? "",,, 'theme=Dark dur=0 show=Fade@250 bdr=0x75aedc ts=12 tfo=norm hide=Fade@250 maxW=400 prog=h15 w300 Range0-100 Smooth tag=uxpRebuild')

uxpProg["msg"].text := "Generating ``generate-api.js``..."
genAPI := __runStep('node scripts/generate-api.js', InstalledDir "\client")
if genAPI.failed {
    __fail("Generating ``generate-api.js``", genAPI)
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_RESET_BUILD_FAIL)
}
try uxpProg["prog"].value := 10

uxpProg["msg"].text := "Copying ``static\``..."
staticCopy := __runStep('xcopy /s /e /y static\. build\', InstalledDir "\client")
if staticCopy.failed {
    __fail("Copying PremiereRemote ``static\``", staticCopy)
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_RESET_BUILD_FAIL)
}
try uxpProg["prog"].value := 20

uxpProg["msg"].text := "Running ``pnpm run bundle``..."
bundle := __runStep('pnpm run bundle', InstalledDir "\client")
if bundle.failed {
    __fail("Bundle", bundle)
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_RESET_BUILD_FAIL)
}
try uxpProg["prog"].value := 30

if isCCx {
    pluginDir    := "C:\Program Files\Common Files\Adobe\UXP\Plugins\External\de.sebinside.premiereremote_" Trim(isCCx)
    dest         := pluginDir "\build"
    src          := InstalledDir "\client\build"
    manifestSrc  := InstalledDir "\client\manifest.json"

    c := Format(
        'copy /y "{1}" "{2}\manifest.json" & xcopy "{3}\*" "{4}\" /s /e /y /i /r /h /k',
        manifestSrc, pluginDir, src, dest
    )
    uxpProg["msg"].text := "Copying ``build\`` and ``manifest.json``..."
    buildCopy := __runStep(c,, true, 1)
    if buildCopy.failed {
        __fail("Copying PremiereRemote ``build\``", buildCopy)
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_RESET_BUILD_FAIL)
    }
    try uxpProg["prog"].value := 40
    if WinExist(prem.winTitle)
        try prem.__remoteUXP('common/reloadPanel')
    try uxpProg["prog"].value := 50
}

uxpProg["msg"].text := "Rebuilding docker compose..."
dockerBuild := __runStep('docker compose down && docker compose up --build -d', InstalledDir)
if dockerBuild.failed {
    __fail("Rebuilding docker compose", dockerBuild)
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_RESET_BUILD_FAIL)
}
try uxpProg["prog"].value := 100
sleep 1000
__clearNotif()
ExitApp(CONST.ErrorCode.GENERIC_PASS)




__clearNotif() {
    if Notify.Exist("uxpRebuild")
        try Notify.Destroy("uxpRebuild", true)
}
__errorNotif() {
    try {
        uxpProg["title"].text := "Rebuild Failed"
        uxpProg["prog"].value := 100
        uxpProg["prog"].Opt("cRed")
    }
}
/**
 * Runs a command using `cmd.result()` when `hide` is true, otherwise the visible `cmd.run()`.
 * @param {String} command the command to run
 * @param {String} [dir=""] the working directory
 * @param {Boolean} [admin=false] run elevated (always uses `cmd.run()`, as `cmd.result()` can't elevate)
 * @param {Integer} [okMax=0] the highest exit code still treated as success
 * @returns {Object} `{ExitCode, response, failed}`
 */
__runStep(command, dir := "", admin := false, okMax := 0) {
    if hide && !admin {
        res := cmd.result(command, true, true, dir)
        return {ExitCode: res.ExitCode, response: res.response, failed: (res.ExitCode < 0 || res.ExitCode > okMax)}
    }
    res := cmd.run(admin,, keepWindow, command, dir, doHide)
    code := (res.exitCode = "") ? -1 : res.exitCode   ; cmd.run returns null exitCode if Run threw
    return {ExitCode: code, response: "", failed: (code < 0 || code > okMax)}
}
__fail(title, step) {
    __errorNotif()
    errorLog(MethodError(title " failed (exit " step.ExitCode ")", -1), step.response,, true)
    __clearNotif()
}