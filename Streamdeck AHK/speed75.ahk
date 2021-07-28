IfWinActive AHK_exe Adobe Premiere Pro.exe
{
SendInput, ^d75{ENTER}
}
Else
sleep 100
ExitApp