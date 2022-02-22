#SingleInstance Force
DetectHiddenWindows(true)
SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.
/* if not WinExist("autosave.ahk - AutoHotkey")
	Run("C:\Program Files\ahk\ahk\autosave.ahk")
if not WinExist("premiere_fullscreen_check.ahk - AutoHotkey")
	Run("C:\Program Files\ahk\ahk\premiere_fullscreen_check.ahk") */
if WinExist("Streaming.ahk")
	WinClose(,,1)
if WinExist("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus
		{
			MouseGetPos(&x, &y)
			WinActivate
			sleep 50
			WinMove 2553, -892, 1104, 1087
			coordmode "pixel", "window"
			coordmode "mouse", "window"
			MouseMove(1020, 929)
			click
			MouseMove(%&x%, %&y%)
		}
if WinExist("ahk_exe foobar2000.exe")
	{
		;WinActivate
		;SendInput("!{F4}")
		;WinClose(,,2)
		ProcessClose("foobar2000.exe")
	}
if WinExist("All Moons UPDATED v.1.3.0")
	{
		WinActivate
		SendInput("!{F4}")
		;WinClose(,,2)
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
		;WinActivate
		;SendInput("!{F4}")
		;WinKill(,,2)
		;coordmode "pixel", "window"
		;coordmode "mouse", "window"
		;MouseMove(780, 13)
		;click
		ProcessClose("chrome.exe")
	}
if WinExist("ahk_exe StreamLabels.exe")
	{
		;WinActivate
		;SendInput("!{F4}")
		;WinClose(,,2)
		ProcessClose("StreamLabels.exe")
	}
if WinExist("ahk_exe chatterino.exe")
	{
		;WinActivate
		;SendInput("!{F4}")
		;WinClose(,,2)
		ProcessClose("chatterino.exe")
	}
if WinExist("ahk_exe LioranBoard Receiver.exe")
	{
		;WinRestore
		;WinActivate
		;SendInput("!{F4}")
		;WinClose(,,2)
		ProcessClose("LioranBoard Receiver.exe")
	}
if WinExist("ahk_exe ApplicationDj.exe")
	{
		;WinRestore
		;WinActivate
		;SendInput("!{F4}")
		;WinClose(,,2)
		ProcessClose("ApplicationDj.exe")
	}
if WinExist("ahk_exe Discord.exe")
	WinMove -1080, -320, 1080, 1646
if WinExist("ahk_exe Docker Desktop.exe")
	{
		;WinRestore
		;WinActivate
		;SendInput("!{F4}")
		;WinKill(,,2)
		ProcessClose("Docker Desktop.exe")
	}
if WinExist("ahk_exe Streamlabs Chatbot.exe")
	{
		;WinActivate
		;SendInput("!{F4}")
		;WinClose(,,2)
		ProcessClose("Streamlabs Chatbot.exe")
	}
if WinExist("ahk_exe Firebot v5.exe")
	{
		ProcessClose("Firebot v5.exe")
	}
if WinExist("StreamElements - Activity feed")
	{
		WinActivate
		SendInput("!{F4}")
		WinClose(,,2)
	}
ExitApp