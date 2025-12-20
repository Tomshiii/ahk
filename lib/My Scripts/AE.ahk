; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\winget.ahk
#Include Classes\Editors\After Effects.ahk
#Include Functions\mouseDrag.ahk
; }

;aetimelineHotkey;
Xbutton1::ae.timeline() ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aeselectionHotkey;
Xbutton2::mouseDrag(KSA.handAE, KSA.selectionAE) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aepreviousframeHotkey;
F21::SendInput(KSA.previousKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys
;aenextframeHotkey;
F23::SendInput(KSA.nextKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys


$+3::ae.zoomCompWindow({x:0, y:0, x2: 738, y2: 29}, A_ThisHotkey, 1)

Space::
{
	switch getTitle := WinGet.Title() {
		case "Color":
			if !CaretGetPos(&x, &y) {
				SendInput("{Enter}")
				return
			}
	}
	SendInput("{Space}")
}