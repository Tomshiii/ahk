;premprojectHotkey;
RAlt & p:: ;This hotkey pulls out the project window and moves it to my second monitor since adobe refuses to just save its position in your workspace
{
	coord.s()
	shiftval := 0
	MouseGetPos(&xpos, &ypos)
	KeyWait("Alt")
	if GetKeyState("Ctrl", "P")
		{
			KeyWait("Ctrl")
			goto added
		}
	if GetKeyState("RShift", "P")
		{
			KeyWait("RShift")
			shiftval := 1
		}
	SendInput(KSA.resetWorkspace)
	sleep 1500
	SendInput(KSA.timelineWindow) ;adjust this shortcut in the ini file
	SendInput(KSA.projectsWindow) ;adjust this shortcut in the ini file
	SendInput(KSA.projectsWindow) ;adjust this shortcut in the ini file
	sleep 300
	WinGetPos(&sanX, &sanY,,, "A")
	;if you have this panel on a different monitor ahk won't be able to find it because of premiere weirdness so this value will be used in some fallback code down below
	coord.w()
	try {
		loop {
			ClassNN := ControlGetClassNN(ControlGetFocus("A"))
			ControlGetPos(&toolx, &tooly, &width, &height, ClassNN)
			/* if ClassNN != "DroverLord - Window Class3"
				break */
			;the window you're searching for can end up being window class 3. Wicked. The function will now attempt to continue on without these values if it doesn't get them as it can still work due to other information we grab along the way
			if A_Index > 5
				{
					;tool.Cust("Function failed to find project window")
					break
				}
		}
	} catch as e {
			tool.Cust("Function failed to find project window")
			errorLog(e)
			return
		}
	;MsgBox("x " toolx "`ny " tooly "`nwidth " width "`nheight " height "`nclass " ClassNN) ;debugging
	block.On()
	try {
		if ImageSearch(&prx, &pry, toolx - 5, tooly - 20, toolx + 1000, tooly + 100, "*2 " ptf.Premiere "project.png") || ImageSearch(&prx, &pry, toolx - 5, tooly - 20, toolx + 1000, tooly + 100, "*2 " ptf.Premiere "project2.png") ;searches for the project window to grab the track
			goto move
		/* else if ImageSearch(&prx, &pry, toolx, tooly, width, height, "*2 " ptf.Premiere "project2.png") ;I honestly have no idea what the original purpose of this line was
			goto bin */
		else
			{
				coord.s()
				if ImageSearch(&prx, &pry, sanX - 5, sanY - 20, sanX + 1000, sanY + 100, "*2 " ptf.Premiere "project.png") || ImageSearch(&prx, &pry, sanX - 5, sanY - 20, sanX + 1000, sanY + 100, "*2 " ptf.Premiere "project2.png") ;This is the fallback code if you have it on a different monitor
					goto move
				else
					throw Error("Couldn't find the project window", -1)
			}
	} catch Error as e {
		block.Off()
		errorLog(e, "If this happens consistently, it may be an issue with premiere", 1)
		return
	}
	move:
	MouseMove(prx+5, pry+3)
	SendInput("{Click Down}")
	coord.s()
	Sleep 100
	MouseMove 3592, 444, 2
	sleep 50
	SendInput("{Click Up}")
	MouseMove(xpos, ypos)
	if shiftval = 1
		{
			block.Off()
			return
		}
	bin:
	if !WinExist("_Editing Stuff")
		{
			Run(ptf.EditingStuff)
			if !WinWaitActive("_Editing Stuff",, 2) && WinExist("_Editing Stuff")
				WinActivate("_Editing Stuff")
			sleep 100
			if !WinActive("_Editing Stuff")
				{
					block.Off()
					errorLog(TargetError("Activating the editing folder failed", -1),, 1)
					return
				}
		}
	else
		{
			WinActivate("_Editing Stuff")
			SendInput("{Up}")
		}
	sleep 250
	if winget.isFullscreen(&title)
		WinRestore(title) ;winrestore will unmaximise it
	newWidth := 1600
	newHeight := 900
	newX := A_ScreenWidth / 2 - newWidth / 2
	newY := newX / 2
	; Move any window that's not the desktop
	try{
		WinMove(newX, newY, newWidth, newHeight, title)
	}
	sleep 250
	coord.w()
	MouseMove(0, 0)
	loop {
		if ImageSearch(&foldx, &foldy, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " ptf.Explorer "sfx.png")
			break
		sleep 100
		if A_Index > 50
			{
				block.Off()
				errorLog(TargetError("Couldn't find the sfx folder in Windows Explorer", -1),, 1)
				return
			}
	}
	MouseMove(foldx + 9, foldy + 5, 2)
	SendInput("{Click Down}")
	;sleep 2000
	coord.s()
	MouseMove(3240, 564, 2)
	SendInput("{Click Up}")
	switchTo.Premiere()
	WinWait("Import Files",, 2)
	WinWaitClose("Import Files", 20)
	sleep 1000
	added:
	coord.w()
	WinActivate(editors.Premiere.winTitle)
	if ImageSearch(&listx, &listy, 10, 3, 1038, 1072, "*2 " ptf.Premiere "list view.png")
		{
			MouseMove(listx, listy)
			SendInput("{Click}")
			sleep 100
		}
	if !ImageSearch(&fold2x, &fold2y, 10, 3, 1038, 1072, "*2 " ptf.Premiere "sfxinproj.png") && !ImageSearch(&fold2x, &fold2y, 10, 3, 1038, 1072, "*2 " ptf.Premiere "sfxinproj2.png")
		{
			block.Off()
			errorLog(TargetError("Couldn't find the sfx folder in Premiere Pro", -1),, 1)
			return
		}
	MouseMove(fold2x + 5, fold2y + 2)
	SendInput("{Click 2}")
	sleep 100
	loop {
		if ImageSearch(&fold3x, &fold3y, 10, 0, 1038, 1072, "*2 " ptf.Premiere "binsfx.png")
			{
				MouseMove(fold3x + 20, fold3y + 4, 2)
				SendInput("{Click Down}")
				MouseMove(772, 993, 2)
				sleep 250
				SendInput("{Click Up Left}")
				break
			}
		if A_Index > 5
			{
				block.Off()
				errorLog(TargetError("Couldn't find the bin", -1),, 1)
				return
			}
	}
	coord.s()
	MouseMove(xpos, ypos)
	block.Off()
}