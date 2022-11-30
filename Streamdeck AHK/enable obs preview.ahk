; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
; }

if WinExist("ahk_exe obs64.exe")
    {
        WinActivate("ahk_exe obs64.exe")
        SendInput(enableOBSPreview)
    }