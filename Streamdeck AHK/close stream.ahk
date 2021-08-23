;F19:: ;this script goes through and closes everything I use for stream
;coordmode "pixel", "Window"
;coordmode "mouse", "Window"
;MouseGetPos &xpos, &ypos
	;MouseMove 878, 14
	;WinActivate "ahk_exe Streamlabs Chatbot.exe"
#SingleInstance Force
;this script is kinda rough and sometimes requires multiple activations to get everything closed. Probably requires more elaborate code but realistically it's just too much effort for me to bother with at the moment.
DetectHiddenWindows(true)
	if WinExist("Streaming.ahk")
		WinClose(,,1)
	if WinExist("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus
			{

					WinActivate
					WinMove 2553, -892, 1111, 1047
				coordmode "pixel", "window"
				coordmode "mouse", "window"
				MouseMove(1022, 880)
				click
			}
	if WinExist("ahk_exe foobar2000.exe")
		{
			WinActivate
			SendInput("!{F4}")
			WinClose(,,2)
		}
	if WinExist("All Moons UPDATED v.1.3.0")
		{
			WinActivate
			SendInput("!{F4}")
			WinClose(,,2)
		}
;	if WinExist("Twitch") ;leaving this in will close the window you're using after a raid which is just annoying so I'd rather just manually close my dashboard window
;		{
;			WinActivate
;			WinClose(,,1)
;		}
;WinClose, ahk_exe LiveSplit.exe ;don't include, just incase of gold/pbs
;WinClose, LiveSplit ;don't include, just incase of gold/pbs
	if WinExist("ahk_exe chrome.exe")
		{
			WinActivate
			SendInput("!{F4}")
			WinKill(,,2)
			coordmode "pixel", "window"
			coordmode "mouse", "window"
			MouseMove(780, 13)
			click
		}
	if WinExist("ahk_exe StreamLabels.exe")
		{
			WinActivate
			SendInput("!{F4}")
			WinClose(,,2)
		}
	if WinExist("ahk_exe chatterino.exe")
		{
			WinActivate
			SendInput("!{F4}")
			WinClose(,,2)
		}
	if WinExist("ahk_exe LioranBoard Receiver.exe")
		{
			WinRestore
			WinActivate
			SendInput("!{F4}")
			WinClose(,,2)
		}
	if WinExist("ahk_exe ApplicationDj.exe")
		{
			WinRestore
			WinActivate
			SendInput("!{F4}")
			WinClose(,,2)
		}
	if WinExist("ahk_exe discord.exe")
		WinMove 4480, -260, 1080, 1488
	if WinExist("ahk_exe Docker Desktop.exe")
		{
			WinRestore
			WinActivate
			SendInput("!{F4}")
			WinKill(,,2)
		}
	if WinExist("ahk_exe Streamlabs Chatbot.exe")
		{
			WinActivate
			SendInput("!{F4}")
			WinClose(,,2)
		}
	if WinExist("ahk_exe Docker Desktop.exe")
		{
			WinRestore
			WinActivate
			SendInput("!{F4}")
			WinKill(,,2)
		}
ExitApp