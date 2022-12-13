; { \\ #Includes
#Include <Functions\getHotkeys>
; }

/**
 * This function facilitates accelerated scrolling. If the window under the cursor isn't the active window when this function is called, it will activate it.
 *
 * *This function use to send 10 WheelUp/Down events but that just kept lagging everything out no matter what I tried to do to fix it, so now it sends PgUp/Dn*
 */
fastWheel()
{
	getHotkeys(&first, &second)
    if second = "WheelUp"
        type := "Up"
    else
        type := "Dn"
	MouseGetPos(,, &UnderCursor)
	orig := WinGetTitle(WinActive("A"))
	titleUnder := WinGetTitle("ahk_id " UnderCursor)
    classUnder := WinGetClass("ahk_id " UnderCursor)
	if orig != titleUnder && classUnder != "tooltips_class32"
		WinActivate(titleUnder)
    WinWaitActive(titleUnder)
    proc := WinGetProcessName(titleUnder)
    if ((InStr(titleUnder, "Visual Studio Code") && proc = "Code.exe") && !InStr(titleUnder, "Preview"))
        SendInput(focusCode)
	SendInput("{Pg" type "}")
	/* SendInput("{" second " 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
    */
}