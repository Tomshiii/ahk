; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

plugin := "PremiereRemote"
cmd.run(,,, Format('.\UnifiedPluginInstallerAgent.exe /remove "{}"', plugin), workDir, "Hide")