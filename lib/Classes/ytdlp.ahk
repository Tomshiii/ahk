/************************************************************************
 * @description a class to contain any ytdlp wrapper functions to allow for cleaner, more expandable code
 * @author tomshi
 * @date 2023/10/23
 * @version 1.0.5
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\cmd>
#Include <Classes\ffmpeg>
#Include <Classes\clip>
#Include <Classes\obj>
#Include <Classes\errorLog>
#Include <Functions\getHTMLTitle>
; }


class ytdlp {

    links := ["https://www.youtube.com/", "https://www.twitch.tv/", "https://clips.twitch.tv/", "https://youtu.be/", "https://www.tiktok.com"]
    URL := ""
    defaultCommand := 'yt-dlp {1} -P `"{2}`" `"{3}`"'
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
        if WinExist(folder " ahk_exe explorer.exe")
            WinActivate(folder " ahk_exe explorer.exe")
        else if WinExist(name " ahk_exe explorer.exe")
            WinActivate(name " ahk_exe explorer.exe")
        else
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
        loop files splitFilePath.dir "\*.*", "F" {
            if A_LoopFileName != splitFilePath.NameNoExt "." A_LoopFileExt
                continue
            ext := A_LoopFileExt
        }
        ffmpeg().reencode_h26x(splitFilePath.dir "\" splitFilePath.NameNoExt "." ext, ytTitle)
        FileDelete(splitFilePath.dir "\" splitFilePath.NameNoExt "." ext)
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
        if !DirExist(folder) ;saftey check
            folder := A_ScriptDir
        oldClip := clip.clear()
        this.URL := oldClip.storedClip
        SendInput("^c")
        if ClipWait(0.3) {
            if !this.__checkClipboard(A_Clipboard, oldClip.storedClip, args, folder)
                return this.URL
        }
        if this.checkClipState = true {
            this.command := Format(this.defaultCommand, args, folder, oldClip.storedClip)
            clip.returnClip(oldClip)
        }
        this.command := Format(this.defaultCommand, args, folder, this.URL)
        cmd.run(,,, this.command)
        this.__activateDir(folder)
        clip.returnClip(oldClip)
        tool.tray({text: "ytdlp process has finished", title: A_ThisFunc "()", options: 1}, 2000)
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
            case InStr(url, "youtube.com"):
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
