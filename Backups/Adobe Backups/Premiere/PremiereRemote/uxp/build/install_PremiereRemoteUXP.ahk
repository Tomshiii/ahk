; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\Apps\docker.ahk
#Include Classes\ptf.ahk
#Include Classes\constants.ahk
; }

try ec := A_Args[1]
ec := IsSet(ec) && ec != 0 && ec != "0" ? ec : false

if RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode", "0") != "1"
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

if !docker.isInstalled()
    ExitApp(CONST.ErrorCode.DOCKER_NOT_INSTALLED)
commonFiles := EnvGet("CommonProgramFiles")
if !DirExist(commonFiles "\Adobe")
    ExitApp(CONST.ErrorCode.ADOBE_NOT_INSTALLED)
SplitPath(A_LineFile,, &buildDir)
try arg := A_Args[1]
ccxPath := IsSet(arg) ? arg : buildDir "\de.sebinside.premiereremote_premierepro.ccx"
if !IsSet(ccxPath) || !FileExist(ccxPath)
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_CCX_NOT_FOUND)

loop {
    if !WinExist("ahk_exe Adobe Premiere Pro.exe") && !WinExist("ahk_exe Adobe Premiere Pro (Beta).exe") && !WinExist("ahk_exe AfterFX.exe") && !WinExist("ahk_exe AfterFX (Beta).exe")
        break
    userResponse := MsgBox("Installation of UXP plugin cannot continue while Premiere/After Effects is open.`nPlease close Premiere to continue.", "Premiere is Open", "262161")
    if userResponse = "Cancel"
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_CANCEL)
    continue
}
uxpDir := commonFiles "\Adobe\UXP\Plugins\External"
c := Format('mkdir "{1}" 2>nul & .\UnifiedPluginInstallerAgent.exe /install "{2}"', uxpDir, ccxPath)
installEx := cmd.run(true,,, c, workDir, "Hide")
if installEx.exitCode != 0 {
    ; errorLog(MethodError("Installing PremiereRemote failed. ExitCode: " installEx.exitCode),,, true)
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_FAIL)
}
;// installs to; A_ProgramFiles "\Common Files\Adobe\UXP\Plugins\External\de.sebinside.premiereremote_4.x.x"
repReset := RunWait(ptf.Backups "\Adobe Backups\Premiere\PremiereRemote\uxp\replaceAndReset.ahk unset " ec)
ExitApp(repReset)