; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\Apps\docker.ahk
#Include Classes\constants.ahk
; }

try ec := A_Args[1]
ec := IsSet(ec) && ec != 0 && ec != "0" ? ec : false

SplitPath(A_LineFile,, &currentDir)
SplitPath(currentDir,, &remoteUxpDir)
SplitPath(remoteUxpDir,, &premRemDir)
SplitPath(premRemDir,, &premDir)
SplitPath(premDir,, &adobemDir)
if RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode", "0") != "1"
    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS.12", "PlayerDebugMode")

if !docker.isInstalled()
    ExitApp(CONST.ErrorCode.DOCKER_NOT_INSTALLED)
commonFiles := EnvGet("CommonProgramFiles")
if !DirExist(commonFiles "\Adobe")
    ExitApp(CONST.ErrorCode.ADOBE_NOT_INSTALLED)

ccxPath   := currentDir "\de.sebinside.premiereremote_premierepro.ccx"
aeCCXPath := adobemDir "\After Effects\AERemote\UXP\build\de.sebinside.aeremote_ae.ccx"
if !FileExist(ccxPath) || !FileExist(aeCCXPath)
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
upi    := ".\UnifiedPluginInstallerAgent.exe"
c := Format('mkdir "{1}" 2>nul & {2} /install "{3}" || exit /b 101 & timeout /t 2 /nobreak >nul & {2} /install "{4}" || exit /b 101'
          , uxpDir, upi, ccxPath, aeCCXPath)

installEx := cmd.run(true,,, c, workDir, "Hide")
if installEx.exitCode != 0 {
    ; errorLog(MethodError("Installing PremiereRemote failed. ExitCode: " installEx.exitCode),,, true)
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_INSTALL_FAIL)
}
;// installs to; A_ProgramFiles "\Common Files\Adobe\UXP\Plugins\External\de.sebinside.premiereremote_4.x.x"
repReset := RunWait(remoteUxpDir "\replaceAndReset.ahk unset " ec)
ExitApp(repReset)