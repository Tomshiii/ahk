;showmoreHotkey;
F18:: ;open the "show more options" menu in win11
{
	;// I think I may have just changed my registry to always pull up the old menu within windows
	;// and so I don't ever use this hotkey anymore and can't guarantee it even still functions
	;Keep in mind I use dark mode on win11. Things will be different in light mode/other versions of windows
	if GetKeyState("LButton", "P") ;this is here so that moveWin() can function within windows Explorer. It is only necessary because I use the same button for both scripts.
		{
			SendInput("{LButton Up}")
			WinMaximize
			return
		}
	MouseGetPos(&mx, &my)
	wingetPos(,, &width, &height, "A")
	colour1 := 0x4D4D4D ;when hovering a folder
	colour2 := 0xFFDA70
	colour3 := 0x353535 ;when already clicked on
	colour4 := 0x777777 ;when already clicked on
	colour := PixelGetColor(mx, my)
	if ImageSearch(&x, &y, 0, 0, width, height, "*5 " ptf.Explorer "showmore.png")
		{
			;tool.Cust(colour "`n imagesearch fired") ;for debugging
			;SendInput("{Esc}")
			;SendInput("{Click}")
			if colour = colour1 || colour = colour2
				{
					;SendInput("{Click}")
					SendInput("{Esc 3}" "+{F10}")
				}
			else
				SendInput("{Esc}" "+{F10}" "+{F10}")
			return
		}
	switch colour {
		case colour1, colour2:
			SendInput("{Click}")
			SendInput("{Esc}" "+{F10}")
			return
		default:
			SendInput("{Esc}" "+{F10}")
			return
	}
}