; { \\ #Includes
#Include <Classes\winget>
#Include <Classes\Move>
#Include <Functions\pauseYT>
; }

;pauseyoutubeHotkey;
Media_Play_Pause::pauseYT() ;pauses youtube video if there is one.


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

;movetabHotkey;
XButton2:: ;these two hotkeys are activated by right clicking on a tab then pressing either of the two side mouse buttons
;movetab2Hotkey;
XButton1::move.Tab()