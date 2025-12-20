; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
; }

if WinExist("ahk_exe obs64.exe")
	{
		WinActivate("ahk_exe obs64.exe")
		SendInput(KSA.disableOBSPreview)
	}