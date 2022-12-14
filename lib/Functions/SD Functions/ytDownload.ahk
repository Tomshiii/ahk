; { \\ #Includes
#Include <Classes\tool>
; }

/**
 * This function requires yt-dlp(https://github.com/yt-dlp) to be installed correctly on the users system
 * It will then read the users highlighted text and if a youtube (or twitch) link is found, download that link with whatever arguments are passed, if the user isn't highlighting any text or a youtube/twitch link isn't found, it will check the users clipboard instead
 *
 * @param args is any arguments you wish to pass to yt-dlp
 * @param folder is the folder you wish the files to save. By default it's this scripts directory
 */
ytDownload(args := "", folder := A_ScriptDir) {
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
    command := Format("yt-dlp {} {} `"{}`""
                     , args, folderCode, oldClip
                    )
    run:
    RunWait(A_ComSpec " /c " command)
    SplitPath(folder, &name)
    if WinExist(folder)
        WinActivate(folder)
    else if WinExist(name " ahk_exe explorer.exe")
        WinActivate(name " ahk_exe explorer.exe")
    else
        Run("explore " folder)
}