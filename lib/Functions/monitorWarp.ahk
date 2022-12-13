; { \\ #Includes
#Include <Classes\coord>
; }

/**
 * warp anywhere on your desktop
 */
monitorWarp(x, y)
{
    priorPix := A_CoordModePixel, priorMouse := A_CoordModeMouse
    coord.s()
    MouseMove(x, y, 2) ;I need the 2 here as I have multiple monitors and things can be funky moving that far that fast. random ahk problems. Change this if you only have 1/2 monitors and see if it works fine for you
    A_CoordModePixel := priorPix, A_CoordModeMouse := priorMouse
}