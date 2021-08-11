;F19:: ;this script goes through and closes everything I use for stream
;coordmode "pixel", "Window"
;coordmode "mouse", "Window"
;MouseGetPos &xpos, &ypos
	;MouseMove 878, 14
	;WinActivate "ahk_exe Streamlabs Chatbot.exe"
DetectHiddenWindows(true)
	if WinExist("Streaming.ahk")
		WinClose
	if WinExist("ahk_exe foobar2000.exe")
	WinClose
	if WinExist("All Moons UPDATED v.1.3.0")
	WinClose
	if WinExist("Twitch")
	WinClose
	if WinExist("ahk_exe Docker Desktop.exe")
	WinClose 
;WinClose, ahk_exe LiveSplit.exe ;don't include, just incase of gold/pbs
;WinClose, LiveSplit ;don't include, just incase of gold/pbs
	if WinExist("ahk_exe chrome.exe")
	WinClose
	if WinExist("ahk_exe obs64.exe")
	WinClose
	if WinExist("ahk_exe StreamLabels.exe")
	WinClose
	if WinExist("ahk_exe chatterino.exe")
	WinClose
	if WinExist("ahk_exe LioranBoard Receiver.exe")
	WinClose
	if WinExist("ahk_exe ApplicationDj.exe")
	WinClose
	if WinExist("ahk_exe discord.exe")
		WinMove 4480, -260, 1080, 1488
;WinKill, Streamlabs Chatbot
ExitApp