; { \\ #Includes
#Include <Classes\tool>
; }

/**
 * This function requires yt-dlp(https://github.com/yt-dlp) to be installed correctly on the users system
 * It will then read the users clipboard and if a youtube (or twitch) link is found, download that link with whatever arguments are passed
 *
 * @param args is any arguments you wish to pass to yt-dlp
 * @param folder is the folder you wish the files to save. By default it's this scripts directory
 */
ytDownload(args := "", folder := A_ScriptDir) {
    if !DirExist(folder) ;saftey check
        folder := A_ScriptDir
    folderCode := "-P " '"' folder '" '
    command := "yt-dlp " args A_Space folderCode '"' A_ClipBoard '"'
    if !InStr(A_Clipboard, "https://www.youtube.com/") && !InStr(A_Clipboard, "https://www.twitch.tv/")
        {
            tool.Cust("Clipboard doesn't contain a youtube link")
            return
        }
    RunWait(A_ComSpec " /c " command)
}