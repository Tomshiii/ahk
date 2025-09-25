; { \\ #Includes
#Include <Classes\cmd>
; }


if !assetDir := FileSelect("D2",, "Select Asset Folder to Backup")
    ExitApp()
if !backupLocation := FileSelect("D2",, "Select the corresponding GDrive folder")
    ExitApp()
if userResponse := MsgBox("You are about to sync;`n`n" assetDir "`n`nwith;`n`n" backupLocation "`n`nWould you like to continue?",, "4129") = "Cancel"
    ExitApp()
if !userResponse
    ExitApp()

command := 'robocopy "{1}" "{2}" /MIR /R:1'
cmd.run(true, false, true, Format(command, assetDir, backupLocation))
