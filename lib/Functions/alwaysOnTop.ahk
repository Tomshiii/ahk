; { \\ #Includes
#Include <Classes\errorLog>
#Include <Classes\winget>
#Include <Functions\drawBorder>
; }

/**
 * This function will toggle the desired window (the active window by default) and attempt to draw an orange border around it (`win11` only)
 * @param {String} winTitle the title of the window you wish to make always on top. Defaults to the active window
 */
alwaysOnTop(winTitle := "A")
{
	tooltipVal := isOnTop()
	isOnTop() {
		try {
			hwnd    := WinExist(winTitle)
			title   := WinGetTitle(winTitle)
			if WinGet.isProc(hwnd)
				return
			ExStyle := wingetExStyle(title)
			if(ExStyle & 0x8) {
				DrawBorder(hwnd)
				return "Active window no longer on top`n" '"' title '"'
			}
			DrawBorder(hwnd, 0x1195F5, true)
			return "Active window now on top`n" '"' title '"'
		} catch as e {
			tool.Cust(A_ThisFunc "() couldn't determine the active window or you're attempting to interact with an ahk GUI")
			errorLog(e)
			Exit()
		}

	}
	tool.Cust(tooltipVal, 2.0)
	WinSetAlwaysOnTop(-1, "A") ;will toggle whether the current window will remain on top
}