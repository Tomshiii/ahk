; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\Apps\docker.ahk
#Include Classes\ptf.ahk
; }

if !docker.isInstalled()
    throw TargetError("Docker needs to be installed", -2)
SplitPath(A_LineFile,, &buildDir)
try arg := A_Args[1]
ccxPath := IsSet(arg) ? arg : buildDir "\de.sebinside.premiereremote_premierepro.ccx"
if !IsSet(ccxPath) || !FileExist(ccxPath)
    return

installEx := cmd.run(true,,, Format('.\UnifiedPluginInstallerAgent.exe /install "{}"', ccxPath), workDir, "Hide")
if installEx.exitCode != 0 {
    errorLog(MethodError("Installing PremiereRemote failed. ExitCode: " installEx.exitCode),,, true)
    return
}
try Run(ptf.Backups "\Adobe Backups\Premiere\PremiereRemote\uxp\replaceAndReset.ahk")
;// installs to; A_ProgramFiles "\Common Files\Adobe\UXP\Plugins\External\de.sebinside.premiereremote_4.x.x"