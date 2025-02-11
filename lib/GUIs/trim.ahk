/************************************************************************
 * @description A GUI to easily trim audio/video files using ffmpeg
 * @author tomshi
 * @date 2025/02/11
 * @version 1.0.4
 ***********************************************************************/

;// this script requires ffmpeg to be installed correctly and in the system path
#SingleInstance Force
; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\obj>
#Include <Classes\ffmpeg>
; }

class trimGUI extends tomshiBasic {
    __New(audOrVid := "audio", extraCommands := "") {
        if !this.__selectFile(this)
            ExitApp()
        super.__New(,,, "Trim Settings")
        this.AddText(, "This script uses ffmpeg to trim the selected " audOrVid " file.`nPlease provide the start and end timecode of the desired section.")
         loop 2 {
            this.AddText(((A_Index = 1) ? "" : "xs y+15 ") "Section", (A_Index = 1) ? "Start Timecode:   H" : "End Timecode:    H")
            this.AddEdit("xs+120 ys-3 w50")
            this.AddUpDown("vH" A_Index " Range0-11 ", 0)

            this.AddText("x+10 ys", "M")
            this.AddEdit("x+5 ys-3 w50")
            this.AddUpDown("vM" A_Index " Range0-59 ", 0)

            this.AddText("x+10 ys", "S")
            this.AddEdit("x+5 ys-3 w50")
            this.AddUpDown("vS" A_Index " Range0-59 ", 0)
        }

        this.AddCheckbox("ys xs+370 Checked" this.overwrite, "Overwrite?").OnEvent("Click", this.__changeCheck.Bind(this))
        this.AddText("xs", "Current File: ")
        this.currentFileName := this.AddText("x+5 W300", this.currentFileName), this.currentFileName.SetFont("Bold")
        this.AddButton("xs+257 w100", "Select File").OnEvent("Click", this.__selectFile.Bind(this))
        this.AddButton("x+10 w50", "Trim").OnEvent("Click", this.__doTrim.Bind(this))
        this.commands := extraCommands
        this.show()
    }
    getFile := ""
    currentFileName := ""

    startVal := 0
    durationVal := 0
    overwrite := 0
    commands := ""

    /** Tracks the values as the user inputs them */
    __changeVal(which, guiobj, *) => this.%which%Val := guiobj.Value

    /** Tracks the status of the overwrite checkbox */
    __changeCheck(guiobj, *) => this.overwrite := guiobj.value

    /** Allows the user to change the file to operate on */
    __selectFile(*) {
        newFile := FileSelect(3,, "Select file to Trim")
        if newFile = ""
            return false
        this.getFile := newFile
        filePath := obj.SplitPath(this.getFile)
        try {
            this.currentFileName.text := filePath.NameNoExt
        } catch {
            this.currentFileName := filePath.NameNoExt
        }
        return true
    }

    /** Sends the trim command to ffmpeg */
    __doTrim(*) {
        ;// for duration calculation
        startVal := A_YYYY A_MM A_DD Format("{:02}", this["H1"].value) Format("{:02}", this["M1"].value) Format("{:02}", this["S1"].value)
        endVal   := A_YYYY A_MM A_DD Format("{:02}", this["H2"].value) Format("{:02}", this["M2"].value) Format("{:02}", this["S2"].value)
        ;// for trim function
        this.startVal    := DateDiff(startVal, A_YYYY A_MM A_DD "000000", "S")
        this.durationVal := DateDiff(endVal, startVal, "S")

        if InStr(this.startVal, "-") || InStr(this.durationVal, "-") {
            MsgBox("Incorrect timecode, please input a valid timecode",, 0x10)
            return
        }
        ;// for duration calculation
        ffmpeg().trim(this.getFile, this.startVal, this.durationVal, this.overwrite, this.commands)
    }
}