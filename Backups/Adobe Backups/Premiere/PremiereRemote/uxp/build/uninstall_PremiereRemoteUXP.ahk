; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\errorLog.ahk
#Include Classes\constants.ahk
#Include Functions\getCCXVersion.ahk
; }

upi   := ".\UnifiedPluginInstallerAgent.exe"
parts := []
for name in ["PremiereRemote", "AERemote"]
    if getExtensionVersion(name) != ""
        parts.Push(Format('{1} /remove "{2}" || exit /b 101', upi, name))

if parts.Length {
    c := ""
    for i, p in parts
        c .= (i > 1 ? " & " : "") p

    uninstEx := cmd.run(true,,, c, workDir, "Hide")
    if uninstEx.exitCode != 0 {
        /* errorLog(MethodError("Uninstalling PremiereRemote failed. ExitCode: " uninstEx.exitCode),,, true) */
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_UNINSTALL_FAIL)
    }
}
if getExtensionVersion() != "" || getExtensionVersion("AERemote") != "" {
    deleteStale := RunWait("*RunAs " '"' ptf.Backups "\Adobe Backups\Premiere\PremiereRemote\uxp\build\deleteStaleDirs.ahk" '"')
    if deleteStale != CONST.ErrorCode.GENERIC_PASS
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_DELETE_STALE_DIRS_FAIL)
}
ExitApp(CONST.ErrorCode.GENERIC_PASS)