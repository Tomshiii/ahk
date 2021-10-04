if not WinExist("ahk_exe obs64.exe")
{
;F16:: ;opens streamelements obs and swaps to botshi profile
	Run '*RunAs "C:\Program Files\ahk\ahk\Stream\Streaming.ahk"'
	MsgBox("have you opened the goxlr stuff yet bud")
	Run "C:\Program Files\ahk\ahk\shortcuts\BOTSHI.lnk" ;opening shortcuts helps to make sure obs and ahk have the same admin level so ahk can interact with it, otherwise obs wont accept inputs
	;Run, C:\Program Files\ahk\obs64.lnk
		WinWait "ahk_exe obs64.exe" ;waits until obs is open then brings it into focus. obs live fucked up their integration so you have to physically click on obs live before you can input alt commands. Thanks obs live
		sleep 3000 ;waits a little bit once obs has opened so it doesn't crash
coordmode "pixel", "Window"
coordmode "mouse", "Window"
BlockInput "SendAndMouse"
BlockInput "MouseMove"
BlockInput "On"
MouseGetPos &xposP, &yposP
	MouseMove 457, 928
	SendInput "{Click}!p" ;I have to physically click on streamelements obs before it will accept any inputs, I have no idea why, this didn't happen originally but started happening in obs 27
	sleep 200 ;either these sleeps are necessary, or every SendInput needs to be on a separate line, obs can't take inputs that fast and breaks
	SendInput "{DOWN 6}"
	sleep 200
	SendInput "{ENTER}"
MouseMove %&xposP%, %&yposP%
blockinput "MouseMoveOff"
BlockInput "off"
}
else
    sleep 100
ExitApp