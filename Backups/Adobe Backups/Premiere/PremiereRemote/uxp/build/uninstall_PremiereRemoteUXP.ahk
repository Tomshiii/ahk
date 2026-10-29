; { \\ #Includes
#Include shared.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

plugin := "PremiereRemote"
cmd.run(true,,, Format('.\UnifiedPluginInstallerAgent.exe /remove "{}"', plugin), workDir, "Hide")