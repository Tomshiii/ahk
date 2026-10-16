; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

workDir := A_ProgramFiles "\Common Files\Adobe\Adobe Desktop Common\RemoteComponents\UPI\UnifiedPluginInstallerAgent"

getExtensionVersion(workDir := A_ProgramFiles "\Common Files\Adobe\Adobe Desktop Common\RemoteComponents\UPI\UnifiedPluginInstallerAgent", extName := "PremiereRemote") {
	RegExEscape(str) => RegExReplace(str, "[\\.*?+\[\]{}|()^$]", "\$0")
    output := cmd.result('.\UnifiedPluginInstallerAgent.exe /list "Premiere Pro"',,, workDir)

    pattern := "m)^\s*\w+\s+" . RegExEscape(extName) . "\s+(\S+)\s*$"
    if RegExMatch(output, pattern, &m)
        return m[1]
    return ""
}