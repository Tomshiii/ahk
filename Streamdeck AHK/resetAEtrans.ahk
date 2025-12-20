; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
; }
;// if after effects gets stuck invisible, this script will return it to normal
;// alternatively you can use `switchTo.AE()` that function will check the transparent status of AE before switching to it
if WinExist(editors.AE.winTitle)
    try WinSetTransparent(255, editors.AE.winTitle)