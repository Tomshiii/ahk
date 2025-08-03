#requires AutoHotkey v2
#Warn VarUnset, StdOut

#Include <Classes\ptf>

instance := newGUI()
instance.Show('w' instance.TotalWidth)

class newGUI extends Gui {
    __New() {
        SplitPath(A_LineFile,, &workDir)
        SetWorkingDir(workDir)
        super.__New("+Resize +MinSize100x170 -MinimizeBox -MaximizeBox", "Install Tomshi AHK")
        SetTimer(() => this.Opt("-Resize"), -10)
        this.SetFont("S11")
        ;nofocus
        this.AddButton("Default X8 Y0 w0 h0 v_", "_")

        ;from `C:\Program Files\AutoHotkey\UX\ui-setup.ahk`
        DllCall('uxtheme\SetWindowThemeAttribute', 'ptr', this.hwnd, 'int', 1 ; WTA_NONCLIENT
                    , 'int64*', 3 | (3<<32), 'int', 8) ; WTNCA_NODRAWCAPTION=1, WTNCA_NODRAWICON=2
        this.AddText('x0 y0 w' this.TotalWidth ' h60 ' this.TitleBack)
        this.Add("Text", "X105 y16 " this.TitleFore " " this.TitleBack " Section W250 H35 vTopText Center", "Installation Complete!`nSee further options for additional features:")
        this.AddText('x-4 y60 w' this.TotalWidth+4 ' h125 0x1000 -Background Section')

        ; this.AddButton("y0 x0 w0 h0 vInstallButton", "Install")
        this.AddButton("ys+20 xs+350 w65 Hidden vInstallButton", "Install").OnEvent("Click", (*) => this.__install())
        this.AddButton("ys+20 xs+350 w65 vDoneButton", "Done").OnEvent("Click", (*) => ExitApp())

        this.AddCheckbox("xs+25 ys+20 Section vPremRemote", "Install/Update Premiere Remote").OnEvent("Click", (guiObj, *) => (this.__checkboxes(guiObj, "PremRemote")))
        this.AddText("xs y+5", "*note: NodeJS must already be installed for all of the above").SetFont("S9 Italic")

    }
    TitleBack  := 'BackgroundWhite'
    TitleFore  := 'c3F627F'
    TotalWidth := 430
    InstallDir := A_WorkingDir

    __checkboxes(guiObj, name) {
        this["_"].focus()
        this.__swap()
    }
    __swap(whichOverride := "unset") {
        which := (this["PremRemote"].Value = 0) ? 0 : 1
        if whichOverride !== "unset"
            which := whichOverride
        switch which {
            case 0:
                this["InstallButton"].opt("Hidden")
                this["DoneButton"].opt("-Hidden")
            default:
                this["DoneButton"].opt("Hidden")
                this["InstallButton"].opt("-Hidden")
        }
    }

    __installPackage(filename) {
        try {
            RunWait(A_WorkingDir "\Install Packages\" filename)
            sleep 100
        } catch {
            throw TargetError("Unable to determine requested file.", -1)
        }
    }

    __install(*) {
        this["_"].focus()
        this.Opt("Disabled")
        ;// do installations
        if this["PremRemote"].value = 1
            this.__installPackage("installPremRemote.ahk")

        ;//end
        this.Opt("-Disabled")
        this.__swap(0)
    }
}