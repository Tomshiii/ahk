#Include SD_functions.ahk
if not WinExist("ahk_exe obs64.exe")
	{
		Run '*RunAs ' location "\Stream\Streaming.ahk"
		Run "C:\Program Files\Chatterino\chatterino.exe"
		;MsgBox("have you opened the goxlr stuff yet bud",, "262144")
		if not WinExist("ahk_exe GoXLR App.exe")
			Run("C:\Program Files (x86)\TC-Helicon\GOXLR\GoXLR App.exe")
		Run location "\shortcuts\obs64.lnk" ;opening shortcuts helps to make sure obs and ahk have the same admin level so ahk can interact with it, otherwise obs wont accept inputs
		WinWaitActive("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus.
		obsLocation()
		sleep 3000 ;waits a little bit once obs has opened so it doesn't crash
		coords()
		MouseGetPos &xposP, &yposP
		blockOn()
		WinActivate("ahk_exe obs64.exe")
		SendInput "!p"
		sleep 200
		SendInput "{DOWN 6}"
		sleep 200
		SendInput "{ENTER}"
		coords()
		blockOff()
		if WinExist("ahk_exe chatterino.exe")
			{
				chatterinoLocationBotshi()
				WinActivate("ahk_exe chatterino.exe")
				coordw()
				WinGetPos(,, &width, &height, "A")
				if ImageSearch(&xpos, &ypos, 0, 0, %&width%, %&height%/ "3", "*2 " Chatterino "botshiactive.png")
					{
						;toolCust("it thinks it's active", "1000") ;debugging
						coords()
						MouseMove(%&xposP%, %&yposP%)
						return
					}
				else 
					if ImageSearch(&xpos, &ypos, 0, 0, %&width%, %&height%/ "3", "*2 " Chatterino "botshinotactive.png")
					{
						;toolCust("it thinks it's not active", "1000") ;debugging
						MouseMove(%&xpos%, %&ypos%)
						SendInput("{Click}")
						coords()
						MouseMove(%&xposP%, %&yposP%)
						return
					}
			}
	}
ExitApp