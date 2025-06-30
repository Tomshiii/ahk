; { \\ #Includes
#Include <Classes\ptf>
;

MButton::
Escape::
{
    MouseGetPos(,, &underMouse)
    if WinGetClass(underMouse) = "mpv" && WinGetProcessName(underMouse) = "mpv.exe" {
        try WinClose(underMouse)
    }
    else {
        try WinClose(ptf.mpvWintitle)
    }
}