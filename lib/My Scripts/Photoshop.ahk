; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Photoshop>
#Include <Functions\mouseDrag>
; }

;pngHotkey;
^+p::ps.Type("png") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
;jpgHotkey;
^+j::ps.Type("jpg") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a jpg instead of the default psd

;photopenHotkey;
XButton1::mouseDrag(KSA.handTool, KSA.penTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;photoselectHotkey;
Xbutton2::mouseDrag(KSA.handTool, KSA.selectionTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;photozoomHotkey;
z::mouseDrag(KSA.zoomTool, KSA.selectionTool) ;changes the tool to the zoom tool while z button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys