#Hotstring
#SingleInstance Force

; This script will continue to be a long term work in progress and will move quite slowling in comparison to everything else

#a:: ;win + a opens notepad to edit this script
{
	if WinExist("ahk_exe notepad.exe") ;if vscode exists it'll simply activate it, if it doesn't, it'll open it
			WinActivate
	else
		Run 'notepad.exe  "C:\Program Files\ahk\textreplace.ahk"' ;opens in vscode (how I edit it)
}
#+r:: ;win + r reloads this script
{
	Reload
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	;MsgBox "The script could not be reloaded. Would you like to open it for editing?",, 4
	Result := MsgBox("The script could not be reloaded. Would you like to open it for editing?",, 4)
		if Result = "Yes"
			{
				if WinExist("ahk_exe Code.exe")
						WinActivate
				else
					Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe"
			}
}
;========================================
; HOTSTRINGS
;========================================
;----------------------------------------
; TWITCH EMOTES
;----------------------------------------
:*:omega::omegalul
:*:oemg::omegalul
:*:pepela::pepeLaugh
:*:pogg::poggies

;----------------------------------------
; TEXT CORRECTIONS
;----------------------------------------
:*:couldnt::couldn't
:*:wouldnt::wouldn't
:*:shouldnt::shouldn't

;----------------------------------------
; AUTOCORRECT
;----------------------------------------
::tyope::type