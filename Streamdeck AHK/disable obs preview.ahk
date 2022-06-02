#Include "SD_functions.ahk"
if WinExist("ahk_exe obs64.exe")
{
	WinActivate("ahk_exe obs64.exe")
	SendInput(disableOBSPreview)
}