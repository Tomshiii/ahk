/************************************************************************
 * @description a class to contain any ytdlp wrapper functions to allow for cleaner, more expandable code
 * @author tomshi
 * @date 2025/07/28
 * @version 1.0.28
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\cmd>
#Include <Classes\ffmpeg>
#Include <Classes\clip>
#Include <Classes\obj>
#Include <Classes\errorLog>
#Include <Classes\switchTo>
#Include <Classes\Streamdeck_opt>
#Include <Other\Notify\Notify>
#Include <Functions\getHTMLTitle>
#Include <Functions\selectFileInOpenWindow>
; }


class ytdlp {

    doAlert := true

    links := [
        "https://www.youtube.com/",  "https://youtu.be/",
        "https://www.twitch.tv/",    "https://clips.twitch.tv/",
        "https://www.tiktok.com/",
        "https://www.facebook.com/", "https://www.instagram.com/",
        "https://old.reddit.com/",   "https://www.reddit.com/"
    ]
    URL := ""
    defaultCommand      := 'yt-dlp {1} -P `"{2}`" `"{3}`"'
    defaultVideoCommand := '-N 8 -o "{1}" -f "bestvideo+bestaudio/best" --verbose --windows-filenames --merge-output-format mp4 --cookies-from-browser firefox'
    defaultPostProcess  := 'ffmpeg -i "{2}\{3}" {1} -c:a aac -b:a 192k "{2}\temp_{3}" && del /f /q "{2}\{3}" && move /y "{2}\temp_{3}" "{2}\{3}"'
    defaultCPU          := "-c:v libx264 -crf 21 -preset medium"
    defaultGPU          := "-c:v h264_nvenc -preset 18 -cq 19"
    defaultAudioCommand := '-N 8 -o "{1}" --verbose --windows-filenames --extract-audio --audio-format wav --cookies-from-browser firefox'
    defaultFilename := "%(title).{1}s [%(id)s].%(ext)s"
    command := ""
    check := false
    checkClipState := false
    currentName := ""

    /** generates a tooltip to alert the user the process has completed */
    __finished() => (this.doAlert = true) ? tool.tray({text: "yt-dlp process has finished", title: "yt-dlp process has completed!", options: 1}, 2000) : ""

    /**
     * checks the clipboard for a valid download link
     * @param {Object} clip the clipboard you wish to check
     * @param {Object} stored the stored clipboard
     * @param {Varadic} formatVars variables to pass to the command
     */
    __checkClipboard(clip, stored, formatVars*) {
        for v in this.links {
            if InStr(clip, v) {
                this.check := true
                this.URL := clip
                break
            }
            if stored != false && InStr(stored, v) {
                this.URL := stored
                this.checkClipState := "attempt"
                return true
            }
        }
        if !this.check && !this.checkClipState {
                tool.Cust("Clipboard doesn't contain a downloadable link")
                this.URL := clip ;// the user may still wish to attempt a download
                return false
            }
        this.command := Format(this.defaultCommand, formatVars[1], formatVars[2], clip)
        this.checkClipState := "run"
        return true
    }

    /**
     * Checks the desired filepath to see if a file of the desired name already exists
     * @param {String} filename the name of the file you wish to check for (**not** including filetype)
     * @param {String} dir the directory you wish to search within (**without** a trailing backslash)
     * @returns {Integer} the filename index
     */
    __getIndex(filename, dir) {
        if !FileExist(dir "\" filename)
            return ""
        newFilename := obj.SplitPath(filename)
        index := 1
        loop files dir "\*", "F" {
            loopObj := obj.SplitPath(A_LoopFilePath)
            if loopObj.NameNoExt != newFilename.NameNoExt index
                continue
            index++
            newFilename.NameNoExt := newFilename.NameNoExt index
        }
        return index
    }


    /**
     * Handles converting a file to h264. This is useful when using video editing programs such as Premiere Pro as it doesn't support the filetypes that youtube stores newer videos in (.webm & vp9/av1)
     * @param {String} filepath the filepath (including filename but extension type is not required)
     * @param {String} title the desired output filename. can be omitted but may encounter issues if the resulting file is the same name as the input file
     */
    reencode(filepath, title?) {
        if this.URL = "" && !IsSet(title)
            return false
        splitFilePath := obj.SplitPath(filepath)
        ytTitle := (this.URL != "" && !IsSet(title)) ? getHTMLTitle(this.URL) : title
        if !FileExist(splitFilePath.dir "\" splitFilePath.NameNoExt ".*")
            return false
        ext := ""
        loop files splitFilePath.dir "\*.*", "F" {
            if A_LoopFileName != splitFilePath.NameNoExt "." A_LoopFileExt
                continue
            ext := "." A_LoopFileExt
        }
        ffmpeg().reencode_h26x(splitFilePath.dir "\" splitFilePath.NameNoExt ext, ytTitle)
        FileDelete(splitFilePath.dir "\" splitFilePath.NameNoExt ext)
    }

    /**
     * ## This function requires [yt-dlp](https://github.com/yt-dlp/yt-dlp) to be installed correctly on the users system
     * ### If this function is called more than once and before the previous instance is able to begin downloading, both instances may error out.
     * This function will either downloaded the value passed into parameter `URL` or will attempt to read the user's clipboard in the event that parameter has not been set.
     *
     * @param {String} [args=""] is any arguments you wish to pass to yt-dlp
     * @param {String} [folder=A_ScriptDir] is the folder you wish the files to save. By default it's this scripts directory
     * @param {String} [URL?] pass through a URL instead of using the user's clipboard
     * @param {Boolean} [openDirOnFinish=true] determines whether the destination directory will be opened once the download process is complete. Defaults to `true`
     * @param {String/boolean} [postArgs=this.defaultPostProcess] any cmdline args you wish to execute after the initial download. By default this process will determine the codec of the downloaded file and if it isn't `h264` or `h265` it will reencode the file to `h264`. *Please note:* If you pass custom arguments to this parameter the prementioned codec check will **no longer** occur. You may also pass `false` to prevent any post download execution.
     * @returns the url
     * ```
     * ytdlp().download("", "download\path")
     * ;// default command with no passed args;
     * ;// yt-dlp -P "link\to\path" "URL"
     * ```
     */
    download(args := "", folder := A_ScriptDir, URL?, openDirOnFinish := true, postArgs := this.defaultPostProcess) {
        if (Type(args) != "string" || Type(folder) != "string") {
                ;// throw
                errorLog(TypeError("Invalid value type passed to function", -1),,, 1)
            }
        check := false
        origFold := folder
        if (StrLen(folder) = 2 && SubStr(folder, 2, 1) = ":") || (StrLen(folder) = 3 && SubStr(folder, 2, 2) =":\")
            folder := SubStr(folder, 1, 1) ":\\"
        if !DirExist(folder) ;saftey check
            folder := A_ScriptDir
        if !IsSet(URL) {
            oldClip := clip.clear()
            SendInput("^c")
            sleep 300
            if !this.__checkClipboard(A_Clipboard, oldClip.storedClip, args, folder) {
                if response := MsgBox("The clipboard may not contain a URL verified to work with yt-dlp.`n`nClipboard: " A_Clipboard "`nDo you wish to attempt the download anyway?", "Attempt Download?", "4 16 256 4096") = "No" {
                    clip.returnClip(oldClip)
                    return this.URL
                }
            }
        }
        else {
            for v in this.links {
                if InStr(URL, v) {
                    this.check := true
                    this.URL := URL
                    break
                }
            }
            if !this.check {
                if response := MsgBox("The clipboard may not contain a URL verified to work with yt-dlp.`n`nDo you wish to attempt the download anyway?", "Attempt Download?", "4 16 256 4096") = "No" {
                    return URL
                }
                this.URL := URL
            }
        }

        ;// checking if filename already exists
        mNotifyGUI_Prog := Notify.Show(, 'Determining name of the output file...', 'C:\Windows\System32\imageres.dll|icon86', 'Windows Balloon',, 'dur=6 maxW=400 bdr=0x75AEDC')
        try SDopt := SD_Opt()
        fileNameLengthLimit := IsSet(SDopt) ? SDopt.filenameLengthLimit : 50
        outputFileName := Format(this.defaultFilename, fileNameLengthLimit)
        nameOutput := cmd.result(Format('yt-dlp --print filename -o "{1}" "{2}" --cookies-from-browser firefox', outputFileName, this.URL))
        SplitPath(nameOutput,,, &ext, &nameNoExt)
        ext := (ext = "webm" || ext = "mkv") ? "mp4" : ext
        checkPath1 := WinGet.pathU(folder "\" nameOutput)
        checkPath2 := WinGet.pathU(folder "\" nameNoExt "." ext)
        if FileExist(checkPath1) || FileExist(checkPath2) {
            index := 1
            loop {
                if FileExist(folder "\" nameNoExt String(index) "." ext) {
                    index++
                    continue
                }
                nameNoExt := nameNoExt String(index)
                args := Format(args, nameNoExt)
                break
            }
        }
        else {
            args := Format(args, nameNoExt)
        }
        Notify.Destroy(mNotifyGUI_Prog['hwnd'])

        this.currentName := nameNoExt "." ext

        ;// building rest of command
        if this.checkClipState = true {
            this.command := Format(this.defaultCommand, args, folder, oldClip.storedClip)
            clip.returnClip(oldClip)
        }
        folderU := WinGet.pathU(origFold)
        folderU := (SubStr(folderU, -1, 1) = "\") ? SubStr(folderU, 1, StrLen(folderU)-1) : folderU
        this.command := Format(this.defaultCommand, args, folder, this.URL)

        ;// running command
        cmd.run(,,, this.command)
        ;// determine if the downloaded file is a video file
        fmpg := ffmpeg()
        fmpg.doAlert := false ;// stops the traytip
        isVideo := fmpg.isVideo(folderU "\" nameNoExt "." ext)
        switch {
            ;// determining what post args to perform
            case (isVideo = true && postArgs != false && postArgs == this.defaultPostProcess):
                ;// determining whether to use cpu encoding or gpu encoding
                fixArgs := (useNVENC() = true) ? Format(postArgs, this.defaultGPU, folderU, nameNoExt "." ext) : Format(postArgs, this.defaultCPU, folderU, nameNoExt "." ext)
                ;// determining if downloaded file needs to be reencoded
                getEncoding := cmd.result(Format('ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "{1}"', folderU "\" nameNoExt "." ext))
                if getEncoding != "h264" && getEncoding != "h265" {
                    Notify.Show(, 'Downloaded file is being reencoded to h264 for NLE compatibility', 'C:\Windows\System32\imageres.dll|icon86', 'Windows Balloon',, 'dur=6 maxW=400 bdr=0x75AEDC')
                    cmd.run(,,, fixArgs)
                }
            case (isVideo = true && postArgs != false && postArgs !== this.defaultPostProcess): cmd.run(,,, postArgs)
        }
        if openDirOnFinish = true
            switchTo.explorerHighlightFile(folder "\" nameNoExt "." ext)
        if !IsSet(URL)
            clip.returnClip(oldClip)
        return this.URL
    }

    /**
     * This function determines what a script should do once it has downloaded a file from certain websites
     * @param {String} url the url you downloaded
     * @param {String} dir the directory you downloaded to
     * @param {String} filename what you called the file when you downloaded it
     * @param {Integer} index the current index value for the current filename, in the current directory
     */
    handleDownload(url, dir, filename, index) {
        switch {
            case InStr(url, "twitch.tv"): ytdlp().reencode(dir "\" filename index, getHTMLTitle(url))
            case InStr(url, "tiktok.com"):
                newName := SubStr(url, atSymbol := InStr(url, "@",, 1, 1), InStr(url, "/",, atSymbol, 1) - atSymbol)
                getind := ytdlp().__getIndex(newName ".mp4", dir)
                newIndex := (getind = 0 || getind = "") ? "" : getind
                try FileMove(dir "\" filename index, dir "\" newName newIndex ".mp4", 1)
                return
            case InStr(url, "youtube.com"), InStr(url, "youtu.be"):
                newName := getHTMLTitle(url)
                ;// if yt-dlp needs to download an .mp4 as the highest qual video and a .webm as the highest qual audio, it'll merge them into a .mkv file
                extension := FileExist(dir "\" filename ".mkv") ? ".mkv" : ".webm"
                getind := ytdlp().__getIndex(newName extension, dir)
                newIndex := (getind = 0 || getind = "") ? "" : getind
                try FileMove(dir "\" filename index extension, dir "\" newName newIndex extension)
                ytdlp().reencode(dir "\" newName newIndex extension, getHTMLTitle(url))
                return
            default:
                newName := getHTMLTitle(url)
                getind := ytdlp().__getIndex(newName, dir)
                newIndex := (getind = 0 || getind = "") ? "" : getind
                try FileMove(dir "\" filename index, dir "\" newName newIndex ".mp4")
                return
        }
    }

    __Delete() {
        this.__finished()
    }
}