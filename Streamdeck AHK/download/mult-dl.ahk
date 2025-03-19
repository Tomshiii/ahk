#Requires AutoHotkey v2.0
#Include <Functions\useNVENC>
#Include <Classes\ytdlp>
#Include <GUIs\tomshiBasic>

class multiDL extends tomshiBasic {
    __New() {
        if !this.__selectFile(this)
            ExitApp()
        super.__New(,,, "Multi Download")
        this.AddText(, "This script uses ytdlp to download videos.`nIt is expected that you have ytdlp and ffmpeg installed.")

        this.AddEdit("r10 vlist w250 Multi Wrap", "Paste all desired URLs here separated by ``,``'s and they will be downloaded one by one. This process may additionally need to reencode some files.")
        this.AddButton("vDL", "Download").OnEvent("Click", this.__download.Bind(this))

        this.show()
    }

    getFile := ""

    /** Allows the user to change the file to operate on */
    __selectFile(*) {
        if !newFile := FileSelect("D2",, "Select download location")
            return false
        this.getFile := newFile
        return true
    }

    __download(*) {
        SDopt := SD_Opt()
        encoder := (useNVENC() = true) ? SDopt.defaultNVENCencode : ""
        list := StrSplit(this["list"].value, [","], " `r`n")
        this["DL"].Enabled := false
        this.Hide()
        yt := ytdlp()
        for v in list {
           yt.download(Format('-N 8 -o "{1}" -f "bestvideo+bestaudio/best" --verbose --windows-filenames --merge-output-format mp4 --recode-video mp4 {2}', "{}", encoder), this.getFile, v, false)
        }
        this.show()
        this["DL"].Enabled := True
        yt.__activateDir(this.getFile)
        yt.__Delete()
    }
}

multiDL()