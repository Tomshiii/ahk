#Include <Classes\ffmpeg>
#Include <GUIs\tomshiBasic>

class adjustAudio extends tomshiBasic {
    __New() {
        if !this.__selectFile(this)
            ExitApp()
        super.__New(,,, "Adjust Audio")
        this.AddText(, "This script uses ffmpeg to adjust the audio gain of the selected file.`nPlease choose one of the methods below to adjust gain.")

        this.AddRadio("vdbAdjust Group Checked1 Section", "db Adjust")
        this.AddRadio("xs ys+75 Checked0", "Loudness Normalisation")

        this.AddButton("xs+300 ys+25 w100", "Select File").OnEvent("Click", this.__selectFile.Bind(this))
        this.AddButton("y+3 w100", "Adjust Gain").OnEvent("Click", this.adjustGain.Bind(this))
        this.AddCheckbox("y+3 Checked" this.overwrite, "Overwrite?").OnEvent("Click", this.__changeCheck.Bind(this))

        this.AddEdit("xs+25 ys+25 w55")
        this.AddUpDown("vdbUpDwn Range-96-96")


        ;// Til
        this.AddEdit("xs+25 ys+100 w55")
        this.AddUpDown("vTilUpDwn Range-70--5")
        this.AddText("x+10", "- Target integrated loudness")

        ;// TPL
        this.AddEdit("xs+25 w55")
        this.AddUpDown("vTplUpDwn Range-9-0", -2)
        this.AddText("x+10", "- True peak limit")

        ;// LRA
        this.AddEdit("xs+25 w55")
        this.AddUpDown("vLraUpDwn Range1-50", 7)
        this.AddText("x+10", "- Loudness range target")



        this.show()
    }

    getFile := ""
    currentFileName := ""
    overwrite := false

    /** Tracks the status of the overwrite checkbox */
    __changeCheck(guiobj, *) => this.overwrite := guiobj.value

    /** Allows the user to change the file to operate on */
    __selectFile(*) {
        newFile := FileSelect(3,, "Select file to Adjust Gain")
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

    /** adjust gain in the selected manor */
    adjustGain(*) {
        switch this["dbAdjust"].value {
            case 1: ffmpeg().adjustGain_db(this.getFile, this["dbUpDwn"].value, this.overwrite)
            case 0: ffmpeg().adjustGain_Normalise(this.getFile, this["TilUpDwn"].value, this["TplUpDwn"].value, this["LraUpDwn"].value, this.overwrite)
        }
    }
}

adjustAudio()