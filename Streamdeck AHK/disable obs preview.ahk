/*
 This value will send the keyboard shortcut you have set to disable the preview window within OBS Studio

 Can be set within KSA.ahk/ini
 */
 disableOBSPreview := IniRead("E:\Github\ahk\KSA\Keyboard Shortcuts.ini", "OBS", "Disable Preview")

if WinExist("ahk_exe obs64.exe")
{
	WinActivate("ahk_exe obs64.exe")
	SendInput(disableOBSPreview)
}