﻿; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\coord>
#Include <Classes\block>
#Include <Functions\SD Functions\win_locations>
; }

if WinExist("ahk_exe obs64.exe")
{
	SetWorkingDir A_ScriptDir
	SetWinDelay 0 ;makes windows move instantly
	Run(ptf["StreamAHK"])
	/* if !WinExist("ahk_exe GoXLR App.exe") ;I don't use the goxlr anymore
		Run(ptf.ProgFi32 "\TC-Helicon\GOXLR\GoXLR App.exe") */
	Run(ptf.LocalAppData "\firebotv5\Firebot v5.exe")
	Run(ptf.ProgFi "\Docker\Docker\frontend\Docker Desktop.exe")
	/* Result := MsgBox("have you started the goxlr bruh",, "1 4096")
	if Result = "OK"
		{
			goto next
		}
	else
		return
	next: */
	Run(ptf["OBS"]) ;opening shortcuts helps to make sure obs doesn't complain about having an incorrect working directory
		if WinExist("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus
			WinActivate
		else
			WinWaitActive("ahk_exe obs64.exe")
	block.On()
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
			SendInput(KSA.sourceRecord1)
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
		if WinExist(browser.firefox.winTitle)
			WinActivate
		else
			WinWaitActive browser.firefox.winTitle
	sleep 1000 ;waits before opening the next tab or firefox derps out */
	Run("firefox.exe https://dashboard.twitch.tv/u/tomshi/stream-manager")
	sleep 1000
	Run("firefox.exe https://yoink.streamelements.com/activity-feed?activitiesToolbar=false&popout=true&theme=dark&withSetupWizard=false")
	sleep 9000
	if WinExist(browser.firefox.winTitle)
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
			block.On()
			WinActivate("ahk_exe Docker Desktop.exe")
			WinWaitActive("ahk_exe Docker Desktop.exe")
			sleep 1500
			coordmode("pixel", "Window")
			coordmode("mouse", "Window")
			MouseMove(1102, 129, 3) ;moves mouse to click the start button
			sleep 1000
			SendInput("{Click}") ;required for brothers queue program for automatic mii wii playback
			sleep 2000
			block.Off()
			WinMinimize()
		}
	else
		{
			WinWaitActive("ahk_exe Docker Desktop.exe")
			sleep 1500
			block.On()
			WinActivate("ahk_exe Docker Desktop.exe")
			coordmode("pixel", "Window")
			coordmode("mouse", "Window")
			MouseMove(1102, 129) ;moves mouse to click the start button
			sleep 1000
			SendInput("{Click}") ;required for brothers queue program for automatic mii wii playback
			sleep 2000
			block.Off()
			WinMinimize()
		}
	block.Off()
	Run(ptf["SongDJ"])
	sleep 2500 ;it needed some time to open
	block.On()
	if WinExist("ahk_exe ApplicationDj.exe") ;waits until ttp's program is open then brings it into focus
		WinActivate
	sleep 500
	SendInput("y{enter}")
	if WinExist("ahk_exe Firebot v5.exe")
		{
			WinActivate("ahk_exe Firebot v5.exe")
			WinWaitActive("ahk_exe Firebot v5.exe")
			coord.w()
			MouseMove(29, 677)
			click
			sleep 1500
			WinMinimize()
		}
	block.Off()
	;Run, chrome.exe https://dashboard.twitch.tv/u/tomshi/stream-manager only need this if I'm doing something subpoint related
	Run(ptf.ProgFi32 "\foobar2000\foobar2000.exe")
	Run(ptf["LiveSplit"])
	;Run, ptf.ProgFi "\Elgato\GameCapture\GameCapture.exe // replaced by source record plugin
	Run("chrome.exe https://www.twitch.tv/popout/tomshi/chat")
	if WinExist("ahk_exe Discord.exe")
		discordlocation()
	SetWorkingDir(ptf.LioranBoardDir)
	Run(ptf["LioranBoard"])
	if WinExist("ahk_exe ApplicationDj.exe")
		{
			WinMinimize()
		}
	block.On()
	sleep 3000
	if WinExist("ahk_exe foobar2000.exe")
		{
			WinActivate("ahk_exe foobar2000.exe")
			WinWaitActive("ahk_exe foobar2000.exe")
			sleep 1000
			WinGetPos(,, &width, &height, "A")
			MouseGetPos(&x, &y)
			if ImageSearch(&xdir, &ydir, 0, 0, width, height, "*2 " ptf.ImgSearch "\Foobar\streambeats.png")
				{
					MouseMove(xdir, ydir)
					SendInput("{Click}")
				}
			SendInput("!p" "a")
			MouseMove(x, y)
		}
	block.Off()
	if WinExist("ahk_exe LioranBoard Receiver.exe")
		{
			WinWait("ahk_exe LioranBoard Receiver.exe",, 3)
			WinMinimize()
		}
}