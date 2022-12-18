; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\dark>
; }

/**
 * This function calls a GUI to showcase some useful hotkeys available to the user while running my scripts. This function is also called during firstCheck()
 */
hotkeysGUI() {
    if WinExist("Handy Hotkeys - Tomshi Scripts")
        return
    hotGUI := tomshiBasic(,, "-Resize AlwaysOnTop", "Handy Hotkeys - Tomshi Scripts")
	Title := hotGUI.Add("Text", "H30 X8 W300", "Handy Hotkeys!")
    Title.SetFont("S15 Bold")

    ;sizing GUI
    gui_Small := {x: 450, y: 281}
    gui_Big := {x: 590}
    guiText_y := [60, 80, 90] ;text y position
    ;sizing text
    widthSize := Map(
        "small", 240,
        "large", 380,
    )
    heightSize := Map(
        "small", 100,
        "large", 220,
    )
    ;defining hotkeys
    hotkeys := ["#F1", "#F2", "#F12", "#+r", "#+^r", "#h", "#c", "#f", "#+``", "^+c", "CapsLock & c"]

    ;add listbox
    selection := hotGUI.Add("ListBox", "r" hotkeys.Length -2 " Choose1", [hotkeys[1], hotkeys[2], hotkeys[3], hotkeys[4], hotkeys[5], hotkeys[6], hotkeys[7], hotkeys[8], hotkeys[9], hotkeys[10], hotkeys[11]])
    selection.OnEvent("Change", text)

    ;buttons
    ;close button
	closeButton := hotGUI.Add("Button", "X8 Y+10", "Close")
	closeButton.OnEvent("Click", close)
    ;remove the default
	hotGUI.AddButton("X0 Y0 W0 H0", "")

    selectionText := hotGUI.Add("Text", "W240 X180 Y80 H100", "Pulls up the settings GUI window to adjust a few settings available to my scripts! This window can also be accessed by right clicking on ``My Scripts.ahk`` in the taskbar. Try it now!")
    text(*) {
        switch selection.Value {
            case 1:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "Pulls up the settings GUI window to adjust a few settings available to my scripts! This window can also be accessed by right clicking on ``My Scripts.ahk`` in the taskbar. Try it now!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 2:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "Pulls up an informational window regarding the currently active scripts, as well as a quick and easy way to close/open any of them. Try it now!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 3:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "A panic button that will loop through and force close all active* ahk scripts!`n`n*will not close ``checklist.ahk``"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 4:
                selectionText.Move(, guiText_y[1], widthSize["large"], heightSize["large"])
                selectionText.Text := "
                (
                    Will refresh all scripts! At anytime if you get stuck in a script press this hotkey to regain control.`n
                    (note: refreshing will not stop scripts run separately ie. from a streamdeck as they are their own process and not included in the refresh hotkey).
                    Alternatively you can also press ^!{del} (ctrl + alt + del) to access task manager, even if inputs are blocked.
                )"
                hotGUI.Move(,, gui_Big.x, gui_Small.y)
            case 5:
                selectionText.Move(, guiText_y[1], widthSize["large"], heightSize["large"])
                selectionText.Text := "
                (
                    Will rerun all active ahk scripts, effectively hard restarting them!. If at anytime a normal refresh isn't enough attempt this hotkey.`n
                    (note: refreshing will not stop scripts run separately ie. from a streamdeck as they are their own process and not included in the refresh hotkey).
                    Alternatively you can also press ^!{del} (ctrl + alt + del) to access task manager, even if inputs are blocked.
                )"
                hotGUI.Move(,, gui_Big.x, gui_Small.y)
            case 6:
                selectionText.Move(, guiText_y[3], widthSize["small"], heightSize["small"])
                selectionText.Text := "Will call this GUI so you can reference these hotkeys at any time!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 7:
                selectionText.Move(, guiText_y[3], widthSize["small"], heightSize["small"])
                selectionText.Text := "Will center the current active window in the middle the active display, or move the window to your main display if activated again!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 8:
                selectionText.Move(, guiText_y[3], widthSize["small"], heightSize["small"])
                selectionText.Text := "Will put the active window in fullscreen if it isn't already, or pull it out of fullscreen if it already is!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 9:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "
                (
                    (That's : win > SHIFT > ``, not the actual + key)
                    Will suspend the ``My Scripts.ahk`` script! - this is similar to using the ``#F2`` hotkey and unticking the same script!
                )"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 10:
                selectionText.Move(, guiText_y[2], widthSize["small"], heightSize["small"])
                selectionText.Text := "
                (
                    (That's : win > SHIFT > c, not the actual + key)
                    Will search google for whatever text you have highlighted!
                    This hotkey is set to not activate while Premiere Pro/After Effects is active!
                )"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
            case 11:
                selectionText.Move(, guiText_y[3], widthSize["small"], heightSize["small"])
                selectionText.Text := "Will remove and then either capitilise or completely lowercase the highlighted text depending on which is less frequent!"
                hotGUI.Move(,, gui_Small.x, gui_Small.y)
        }
    }

    ;what happens when you close the GUI
    hotGUI.OnEvent("Escape", close)
    hotGUI.OnEvent("Close", close)
    ;onEvent Functions
	close(*) => hotGUI.Destroy()

    if IniRead(ptf["settings"], "Settings", "dark mode") = "true"
        goDark()
    goDark()
    {
        dark.titleBar(hotGUI.Hwnd)
        dark.button(closeButton.Hwnd)
        dark.button(selection.Hwnd)
    }

    ;Show the GUI
	hotGUI.Show("AutoSize")
}