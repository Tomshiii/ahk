; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\After Effects>
#Include <Functions\mouseDrag>
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