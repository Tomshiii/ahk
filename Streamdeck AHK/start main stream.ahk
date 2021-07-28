IfWinNotExist(ahk_exe obs64.exe)
{
;F15:: ;Start everything for stream
SetWinDelay, 0 ;makes windows move instantly
	Run, C:\Program Files\Docker\Docker\frontend\Docker Desktop.exe
	Run, C:\Program Files\ahk\obs64.lnk ;opening shortcuts helps to make sure obs doesn't complain about having an incorrect working directory
		if WinExist("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus
			WinActivate
		else
			WinWaitActive, ahk_exe obs64.exe
	sleep 2500 ; you have to wait a while after obs opens before you can start sending it commands or it'll crash
	SendInput, !p ;Opens alt context menu - The Above 2.5s sleep is essential as obs crashes if you instantly change the profile
	SendInput, {DOWN 7}
	SendInput, {ENTER} ;Changes profile to main stream profile.
	sleep 2000
	WinMove, OBS,,  2553, -892, 1111, 1047 ;Moves obs into position, important for me to keep because streamelements obs is wider and ruins main obs
{ ;this part of the script is just to set the source record hotkey(s) until they fix it
		WinActivate, ahk_exe obs64.exe ;just incase windows loses it
		SendInput, !f
		sleep 100
		SendInput, s
		sleep 2000
		SendInput, {DOWN 5}
		sleep 200
		SendInput, {TAB 55}
		sleep 200
		SendInput, ^+8
		sleep 1000
		SendInput, {TAB}
		SendInput, +{TAB 54}
		sleep 200
		SendInput, {UP}
		SendInput, {TAB}
		SendInput, {ENTER}
		sleep 200
}
	Run, firefox.exe https://docs.google.com/presentation/d/1b6pCuOIrw4pEF6GACxrBh8C-mB4XsDeHLM50cj4jAkQ/edit#slide=id.g90e8195d3c_16_958 ;opens the AM route doc to pauline questions
		if WinExist("ahk_exe firefox.exe")
			WinActivate
		else
			WinWaitActive, ahk_exe firefox.exe
	sleep 1000 ;waits before opening the next tab or firefox derps out
	Run, firefox.exe https://dashboard.twitch.tv/u/tomshi/stream-manager
	sleep 9000 ;if both tabs don't load in, it can mess with trying to separate them
		;{ ;if WinExist("ahk_exe firefox.exe")
			;WinActivate
		;else
			;WinWaitActive, ahk_exe firefox.exe ;the following code was yoinked from taran, it's just a deeper method of calling firefox forwards since sometimes it doesn't focus
			;WinActivatebottom ahk_exe firefox.exe
			;WinGet, hWnd, ID, ahk_class MozillaWindowClass
				;DllCall("SetForegroundWindow", UInt, hWnd) } ;old code, testing ;
			WinActivate ahk_exe firefox.exe
			;WinWaitActive, ahk_exe firefox.exe ;the following code was yoinked from taran, it's just a deeper method of calling firefox forwards since sometimes it doesn't focus
			WinActivatebottom ahk_exe firefox.exe
			WinGet, hWnd, ID, ahk_class MozillaWindowClass
				DllCall("SetForegroundWindow", UInt, hWnd)
	SetKeyDelay, 100
	Send, !d ;opens the alt context menu to begin detatching the firefox tab
	Send, +{TAB 3}
	sleep, 100
	Send, +{F10}
	sleep, 100
	Send, v
	sleep, 100
	Send, w
	sleep, 2000
	WinMove, Twitch,, -6, 0, 1497, 886 ;moves browser tabs into position for stream
	WinMove, All Moons UPDATED v.1.3.0,, 1218, 658, 1347, 747 ;moves browser tabs into position for stream
	;Run, chrome.exe https://dashboard.twitch.tv/u/tomshi/stream-manager only need this if I'm doing something subpoint related
	Run, C:\Program Files\Chatterino\chatterino.exe
	Run, F:\Twitch\lioranboard\LioranBoard Receiver(PC)\LioranBoard Receiver.exe
	Run, C:\Program Files (x86)\foobar2000\foobar2000.exe
	Run, F:\Twitch\Splits\Splits\LiveSplit_1.7.6\LiveSplit.exe
	Run, C:\Users\Tom\AppData\Local\Programs\streamlabels\StreamLabels.exe
	Run, C:\Program Files\ahk\Streamlabs Chatbot.lnk
	;Run, C:\Program Files\Elgato\GameCapture\GameCapture.exe // replaced by source record plugin
	Run, chrome.exe https://www.twitch.tv/popout/tomshi/chat
	WinMove, ahk_exe Discord.exe,, 4480, 432, 1080, 797 ;moves into position
	 ;required for brothers queue program for automatic mii wii playback
if WinExist("ahk_exe Docker Desktop.exe") ;waits until docker is open then brings it into focus
	WinActivate
	sleep 2000
		coordmode, pixel, Window
		coordmode, mouse, Window
		MouseMove, 1128, 130 ;moves mouse to click the start button
		click
sleep 1000
	Run, C:\Program Files\ahk\TomSongQueueue\Builds\ApplicationDj.exe
		if WinExist("ahk_exe ApplicationDj.exe") ;waits until ttp's program is open then brings it into focus
			WinActivate
		else
			WinWaitActive, ahk_exe ApplicationDj.exe
sleep 2000
	SendInput, y{enter}
	Run, F:\Twitch\lioranboard\LioranBoard Receiver(PC)\LioranBoard Receiver.exe ;try to run it again since apparently running it once sometimes isn't enough
    }
else
    sleep 100