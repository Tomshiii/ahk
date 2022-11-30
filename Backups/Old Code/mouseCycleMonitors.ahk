;This code never got published anywhere but will mousemove between all monitors (note: it'll cycle between the order found in windows display settings) it'll then jiggle the mouse to show you where it is

#Include <Classes\winget>

F18::
{
	coord.s()
	numberofMonitors := SysGet(80)
	monitor := WinGet.MouseMonitor()
	if monitor.monitor + 1 <= numberofMonitors
		which := monitor.monitor + 1
	else
		which := 1
	MonitorGet(which, &left, &Top, &Right, &Bottom)

	newX := ((left) + (right))/2
	newY := ((top) + (bottom))/2
	MouseMove(newX, newY)

	detectVal := A_DetectHiddenWindows
	DetectHiddenWindows(0)
	if WinExist("ahk_class tooltips_class32")
		{
			title := WinGetTitle("ahk_class tooltips_class32")
			if InStr(title, "Cursor moved to monitor: ")
				ToolTip("")
		}
	DetectHiddenWindows(detectVal)
	tool.Cust("Cursor moved to monitor: " which, 3.0,, A_ScreenWidth-220, A_ScreenHeight-110)
	MouseGetPos(&xval, &yval)
	loop 15 {
		valX := Random(xval, xval+30)
		valY := Random(yval, yval+30)
		MouseMove(valX, valY, 2)
	}
}