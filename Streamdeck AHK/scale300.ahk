IfWinActive AHK_exe Adobe Premiere Pro.exe
{
coordmode, pixel, Window
coordmode, mouse, Window
SetDefaultMouseSpeed 0
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
MouseGetPos, xposP, yposP
	MouseMove, 237,1102
	SendInput, {CLICK}300{ENTER}
MouseMove, %xposP%, %yposP%
blockinput, MouseMoveOff
BlockInput, off
}
Else
sleep 100
ExitApp