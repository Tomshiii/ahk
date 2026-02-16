; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Functions\delaySI.ahk
; }

;// this script just reopens an extension window within premiere as anytime you change
;// the `index` file for `PremiereRemote` you need to reset the window within premiere

if !WinActive(Editors.Premiere.winTitle)
    return

delaySI(25, "!w", "{Down 2}", "{Right}", "{Up 3}", "{Enter}")