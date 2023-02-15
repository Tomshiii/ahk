; { \\ #Includes
#Include <Classes\cmd>
; }

;// this script will only work properly if powershel was initially installed via winget
cmd.run(true, true, "winget install microsoft.powershell")