;// this script requires ffmpeg to be installed correctly and to the system path

; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\cmd>
; }

class trimGUI extends tomshiBasic {
    __New(audOrVid := "audio", extraCommands := "") {
        this.getFile := FileSelect(3,, "Select file to Trim")
        if this.getFile = ""
            ExitApp()
        super.__New(,,, "Trim Settings")
        this.AddText(, "This script uses ffmpeg to trim the selected " audOrVid " file.`nPlease provide the start time and duration (in seconds)")
        this.AddText("Section", "Start time:")
        this.AddEdit("ys-3 xs+65 r1 w100 Number").OnEvent("Change", this.__changeVal.bind(this, "start"))
        this.AddText("ys xs+190", "Duration:")
        this.AddEdit("ys-3 xs+250 r1 w100 Number").OnEvent("Change", this.__changeVal.bind(this, "duration"))
        this.AddCheckbox("ys xs+370 Checked" this.overwrite, "Overwrite?").OnEvent("Click", this.__changeCheck.Bind(this))
        this.AddButton("xs+368 w50", "Trim").OnEvent("Click", this.__doTrim.Bind(this))
        this.commands := extraCommands
    }
    getFile := ""

    startVal := 0
    durationVal := 0
    overwrite := 0
    commands := ""

    __changeVal(which, guiobj, *) => this.%which%Val := guiobj.Value
    __changeCheck(guiobj, *) => this.overwrite := guiobj.value

    __doTrim(*) => trim().__operate(this.getFile, this.startVal, this.durationVal, this.overwrite, this.commands)
}

/**
 * A class to contain some code designed to aid in trimming audio/video files with ffmpeg
 */
class trim {
    /**
     * Get the index to append to the file if the user doesn't wish to overwrite it
     */
    __getIndex(path) {
        pathobj := obj.SplitPath(path)
        index := 1
        loop {
            if FileExist(pathobj.dir "\" pathobj.NameNoExt "_" index "." pathobj.ext) {
                index++
                continue
            }
            break
        }
        return (pathobj.dir "\" pathobj.NameNoExt "_" index "." pathobj.ext)
    }

    /**
     * Run the dir
     */
    __run(obj) {
        if WinExist(obj.dir)
            WinActivate(obj.dir)
        else
            Run(obj.dir)
    }

    /**
     * send the ffmpeg command to the commandline and handle overwritting the file
     */
    __operate(path, startval, durationval, overwrite, commands, *) {
        pathobj := obj.SplitPath(path)
        outputFile := this.__getIndex(path)
        command := Format('ffmpeg -ss {1} -i "{3}" -t {2} {5} "{4}"', startval, durationval, path, outputFile, commands)
        cmd.run(,, command)
        switch overwrite {
            case 1:
                FileDelete(path)
                FileMove(outputFile, path)
                this.__run(pathobj)
            default:
                this.__run(pathobj)
        }
    }
}