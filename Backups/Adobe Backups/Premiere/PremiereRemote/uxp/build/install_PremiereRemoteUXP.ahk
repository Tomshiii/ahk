; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\Apps\docker.ahk
#Include Classes\ptf.ahk
; }
if RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode", "0") != "1"
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

if !docker.isInstalled()
    throw TargetError("Docker needs to be installed", -2)
commonFiles := EnvGet("CommonProgramFiles")
if !DirExist(commonFiles "\Adobe") {
    MsgBox("Adobe programs don't seem to be installed. Attempting to install the UXP extension may fail.`n`nAborting.")
    return
}
SplitPath(A_LineFile,, &buildDir)
try arg := A_Args[1]
ccxPath := IsSet(arg) ? arg : buildDir "\de.sebinside.premiereremote_premierepro.ccx"
if !IsSet(ccxPath) || !FileExist(ccxPath)
    return

loop {
    if !WinExist("ahk_exe Adobe Premiere Pro.exe") && !WinExist("ahk_exe Adobe Premiere Pro (Beta).exe")
        break
    userResponse := MsgBox("Installation of UXP plugin cannot continue while Premiere is open.`nPlease close Premiere to continue.", "Premiere is Open", "262161")
    if userResponse = "Cancel"
        return
    continue
}
uxpDir := commonFiles "\Adobe\UXP\Plugins\External"
c := Format('cmd /c "if not exist "{1}" mkdir "{1}" & .\UnifiedPluginInstallerAgent.exe /install "{2}""', uxpDir, ccxPath)
installEx := cmd.run(true,,, c, workDir, "Hide")
if installEx.exitCode != 0 {
    errorLog(MethodError("Installing PremiereRemote failed. ExitCode: " installEx.exitCode),,, true)
    return
}
try Run(ptf.Backups "\Adobe Backups\Premiere\PremiereRemote\uxp\replaceAndReset.ahk")
;// installs to; A_ProgramFiles "\Common Files\Adobe\UXP\Plugins\External\de.sebinside.premiereremote_4.x.x"