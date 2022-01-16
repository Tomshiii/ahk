If WinActive("ahk_exe Adobe Premiere Pro.exe")
	{
		;select the track you wish to push to audition then watch as it does it automatically
		SendInput "{Click Right}"
		sleep 200
		SendInput "{Down 8}" ;menus down to send to adobe audition
		sleep 200
		SendInput "{Enter}"
		if WinExist("ahk_exe Adobe Audition.exe") ;waits until audition opens
			WinActivate
		else
			WinWaitActive "ahk_exe Adobe Audition.exe"
		sleep 4000 ;audition is slow asf to load
		if WinExist("ahk_exe Adobe Audition.exe")		
			WinMaximize "ahk_exe Adobe Audition.exe" ;for whatever reason audition opens windowed sometimes, this just forces fullscreen
		sleep 4000 ;audition is slow asf to load
		coordmode "pixel", "Screen"
		coordmode "mouse", "Screen"
		BlockInput "SendAndMouse"
		BlockInput "MouseMove"
		BlockInput "On"
		MouseGetPos &xposP, &yposP
		MouseMove 1192, 632 ;moves the mouse to the middle of MY screen
		SendInput "{click}" ;clicks in the middle of the screen to ensure the current audio is actually selected, audition is just jank as hell and it's easier to just add this step than to deal with it not working sometimes
		sleep 1000
		MouseMove 301, 373 ;moves the mouse to the preset selector
		SendInput "{Click}l{DOWN 3}{ENTER}" ;menus to the limit preset I have
		sleep 100
		MouseMove 80, 714
		SendInput "{Click}"
		sleep 2200
		SendInput "!rnn{ENTER}" ;menus to the normalise preset in the alt menu
		sleep 2200
		MouseMove 1192, 632 ;moves back to the middle of the screen and clicks
		SendInput "{click}"
		SendInput "^s" ;saves so the changes translate over to premiere
		MouseMove %&xposP%, %&yposP%
		blockinput "MouseMoveOff"
		BlockInput "off"
		WinMinimize "ahk_exe Adobe Audition.exe" ;minimises audition and reactivates premiere
		WinActivate "ahk_exe Adobe Premiere Pro.exe"
	}
else
    sleep 100
ExitApp