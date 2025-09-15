; { \\ #Includes
#Include <Classes\obj>
#Include <Classes\coord>
; }

~<^Space::
{
	if !DirExist(A_AppData "\Knights of the Editing Table\excalibur") {
		return
	}
	if !WinWait("ahk_class PLUGPLUG_UI_NATIVE_WINDOW_CLASS_NAME",, 2) {
		return
	}
	coord.s()
	currMouse := obj.MousePos()
	currWin := obj.WinPos("ahk_class PLUGPLUG_UI_NATIVE_WINDOW_CLASS_NAME")
	WinMove(currMouse.x-(currWin.width/2), currMouse.y-currWin.height)
}