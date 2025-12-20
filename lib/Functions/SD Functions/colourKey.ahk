; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\Premiere.ahk
; }

colourKey(colour) {
    prem.preset(colour "Key")
}