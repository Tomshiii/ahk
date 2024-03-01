#Include <Classes\Editors\Premiere>
#Include <Functions\delaySI>

;// this script just reopens an extension window within premiere as anytime you change
;// the `index` file for `PremiereRemote` you need to reset the window within premiere

if !WinActive(prem.winTitle)
    return

delaySI(25, "!w", "{Down 2}", "{Right}", "{Up 2}", "{Enter}")