; { \\ #Includes
#Include <Classes\tool>
#Include <Functions\errorLog>
#Include <Functions\getHTMLTitle>
#Include <Functions\runcmd>
#Include <Functions\SD Functions\convert2>
#Include <Classes\clip>
; }

/**
 * This function requires [yt-dlp](https://github.com/yt-dlp/yt-dlp) to be installed correctly on the users system
 * It will then read the users highlighted text and if a youtube (or twitch) link is found, download that link with whatever arguments are passed, if the user isn't highlighting any text or a youtube/twitch link isn't found, it will check the users clipboard instead
 *
 * @param {String} args is any arguments you wish to pass to yt-dlp
 * @param {String} folder is the folder you wish the files to save. By default it's this scripts directory
 * @param {Object/Boolean} conv2 determines whether you wish for the function to convert a downloaded file to another filetype. If this value is simply set to true, it will default to converting a downloaded `mkv` file to an `mp4` file. If you wish to customise this, use the below syntax
 * ```
 * ytDownload("", "download\path", {from: "webm", to: "mkv", delete: true})
 * ;//! this will download the highest quality file (usually a webm file BUT MIGHT NOT BE SO BE CAREFUL), and attempt to convert it to an mkv file
 * ```
 */
ytDownload(args := "", folder := A_ScriptDir, conv2 := true) {
    if (Type(args) != "string"   ||
        Type(folder) != "string" ||
        ((conv2 != true && conv2 != false) && !IsObject(conv2))
    )
        {
            ;// throw
            errorLog(TypeError("Invalid value type passed to function", -1),,, 1)
        }
    if !DirExist(folder) ;saftey check
        folder := A_ScriptDir
    oldClip := clip.clear()
    SendInput("^c")
    if ClipWait(0.3)
        {
            if !InStr(A_Clipboard, "https://www.youtube.com/") && !InStr(A_Clipboard, "https://www.twitch.tv/")
                goto attempt
            command := Format('yt-dlp {} -P `"{}`" `"{}`"'
                     , args, folder, A_Clipboard
                    )
            goto run
        }
    attempt:
    if !InStr(oldClip.storedClip, "https://www.youtube.com/") && !InStr(oldClip.storedClip, "https://www.twitch.tv/")
        {
            tool.Cust("Clipboard doesn't contain a youtube link")
            return
        }
    command := Format('yt-dlp {} -P `"{}`" `"{}`"'
                     , args, folder, oldClip.storedClip
                    )
    clip.returnClip(oldClip)
    run:
    runcmd(,, command)
    SplitPath(folder, &name)
    if WinExist(folder " ahk_exe explorer.exe")
        WinActivate(folder " ahk_exe explorer.exe")
    else if WinExist(name " ahk_exe explorer.exe")
        WinActivate(name " ahk_exe explorer.exe")
    else
        RunWait("explore " folder)
    getId := WinGetID("A")
    ;// the below block converts the downloaded file from mkv to mp4 if the user has it set to true
    if (conv2 = true || IsObject(conv2))
        {
            knownTypes := ["mkv", "mp4", "webm"]
            dlFileType   := (IsObject(conv2) && conv2.HasOwnProp("from"))   ? conv2.from   : "mkv"
            convFileType := (IsObject(conv2) && conv2.HasOwnProp("to"))     ? conv2.to     : "mp4"
            doDelete     := (IsObject(conv2) && conv2.HasOwnProp("delete")) ? conv2.delete : true
            ;// check to make sure the user is passing known working filetypes
            for value in knownTypes
                {
                    if dlFileType = value
                        fromContains := 1
                    if convFileType = value
                        toContains := 1
                    if IsSet(fromContains) && IsSet(toContains)
                        break
                    if A_Index = knownTypes.Length
                        {
                            alert := MsgBox("One or both of the passed filetypes aren't confirmed to work with this function, do you wish to continue?", "Error", "4 4096")
                            if alert = "No"
                                return
                        }
                }
            ;//* convert from downloaded filetype to the specified type

            ;// get the path of the explorer window
            expPath := WinGet.ExplorerPath(getId)
            ;// get title of url
            URLTitle := RTrim(getHTMLTitle(A_Clipboard), " - YouTube")
            ;// determine if title is a full length video or a short
            if InStr(URLTitle, "watch?v=")
                fileTitle := URLTitle " [" SubStr(A_Clipboard, InStr(A_Clipboard, "=",, 1, 1) + 1) "]"
            else
                fileTitle := URLTitle " [" SubStr(A_Clipboard, InStr(A_Clipboard, "/shorts/",, 1, 1) + 8) "]"
            ;// check to make sure the download suceeded
            if FileExist(expPath "\" fileTitle "." dlFileType)
                {
                    convert2(Format('ffmpeg -i `"{}.{}`" -codec copy `"{}.{}`"', fileTitle, dlFileType, URLTitle, convFileType))
                    sleep 1000
                    ;// check if the user wants the dl file to be deleted
                    if doDelete != true
                        return
                    if FileExist(expPath "\" fileTitle "." convFileType) || FileExist(expPath "\" URLTitle "." convFileType)  ;// ensure the conver2() worked before deleting
                        FileDelete(expPath "\" fileTitle "." dlFileType)
                }
        }
    clip.returnClip(oldClip)
}