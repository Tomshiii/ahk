; { \\ #Includes
#Include <Functions\runcmd>
; }

;// this script will only work properly if powershel was initially installed via winget
runcmd(true, true, "winget install microsoft.powershell")