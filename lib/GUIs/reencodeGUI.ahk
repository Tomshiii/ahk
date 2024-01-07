/************************************************************************
 * @description A GUI to quickly reencode video files using ffmpeg
 * @author tomshi
 * @date 2024/01/08
 * @version 1.1.2
 ***********************************************************************/

;// this script requires ffmpeg to be installed correctly and in the system path
#SingleInstance Force
; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\obj>
#Include <Classes\ffmpeg>
; }

class encodeGUI extends tomshiBasic {
    __New(fileOrDir := "file", type := "h26") {
        if !this.__selectFile(fileOrDir, this)
            ExitApp()
        super.__New(,,, "Encode Settings")
        this.MarginX := 8
        this.AddText("Section vBlurb", "This script uses ffmpeg to reencode the selected file to a h264/5 .mp4 file.")
        if fileOrDir = "file" {
            this.AddText("xs", "Current File: ")
            this.currentFileName := this.AddText("x+5 W300", this.currentFileName), this.currentFileName.SetFont("Bold")
        }
        if type = "h26" {
            this.AddText("xs", "Encoding: ")
            this.AddRadio("x" this.secMarg " yp Group Checked", "h264").OnEvent("Click", (*) => this.h26 := "4")
            this.AddRadio("x" this.trdMarg " yp", "h265").OnEvent("Click", (*) => this.h26 := "5")
        }

        this.AddText("xs", "Preset: ")
        this.AddDropDownList("x" this.secMarg " yp-3 w100 Choose3 vpres", this.presetsArr).OnEvent("Change", (guiCtrl, *) => this.preset := guiCtrl.text)

        if type = "h26" {
            ;// separate
            this.AddText("xs yp+45", "CRF or BR: ")
            this.AddRadio("x" this.secMarg " yp Group Checked", "crf").OnEvent("Click", this.__crforbitRadio.Bind(this, "crf"))
            this.AddRadio("x" this.trdMarg " yp", "bitrate").OnEvent("Click", this.__crforbitRadio.Bind(this, "bitrate"))
            ;// crf
            this.AddText("xs", "crf: ")
            this.AddEdit("x" this.secMarg " yp-3 Number w50 vCRFEdit")
            this.AddUpDown("Range0-51", 17).OnEvent("Change", (guiObj, *) => this.crf := guiObj.value)
            ;// bitrate
            this.AddText("xs", "bitrate: ")
            this.AddEdit("x" this.secMarg " yp-3 limit5 Number w75 vBitrateEdit Disabled", this.bitrate)
            this.AddText("x+5 yp+3", "kb/s")
        }

        ;// do these last
        this.AddButton("x" this.firstButtonX " y" this.firstButtonY " w100", "Select File").OnEvent("Click", this.__selectFile.Bind(this, fileOrDir))
        this.AddButton("x" this.firstButtonX " y" this.firstButtonY+30 " w100", "Encode").OnEvent("Click", this.__doEncode.Bind(this))
    }

    firstButtonX := 300
    firstButtonY := 50

    secMarg := 80
    trdMarg := this.secMarg+75

    getFile := ""
    currentFileName := ""
    h26 := "4"
    preset := "veryfast"
    crf := 17
    crfOrBitrate := "crf"
    bitrate := 20000

    overwrite := 0
    commands := ""

    presetsArr := ["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow", "placebo"]

    /** This function is called anytime the crf/bitrate radio control is toggled and facilitates disabling the opposite of the selection */
    __crforbitRadio(which, *) {
        this.crfOrBitrate := which
        switch which {
            case "crf":
                this["BitrateEdit"].Opt("Disabled")
                this["CRFEdit"].Opt("-Disabled")
            case "bitrate":
                this["BitrateEdit"].Opt("-Disabled")
                this["CRFEdit"].Opt("Disabled")
        }
    }

    /**
     * Run the dir
     * @param {Object} obj the splitpath object that contains the path of the file being worked on
     */
    __runDir(obj) {
        if WinExist(obj.NameNoExt)
            WinActivate(obj.NameNoExt)
        else
            Run(obj.dir)
    }

    /** cleanse an input of .mkv/.mp4 and replaces whitespace/- with _ */
    __cleanse(input) {
        output := StrReplace(input, ".mkv", "")
        output := StrReplace(input, ".mp4", "")
        output := StrReplace(output, A_Space, "_")
        output := StrReplace(output, "-", "_")
        return output
    }


    /**
     * Facilitates determining the final filename of the selected file
     * @returns {Object}
     * ```
     * {
     * fileObjOrig: ;an obj.SplitPath of the originally selected file,
     * fileObj: ;an obj.SplitPath of the newly indexed file
     * }
     * ```
     */
    __fileObj() {
        fileObjOrig := obj.SplitPath(this.getFile)
        if FileExist(fileObjOrig.dir "\" fileObjOrig.NameNoExt ".mp4")
            this.getFile := ffmpeg().__getIndex(this.getfile)
        fileObj := obj.SplitPath(this.getFile)
        return {fileObjOrig: fileObjOrig, fileObj: fileObj}
    }

    /** This function facilitates setting up for and then calling ffmpeg to reencode the selected file */
    __doEncode(*) {
        pathObj := this.__fileObj()
        crfVal := (this.crfOrBitrate = "crf") ? this.crf : false
        bitrateVal := (crfVal = false) ? this.bitrate : false
        ffmpeg().reencode_h26x(pathObj.fileObjOrig.path, pathObj.fileObj.NameNoExt, "libx26" this.h26, this.preset, crfVal, bitrateVal)
        this.__runDir(pathObj.fileObj)
    }

    /**
     * Allows the user to change the file to operate on
     * @param {String} fileOrDir whether the user is operating on a file or directory. this is necessary as some scripts will require certain actions depending on the desired outcome
     */
    __selectFile(fileOrDir, *) {
        selection := (fileOrDir = "dir") ? "D " : ""
        selectionTitle := (fileOrDir = "dir") ? "directory" : "file"
        newFile := FileSelect(selection 3,, "Select " selectionTitle " to Reencode")
        if newFile = ""
            return false
        this.getFile := newFile
        filePath := obj.SplitPath(this.getFile)
        try {
            this.currentFileName.text := Trim(filePath.Name)
        } catch {
            this.currentFileName := filePath.Name
        }
        return true
    }
}