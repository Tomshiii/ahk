#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_opt>
; }

SDopt := SD_Opt()
if !DirExist(SDopt.sfxFolder)
    return
storedClip := A_Clipboard

;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"
ytdlp().download(Format('-N 8 -o "{1}" --verbose --windows-filenames --extract-audio --audio-format wav', "{}"), SDopt.sfxFolder, storedClip)