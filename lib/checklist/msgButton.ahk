/**
 * Changes the button names of a generated msgbox
 */
change_msgButton()
{
    if !WinExist("Wait or Continue?")
        return  ; Keep waiting.
    SetTimer(, 0)
    WinActivate("Wait or Continue?")
    ControlSetText("&Wait", "Button1")
    ControlSetText("&Select Now", "Button2")
}