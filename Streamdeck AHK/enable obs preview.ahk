/*
 This value will send the keyboard shortcut you have set to enable the preview window within OBS Studio

 Can be set within KSA.ahk/ini
 */
 enableOBSPreview := IniRead("E:\Github\ahk\KSA\Keyboard Shortcuts.ini", "OBS", "Enable Preview")

if WinExist("ahk_exe obs64.exe")
    {
        WinActivate("ahk_exe obs64.exe")
        SendInput(enableOBSPreview)
    }