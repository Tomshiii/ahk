; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Classes\clip.ahk
#Include Classes\Move.ahk
#Include Classes\clipStorage.ahk
#Include Functions\fastWheel.ahk
#Include Functions\youMouse.ahk
#Include Functions\alwaysOnTop.ahk
; }

;winleftHotkey;
XButton2::move.Window("#{Left}") ;snap left
;winrightHotkey;
XButton1::move.Window("#{Right}") ;snap right
;winminHotkey;
RButton::move.Window() ;minimise

/* z & -::
z & =::
z & Up::
z & Down::move.adjust("y")
z::z
x & -::
x & =::
x & Left::
x & Right::move.adjust()
x::x */

;alwaysontopHotkey;
^SPACE::alwaysOnTop()

;searchgoogleHotkey;
^+c::clip.search("https://duckduckgo.com/?t=ffab&q=", "firefox.exe") ;runs a google search of highlighted text

~^c::
{
	if !WinActive("ahk_class #32770 ahk_exe AutoHotkey64.exe")
    	return
	sleep 25
	split := StrSplit(A_Clipboard, "`n")
	try SplitPath(split[2],,, &ext)
	catch {
		return
	}
	if split[1] != "---------------------------`r" && ext != "ahk"
		return
	split.RemoveAt(split.Length-3, 3)
	split.RemoveAt(1, 3)
	newStr := ""
	loop split.Length {
		newStr .= split[A_Index]
	}
	A_Clipboard := newStr
}

;capitaliseHotkey;
SC03A & c::clip.capitilise()

;timeHotkey;
^+t::
{
	if WinActive("ahk_group Browsers") && !WinActive("ahk_class #32770")
		{
			SendInput(A_ThisHotkey)
			return
		}
	SendInput(A_YYYY "-" A_MM "-" A_DD)
}

!d::
{
	if !WinExist("Tracked Ideas · Planned Changes")
		Run("https://github.com/users/Tomshiii/projects/1")
}

;extraEnterHotkey;
PgDn::Enter ;// I use a TKL keyboard and miss my NumpadEnter key

^#`::clipStorage.clearAll()
LWin & Escape::clipStorage.open()

#1::
#2::
#3::
#4::
#5::clipStorage.send()

^#1::
^#2::
^#3::
^#4::
^#5::clipStorage.store()

;centreHotkey;
#c::move.winCenter(1.25)
#+c::move.winCenterWide()

;fullscreenHotkey;
#f:: ;this hotkey will fullscreen the active window if it isn't already. If it is already fullscreened, it will pull it out of fullscreen
{
	if !winget.isFullscreen(&title)
		WinMaximize(title)
	else
		WinRestore(title) ;winrestore will unmaximise it
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;You can check out \mouse settings.png in the root repo to check what mouse buttons I have remapped

;The below scripts are to swap between virtual desktops
;// leaving them as sendinputs stops ;winleft; & ;winright; from firing twice..? ahk is weird
;virtualrightHotkey;
F19 & XButton2::SendInput("^#{Right}")
;virtualleftHotkey;
F19 & XButton1::SendInput("^#{Left}")

;The below scripts are to skip ahead in the youtube player with the mouse
;youskipbackHotkey;
F21::youMouse("j", "{Left}")
;youskipforHotkey;
F23::youMouse("l", "{Right}")