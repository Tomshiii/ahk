if not WinExist("ahk_exe obs64.exe")
{
SetWinDelay 0 ;makes windows move instantly
	Run '*RunAs "C:\Program Files\ahk\ahk\Streaming.ahk"'
	Run "C:\Program Files\Docker\Docker\frontend\Docker Desktop.exe"
	Result := MsgBox("have you started the goxlr bruh",, 1)
	if Result = "OK"
		{
			goto next
		}
	else
		goto theend
	next:
	Run "C:\Program Files\ahk\ahk\obs64.lnk" ;opening shortcuts helps to make sure obs doesn't complain about having an incorrect working directory
		if WinExist("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus
			WinActivate
		else
			WinWaitActive "ahk_exe obs64.exe"
	sleep 2500 ; you have to wait a while after obs opens before you can start sending it commands or it'll crash
	SendInput "!p" ;Opens alt context menu - The Above 2.5s sleep is essential as obs crashes if you instantly change the profile
	SendInput "{DOWN 7}"
	SendInput "{ENTER}" ;Changes profile to main stream profile.
	sleep 2000
	if WinExist("ahk_exe obs64.exe")
		WinMove 2553, -892, 1111, 1047  ;Moves obs into position, important for me to keep because streamelements obs is wider and ruins main obs
{ ;this part of the script is just to set the source record hotkey(s) until they fix it
		WinActivate "ahk_exe obs64.exe" ;just incase windows loses it
		SendInput "!f"
		sleep 100
		SendInput "s"
		sleep 2000
		SendInput "{DOWN 5}"
		sleep 200
		SendInput "{TAB 55}"
		sleep 200
		SendInput "^+8"
		sleep 1000
		SendInput "{TAB}"
		SendInput "+{TAB 57}"
		sleep 200
		SendInput "{UP}{TAB}{ENTER}"
		sleep 200
}
	Run "firefox.exe https://docs.google.com/presentation/d/1b6pCuOIrw4pEF6GACxrBh8C-mB4XsDeHLM50cj4jAkQ/edit#slide=id.g90e8195d3c_16_958" ;opens the AM route doc to pauline questions
		if WinExist("ahk_exe firefox.exe")
			WinActivate
		else
			WinWaitActive "ahk_exe firefox.exe"
	sleep 1000 ;waits before opening the next tab or firefox derps out
	Run "firefox.exe https://dashboard.twitch.tv/u/tomshi/stream-manager"
	sleep 9000 
	if WinExist("ahk_exe firefox.exe")
WinActivate
	SetKeyDelay 100
	Send "!d" ;opens the alt context menu to begin detatching the firefox tab
	sleep 100
	Send "+{TAB 3}"
	sleep 100
	Send "+{F10}"
	sleep 100
	Send "v"
	sleep 100
	Send "w"
	sleep 2000
	WinWait("Twitch", , 10) ;WinMove -6, 0, 1497, 886,, "Twitch"  ;moves browser tabs into position for stream
			WinMove -6, 0, 1497, 886
	WinWait("All Moons UPDATED v.1.3.0", , 10) ;WinMove 1218, 658, 1347, 747,, "All Moons UPDATED v.1.3.0"  ;moves browser tabs into position for stream
		WinMove 1218, 658, 1347, 747
	if WinExist("ahk_exe Docker Desktop.exe") ;waits until docker is open then brings it into focus
		WinActivate
	else
		WinWait("ahk_exe Docker Desktop.exe")
	sleep 2000
		coordmode "pixel", "Window"
		coordmode "mouse", "Window"
		MouseMove 1128, 130 ;moves mouse to click the start button
		click ;required for brothers queue program for automatic mii wii playback
sleep 2000
Run "C:\Program Files\ahk\ahk\TomSongQueueue\Builds\ApplicationDj.exe"
sleep 3500 ;it needed some time to open
	if WinExist("ahk_exe ApplicationDj.exe") ;waits until ttp's program is open then brings it into focus
		WinActivate
sleep 2000
SendInput "y{enter}"
	;Run, chrome.exe https://dashboard.twitch.tv/u/tomshi/stream-manager only need this if I'm doing something subpoint related
	Run "C:\Program Files\Chatterino\chatterino.exe"
	;Run "F:\Twitch\lioranboard\LioranBoard Receiver(PC)\LioranBoard Receiver.exe"
	Run "C:\Program Files (x86)\foobar2000\foobar2000.exe"
	Run "F:\Twitch\Splits\Splits\LiveSplit_1.7.6\LiveSplit.exe"
	Run "C:\Users\Tom\AppData\Local\Programs\streamlabels\StreamLabels.exe"
	Run "C:\Program Files\ahk\ahk\Streamlabs Chatbot.lnk"
	;Run, C:\Program Files\Elgato\GameCapture\GameCapture.exe // replaced by source record plugin
	Run "chrome.exe https://www.twitch.tv/popout/tomshi/chat"
	if WinExist("ahk_exe Discord.exe")
		WinMove 4480, 432, 1080, 797  ;moves into position
	Run "F:\Twitch\lioranboard\LioranBoard Receiver(PC)\LioranBoard Receiver.exe" ;try to run it again since apparently running it once sometimes isn't enough
}
else
    sleep 100
theend:
ExitApp