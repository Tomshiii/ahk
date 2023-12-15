; { \\ #Includes
;// these includes are only for things directly called within this script, any functions/classes may contain their own includes
#Include <Classes\Move>
#Include <Classes\winget>
#Include <Classes\switchTo>
#Include <Functions\jumpChar>
#Include <Functions\refreshWin>
#Include <Functions\isDoubleClick>
; }
;capsHotkey;
SC03A:: ;double tap capslock to activate it, double tap to deactivate it. We need this hotkey because I have capslock disabled by default
{
	if !isDoubleClick()
		return
	SetCapsLockState !GetKeyState("CapsLock", "T")
}

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

;jump10charLeftHotkey;
SC03A & Left::
;jump10charRightHotkey;
SC03A & Right::jumpChar()

;refreshWinHotkey;
SC03A & F5::refreshWin("A", wingetProcessPath("A"))
;refreshElevateHotkey;
^+F5::refreshWin("A", wingetProcessPath("A"), true)

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		launch programs
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;windowspyHotkey;
Pause::switchTo.WindowSpy() ;run/swap to windowspy
;vscodeHotkey;
PrintScreen::switchTo.VSCode() ;run/swap to vscode
;streamdeckHotkey;
ScrollLock::switchTo.Streamdeck() ;run/swap to the streamdeck program

;This script is to open the ahk documentation. If ctrl is held, highlighted text will be searched
;akhdocuHotkey;
RWin::
;// both are needed here otherwise using ctrl+appskey might fail to work if the active window grabs it first
;ahksearchHotkey;
RShift & RWin::switchTo.ahkDocs()

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;move mouse along one axis
;moveXhotkey;
SC03A & XButton2::
;moveYhotkey;
SC03A & XButton1::move.XorY()

;SubUnderHotkey;
+NumpadSub::_

;extraEnterHotkey;
PgDn::Enter ;// I use a TKL keyboard and miss my NumpadEnter key