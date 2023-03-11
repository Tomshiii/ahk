/**
 * Changes the button names of a generated msgbox. This function is best called via a settimer, see example.
 * @param {String} title the title of the message box you wish to wait for
 * @param {Varadic/String} buttons the new text you wish the buttons to show
 * Example #1
 * ```
 * title := "Change Buttons"
 * SetTimer(change_msgButton.Bind(title, "OK", "Open Dir"), 16)
 * ;// will wait for a msgbox with a title "Change Buttons" and swap the first two buttons to "OK" & "Open Dir"
 * ```
 */
change_msgButton(title, buttons*) {
    if !WinExist(title)
        return  ; Keep waiting.
    SetTimer(, 0)
    WinActivate(title)
    for k, v in buttons {
        try {
            ControlSetText("&" v, "Button" k)
        }
    }
}