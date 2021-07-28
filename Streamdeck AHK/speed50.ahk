IfWinActive AHK_exe Adobe Premiere Pro.exe
{
SendInput, ^d50{ENTER}
}
Else
sleep 100
ExitApp