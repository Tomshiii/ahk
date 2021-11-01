coords() ;sets coordmode to "screen"
{
	coordmode "pixel", "screen"
	coordmode "mouse", "screen"
}
coordw() ;sets coordmode to "window"
{
	coordmode "pixel", "window"
	coordmode "mouse", "window"
}
blockOn() ;blocks all user inputs
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
	;it has recently come to my attention that all 3 of these operate independantly and doing all 3 of them at once is no different to just using "BlockInput "on"" but uh. oops, too late now I guess 
}

blockOff() ;turns off the blocks on user input
{
	blockinput "MouseMoveOff"
	BlockInput "off"
}
toolFind(message, timeout) ;create a tooltip for errors finding things
;&message is what you want the tooltip to say after "couldn't find"
;&timeout is how many ms you want the tooltip to last
{
	ToolTip("couldn't find " %&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}

toolCust(message, timeout) ;create a tooltip with any message
;&message is what you want the tooltip to say
;&timeout is how many ms you want the tooltip to last
{
	ToolTip(%&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}

dock() ;a function for Start Main Stream.ahk
{
	sleep 1500
	coordmode "pixel", "Window"
	coordmode "mouse", "Window"
	MouseMove 1128, 130 ;moves mouse to click the start button
	click ;required for brothers queue program for automatic mii wii playback
	sleep 1000
	WinMinimize()
}