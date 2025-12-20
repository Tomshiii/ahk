SetDefaultMouseSpeed 0
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\Editors\Resolve.ahk
; }

if WinActive(editors.Premiere.winTitle)
	prem.setScale(300)
if WinActive(editors.Resolve.winTitle)
	resolve.scale(3, "zoom", 60)