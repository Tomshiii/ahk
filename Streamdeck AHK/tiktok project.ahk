#SingleInstance Force
; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\ptf>
#Include <Classes\coord>
#Include <Classes\errorLog>
#Include <Classes\switchTo>
#Include <Functions\delaySI>
; }

if !WinActive(editors.Premiere.winTitle)
    return

tiktokGUI()

class tiktokGUI extends tomshiBasic {
    __New() {
        super.__New(,, "+Resize +MinSize300x", this.guiTitle)
        this.__generateGUI()
        this.show()
    }

    finalChoice := ""
    guiTitle := "Select desired resolution"
    current := "1080x1920"

    __generateGUI() {
        this.AddText(, "Desired Resolution")

        ;// radio controls
        this.AddRadio("vseven", "720x1280").OnEvent("Click", (*) => this.__radioChange("720x1280"))
        this.AddRadio("vten Checked", "1080x1920").OnEvent("Click", (*) =>  this.__radioChange("1080x1920"))
        this.AddRadio("vfour", "2160x3840").OnEvent("Click", (*) => this.__radioChange("2160x3840"))
        this.AddRadio("vcustom Section", "Custom").OnEvent("Click", (*) => this.__custSelect())

        ;// edit boxes
        this.AddEdit("xs+75 ys-5 Section r1 w100 Limit4 Number vcustX").OnEvent("Change", (*) => this.__editChange())
        this.AddText("xs+105 ys+3 Section", "x")
        this.AddEdit("xs+13 ys-3 r1 w100 Limit4 Number vcustY").OnEvent("Change", (*) => this.__editChange())
        this["custX"].opt("Disabled")
        this["custY"].opt("Disabled")

        ;// button
        this.Add("Button", "ys-40 xs+54", "Select").OnEvent("Click", (*) => this.__selectButton())
    }

    /**
     * called when 3 main radio buttons are selected. this function will also disable the `custom` edit boxes
     * @param {String} newVal what the corresponding value is. eg. `"1080x1920"`
     */
    __radioChange(newVal, *) {
        this.__editBoxes(false)
        this["custom"].opt("Checked0")
        this.current := newVal
    }

    /** called when typing in the edit boxes */
    __editChange(*) {
        this.current := this["custX"].text "x" this["custY"].text
    }

    /** called when the `custom` radio button is selected. enables the `custom` edit boxes */
    __custSelect(*) {
        this.__editBoxes(true)
    }

    /**
     * enables/disables the `custom` edit boxes
     * @param {Boolean} which `true` to enable, `false` to disable
     */
    __editBoxes(which) {
        opt := (which = true) ? "-Disabled" : "Disabled"
        this["custX"].opt(opt)
        this["custY"].opt(opt)
    }

    /** called when the `select` button is clicked. handles interacting with Premiere */
    __selectButton(*) {
        this.Hide()
        selections := StrSplit(this.current, "x")
        if !WinExist(prem.winTitle) ;// incase the user closes premiere
            ExitApp()
        switchTo.Premiere()
        if !WinWaitActive(Editors.Premiere.winTitle,, 3) {
            errorLog(Error("Timed out waiting for Premiere to activate.", -1),, 1)
            ExitApp()
        }
        coord.w()
        ;// input resolution options
        ;// maybe input selector && text input boxes for custom
        delaySI(, "!s", "q")
        if !WinWait("Sequence Settings",, 4) {
            errorLog(Error("Timed out waiting for Sequence Settings window.", -1),, 1)
            ExitApp()
        }
        sleep 500
        MouseMove(0, 0)
        delaySI(50, "{Tab 4}", selections[1], "{Tab}", selections[2], "{Enter}")
        if WinWait("Delete All Previews For This Sequence",, 1)
            SendInput("{Enter}")
        ExitApp()
    }
}