; { \\ #Includes
#Include <Classes\winget>
#Include <Classes\Move>
; }

;the below disables the numpad on youtube so you don't accidentally skip around a video
;numpadytHotkey;
Numpad0::
Numpad1::
Numpad2::
Numpad3::
Numpad4::
Numpad5::
Numpad6::
Numpad7::
Numpad8::
Numpad9::
{
	SetTitleMatchMode 2
	needle := "YouTube"
	ignore := "YouTube Studio"
	winget.Title(&title)
	if (InStr(title, needle) && !InStr(title, ignore))
		return
	SendInput("{" A_ThisHotkey "}")
}