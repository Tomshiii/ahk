#SingleInstance Force

; { \\ #Includes
#Include <\Functions\detect>
#Include <\Classes\coord>
#Include <\Classes\ptf>
#Include <Functions\SD Functions\win_locations>
; }

detect()
if WinExist("Streaming.ahk")
	WinClose(,,1)
MsgBox("TURN OFF YOUR CAMERA", "CAMERA", "16 4096")
if WinExist("ahk_exe obs64.exe")
		{
			coord.s()
			MouseGetPos(&x, &y)
			WinActivate
			sleep 50
			obsLocation()
			MouseMove(3440, 20, 2)
			click
			MouseMove(x, y, 2)
		}
if WinExist("ahk_exe foobar2000.exe")
	ProcessClose("foobar2000.exe")
if WinExist("All Moons UPDATED v.1.3.0")
	{
		WinActivate
		SendInput("!{F4}")
	}

if WinExist(browser.winTitle["chrome"])
	ProcessClose("chrome.exe")
if WinExist("ahk_exe StreamLabels.exe")
	ProcessClose("StreamLabels.exe")
if WinExist("ahk_exe chatterino.exe")
	ProcessClose("chatterino.exe")
if WinExist("ahk_exe LioranBoard Receiver.exe")
	ProcessClose("LioranBoard Receiver.exe")
if WinExist("ahk_exe ApplicationDj.exe")
	ProcessClose("ApplicationDj.exe")
if WinExist("ahk_exe Discord.exe")
	discordlocation()
if WinExist("ahk_exe Docker Desktop.exe")
	ProcessClose("Docker Desktop.exe")
if WinExist("ahk_exe Streamlabs Chatbot.exe")
	ProcessClose("Streamlabs Chatbot.exe")
if WinExist("ahk_exe Firebot v5.exe")
	ProcessClose("Firebot v5.exe")
if WinExist("StreamElements - Activity feed")
	{
		WinActivate
		SendInput("!{F4}")
		WinClose(,,2)
	}
ExitApp