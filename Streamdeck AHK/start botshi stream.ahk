#Include SD_functions.ahk
if !WinExist("ahk_exe obs64.exe")
	{
		Run(location "\Stream\Streaming.ahk")
		Run("C:\Program Files\Chatterino\chatterino.exe")
		;MsgBox("have you opened the goxlr stuff yet bud",, "262144")
		/* if !WinExist("ahk_exe GoXLR App.exe") ;I don't use the goxlr anymore
			Run("C:\Program Files (x86)\TC-Helicon\GOXLR\GoXLR App.exe") */
		Run(location "\Support Files\shortcuts\obs64.lnk") ;opening shortcuts helps to make sure obs and ahk have the same admin level so ahk can interact with it, otherwise obs wont accept inputs
		WinWaitActive("ahk_exe obs64.exe") ;waits until obs is open then brings it into focus.
		obsLocation()
		sleep 3000 ;waits a little bit once obs has opened so it doesn't crash
		coord.s()
		MouseGetPos &xposP, &yposP
		block.On()
		WinActivate("ahk_exe obs64.exe")
		SendInput "!p"
		sleep 200
		SendInput "{DOWN 6}"
		sleep 200
		SendInput "{ENTER}"
		coord.s()
		block.Off()
		if WinExist("ahk_exe chatterino.exe")
			{
				chatterinoLocationBotshi()
				WinActivate("ahk_exe chatterino.exe")
				coord.w()
				WinGetPos(,, &width, &height, "A")
				if ImageSearch(&xpos, &ypos, 0, 0, width, height/ "3", "*2 " ptf.Chatterino "botshinotactive.png")
					{
						MouseMove(xpos, ypos)
						SendInput("{Click}")
					}
				coord.s()
				MouseMove(xposP, yposP)
			}
	}