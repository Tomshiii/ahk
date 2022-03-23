#Include SD_functions.ahk
location := "E:\Github\ahk"

if not WinExist("ahk_exe obs64.exe")
{
	SetWorkingDir A_ScriptDir
	SetWinDelay 0 ;makes windows move instantly
	DetectHiddenWindows True  ; Allows a script's hidden main window to be detected.
	SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.
	/* if WinExist("autosave.ahk - AutoHotkey")
		WinClose()
	if WinExist("premiere_fullscreen_check.ahk - AutoHotkey")
		WinClose() */
	Run('*RunAs ' location "\Stream\Streaming.ahk")
	Run("C:\Users\Tom\AppData\Local\firebotv5\Firebot v5.exe")
	Run("C:\Program Files\Docker\Docker\frontend\Docker Desktop.exe")
	Result := MsgBox("have you started the goxlr bruh",, "1 4096")
	if Result = "OK"
		{
			goto next
		}
	else
		return
	next:
	Run(location "\shortcuts\obs64.lnk") ;opening shortcuts helps to make sure obs doesn't complain about having an incorrect working directory
		if WinExist("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus
			WinActivate
		else
			WinWaitActive "ahk_exe obs64.exe"
	blockOn()
	sleep 2500 ; you have to wait a while after obs opens before you can start sending it commands or it'll crash
	SendInput("!p") ;Opens alt context menu - The Above 2.5s sleep is essential as obs crashes if you instantly change the profile
	SendInput("{DOWN 7}")
	SendInput("{ENTER}") ;Changes profile to main stream profile.
	sleep 2000
	if WinExist("ahk_exe obs64.exe") ;this part of the script is just to set the source record hotkey(s) until they fix it
		WinActivate "ahk_exe obs64.exe" ;just incase windows loses it
		/*{
			SendInput "!f"
			sleep 100
			SendInput "s"
			sleep 2000
			SendInput "{DOWN 5}"
			sleep 200
			SendInput "{TAB 55}"
			sleep 200
			SendInput(sourceRecord1)
			sleep 1000
			SendInput "{TAB}"
			SendInput "+{TAB 57}"
			sleep 200
			SendInput "{UP}{ENTER}"
			sleep 200
		} */
		;not using this currently
	obsLocation() ;Moves obs into position
/* 	Run "firefox.exe https://docs.google.com/presentation/d/1b6pCuOIrw4pEF6GACxrBh8C-mB4XsDeHLM50cj4jAkQ/edit#slide=id.g90e8195d3c_16_958" ;opens the AM route doc to pauline questions
		if WinExist("ahk_exe firefox.exe")
			WinActivate
		else
			WinWaitActive "ahk_exe firefox.exe"
	sleep 1000 ;waits before opening the next tab or firefox derps out */
	Run("firefox.exe https://dashboard.twitch.tv/u/tomshi/stream-manager")
	sleep 1000
	Run("firefox.exe https://yoink.streamelements.com/activity-feed?activitiesToolbar=false&popout=true&theme=dark&withSetupWizard=false")
	sleep 9000 
	if WinExist("ahk_exe firefox.exe")
		{
			WinActivate
			SetKeyDelay 100
			Send("!d") ;opens the alt context menu to begin detatching the firefox tab
			sleep 100
			Send("+{TAB 3}")
			sleep 100
			Send("+{F10}")
			sleep 100
			Send("v")
			sleep 100
			Send("w")
			sleep 1500
		}
/* 	if WinExist("Twitch")
		{
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
			sleep 1500
		} */
	WinWait("Twitch", , 10) ;moves browser tabs into position for stream
		WinMove(-7, 0, 1497, 886)
	;WinWait("All Moons UPDATED v.1.3.0", , 10) ;moves browser tabs into position for stream
	;	WinMove 1218, 658, 1347, 747
	if WinExist("StreamElements")
		{
			WinActivate
			streamelementsLocation()
		}
	if WinExist("ahk_exe Docker Desktop.exe") ;waits until docker is open then brings it into focus
		{
			blockOn()
			WinActivate("ahk_exe Docker Desktop.exe")
			WinWaitActive("ahk_exe Docker Desktop.exe")
			sleep 1500
			coordmode("pixel", "Window")
			coordmode("mouse", "Window")
			MouseMove(1102, 129) ;moves mouse to click the start button
			sleep 1000
			SendInput("{Click}") ;required for brothers queue program for automatic mii wii playback
			sleep 2000
			blockOff()
			WinMinimize()
		}
	else
		{
			WinWaitActive("ahk_exe Docker Desktop.exe")
			sleep 1500
			blockOn()
			WinActivate("ahk_exe Docker Desktop.exe")
			coordmode("pixel", "Window")
			coordmode("mouse", "Window")
			MouseMove(1102, 129) ;moves mouse to click the start button
			sleep 1000
			SendInput("{Click}") ;required for brothers queue program for automatic mii wii playback
			sleep 2000
			blockOff()
			WinMinimize()
		}
	blockOff()
	Run location "\TomSongQueueue\Builds\ApplicationDj.exe"
	sleep 2500 ;it needed some time to open
	blockOn()
	if WinExist("ahk_exe ApplicationDj.exe") ;waits until ttp's program is open then brings it into focus
		WinActivate
	sleep 500
	SendInput("y{enter}")
	if WinExist("ahk_exe Firebot v5.exe")
		{
			WinActivate("ahk_exe Firebot v5.exe")
			WinWaitActive("ahk_exe Firebot v5.exe")
			coordw()
			MouseMove(29, 677)
			click
			sleep 1500
			WinMinimize()
		}
	blockOff()
	;Run, chrome.exe https://dashboard.twitch.tv/u/tomshi/stream-manager only need this if I'm doing something subpoint related
	Run("C:\Program Files (x86)\foobar2000\foobar2000.exe")
	Run("F:\Twitch\Splits\Splits\LiveSplit_1.7.6\LiveSplit.exe")
	;Run, C:\Program Files\Elgato\GameCapture\GameCapture.exe // replaced by source record plugin
	Run("chrome.exe https://www.twitch.tv/popout/tomshi/chat")
	if WinExist("ahk_exe Discord.exe")
		discordLocation()
	SetWorkingDir "F:\Twitch\lioranboard\LioranBoard Receiver(PC)"
	Run("F:\Twitch\lioranboard\LioranBoard Receiver(PC)\LioranBoard Receiver.exe")
	if WinExist("ahk_exe ApplicationDj.exe")
		{
			WinMinimize()
		}
	blockOn()
	sleep 3000
	if WinExist("ahk_exe foobar2000.exe")
		{
			WinActivate("ahk_exe foobar2000.exe")
			WinWaitActive("ahk_exe foobar2000.exe")
			sleep 1000
			WinGetPos(,, &width, &height, "A")
			MouseGetPos(&x, &y)
			if ImageSearch(&xdir, &ydir, 0, 0, %&width%, %&height%, "*2 " location "\ImageSearch\Foobar\streambeats.png")
				{
					MouseMove(%&xdir%, %&ydir%)
					SendInput("{Click}")
				}
			SendInput("!p" "a")
			MouseMove(%&x%, %&y%)
		}
	blockOff()
	if WinExist("ahk_exe LioranBoard Receiver.exe")
		{
			WinWait("ahk_exe LioranBoard Receiver.exe",, 3)
			WinMinimize()
		}
}
else
    return
ExitApp