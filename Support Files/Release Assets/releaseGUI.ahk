releaseGUI := Gui("+Resize +MinSize100x -MaximizeBox", "Select Install Options")
releaseGUI.SetFont("S11")
;nofocus
removedefault := releaseGUI.Add("Button", "Default X0 Y0 w0 h0", "_")

;text
text    := releaseGUI.Add("Text", "X35 Section W200 Center", "Please select any install options you wish these scripts to take;`n")

;checkboxes
sym     := releaseGUI.Add("CheckBox", "xs-20", "Symlink")
replace := releaseGUI.Add("CheckBox", "x+50", "Hotkey Replacer")
;checkbox onevents
sym.OnEvent("Click", checkbox)
replace.OnEvent("Click", checkbox)

;buttons
close_Install := releaseGUI.Add("Button", "x+-58 Y+10", "Close")
close_Install.OnEvent("Click", buttonWhich)

releaseGUI.Show()



/**
 * This function handles the logic when a checkbox is selected. All it's doing is changing the text of the button
 */
checkbox(guiCtrl, other) {
    if sym.Value = 1 || replace.Value = 1
        dont_change := 1
    else
        dont_change := 0
    switch guiCtrl.Value {
        case 1: ;checking
            if close_Install.Text = "Close"
                close_Install.Text := "Install"
        case 0: ;unchecking
            if dont_change = 1
                return
            if close_Install.Text = "Install"
                close_Install.Text := "Close"
    }
}

/**
 * This function handles the logic of when the button is selected.
 */
buttonWhich(guiCtrl, other) {
    switch close_Install.Text {
        case "Close":
            releaseGUI.Destroy()
        case "Install":
            if sym.Value = 1
                {
                    detect()
                    Run(A_ScriptDir "\CreateSymLink.ahk")
                    WinWait("CreateSymLink.ahk")
                    WinWaitClose("CreateSymLink.ahk")
                }
            if replace.Value = 1
                Run(A_ScriptDir "\HotkeyReplacer.ahk")
            ;//
            releaseGUI.Destroy()
    }
}

/**
 * A function to cut repeat code and set some values required to detect ahk scripts
 * @param {Boolean} windows is what hidden window mode you wish for the script to take. This value `defaults to true`
 * @param {Integer/String} title is what title match mode you wish for the script to take. This value `defaults to 2`
 */
 detect(windows := true, title := 2) => (DetectHiddenWindows(windows), SetTitleMatchMode(title))