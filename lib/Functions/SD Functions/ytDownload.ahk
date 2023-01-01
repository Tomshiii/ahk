; { \\ #Includes
#Include <Classes\tool>
#Include <Functions\errorLog>
#Include <Functions\getHTMLTitle>
#Include <Functions\SD Functions\convert2>
; }

/**
 * This function requires yt-dlp(https://github.com/yt-dlp) to be installed correctly on the users system
 * It will then read the users highlighted text and if a youtube (or twitch) link is found, download that link with whatever arguments are passed, if the user isn't highlighting any text or a youtube/twitch link isn't found, it will check the users clipboard instead
 *
 * @param args is any arguments you wish to pass to yt-dlp
 * @param folder is the folder you wish the files to save. By default it's this scripts directory
 */
ytDownload(args := "", folder := A_ScriptDir) {
    if Type(args) != "string" || Type(folder) != "string"
        {
            ;// throw
            errorLog(TypeError("Invalid parameter type in Parameter #1", -1),,, 1)
        }
    if !DirExist(folder) ;saftey check
        folder := A_ScriptDir
    oldClip := A_ClipBoard
    A_Clipboard := ""
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
    if !InStr(oldClip, "https://www.youtube.com/") && !InStr(oldClip, "https://www.twitch.tv/")
        {
            tool.Cust("Clipboard doesn't contain a youtube link")
            return
        }
    command := Format('yt-dlp {} -P `"{}`" `"{}`"'
                     , args, folder, oldClip
                    )
    A_Clipboard := oldClip
    run:
    RunWait(A_ComSpec " /c " command)
    SplitPath(folder, &name)
    if WinExist(folder " ahk_exe explorer.exe")
        WinActivate(folder " ahk_exe explorer.exe")
    else if WinExist(name " ahk_exe explorer.exe")
        WinActivate(name " ahk_exe explorer.exe")
    else
        Run("explore " folder)
    ;// convert mkv to mp4
    expPath := WinGet.ExplorerPath(WinActive("A"))
    URLTitle := RTrim(getHTMLTitle(A_Clipboard), " - YouTube")
    fileTitle := URLTitle " [" SubStr(A_Clipboard, InStr(A_Clipboard, "=",, 1, 1) + 1) "]"
    if FileExist(expPath "\" fileTitle ".mkv")
        {
            convert2(Format('ffmpeg -i `"{}.mkv`" -codec copy `"{}.mp4`"', fileTitle, URLTitle))
            sleep 1000
            if FileExist(expPath "\" fileTitle ".mp4") || FileExist(expPath "\" URLTitle ".mp4") ;// ensure the conver2() worked before deleting
                FileDelete(expPath "\" fileTitle ".mkv")
        }
    A_Clipboard := oldClip
}