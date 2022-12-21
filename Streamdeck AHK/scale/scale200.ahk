SetDefaultMouseSpeed 0
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\Editors\Resolve>
#Include <Functions\SD Functions\scale>
; }

if WinActive(editors.Premiere.winTitle)
	scale("200")
if WinActive(editors.Resolve.winTitle)
	resolve.scale(2, "zoom", 60)