SetDefaultMouseSpeed 0
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\Editors\Premiere>
#Include <Classes\Editors\Resolve>
; }

if WinActive(editors.Premiere.winTitle)
	prem.setScale(300)
if WinActive(editors.Resolve.winTitle)
	resolve.scale(3, "zoom", 60)