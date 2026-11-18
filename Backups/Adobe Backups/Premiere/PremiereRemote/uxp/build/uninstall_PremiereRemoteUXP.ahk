; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\errorLog.ahk
#Include Classes\constants.ahk
#Include Functions\getCCXVersion.ahk
; }

loop {
    if !WinExist("ahk_exe Adobe Premiere Pro.exe") && !WinExist("ahk_exe Adobe Premiere Pro (Beta).exe") && !WinExist("ahk_exe AfterFX.exe") && !WinExist("ahk_exe AfterFX (Beta).exe")
        break
    userResponse := MsgBox("Uninstallation of UXP plugin cannot continue while Premiere/After Effects is open.`nPlease close Premiere to continue.", "Premiere is Open", "262161")
    if userResponse = "Cancel"
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_CANCEL)
}

upi   := ".\UnifiedPluginInstallerAgent.exe"
names := ["PremiereRemote", "AERemote"]

/** @returns {Map} name => version for every extension that is still installed */
getInstalled(names) {
    found := Map()
    for name in names
        if (ver := getExtensionVersion(name)) != ""
            found[name] := ver
    return found
}

seen := Map()  ; "name_version" keys we've already tried to remove
while (found := getInstalled(names)).Count {
    ; if a name+version we already tried to remove is still listed, removal isn't
    ; working, so stop looping instead of spinning forever
    stuck := false
    for name, ver in found {
        if seen.Has(key := name "_" ver)
            stuck := true
        seen[key] := true
    }
    if stuck
        break

    c := ""
    for name in found
        c .= (A_Index > 1 ? " & " : "") Format('{1} /remove "{2}" || exit /b 101', upi, name)

    uninstEx := cmd.run(true,,, c, workDir, "Hide")
    if uninstEx.exitCode != 0
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_UNINSTALL_FAIL)
}

;// anything still listed means the loop gave up
if getInstalled(names).Count
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_UNINSTALL_FAIL)

ExitApp(CONST.ErrorCode.GENERIC_PASS)