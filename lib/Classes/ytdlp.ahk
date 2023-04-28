/************************************************************************
 * @description a class to contain any ytdlp wrapper functions to allow for cleaner, more expandable code
 * @author tomshi
 * @date 2023/04/25
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\cmd>
#Include <Classes\ffmpeg>
#Include <Classes\clip>
#Include <Classes\obj>
#Include <Functions\errorLog>
#Include <Functions\getHTMLTitle>
; }


class ytdlp {

    links := ["https://www.youtube.com/", "https://www.twitch.tv/", "https://clips.twitch.tv/", "https://youtu.be/"]
    URL := ""
    defaultCommand := 'yt-dlp {1} -P `"{2}`" `"{3}`"'
    command := ""
    check := false
    checkClipState := false

    /** generates a tooltip to alert the user the process has completed */
    __finished() => tool.tray({text: "yt-dlp process has finished", title: "ffmpeg process has completed!", options: 1}, 2000)

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
        ffmpeg().convert2_h264(splitFilePath.dir "\" splitFilePath.NameNoExt "." ext, splitFilePath.dir "\" ytTitle)
        FileDelete(splitFilePath.dir "\" splitFilePath.NameNoExt "." ext)
    }

    /**
     * This function requires [yt-dlp](https://github.com/yt-dlp/yt-dlp) to be installed correctly on the users system
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
        cmd.run(,, this.command)
        this.__activateDir(folder)
        clip.returnClip(oldClip)
        tool.tray({text: "ytdlp process has finished", title: A_ThisFunc "()", options: 1}, 2000)
        return this.URL
    }

    __Delete() {
        this.__finished()
    }
}
