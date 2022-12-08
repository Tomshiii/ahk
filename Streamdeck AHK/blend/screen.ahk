#SingleInstance Force
; { \\ #Includes
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
#Include <Classes\Editors\After Effects>
; }

if WinActive(Editors.Premiere.winTitle)
    prem.valuehold("blend\blendmode",, "screen")
if WinActive(Editors.AE.winTitle)
    AE.blendMode()