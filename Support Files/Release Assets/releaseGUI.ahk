#Include "*i %A_ScriptDir% \..\..\lib\Functions\getLocalVer.ahk"
#Warn VarUnset, StdOut

releaseGUI := Gui("+Resize +MinSize100x170 -MinimizeBox -MaximizeBox", "Select Install Options")
SetTimer(() => releaseGUI.Opt("-Resize"), -10)
releaseGUI.SetFont("S11")
;nofocus
removedefault := releaseGUI.Add("Button", "Default X0 Y0 w0 h0", "_")

;from `C:\Program Files\AutoHotkey\UX\ui-setup.ahk`
DllCall('uxtheme\SetWindowThemeAttribute', 'ptr', releaseGUI.hwnd, 'int', 1 ; WTA_NONCLIENT
            , 'int64*', 3 | (3<<32), 'int', 8) ; WTNCA_NODRAWCAPTION=1, WTNCA_NODRAWICON=2
TitleBack := 'BackgroundWhite'
TitleFore := 'c3F627F'
TotalWidth := 300
releaseGUI.AddText('x0 y0 w' TotalWidth ' h60 ' TitleBack)


;// text
text    := releaseGUI.Add("Text", "X50 y16 " TitleFore " " TitleBack " Section W200 H35 Center", "Please select any install options you wish these scripts to take;`n")

releaseGUI.AddText('x-4 y60 w' TotalWidth+4 ' h90 0x1000 -Background Section')

;// attempt to disable hotkey replacer checkbox if user version is too high
try doDisable := (VerCompare(getLocalVer(), "v2.13.0") > 0) ? " Disabled" : ""
catch
    doDisable := ""
;// checkboxes
sym     := releaseGUI.Add("CheckBox", "Section xs+32 ys+20", "Symlink")
replace := releaseGUI.Add("CheckBox", "xs+130 ys" doDisable, "Hotkey Replacer")
startup := releaseGUI.Add("CheckBox", "Section xs ys+25", "Run at Startup")
adobeksa := releaseGUI.Add("CheckBox", "xs+130 ys", "adobeKSA.ahk")
;// checkbox onevents
sym.OnEvent("Click", checkbox)
replace.OnEvent("Click", checkbox)
startup.OnEvent("Click", checkbox)
adobeksa.OnEvent("Click", checkbox)

;// buttons
replace.GetPos(&rightX)
close_Install := releaseGUI.Add("Button", "x" rightX+50 " Y+10 w70", "Close")
close_Install.OnEvent("Click", buttonWhich)
releaseGUI.MarginY := -1
releaseGUI.Show('w' TotalWidth)



/**
 * This function handles the logic when a checkbox is selected. All it's doing is changing the text of the button
 */
checkbox(guiCtrl, other) {
    if sym.Value = 1 || replace.Value = 1 || startup.Value = 1 || adobeksa.Value = 1
        dont_change := 1
    else
        dont_change := 0
    switch guiCtrl.Value {
        case 1: ;checking
            if close_Install.Text = "Close"
                close_Install.Text := "Install"
            if !A_IsAdmin && sym.Value = 1
                SendMessage 0x160C,, true, close_Install, releaseGUI ; BCM_SETSHIELD := 0x160C
        case 0: ;unchecking
            if sym.Value = 0
                SendMessage 0x160C,, false, close_Install, releaseGUI ; BCM_SETSHIELD := 0x160C
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
            if startup.Value = 1
                {
                    startupScript := A_ScriptDir "..\..\PC Startup\PC Startup.ahk"
                    FileCreateShortcut(startupScript, A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\PC Startup.ahk - Shortcut.lnk")
                }
            if adobeksa.Value = 1
                Run(A_ScriptDir "\adobeKSA.ahk")
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