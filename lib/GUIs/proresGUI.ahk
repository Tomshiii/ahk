/************************************************************************
 * @description A GUI to quickly reencode a file to prores
 * @author tomshi
 * @date 2024/03/20
 * @version 1.0.4
 ***********************************************************************/

;// this script requires ffmpeg to be installed correctly and in the system path
#SingleInstance Force
; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <GUIs\reencodeGUI>
#Include <Classes\ffmpeg>
#Include <Classes\cmd>
; }

class proresGUI extends encodeGUI {
    __New(fileOrDir := "file", recurse := false, skipDupes := false) {
        super.__New(fileOrDir, "prores")
        ;// change the initial text
        this["Blurb"].Text := "This script uses ffmpeg to reencode the selected file to a prores .mov file."
        ;// create a new dropdown list
        this["pres"].Delete(), this["pres"].Add(this.presetsArr), this["pres"].Choose(1)


        ;// do these last
        this["Encode"].Text := "Encode_Old"
        this["Encode_Old"].Move(,, 0, 0)
        switch fileOrDir {
            case "file": this.AddButton("x" this.firstButtonX " y" this.firstButtonY+30 " w100", "Encode").OnEvent("Click", this.__proresEncode.Bind(this))
            case "dir":
                recurseDir := (recurse = true) ? "R" : ""
                loop files this.getFile "\*", "F" recurseDir {
                    if A_LoopFileExt != "mkv" && A_LoopFileExt != "mp4"
                        continue
                    SplitPath(A_LoopFileFullPath,, &outDir,, &outNameNoExt)
                    if FileExist(outDir "\" outNameNoExt ".mov") && skipDupes = true
                        continue
                    this.nameArr.Push(A_LoopFileFullPath)
                    this.nameCleansed.Push(this.__cleanse(A_LoopFileName))
                }
                this.AddButton("x" this.firstButtonX " y" this.firstButtonY+30 " w100", "Encode").OnEvent("Click", this.__dirproresEncode.Bind(this))
        }
    }

    presetsArr := ["proxy", "lt", "standard", "hq", "4444", "4444hq"]

    nameArr      := []
    nameCleansed := []

    /**
     * Facilitates determining the final filename of the selected file
     * @returns {Object}  _
     * ```
     * {
     * fileObjOrig: ;an obj.SplitPath of the originally selected file,
     * fileObj: ;an obj.SplitPath of the newly indexed file
     * }
     * ```
     */
    __fileObj(path := this.getFile) {
        fileObjOrig := obj.SplitPath(this.getFile)
        if FileExist(fileObjOrig.dir "\" fileObjOrig.NameNoExt ".mov")
            this.getFile := ffmpeg().__getIndex(this.getFile, "mov")
        fileObj := obj.SplitPath(this.getFile)
        return {fileObjOrig: fileObjOrig, fileObj: fileObj}
    }

    __proresEncode(*) {
        pathObj := this.__fileObj()
        command := Format('ffmpeg -i "{1}" -c:v prores_ks -profile:v {2} "{3}"', pathObj.fileObjOrig.path, String(this["pres"].value-1), pathObj.fileObj.Dir "\" pathObj.fileObj.NameNoExt ".mov")
        cmd.run(,,, command)
    }

    __dirproresEncode(*) {
        origPath := this.getFile
        for k, v in this.nameArr {
            this.getFile := v
            pathObj := this.__fileObj()
            command := Format('ffmpeg -i "{1}" -c:v prores_ks -profile:v {2} "{3}"', v, String(this["pres"].value-1), pathObj.fileObj.Dir "\" pathObj.fileObj.NameNoExt ".mov")
            cmd.run(,,, command)
        }
    }
}