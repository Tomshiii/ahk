; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

removeCommand := 'Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage'
command  := 'powershell -NoProfile -Command "' removeCommand '"'
cmd.run(true,, true, command)