; { \\ #Includes
#Include <Functions\runcmd>
; }

;// this script requires the user to be using chocolatey
runcmd(true, true, "choco upgrade yt-dlp")