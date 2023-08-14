/************************************************************************
 * @description A GUI to quickly reencode files using ffmpeg
 * @author tomshi
 * @date 2023/08/14
 * @version 1.0.0
 ***********************************************************************/

;// this script requires ffmpeg to be installed correctly and in the system path
#SingleInstance Force
; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\obj>
#Include <Classes\ffmpeg>
; }

class encodeGUI extends tomshiBasic {
    __New() {
        if !this.__selectFile(this)
            ExitApp()
        super.__New(,,, "Encode Settings")
        this.AddText("Section", "This script uses ffmpeg to reencode the selected file to a .mp4 h264/5 file.")
        this.AddText("xs", "Current File: ")
        this.currentFileName := this.AddText("x+5 W300", this.currentFileName), this.currentFileName.SetFont("Bold")
        this.AddText("xs", "Encoding: ")
        this.AddRadio("x" this.secMarg " yp Group Checked", "h264").OnEvent("Click", (*) => this.h26 := "4")
        this.AddRadio("x+50 yp", "h265").OnEvent("Click", (*) => this.h26 := "5")
        this.AddText("xs", "Preset: ")
        this.AddDropDownList("x" this.secMarg " yp-3 w100 Choose3 vpres", this.presetsArr).OnEvent("Change", (guiCtrl, *) => this.preset := guiCtrl.text)
        this.AddText("xs", "crf: ")
        this.AddEdit("x" this.secMarg " yp-3 Number w50")
        this.AddUpDown("Range0-51", 17).OnEvent("Change", (guiObj, *) => this.crf := guiObj.value)
        this.AddButton("xs w100", "Select File").OnEvent("Click", this.__selectFile.Bind(this))
        this.AddButton("x+10 yp w100", "Encode").OnEvent("Click", this.__doEncode.Bind(this))
        this.show()
    }

    secMarg := 80

    getFile := ""
    currentFileName := ""
    h26 := "4"
    preset := "veryfast"
    crf := 17

    overwrite := 0
    commands := ""

    presetsArr := ["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow", "placebo"]

    /**
     * Run the dir
     * @param {Object} obj the splitpath object that contains the path of the file being worked on
     */
    __runDir(obj) {
        if WinExist(obj.dir)
            WinActivate(obj.dir)
        else
            Run(obj.dir)
    }

    __doEncode(*) {
        fileObjOrig := obj.SplitPath(this.getFile)
        if FileExist(fileObjOrig.dir "\" fileObjOrig.NameNoExt ".mp4")
            this.getFile := ffmpeg().__getIndex(this.getfile)
        fileObj := obj.SplitPath(this.getFile)
        ffmpeg().reencode_h26x(fileObjOrig.path, fileObj.NameNoExt, "libx26" this.h26, this.preset, this.crf)
        this.__runDir(fileObj)
    }

    /** Allows the user to change the file to operate on */
    __selectFile(*) {
        newFile := FileSelect(3,, "Select file to Reencode")
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