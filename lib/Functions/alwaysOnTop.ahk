; { \\ #Includes
#Include <Classes\errorLog>
; }

/**
 * This function will toggle the desired window (the active window by default) and attempt to draw an orange border around it (`win11` only)
 */
alwaysOnTop(winTitle := "A")
{
    DrawBorder(hwnd, color, enable) {
		if VerCompare(A_OSVersion, "10.0.22000") >= 0
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", 34, "int*", enable ? color : 0xFFFFFFFF, "int", 4)
	}
	tooltipVal := isOnTop()
	isOnTop() {
		try {
			hwnd := WinExist(winTitle)
			title := WinGetTitle(winTitle)
			ExStyle := wingetExStyle(title)
			if(ExStyle & 0x8) {
				DrawBorder(hwnd, 0x1195F5, false)
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