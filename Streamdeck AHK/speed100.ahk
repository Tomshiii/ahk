IfWinActive AHK_exe Adobe Premiere Pro.exe
{
SendInput, ^d100{ENTER}
}
Else
sleep 100
ExitApp