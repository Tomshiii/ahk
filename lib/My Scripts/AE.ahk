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
Xbutton2::mouseDrag(KSA.ae.handTool, KSA.ae.selectionTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aepreviousframeHotkey;
F21::SendInput(KSA.ae.previousKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys
;aenextframeHotkey;
F23::SendInput(KSA.ae.nextKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys


$+3::ae.setViewerZoom()

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

SC03A & v::ae.selectTool("Selection Tool")