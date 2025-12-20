SetDefaultMouseSpeed 0
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\Editors\Resolve.ahk
; }

if WinActive(editors.Premiere.winTitle)
	prem.setScale(200)
if WinActive(editors.Resolve.winTitle)
	resolve.scale(2, "zoom", 60)