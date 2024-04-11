/************************************************************************
 * @description A GUI to quickly reencode video files using ffmpeg
 * @author tomshi
 * @date 2024/04/11
 * @version 1.2.0
 ***********************************************************************/

;// this script requires ffmpeg to be installed correctly and in the system path
#SingleInstance Force
; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\obj>
#Include <Classes\ffmpeg>
#Include <Classes\winGet>
#Include <Functions\Win32_VideoController>
; }

class encodeGUI extends tomshiBasic {
    __New(fileOrDir := "file", type := "h26") {
        if !this.__selectFile(fileOrDir, this)
            ExitApp()
        this.ffmpegInstance := ffmpeg()
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
        this.AddDropDownList("x" this.secMarg " yp-3 w100 Choose6 vpres", this.presetsArr).OnEvent("Change", (guiCtrl, *) => this.preset := guiCtrl.text)

        if type = "h26" {
            ;// separate
            this.AddText("xs yp+45", "CRF or BR: ")
            this.AddRadio("x" this.secMarg " yp Group Checked vcrfRadio", "crf").OnEvent("Click", this.__crforbitRadio.Bind(this, "crf"))
            this.AddRadio("x" this.trdMarg " yp Disabled vbitrateRadio", "bitrate").OnEvent("Click", this.__crforbitRadio.Bind(this, "bitrate"))
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

        if type = "h26" {
            this.AddCheckbox("x" this.firstButtonX " y" this.firstButtonY+65 " vuseNVENC Checked1", "Render using GPU").OnEvent("Click", (guiCtrl, *) => this.__gpuCheck(guiCtrl))
        }
    }

    ffmpegInstance := ""

    firstButtonX := 300
    firstButtonY := 50

    secMarg := 80
    trdMarg := this.secMarg+75

    getFile := ""
    currentFileName := ""
    h26 := "4"
    preset := "veryfast"
    presetGPU := "slower (p6)"
    crf := 17
    crfOrBitrate := "crf"
    bitrate := 20000

    overwrite := 0
    commands := ""
    useNVENC := 1

    presetsArrCPU := ["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow", "placebo"]
    presetsArrGPU := ["fastest (p1)", "faster (p2)", "fast (p3)", "medium (p4)", "slow (p5)", "slower (p6)", "slowest (p7)"]
    presetsArr := this.presetsArrGPU

    __gpuCheck(guiCtrl, *) {
        this.useNVENC := guiCtrl.value
        switch {
            case this.useNVENC = 1:
                this["bitrateRadio"].value := 0
                this["bitrateRadio"].Opt("Disabled")
                this["BitrateEdit"].Opt("Disabled")
                this["CRFEdit"].Opt("-Disabled")
                this["crfRadio"].value := 1
                this.crfOrBitrate := "crf"
                this["pres"].Delete()
                this["pres"].Add(this.presetsArrGPU)
                this["pres"].Choose(6)
            case (this.useNVENC = 0 && this.crfOrBitrate = "bitrate"):
                this["BitrateEdit"].Opt("-Disabled")
                this["bitrateRadio"].Opt("-Disabled")
                this["CRFEdit"].Opt("Disabled")
                this["bitrateRadio"].value := 1
                this["crfRadio"].value := 0
                this["pres"].Delete()
                this["pres"].Add(this.presetsArrCPU)
                this["pres"].Choose(3)
            default:
                this["bitrateRadio"].Opt("-Disabled")
                this["BitrateEdit"].Opt("-Disabled")
                this["pres"].Delete()
                this["pres"].Add(this.presetsArrCPU)
                this["pres"].Choose(3)
        }
    }

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
            this.getFile := this.ffmpegInstance.__getIndex(this.getfile)
        fileObj := obj.SplitPath(this.getFile)
        return {fileObjOrig: fileObjOrig, fileObj: fileObj}
    }

    /** This function facilitates setting up for and then calling ffmpeg to reencode the selected file */
    __doEncode(*) {
        if this.useNVENC = true {
            getGPU := Win32_VideoController()
            if getGPU.Manufacturer != "NVIDIA" {
                MsgBox("System failed to detect a NVIDIA GPU. NVENC Rendering is unavailable.`nPlease use CPU encoding", "No NVENC Detected", "48 4096")
                return
            }
        }
        pathObj := this.__fileObj()
        crfVal  := (this.crfOrBitrate = "crf") ? this.crf : false
        bitrateVal := (crfVal = false) ? this.bitrate : false
        encoder := (this.useNVENC = true) ? "h26" this.h26 "_nvenc" : "libx26" this.h26
        this.ffmpegInstance.reencode_h26x(pathObj.fileObjOrig.path, pathObj.fileObj.NameNoExt, encoder, this.preset, crfVal, bitrateVal, this.useNVENC)
        this.__runDir(pathObj.fileObj)
        ;// calls the traytip
        this.ffmpegInstance.__Delete()
    }

    /**
     * Allows the user to change the file to operate on
     * @param {String} fileOrDir whether the user is operating on a file or directory. this is necessary as some scripts will require certain actions depending on the desired outcome
     */
    __selectFile(fileOrDir, *) {
        selection := (fileOrDir = "dir") ? "D " : ""
        selectionTitle := (fileOrDir = "dir") ? "directory" : "file"
        currentDir := WinGet.ExplorerPath()
        defaultDir := currentDir != false ? currentDir : ""
        newFile := FileSelect(selection 3, defaultDir, "Select " selectionTitle " to Reencode")
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