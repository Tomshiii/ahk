; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\errorLog.ahk
#Include Functions\getCCXVersion.ahk
; }

plugin := "PremiereRemote"
uninstEx := cmd.run(true,,, Format('.\UnifiedPluginInstallerAgent.exe /remove "{}"', plugin), workDir, "Hide")
if uninstEx.exitCode != 0 {
    errorLog(MethodError("Uninstalling PremiereRemote failed. ExitCode: " uninstEx.exitCode),,, true)
    return
}
if getExtensionVersion() != "" {
    Run(ptf.Backups "\Adobe Backups\Premiere\PremiereRemote\uxp\build\deleteStaleDirs.ahk")
}