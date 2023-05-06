/************************************************************************
 * @description A script to contain classes relating to trimming audio/video files with ffmpeg
 * @author tomshi
 * @date 2023/05/06
 * @version 1.0.2
 ***********************************************************************/

;// this script requires ffmpeg to be installed correctly and in the system path
#SingleInstance Force
; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\cmd>
#Include <Classes\obj>
#Include <Classes\ffmpeg>
; }

class trimGUI extends tomshiBasic {
    __New(audOrVid := "audio", extraCommands := "") {
        if !this.__selectFile(this)
            ExitApp()
        super.__New(,,, "Trim Settings")
        this.AddText(, "This script uses ffmpeg to trim the selected " audOrVid " file.`nPlease provide the start time and duration (in seconds)")
        this.AddText("Section", "Start time:")
        this.AddEdit("ys-3 xs+65 r1 w100 Number").OnEvent("Change", this.__changeVal.bind(this, "start"))
        this.AddText("ys xs+190", "Duration:")
        this.AddEdit("ys-3 xs+250 r1 w100 Number").OnEvent("Change", this.__changeVal.bind(this, "duration"))
        this.AddCheckbox("ys xs+370 Checked" this.overwrite, "Overwrite?").OnEvent("Click", this.__changeCheck.Bind(this))
        this.AddButton("xs+250 w100", "Select File").OnEvent("Click", this.__selectFile.Bind(this))
        this.AddButton("x+10 w50", "Trim").OnEvent("Click", this.__doTrim.Bind(this))
        this.commands := extraCommands
        this.show()
    }
    getFile := ""

    startVal := 0
    durationVal := 0
    overwrite := 0
    commands := ""

    /** Tracks the values as the user inputs them */
    __changeVal(which, guiobj, *) => this.%which%Val := guiobj.Value

    /** Tracks the status of the overwrite checkbox */
    __changeCheck(guiobj, *) => this.overwrite := guiobj.value

    /** Allows the user to change the file to operate on */
    __selectFile(guiObj, *) {
        newFile := FileSelect(3,, "Select file to Trim")
        if newFile = ""
            return false
        this.getFile := newFile
        return true
    }

    /** Sends the trim command to ffmpeg */
    __doTrim(*) => ffmpeg().trim(this.getFile, this.startVal, this.durationVal, this.overwrite, this.commands)
}