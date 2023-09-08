; { \\ #Includes
#Include <Functions\getHotkeys>
#Include <Classes\obj>
; }

/**
 * This function facilitates accelerated scrolling. If the window under the cursor isn't the active window when this function is called, it will activate it
 */
fastWheel() {
	getHotkeys(&first, &second)
	try {
		cursor := obj.MousePos()
		orig := WinGetTitle(WinActive("A"))
		titleUnder := WinGetTitle("ahk_id " cursor.win)
		classUnder := WinGetClass("ahk_id " cursor.win)
		if orig != titleUnder && classUnder != "tooltips_class32"
			WinActivate(titleUnder)
		SendInput("{" second " 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
	}
}