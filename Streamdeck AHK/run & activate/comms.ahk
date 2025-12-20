; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include runActivate.ahk
#Include Classes\Streamdeck_opt.ahk
; }

SDopt := SD_Opt()
runAndActivate(SDopt.comms)