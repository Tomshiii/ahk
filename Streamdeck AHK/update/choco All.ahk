; { \\ #Includes
#Include <Classes\cmd>
; }

;// this script requires the user to be using chocolatey
cmd.run(true, false, true, "choco upgrade all --yes")