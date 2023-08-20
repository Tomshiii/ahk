; { \\ #Includes
#Include <Classes\coord>
#Include <Classes\winget>
#Include <Classes\switchTo>
#Include <Classes\errorLog>
; }

/**
 * Searches for the yt logo on your tab bar, then selects it and inputs a space to play/pause
 */
pauseYT() {
	coord.s()
	MouseGetPos(&x, &y)
	coord.w()
	SetTitleMatchMode 2
	needle := "YouTube"
	winget.Title(&title)
	if InStr(title, needle)
		{
			if InStr(title, "Subscriptions - YouTube", 1) || title = "YouTube"
				{
					SendInput("{Media_Play_Pause}")
					return
				}
			SendInput("{Space}")
			return
		}
	else loop {
		wingetPos(,, &width,, "A")
		if ytPos := obj.imgSrchMulti({x1: 0, y1:0, x2: width, y2: 60},,,, ptf.firefox "youtube1.png", ptf.firefox "youtube2.png", ptf.firefox "youtube3.png") {
			MouseMove(ytPos.x, ytPos.y, 2) ;2 speed is only necessary because of my multiple monitors - if I start my mouse in a certain position, it'll get stuck on the corner of my main monitor and close the firefox tab
			SendInput("{Click}")
			coord.s()
			MouseMove(x, y, 2)
			break
		}
		switchTo().__OtherFirefoxWindow()
		if A_Index > 5
			{
				tool.Cust("Couldn't find a youtube tab")
				try {
					WinActivate(title) ;reactivates the original window
				} catch as e {
					tool.Cust("Failed to get information on last active window")
					errorLog(e)
				}
				SendInput("{Media_Play_Pause}") ;if it can't find a youtube window it will simply send through a regular play pause input
				return
			}
	}
	SendInput("{Space}")
}