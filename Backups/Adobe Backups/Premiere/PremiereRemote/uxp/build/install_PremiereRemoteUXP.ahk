; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\docker.ahk
; }

if !docker.isInstalled()
    throw TargetError("Docker needs to be installed", -2)
SplitPath(A_LineFile,, &buildDir)
try arg := A_Args[1]
ccxPath := IsSet(arg) ? arg : buildDir "\de.sebinside.premiereremote_premierepro.ccx"
if !IsSet(ccxPath) || !FileExist(ccxPath)
    return

cmd.run(true,, true, Format('.\UnifiedPluginInstallerAgent.exe /install "{}"', ccxPath), workDir)
;// installs to; A_ProgramFiles "\Common Files\Adobe\UXP\Plugins\External\de.sebinside.premiereremote_4.x.x"