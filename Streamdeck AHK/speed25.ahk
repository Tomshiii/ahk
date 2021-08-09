If WinActive("ahk_exe Adobe Premiere Pro.exe")
{
SendInput "^d25{ENTER}"
}
Else
sleep 100
ExitApp