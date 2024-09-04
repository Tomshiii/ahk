/************************************************************************
 * @description a class to contain any ytdlp wrapper functions to allow for cleaner, more expandable code
 * @author tomshi
 * @date 2024/09/05
 * @version 1.0.13
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\cmd>
#Include <Classes\ffmpeg>
#Include <Classes\clip>
#Include <Classes\obj>
#Include <Classes\errorLog>
#Include <Classes\Streamdeck_opt>
#Include <Other\Notify>
#Include <Functions\getHTMLTitle>
; }


class ytdlp {

    links := [
        "https://www.youtube.com/",  "https://youtu.be/",
        "https://www.twitch.tv/",    "https://clips.twitch.tv/",
        "https://www.tiktok.com/",
        "https://www.facebook.com/", "https://www.instagram.com/",
        "https://old.reddit.com/",   "https://www.reddit.com/"
    ]
    URL := ""
    defaultCommand := 'yt-dlp {1} -P `"{2}`" `"{3}`"'
    defaultFilename := "%(title).{1}s [%(id)s].%(ext)s"
    command := ""
    check := false
    checkClipState := false

    /** generates a tooltip to alert the user the process has completed */
    __finished() => tool.tray({text: "yt-dlp process has finished", title: "yt-dlp process has completed!", options: 1}, 2000)

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
            if InStr(stored, v) {
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
     * Activates the directory
     */
    __activateDir(folder) {
        SplitPath(folder, &name)
        __determineFolder(path, name) {
            hasPath := WinExist(path " ahk_exe explorer.exe")
            noPath  := WinExist(name " ahk_exe explorer.exe")
            if !hasPath && !noPath
                return false

            hwnd := (hasPath != 0) ? hasPath : noPath
            pathStr := WinGet.ExplorerPath(hwnd)
            if pathStr == path {
                WinActivate(hwnd)
                return true
            }
            return false
        }

        if WinExist(folder " ahk_exe explorer.exe") || WinExist(name " ahk_exe explorer.exe") {
            if __determineFolder(folder, name)
                return
        }
        RunWait("explore " folder)
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
     * It will then read the users highlighted text and if a youtube (or twitch video/clip) link is found, download that link with whatever arguments are passed, if the user isn't highlighting any text or a youtube/twitch link isn't found, it will check the users clipboard instead.
     *
     * @param {String} args is any arguments you wish to pass to yt-dlp
     * @param {String} folder is the folder you wish the files to save. By default it's this scripts directory
     * @returns the url
     * ```
     * ytdlp().download("", "download\path")
     * ;// default command with no passed args;
     * ;// yt-dlp -P "link\to\path" "URL"
     * ```
     */
    download(args := "", folder := A_ScriptDir) {
        if (Type(args) != "string" || Type(folder) != "string") {
                ;// throw
                errorLog(TypeError("Invalid value type passed to function", -1),,, 1)
            }
        check := false
        if (StrLen(folder) = 2 && SubStr(folder, 2, 1) = ":") || (StrLen(folder) = 3 && SubStr(folder, 2, 2) =":\")
            folder := SubStr(folder, 1, 1) ":\\"
        if !DirExist(folder) ;saftey check
            folder := A_ScriptDir
        oldClip := clip.clear()
        this.URL := oldClip.storedClip
        SendInput("^c")
        if ClipWait(0.3) {
            if !this.__checkClipboard(A_Clipboard, oldClip.storedClip, args, folder) {
                if response := MsgBox("The clipboard may not contain a URL verified to work with yt-dlp.`n`nDo you wish to attempt the download anyway?", "Attempt Download?", "4 16 256 4096") = "No" {
                    clip.returnClip(oldClip)
                    return this.URL
                }
            }
        }

        ;// checking if filename already exists
        mNotifyGUI_Prog := Notify.Show('ytdlp', 'Determining name of output file...', 'iconi', 'Windows Balloon',, 'TC=black MC=black BC=75AEDC POS=BR show=fade@250 hide=fade@250 DUR=6')
        SDopt := SD_Opt()
        outputFileName := Format(this.defaultFilename, SDopt.filenameLengthLimit)
        nameOutput := cmd.result(Format('yt-dlp --print filename -o "{1}" "{2}"', outputFileName, this.URL))
        SplitPath(nameOutput,,,, &nameNoExt)
        checkPath1 := WinGet.pathU(folder "\" nameOutput)
        checkPath2 := WinGet.pathU(folder "\" nameNoExt ".mp4")
        if FileExist(checkPath1) || FileExist(checkPath2) {
            index := 1
            loop {
                if FileExist(folder "\" nameNoExt String(index) ".webm") || FileExist(folder "\" nameNoExt String(index) ".mp4") {
                    index++
                    continue
                }
                args := Format(args, nameNoExt index)
                break
            }
        }
        else {
            args := Format(args, outputFileName)
        }
        Notify.Destroy(mNotifyGUI_Prog['hwnd'])

        ;// building rest of command
        if this.checkClipState = true {
            this.command := Format(this.defaultCommand, args, folder, oldClip.storedClip)
            clip.returnClip(oldClip)
        }
        this.command := Format(this.defaultCommand, args, folder, this.URL)
        cmd.run(,,, this.command)
        this.__activateDir(folder)
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