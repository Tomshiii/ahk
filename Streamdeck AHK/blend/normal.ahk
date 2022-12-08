#SingleInstance Force
; { \\ #Includes
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
; }

if WinActive(Editors.Premiere.winTitle)
    prem.valuehold("blend\blendmode",, "normal")
if WinActive(Editors.AE.winTitle)
    AE.blendMode()