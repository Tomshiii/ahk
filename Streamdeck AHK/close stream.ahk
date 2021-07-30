;F19:: ;this script goes through and closes everything I use for stream
coordmode "pixel", "Window"
coordmode "mouse", "Window"
MouseGetPos &xposP, &yposP
	MouseMove 878, 14
	WinActivate "ahk_exe Streamlabs Chatbot.exe"
	WinClose "ahk_exe foobar2000.exe"
	WinClose "All Moons UPDATED v.1.3.0"
	WinClose "Twitch"
	WinClose "ahk_exe Docker Desktop.exe"
;WinClose, ahk_exe LiveSplit.exe ;don't include, just incase of gold/pbs
;WinClose, LiveSplit ;don't include, just incase of gold/pbs
	WinClose "ahk_exe chrome.exe"
	WinClose "ahk_exe obs64.exe"
	WinClose "ahk_exe StreamLabels.exe"
	WinClose "ahk_exe chatterino.exe"
	WinClose "ahk_exe LioranBoard Receiver.exe"
	WinClose "ahk_exe ApplicationDj.exe"
;WinKill, Streamlabs Chatbot
ExitApp