#Warn VarUnset, StdOut

;// This script is designed to assist the user of my repo in getting their feet off the ground by parsing through their keyboard shortcut file and attempting to auto assign KSA.ini values based on it.

;//! GUI is currently functional -- no logic for actual KSA values yet.

; { \\ #Includes
#Include *i <Classes\settings>
#Include *i <Classes\ptf>
#Include *i <Classes\Dark>
#Include *I <GUIs\tomshiBasic>
; }

try {
    UserSettings := UserPref()
}

if !IsSet(UserSettings)
    {
        MsgBox("This script requires the user to properly generate a symlink using ``CreateSymLink.ahk```n`nPlease run ``CreateSymLink.ahk`` to do so and then try running this script again.", A_ScriptName ".ahk requires SymLink")
        return
    }

class adobeKSA extends tomshiBasic {
    __New() {
        super.__New(,,, "Adjust adobe hotkeys")
        this.__generate()
        if UserSettings.dark_mode = true
            Dark.allButtons(this)
    }

    Xmargin := "x" 8
    Xclude := 500

    defaultPremiereFolder := A_MyDocuments "\Adobe\Premiere Pro\"
    defaultAEFolder := A_AppData "\Adobe\After Effects\"

    PremiereExclude := 0
    AEExclude := 0

    /**
     * This function is called to generate the main section of the GUI
     */
    __generate() {
        this.AddText(this.Xmargin, "Please select the root directory locations for where each program keeps its keyboard shortcut file.")
        this.AddText(this.Xmargin " r1 w500", "Please include your version number && profile folder if applicible.").SetFont("bold")
        this.AddText(this.Xmargin, "example: " this.defaultPremiereFolder "22.0\Profile-Tom`n").SetFont("s8")

        this.__indivSection(this.defaultPremiereFolder, "Premiere")
        this.__indivSection(this.defaultAEFolder, "AE")
    }

    /**
     * This function is designed to cut repeat code and is called to generate the two sections (premiere/ae)
     * @param {String} defaultFolder the default directory that adobe keeps the keyboard shortcut files
     * @param {String} which which program the iteration of the function is working on. It's important for this to be right as it passes it to following functions
     */
    __indivSection(defaultFolder, which) {
        this.AddText(this.Xmargin " r1 w120", which " Folder: ").SetFont("bold")
        this.%which%Folder := this.Add("Text", this.Xmargin " Section ", defaultFolder)
        this.AddCheckbox("x" this.Xclude " ys-25", "Exclude").OnEvent("Click", this.__exclude.Bind(this, which))
        this.AddButton("y+7", "Change").OnEvent("Click", this.__changePath.Bind(this, which, defaultFolder))

    }

    /**
     * This function is called when the exclude checkboxes are clicked
     */
    __exclude(which, guiObj, *) {
        this.%which%Exclude := guiObj.Value
        switch guiObj.Value {
            case 1: this.%which%Folder.SetFont("strike")
            default: this.%which%Folder.SetFont("norm")
        }
    }
    /**
     * This function is called when the change buttons are clicked
     */
    __changePath(which, defaultFolder, *) {
        which := InStr(defaultFolder, "Premiere Pro", 1, 1, 1) ? "Premiere" : "AE"
        changePath := FileSelect("D", defaultFolder, "Select " which " directory, including version.")
        if changePath = ""
            return
        ; this.default%which%Folder := changePath
        this.%which%Folder.Text := SubStr(changePath, InStr(changePath, "Adobe")-1)
    }

}

adobegui := adobeKSA()
adobegui.Show()