; { \\ #Includes
#Include <Functions\delaySI>
; }

;explorerbackHotkey;
F21::SendInput("!{Up}") ;Moves back 1 folder in the tree in explorer

#+F::delaySI(100, "{F11}", "{F11}")