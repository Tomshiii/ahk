IfWinActive AHK_exe Adobe Premiere Pro.exe
{
SendInput, ^d200{ENTER}
}
Else
sleep 100
ExitApp