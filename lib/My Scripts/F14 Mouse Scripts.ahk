; { \\ #Includes
#Include <Classes\Move>
#Include <Functions\fastWheel>
; }

;winmaxHotkey;
F14::move.Window() ;maximise

;You can check out \mouse settings.png in the root repo to check what mouse buttons I have remapped
;The below scripts are to accelerate scrolling. If you encounter any slowdowns caused by spamming these two hotkeys, make sure no other hotkeys overlap with the activation script - I previously encountered issues with `showmoreHotkey` when they were both set to the same Fkey
;wheelupHotkey;
F14 & WheelDown::fastWheel()
;wheeldownHotkey;
F14 & WheelUp::fastWheel()