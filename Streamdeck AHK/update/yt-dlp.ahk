; { \\ #Includes
#Include <Classes\cmd>
; }

;// this script requires the user to be using chocolatey
cmd.run(true, true, "choco upgrade yt-dlp")