; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\errorLog.ahk
#Include Classes\constants.ahk
#Include Functions\getCCXVersion.ahk
; }

plugin := "PremiereRemote"
uninstEx := cmd.run(true,,, Format('.\UnifiedPluginInstallerAgent.exe /remove "{}"', plugin), workDir, "Hide")
if uninstEx.exitCode != 0 {
    /* errorLog(MethodError("Uninstalling PremiereRemote failed. ExitCode: " uninstEx.exitCode),,, true) */
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_UNINSTALL_FAIL)
}
if getExtensionVersion() != "" {
    deleteStale := RunWait("*RunAs " '"' ptf.Backups "\Adobe Backups\Premiere\PremiereRemote\uxp\build\deleteStaleDirs.ahk" '"')
    if deleteStale != CONST.ErrorCode.GENERIC_PASS
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_DELETE_STALE_DIRS_FAIL)
}
ExitApp(CONST.ErrorCode.GENERIC_PASS)