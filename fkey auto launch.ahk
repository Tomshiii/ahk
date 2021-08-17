;https://www.youtube.com/watch?v=OqyQABySV8k
#SingleInstance Force
TraySetIcon("C:\Program Files\ahk\ahk\Icons\Flaunch.png")
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0

HotIfWinActive
F1::
{
;switchToExplorer(){
if not WinExist("ahk_class CabinetWClass")
	Run "explorer.exe"
GroupAdd "taranexplorers", "ahk_class CabinetWClass"
if WinActive("ahk_exe explorer.exe")
	GroupActivate "taranexplorers", "r"
else
	if WinExist("ahk_class CabinetWClass")
	WinActivate "ahk_class CabinetWClass" ;you have to use WinActivatebottom if you didn't create a window group.
}

F2::
{
;switchToPremiere(){
if not WinExist("ahk_class Premiere Pro")
	{
	;Run, Adobe Premiere Pro.exe
	;Adobe Premiere Pro CC 2017
	; Run, C:\Program Files\Adobe\Adobe Premiere Pro CC 2017\Adobe Premiere Pro.exe ;if you have more than one version instlaled, you'll have to specify exactly which one you want to open.
	Run "Adobe Premiere Pro.exe"
	}
else
	if WinExist("ahk_class Premiere Pro")
	WinActivate "ahk_class Premiere Pro"
}


F3::
{
;switchToFirefox(){
sendinput "{SC0E8}" ;scan code of an unassigned key. Do I NEED this?
if not WinExist("ahk_class MozillaWindowClass")
	Run "firefox.exe"
if WinActive("ahk_exe firefox.exe")
	{
	Class := WinGetClass("A")
	;WinGetClass class, A
	if (class = "Mozillawindowclass1")
		msgbox "this is a notification"
	}
if WinActive("ahk_exe firefox.exe")
	Send "^{tab}"
else
	{
	;WinRestore ahk_exe firefox.exe
	WinWaitActive "ahk_exe firefox.exe"
	;sometimes winactivate is not enough. the window is brought to the foreground, but not put into FOCUS.
	;the below code should fix that.
	;Controls := WinGetControlsHwnd("ahk_class MozillaWindowClass")
	;WinGet hWnd ID ahk_class MozillaWindowClass
	;Result := DllCall("SetForegroundWindow UInt hWnd")
	;DllCall("SetForegroundWindow" UInt hWnd) 
	}
}

!F3::
{
;switchToOtherFirefoxWindow(){
;sendinput, {SC0E8} ;scan code of an unassigned key

;Process Exist firefox.exe
;msgbox errorLevel `n%errorLevel%
	If (PID := ProcessExist("firefox.exe"))
	{
	GroupAdd "taranfirefoxes", "ahk_class MozillaWindowClass"
	if WinActive("ahk_class MozillaWindowClass")
		GroupActivate "taranfirefoxes", "r"
	else
		WinActivate "ahk_class MozillaWindowClass"
	}
	else
	Run "firefox.exe"
}

RWin::
{
;switchToVSCodehub(){
if not WinExist("ahk_exe Code.exe")
	Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe"
GroupAdd "taranCode", "ahk_class Chrome_WidgetWin_1"
if WinActive("ahk_exe Code.exe")
	GroupActivate "taranCode", "r"
else
	if WinExist("ahk_exe Code.exe")
	WinActivate "ahk_exe Code.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

F8::
{
;switchToGithub(){
if not WinExist("ahk_exe GitHubDesktop.exe")
	Run "C:\Users\Tom\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
GroupAdd "tarangit", "ahk_class Chrome_WidgetWin_1"
if WinActive("ahk_exe GitHubDesktop.exe")
	GroupActivate "tarangit", "r"
else
	if WinExist("ahk_exe GitHubDesktop.exe")
	WinActivate "ahk_exe GitHubDesktop.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

F9::
{
;switchToStreamdeck(){
if not WinExist("ahk_exe StreamDeck.exe")
	Run "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"
GroupAdd "taranstream", "ahk_class Qt5152QWindowIcon"
if WinActive("ahk_exe StreamDeck.exe")
	GroupActivate "taranstream", "r"
else
	if WinExist("ahk_exe Streamdeck.exe")
	WinActivate "ahk_exe StreamDeck.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}
