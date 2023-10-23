/************************************************************************
 * @description A GUI to quickly horizontally crop video files using ffmpeg
 * @author tomshi
 * @date 2023/10/23
 * @version 1.0.0
 ***********************************************************************/

;// this script requires ffmpeg to be installed correctly and in the system path
#SingleInstance Force
; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <GUIs\reencodeGUI>
#Include <Classes\obj>
#Include <Classes\ffmpeg>
#Include <Classes\cmd>
; }

class hCropGui extends encodeGUI {
    __New(singleOrAll := "singleCam") {
        fileOrDir := (singleOrAll = "single" || singleOrAll = "singleCam") ? "file" : "dir"
        super.__New(fileOrDir)
        ;// rename encode button
        this["Encode"].Move(,, 0, 0)
        this.AddButton("x" this.firstButtonX " y" this.firstButtonY+30 " w100", "Crop")
        switch singleOrAll {
            case "singleCam":
                this["BitrateEdit"].GetPos(, &lastCTRLY)
                ;// add additional option
                this.AddText("x" this.MarginX A_Space "y" lastCTRLY+45 " w100", "Cam is:")
                this.AddRadio("Group vLorR Checked x" this.secMarg " yp", "Left")
                this.AddRadio("x" this.trdMarg " yp", "Right") ;// this["LorR"].value -- Left returns 1, Right returns 0
                ;// change what clicking crop button does
                this["Crop"].OnEvent("Click", this.__singleCamCrop.Bind(this, "cam"))
            case "all":
                loop files this.getFile "\*.mkv", "F" {
                    this.nameArr.Push(A_LoopFileName)
                    this.nameCleansed.Push(this.__cleanse(A_LoopFileName))
                }
                this["BitrateEdit"].GetPos(, &lastCTRLY)
                ;// add additional option
                this.AddText("x" this.MarginX A_Space "y" lastCTRLY+35 " w150", "Select Game Sides:")
                for i, v in this.nameArr {
                    this.AddText("x" this.MarginX, "Video " i ": " v)
                    this.AddRadio("Group v" this.nameCleansed.Get(i) "Radio Checked x" this.MarginX, "Left")
                    this.AddRadio("x" this.trdMarg " yp", "Right")
                }
                this["Crop"].OnEvent("Click", this.__allCamCrop.Bind(this))
            case "single":
                ;// change what clicking crop button does
                this["Crop"].OnEvent("Click", this.__singleCamCrop.Bind(this, "single"))
        }
    }

    nameArr      := []
    nameCleansed := []

    __cleanse(input) {
        output := StrReplace(input, ".mkv", "")
        output := StrReplace(output, A_Space, "_")
        output := StrReplace(output, "-", "_")
        return output
    }

    /** This function will attempt to split all videos in `nameArr` using the values passed into it by the GUI */
    __allCamCrop(*) {
        for k, v in this.nameArr {
            ;determine crf or bitrate
            crfOrBR := (this.crfOrBitrate = "crf") ? " -crf " this.crf : " -b:v " this.bitrate "k"

            ;//determine which half you need
            half := (this[this.nameCleansed.Get(k) "Radio"].value = 1) ? '"crop=iw/2:ih:0:0"' : '"crop=iw/2:ih:ow:0"'
            ;// build command
            command := Format('ffmpeg -i "{1}" -c:v {2} -preset {3} {4} -c:a copy -filter:v {6} "{5}"', this.getFile "\" v, "libx26" this.h26, this.preset, crfOrBR, this.getFile "\" StrReplace(v, ".mkv", "") "_cropped.mp4", half)
            cmd.run(false, true, false, command, this.getFile)
        }
    }

    /** This function will attempt to split the video selected at the beginning using the values passed into it by the GUI, using the values passed into it by the GUI */
    __singleCamCrop(which, *) {
        qualFact := (this.crfORbitrate = "crf") ? "-crf " this.crf : "-b:v " this.bitrate "k"
        finalPath := obj.SplitPath(this.getFile)
        finalFileName := finalPath.dir "\" finalPath.NameNoExt ".mp4"
        switch which {
            case "cam":
                whichCrop := this["LorR"].value = true ? '"crop=in_w/2:in_h:0:0"' : '"crop=in_w/2:in_h:in_w/2:0"'
                ;// build command
                command := Format('ffmpeg -i "{1}" -c:v {2} -preset {3} {4} -c:a copy -filter:v {5} "{6}"', this.getFile, "libx26" this.h26, this.preset, qualFact, whichCrop, finalFileName)
                ;// run command
                cmd.run(false, true, false, command)
            case "single":
                ;// build command
                command := Format('ffmpeg -i "{1}" -c:v {2} -preset {3} {4} -c:a copy -filter_complex "[0]crop=iw/2:ih:0:0[left];[0]crop=iw/2:ih:ow:0[right]" -map "[left]" "{5}" -map "[right]" "{6}"'
                        , this.getFile, "libx26" this.h26
                        , this.preset, qualFact
                        , finalPath.dir "\" finalPath.NameNoExt "_LC.mp4"
                        , finalPath.dir "\" finalPath.NameNoExt "_RC.mp4")
                cmd.run(false, true, false, command)
        }
    }
}