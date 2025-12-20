; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

;// this script requires the user to be using chocolatey
cmd.run(true, false, true, "choco upgrade ffmpeg")