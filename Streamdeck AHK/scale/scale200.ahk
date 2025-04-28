SetDefaultMouseSpeed 0
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\Editors\Premiere>
#Include <Classes\Editors\Resolve>
; }

if WinActive(editors.Premiere.winTitle)
	prem.setScale(200)
if WinActive(editors.Resolve.winTitle)
	resolve.scale(2, "zoom", 60)